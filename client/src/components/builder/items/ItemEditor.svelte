<script>
  import { WorldBuilderStore } from "../state";
  const { itemUnderConstruction, saveItem, cancelEditItem } = WorldBuilderStore;

  const allowRelativeToCharacterPlacement = false;
  export let allowRelativePlacement = false;
  export let otherItemsForRelativePlacement = {};
  export let saveItemCallback = saveItem;

  $: disableArmorCheckbox =
    $itemUnderConstruction.flags.clothing ||
    $itemUnderConstruction.flags.coin ||
    $itemUnderConstruction.flags.container ||
    $itemUnderConstruction.flags.furniture ||
    $itemUnderConstruction.flags.gem ||
    $itemUnderConstruction.flags.instrument ||
    $itemUnderConstruction.flags.jewelry ||
    $itemUnderConstruction.flags.material ||
    $itemUnderConstruction.flags.shield ||
    $itemUnderConstruction.flags.surface ||
    $itemUnderConstruction.flags.weapon;

  $: disableClothingCheckbox =
    $itemUnderConstruction.flags.armor ||
    $itemUnderConstruction.flags.coin ||
    $itemUnderConstruction.flags.container ||
    $itemUnderConstruction.flags.furniture ||
    $itemUnderConstruction.flags.gem ||
    $itemUnderConstruction.flags.instrument ||
    $itemUnderConstruction.flags.jewelry ||
    $itemUnderConstruction.flags.material ||
    $itemUnderConstruction.flags.shield ||
    $itemUnderConstruction.flags.surface ||
    $itemUnderConstruction.flags.weapon;

  $: disableCoinCheckbox =
    $itemUnderConstruction.flags.armor ||
    $itemUnderConstruction.flags.clothing ||
    $itemUnderConstruction.flags.container ||
    $itemUnderConstruction.flags.furniture ||
    $itemUnderConstruction.flags.gem ||
    $itemUnderConstruction.flags.instrument ||
    $itemUnderConstruction.flags.jewelry ||
    $itemUnderConstruction.flags.material ||
    $itemUnderConstruction.flags.shield ||
    $itemUnderConstruction.flags.surface ||
    $itemUnderConstruction.flags.weapon;

  $: disableContainerCheckbox =
    $itemUnderConstruction.flags.armor ||
    $itemUnderConstruction.flags.clothing ||
    $itemUnderConstruction.flags.coin ||
    $itemUnderConstruction.flags.furniture ||
    $itemUnderConstruction.flags.gem ||
    $itemUnderConstruction.flags.instrument ||
    $itemUnderConstruction.flags.jewelry ||
    $itemUnderConstruction.flags.material ||
    $itemUnderConstruction.flags.shield ||
    $itemUnderConstruction.flags.surface ||
    $itemUnderConstruction.flags.weapon;

  $: disableFurnitureCheckbox =
    $itemUnderConstruction.flags.armor ||
    $itemUnderConstruction.flags.clothing ||
    $itemUnderConstruction.flags.coin ||
    $itemUnderConstruction.flags.container ||
    $itemUnderConstruction.flags.gem ||
    $itemUnderConstruction.flags.instrument ||
    $itemUnderConstruction.flags.jewelry ||
    $itemUnderConstruction.flags.material ||
    $itemUnderConstruction.flags.shield ||
    $itemUnderConstruction.flags.surface ||
    $itemUnderConstruction.flags.weapon;

  $: disableGemCheckbox =
    $itemUnderConstruction.flags.armor ||
    $itemUnderConstruction.flags.clothing ||
    $itemUnderConstruction.flags.coin ||
    $itemUnderConstruction.flags.container ||
    $itemUnderConstruction.flags.furniture ||
    $itemUnderConstruction.flags.gem ||
    $itemUnderConstruction.flags.instrument ||
    $itemUnderConstruction.flags.jewelry ||
    $itemUnderConstruction.flags.material ||
    $itemUnderConstruction.flags.shield ||
    $itemUnderConstruction.flags.surface ||
    $itemUnderConstruction.flags.weapon;

  $: disableInstrumentCheckbox =
    $itemUnderConstruction.flags.armor ||
    $itemUnderConstruction.flags.clothing ||
    $itemUnderConstruction.flags.coin ||
    $itemUnderConstruction.flags.container ||
    $itemUnderConstruction.flags.furniture ||
    $itemUnderConstruction.flags.gem ||
    $itemUnderConstruction.flags.jewelry ||
    $itemUnderConstruction.flags.material ||
    $itemUnderConstruction.flags.shield ||
    $itemUnderConstruction.flags.surface ||
    $itemUnderConstruction.flags.weapon;

  $: disableJewelryCheckbox =
    $itemUnderConstruction.flags.armor ||
    $itemUnderConstruction.flags.clothing ||
    $itemUnderConstruction.flags.coin ||
    $itemUnderConstruction.flags.container ||
    $itemUnderConstruction.flags.furniture ||
    $itemUnderConstruction.flags.gem ||
    $itemUnderConstruction.flags.instrument ||
    $itemUnderConstruction.flags.material ||
    $itemUnderConstruction.flags.shield ||
    $itemUnderConstruction.flags.surface ||
    $itemUnderConstruction.flags.weapon;

  $: disableMaterialCheckbox =
    $itemUnderConstruction.flags.armor ||
    $itemUnderConstruction.flags.clothing ||
    $itemUnderConstruction.flags.coin ||
    $itemUnderConstruction.flags.container ||
    $itemUnderConstruction.flags.furniture ||
    $itemUnderConstruction.flags.gem ||
    $itemUnderConstruction.flags.instrument ||
    $itemUnderConstruction.flags.jewelry ||
    $itemUnderConstruction.flags.surface ||
    $itemUnderConstruction.flags.shield;
  $itemUnderConstruction.flags.weapon;

  $: disableSceneryCheckbox = false;

  $: disableShieldCheckbox =
    $itemUnderConstruction.flags.armor ||
    $itemUnderConstruction.flags.clothing ||
    $itemUnderConstruction.flags.coin ||
    $itemUnderConstruction.flags.container ||
    $itemUnderConstruction.flags.furniture ||
    $itemUnderConstruction.flags.gem ||
    $itemUnderConstruction.flags.instrument ||
    $itemUnderConstruction.flags.jewelry ||
    $itemUnderConstruction.flags.material ||
    $itemUnderConstruction.flags.surface ||
    $itemUnderConstruction.flags.weapon;

  $: disableWeaponCheckbox =
    $itemUnderConstruction.flags.armor ||
    $itemUnderConstruction.flags.clothing ||
    $itemUnderConstruction.flags.coin ||
    $itemUnderConstruction.flags.container ||
    $itemUnderConstruction.flags.furniture ||
    $itemUnderConstruction.flags.gem ||
    $itemUnderConstruction.flags.instrument ||
    $itemUnderConstruction.flags.jewelry ||
    $itemUnderConstruction.flags.material ||
    $itemUnderConstruction.flags.surface ||
    $itemUnderConstruction.flags.shield;

  $: disableGemPouchCheckbox =
    !$itemUnderConstruction.flags.container ||
    !$itemUnderConstruction.flags.wearable;

  $: disableHiddenCheckbox = !$itemUnderConstruction.flags.scenery;

  $: disableShopDisplayCheckbox = !$itemUnderConstruction.flags.furniture;

  $: disableWearableCheckbox = !$itemUnderConstruction.flags.container;

  $: disablePocketCheckbox =
    $itemUnderConstruction.flags.armor ||
    $itemUnderConstruction.flags.clothing ||
    $itemUnderConstruction.flags.coin ||
    $itemUnderConstruction.flags.container ||
    $itemUnderConstruction.flags.furniture ||
    $itemUnderConstruction.flags.gem ||
    $itemUnderConstruction.flags.instrument ||
    $itemUnderConstruction.flags.jewelry ||
    $itemUnderConstruction.flags.material ||
    $itemUnderConstruction.flags.shield ||
    $itemUnderConstruction.flags.weapon;

  $: disableSurfaceCheckbox =
    !$itemUnderConstruction.flags.furniture &&
    !$itemUnderConstruction.flags.scenery;

  $: disableCloseCheckbox = !$itemUnderConstruction.flags.container;

  $: disableDropCheckbox = !$itemUnderConstruction.flags.hold;

  $: disableHoldCheckbox = $itemUnderConstruction.flags.scenery;

  $: disableLookCheckbox = false;

  $: disableOpenCheckbox = !$itemUnderConstruction.flags.container;

  $: disableRemoveCheckbox = !$itemUnderConstruction.flags.wearable;

  $: disableStoreCheckbox = $itemUnderConstruction.flags.scenery;

  $: disableTrashCheckbox =
    $itemUnderConstruction.flags.scenery ||
    $itemUnderConstruction.flags.furniture ||
    $itemUnderConstruction.flags.gem ||
    $itemUnderConstruction.flags.coin;

  $: disableWearCheckbox = !$itemUnderConstruction.flags.wearable;

  $: disableRelationSelect =
    $itemUnderConstruction.location.relative_item_id == "";

  $: disableOnGroundCheckbox =
    $itemUnderConstruction.location.relative_to_item ||
    $itemUnderConstruction.location.held_in_hand ||
    $itemUnderConstruction.location.worn_on_character;

  $: disableHeldInHandCheckbox =
    $itemUnderConstruction.location.relative_to_item ||
    $itemUnderConstruction.location.on_ground ||
    $itemUnderConstruction.location.worn_on_character;

  $: disableRelativeToItemCheckbox =
    $itemUnderConstruction.location.on_ground ||
    $itemUnderConstruction.location.held_in_hand ||
    $itemUnderConstruction.location.worn_on_character;

  $: disableWornOnCharacterCheckbox =
    $itemUnderConstruction.location.relative_to_item ||
    $itemUnderConstruction.location.on_ground ||
    $itemUnderConstruction.location.held_in_hand;

  function handleOtherItemChange() {
    // if other id is blank make sure it the rest of the flags are not set for it to be relative to an item
    // if other item id is not blank make sure flags are set for it to be relative
    if ($itemUnderConstruction.location.relative_item_id != "") {
      $itemUnderConstruction.location.on_ground = false;
      $itemUnderConstruction.location.relative_to_item = true;
    } else {
      $itemUnderConstruction.location.on_ground = true;
      $itemUnderConstruction.location.relative_to_item = false;
    }

    if (
      otherItemsForRelativePlacement[
        $itemUnderConstruction.location.relative_item_id
      ].flags.furniture &&
      otherItemsForRelativePlacement[
        $itemUnderConstruction.location.relative_item_id
      ].furniture.has_external_surface
    ) {
      const vals = ["on"];
      if (!vals.includes($itemUnderConstruction.location.relation)) {
        $itemUnderConstruction.location.relation = "on";
      }
    } else if (
      otherItemsForRelativePlacement[
        $itemUnderConstruction.location.relative_item_id
      ].flags.container ||
      (otherItemsForRelativePlacement[
        $itemUnderConstruction.location.relative_item_id
      ].flags.furniture &&
        otherItemsForRelativePlacement[
          $itemUnderConstruction.location.relative_item_id
        ].furniture.has_internal_surface)
    ) {
      const vals = ["in"];
      if (!vals.includes($itemUnderConstruction.location.relation)) {
        $itemUnderConstruction.location.relation = "in";
      }
    }
  }
