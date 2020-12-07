<script>
  import { createEventDispatcher } from "svelte";
  const dispatch = createEventDispatcher();
  import { WorldBuilderStore } from "./state";
  const { area, areaUnderConstruction } = WorldBuilderStore;
  import areaState from "../../../../../models/area";
  import { AreasStore } from "../../../../../stores/areas";

  function save() {
    AreasStore.saveArea(area).then((updatedArea) =>
      dispatch("save", updatedArea)
    );
  }

  function cancel() {
    dispatch("cancel");
  }
</script>

<form
  class="h-full flex flex-col place-content-center"
  on:submit|preventDefault={save}>
  <div class="overflow-hidden sm:rounded-md">
    <div class="px-4 py-5 sm:p-6">
      <div class="grid grid-cols-6 gap-6">
        <div class="col-span-3">
          <label
            for="name"
            class="block text-sm font-medium text-gray-300">Name</label>
          <input
            bind:value={$areaUnderConstruction.name}
            type="text"
            name="name"
            id="name"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
        </div>

        <div class="col-span-3">
          <label
            for="description"
            class="block text-sm font-medium text-gray-300">Description</label>
          <textarea
            bind:value={$areaUnderConstruction.description}
            name="description"
            id="description"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
        </div>

        <div class="col-span-3">
          <label for="mapX" class="block text-sm font-medium text-gray-300">Map
            X Coordinate</label>
          <input
            bind:value={$areaUnderConstruction.mapX}
            type="number"
            min="-5000"
            max="5000"
            step="1"
            name="mapX"
            id="mapX"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
        </div>

        <div class="col-span-3">
          <label for="mapY" class="block text-sm font-medium text-gray-300">Map
            Y Coordinate</label>
          <input
            bind:value={$areaUnderConstruction.mapY}
            type="number"
            min="-5000"
            max="5000"
            step="1"
            name="mapY"
            id="mapY"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
        </div>

        <div class="col-span-3">
          <label
            for="mapSize"
            class="block text-sm font-medium text-gray-300">Map Size</label>
          <input
            bind:value={$areaUnderConstruction.mapSize}
            type="number"
            min="5"
            max="100"
            step="1"
            name="mapSize"
            id="mapSize"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
        </div>
      </div>
    </div>
    <div class="px-4 py-3 text-right sm:px-6">
      <button
        type="submit"
        class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
        Save
      </button>
      <button
        on:click={cancel}
        class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
        Cancel
      </button>
    </div>
  </div>
</form>
