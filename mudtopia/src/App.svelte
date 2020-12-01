<script lang="ts">
  import Router from "svelte-spa-router";
  import routes from "./routes";
  import Tailwindcss from "./Tailwind.svelte";
  import { onMount } from "svelte";
  import { AuthStore } from "./stores/auth";
  import { Circle2 } from "svelte-loading-spinners";

  let syncing = true;

  onMount(async () => {
    AuthStore.syncPlayer().then(() => (syncing = false));
  });
</script>

<main class="w-screen h-screen bg-gray-900">
  {#if syncing}
    <div
      class="min-h-screen flex flex-col items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <Circle2 />
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
        Syncing session with server
      </h2>
    </div>
  {:else}
    <Router {routes} />
  {/if}

  <Tailwindcss />
</main>
