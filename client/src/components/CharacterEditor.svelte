<script>
  import { Circle2 } from "svelte-loading-spinners";
  import CharacterState from "../models/character";
  import { races } from "../stores/characterRaces";
  import { player } from "../stores/player";
  import { CharactersStore } from "../stores/characters";
  import { loadCharacterCreationData } from "../api/server";
  import { push } from "svelte-spa-router";

  import { onMount } from "svelte";

  let characterUnderConstruction = { ...CharacterState };
  let loading = true;

  $: selectedRace = $races[index];

  $: viableHairStyles =
    selectedRace == undefined
      ? []
      : selectedRace.hairStyles
          .filter((style) =>
            style.lengths.includes(characterUnderConstruction.hairLength)
          )
          .map((style) => style.style);

  $: hairStylesDisabled = viableHairStyles.length == 0;

  $: saveButtonDisabled =
    characterUnderConstruction.name == "" ||
    (characterUnderConstruction.style == "" && viableHairStyles.length > 0);

  async function save() {
    if (!saveButtonDisabled) {
      await CharactersStore.save(characterUnderConstruction);
      push("#/dashboard");
    }
    // saveArea($areaUnderConstruction);
  }

  function cancel() {
    //   WorldBuilderStore.cancelEditArea();
  }

  onMount(async () => {
    // load character creation data
    // prepopulate some of the character data with random values from the loaded creation data
    const res = await loadCharacterCreationData($player.id);

    races.set(res.data);
    loading = false;
  });

  // $: saveButtonDisabled =
  //   $areaUnderConstruction.name == "" ||
  //   $areaUnderConstruction.description == "";

  // Stuff for managing the character race portion of the editor

  let index = 0;

  const next = () => {
    index = (index + 1) % $races.length;
  };

  const previous = () => {
    const maybeNewIndex = index - 1;

    index = maybeNewIndex >= 0 ? maybeNewIndex : $races.length - 1;
  };

  function randomValue(arr) {
    return arr[randomNumber(arr.length - 1)];
  }

  function randomNumber(mult) {
    return Math.ceil(Math.random() * mult);
  }

  function chooseRace() {
    characterUnderConstruction.eyeColor = randomValue($races[index].eyeColors);
    characterUnderConstruction.eyeAccentColor = randomValue(
      $races[index].eyeColors
    );
    characterUnderConstruction.hairColor = randomValue(
      $races[index].hairColors
    );
    characterUnderConstruction.hairLength = randomValue(
      $races[index].hairLengths
    );

    if (viableHairStyles.length > 0) {
      characterUnderConstruction.style = randomValue(viableHairStyles);
    }

    characterUnderConstruction.skinTone = randomValue($races[index].skinTones);
    characterUnderConstruction.height = randomValue($races[index].heights);

    characterUnderConstruction.age = Math.max(
      randomNumber($races[index].ageMax),
      $races[index].ageMin
    );

    characterUnderConstruction.race = $races[index].singular;
  }
</script>

