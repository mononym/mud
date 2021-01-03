<script>
  import SettingsTabBar from "./SettingsTabBar.svelte";
  import SettingsTextView from "./SettingsTextView.svelte";
  import { State } from "./state";
  const { settingsView, view } = State;
</script>

<div class="flex flex-col" hidden={$view != 'settings'}>
  <SettingsTabBar />
  {#if $settingsView == 'text'}
    <SettingsTextView />
  {/if}
</div>
