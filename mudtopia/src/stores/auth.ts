import { writable } from "svelte/store";
import {
  submitEmailForAuth,
  submitTokenForAuth,
  syncPlayer
} from "../api/server";
import PlayerState from '../models/player'

const initialState = {
  authenticated: false,
  player: {...PlayerState},
  isAuthenticating: false,
  isSyncing: false
};
function createAuthStore() {
  const { subscribe, update } = writable(initialState);

  return {
    subscribe,
    syncPlayer: async () => {
      update(state => (state = { ...state, isSyncing: true }));
      try {
        const res = (await syncPlayer()).data;
        update(state => (state = { ...state, authenticated: res.authenticated, player: res.authenticated ? res.player : state.player }));
      } catch (e) {
        alert(e.message);
      } finally {
        update(state => (state = { ...state, isSyncing: false }));
      }
    },
    initLoginWithEmail: async (email: string) => {
      update(state => (state = { ...state, isAuthenticating: true }));
      try {
        await submitEmailForAuth(email);
      } catch (e) {
        alert(e.message);
      } finally {
        update(state => (state = { ...state, isAuthenticating: false }));
      }
    },
    completeLoginWithToken: async (token: string) => {
      update(state => (state = { ...state, isAuthenticating: true }));
      try {
        const res = await submitTokenForAuth(token);
        update(state => (state = { ...state, authenticated: true, player: res.data }));
      } catch (e) {
        alert(e.message);
      } finally {
        update(state => (state = { ...state, isAuthenticating: false }));
      }
    },

//   /* Optimistic UI update. Updating the UI before sending the request to the web service */
//     removeHero: async id => {
//       const confirmation = confirm("You sure you want to delete this?");
//       if (!confirmation) return;

//       let previousHeroes;
//       update(state => {
//         previousHeroes = state.heroes;
//         const updatedHeroes = state.heroes.filter(h => h._id !== id);
//         return (state = { ...state, heroes: updatedHeroes }); // need to return the state only
//       });
//       try {
//         await deleteHero(id);
//       } catch (e) {
//         alert(e.message);
//         update(state => (state = { ...state, heroes: previousHeroes })); // rolling back. =)
//       }
//     },

  };
}

export const authStore = createAuthStore();

/* computed values */
// export const getTotalHeroes = derived(
//   heroStore,
//   $heroStore => $heroStore.heroes.length
// );