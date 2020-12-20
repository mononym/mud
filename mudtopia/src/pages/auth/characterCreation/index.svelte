<script language="typescript">
  import { CharactersStore } from "../../../stores/characters";
  const { loading, characters } = CharactersStore;
  import CharacterEditor from "./_components/CharacterEditor.svelte";

  import { onMount } from "svelte";
  import { goto } from "@roxi/routify";

  onMount(async () => {
    console.log("hello");
  });
</script>

<div class="flex-1 flex flex-col overflow-hidden justify-center">
  <CharacterEditor />
</div>
