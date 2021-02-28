<script>
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const { selectedCharacter } = state;
</script>

<div
  style="background-color:#28282D"
  class="CharacterStatusWindow h-full w-full flex flex-col place-content-center items-center"
>
  <p class="text-center text-white">{$selectedCharacter.status.position}</p>
</div>
