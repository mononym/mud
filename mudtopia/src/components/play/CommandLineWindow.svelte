<script>
  import { onMount } from "svelte";
  import { State } from "./state";
  const { channel, showHistoryWindow, selectedCharacter } = State;

  export let input = "";
  let actualInput = "";
  let commandLineDiv;
  let commandHistory = [];
  $: commandHistoryReversed = commandHistory.reverse();
  let workingInput = "";
  let commandHistoryIndex = 0;
  let commandHistoryLength = 1000;

  onMount(() => {
    actualInput = input;

    commandLineDiv.addEventListener("keydown", (event) => {
      if (event.key == "Enter" && !event.shiftKey) {
        // prevent default behavior
        event.preventDefault();
        // Submit command
        submitPlayerInput();
      } else if (event.key == "PageUp") {
        event.preventDefault();
        showHistoryWindow();
      } else if (event.key == "ArrowUp") {
        event.preventDefault();
        console.log(actualInput);
        console.log(commandHistoryIndex);

        if (commandHistoryIndex == -1) {
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

          if (commandHistory.length - 1 > commandHistoryIndex) {
            commandHistoryIndex++;
          }
          console.log(commandHistoryIndex);
        }
      } else if (event.key == "ArrowDown") {
        event.preventDefault();
        console.log(commandHistoryIndex);

        if (commandHistory.length == 0 || commandHistoryIndex == -1) {
          return;
        } else if (commandHistoryIndex == 0) {
          actualInput = workingInput;
          workingInput = "";

          commandHistoryIndex--;
        } else {
          commandHistoryIndex--;
          actualInput = commandHistory[commandHistoryIndex];

          console.log(commandHistoryIndex);
        }
      } else {
        commandHistoryIndex = 0;
      }
    });

    commandLineDiv.focus();
  });

  function submitPlayerInput() {
    $channel.push("cli", { text: actualInput });
    commandHistory.unshift(actualInput);

    actualInput = "";
  }
</script>

<div class="commandlineWrapper h-full w-full flex pl-1 pb-1 pr-1">
  <button
    class="hover:bg-gray-400 hover:text-white text-gray-200 bg-transparent border border-solid border-gray-400 active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
    type="button"
    style="transition: all .15s ease">
    <i class="fas fa-comment-alt" />
  </button>
  <form class="flex-1 flex">
    <textarea
      bind:this={commandLineDiv}
      on:submit|preventDefault={submitPlayerInput}
      bind:value={actualInput}
      class="flex-grow"
      style="resize:none;color:{$selectedCharacter.settings.colors.input};background-color:{$selectedCharacter.settings.colors.input_background}" />
  </form>
</div>
