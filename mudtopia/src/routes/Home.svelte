<script>
  import { onMount } from "svelte";
  import { AuthStore } from "../stores/auth";
  import { push } from "svelte-spa-router";
  const { authenticated } = AuthStore;

  onMount(() => {
    $authenticated ? push("#/dashboard") : push("#/login");
  });
</script>
