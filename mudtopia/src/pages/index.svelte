<script>
  import RoutifyIntro from "./example/_components/RoutifyIntro.svelte";
  import { metatags } from "@roxi/routify";
  metatags.title = "My Routify app";
  metatags.description = "Description coming soon...";
  import { redirect } from "@roxi/routify";
  import { AuthStore } from "../stores/auth";
  const { authenticated } = AuthStore;
  // $redirect("/login");

  console.log(authenticated);
  console.log($authenticated);
  $: $authenticated ? $redirect("/dashboard") : $redirect("/login");
  // $: if ($authenticated) {
  //   $redirect("/dashboard");
  // }
</script>

<!-- <RoutifyIntro /> -->
