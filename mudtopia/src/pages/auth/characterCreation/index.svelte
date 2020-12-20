<script language="typescript">
  import { Circle2 } from "svelte-loading-spinners";
  import { player } from "../../../stores/player";
  import { CharactersStore } from "../../../stores/characters";
  const { loading, characters } = CharactersStore;
  import CharacterEditor from "./_components/CharacterEditor";

  import { onMount } from "svelte";
  import { goto } from "@roxi/routify";

  // onMount(async () => {
  //   CharactersStore.load($player.id);
  // });
</script>

<div class="h-full w-full flex flex-col overflow-hidden justify-center">
  <CharacterEditor />
</div>
