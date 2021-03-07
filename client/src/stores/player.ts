import { writable } from "svelte/store";
import PlayerState from '../models/player'

export const player = writable({...PlayerState});