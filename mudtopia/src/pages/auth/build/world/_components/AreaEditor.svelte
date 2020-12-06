<script>
  import { createEventDispatcher } from "svelte";
  const dispatch = createEventDispatcher();
  import { WorldBuilderStore } from "./state";
  const { mapSelected, selectedMap } = WorldBuilderStore;
  import mapState from "../../../../../models/map";

  export let map = { ...mapState };

  function save() {
    saveMap(map).then((updatedMap) => dispatch("save", updatedMap));
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
            bind:value={map.name}
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
            bind:value={map.description}
            name="description"
            id="description"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
        </div>

        <div class="col-span-3">
          <label
            for="viewSize"
            class="block text-sm font-medium text-gray-300">Initial View Size</label>
          <input
            bind:value={map.viewSize}
            type="number"
            min="100"
            max="5000"
            step="100"
            name="viewSize"
            id="viewSize"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
        </div>

        <div class="col-span-3">
          <label
            for="gridSize"
            class="block text-sm font-medium text-gray-300">Grid Size</label>
          <input
            bind:value={map.gridSize}
            type="number"
            min="10"
            max="100"
            step="2"
            name="gridSize"
            id="gridSize"
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
