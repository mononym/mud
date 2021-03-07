<script>
  import { onMount } from "svelte";
  import { WorldBuilderStore } from "../state";
  const {
    characterSettings,
    templateUnderConstruction,
    saveTemplate,
    cancelEditTemplate,
  } = WorldBuilderStore;

  $: disableArmorCheckbox =
    $templateUnderConstruction.template.flags.clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.container ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableClothingCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.container ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableCoinCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.clothing ||
    $templateUnderConstruction.template.flags.container ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableContainerCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableFurnitureCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.container ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableGemCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.container ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableInstrumentCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.container ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableJewelryCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.container ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableMaterialCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.container ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableSceneryCheckbox = false;

  $: disableShieldCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.container ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableWeaponCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.container ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield;

  $: disableGemPouchCheckbox =
    !$templateUnderConstruction.template.flags.container ||
    !$templateUnderConstruction.template.flags.wearable;

  $: disableHiddenCheckbox = !$templateUnderConstruction.template.flags.scenery;

  $: disableShopDisplayCheckbox = !$templateUnderConstruction.template.flags
    .furniture;

  $: disableWearableCheckbox = !$templateUnderConstruction.template.flags
    .container;

  $: disableCloseCheckbox = !$templateUnderConstruction.template.flags
    .container;

  $: disableDropCheckbox = !$templateUnderConstruction.template.flags.hold;

  $: disableHoldCheckbox = $templateUnderConstruction.template.flags.scenery;

  $: disableLookCheckbox = false;

  $: disableOpenCheckbox = !$templateUnderConstruction.template.flags.container;

  $: disableRemoveCheckbox = !$templateUnderConstruction.template.flags
    .wearable;

  $: disableStoreCheckbox = $templateUnderConstruction.template.flags.scenery;

  $: disableTrashCheckbox =
    $templateUnderConstruction.template.flags.scenery ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.coin;

  $: disableWearCheckbox = !$templateUnderConstruction.template.flags.wearable;

  onMount(() => {
    console.log("onMount");
    console.log($templateUnderConstruction);
  });
</script>

<form
  class="h-full flex flex-col place-content-center"
  on:submit|preventDefault={saveTemplate}
