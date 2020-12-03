<script lang="ts">
  import Tailwindcss from "./Tailwind.svelte";
  import { onMount } from "svelte";
  import { AuthStore } from "./stores/auth";
  import { Circle2 } from "svelte-loading-spinners";
  import Router from "@roxi/routify/runtime/Router.svelte";
  import { routes } from "../.routify/routes";
  const { isSyncing } = AuthStore;

  onMount(async () => {
    AuthStore.sync();
  });
</script>

<main class="w-screen h-screen bg-gray-900">
  <Tailwindcss />
  {#if $isSyncing}
    <div
      class="min-h-screen flex flex-col items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <Circle2 />
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
        Syncing session with server
      </h2>
    </div>
  {:else}
    <Router {routes} config={{ useHash: true }} />
  {/if}
</main>
