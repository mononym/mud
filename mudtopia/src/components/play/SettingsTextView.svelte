<script>
  import { State } from "./state";
  const { selectedCharacter } = State;
</script>

<div class="container grid grid-cols-8 gap-4">
  <div class="col-span-2">
    <label
      for="color"
      style="color:{$selectedCharacter.settings.area_name_text_color}"
      class="block text-sm font-medium">[Area Name Text Color]</label>
    <input
      bind:value={$selectedCharacter.settings.area_name_text_color}
      type="color"
      name="color"
      id="color"
      class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
  </div>
  <div class="col-span-2">
    <label
      for="color"
      style="color:{$selectedCharacter.settings.area_description_text_color}"
      class="block text-sm font-medium">Area Description Text Color</label>
    <input
      bind:value={$selectedCharacter.settings.area_description_text_color}
      type="color"
      name="color"
      id="color"
      class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
  </div>
  <div class="col-span-2">
    <label
      for="color"
      style="color:{$selectedCharacter.settings.system_warning_text_color}"
      class="block text-sm font-medium">***** System Warning Text Color *****</label>
    <input
      bind:value={$selectedCharacter.settings.system_warning_text_color}
      type="color"
      name="color"
      id="color"
      class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
  </div>
  <div class="col-span-2">
    <label
      for="color"
      style="color:{$selectedCharacter.settings.system_alert_text_color}"
      class="block text-sm font-medium">***** System Alert Text Color *****</label>
    <input
      bind:value={$selectedCharacter.settings.system_alert_text_color}
      type="color"
      name="color"
      id="color"
      class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
  </div>
  <div class="col-span-2">
    <label
      for="color"
      style="color:{$selectedCharacter.settings.character_text_color}"
      class="block text-sm font-medium">Character Text Color</label>
    <input
      bind:value={$selectedCharacter.settings.character_text_color}
      type="color"
      name="color"
      id="color"
      class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
  </div>
  <div class="col-span-2">
    <label
      for="color"
      style="color:{$selectedCharacter.settings.furniture_text_color}"
      class="block text-sm font-medium">Furniture Text Color</label>
    <input
      bind:value={$selectedCharacter.settings.furniture_text_color}
      type="color"
      name="color"
      id="color"
      class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
  </div>
  <div class="col-span-2">
    <label
      for="color"
      style="color:{$selectedCharacter.settings.exit_text_color}"
      class="block text-sm font-medium">Exit Text Color</label>
    <input
      bind:value={$selectedCharacter.settings.exit_text_color}
      type="color"
      name="color"
      id="color"
      class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
  </div>
  <div class="col-span-2">
    <label
      for="color"
      style="color:{$selectedCharacter.settings.denizen_text_color}"
      class="block text-sm font-medium">Denizen Text Color</label>
    <input
      bind:value={$selectedCharacter.settings.denizen_text_color}
      type="color"
      name="color"
      id="color"
      class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
  </div>
</div>
