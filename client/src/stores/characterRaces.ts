import { writable } from "svelte/store";
import type { CharacterRaceInterface } from "../models/characterRace";

export const races = writable(<CharacterRaceInterface[]>[]);
