<script>
  import { WorldBuilderStore } from "../state";
  const {
    shopProductUnderConstruction,
    saveShopProduct,
    cancelEditShopProduct,
  } = WorldBuilderStore;
</script>

<form
  class="h-full flex flex-col place-content-center"
  on:submit|preventDefault={saveShopProduct}
>
  <div class="overflow-hidden sm:rounded-md">
    <div class="px-4 py-5 sm:p-6">
      <div class="grid grid-cols-6 gap-6">
        <div class="col-span-2">
          <label
            for="description"
            class="block text-sm font-medium text-gray-300">Description</label
          >
          <input
            bind:value={$shopProductUnderConstruction.description}
            type="text"
            name="description"
            id="description"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>

        <div class="col-span-1">
          <label for="gold" class="block text-sm font-medium text-gray-300"
            >Gold</label
          >
          <input
            bind:value={$shopProductUnderConstruction.gold}
            type="number"
            min=0
            max=9223372036854775807
            name="gold"
            id="gold"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>

        <div class="col-span-1">
          <label for="silver" class="block text-sm font-medium text-gray-300"
            >Silver</label
          >
          <input
            bind:value={$shopProductUnderConstruction.silver}
            type="number"
            min=0
            max=99
            name="silver"
            id="silver"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>

        <div class="col-span-1">
          <label for="bronze" class="block text-sm font-medium text-gray-300"
            >Bronze</label
          >
          <input
            bind:value={$shopProductUnderConstruction.bronze}
            type="number"
            min=0
            max=99
            name="bronze"
            id="bronze"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>

        <div class="col-span-1">
          <label for="bronze" class="block text-sm font-medium text-gray-300"
            >Copper</label
          >
          <input
            bind:value={$shopProductUnderConstruction.copper}
            type="number"
            min=0
            max=99
            name="copper"
            id="copper"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
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
        on:click={cancelEditShopProduct}
        class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
      >
        Cancel
      </button>
    </div>
  </div>
</form>
