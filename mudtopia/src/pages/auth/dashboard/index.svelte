<script language="typescript">
  import { Circle2 } from "svelte-loading-spinners";
  import { player } from "../../../stores/player";
  import { CharactersStore } from "../../../stores/characters";
  const { loading, characters } = CharactersStore;

  import { onMount } from "svelte";
  import { goto } from "@roxi/routify";

  function playCharacter(character) {
    $goto(`/auth/play/${character.id}`);
  }

  onMount(async () => {
    CharactersStore.load($player.id);
  });
</script>

<div class="h-full w-full flex flex-col overflow-hidden justify-center">
  {#if $loading}
    <div class="flex-1 flex flex-col justify-center items-center">
      <Circle2 />
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
        Loading Characters
      </h2>
    </div>
  {:else if $characters.length == 0}
    <button
      on:click={$goto('../characterCreation')}
      type="button"
      class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-blue-600 text-base font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:ml-3 sm:w-auto sm:text-sm">Create
      your first character!
    </button>
  {:else}
    <div class="w-full h-full flex flex-col justify-center">
      {#each $characters as character}
        <!-- <div class="flex-shrink flex flex-col justify-center"> -->
        <!-- card -->
        <div class="flex flex-col items-center">
          <img
            src="https://d148p4q18vviek.cloudfront.net/{character.race}.jpg"
            alt={character.name}
            style="height:200px;width:200px;object-fit:cover" />
          <p class="text-center text-white">{character.name}</p>

          <button
            on:click={playCharacter(character)}
            type="button"
            class="rounded-md border border-transparent shadow-sm px-4 py-2 bg-blue-600 text-base font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:ml-3 sm:w-auto sm:text-sm">Play
          </button>
        </div>
        <!-- </div> -->
      {/each}
    </div>
  {/if}
</div>
