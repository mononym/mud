import { get, derived, writable } from "svelte/store";

const musicThemes = {
  celtic: [
    "media/music/themes/celtic/1 Lands of Magic by Ean Grimm.mp3",
    "media/music/themes/celtic/2 Warriors of Avalon by Ean Grimm.mp3",
    "media/music/themes/celtic/3 Stone Magic by Ean Grimm.mp3",
    "media/music/themes/celtic/4 The Watcher by Ean Grimm.mp3",
    "media/music/themes/celtic/1_Celtic Wisdom Forest - Ean Grimm.mp3",
    "media/music/themes/celtic/2_Celtic Raven Legend - Ean Grimm.mp3",
    "media/music/themes/celtic/3_Celtic Elf Ocean - Ean Grimm.mp3",
    "media/music/themes/celtic/4_Celtic River Elfs - Ean Grimm.mp3",
    "media/music/themes/celtic/5_Celtic Freedom Fighters - Ean Grimm.mp3",
    "media/music/themes/celtic/6_Celtic Druid Castle - Ean Grimm.mp3",
    "media/music/themes/celtic/7_Celtic Fairy Prophecy - Ean Grimm.mp3",
    "media/music/themes/celtic/8_Celtic Nightship - Ean Grimm.mp3",
    "media/music/themes/celtic/9_Celtic Eagle Mountain - Ean Grimm.mp3",
    "media/music/themes/celtic/10_Celtic Elf Wedding - Ean Grimm.mp3",
  ],
  viking: [
    "media/music/themes/viking/1_Viking Trolls - Ean Grimm.mp3",
    "media/music/themes/viking/2_Viking Hill Legend - Ean Grimm.mp3",
    "media/music/themes/viking/3_Viking Raid Raven - Ean Grimm.mp3",
    "media/music/themes/viking/4_Viking Wolf Howls - Ean Grimm.mp3",
    "media/music/themes/viking/5_Viking Ship Melodies - Ean Grimm.mp3",
    "media/music/themes/viking/6_Viking Moon Melody - Ean Grimm.mp3",
    "media/music/themes/viking/7_Viking God Wisdom - Ean Grimm.mp3",
    "media/music/themes/viking/8_Viking Life Lesson - Ean Grimm.mp3",
    "media/music/themes/viking/9_Viking Axe Anger - Ean Grimm.mp3",
    "media/music/themes/viking/10_Viking Shield Maiden - Ean Grimm.mp3",
    "media/music/themes/viking/11_Viking World Waters - Ean Grimm.mp3",
  ],
  tavern: [
    "media/music/themes/tavern/1_Black Moon Tavern by Ean Grimm.mp3",
    "media/music/themes/tavern/2_The Ranger's Tavern by Ean Grimm.mp3",
    "media/music/themes/tavern/3_Old King Tavern by Ean Grimm.mp3",
    "media/music/themes/tavern/4_Night Owl Tavern by Ean Grimm.mp3",
    "media/music/themes/tavern/5_Dark Woods Tavern by Ean Grimm.mp3",
  ],
};

function getRandomInt(max) {
  return Math.floor(Math.random() * max);
}

function createAudioStore() {
  const theme = writable("celtic");
  const songIndex = writable(0);
  const playMusic = writable(true);
  const playAmbiance = writable(true);
  const playSoundEffects = writable(true);
  const musicVolume = writable(0.5);
  const ambientVolume = writable(0.6);
  const soundEffectsVolume = writable(0.7);
  const songSource = derived(
    [theme, songIndex],
    function ([$theme, $songIndex]) {
      return musicThemes[$theme][$songIndex];
    }
  );

  async function changeMusicTheme(newTheme) {
    if (get(theme) != newTheme) {
      theme.set(newTheme);
      randomizeSong();
    }
  }

  async function randomizeSong() {
    songIndex.set(getRandomInt(musicThemes[get(theme)].length - 1));
  }

  async function handleSongEnd() {
    console.log("handleSongEnd");
    if (get(songIndex) + 1 == musicThemes[get(theme)].length) {
      songIndex.set(0);
    } else {
      songIndex.set(get(songIndex) + 1);
    }
  }

  async function updateMusicVolume(newVolume) {
    musicVolume.set(newVolume);
  }

  async function updateStoreWithCharacterSettings(newCharacterAudioSettings) {
    const rawMusicVolume = parseFloat(newCharacterAudioSettings.music_volume);
    const modifiedMusicVolume = parseFloat((rawMusicVolume / 100).toFixed(2));
    musicVolume.set(modifiedMusicVolume);

    const rawAmbientVolume = parseFloat(
      newCharacterAudioSettings.ambient_volume
    );
    const modifiedAmbientVolume = parseFloat(
      (rawAmbientVolume / 100).toFixed(2)
    );
    ambientVolume.set(modifiedAmbientVolume);

    const rawSEVolume = parseFloat(
      newCharacterAudioSettings.sound_effect_volume
    );
    const modifiedSEVolume = parseFloat((rawSEVolume / 100).toFixed(2));
    soundEffectsVolume.set(modifiedSEVolume);

    playMusic.set(newCharacterAudioSettings.play_music);
    playAmbiance.set(newCharacterAudioSettings.play_ambiance);
    playSoundEffects.set(newCharacterAudioSettings.play_sound_effects);
  }

  return {
    handleSongEnd,
    changeMusicTheme,
    randomizeSong,
    updateMusicVolume,
    updateStoreWithCharacterSettings,
    musicVolume,
    ambientVolume,
    soundEffectsVolume,
    songSource,
    playMusic,
    playAmbiance,
    playSoundEffects,
  };
}

export const AudioStore = createAudioStore();
