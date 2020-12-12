<script>
  import { createEventDispatcher } from "svelte";

  const dispatch = createEventDispatcher();

  import { WorldBuilderStore } from "./state";
  const { selectedArea, selectedLink, view } = WorldBuilderStore;

  export let links = [];
  export let areasMap = {};
  export let mapsMap = {};
  export let showExit = true;
  export let showArrival = true;

  function selectLink(link) {
    if (link.id != $selectedLink.id) {
      console.log(link.id)
      console.log($selectedLink.id)
      WorldBuilderStore.selectLink(link);
    }
  }

  function editLink(link) {
    WorldBuilderStore.editLink(link)
  }

  function deleteLink(link) {
    WorldBuilderStore.deleteLink(link);
  }
</script>

<div class="h-full w-full flex flex-col overflow-y-auto overflow-x-hidden">
  <table class="divide-y divide-gray-200 w-full">
    <thead>
      <tr>
        <th
          scope="col"
          class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
          Other Area
        </th>
        {#if showExit}
          <th
            scope="col"
            class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
            Exit
          </th>
        {/if}
        {#if showArrival}
          <th
            scope="col"
            class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
            Arrival Text
          </th>
        {/if}
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
          class="{$selectedLink.id == link.id ? 'bg-gray-900' : i % 2 == 0 ? 'bg-gray-500 hover:bg-gray-700' : 'bg-gray-600 hover:bg-gray-700'} {$selectedLink.id == link.id ? 'cursor-not-allowed' : 'cursor-pointer'}"
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
            {:else if link.fromId == $selectedArea.id && areasMap[link.toId].mapId != $selectedArea.mapId}
              <div class="text-sm text-gray-100">
                {mapsMap[areasMap[link.toId].mapId].name}
                -
                {areasMap[link.toId].name}
              </div>
            {:else if link.fromId == $selectedArea.id && areasMap[link.toId].mapId == $selectedArea.mapId}
              <div class="text-sm text-gray-100">
                {areasMap[link.toId].name}
              </div>
            {/if}
          </td>
          {#if showExit}
            <td class="px-4 py-4">
              <p class="text-sm text-gray-100">{link.shortDescription}</p>
            </td>
          {/if}
          {#if showArrival}
            <td class="px-4 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-100">{link.arrivalText}</div>
            </td>
          {/if}
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
