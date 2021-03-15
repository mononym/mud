<script language="typescript">
  import Confirm from "../Confirm.svelte";
  import ShopList from "./shops/ShopList.svelte";
  import ShopDetails from "./shops/ShopDetails.svelte";
  import ShopEditor from "./shops/ShopEditor.svelte";
  import ShopProductEditor from "./shops/ShopProductEditor.svelte";
  import { onMount } from "svelte";
  import { Circle2 } from "svelte-loading-spinners";
  import { WorldBuilderStore } from "./state";
  const {
    createNewShop,
    loadShops,
    loadingShops,
    shopview,
    loadTemplates,
  } = WorldBuilderStore;

  let showDeletePrompt = false;
  let deleteCallback;
  let deleteMatchString = "";
  $: newShopButtonDisabled = $shopview != "details";

  onMount(async () => {
    loadShops();
    loadTemplates();
  });
</script>

<div class="h-full w-full overflow-hidden flex flex-col">
  {#if $loadingShops}
    <div class="flex-1 flex flex-col justify-center items-center">
      <Circle2 />
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
        Loading Shops
      </h2>
    </div>
  {:else}
    <div class="h-full flex flex-1">
      <div class="h-full max-h-full flex-1">
        <div class="h-1/2 max-h-1/2 w-full">
          <p class="text-white text-center align-center">
            Shopping Window Preview
          </p>
        </div>
        <div class="h-1/2 max-h-1/2 w-full overflow-hidden flex flex-col">
          <ShopList />

          <div class="flex-shrink flex">
            <button
              on:click={createNewShop}
              disabled={newShopButtonDisabled}
              type="button"
              class="flex-1 rounded-l-md {newShopButtonDisabled
                ? 'text-gray-600 bg-gray-500'
                : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {newShopButtonDisabled
                ? 'cursor-not-allowed'
                : 'cursor-pointer'}">New Shop</button
            >
          </div>
        </div>
      </div>
      <div class="h-full max-h-full flex-1">
        {#if $shopview == "details"}
          <ShopDetails />
        {:else if $shopview == "edit"}
          <ShopEditor />
        {:else if $shopview == "edit_product"}
          <ShopProductEditor />
        {/if}
      </div>
      <Confirm
        show={showDeletePrompt}
        callback={deleteCallback}
        matchString={deleteMatchString}
      />
    </div>
  {/if}
</div>