>
  <div class="overflow-hidden sm:rounded-md">
    <div class="px-4 py-5 sm:p-6">
      <div class="grid grid-cols-12 gap-4">
        <div class="col-span-12">
          <h2 class="text-gray-300 text-center">Template Details</h2>
        </div>
        <div class="col-span-6">
          <label for="name" class="block text-sm font-medium text-gray-300"
            >Template Name</label
          >
          <input
            bind:value={$templateUnderConstruction.name}
            type="text"
            name="name"
            id="name"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>
        <div class="col-span-6">
          <label
            for="description"
            class="block text-sm font-medium text-gray-300"
            >Template Description</label
          >
          <input
            bind:value={$templateUnderConstruction.description}
            type="text"
            name="description"
            id="description"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>
        <div class="col-span-12">
          <h2 class="text-gray-300 text-center">Item Description</h2>
        </div>
        <div class="col-span-6">
          <label
            for="itemShortDescription"
            class="block text-sm font-medium text-gray-300"
            >Item Short Description</label
          >
          <input
            bind:value={$templateUnderConstruction.template.description.short}
            type="textarea"
            name="itemShortDescription"
            id="itemShortDescription"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>
        <div class="col-span-6">
          <label
            for="itemLongDescription"
            class="block text-sm font-medium text-gray-300"
            >Item Long Description</label
          >
          <input
            bind:value={$templateUnderConstruction.template.description.long}
            type="textarea"
            name="itemLongDescription"
            id="itemLongDescription"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>
        <div class="col-span-12">
          <h2 class="text-gray-300 text-center">Item Type (Pick One)</h2>
        </div>
        <div class="col-span-1">
          <label for="isArmor" class="block text-sm font-medium text-gray-300"
            >Armor</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.armor}
            type="checkbox"
            name="isArmor"
            id="isArmor"
            disabled={disableArmorCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label
            for="isClothing"
            class="block text-sm font-medium text-gray-300">Clothing</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.clothing}
            type="checkbox"
            name="isClothing"
            id="isClothing"
            disabled={disableClothingCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="isCoin" class="block text-sm font-medium text-gray-300"
            >Coin</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.coin}
            type="checkbox"
            name="isCoin"
            id="isCoin"
            disabled={disableCoinCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label
            for="isContainer"
            class="block text-sm font-medium text-gray-300">Container</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.container}
            type="checkbox"
            name="isContainer"
            id="isContainer"
            disabled={disableContainerCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label
            for="isFurniture"
            class="block text-sm font-medium text-gray-300">Furniture</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.furniture}
            type="checkbox"
            name="isFurniture"
            id="isFurniture"
            disabled={disableFurnitureCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="isGem" class="block text-sm font-medium text-gray-300"
            >Gem</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.gem}
            type="checkbox"
            name="isGem"
            id="isGem"
            disabled={disableGemCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label
            for="isInstrument"
            class="block text-sm font-medium text-gray-300">Instrument</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.instrument}
            type="checkbox"
            name="isInstrument"
            id="isInstrument"
            disabled={disableInstrumentCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="isJewelry" class="block text-sm font-medium text-gray-300"
            >Jewelry</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.jewelry}
            type="checkbox"
            name="isJewelry"
            id="isJewelry"
            disabled={disableJewelryCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label
            for="isMaterial"
            class="block text-sm font-medium text-gray-300">Material</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.material}
            type="checkbox"
            name="isMaterial"
            id="isMaterial"
            disabled={disableMaterialCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="isScenery" class="block text-sm font-medium text-gray-300"
            >Scenery</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.scenery}
            type="checkbox"
            name="isScenery"
            id="isScenery"
            disabled={disableSceneryCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="isShield" class="block text-sm font-medium text-gray-300"
            >Shield</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.shield}
            type="checkbox"
            name="isShield"
            id="isShield"
            disabled={disableShieldCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="isWeapon" class="block text-sm font-medium text-gray-300"
            >Weapon</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.weapon}
            type="checkbox"
            name="isWeapon"
            id="isWeapon"
            disabled={disableWeaponCheckbox}
          />
        </div>
        <div class="col-span-12">
          <h2 class="text-gray-300 text-center">
            Item Type Behavior Modifiers
          </h2>
        </div>
        <div class="col-span-1">
          <label
            for="isGemPouch"
            class="block text-sm font-medium text-gray-300">Gem Pouch</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.gem_pouch}
            type="checkbox"
            name="isGemPouch"
            id="isGemPouch"
            disabled={disableGemPouchCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="isHidden" class="block text-sm font-medium text-gray-300"
            >Hidden</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.hidden}
            type="checkbox"
            name="isHidden"
            id="isHidden"
            disabled={disableHiddenCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label
            for="isShopDisplay"
            class="block text-sm font-medium text-gray-300">Shop Display</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags
              .shop_display}
            type="checkbox"
            name="isShopDisplay"
            id="isShopDisplay"
            disabled={disableShopDisplayCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label
            for="isWearable"
            class="block text-sm font-medium text-gray-300">Wearable</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.wearable}
            type="checkbox"
            name="isWearable"
            id="isWearable"
            disabled={disableWearableCheckbox}
          />
        </div>
        <div class="col-span-12">
          <h2 class="text-gray-300 text-center">
            Actions which can be taken on an item by a character
          </h2>
        </div>
        <div class="col-span-1">
          <label for="canClose" class="block text-sm font-medium text-gray-300"
            >Close</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.close}
            type="checkbox"
            name="canClose"
            id="canClose"
            disabled={disableCloseCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="canDrop" class="block text-sm font-medium text-gray-300"
            >Drop</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.drop}
            type="checkbox"
            name="canDrop"
            id="canDrop"
            disabled={disableDropCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="canHold" class="block text-sm font-medium text-gray-300"
            >Hold</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.hold}
            type="checkbox"
            name="canHold"
            id="canHold"
            disabled={disableHoldCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="canLook" class="block text-sm font-medium text-gray-300"
            >Look</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.look}
            type="checkbox"
            name="canLook"
            id="canLook"
            disabled={disableLookCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="canOpen" class="block text-sm font-medium text-gray-300"
            >Open</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.open}
            type="checkbox"
            name="canOpen"
            id="canOpen"
            disabled={disableOpenCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="canRemove" class="block text-sm font-medium text-gray-300"
            >Remove</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.remove}
            type="checkbox"
            name="canRemove"
            id="canRemove"
            disabled={disableRemoveCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="canStore" class="block text-sm font-medium text-gray-300"
            >Store</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.store}
            type="checkbox"
            name="canStore"
            id="canStore"
            disabled={disableStoreCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="canTrash" class="block text-sm font-medium text-gray-300"
            >Trash</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.trash}
            type="checkbox"
            name="canTrash"
            id="canTrash"
            disabled={disableTrashCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="canWear" class="block text-sm font-medium text-gray-300"
            >Wear</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.wear}
            type="checkbox"
            name="canWear"
            id="canWear"
            disabled={disableWearCheckbox}
          />
        </div>

        <div class="col-span-12">
          <h2 class="text-gray-300 text-center">Physical Properties</h2>
        </div>
        <div class="col-span-2">
          <label
            for="itemWeight"
            class="block text-sm font-medium text-gray-300"
            >Weight in grams</label
          >
          <input
            bind:value={$templateUnderConstruction.template.physics.weight}
            type="number"
            min="0"
            max="1000000000000000"
            name="itemWeight"
            id="itemWeight"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>
        <div class="col-span-2">
          <label
            for="itemHeight"
            class="block text-sm font-medium text-gray-300">Height in cm</label
          >
          <input
            bind:value={$templateUnderConstruction.template.physics.height}
            type="number"
            min="0"
            max="1000000000000000"
            name="itemHeight"
            id="itemHeight"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>
        <div class="col-span-2">
          <label
            for="itemLength"
            class="block text-sm font-medium text-gray-300">Length in cm</label
          >
          <input
            bind:value={$templateUnderConstruction.template.physics.length}
            type="number"
            min="0"
            max="1000000000000000"
            name="itemLength"
            id="itemLength"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>
        <div class="col-span-2">
          <label for="itemWidth" class="block text-sm font-medium text-gray-300"
            >Width in cm</label
          >
          <input
            bind:value={$templateUnderConstruction.template.physics.width}
            type="number"
            min="0"
            max="1000000000000000"
            name="itemWidth"
            id="itemWidth"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>

        {#if $templateUnderConstruction.template.flags.container}
          <div class="col-span-12">
            <h2 class="text-gray-300 text-center">Container Properties</h2>
          </div>
          <div class="col-span-2">
            <label
              for="containerCapacity"
              class="block text-sm font-medium text-gray-300"
              >Capacity in grams</label
            >
            <input
              bind:value={$templateUnderConstruction.template.container
                .capacity}
              type="number"
              min="0"
              max="1000000000000000"
              name="containerCapacity"
              id="containerCapacity"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="containerHeight"
              class="block text-sm font-medium text-gray-300"
              >Internal height in cm</label
            >
            <input
              bind:value={$templateUnderConstruction.template.container.height}
              type="number"
              min="0"
              max="1000000000000000"
              name="containerHeight"
              id="containerHeight"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="containerLength"
              class="block text-sm font-medium text-gray-300"
              >Internal length in cm</label
            >
            <input
              bind:value={$templateUnderConstruction.template.container.length}
              type="number"
              min="0"
              max="1000000000000000"
              name="containerLength"
              id="containerLength"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="containerWidth"
              class="block text-sm font-medium text-gray-300"
              >Internal width in cm</label
            >
            <input
              bind:value={$templateUnderConstruction.template.container.width}
              type="number"
              min="0"
              max="1000000000000000"
              name="containerWidth"
              id="containerWidth"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
        {/if}

        {#if $templateUnderConstruction.template.flags.furniture}
          <div class="col-span-12">
            <h2 class="text-gray-300 text-center">Furniture Properties</h2>
          </div>
          <div class="col-span-2">
            <label
              for="furnitureHasExternalSurface"
              class="block text-sm font-medium text-gray-300"
              >Has external surface?</label
            >
            <input
              bind:checked={$templateUnderConstruction.template.furniture
                .has_external_surface}
              type="checkbox"
              name="furnitureHasExternalSurface"
              id="furnitureHasExternalSurface"
            />
          </div>
          <div class="col-span-2">
            <label
              for="furnitureExternalSurfaceCanHoldCharacters"
              class="block text-sm font-medium text-gray-300"
              >External surface can hold characters?</label
            >
            <input
              bind:checked={$templateUnderConstruction.template.furniture
                .external_surface_can_hold_characters}
              type="checkbox"
              name="furnitureExternalSurfaceCanHoldCharacters"
              id="furnitureExternalSurfaceCanHoldCharacters"
            />
          </div>
          <div class="col-span-2">
            <label
              for="furnitureExternalSurfaceSize"
              class="block text-sm font-medium text-gray-300"
              >External surface size</label
            >
            <input
              bind:value={$templateUnderConstruction.template.furniture.external_surface_size}
              type="number"
              min="0"
              max="1000000000000000"
              name="furnitureExternalSurfaceSize"
              id="furnitureExternalSurfaceSize"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="furnitureHasInternalSurface"
              class="block text-sm font-medium text-gray-300"
              >Has internal surface?</label
            >
            <input
              bind:checked={$templateUnderConstruction.template.furniture
                .has_internal_surface}
              type="checkbox"
              name="furnitureHasInternalSurface"
              id="furnitureHasInternalSurface"
            />
          </div>
          <div class="col-span-2">
            <label
              for="furnitureInternalSurfaceCanHoldCharacters"
              class="block text-sm font-medium text-gray-300"
              >Internal surface can hold characters?</label
            >
            <input
              bind:checked={$templateUnderConstruction.template.furniture
                .internal_surface_can_hold_characters}
              type="checkbox"
              name="furnitureInternalSurfaceCanHoldCharacters"
              id="furnitureInternalSurfaceCanHoldCharacters"
            />
          </div>
          <div class="col-span-2">
            <label
              for="furnitureInternalSurfaceSize"
              class="block text-sm font-medium text-gray-300"
              >Internal surface size</label
            >
            <input
              bind:value={$templateUnderConstruction.template.furniture.internal_surface_size}
              type="number"
              min="0"
              max="1000000000000000"
              name="furnitureInternalSurfaceSize"
              id="furnitureInternalSurfaceSize"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
        {/if}

        {#if $templateUnderConstruction.template.flags.wearable}
          <div class="col-span-12">
            <h2 class="text-gray-300 text-center">Wearable Properties</h2>
          </div>
          <div class="col-span-2">
            <label for="gemType" class="block text-sm font-medium text-gray-300"
              >Slot</label
            >
            <select
              id="gemType"
              bind:value={$templateUnderConstruction.template.wearable.slot}
              name="gemType"
              class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
              <option value="on_back">On Back</option>
              <option value="around_waist">Around Waist (like belt)</option>
              <option value="on_belt"
                >On Belt (belt assumed to be present)</option
              >
              <option value="on_finger">On Finger</option>
              <option value="over_shoulders">Over Shoulders (like cloak)</option
              >
              <option value="over_shoulder"
                >Over Shoulder (like bow or satchal tossed over a shoulder)</option
              >
              <option value="on_head">On Head</option>
              <option value="in_hair">In Hair (like a hair comb)</option>
              <option value="on_hair">On Hair (like a bow or hair net)</option>
              <option value="around_neck">Around Neck (like necklace)</option>
              <option value="on_torso">On Torso (like shirt)</option>
              <option value="on_legs">On Legs (like pants)</option>
              <option value="on_feet">On Feet (like shoes)</option>
              <option value="on_hands">On Hands (like gloves)</option>
              <option value="on_thigh">On Thigh</option>
              <option value="on_ankle">On Ankle (like anklet)</option>
            </select>
          </div>
        {/if}

        {#if $templateUnderConstruction.template.flags.gem}
          <div class="col-span-12">
            <h2 class="text-gray-300 text-center">Gem Properties</h2>
          </div>
          <div class="col-span-2">
            <label for="gemType" class="block text-sm font-medium text-gray-300"
              >Type</label
            >
            <select
              id="gemType"
              bind:value={$templateUnderConstruction.template.gem.type}
              name="gemType"
              class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
              <option>agate</option>
              <option>diamond</option>
              <option>emerald</option>
              <option>sapphire</option>
              <option>zircon</option>
            </select>
          </div>
          <div class="col-span-2">
            <label
              for="gemCutType"
              class="block text-sm font-medium text-gray-300">Cut</label
            >
            <select
              id="gemCutType"
              bind:value={$templateUnderConstruction.template.gem.cut_type}
              name="gemCutType"
              class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
              <option>uncut</option>
              <option>diamond</option>
              <option>empire</option>
              <option>oval</option>
              <option>princess</option>
              <option>round</option>
              <option>square</option>
            </select>
          </div>
          <div class="col-span-2">
            <label
              for="gemCutQuality"
              class="block text-sm font-medium text-gray-300"
              >Cut quality (1-100)</label
            >
            <input
              bind:value={$templateUnderConstruction.template.gem.cut_quality}
              type="number"
              min="1"
              max="100"
              name="gemCutQuality"
              id="gemCutQuality"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="gemCarats"
              class="block text-sm font-medium text-gray-300"
              >Carats (1-10,000)</label
            >
            <input
              bind:value={$templateUnderConstruction.template.gem.carat}
              type="number"
              min="1"
              max="10000"
              name="gemCarats"
              id="gemCarats"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="gemClarity"
              class="block text-sm font-medium text-gray-300"
              >Clarity (1-10)</label
            >
            <input
              bind:value={$templateUnderConstruction.template.gem.clarity}
              type="number"
              min="1"
              max="10"
              name="gemClarity"
              id="gemClarity"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="gemSaturation"
              class="block text-sm font-medium text-gray-300"
              >Saturation (1-10, 5-6 Ideal)</label
            >
            <input
              bind:value={$templateUnderConstruction.template.gem.saturation}
              type="number"
              min="1"
              max="10"
              name="gemSaturation"
              id="gemSaturation"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label for="gemTone" class="block text-sm font-medium text-gray-300"
              >Tone (1-10, 5-6 Ideal)</label
            >
            <input
              bind:value={$templateUnderConstruction.template.gem.saturation}
              type="number"
              min="1"
              max="10"
              name="gemTone"
              id="gemTone"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
        {/if}
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
        on:click={cancelEditTemplate}
        class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
      >
        Cancel
      </button>
    </div>
  </div>
</form>
