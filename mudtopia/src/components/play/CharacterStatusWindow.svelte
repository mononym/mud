<script>
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const { selectedCharacter } = state;
</script>

<div
  style="background-color:#28282D"
  class="CharacterStatusWindow h-full w-full flex flex-col place-content-center items-center p-2"
>
  <img
    src="positions/{$selectedCharacter.status.position}.svg"
    alt={$selectedCharacter.status.position}
  />
</div>
