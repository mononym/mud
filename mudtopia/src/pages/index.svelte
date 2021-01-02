<script>
  import { metatags, url, goto } from "@roxi/routify";
  metatags.title = "My Routify app";
  metatags.description = "Description coming soon...";
  import { onMount } from "svelte";
  import { AuthStore } from "../stores/auth";
  const { authenticated } = AuthStore;

  onMount(() => {
    console.log($url("/auth/dashboard"));
    console.log($url("/unauth/login"));

    $authenticated ? $goto("/auth/dashboard") : $goto("/unauth/login");
  });
</script>
