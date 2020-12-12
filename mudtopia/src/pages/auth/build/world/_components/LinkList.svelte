<script>
  import { createEventDispatcher } from "svelte";

  const dispatch = createEventDispatcher();

  import { WorldBuilderStore } from "./state";
  const { selectedArea, view } = WorldBuilderStore;

  export let links = [];
  export let areasMap = {};
  export let mapsMap = {};

  function selectLink(link) {
    if (link.id != $selectedArea.id) {
      WorldBuilderStore.selectLink(link);
    }
  }

  function editLink(link) {
    if ($view != "edit") {
      $selectedArea = link;
      dispatch("editLink", link);
    }
  }

  function linklink(link) {
    if ($view != "edit") {
      WorldBuilderStore.linklink(link);
    }
  }

  function deleteLink(link) {
    if ($view != "edit") {
      $selectedArea = link;
      dispatch("deleteLink", link);
    }
  }
</script>

<div class="flex flex-col">
  <table class="divide-y divide-gray-200">
    <thead>
      <tr>
        <th
          scope="col"
          class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
          Other link
        </th>
        <th
          scope="col"
          class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
          Exit
        </th>
        <th
          scope="col"
          class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
          Arrival
        </th>
        <th
          scope="col"
          class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
          Actions
        </th>
      </tr>
    </thead>
    <tbody class="bg-white divide-y divide-gray-200">
      {#each links as link, i}
        <tr
          id={link.id}
          class="{$selectedArea.id == link.id ? 'bg-gray-900' : i % 2 == 0 ? 'bg-gray-500 hover:bg-gray-700' : 'bg-gray-600 hover:bg-gray-700'} {$selectedArea.id == link.id ? 'cursor-not-allowed' : 'cursor-pointer'}"
          on:click={selectLink(link)}>
          <td class="px-4 py-4 whitespace-nowrap">
            {#if link.toId == $selectedArea.id && areasMap[link.fromId].mapId != $selectedArea.mapId}
              <div class="text-sm text-gray-100">
                {mapsMap[areasMap[link.fromId].mapId].name}
                -
                {areasMap[link.fromId].name}
              </div>
            {:else if link.toId == $selectedArea.id && areasMap[link.fromId].mapId == $selectedArea.mapId}
              <div class="text-sm text-gray-100">
                {areasMap[link.fromId].name}
              </div>
            {:else if link.fromId == $selectedArea.id && areasMap[link.fromId].mapId != $selectedArea.mapId}
              <div class="text-sm text-gray-100">
                {mapsMap[areasMap[link.fromId].mapId].name}
                -
                {areasMap[link.fromId].name}
              </div>
            {:else if link.fromId == $selectedArea.id && areasMap[link.fromId].mapId == $selectedArea.mapId}
              <div class="text-sm text-gray-100">
                {areasMap[link.fromId].name}
              </div>
            {/if}
          </td>
          <td class="px-4 py-4">
            <p class="text-sm text-gray-100">{link.shortDescription}</p>
          </td>
          <td class="px-4 py-4 whitespace-nowrap">
            <div class="text-sm text-gray-100">{link.arrivaltext}</div>
          </td>
          <td class="px-4 py-4 whitespace-nowrap text-sm font-medium">
            <button
              on:click={editLink(link)}
              class="{$view == 'edit' ? 'cursor-not-allowed' : 'hover:bg-gray-400 hover:text-white'} text-gray-200 bg-transparent border border-solid border-gray-400 active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
              type="button"
              style="transition: all .15s ease">
              <i class="fas fa-edit" />
              Edit
            </button>
            <button
              on:click={deleteLink(link)}
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
