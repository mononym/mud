<script>
  import { WorldBuilderStore } from "./state";
  const {
    mapLabelUnderConstruction,
    saveMapLabel,
    cancelEditMapLabel,
  } = WorldBuilderStore;
</script>

<form
  class="h-full flex flex-col place-content-center"
  on:submit|preventDefault={saveMapLabel}>
  <div class="overflow-hidden sm:rounded-md">
    <div class="px-4 py-5 sm:p-6">
      <div class="grid grid-cols-10 gap-6">
        <div class="col-span-5">
          <label
            for="text"
            class="block text-sm font-medium text-gray-300">Text</label>
          <textarea
            bind:value={$mapLabelUnderConstruction.text}
            name="text"
            id="text"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
        </div>

        <div class="col-span-1">
          <label for="size" class="block text-sm font-medium text-gray-300">Font
            Size</label>
          <input
            bind:value={$mapLabelUnderConstruction.size}
            type="number"
            min="4"
            max="100"
            step="1"
            name="size"
            id="size"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
        </div>

        <div class="col-span-2">
          <label
            for="weight"
            class="block text-sm font-medium text-gray-300">Font Weight</label>
          <!-- svelte-ignore a11y-no-onchange -->
          <select
            id="weight"
            bind:value={$mapLabelUnderConstruction.weight}
            name="weight"
            class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
            <option>normal</option>
            <option>bold</option>
            <!-- <option>100</option>
            <option>200</option>
            <option>300</option>
            <option>400</option>
            <option>500</option>
            <option>600</option>
            <option>700</option>
            <option>800</option>
            <option>900</option> -->
          </select>
        </div>

        <div class="col-span-1">
          <label
            for="color"
            class="block text-sm font-medium text-gray-300">Text Color</label>
          <input
            bind:value={$mapLabelUnderConstruction.color}
            type="color"
            name="color"
            id="color"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
        </div>

        <div class="col-span-1">
          <label
            for="y"
            class="block text-sm font-medium text-gray-300">Rotation</label>
          <input
            bind:value={$mapLabelUnderConstruction.rotation}
            type="number"
            min="-359"
            max="359"
            step="1"
            name="x"
            id="x"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
        </div>

        <div class="col-span-5">
          <label for="x" class="block text-sm font-medium text-gray-300">X
            coordinate</label>
          <input
            bind:value={$mapLabelUnderConstruction.x}
            type="number"
            min="-10000"
            max="1000"
            step="1"
            name="x"
            id="x"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
        </div>

        <div class="col-span-5">
          <label
            for="horizontalOffset"
            class="block text-sm font-medium text-gray-300">Horizontal Offset</label>
          <input
            bind:value={$mapLabelUnderConstruction.horizontalOffset}
            type="number"
            name="horizontalOffset"
            id="horizontalOffset"
            min="-200"
            max="200"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
        </div>

        <div class="col-span-5">
          <label for="y" class="block text-sm font-medium text-gray-300">Y
            coordinate</label>
          <input
            bind:value={$mapLabelUnderConstruction.y}
            type="number"
            min="-10000"
            max="1000"
            step="1"
            name="x"
            id="x"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
        </div>

        <div class="col-span-5">
          <label
            for="verticalOffset"
            class="block text-sm font-medium text-gray-300">Vertical Offset</label>
          <input
            bind:value={$mapLabelUnderConstruction.verticalOffset}
            type="number"
            name="verticalOffset"
            id="verticalOffset"
            min="-200"
            max="200"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
        </div>
        <!-- <div class="col-span-3">
          <label
            for="style"
            class="block text-sm font-medium text-gray-300">Font Style</label>
          <select
            id="style"
            bind:value={$mapLabelUnderConstruction.style}
            name="style"
            class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
            <option>normal</option>
            <option>italic</option>
            <option>oblique</option>
          </select>
        </div>
        <div class="col-span-3">
          <label
            for="family"
            class="block text-sm font-medium text-gray-300">Font Family</label>
          <select
            id="family"
            bind:value={$mapLabelUnderConstruction.weight}
            name="family"
            class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
            <option>sans-sarif</option>
            <option>sarif</option>
            <option>cursive</option>
            <option>fantasy</option>
            <option>monospace</option>
          </select>
        </div> -->
      </div>
    </div>
    <div class="px-4 py-3 text-right sm:px-6">
      <button
        type="submit"
        class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
        Save
      </button>
      <button
        on:click={cancelEditMapLabel}
        class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
        Cancel
      </button>
    </div>
  </div>
</form>
