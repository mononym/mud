<script>
  import { onMount } from "svelte";
  import { WorldBuilderStore } from "../state";
  const {
    templateUnderConstruction,
    saveTemplate,
    cancelEditTemplate,
  } = WorldBuilderStore;

  $: disableArmorCheckbox =
    $templateUnderConstruction.template.flags.is_clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.is_equipment ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.surface ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableClothingCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.is_equipment ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.surface ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableCoinCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.is_clothing ||
    $templateUnderConstruction.template.flags.is_equipment ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.surface ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableEquipmentCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.is_clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.surface ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableFurnitureCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.is_clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.is_equipment ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.surface ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableGemCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.is_clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.is_equipment ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.surface ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableInstrumentCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.is_clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.is_equipment ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.surface ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableJewelryCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.is_clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.is_equipment ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.shield ||
    $templateUnderConstruction.template.flags.surface ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableMaterialCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.is_clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.is_equipment ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.surface ||
    $templateUnderConstruction.template.flags.shield;
  $templateUnderConstruction.template.flags.weapon;

  $: disableSceneryCheckbox = false;

  $: disableShieldCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.is_clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.is_equipment ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.surface ||
    $templateUnderConstruction.template.flags.weapon;

  $: disableWeaponCheckbox =
    $templateUnderConstruction.template.flags.armor ||
    $templateUnderConstruction.template.flags.is_clothing ||
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.is_equipment ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.instrument ||
    $templateUnderConstruction.template.flags.jewelry ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.surface ||
    $templateUnderConstruction.template.flags.shield;

  $: disableGemPouchCheckbox =
    !$templateUnderConstruction.template.flags.has_pocket ||
    !$templateUnderConstruction.template.flags.wearable;

  $: disableHiddenCheckbox = !$templateUnderConstruction.template.flags.scenery;

  $: disableShopDisplayCheckbox = !$templateUnderConstruction.template.flags
    .furniture;

  $: disableWearableCheckbox =
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.material ||
    $templateUnderConstruction.template.flags.scenery;

  $: disablePocketCheckbox =
    $templateUnderConstruction.template.flags.coin ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.material;

  $: disableSurfaceCheckbox =
    !$templateUnderConstruction.template.flags.furniture &&
    !(
      $templateUnderConstruction.template.flags.scenery &&
      $templateUnderConstruction.template.flags.equipment
    );

  $: disableCloseCheckbox = !$templateUnderConstruction.template.flags
    .has_pocket;

  $: disableDropCheckbox = !$templateUnderConstruction.template.flags.hold;

  $: disableHoldCheckbox = $templateUnderConstruction.template.flags.scenery;

  $: disableLookCheckbox = false;

  $: disableOpenCheckbox = !$templateUnderConstruction.template.flags
    .has_pocket;

  $: disableRemoveCheckbox = !$templateUnderConstruction.template.flags
    .wearable;

  $: disableStoreCheckbox = $templateUnderConstruction.template.flags.scenery;

  $: disableTrashCheckbox =
    $templateUnderConstruction.template.flags.scenery ||
    $templateUnderConstruction.template.flags.furniture ||
    $templateUnderConstruction.template.flags.gem ||
    $templateUnderConstruction.template.flags.coin;

  $: disableWearCheckbox = !$templateUnderConstruction.template.flags.wearable;

  $: disableRelationSelect =
    $templateUnderConstruction.template.location.relative_item_id == "";

  $: disableOnGroundCheckbox =
    $templateUnderConstruction.template.location.relative_to_item ||
    $templateUnderConstruction.template.location.held_in_hand ||
    $templateUnderConstruction.template.location.worn_on_character;

  $: disableHeldInHandCheckbox =
    $templateUnderConstruction.template.location.relative_to_item ||
    $templateUnderConstruction.template.location.on_ground ||
    $templateUnderConstruction.template.location.worn_on_character;

  $: disableRelativeToItemCheckbox =
    $templateUnderConstruction.template.location.on_ground ||
    $templateUnderConstruction.template.location.held_in_hand ||
    $templateUnderConstruction.template.location.worn_on_character;

  $: disableWornOnCharacterCheckbox =
    $templateUnderConstruction.template.location.relative_to_item ||
    $templateUnderConstruction.template.location.on_ground ||
    $templateUnderConstruction.template.location.held_in_hand;

  onMount(() => {
    console.log("onMount");
    console.log($templateUnderConstruction);
  });

  let customizeLongDescription = false;

  function onChangeCustomizeLongDescription(event) {
    console.log("onChange");
    console.log($templateUnderConstruction.template.description);
    if (!customizeLongDescription) {
      $templateUnderConstruction.template.description.long =
        $templateUnderConstruction.template.description.short;
    }
    console.log($templateUnderConstruction.template.description);
  }
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
        <div class="col-span-3">
          <label
            for="name"
            class="block text-sm font-medium text-gray-300"
            data-tippy-content="The name of the template is not the name of the item."
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
        <div class="col-span-9">
          <label
            for="description"
            class="block text-sm font-medium text-gray-300"
            data-tippy-content="The intended use or reason for creation of the template. To aid with organizing and keeping track of created templates."
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
          <h2 class="text-gray-300 font-bold">Item Description:</h2>
        </div>
        <div
          class="col-span-1"
          data-tippy-content="The key aids in searching for items, and as such this single word MUST match one of the words in both the short and long description. For example, `a sturdy backpack with red and white piping` would have the key `backpack`."
        >
          <label for="itemKey" class="block text-sm font-medium text-gray-300"
            >Item Key</label
          >
          <input
            bind:value={$templateUnderConstruction.template.description.key}
            type="textarea"
            name="itemKey"
            id="itemKey"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>
        <div class="col-span-2">
          <label
            for="itemShortDescription"
            class="block text-sm font-medium text-gray-300"
            >Item Short Description</label
          >
          <input
            bind:value={$templateUnderConstruction.template.description.short}
            on:keydown={onChangeCustomizeLongDescription}
            type="textarea"
            name="itemShortDescription"
            id="itemShortDescription"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>

        <div class="col-span-1">
          <label
            for="customizeLongDescription"
            class="block text-sm font-medium text-gray-300"
            >Customize Long Description</label
          >
          <input
            bind:checked={customizeLongDescription}
            type="checkbox"
            name="customizeLongDescription"
            id="customizeLongDescription"
          />
        </div>
        {#if customizeLongDescription}
          <div class="col-span-8">
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
        {/if}
        <div class="col-span-12">
          <h2 class="text-gray-300 font-bold">Item Type (Pick One):</h2>
        </div>
        <!-- <div class="col-span-1">
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
      </div> -->
        <div class="col-span-1">
          <label
            for="isClothing"
            class="block text-sm font-medium text-gray-300">Clothing</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.is_clothing}
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
        <div
          class="col-span-1"
          data-tippy-content="Most things that are not of a special sort, like furniture or armor, end up being equipment. A cup or a platter is equipment as much as a rope is."
        >
          <label
            for="isEquipment"
            class="block text-sm font-medium text-gray-300">Equipment</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags
              .is_equipment}
            type="checkbox"
            name="isEquipment"
            id="isEquipment"
            disabled={disableEquipmentCheckbox}
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
        <!-- <div class="col-span-1">
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
      </div> -->
        <!-- <div class="col-span-1">
        <label
          for="isMaterial"
          data-tippy-content="Raw materials used in crafting"
          class="block text-sm font-medium text-gray-300">Material</label
        >
        <input
          bind:checked={$templateUnderConstruction.template.flags.material}
          type="checkbox"
          name="isMaterial"
          id="isMaterial"
          disabled={disableMaterialCheckbox}
        />
      </div> -->
        <!-- <div class="col-span-1">
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
      </div> -->
        <div class="col-span-12">
          <h2 class="text-gray-300 font-bold">Behavior Modifiers:</h2>
        </div>
        <div
          class="col-span-1"
          data-tippy-content="A gem pouch is a special class of container that is treated differently with some commands. Only apply this to things actually meant to be a gem pouch"
        >
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
        <div
          class="col-span-1"
          data-tippy-content="Should be used together with scenery. Making an item hidden means that while it will exist in the area, it will not show up directly in the list of items to be seen. This lets you do things like reference a fountain in a description and have a hidden item for characters to look at."
        >
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
        <!-- <div class="col-span-1">
        <label
          for="isShopDisplay"
          class="block text-sm font-medium text-gray-300">Shop Display</label
        >
        <input
          bind:checked={$templateUnderConstruction.template.flags.shop_display}
          type="checkbox"
          name="isShopDisplay"
          id="isShopDisplay"
          disabled={disableShopDisplayCheckbox}
        />
      </div> -->
        <div class="col-span-1" data-tippy-content="The item can be worn.">
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
        <div
          class="col-span-1"
          data-tippy-content="Items which have a physical presence need to have their dimensions/weight configured."
        >
          <label
            for="hasPhysics"
            class="block text-sm font-medium text-gray-300">Has Physics</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.has_physics}
            type="checkbox"
            name="hasPhysics"
            id="hasPhysics"
          />
        </div>
        <div
          class="col-span-1"
          data-tippy-content="A pocket is a generic 'space' for holding things and can apply equally to a vault as to a packpack as to a pouch."
        >
          <label for="hasPocket" class="block text-sm font-medium text-gray-300"
            >Has Pocket</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.has_pocket}
            type="checkbox"
            name="hasPocket"
            id="hasPocket"
            disabled={disablePocketCheckbox}
          />
        </div>
        <div
          class="col-span-1"
          data-tippy-content="A  generic horizontal surface which can be configured to hold items and characters. Could apply to things like a jewelry box, a table, or a shelf."
        >
          <label
            for="hasSurface"
            class="block text-sm font-medium text-gray-300">Has Surface</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.has_surface}
            type="checkbox"
            name="hasSurface"
            id="hasSurface"
            disabled={disableSurfaceCheckbox}
          />
        </div>
        <div
          class="col-span-1"
          data-tippy-content="The item will be part of the background and will show up in the Things of Interest part of an area description. Items that are scenery are expected to be locked down in terms of what characters can do with them."
        >
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
        <div class="col-span-12">
          <h2 class="text-gray-300 font-bold">
            Actions which can be taken on an item by a character :
          </h2>
        </div>
        <div
          class="col-span-1"
          data-tippy-content="This generally applies to things with pockets, such as backpacks, but can also apply to books or jewelry, or so on."
        >
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
        <div
          class="col-span-1"
          data-tippy-content="If a character is holding an item, this determines if it can be dropped/put somewhere. Does not control if the item can be stowed on the character."
        >
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
        <div
          class="col-span-1"
          data-tippy-content="Determines if a character can hold an item, which in practice means being able to get or even stow (because to stow you have to 'get') an item."
        >
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
        <!-- <div class="col-span-1">
        <label for="canLook" class="block text-sm font-medium text-gray-300"
        data-tippy-content="If the item can be looked at."
          >Look</label
        >
        <input
          bind:checked={$templateUnderConstruction.template.flags.look}
          type="checkbox"
          name="canLook"
          id="canLook"
          disabled={disableLookCheckbox}
        />
      </div> -->
        <div
          class="col-span-1"
          data-tippy-content="If the item is a closable item, controls if you can also open said item."
        >
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
        <div
          class="col-span-1"
          data-tippy-content="If an item is a wearable item, this controls if the item can be removed from the character or if they are stuck with it once it is on."
        >
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
        <div
          class="col-span-1"
          data-tippy-content="Controls if an item can be put away into a container on the character."
        >
          <label for="canStore" class="block text-sm font-medium text-gray-300"
            >Stow</label
          >
          <input
            bind:checked={$templateUnderConstruction.template.flags.stow}
            type="checkbox"
            name="canStore"
            id="canStore"
            disabled={disableStoreCheckbox}
          />
        </div>
        <!-- <div class="col-span-1">
        <label for="canTrash" class="block text-sm font-medium text-gray-300"
        data-tippy-content="A trashed item is simply destroyed."
          >Trash</label
        >
        <input
          bind:checked={$templateUnderConstruction.template.flags.trash}
          type="checkbox"
          name="canTrash"
          id="canTrash"
          disabled={disableTrashCheckbox}
        />
      </div> -->
        <div
          class="col-span-1"
          data-tippy-content="If a character can wear a wearable item."
        >
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

        {#if $templateUnderConstruction.template.flags.has_physics}
          <div class="col-span-12">
            <h2 class="text-gray-300 font-bold">Physical Properties:</h2>
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
              class="block text-sm font-medium text-gray-300"
              >Height in cm</label
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
              class="block text-sm font-medium text-gray-300"
              >Length in cm</label
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
            <label
              for="itemWidth"
              class="block text-sm font-medium text-gray-300">Width in cm</label
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
        {/if}

        {#if $templateUnderConstruction.template.flags.has_surface}
          <div class="col-span-12">
            <h2 class="text-gray-300 font-bold">Surface Properties:</h2>
          </div>
          <div
            class="col-span-1"
            data-tippy-content="Show items on the surface as part of a generic look action. A table with this on would show the items on it as part of the area description."
          >
            <label
              for="showItemContents"
              class="block text-sm font-medium text-gray-300"
              >Show Item Contents</label
            >
            <input
              bind:checked={$templateUnderConstruction.template.surface
                .show_item_contents}
              type="checkbox"
              name="showItemContents"
              id="showItemContents"
            />
          </div>
          {#if $templateUnderConstruction.template.surface.show_item_contents}
            <div
              class="col-span-1"
              data-tippy-content="If selected items on the surface will be described using their long description rather than their short."
            >
              <label
                for="showDetailedItems"
                class="block text-sm font-medium text-gray-300"
                >Show Detailed Items</label
              >
              <input
                bind:checked={$templateUnderConstruction.template.surface
                  .show_detailed_items}
                type="checkbox"
                name="showDetailedItems"
                id="showDetailedItems"
              />
            </div>
            <div
              class="col-span-2"
              data-tippy-content="When showing items, as in the case of a table in an area during a 'look' action, this determines how many items to actually show before signaling there is more to see with an explicit 'look on table'. O is unlimited."
            >
              <label
                for="showItemLimit"
                class="block text-sm font-medium text-gray-300"
                >Show Item Limit</label
              >
              <input
                bind:value={$templateUnderConstruction.template.surface
                  .show_item_limit}
                type="number"
                min="0"
                max="1000000000000000"
                name="showItemLimit"
                id="showItemLimit"
                class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
              />
            </div>
          {/if}
          <div
            class="col-span-2"
            data-tippy-content="Control how many items, seperate from size or weight, a surface can hold. 0 is unlimited."
          >
            <label
              for="itemCountLimit"
              class="block text-sm font-medium text-gray-300"
              >Item Count Limit</label
            >
            <input
              bind:value={$templateUnderConstruction.template.surface
                .item_count_limit}
              type="number"
              min="0"
              max="1000000000000000"
              name="itemCountLimit"
              id="itemCountLimit"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div
            class="col-span-2"
            data-tippy-content="How much weight a surface can hold. 0 is unlimited. Only items are taken into account, not characters and the items they are carrying. 0 is unlimited."
          >
            <label
              for="itemWeightLimit"
              class="block text-sm font-medium text-gray-300"
              >Item Weight Limit</label
            >
            <input
              bind:value={$templateUnderConstruction.template.surface
                .item_weight_limit}
              type="number"
              min="0"
              max="1000000000000000"
              name="itemWeightLimit"
              id="itemWeightLimit"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div
            class="col-span-2"
            data-tippy-content="The maximum length of the surface available for supporting items. 0 is unlimited."
          >
            <label
              for="surfaceLength"
              class="block text-sm font-medium text-gray-300"
              >Surface length in cm</label
            >
            <input
              bind:value={$templateUnderConstruction.template.surface.length}
              type="number"
              min="0"
              max="1000000000000000"
              name="surfaceLength"
              id="surfaceLength"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div
            class="col-span-2"
            data-tippy-content="The maximum width of the surface available for supporting items. 0 is unlimited."
          >
            <label
              for="surfaceWidth"
              class="block text-sm font-medium text-gray-300"
              >Surface width in cm</label
            >
            <input
              bind:value={$templateUnderConstruction.template.surface.width}
              type="number"
              min="0"
              max="1000000000000000"
              name="surfaceWidth"
              id="surfaceWidth"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div
            class="col-span-1"
            data-tippy-content="Controls whether or not items will have to fit the length/width of the surface. For example a pedistal might be able to support an item that is much larger than itself."
          >
            <label
              for="surfaceitemsFit"
              class="block text-sm font-medium text-gray-300"
              >Items must fit</label
            >
            <input
              bind:checked={$templateUnderConstruction.template.surface
                .items_must_fit}
              type="checkbox"
              name="surfaceitemsFit"
              id="surfaceitemsFit"
            />
          </div>
          <div
            class="col-span-1"
            data-tippy-content="Whether or not the surface can actually hold characters."
          >
            <label
              for="canHoldCharacters"
              class="block text-sm font-medium text-gray-300"
              >Can Hold Characters</label
            >
            <input
              bind:checked={$templateUnderConstruction.template.surface
                .can_hold_characters}
              type="checkbox"
              name="canHoldCharacters"
              id="canHoldCharacters"
            />
          </div>
          {#if $templateUnderConstruction.template.surface.can_hold_characters}
            <div
              class="col-span-2"
              data-tippy-content="How many characters a surface can hold. 0 is unlimited."
            >
              <label
                for="characterLimit"
                class="block text-sm font-medium text-gray-300"
                >Character Limit</label
              >
              <input
                bind:value={$templateUnderConstruction.template.surface
                  .character_limit}
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

        {#if $templateUnderConstruction.template.flags.has_pocket}
          <div class="col-span-12">
            <h2 class="text-gray-300 font-bold">Pocket Properties:</h2>
          </div>
          <div
            class="col-span-2"
            data-tippy-content="Total amount of weight the pocket is able to contain. 0 is unlimited."
          >
            <label
              for="pocketCapacity"
              class="block text-sm font-medium text-gray-300"
              >Capacity in grams</label
            >
            <input
              bind:value={$templateUnderConstruction.template.pocket.capacity}
              type="number"
              min="0"
              max="1000000000000000"
              name="pocketCapacity"
              id="pocketCapacity"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div
            class="col-span-2"
            data-tippy-content="Control how many items, seperate from size or weight, a surface can hold. 0 is unlimited."
          >
            <label
              for="pocketCountLimit"
              class="block text-sm font-medium text-gray-300"
              >Item Count Limit</label
            >
            <input
              bind:value={$templateUnderConstruction.template.pocket.item_limit}
              type="number"
              min="0"
              max="1000000000000000"
              name="pocketCountLimit"
              id="pocketCountLimit"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div
            class="col-span-2"
            data-tippy-content="The maximum internal height of the pocket available for containing items. 0 is unlimited."
          >
            <label
              for="pocketHeight"
              class="block text-sm font-medium text-gray-300"
              >Internal height in cm</label
            >
            <input
              bind:value={$templateUnderConstruction.template.pocket.height}
              type="number"
              min="0"
              max="1000000000000000"
              name="pocketHeight"
              id="pocketHeight"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div
            class="col-span-2"
            data-tippy-content="The maximum internal length of the pocket available for containing items. 0 is unlimited."
          >
            <label
              for="pocketLength"
              class="block text-sm font-medium text-gray-300"
              >Internal length in cm</label
            >
            <input
              bind:value={$templateUnderConstruction.template.pocket.length}
              type="number"
              min="0"
              max="1000000000000000"
              name="pocketLength"
              id="pocketLength"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div
            class="col-span-2"
            data-tippy-content="The maximum internal width of the pocket available for containing items. 0 is unlimited."
          >
            <label
              for="pocketWidth"
              class="block text-sm font-medium text-gray-300"
              >Internal width in cm</label
            >
            <input
              bind:value={$templateUnderConstruction.template.pocket.width}
              type="number"
              min="0"
              max="1000000000000000"
              name="pocketWidth"
              id="pocketWidth"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
        {/if}

        {#if $templateUnderConstruction.template.flags.wearable}
          <div class="col-span-12">
            <h2 class="text-gray-300 font-bold">Wearable Properties:</h2>
          </div>
          <div
            class="col-span-2"
            data-tippy-content="Where on the body the wearable item is actually worn."
          >
            <label
              for="wearableSlot"
              class="block text-sm font-medium text-gray-300">Slot</label
            >
            <select
              id="wearableSlot"
              bind:value={$templateUnderConstruction.template.wearable.slot}
              name="wearableSlot"
              class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
              {#if $templateUnderConstruction.template.wearable.slot == null || $templateUnderConstruction.template.wearable.slot == ""}
                <option value="" disabled selected>Select a Slot</option>
              {/if}
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
            <h2 class="text-gray-300 font-bold">Gem Properties:</h2>
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
              >Carats (0.05-10,000)</label
            >
            <input
              bind:value={$templateUnderConstruction.template.gem.carat}
              type="text"
              pattern="^(\d+|\d+\.(\d|\d[05]))$"
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
