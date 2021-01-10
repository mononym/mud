<script>
  import { onMount, tick } from "svelte";
  import { State } from "./state";
  const {
    channel,
    selectedCharacter,
    storyWindowMessages,
    historyWindowMessages,
    showHistoryWindow,
    hideHistoryWindow,
    storyWindowView,
    appendNewStoryMessage,
  } = State;

  let currentStoryWindowDiv;

  let historyStoryWindowDiv;

  var currentStoryWindowLastScrollTop = 0;

  var hasScrolledHistoryWindow = false;

  onMount(() => {
    // console.log("mounting storywindow");
    // $channel.on("output:story", async function (msg) {
    //   console.log("received messages");
    //   console.log(msg);
    //   msg.messages.forEach((output) => {
    //     const segments = output.segments.map((segment) => {
    //       return {
    //         text: segment.text,
    //         type: segment.type,
    //       };
    //     });

    //     appendNewStoryMessage({ segments: segments });
    //   });

    //   await tick();

    //   scrollToBottom(currentStoryWindowDiv);
    // });

    scrollToBottom(currentStoryWindowDiv);
    currentStoryWindowLastScrollTop = currentStoryWindowDiv.scrollTop;
    hideHistoryWindow();
  });

  $: $storyWindowMessages, scrollMainStoryWindow();

  async function scrollMainStoryWindow() {
    if (currentStoryWindowDiv != undefined) {
      scrollToBottom(currentStoryWindowDiv);
    }
  }

  // Scrolling the main window upwards should trigger the display of the history window.
  async function handleHistoryWindowCurrentViewScrollEvent(event) {
    var newScrollTop = historyStoryWindowDiv.scrollTop;

    // Window will get shut automatically because a scroll event is triggered by the history window being sent to the
    // bottom when being shown. Making sure that the user has actually triggered a scroll fixes that.
    if (
      hasScrolledHistoryWindow &&
      newScrollTop == getActualScrollHeight(historyStoryWindowDiv)
    ) {
      // Set this back to false otherwise when it tries to reopen it will close again.
      hasScrolledHistoryWindow = false;
      hideHistoryWindow();
    } else if (
      !hasScrolledHistoryWindow &&
      newScrollTop != getActualScrollHeight(historyStoryWindowDiv)
    ) {
      hasScrolledHistoryWindow = true;
    }
  }

  // Scrolling the main window upwards should trigger the display of the history window.
  async function handleStoryWindowCurrentViewScrollEvent(event) {
    // If the history window is already open, make scrolling effectively a no-op
    if ($storyWindowView == "history") {
      scrollToBottom(currentStoryWindowDiv);
    } else {
      var newScrollTop = currentStoryWindowDiv.scrollTop;

      if (newScrollTop > currentStoryWindowLastScrollTop) {
        // downscroll code
      } else {
        // upscroll code
        scrollToBottom(currentStoryWindowDiv);
        if ($storyWindowView != "history") {
          showHistoryWindow();
          await tick();
          scrollToBottom(historyStoryWindowDiv);
        }
      }

      currentStoryWindowLastScrollTop = newScrollTop >= 0 ? newScrollTop : 0;
    }
  }

  function scrollToBottom(element) {
    element.scrollTop = getActualScrollHeight(element);
  }

  function getActualScrollHeight(element) {
    return element.scrollHeight - element.clientHeight;
  }

  function closeHistoryCallback(event) {
    if (event.key == "Escape" && $storyWindowView == "history") {
      // prevent default behavior
      event.preventDefault();
      // Submit command
      hideHistoryWindow();
    }
  }

  $: $storyWindowView, updateEventListener();
  function updateEventListener() {
    if ($storyWindowView == "history") {
      window.addEventListener("keydown", closeHistoryCallback);
    } else {
      window.removeEventListener("keydown", closeHistoryCallback);
    }
  }

  function toggleHistoryView() {
    if ($storyWindowView == "history") {
      hideHistoryWindow();
    } else {
      showHistoryWindow();
    }
  }
</script>

<div class="h-full w-full flex flex-col relative">
  {#if $storyWindowView == 'history'}
    <i
      on:click={toggleHistoryView}
      class="mt-2 mr-8 absolute fas fa-eye-slash cursor-pointer"
      style="right:0;color:{$selectedCharacter.settings.colors.story_history_icon}" />
    <div
      on:scroll={handleHistoryWindowCurrentViewScrollEvent}
      bind:this={historyStoryWindowDiv}
      id="StoryWindowHistoryView"
      class="flex-1 flex flex-col overflow-y-scroll border-b-2 pl-2"
      style="background-color:{$selectedCharacter.settings.colors.story_background};border-color:{$selectedCharacter.settings.colors.story_history_border}">
      {#each $historyWindowMessages as message}
        <pre>
        {#each message.segments as segment}
            <span
              style="color:{$selectedCharacter.settings.colors[segment.type]}">{segment.text}</span>
          {/each}
      </pre>
      {/each}
    </div>
  {:else}
    <i
      on:click={toggleHistoryView}
      class="mt-2 mr-2 absolute fas fa-eye cursor-pointer"
      style="right:0;color:{$selectedCharacter.settings.colors.story_history_icon}" />
  {/if}
  <div class="flex-1 overflow-hidden">
    <div
      on:scroll={handleStoryWindowCurrentViewScrollEvent}
      bind:this={currentStoryWindowDiv}
      id="StoryWindowCurrentView"
      class="h-full flex flex-col overflow-y-scroll ml-2 mb-2 mr-2"
      style="width:calc(100% + 15px);background-color:{$selectedCharacter.settings.colors.story_background}">
      {#each $storyWindowMessages as message}
        <pre>
          {#each message.segments as segment}
            <span
              style="color:{$selectedCharacter.settings.colors[segment.type]}">{segment.text}</span>
          {/each}
        </pre>
      {/each}
    </div>
  </div>
</div>
