<script>
  import { WorldBuilderStore } from "./state";
  const { mapUnderConstruction, saveMap, cancelEditMap } = WorldBuilderStore;
</script>

<form
  class="h-full flex flex-col place-content-center"
  on:submit|preventDefault={saveMap}
>
  <div class="overflow-hidden sm:rounded-md">
    <div class="px-4 py-5 sm:p-6">
      <div class="grid grid-cols-6 gap-6">
        <div class="col-span-3">
          <label for="name" class="block text-sm font-medium text-gray-300"
            >Name</label
          >
          <input
            bind:value={$mapUnderConstruction.name}
            type="text"
            name="name"
            id="name"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>

        <div class="col-span-3">
          <label
            for="description"
            class="block text-sm font-medium text-gray-300">Description</label
          >
          <textarea
            bind:value={$mapUnderConstruction.description}
            name="description"
            id="description"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>

        <div class="col-span-3">
          <label for="viewSize" class="block text-sm font-medium text-gray-300"
            >Initial View Size</label
          >
          <input
            bind:value={$mapUnderConstruction.viewSize}
            type="number"
            min="100"
            max="5000"
            step="100"
            name="viewSize"
            id="viewSize"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>

        <div class="col-span-3">
          <label for="gridSize" class="block text-sm font-medium text-gray-300"
            >Grid Size</label
          >
          <input
            bind:value={$mapUnderConstruction.gridSize}
            type="number"
            min="10"
            max="100"
            name="gridSize"
            id="gridSize"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>

        <div class="col-span-2">
          <label for="minZoom" class="block text-sm font-medium text-gray-300"
            >Minimum Zoom Index</label
          >

          <select
            id="minZoom"
            bind:value={$mapUnderConstruction.minimumZoomIndex}
            name="minZoom"
            class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
          >
            <option
              value="4"
              selected={$mapUnderConstruction.minimumZoomIndex == 4}>1x</option
            >
            <option
              value="5"
              selected={$mapUnderConstruction.minimumZoomIndex == 5}
              >1/2x</option
            >
            <option
              value="6"
              selected={$mapUnderConstruction.minimumZoomIndex == 6}
              >1/4x</option
            >
            <option
              value="7"
              selected={$mapUnderConstruction.minimumZoomIndex == 7}
              >1/8x</option
            >
            <option
              value="8"
              selected={$mapUnderConstruction.minimumZoomIndex == 8}
              >1/16x</option
            >
          </select>
        </div>

        <div class="col-span-2">
          <label for="maxZoom" class="block text-sm font-medium text-gray-300"
            >Maximum Zoom Index</label
          >

          <select
            id="maxZoom"
            bind:value={$mapUnderConstruction.maximumZoomIndex}
            name="maxZoom"
            class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
          >
            <option
              value="4"
              selected={$mapUnderConstruction.maximumZoomIndex == 4}>1x</option
            >
            <option
              value="3"
              selected={$mapUnderConstruction.maximumZoomIndex == 3}>2x</option
            >
            <option
              value="2"
              selected={$mapUnderConstruction.maximumZoomIndex == 2}>4x</option
            >
            <option
              value="1"
              selected={$mapUnderConstruction.maximumZoomIndex == 1}>8x</option
            >
            <option
              value="0"
              selected={$mapUnderConstruction.maximumZoomIndex == 0}>16x</option
            >
          </select>
        </div>

        <div class="col-span-2">
          <label
            for="isPermExplored"
            class="block text-sm font-medium text-gray-300"
            >Is Permanently Explored</label
          >
          <input
            bind:checked={$mapUnderConstruction.permanently_explored}
            type="checkbox"
            name="isPermExplored"
            id="isPermExplored"
          />
        </div>
      </div>
    </div>
    <div class="px-4 py-3 text-right sm:px-6">
      <button
        type="submit"
        class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
      >
        Save
      </button>
      <button
        on:click={cancelEditMap}
        class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
      >
        Cancel
      </button>
    </div>
  </div>
</form>
