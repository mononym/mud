<script>
  import { onMount } from "svelte";

  export let input = "";
  let actualInput = "";
  let commandLineDiv;

  onMount(() => {
    actualInput = input;

    commandLineDiv.addEventListener("keydown", (event) => {
      if (event.key == "Enter" && !event.shiftKey) {
        // prevent default behavior
        event.preventDefault();
        // Submit command
        submitPlayerInput();
      } else {
        // Nothing to do when shift + enter is pressed but let event add the newline
      }
    });
  });

  function submitPlayerInput() {
    console.log("Submitting input");
    console.log(actualInput);
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
      style="resize:none" />
  </form>
</div>
