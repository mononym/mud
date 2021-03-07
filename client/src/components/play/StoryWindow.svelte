<script>
  import { onMount, tick } from "svelte";
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const {
    selectedCharacter,
    storyWindowMessages,
    historyWindowMessages,
    storyWindowView,
    hideHistoryWindow,
    toggleHistoryWindow,
  } = state;

  let currentStoryWindowDiv;

  let historyStoryWindowDiv;

  var hasScrolledHistoryWindow = false;

  onMount(() => {
    scrollToBottom(currentStoryWindowDiv);
    hideHistoryWindow();
  });

  $: $storyWindowMessages, scrollMainStoryWindow();

  async function scrollMainStoryWindow() {
    console.log("scrollMainStoryWindow");
    if (currentStoryWindowDiv != undefined) {
      await tick();
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

  function scrollToBottom(element) {
    element.scrollTop = getActualScrollHeight(element);
  }

  function getActualScrollHeight(element) {
    console.log(element);
    console.log(element.scrollHeight - element.clientHeight);
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

  async function toggleHistoryView() {
    console.log("toggleHistoryView");
    toggleHistoryWindow();
  }

  $: historyStoryWindowDiv, scrollWindows();
  async function scrollWindows() {
    if ($storyWindowView == "history" && historyStoryWindowDiv != undefined) {
      scrollToBottom(historyStoryWindowDiv);
    }

    if (currentStoryWindowDiv != undefined) {
      scrollToBottom(currentStoryWindowDiv);
    }
  }
</script>

<div class="h-full w-full flex flex-col relative">
  {#if $storyWindowView == "history"}
    <i
      on:click={toggleHistoryView}
      class="mt-2 mr-8 absolute fas fa-eye-slash cursor-pointer"
      style="right:0;color:{$selectedCharacter.settings.colors
        .story_history_icon}"
    />
    <div
      on:scroll={handleHistoryWindowCurrentViewScrollEvent}
      bind:this={historyStoryWindowDiv}
      id="StoryWindowHistoryView"
      class="flex flex-col overflow-y-scroll border-b-2 pl-2"
      style="height:{$storyWindowView == 'history'
        ? '50%'
        : '100%'};background-color:{$selectedCharacter.settings.colors
        .story_background};border-color:{$selectedCharacter.settings.colors
        .story_history_border}"
    >
      {#each $historyWindowMessages as message}
        <pre
          class="whitespace-pre-wrap mb-4">
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
      style="right:0;color:{$selectedCharacter.settings.colors
        .story_history_icon}"
    />
  {/if}
  <div
    bind:this={currentStoryWindowDiv}
    id="StoryWindowCurrentView"
    class="flex flex-col overflow-hidden w-full pl-4 pr-4 pt-4"
    style="height:{$storyWindowView == 'history'
      ? '50%'
      : '100%'};background-color:{$selectedCharacter.settings.colors
      .story_background}"
  >
    {#each $storyWindowMessages as message}
      <pre
        class="whitespace-pre-wrap mb-4">
          {#each message.segments as segment}<span
            style="color:{$selectedCharacter.settings.colors[segment.type]}">{segment.text}</span>{/each}</pre>
    {/each}
  </div>
</div>
