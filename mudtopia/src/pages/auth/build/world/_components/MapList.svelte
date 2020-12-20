<script>
  import { createEventDispatcher } from "svelte";

  const dispatch = createEventDispatcher();

  import { MapsStore } from "../../../../../stores/maps";
  const { maps } = MapsStore;
  import { WorldBuilderStore } from "./state";
  const { loadAllMapData, selectedMap, editMap, addLabelToMap } = WorldBuilderStore;

  function selectMap(map) {
    WorldBuilderStore.selectMap(map);
    loadAllMapData(map.id);
  }

  function buildMap(map) {
    WorldBuilderStore.buildMap(map);
  }

  function deleteMap(map) {
    $selectedMap = map;
    dispatch("deleteMap", map);
  }
</script>

<div class="flex flex-col p-1">
  <div class="-my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
    <div class="py-2 align-middle inline-block min-w-full sm:px-6 lg:px-8">
      <div
        class="shadow overflow-hidden border-b border-gray-800 sm:rounded-lg">
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
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            {#each $maps as map, i}
              <tr
                class="{$selectedMap.id == map.id ? 'bg-gray-900' : i % 2 == 0 ? 'bg-gray-500 hover:bg-gray-700' : 'bg-gray-600 hover:bg-gray-700'} cursor-pointer"
                on:click={selectMap(map)}>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-100">{map.name}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-100">{map.description}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <button
                    on:click={buildMap(map)}
                    class="text-gray-200 bg-transparent border border-solid border-gray-400 hover:bg-gray-400 hover:text-white active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
                    type="button"
                    style="transition: all .15s ease">
                    <i class="fas fa-hammer" />
                    Build
                  </button>
                  <button
                    on:click={addLabelToMap(map)}
                    class="text-gray-200 bg-transparent border border-solid border-gray-400 hover:bg-gray-400 hover:text-white active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
                    type="button"
                    style="transition: all .15s ease">
                    <i class="fas fa-comment-alt" />
                    Label
                  </button>
                  <button
                    on:click={editMap(map)}
                    class="text-gray-200 bg-transparent border border-solid border-gray-400 hover:bg-gray-400 hover:text-white active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
                    type="button"
                    style="transition: all .15s ease">
                    <i class="fas fa-edit" />
                    Edit
                  </button>
                  <button
                    on:click={deleteMap(map)}
                    class="text-gray-200 bg-transparent border border-solid border-gray-400 hover:bg-gray-400 hover:text-white active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
                    type="button"
                    style="transition: all .15s ease">
                    <i class="fas fa-trash" />
                    Delete
                  </button>
                </td>
              </tr>
            {/each}

            <!-- More rows... -->
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>
