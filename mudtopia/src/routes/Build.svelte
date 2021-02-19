<script>
  import MainNavBar from "../components/MainNavBar.svelte";
  import BuilderTabBar from "../components/builder/BuilderTabBar.svelte";
  import BuildWorldAndAreasTab from "../components/builder/BuildWorldAndAreasTab.svelte";

  import { setContext } from "svelte";
  import { createWorldBuilderStore, key } from "../components/builder/state";

  // Set up the store to be used by everyone
  const state = createWorldBuilderStore();
  setContext(key, state);

  const { builderTab } = state;
</script>

<div class="h-full w-full flex flex-col overflow-y-auto">
  <MainNavBar />
  <BuilderTabBar />
  {#if $builderTab == "mapsAndAreas"}
    <BuildWorldAndAreasTab />
  {/if}
  {#if $builderTab == "shops"}
    <BuildWorldAndAreasTab />
  {/if}
  {#if $builderTab == "items"}
    <BuildWorldAndAreasTab />
  {/if}
</div>