</script>

<form
  class="h-full flex flex-col place-content-center"
  on:submit|preventDefault={saveItemCallback}
>
  <div class="overflow-hidden sm:rounded-md">
    <div class="px-4 py-5 sm:p-6">
      <div class="grid grid-cols-12 gap-4">
        <div class="col-span-12">
          <h2 class="text-gray-300 text-center">Item Description</h2>
        </div>
        <div class="col-span-3">
          <label
            for="itemShortDescription"
            class="block text-sm font-medium text-gray-300"
            >Item Short Description</label
          >
          <input
            bind:value={$itemUnderConstruction.description.short}
            type="textarea"
            name="itemShortDescription"
            id="itemShortDescription"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>
        <div class="col-span-9">
          <label
            for="itemLongDescription"
            class="block text-sm font-medium text-gray-300"
            >Item Long Description</label
          >
          <input
            bind:value={$itemUnderConstruction.description.long}
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
            bind:checked={$itemUnderConstruction.flags.armor}
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
            bind:checked={$itemUnderConstruction.flags.clothing}
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
            bind:checked={$itemUnderConstruction.flags.coin}
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
            bind:checked={$itemUnderConstruction.flags.container}
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
            bind:checked={$itemUnderConstruction.flags.furniture}
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
            bind:checked={$itemUnderConstruction.flags.gem}
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
            bind:checked={$itemUnderConstruction.flags.instrument}
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
            bind:checked={$itemUnderConstruction.flags.jewelry}
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
            bind:checked={$itemUnderConstruction.flags.material}
            type="checkbox"
            name="isMaterial"
            id="isMaterial"
            disabled={disableMaterialCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="isShield" class="block text-sm font-medium text-gray-300"
            >Shield</label
          >
          <input
            bind:checked={$itemUnderConstruction.flags.shield}
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
            bind:checked={$itemUnderConstruction.flags.weapon}
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
            bind:checked={$itemUnderConstruction.flags.gem_pouch}
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
            bind:checked={$itemUnderConstruction.flags.hidden}
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
            bind:checked={$itemUnderConstruction.flags.shop_display}
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
            bind:checked={$itemUnderConstruction.flags.wearable}
            type="checkbox"
            name="isWearable"
            id="isWearable"
            disabled={disableWearableCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="hasPocket" class="block text-sm font-medium text-gray-300"
            >Has Pocket</label
          >
          <input
            bind:checked={$itemUnderConstruction.flags.has_pocket}
            type="checkbox"
            name="hasPocket"
            id="hasPocket"
            disabled={disablePocketCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label
            for="hasSurface"
            class="block text-sm font-medium text-gray-300">Surface</label
          >
          <input
            bind:checked={$itemUnderConstruction.flags.has_surface}
            type="checkbox"
            name="hasSurface"
            id="hasSurface"
            disabled={disableSurfaceCheckbox}
          />
        </div>
        <div class="col-span-1">
          <label for="isScenery" class="block text-sm font-medium text-gray-300"
            >Scenery</label
          >
          <input
            bind:checked={$itemUnderConstruction.flags.scenery}
            type="checkbox"
            name="isScenery"
            id="isScenery"
            disabled={disableSceneryCheckbox}
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
            bind:checked={$itemUnderConstruction.flags.close}
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
            bind:checked={$itemUnderConstruction.flags.drop}
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
            bind:checked={$itemUnderConstruction.flags.hold}
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
            bind:checked={$itemUnderConstruction.flags.look}
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
            bind:checked={$itemUnderConstruction.flags.open}
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
            bind:checked={$itemUnderConstruction.flags.remove}
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
            bind:checked={$itemUnderConstruction.flags.store}
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
            bind:checked={$itemUnderConstruction.flags.trash}
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
            bind:checked={$itemUnderConstruction.flags.wear}
            type="checkbox"
            name="canWear"
            id="canWear"
            disabled={disableWearCheckbox}
          />
        </div>

        <div class="col-span-12">
          <h2 class="text-gray-300 text-center">Location</h2>
        </div>
        <div class="col-span-1">
          <label for="onGround" class="block text-sm font-medium text-gray-300"
            >On Ground</label
          >
          <input
            bind:checked={$itemUnderConstruction.location.on_ground}
            type="checkbox"
            name="onGround"
            id="onGround"
            disabled={disableOnGroundCheckbox}
          />
        </div>

        {#if allowRelativeToCharacterPlacement}
          <div class="col-span-1">
            <label
              for="heldInHand"
              class="block text-sm font-medium text-gray-300"
              >Held In Hand</label
            >
            <input
              bind:checked={$itemUnderConstruction.location.held_in_hand}
              type="checkbox"
              name="heldInHand"
              id="heldInHand"
              disabled={disableHeldInHandCheckbox}
            />
          </div>
          <div class="col-span-1">
            <label
              for="wornOnCharacter"
              class="block text-sm font-medium text-gray-300"
              >Worn On Character</label
            >
            <input
              bind:checked={$itemUnderConstruction.location.worn_on_character}
              type="checkbox"
              name="wornOnCharacter"
              id="wornOnCharacter"
              disabled={disableWornOnCharacterCheckbox}
            />
          </div>
        {/if}
        <div class="col-span-1">
          <label
            for="relativeToItem"
            class="block text-sm font-medium text-gray-300"
            >Relative To Item</label
          >
          <input
            bind:checked={$itemUnderConstruction.location.relative_to_item}
            type="checkbox"
            name="relativeToItem"
            id="relativeToItem"
            disabled={disableRelativeToItemCheckbox}
          />
        </div>

        {#if $itemUnderConstruction.flags.physics}
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
              bind:value={$itemUnderConstruction.physics.weight}
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
              class="block text-sm font-medium text-gray-300"
              >Height in cm</label
            >
            <input
              bind:value={$itemUnderConstruction.physics.height}
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
              class="block text-sm font-medium text-gray-300"
              >Length in cm</label
            >
            <input
              bind:value={$itemUnderConstruction.physics.length}
              type="number"
              min="0"
              max="1000000000000000"
              name="itemLength"
              id="itemLength"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="itemWidth"
              class="block text-sm font-medium text-gray-300">Width in cm</label
            >
            <input
              bind:value={$itemUnderConstruction.physics.width}
              type="number"
              min="0"
              max="1000000000000000"
              name="itemWidth"
              id="itemWidth"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
        {/if}

        {#if $itemUnderConstruction.flags.has_surface}
          <div class="col-span-12">
            <h2 class="text-gray-300 text-center">Surface Properties</h2>
          </div>
          <div class="col-span-1">
            <label
              for="showItemContents"
              class="block text-sm font-medium text-gray-300"
              >Show Item Contents</label
            >
            <input
              bind:checked={$itemUnderConstruction.surface.show_item_contents}
              type="checkbox"
              name="showItemContents"
              id="showItemContents"
            />
          </div>
          {#if $itemUnderConstruction.surface.show_item_contents}
            <div class="col-span-1">
              <label
                for="showDetailedItems"
                class="block text-sm font-medium text-gray-300"
                >Show Detailed Items</label
              >
              <input
                bind:checked={$itemUnderConstruction.surface
                  .show_detailed_items}
                type="checkbox"
                name="showDetailedItems"
                id="showDetailedItems"
              />
            </div>
            <div class="col-span-2">
              <label
                for="showItemLimit"
                class="block text-sm font-medium text-gray-300"
                >Show Item Limit</label
              >
              <input
                bind:value={$itemUnderConstruction.surface.show_item_limit}
                type="number"
                min="0"
                max="1000000000000000"
                name="showItemLimit"
                id="showItemLimit"
                class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
              />
            </div>
          {/if}
          <div class="col-span-2">
            <label
              for="itemCountLimit"
              class="block text-sm font-medium text-gray-300"
              >Item Count Limit</label
            >
            <input
              bind:value={$itemUnderConstruction.surface.item_count_limit}
              type="number"
              min="0"
              max="1000000000000000"
              name="itemCountLimit"
              id="itemCountLimit"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="itemWeightLimit"
              class="block text-sm font-medium text-gray-300"
              >Item Weight Limit</label
            >
            <input
              bind:value={$itemUnderConstruction.surface.item_weight_limit}
              type="number"
              min="0"
              max="1000000000000000"
              name="itemWeightLimit"
              id="itemWeightLimit"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-1">
            <label
              for="canHoldCharacters"
              class="block text-sm font-medium text-gray-300"
              >Can Hold Characters</label
            >
            <input
              bind:checked={$itemUnderConstruction.surface.can_hold_characters}
              type="checkbox"
              name="canHoldCharacters"
              id="canHoldCharacters"
            />
          </div>
          {#if $itemUnderConstruction.surface.can_hold_characters}
            <div class="col-span-2">
              <label
                for="characterLimit"
                class="block text-sm font-medium text-gray-300"
                >Character Limit</label
              >
              <input
                bind:value={$itemUnderConstruction.surface.character_limit}
                type="number"
                min="0"
                max="1000000000000000"
                name="characterLimit"
                id="characterLimit"
                class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
              />
            </div>
          {/if}
        {/if}

        {#if $itemUnderConstruction.flags.container}
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
              bind:value={$itemUnderConstruction.container.capacity}
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
              bind:value={$itemUnderConstruction.container.height}
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
              bind:value={$itemUnderConstruction.container.length}
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
              bind:value={$itemUnderConstruction.container.width}
              type="number"
              min="0"
              max="1000000000000000"
              name="containerWidth"
              id="containerWidth"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
        {/if}

        {#if $itemUnderConstruction.flags.wearable}
          <div class="col-span-12">
            <h2 class="text-gray-300 text-center">Wearable Properties</h2>
          </div>
          <div class="col-span-2">
            <label for="gemType" class="block text-sm font-medium text-gray-300"
              >Slot</label
            >
            <select
              id="gemType"
              bind:value={$itemUnderConstruction.wearable.slot}
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

        {#if $itemUnderConstruction.flags.gem}
          <div class="col-span-12">
            <h2 class="text-gray-300 text-center">Gem Properties</h2>
          </div>
          <div class="col-span-2">
            <label for="gemType" class="block text-sm font-medium text-gray-300"
              >Type</label
            >
            <select
              id="gemType"
              bind:value={$itemUnderConstruction.gem.type}
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
              bind:value={$itemUnderConstruction.gem.cut_type}
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
              bind:value={$itemUnderConstruction.gem.cut_quality}
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
              bind:value={$itemUnderConstruction.gem.carat}
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
              bind:value={$itemUnderConstruction.gem.clarity}
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
              bind:value={$itemUnderConstruction.gem.saturation}
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
              bind:value={$itemUnderConstruction.gem.saturation}
              type="number"
              min="1"
              max="10"
              name="gemTone"
              id="gemTone"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
        {/if}

        {#if allowRelativePlacement && Object.values(otherItemsForRelativePlacement).length > 0 && $itemUnderConstruction.location.relative_to_item}
          <div class="col-span-12">
            <h2 class="text-gray-300 text-center">
              Placement Relative to Other Item
            </h2>
          </div>
          <div class="col-span-2">
            <label
              for="otherItem"
              class="block text-sm font-medium text-gray-300"
              >Item to place relative to</label
            >
            <select
              id="otherItem"
              on:blur={handleOtherItemChange}
              bind:value={$itemUnderConstruction.location.relative_item_id}
              name="otherItem"
              class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
              <option value="">none</option>
              {#each Object.values(otherItemsForRelativePlacement) as otherItem}
                <option value={otherItem.id}
                  >{otherItem.description.short}</option
                >
              {/each}
            </select>
          </div>
          <div class="col-span-2">
            <label
              for="relationToOtherItem"
              class="block text-sm font-medium text-gray-300"
              >Position to place item relative to other</label
            >
            <select
              id="relationToOtherItem"
              bind:value={$itemUnderConstruction.location.relation}
              disabled={disableRelationSelect}
              name="relationToOtherItem"
              class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
              {#if $itemUnderConstruction.location.relation == ""}
                <option value="" selected disabled
                  >Select Relative Location</option
                >
              {/if}
              {#if otherItemsForRelativePlacement[$itemUnderConstruction.location.relative_item_id] && otherItemsForRelativePlacement[$itemUnderConstruction.location.relative_item_id].flags.has_surface}
                <option value="on">on</option>
              {/if}
              {#if otherItemsForRelativePlacement[$itemUnderConstruction.location.relative_item_id] && otherItemsForRelativePlacement[$itemUnderConstruction.location.relative_item_id].flags.container}
                <option value="in">in</option>
              {/if}
            </select>
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
        on:click={cancelEditItem}
        class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
      >
        Cancel
      </button>
    </div>
  </div>
</form>
