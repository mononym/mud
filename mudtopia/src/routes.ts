import Home from './routes/Home.svelte';
import TokenAuthentication from './routes/TokenAuthentication.svelte';
import NotFound from './routes/NotFound.svelte';

import type {RouteDefinition} from 'svelte-spa-router'

export default <RouteDefinition>{
    '/': Home,
    '/authenticate/token': TokenAuthentication,
    // The catch-all route must always be last
    '*': NotFound
};