<script lang="ts">
  import Router from "svelte-spa-router";
  import routes from "./routes";
  import Tailwindcss from "./Tailwind.svelte";
</script>

<main>
  <Router {routes} />
  <Tailwindcss />
</main>
