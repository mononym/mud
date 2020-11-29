<script lang="ts">
  import Router from "svelte-spa-router";
  import routes from "./routes";
  import Tailwindcss from "./Tailwind.svelte";
</script>

<main class="w-screen h-screen bg-gray-900">
  <Router {routes} />
  <Tailwindcss />
</main>
