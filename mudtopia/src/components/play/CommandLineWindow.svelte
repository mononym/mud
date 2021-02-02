<script>
  import { prevent_default, tick } from "svelte/internal";
  import {
    buildHotkeyStringFromEvent,
    buildHotkeyStringFromRecord,
  } from "../../utils/utils";
  import { onDestroy, onMount } from "svelte";
  import tippy from "tippy.js";
  import "tippy.js/dist/tippy.css";
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const { channel, selectedCharacter, appendNewStoryMessage } = state;

  export let input = "";
  let actualInput = "";
  let commandLineDiv;
  let commandHistory = [];
  let workingInput = "";
  let commandHistoryIndex = 0;
  let commandHistoryLength = 1000;
  let inputMode = "command";
  let tippyInstance;

  function toggleInputMode() {
    if (inputMode == "command") {
      inputMode = "speak";
      tippyInstance.setContent("Speaking Mode");
    } else {
      inputMode = "command";
      tippyInstance.setContent("Command Mode");
    }
  }

  onMount(() => {
    actualInput = input;

    commandLineDiv.addEventListener("keydown", (event) => {
      if (event.key == "Enter" && !event.shiftKey) {
        // prevent default behavior
        event.preventDefault();
        // Submit command
        submitPlayerInput();
        commandHistoryIndex = -1;
      } else if (event.key == "ArrowUp") {
        event.preventDefault();

        if (commandHistory.length - 1 > commandHistoryIndex) {
          commandHistoryIndex++;
        }

        if (commandHistory.length == 0) {
          return;
          // if there is existing input we don't want to lose it, so move to a special holder
        } else if (commandHistoryIndex == 0) {
          workingInput = actualInput;
        }

        if (commandHistory.length - 1 >= commandHistoryIndex) {
          actualInput = commandHistory[commandHistoryIndex];
        }
      } else if (event.key == "ArrowDown") {
        prevent_default(event);

        if (commandHistory.length == 0 || commandHistoryIndex == -1) {
          return;
        } else {
          commandHistoryIndex--;
        }

        if (commandHistoryIndex == -1) {
          actualInput = workingInput;
          workingInput = "";
        } else {
          actualInput = commandHistory[commandHistoryIndex];
        }
      } else {
        commandHistoryIndex = 0;
      }
    });

    normalizeCustomHotkeys();
    setupHotkeyWatcher();
    commandLineDiv.focus();

    tippyInstance = tippy(
      document.querySelector(".CommandLineWindowInputTypeButton"),
      {
        content: inputMode == "command" ? "Command Mode" : "Speaking Mode",
      }
    );
  });

  $: $selectedCharacter.settings.customHotkeys, normalizeCustomHotkeys();

  function submitPlayerInput() {
    $channel.push("cli", { text: actualInput });
    commandHistory.unshift(actualInput);

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
  <button
    on:click={toggleInputMode}
    class="CommandLineWindowInputTypeButton hover:bg-gray-400 hover:text-white text-gray-200 bg-transparent active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 outline-none focus:outline-none border-r"
    type="button"
    style="width:50px"
  >
    <i class="fas fa-{inputMode == 'command' ? 'terminal' : 'comment-alt'}" />
  </button>
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
