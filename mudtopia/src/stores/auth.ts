import { writable } from "svelte/store";
import {
  logoutPlayer,
  submitEmailForAuth,
  submitTokenForAuth,
  syncPlayer
} from "../api/server";
import {player} from './player'
import PlayerState from './../models/player'

function createAuthStore() {
  const authenticated = writable(false);
  const isAuthenticating = writable(false);
  const isSyncing = writable(false);
  const loggingOut = writable(false);

  async function sync(){
    isSyncing.set(true)
    try {
      const res = (await syncPlayer()).data;
      if (res.authenticated) {
        player.set(res.player)
      }

      authenticated.set(res.authenticated)
    } catch (e) {
      alert(e.message);
    } finally {
      isSyncing.set(false)
    }
  }
    
  async function initLoginWithEmail(email: string){
    isAuthenticating.set(true)
    try {
      await submitEmailForAuth(email);
    } catch (e) {
      alert(e.message);
    } finally {
      isAuthenticating.set(false)
    }
  }
    
  async function completeLoginWithToken(token: string){
    isAuthenticating.set(true)
    try {
      const res = await submitTokenForAuth(token);
      player.set(res.data)
      authenticated.set(true)
    } catch (e) {
      alert(e.message);
    } finally {
      isAuthenticating.set(false)
    }
  }

  async function logout(){
    console.log('logging out')
    loggingOut.set(true)
    try {
      await logoutPlayer();
      authenticated.set(false)
      player.set({...PlayerState})
    } catch (e) {
      alert(e.message);
    } finally {
      loggingOut.set(false)
    }
  }

  return {
    authenticated,
    isAuthenticating,
    isSyncing,
    loggingOut,
    sync,
    initLoginWithEmail,
    completeLoginWithToken,
    logout
    }

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
}

export const AuthStore = createAuthStore();

/* computed values */
// export const getTotalHeroes = derived(
//   heroStore,
//   $heroStore => $heroStore.heroes.length
// );