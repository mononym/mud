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

<nav class="bg-gray-800 flex-shrink">
  <div class="flex items-baseline space-x-4">
    <button
      on:click={selectBuilderTabMapsAndAreas}
      class="px-3 py-2 rounded-md text-sm font-medium {$builderTab ==
      'mapsAndAreas'
        ? 'text-white bg-gray-900'
        : 'text-gray-300 hover:text-white hover:bg-gray-700'} "
      >Maps and Areas</button
    >

    <button
      on:click={selectBuilderTabShops}
      class="px-3 py-2 rounded-md text-sm font-medium {$builderTab == 'shops'
        ? 'text-white bg-gray-900'
        : 'text-gray-300 hover:text-white hover:bg-gray-700'}">Shops</button
    >

    <button
      on:click={selectBuilderTabItems}
      class="px-3 py-2 rounded-md text-sm font-medium {$builderTab == 'items'
        ? 'text-white bg-gray-900'
        : 'text-gray-300 hover:text-white hover:bg-gray-700'}">Items</button
    >
  </div>
</nav>
