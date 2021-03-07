<script>
  import SettingsTabBar from "./SettingsTabBar.svelte";
  import SettingsGeneralView from "./SettingsGeneralView.svelte";
  import SettingsHotkeysView from "./SettingsHotkeysView.svelte";
  import SettingsCommandsView from "./SettingsCommandsView.svelte";

  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const { settingsView, view } = state;
</script>

<div class="flex flex-col overflow-y-auto" hidden={$view != "settings"}>
  <SettingsTabBar />
  {#if $settingsView == "general"}
    <SettingsGeneralView />
  {/if}
  {#if $settingsView == "hotkeys"}
    <SettingsHotkeysView />
  {/if}
  {#if $settingsView == "commands"}
    <SettingsCommandsView />
  {/if}
</div>
