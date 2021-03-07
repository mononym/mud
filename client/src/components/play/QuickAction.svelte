<script>
  import tippy from "tippy.js";
  import "tippy.js/dist/tippy.css";
  import { onMount } from "svelte";
  import { getContext } from "svelte";
  import { key } from "./state";
  export let active = true;
  export let icon = "";
  export let activeTooltip = "";
  export let inactiveTooltip = "";
  export let cliInput = "";
  export let storyOutput = "";
  export let activeIconColor = "";
  export let inactiveIconColor = "";
  let tippyInstance;
  let iconDiv;

  $: active, updateTooltip();

  function updateTooltip() {
    if (tippyInstance != undefined) {
      tippyInstance.setContent(active ? activeTooltip : inactiveTooltip);
    }
  }

  const state = getContext(key);
  const { channel, selectedCharacter, appendNewStoryMessage } = state;

  function submitPlayerInput() {
    $channel.push("cli", { text: cliInput });

    if ($selectedCharacter.settings.echo.ui_commands_in_story) {
      if ($selectedCharacter.settings.echo.ui_commands_replace_ids_in_story) {
        appendNewStoryMessage({
          segments: [{ type: "echo", text: `> ${storyOutput}` }],
        });
      } else {
        appendNewStoryMessage({
          segments: [{ type: "echo", text: `> ${cliInput}` }],
        });
      }
    }
  }

  onMount(() => {
    tippyInstance = tippy(iconDiv, {
      content: active ? activeTooltip : inactiveTooltip,
    });
  });
</script>

<i
  on:click={submitPlayerInput}
  bind:this={iconDiv}
  class="{icon} fa-lg fa-fw self-center"
  style="color:{active ? activeIconColor : inactiveIconColor}"
/>
