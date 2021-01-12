<script>
  import SettingsTabBar from "./SettingsTabBar.svelte";
  import SettingsColorsView from "./SettingsColorsView.svelte";
  import SettingsHotkeysView from "./SettingsHotkeysView.svelte";

  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const { settingsView, view } = state;
</script>

<div class="flex flex-col" hidden={$view != 'settings'}>
  <SettingsTabBar />
  {#if $settingsView == 'colors'}
    <SettingsColorsView />
  {/if}
  {#if $settingsView == 'hotkeys'}
    <SettingsHotkeysView />
  {/if}
</div>
