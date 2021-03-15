<script lang="ts">
  import { onMount } from "svelte";
  import { AuthStore } from "./stores/auth";
  import { Circle2 } from "svelte-loading-spinners";
  import Router from "svelte-spa-router";
  import routes from "./routes";
  import Tailwindcss from "./Tailwind.svelte";
  const { authenticated, isSyncing } = AuthStore;
  import { push } from "svelte-spa-router";
  import "smelte/src/tailwind.css";
  import { Notifications } from "smelte";

  onMount(async () => {
    AuthStore.sync().then(() => {
      $authenticated ? push("#/dashboard") : push("#/login");
    });
  });
</script>

<main class="bg-gray-900 h-full w-full max-h-full max-w-full">
  <Tailwindcss />
  {#if $isSyncing}
    <div
      class="h-full flex flex-col items-center justify-center py-12 px-4 sm:px-6 lg:px-8"
    >
      <Circle2 />
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
        Syncing session with server
      </h2>
    </div>
  {:else}
    <Router {routes} />
  {/if}
  <Notifications />
</main>
