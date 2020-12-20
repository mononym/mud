<script>
  import ConfirmWithInput from "../../../../../components/ConfirmWithInput.svelte";
  import { WorldBuilderStore } from "./state";
  const {
    mapSelected,
    selectedMap,
    selectedMapLabel,
    selectMapLabel,
    editMapLabel
  } = WorldBuilderStore;

  let showDeletePrompt = false;
  let labelForDeleting;
  let deleteMatchString = "";

  function promptForDeleteLabel(label) {
    deleteMatchString = "delete";
    labelForDeleting = label;
    showDeletePrompt = true;
  }

  function deleteCallback() {
    WorldBuilderStore.deleteLabel(labelForDeleting);
  }
</script>

{#if $mapSelected}
  <div class="h-full w-full flex flex-col p-1 place-content-center">
    <h2 class="text-center text-gray-300">{$selectedMap.name}</h2>
    <p class="text-center text-gray-300">{$selectedMap.description}</p>
    <p class="text-center text-gray-300">Grid Size: {$selectedMap.gridSize}</p>
    <p class="text-center text-gray-300">View Size: {$selectedMap.viewSize}</p>
    <table class="divide-y divide-gray-200 w-full">
      <thead>
        <tr>
          <th
            scope="col"
            class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
            Text
          </th>
          <th
            scope="col"
            class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
            Color
          </th>
          <th
            scope="col"
            class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
            Font Size
          </th>
          <th
            scope="col"
            class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
            X
          </th>
          <th
            scope="col"
            class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
            Y
          </th>
          <th
            scope="col"
            class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
            Rotation
          </th>
          <th
            scope="col"
            class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
            Weight
          </th>
          <th
            scope="col"
            class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
            Style
          </th>
          <th
            scope="col"
            class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
            Family
          </th>
          <th
            scope="col"
            class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
            Actions
          </th>
        </tr>
      </thead>
      <tbody class="bg-white divide-y divide-gray-200">
        {#each $selectedMap.labels as label, i}
          <tr
            id={label.id}
            class="{$selectedMapLabel.id == label.id ? 'bg-gray-900' : i % 2 == 0 ? 'bg-gray-500 hover:bg-gray-700' : 'bg-gray-600 hover:bg-gray-700'} {$selectedMapLabel.id == label.id ? 'cursor-not-allowed' : 'cursor-pointer'}"
            on:click={selectMapLabel(label)}>
            <td class="px-4 py-4 whitespace-nowrap">
              <p class="text-sm text-gray-100">{label.text}</p>
            </td>
            <td class="px-4 py-4">
              <p class="text-sm text-gray-100">{label.color}</p>
            </td>
            <td class="px-4 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-100">{label.size}</div>
            </td>
            <td class="px-4 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-100">{label.x}</div>
            </td>
            <td class="px-4 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-100">{label.y}</div>
            </td>
            <td class="px-4 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-100">{label.rotation}</div>
            </td>
            <td class="px-4 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-100">{label.weight}</div>
            </td>
            <td class="px-4 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-100">{label.style}</div>
            </td>
            <td class="px-4 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-100">{label.family}</div>
            </td>
            <td class="px-4 py-4 whitespace-nowrap text-sm font-medium">
              <button
                on:click|stopPropagation={editMapLabel(label)}
                class="hover:bg-gray-400 hover:text-white text-gray-200 bg-transparent border border-solid border-gray-400 active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
                type="button"
                style="transition: all .15s ease"
                title="Edit">
                <i class="fas fa-edit" />
              </button>
              <button
                on:click|stopPropagation={promptForDeleteLabel(label)}
                class="hover:bg-gray-400 hover:text-white text-gray-200 bg-transparent border border-solid border-gray-400 active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
                type="button"
                style="transition: all .15s ease"
                title="Delete">
                <i class="fas fa-trash" />
              </button>
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
    <ConfirmWithInput
      bind:show={showDeletePrompt}
      callback={deleteCallback}
      matchString={deleteMatchString} />
  </div>
{:else}
  <div class="h-full w-full flex flex-col place-content-center p-1">
    <p class="text-gray-300 text-center">Select a map to view its details</p>
  </div>
{/if}
