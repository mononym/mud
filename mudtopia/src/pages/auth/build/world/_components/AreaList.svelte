<script>
  import { createEventDispatcher } from "svelte";

  const dispatch = createEventDispatcher();

  import { WorldBuilderStore } from "./state";
  const { selectedArea, selectedMap, view } = WorldBuilderStore;
  import { AreasStore } from "../../../../../stores/areas";
  const { areas } = AreasStore;

  $: filteredAreas = $areas.filter((area) => area.mapId == $selectedMap.id);

  function selectArea(area) {
    if (area.id != $selectedArea.id) {
      WorldBuilderStore.selectArea(area);
    }
  }

  function editArea(area) {
    if ($view != "edit") {
      $selectedArea = area;
      dispatch("editArea", area);
    }
  }

  function linkArea(area) {
    if ($view != "edit") {
      WorldBuilderStore.linkArea(area);
    }
  }

  function deleteArea(area) {
    if ($view != "edit") {
      $selectedArea = area;
      dispatch("deleteArea", area);
    }
  }
</script>

<div class="flex flex-col">
  <div class="align-middle inline-block min-w-full">
    <div class="shadow border-b border-gray-800 sm:rounded-lg">
      <table class="min-w-full divide-y divide-gray-200">
        <thead>
          <tr>
            <th
              scope="col"
              class="px-6 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Name
            </th>
            <th
              scope="col"
              class="px-6 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Description
            </th>
            <th
              scope="col"
              class="px-6 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Map X
            </th>
            <th
              scope="col"
              class="px-6 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Map Y
            </th>
            <th
              scope="col"
              class="px-6 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Map Size
            </th>
            <th
              scope="col"
              class="px-6 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Actions
            </th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          {#each filteredAreas as area, i}
            <tr
              id={area.id}
              class="{$selectedArea.id == area.id ? 'bg-gray-900' : i % 2 == 0 ? 'bg-gray-500 hover:bg-gray-700' : 'bg-gray-600 hover:bg-gray-700'} {$selectedArea.id == area.id ? 'cursor-not-allowed' : 'cursor-pointer'}"
              on:click={selectArea(area)}>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-gray-100">{area.name}</div>
              </td>
              <td class="px-6 py-4">
                <p class="text-sm text-gray-100">{area.description}</p>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-gray-100">{area.mapX}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-gray-100">{area.mapY}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-gray-100">{area.mapSize}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <button
                  on:click={linkArea(area)}
                  class="{$view == 'edit' ? 'cursor-not-allowed' : 'hover:bg-gray-400 hover:text-white'} text-gray-200 bg-transparent border border-solid border-gray-400 active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
                  type="button"
                  style="transition: all .15s ease">
                  <i class="fas fa-link" />
                  Link
                </button>
                <button
                  on:click={editArea(area)}
                  class="{$view == 'edit' ? 'cursor-not-allowed' : 'hover:bg-gray-400 hover:text-white'} text-gray-200 bg-transparent border border-solid border-gray-400 active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
                  type="button"
                  style="transition: all .15s ease">
                  <i class="fas fa-edit" />
                  Edit
                </button>
                <button
                  on:click={deleteArea(area)}
                  class="{$view == 'edit' ? 'cursor-not-allowed' : 'hover:bg-gray-400 hover:text-white'} text-gray-200 bg-transparent border border-solid border-gray-400 active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
                  type="button"
                  style="transition: all .15s ease">
                  <i class="fas fa-trash" />
                  Delete
                </button>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  </div>
</div>
