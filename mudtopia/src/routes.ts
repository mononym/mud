import Home from './routes/Home.svelte';
import TokenAuthentication from './routes/TokenAuthentication.svelte';
import NotFound from './routes/NotFound.svelte';
import Dashboard from './routes/Dashboard.svelte';
import {wrap} from 'svelte-spa-router/wrap'
import type {RouteDefinition} from 'svelte-spa-router'
import {AuthStore} from './stores/auth'

export default <RouteDefinition>{
    '/': Home,
    // '/lucky': wrap({
    //     // The Svelte component used by the route
    //     component: Home,

    //     // List of route pre-conditions
    //     conditions: [
    //         // Must not be authenticated
    //         () => {
    //             // Pre-condition succeeds only 50% of times
    //             return authStore.subscribe(value => {
    //                 count_value = value;
    //             });
    //         },
    //     ]
    // }),
    '/authenticate/token': TokenAuthentication,
    '/dashboard': Dashboard,
    // The catch-all route must always be last
    '*': NotFound
};