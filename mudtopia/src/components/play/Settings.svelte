<script>
  import SettingsTabBar from "./SettingsTabBar.svelte";
  import SettingsColorsView from "./SettingsColorsView.svelte";
  import SettingsHotkeysView from "./SettingsHotkeysView.svelte";
  import { State } from "./state";
  const { settingsView, view } = State;
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
