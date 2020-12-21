import { derived, writable } from "svelte/store";
import {} from "../api/server";
import type { CharacterInterface } from "../models/character";
import CharacterState from "../models/character";

function createMudClientStore() {
  //
  // Character Stuff
  //

  const characterInitialized = writable(false);
  const characterInitializing = writable(false);
  const selectedCharacter = writable({ ...CharacterState });

  async function initializeCharacter(character: CharacterInterface) {
    selectedCharacter.set(character);
    characterInitialized.set(true);
    characterInitializing.set(false);
  }

  return {
    //
    // Character Stuff
    //
    characterInitialized,
    characterInitializing,
    selectedCharacter,
    initializeCharacter,
  };
}

export const MudClientStore = createMudClientStore();
