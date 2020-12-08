<script>
  import { metatags, url } from "@roxi/routify";
  metatags.title = "My Routify app";
  metatags.description = "Description coming soon...";
  import { AuthStore } from "../stores/auth";
  const { authenticated } = AuthStore;
  // $redirect("/login");

  // $: $authenticated ? $goto("/auth/dashboard") : $goto("/unauth/login");
</script>

<a href={$authenticated ? $url('/auth/dashboard') : $url('/unauth/login')}>Go
  here</a>
