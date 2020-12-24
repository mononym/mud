<script>
  import { onMount, setContext, tick } from "svelte";
  import { MudClientStore } from "../../../../stores/mudClient";
  const { channel, selectedCharacter } = MudClientStore;

  let view = "current";

  let currentStoryWindowDiv;

  let historyStoryWindowDiv;

  var currentStoryWindowLastScrollTop = 0;

  var historyStoryWindowLastScrollTop = 0;

  var hasScrolledHistoryWindow = false;

  var messages = [];

  function getTextColorFromType(type) {
    if (type == "system warning") {
      return $selectedCharacter.settings.system_warning_text_color;
    } else if (type == "system danger") {
      return $selectedCharacter.settings.system_danger_text_color;
    }
  }

  onMount(() => {
    $channel.on("output:story", function (msg) {
      const textColor = getTextColorFromType(msg.type);
      messages = [
        ...messages,
        {
          color: textColor,
          text: msg.text,
        },
      ];
      console.log("Got message for story", {
        msg: msg,
        color: textColor,
        text: msg.text,
      });
    });

    $channel.push("ping", {}).receive("ok", (payload) => {
      messages = [
        {
          color: $selectedCharacter.settings.system_warning_text_color,
          text: payload.response,
        },
      ];
      console.log(messages);
    });

    scrollToBottom(currentStoryWindowDiv);
    currentStoryWindowLastScrollTop = currentStoryWindowDiv.scrollTop;
    historyStoryWindowLastScrollTop =
      historyStoryWindowDiv != undefined ? historyStoryWindowDiv.scrollTop : 0;
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
      class="flex-1 flex flex-col overflow-y-scroll border-b-2" />
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
      {#each messages as message}
        <p style="color:{message.color}">{message.text}</p>
      {/each}
    </div>
  </div>
</div>
