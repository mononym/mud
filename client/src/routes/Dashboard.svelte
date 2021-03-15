<script language="typescript">
  import Confirm from "../components/Confirm.svelte";
  import { Circle2 } from "svelte-loading-spinners";
  import { player } from "../stores/player";
  import { CharactersStore } from "../stores/characters";
  import { push } from "svelte-spa-router";
  import MainNavBar from "../components/MainNavBar.svelte";
  const { loading, characters } = CharactersStore;
  let showDeletePrompt = false;
  let characterForDeleting;
  let deleteMatchString = "";

  import { onMount } from "svelte";

  function playCharacter(character) {
    push(`#/play/${character.id}`);
  }

  function createCharacter() {
    push("#/character/create");
  }

  function deleteCallback() {
    CharactersStore.deleteCharacter(characterForDeleting);
  }

  function promptForDeleteCharacter(character) {
    deleteMatchString = character.name;
    characterForDeleting = character;
    showDeletePrompt = true;
  }

  onMount(async () => {
    CharactersStore.load($player.id);
  });
</script>

<div class="h-full w-full flex flex-col overflow-hidden">
  <MainNavBar />
  {#if $loading}
    <div class="flex-1 flex flex-col justify-center items-center">
      <Circle2 />
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
        Loading Characters
      </h2>
    </div>
  {:else if $characters.length == 0}
    <div class="flex-1 w-full flex justify-center">
      <div class="h-full flex flex-col justify-center">
        <button
          on:click={createCharacter}
          type="button"
          class="rounded-md border border-transparent shadow-sm px-4 py-2 bg-blue-600 text-base font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:ml-3 sm:w-auto sm:text-sm"
          >Create your first character!
        </button>
      </div>
    </div>
  {:else}
    <div class="w-full h-full flex flex-row justify-center">
      {#each $characters as character}
        <!-- <div class="flex-shrink flex flex-col justify-center"> -->
        <!-- card -->
        <div class="flex flex-col justify-center">
          <img
            src="https://d148p4q18vviek.cloudfront.net/{character.race}.jpg"
            alt={character.name}
            style="height:200px;width:200px;object-fit:cover"
          />
          <p class="text-center text-white">{character.name}</p>

          <button
            on:click={playCharacter(character)}
            type="button"
            class="rounded-md border border-transparent shadow-sm px-4 py-2 bg-blue-600 text-base font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:ml-3 sm:w-auto sm:text-sm"
            >Play
          </button>
          <button
            on:click|stopPropagation={promptForDeleteCharacter(character)}
            class="rounded-md border border-transparent shadow-sm px-4 py-2 bg-red-600 text-base font-medium text-white hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:ml-3 sm:w-auto sm:text-sm"
            type="button"
          >
            <i class="fas fa-trash" />
          </button>
        </div>
        <!-- </div> -->
      {/each}
    </div>
  {/if}

  <Confirm
    bind:show={showDeletePrompt}
    callback={deleteCallback}
    matchString={deleteMatchString}
  />
</div>
