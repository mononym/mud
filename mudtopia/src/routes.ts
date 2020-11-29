import Home from './routes/Home.svelte';
import TokenAuthentication from './routes/TokenAuthentication.svelte';
import NotFound from './routes/NotFound.svelte';
import Dashboard from './routes/Dashboard.svelte';
import {wrap} from 'svelte-spa-router/wrap'
import type {RouteDefinition} from 'svelte-spa-router'
import {authenticated} from './stores/auth'
import {replace} from 'svelte-spa-router'
import { get } from 'svelte/store';

export default <RouteDefinition>{
    // '/': Home,
    '/': wrap({
        // The Svelte component used by the route
        component: Home,

        // List of route pre-conditions
        conditions: [
            () => {
                console.log('authenticated')
                console.log(get(authenticated))
                // Must not be authenticated
                if (get(authenticated)) {
                    // Replace with desired route
                    replace('/dashboard')
                }
                // Expects a boolean return value
                return !get(authenticated)
            },
        ]
    }),
    '/authenticate/token': TokenAuthentication,
    '/dashboard': Dashboard,
    // The catch-all route must always be last
    '*': NotFound
};