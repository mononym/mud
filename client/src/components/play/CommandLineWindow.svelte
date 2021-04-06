<script>
  import { prevent_default, tick } from "svelte/internal";
  import {
    buildHotkeyStringFromEvent,
    buildHotkeyStringFromRecord,
  } from "../../utils/utils";
  import { onDestroy, onMount } from "svelte";
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const { channel, selectedCharacter, appendNewStoryMessage } = state;

  export let input = "";
  let actualInput = "";
  let commandLineDiv;
  let commandHistory = [];
  let commandHistoryIndex = -1;
  let commandHistoryMaxLength = 1000;

  onMount(() => {
    actualInput = input;
    let workingInput = "";

    commandLineDiv.addEventListener("keydown", (event) => {
      if (event.key == "Enter" && !event.shiftKey) {
        // prevent default behavior
        event.preventDefault();
        // Submit command
        submitPlayerInput();
        commandHistoryIndex = -1;
      } else if (event.key == "ArrowUp") {
        event.preventDefault();

        if (commandHistoryIndex == -1) {
          workingInput = actualInput;
        }

        if (
          commandHistory.length != 0 &&
          commandHistory.length - 1 > commandHistoryIndex
        ) {
          actualInput = commandHistory[++commandHistoryIndex];
        } else if (
          commandHistory.length == 0 ||
          commandHistory.length - 1 == commandHistoryIndex
        ) {
          return;
        }
      } else if (event.key == "ArrowDown") {
        event.preventDefault();

        if (commandHistory.length != 0 && commandHistoryIndex == 0) {
          actualInput = workingInput;
          workingInput = "";
          --commandHistoryIndex;
        } else if (commandHistory.length == 0 || commandHistoryIndex == -1) {
          return;
        } else {
          actualInput = commandHistory[--commandHistoryIndex];
        }
      } else {
        commandHistoryIndex = -1;
      }
    });

    normalizeCustomHotkeys();
    setupHotkeyWatcher();
    commandLineDiv.focus();
  });

  $: $selectedCharacter.settings.customHotkeys, normalizeCustomHotkeys();

  function submitPlayerInput() {
    actualInput.trim();
    $channel.push("cli", { text: actualInput });

    if (commandHistory[0] != actualInput) {
      commandHistory.unshift(actualInput);
    }

    if ($selectedCharacter.settings.echo.cli_commands_in_story) {
      appendNewStoryMessage({
        segments: [{ type: "echo", text: `> ${actualInput}` }],
      });
    }

    actualInput = "";
  }

  onDestroy(() => {
    teardownHotkeyWatcher();
  });

  function setupHotkeyWatcher() {
    commandLineDiv.addEventListener("keydown", maybeHandleCustomHotkey);
  }

  function teardownHotkeyWatcher() {
    commandLineDiv.removeEventListener("keydown", maybeHandleCustomHotkey);
  }

  let normalizedCustomHotkeys = {};

  function normalizeCustomHotkeys() {
    normalizedCustomHotkeys = {};
    $selectedCharacter.settings.customHotkeys.forEach((hotkey) => {
      const hotkeyString = buildHotkeyStringFromRecord(hotkey);
      hotkey.string = hotkeyString;
      normalizedCustomHotkeys[hotkey.string] = hotkey.command;
    });
  }

  function maybeHandleCustomHotkey(event) {
    const potentialHotkeyString = buildHotkeyStringFromEvent(event);

    if (potentialHotkeyString in normalizedCustomHotkeys) {
      event.preventDefault();

      const commandString = normalizedCustomHotkeys[potentialHotkeyString];

      $channel.push("cli", { text: commandString });
      commandHistory.unshift(commandString);

      if ($selectedCharacter.settings.echo.hotkey_commands_in_story) {
        appendNewStoryMessage({
          segments: [{ type: "echo", text: `> ${commandString}` }],
        });
      }
    }
  }
</script>

<div class="commandlineWrapper h-full w-full flex">
  <form class="flex-1 flex">
    <textarea
      id="cli"
      bind:this={commandLineDiv}
      on:submit|preventDefault={submitPlayerInput}
      bind:value={actualInput}
      class="flex-grow"
      style="resize:none;color:{$selectedCharacter.settings.colors
        .input};background-color:{$selectedCharacter.settings.colors
        .input_background}"
    />
  </form>
</div>
