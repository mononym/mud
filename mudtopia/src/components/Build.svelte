<script>
  import { push } from "svelte-spa-router";
  import { AuthStore } from "../stores/auth";
  import { onMount } from "svelte";
  import { Circle2 } from "svelte-loading-spinners";
  import { scale } from "svelte/transition";
  import { cubicIn, cubicOut } from "svelte/easing";
  import MainNavBar from "../components/MainNavBar.svelte";
  import { fade } from "svelte/transition";

  let email = "";
  let menuOpen = false;

  function authenticate() {
    // authStore.initLoginWithEmail(email).then(() => push("/authenticate/token"));
  }

  function logout() {
    AuthStore.logout().then(() => push("/"));
  }

  function toggleMenu() {
    menuOpen = !menuOpen;
  }

  function clickOutside(node, { enabled: initialEnabled, cb }) {
    const handleOutsideClick = ({ target }) => {
      if (!node.contains(target)) {
        cb();
      }
    };

    function update({ enabled }) {
      if (enabled) {
        window.addEventListener("click", handleOutsideClick);
      } else {
        window.removeEventListener("click", handleOutsideClick);
      }
    }

    update(initialEnabled);
    return {
      update,
      destroy() {
        window.removeEventListener("click", handleOutsideClick);
      },
    };
  }

  onMount(async () => {
    // authStore.syncPlayer();
  });
</script>

<style>
</style>

<!-- component -->
<!-- This example requires Tailwind CSS v2.0+ -->
<div>
  <MainNavBar />

  <header class="bg-white">
    <h1 class="text-3xl font-bold leading-tight text-gray-900">Build</h1>
  </header>
</div>
