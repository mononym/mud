<script>
  import { metatags, url, goto } from "@roxi/routify";
  metatags.title = "My Routify app";
  metatags.description = "Description coming soon...";
  import { onMount } from "svelte";
  import { AuthStore } from "../stores/auth";
  const { authenticated } = AuthStore;

  onMount(() => {
    $authenticated ? $goto("/auth/dashboard") : $goto("/unauth/login");
  });
</script>
