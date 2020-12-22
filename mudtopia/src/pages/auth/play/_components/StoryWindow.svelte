<script>
  import { onMount, tick } from "svelte";

  let view = "current";

  let currentStoryWindowDiv;

  let historyStoryWindowDiv;

  var currentStoryWindowLastScrollTop = 0;

  var historyStoryWindowLastScrollTop = 0;

  var hasScrolledHistoryWindow = false;

  // element should be replaced with the actual target element on which you have applied scroll, use window in case of no target element.
  // element.addEventListener("scroll", function(){ // or window.addEventListener("scroll"....
  //  var st = window.pageYOffset || document.documentElement.scrollTop; // Credits: "https://github.com/qeremy/so/blob/master/so.dom.js#L426"
  // if (st > currentStoryWindowLastScrollTop) {
  //   // downscroll code
  // } else {
  //   // upscroll code
  // }
  // currentStoryWindowLastScrollTop = st <= 0 ? 0 : st; // For Mobile or negative scrolling
  // }, false);

  onMount(() => {
    scrollToBottom(currentStoryWindowDiv);
    currentStoryWindowLastScrollTop = currentStoryWindowDiv.scrollTop;
    historyStoryWindowLastScrollTop =
      historyStoryWindowDiv != undefined ? historyStoryWindowDiv.scrollTop : 0;
    // var isMouseScroll = false;

    // currentStoryWindowDiv.addEventListener("wheel", function (e) {
    //   console.log("mouse wheel");
    //   isMouseScroll = true;
    // });

    // currentStoryWindowDiv.addEventListener("scroll", function (e) {
    //   if (!isMouseScroll) {
    //     console.log("scroll");
    //   }

    // isMouseScroll = false;
    // });
  });

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
      view = "current";
    } else if (
      !hasScrolledHistoryWindow &&
      newScrollTop != getActualScrollHeight(historyStoryWindowDiv)
    ) {
      hasScrolledHistoryWindow = true;
    }

    historyStoryWindowLastScrollTop = newScrollTop >= 0 ? newScrollTop : 0;
  }

  // Scrolling the main window upwards should trigger the display of the history window.
  async function handleStoryWindowCurrentViewScrollEvent(event) {
    // If the history window is already open, make scrolling effectively a no-op
    if (view == "history") {
      scrollToBottom(currentStoryWindowDiv);
    } else {
      var newScrollTop = currentStoryWindowDiv.scrollTop;

      if (newScrollTop > currentStoryWindowLastScrollTop) {
        // downscroll code
      } else {
        // upscroll code
        scrollToBottom(currentStoryWindowDiv);
        if (view != "history") {
          view = "history";
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

  function toggleHistoryView() {
    if (view == "history") {
      view = "current";
    } else {
      view = "history";
    }
  }
</script>

<div class="h-full w-full flex flex-col relative">
  {#if view == 'history'}
    <i
      on:click={toggleHistoryView}
      class="mt-2 mr-5 absolute fas fa-eye-slash text-red-300 cursor-pointer"
      style="right:0" />
    <div
      on:scroll={handleHistoryWindowCurrentViewScrollEvent}
      bind:this={historyStoryWindowDiv}
      id="StoryWindowHistoryView"
      class="flex-1 flex flex-col overflow-y-scroll">
      <p>This is history0.</p>
      <p>This is more recent history1.</p>
      <p>This is more recent history2.</p>
      <p>This is more recent history3.</p>
      <p>This is more recent history4.</p>
      <p>This is more recent history5.</p>
      <p>This is more recent history6.</p>
      <p>This is more recent history7.</p>
      <p>This is more recent history8.</p>
      <p>This is more recent history9.</p>
      <p>This is more recent history0.</p>
      <p>This is more recent history1.</p>
      <p>This is more recent history2.</p>
      <p>This is more recent history3.</p>
      <p>This is more recent history4.</p>
      <p>This is more recent history5.</p>
      <p>This is more recent history6.</p>
      <p>This is more recent history7.</p>
      <p>This is more recent history8.</p>
      <p>This is more recent history9.</p>
      <p>This is more recent history0.</p>
      <p>This is more recent history1.</p>
      <p>This is more recent history2.</p>
      <p>This is more recent history3.</p>
      <p>This is more recent history4.</p>
      <p>This is more recent history5.</p>
      <p>This is more recent history6.</p>
      <p>This is more recent history7.</p>
      <p>This is more recent history8.</p>
      <p>This is more recent history9.</p>
      <p>This is more recent history0.</p>
      <p>Bottom.</p>
    </div>
  {:else}
    <i
      on:click={toggleHistoryView}
      class="mt-2 mr-2 absolute fas fa-eye text-red-300 cursor-pointer"
      style="right:0" />
  {/if}
  <div class="flex-1 overflow-hidden">
    <div
      on:scroll={handleStoryWindowCurrentViewScrollEvent}
      bind:this={currentStoryWindowDiv}
      id="StoryWindowCurrentView"
      class="h-full flex flex-col overflow-y-scroll ml-2 mb-2 mr-2"
      style="width:calc(100% + 15px)">
      <p>This is an example game prompt.</p>
      <p>So is this, and should come right below the above.</p>
      <p>So is this, and should come right below the above.</p>
      <p>So is this, and should come right below the above.</p>
      <p>So is this, and should come right below the above.</p>
      <p>So is this, and should come right below the above.</p>
      <p>So is this, and should come right below the above.</p>
      <p>So is this, and should come right below the above.</p>
      <p>So is this, and should come right below the above.</p>
      <p>So is this, and should come right below the above.</p>
      <p>So is this, and should come right below the above.</p>
      <p>So is this, and should come right below the above.</p>
      <p>So is this, and should come right below the above.</p>
      <p>Bottom.</p>
    </div>
  </div>
</div>
