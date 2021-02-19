// Components
import Home from "./routes/Home.svelte";
import Dashboard from "./routes/Dashboard.svelte";
import Login from "./routes/Login.svelte";
import ValidateLoginToken from "./routes/ValidateLoginToken.svelte";
import CharacterCreation from "./routes/CharacterCreation.svelte";
import Build from "./routes/Build.svelte";
import Play from "./routes/Play.svelte";
import NotFound from "./routes/NotFound.svelte";

// Export the route definition object
export default {
  // Landing page which immediately redirects to either /dashboard or /login
  "/": Home,

  // The landing page for a logged in account
  "/dashboard": Dashboard,

  // Auth stuff
  "/login": Login,
  "/token": ValidateLoginToken,

  // Building stuff
  "/build/world": Build,

  // Character creation stuff
  "/character/create": CharacterCreation,

  // Play Game stuff
  "/play/:characterId": Play,

  // Wildcard parameter
  // Included twice to match both `/wild` (and nothing after) and `/wild/*` (with anything after)
  //   "/wild": Wild,
  //   "/wild/*": Wild,

  // Catch-all, must be last
  "*": NotFound,
};
