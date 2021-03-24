<script>
  import Confirm from "../../Confirm.svelte";

  import { WorldBuilderStore } from "../state";
  const { selectedItem, view } = WorldBuilderStore;

  export let items = [];
  let showDeletePrompt = false;
  let itemForDeleting;
  let deleteMatchString = "";

  function selectItem(item) {
    if (item.id != $selectedItem.id) {
      WorldBuilderStore.selectItem(item);
    }
  }

  function editItem(item) {
    WorldBuilderStore.editItem({ ...item });
  }

  function updateItemMovedAt(item) {
    WorldBuilderStore.updateItemMovedAt(item);
  }

  function promptForDeleteItem(item) {
    deleteMatchString = "delete";
    itemForDeleting = item;
    showDeletePrompt = true;
  }

  function deleteCallback() {
    WorldBuilderStore.deleteItemForArea(itemForDeleting);
  }
</script>

<div class="h-full w-full flex flex-col overflow-y-auto overflow-x-hidden">
  <table class="divide-y divide-gray-200 w-full">
    <thead>
      <tr>
        <th
          scope="col"
          class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
        >
          Short Description
        </th>
        <th
          scope="col"
          class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
        >
          Long Description
        </th>
        <th
          scope="col"
          class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
        >
          Actions
        </th>
      </tr>
    </thead>
    <tbody class="bg-white divide-y divide-gray-200">
      {#each items as item, i}
        <tr
          id={item.id}
          class="{$selectedItem.id == item.id
            ? 'bg-gray-900'
            : i % 2 == 0
            ? 'bg-gray-500 hover:bg-gray-700'
            : 'bg-gray-600 hover:bg-gray-700'} {$selectedItem.id == item.id
            ? 'cursor-not-allowed'
            : 'cursor-pointer'}"
          on:click={selectItem(item)}
        >
          <td class="px-4 py-4">
            <p class="text-sm text-gray-100">{item.description.short}</p>
          </td>
          <td class="px-4 py-4">
            <p class="text-sm text-gray-100">{item.description.long}</p>
          </td>
          <td class="px-4 py-4 whitespace-nowrap text-sm font-medium">
            <button
              on:click|stopPropagation={editItem(item)}
              class="{$view == 'edit'
                ? 'cursor-not-allowed'
                : 'hover:bg-gray-400 hover:text-white'} text-gray-200 bg-transparent border border-solid border-gray-400 active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
              type="button"
              style="transition: all .15s ease"
              title="Edit"
            >
              <i class="fas fa-edit" />
            </button>
            <button
              on:click|stopPropagation={updateItemMovedAt(item)}
              class="{$view == 'edit'
                ? 'cursor-not-allowed'
                : 'hover:bg-gray-400 hover:text-white'} text-gray-200 bg-transparent border border-solid border-gray-400 active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
              type="button"
              style="transition: all .15s ease"
              title="Update Moved At"
            >
              <i class="fas fa-stopwatch" />
            </button>
            <button
              on:click|stopPropagation={promptForDeleteItem(item)}
              class="{$view == 'edit'
                ? 'cursor-not-allowed'
                : 'hover:bg-gray-400 hover:text-white'} text-gray-200 bg-transparent border border-solid border-gray-400 active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
              type="button"
              style="transition: all .15s ease"
              title="Delete"
            >
              <i class="fas fa-trash" />
            </button>
          </td>
        </tr>
      {/each}
    </tbody>
  </table>
  <Confirm
    bind:show={showDeletePrompt}
    callback={deleteCallback}
    matchString={deleteMatchString}
  />
</div>
