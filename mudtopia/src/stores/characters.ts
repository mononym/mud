import { derived, writable } from "svelte/store";
import {
  createCharacter,
  updateCharacter,
  deleteCharacter as delCharacter,
  loadCharactersForPlayer,
} from "../api/server";
import type { CharacterInterface } from "../models/character";

function createCharactersStore() {
  const loaded = writable(false);
  const loading = writable(false);
  const saving = writable(false);
  const deleting = writable(false);
  const charactersMap = writable(<Record<string, CharacterInterface>>{});
  const characters = derived(
    charactersMap,
    ($charactersMap) => <CharacterInterface[]>Object.values($charactersMap)
  );

  async function load(playerId: string) {
    loading.set(true);
    try {
      let res = (await loadCharactersForPlayer(playerId)).data;

      const newCharactersMap = {};
      for (var i = 0; i < res.length; i++) {
        newCharactersMap[res[i].id] = res[i];
      }

      charactersMap.set(newCharactersMap);

      loaded.set(true);
    } catch (e) {
      alert(e.message);
    } finally {
      loading.set(false);
    }
  }

  async function putCharacters(characters: CharacterInterface[]) {
    const newCharactersCharacter = {};
    for (var i = 0; i < characters.length; i++) {
      newCharactersCharacter[characters[i].id] = characters[i];
    }

    charactersMap.set(newCharactersCharacter);
  }

  async function deleteCharacter(character: CharacterInterface) {
    deleting.set(true);

    try {
      await delCharacter(character.id);

      charactersMap.update(function (mm) {
        delete mm[character.id];
        return mm;
      });
    } catch (e) {
      alert(e.message);
    } finally {
      deleting.set(false);
    }
  }

  async function saveCharacter(character: CharacterInterface) {
    saving.set(true);
    let oldData;
    const isNew = character.id == "";

    try {
      if (!isNew) {
        oldData = charactersMap[character.id];
        charactersMap[character.id] = character;
      }

      let res: CharacterInterface;

      if (isNew) {
        res = (await createCharacter(character)).data;
      } else {
        res = (await updateCharacter(character)).data;
      }

      charactersMap.update(function (mm) {
        mm[res.id] = res;
        return mm;
      });

      return res;
    } catch (e) {
      if (!isNew) {
        charactersMap[character.id] = oldData;
      }
      alert(e.message);
    } finally {
      saving.set(false);
    }
  }

  return {
    putCharacters,
    load,
    loaded,
    loading,
    saving,
    deleting,
    characters,
    charactersMap,
    saveCharacter,
    deleteCharacter,
  };
}

export const CharactersStore = createCharactersStore();
