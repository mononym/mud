<script>
  import { getContext, onMount } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const { AudioStore, selectedCharacter } = state;

  const {
    musicVolume,
    playMusic,
    songSource,
    randomizeSong,
    handleSongEnd,
  } = AudioStore;

  $: $songSource, handleSongSourceChange();
  $: $musicVolume, handleMusicVolumeChange();
  $: $playMusic, handlePlayMusicChange();

  async function handlePlayMusicChange() {
    if (player == undefined) {
      return;
    }
    console.log("handlePlayMusicChange");
    console.log($playMusic);
    console.log(player);

    if ($playMusic) {
      player.play();
    } else {
      player.pause();
    }
  }

  async function handleMusicVolumeChange() {
    console.log("handleMusicVolumeChange");
    if (player != undefined) {
      player.volume = $musicVolume;
    }
  }

  async function handleSongSourceChange() {
    console.log("handleSongSourceChange");
    if (player != undefined) {
      player.load();

      if ($playMusic) {
        player.play();
      }
    }
  }

  let player;

  onMount(() => {
    $playMusic = $selectedCharacter.settings.audio.play_music;
    console.log($musicVolume);
    player.volume = $musicVolume;
    randomizeSong();
  });
</script>

<!-- <div
  style="background-color:#28282D"
  class="CharacterStatusWindow h-full w-full flex flex-col place-content-center items-center p-2"
> -->
<!-- svelte-ignore a11y-media-has-caption -->
<audio bind:this={player} on:ended={handleSongEnd}>
  <source src={$songSource} type="audio/mp3" />
  Your browser does not support the audio element.
</audio>
<!-- </div> -->
