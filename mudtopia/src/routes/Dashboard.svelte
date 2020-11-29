<script>
  import { push } from "svelte-spa-router";
  import { AuthStore } from "../stores/auth";
  import { onMount } from "svelte";
  import { Circle2 } from "svelte-loading-spinners";

  let email = "";

  function authenticate() {
    // authStore.initLoginWithEmail(email).then(() => push("/authenticate/token"));
  }

  onMount(async () => {
    // authStore.syncPlayer();
  });
</script>

<style>
</style>

<!-- component -->
<div
  class="min-h-screen flex flex-col items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
  <Circle2 />
  <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
    This is a dashboard - loading data
  </h2>
</div>
