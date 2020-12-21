<script language="typescript">
  import { params } from "@roxi/routify";
  import { Circle2 } from "svelte-loading-spinners";
  import { player } from "../../../stores/player";
  import { CharactersStore } from "../../../stores/characters";
  const { characters } = CharactersStore;
  import { MudClientStore } from "../../../stores/mudClient";
  const {
    characterInitialized,
    characterInitializing,
    selectedCharacter,
  } = MudClientStore;

  import { onMount } from "svelte";

  onMount(async () => {
    const character = $characters.filter(
      (character) => character.id == $params.id
    )[0];

    MudClientStore.initializeCharacter(character);
  });
</script>

<div class="h-full w-full flex flex-col overflow-hidden justify-center">
  {#if !$characterInitialized || $characterInitializing}
    <div class="flex-1 flex flex-col justify-center items-center">
      <Circle2 />
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
        Initializing
        {$selectedCharacter.name == '' ? 'Character' : $selectedCharacter.name}
      </h2>
    </div>
  {:else if $characterInitialized}
    <p>Now the fun begins: {$selectedCharacter.name}!</p>
  {/if}
</div>
