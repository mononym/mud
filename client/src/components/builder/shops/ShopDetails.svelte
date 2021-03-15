<script>
  import Confirm from "../../Confirm.svelte";
  import { WorldBuilderStore } from "../state";
  const {
    createNewShopProduct,
    editShopProduct,
    shopSelected,
    selectedShop,
    selectShopProduct,
    selectedShopProduct,
    shopview,
  } = WorldBuilderStore;

  $: newShopProductButtonDisabled = $shopview != "details";

  let showDeletePrompt = false;
  let productForDeleting;
  let deleteMatchString = "";

  function promptForDeleteProduct(product) {
    deleteMatchString = product.description;
    productForDeleting = product;
    showDeletePrompt = true;
  }

  function deleteCallback() {
    WorldBuilderStore.deleteShopProduct(productForDeleting);
  }
</script>

{#if $shopSelected}
  <div class="h-full w-full flex flex-col p-1 place-content-center">
    <h2 class="text-center text-gray-300">{$selectedShop.name}</h2>
    <p class="text-center text-gray-300">{$selectedShop.description}</p>
    <h2 class="text-center text-gray-300">Products</h2>
    <table class="divide-y divide-gray-200 w-full">
      <thead>
        <tr>
          <th
            scope="col"
            class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
          >
            Description
          </th>
          <th
            scope="col"
            class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
          >
            Price
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
        {#each $selectedShop.products as product, i}
          <tr
            id={product.id}
            class="{$selectedShopProduct.id == product.id
              ? 'bg-gray-900'
              : i % 2 == 0
              ? 'bg-gray-500 hover:bg-gray-700'
              : 'bg-gray-600 hover:bg-gray-700'} {$selectedShopProduct.id ==
            product.id
              ? 'cursor-not-allowed'
              : 'cursor-pointer'}"
            on:click={selectShopProduct(product)}
          >
            <td class="px-4 py-4 whitespace-nowrap">
              <p class="text-sm text-gray-100">{product.description}</p>
            </td>
            <td class="px-4 py-4">
              <p class="text-sm text-gray-100">
                {#if product.gold > 0}{product.gold} gold{/if}{#if product.silver > 0}{#if product.gold > 0},
                  {/if}{product.silver}
                  silver{/if}{#if product.bronze > 0}{#if product.gold > 0 || product.silver > 0},
                  {/if}{product.bronze} bronze{/if}{#if product.copper > 0}{#if product.gold > 0 || product.silver > 0 || product.bronze > 0},
                  {/if}{product.copper}
                  copper{/if}
              </p>
            </td>
            <td class="px-4 py-4 whitespace-nowrap text-sm font-medium">
              <button
                on:click|stopPropagation={editShopProduct(product)}
                class="hover:bg-gray-400 hover:text-white text-gray-200 bg-transparent border border-solid border-gray-400 active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
                type="button"
                style="transition: all .15s ease"
                title="Edit"
              >
                <i class="fas fa-edit" />
              </button>
              <button
                on:click|stopPropagation={promptForDeleteProduct(product)}
                class="hover:bg-gray-400 hover:text-white text-gray-200 bg-transparent border border-solid border-gray-400 active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
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
    <div class="flex-shrink flex">
      <button
        on:click={createNewShopProduct}
        disabled={newShopProductButtonDisabled}
        type="button"
        class="flex-1 rounded-l-md {newShopProductButtonDisabled
          ? 'text-gray-600 bg-gray-500'
          : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {newShopProductButtonDisabled
          ? 'cursor-not-allowed'
          : 'cursor-pointer'}">New Product</button
      >
    </div>
    <Confirm
      bind:show={showDeletePrompt}
      callback={deleteCallback}
      matchString={deleteMatchString}
    />
  </div>
{:else}
  <div class="h-full w-full flex flex-col place-content-center p-1">
    <p class="text-gray-300 text-center">Select a Shop to view its details</p>
  </div>
{/if}
