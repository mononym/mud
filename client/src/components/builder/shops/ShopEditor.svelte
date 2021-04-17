<script>
  import { WorldBuilderStore } from "../state";
  const { shopUnderConstruction, saveShop, cancelEditShop } = WorldBuilderStore;
</script>

<form
  class="h-full flex flex-col place-content-center"
  on:submit|preventDefault={saveShop}
>
  <div class="overflow-hidden sm:rounded-md">
    <div class="px-4 py-5 sm:p-6">
      <div class="grid grid-cols-6 gap-6">
        <div class="col-span-3">
          <label for="name" class="block text-sm font-medium text-gray-300"
            >Name</label
          >
          <input
            bind:value={$shopUnderConstruction.name}
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
          <input
            bind:value={$shopUnderConstruction.description}
            type="text"
            name="description"
            id="description"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>
      </div>
    </div>
    <div class="px-4 py-3 text-right sm:px-6">
      <button
        type="submit"
        class="inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-primary text-base font-medium text-black hover:bg-primary-light focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-dark"
      >
        Save
      </button>
      <button
        on:click={cancelEditShop}
        class="inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-red-600 text-base font-medium text-black hover:bg-red-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-400"
      >
        Cancel
      </button>
    </div>
  </div>
</form>
