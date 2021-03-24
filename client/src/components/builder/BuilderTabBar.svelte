<script>
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const {
    builderTab,
    selectBuilderTabMapsAndAreas,
    selectBuilderTabShops,
    selectBuilderTabItems,
  } = state;
</script>

<nav class="bg-gray-700 flex-shrink">
  <div class="flex items-baseline space-x-4">
    <button
      on:click={selectBuilderTabMapsAndAreas}
      class="px-3 py-2 text-sm font-medium {$builderTab == 'mapsAndAreas'
        ? 'text-white border-accent border-b-2 focus:outline-none'
        : 'text-gray-300 hover:text-white hover:bg-gray-600'} "
      >Maps and Areas</button
    >

    <button
      on:click={selectBuilderTabShops}
      class="px-3 py-2 text-sm font-medium {$builderTab == 'shops'
        ? 'text-white border-accent border-b-2 focus:outline-none'
        : 'text-gray-300 hover:text-white hover:bg-gray-600'}">Shops</button
    >

    <button
      on:click={selectBuilderTabItems}
      class="px-3 py-2 text-sm font-medium {$builderTab == 'items'
        ? 'text-white border-accent border-b-2 focus:outline-none'
        : 'text-gray-300 hover:text-white hover:bg-gray-600'}">Items</button
    >
  </div>
</nav>
