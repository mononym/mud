import Home from './routes/Home.svelte';
import TokenAuthentication from './routes/TokenAuthentication.svelte';
import NotFound from './routes/NotFound.svelte';
import Dashboard from './routes/Dashboard.svelte';
import {wrap} from 'svelte-spa-router/wrap'
import type {RouteDefinition} from 'svelte-spa-router'
import {authenticated} from './stores/auth'
import {replace} from 'svelte-spa-router'

export default <RouteDefinition>{
    // '/': Home,
    '/': wrap({
        // The Svelte component used by the route
        component: Home,

        // List of route pre-conditions
        conditions: [
            () => {
                // Must not be authenticated
                if (authenticated) {
                    // Replace with desired route
                    replace('/dashboard')
                }
                // Expects a boolean return value
                return !authenticated
            },
        ]
    }),
    '/authenticate/token': TokenAuthentication,
    '/dashboard': Dashboard,
    // The catch-all route must always be last
    '*': NotFound
};