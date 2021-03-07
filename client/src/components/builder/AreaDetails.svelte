<script>
  import { MapsStore } from "../../stores/maps";
  import { AreasStore } from "../../stores/areas";
  const { mapsMap } = MapsStore;
  const { areasMap } = AreasStore;
  import { WorldBuilderStore } from "./state";
  import LinkList from "./LinkList.svelte";
  const {
    areaSelected,
    selectedArea,
    incomingLinksForSelectedArea,
    outgoingLinksForSelectedArea,
    selectShop,
    selectedShop,
    shopview,
    unattachedShops,
    attachShop,
    selectedAreaShops,
    detachShop,
  } = WorldBuilderStore;

  function attachAShop(event) {
    const shopToAttachId = event.target.shops.value;
    const shopToAttach = $unattachedShops.find(
      (shop) => shop.id == shopToAttachId
    );
    const areaToAttachTo = $selectedArea.id;
    attachShop(shopToAttach, areaToAttachTo);
  }
</script>

{#if $areaSelected}
  <div class="h-full w-full flex flex-col p-1 place-content-center">
    <h2 class="text-center text-gray-300">{$selectedArea.name}</h2>
    <p class="text-center text-gray-300">{$selectedArea.description}</p>
    <p class="text-center text-gray-300">
      Map X Coordinate:
      {$selectedArea.mapX}
    </p>
    <p class="text-center text-gray-300">
      Map Y Coordinate:
      {$selectedArea.mapY}
    </p>
    <p class="text-center text-gray-300">Map Size: {$selectedArea.mapSize}</p>
    <div class="grid grid-cols-2">
      <div class="bg-gray-800 text-white rounded-l flex flex-col">
        <h2 class="text-center border-b-2 border-black flex-shrink">
          Incoming Links
        </h2>
        <div class="flex-1">
          <LinkList
            mapsMap={$mapsMap}
            links={$incomingLinksForSelectedArea}
            areasMap={$areasMap}
            showExit={false}
          />
        </div>
      </div>
      <div
        class="bg-gray-800 text-white border-l-2 rounded-r border-black flex flex-col"
      >
        <h2 class="text-center border-b-2 border-black flex-shrink">
          Outgoing Links
        </h2>
        <div class="flex-1">
          <LinkList
            mapsMap={$mapsMap}
            links={$outgoingLinksForSelectedArea}
            areasMap={$areasMap}
            showArrival={false}
          />
        </div>
      </div>
    </div>
    <div class="flex flex-col">
      <h2 class="text-center text-gray-300 flex-shrink">Shops</h2>
      <table class="divide-y divide-gray-200 w-full flex-1">
        <thead>
          <tr>
            <th
              scope="col"
              class="px-4 py-3 bg-gray-800 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
            >
              Name
            </th>
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
              Actions
            </th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          {#each $selectedAreaShops as shop, i}
            <tr
              id={shop.id}
              class="{$selectedShop.id == shop.id
                ? 'bg-gray-900'
                : i % 2 == 0
                ? 'bg-gray-500 hover:bg-gray-700'
                : 'bg-gray-600 hover:bg-gray-700'} {$selectedShop.id == shop.id
                ? 'cursor-not-allowed'
                : 'cursor-pointer'}"
              on:click={selectShop(shop)}
            >
              <td class="px-4 py-4 whitespace-nowrap">
                <p class="text-sm text-gray-100">{shop.name}</p>
              </td>
              <td class="px-4 py-4 whitespace-nowrap">
                <p class="text-sm text-gray-100">{shop.description}</p>
              </td>
              <td class="px-4 py-4 whitespace-nowrap text-sm font-medium">
                <button
                  on:click|stopPropagation={detachShop(shop)}
                  class="{$shopview == 'edit'
                    ? 'cursor-not-allowed'
                    : 'hover:bg-gray-400 hover:text-white'} text-gray-200 bg-transparent border border-solid border-gray-400 active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
                  type="button"
                  style="transition: all .15s ease"
                  title="Unlink"
                >
                  <i class="fas fa-unlink" />
                </button>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
      <form on:submit|preventDefault={attachAShop}>
        <label for="shops">Attach Shop:</label>
        {#if $unattachedShops.length > 0}
          <select name="shops" id="shops">
            <optgroup label="Standard Shops">
              {#each $unattachedShops as shop}
                <option value={shop.id}>{shop.name}</option>
              {/each}
            </optgroup>
          </select>
        {:else}
          <select name="shops" id="shops" disabled>
            <option>No Unattached Shops</option>
          </select>
        {/if}
        <br /><br />
        <input type="submit" value="Submit" />
      </form>
    </div>
  </div>
{:else}
  <div class="h-full w-full flex flex-col place-content-center p-1">
    <p class="text-gray-300 text-center">Select an area to view its details</p>
  </div>
{/if}