{#if loading}
  <div class="flex-1 flex flex-col justify-center items-center">
    <Circle2 />
    <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
      Loading Character Creation Data
    </h2>
  </div>
{:else if characterUnderConstruction.race == ""}
  <div class="h-full flex flex-col justify-center text-white space-y-4">
    <div class="flex flex-col place-content-center">
      <p class="text-center">Pick a race</p>
      <div class="flex flex-col place-content-center content-center space-y-4">
        {#each [$races[index]] as race (index)}
          <div class="flex place-content-center space-x-4">
            <div class="flex-shrink flex flex-col place-content-center">
              <i on:click={previous} class="fas fa-arrow-from-right text-6xl" />
            </div>
            <img
              src={race.portrait}
              alt={race.singular}
              style="height:200px;width:200px;object-fit:cover"
            />
            <div class="flex-shrink flex flex-col place-content-center">
              <i
                on:click={next}
                class="fas fa-arrow-from-left text-6xl align-middle"
              />
            </div>
          </div>
          <div
            class="flex flex-col place-content-center content-center text-center"
          >
            <p>{race.singular}</p>
            <p>{race.description}</p>
          </div>
        {/each}
      </div>

      <div class="flex justify-center">
        <button
          on:click={chooseRace}
          type="button"
          class="inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-blue-600 text-base font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:ml-3 sm:w-auto sm:text-sm"
          >Continue
        </button>
      </div>
    </div>
  </div>
{:else}
  <div class="container self-center justify-self-center">
    <form
      class="h-full flex flex-col place-content-center"
      on:submit|preventDefault={save}
    >
      <div class="overflow-hidden sm:rounded-md">
        <div class="px-4 py-5 sm:p-6">
          <div class="grid grid-cols-6 gap-6">
            <div class="col-span-2">
              <label for="name" class="block text-sm font-medium text-gray-300"
                >Name</label
              >
              <input
                bind:value={characterUnderConstruction.name}
                type="text"
                name="name"
                id="name"
                class="focus mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
              />
            </div>

            <div class="col-span-2">
              <label
                for="handedness"
                class="block text-sm font-medium text-gray-300"
                >Primary Hand (Note: This has nothing to do with in-game
                abilities. It is simply configuration for which hand to use as
                the primary when interacting with the world)</label
              >

              <select
                id="handedness"
                bind:value={characterUnderConstruction.handedness}
                name="handedness"
                class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              >
                <option>right</option>
                <option>left</option>
              </select>
            </div>

            <div class="col-span-2">
              <label
                for="genderPronoun"
                class="block text-sm font-medium text-gray-300"
                >Which set of gender pronouns should be used with your character
                (i.e. her/him/they or their/his/hers)
              </label>

              <select
                id="genderPronoun"
                bind:value={characterUnderConstruction.genderPronoun}
                name="handedness"
                class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              >
                <option>neutral</option>
                <option>feminine</option>
                <option>masculine</option>
              </select>
            </div>

            <div class="col-span-1">
              <label for="age" class="block text-sm font-medium text-gray-300"
                >Character Age</label
              >
              <input
                bind:value={characterUnderConstruction.age}
                type="number"
                name="age"
                id="age"
                min={selectedRace.ageMin}
                max={selectedRace.ageMax}
                class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
              />
            </div>

            <div class="col-span-2">
              <label
                for="eyeColorType"
                class="block text-sm font-medium text-gray-300">Iris type</label
              >

              <select
                id="eyeColorType"
                bind:value={characterUnderConstruction.eyeColorType}
                name="eyeColorType"
                class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              >
                <option>solid</option>
                <option>heterochromia</option>
              </select>
            </div>

            <div class="col-span-2">
              <label
                for="eyeColor"
                class="block text-sm font-medium text-gray-300"
                >Primary iris color</label
              >

              <select
                id="eyeColor"
                bind:value={characterUnderConstruction.eyeColor}
                name="eyeColor"
                class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              >
                {#each selectedRace.eyeColors as eyeColor}
                  <option>{eyeColor}</option>
                {/each}
              </select>
            </div>

            {#if characterUnderConstruction.eyeColorType == "heterochromia"}
              <div class="col-span-2">
                <label
                  for="eyeColor"
                  class="block text-sm font-medium text-gray-300"
                  >Iris accent color</label
                >

                <select
                  id="eyeColor"
                  bind:value={characterUnderConstruction.eyeAccentColor}
                  name="eyeColor"
                  class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                >
                  {#each selectedRace.eyeColors as eyeColor}
                    <option>{eyeColor}</option>
                  {/each}
                </select>
              </div>
            {/if}

            <div class="col-span-2">
              <label
                for="hairColor"
                class="block text-sm font-medium text-gray-300"
                >Hair Color</label
              >

              <select
                id="hairColor"
                bind:value={characterUnderConstruction.hairColor}
                name="hairColor"
                class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              >
                {#each selectedRace.hairColors as hairColor}
                  <option>{hairColor}</option>
                {/each}
              </select>
            </div>

            <div class="col-span-2">
              <label
                for="hairLength"
                class="block text-sm font-medium text-gray-300"
                >Hair Length</label
              >

              <select
                id="hairLength"
                bind:value={characterUnderConstruction.hairLength}
                name="hairLength"
                class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              >
                {#each selectedRace.hairLengths as hairLength}
                  <option>{hairLength}</option>
                {/each}
              </select>
            </div>

            <div class="col-span-2">
              <label
                for="hairStyle"
                class="block text-sm font-medium text-gray-300"
                >Hair Style</label
              >

              <select
                id="hairStyle"
                disabled={hairStylesDisabled}
                bind:value={characterUnderConstruction.hairStyle}
                name="hairStyle"
                class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              >
                {#each viableHairStyles as hairStyle}
                  <option>{hairStyle}</option>
                {/each}
              </select>
            </div>

            <div class="col-span-2">
              <label
                for="skinTone"
                class="block text-sm font-medium text-gray-300">Skin Tone</label
              >

              <select
                id="skinTone"
                bind:value={characterUnderConstruction.skinTone}
                name="skinTone"
                class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              >
                {#each selectedRace.skinTones as skinTone}
                  <option>{skinTone}</option>
                {/each}
              </select>
            </div>

            <div class="col-span-2">
              <label
                for="height"
                class="block text-sm font-medium text-gray-300">Height</label
              >

              <select
                id="height"
                bind:value={characterUnderConstruction.height}
                name="height"
                class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              >
                {#each selectedRace.heights as height}
                  <option>{height}</option>
                {/each}
              </select>
            </div>

            <div class="px-4 py-3 text-right sm:px-6">
              <button
                disabled={saveButtonDisabled}
                type="submit"
                class="{saveButtonDisabled
                  ? 'bg-primary-dark text-gray-500 cursor-not-allowed'
                  : 'bg-primary hover:bg-primary-light'} inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 text-base font-medium text-black focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-dark"
              >
                Save
              </button>
              <button
                on:click|preventDefault={cancel}
                class="inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-red-600 text-base font-medium text-black hover:bg-red-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-400"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      </div>
    </form>
  </div>
{/if}
