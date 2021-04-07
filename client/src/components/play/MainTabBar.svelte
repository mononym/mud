<script>
  import { AuthStore } from "../../stores/auth";
  import { scale } from "svelte/transition";
  import { cubicIn, cubicOut } from "svelte/easing";
  import { push } from "svelte-spa-router";
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const {
    endGameSession,
    view,
    selectSettingsView,
    selectPlayView,
    setWindowVisibility,
    windowVisibility,
  } = state;

  let menuOpen = false;
  let windowDropdownMenuOpen = false;

  function logout() {
    endGameSession().then(() => AuthStore.logout().then(() => push("#/login")));
  }

  function endSession() {
    endGameSession().then(() => push("#/dashboard"));
  }

  function toggleMenu() {
    menuOpen = !menuOpen;
  }

  function openWindowMenu() {
    windowDropdownMenuOpen = true;
  }

  function toggleWindowVisibility(key) {
    setWindowVisibility($windowVisibility[key]);
  }

  function clickOutside(node, { enabled: initialEnabled, cb }) {
    const handleOutsideClick = ({ target }) => {
      if (!node.contains(target)) {
        cb();
      }
    };

    function update({ enabled }) {
      if (enabled) {
        window.addEventListener("click", handleOutsideClick);
      } else {
        window.removeEventListener("click", handleOutsideClick);
      }
    }

    update(initialEnabled);
    return {
      update,
      destroy() {
        window.removeEventListener("click", handleOutsideClick);
      },
    };
  }
</script>

<nav class="bg-gray-800 flex-shrink">
  <div class="mx-auto px-2">
    <div class="flex items-center justify-between">
      <div class="flex">
        <div class="flex items-baseline space-x-4">
          <button
            on:click={selectPlayView}
            class="px-3 py-2 text-sm font-medium focus:outline-none {$view ==
            'play'
              ? 'text-white border-primary border-b-2'
              : 'text-gray-300 hover:text-white hover:bg-gray-700'} "
            >Play</button
          >

          <button
            on:click={selectSettingsView}
            class="px-3 py-2 text-sm font-medium focus:outline-none {$view ==
            'settings'
              ? 'text-white border-primary border-b-2'
              : 'text-gray-300 hover:text-white hover:bg-gray-700'}"
            >Settings</button
          >
        </div>
      </div>
      <div class="hidden md:block">
        <div class="ml-4 flex items-center md:ml-6">
          <!-- Window dropdown -->
          <div class="ml-3 relative">
            <div>
              <button
                use:clickOutside={{
                  enabled: true,
                  cb: () =>
                    windowDropdownMenuOpen
                      ? (windowDropdownMenuOpen = false)
                      : (windowDropdownMenuOpen = windowDropdownMenuOpen),
                }}
                on:click={openWindowMenu}
                class="max-w-xs bg-gray-800 flex items-center text-sm focus:outline-none"
                id="window-menu"
                aria-haspopup="true"
              >
                <span class="sr-only">Open Window Visibility Menu</span>
                <i class="text-gray-300 fa-2x fa-fw fal fa-window" />
              </button>
            </div>
            <!--
                Profile dropdown panel, show/hide based on dropdown state.

                Entering: "transition ease-out duration-100"
                  From: "transform opacity-0 scale-95"
                  To: "transform opacity-100 scale-100"
                Leaving: "transition ease-in duration-75"
                  From: "transform opacity-100 scale-100"
                  To: "transform opacity-0 scale-95"
              -->
            <div
              in:scale={{ duration: 100, start: 0.95, easing: cubicOut }}
              out:scale={{ duration: 75, start: 0.95, easing: cubicIn }}
              class="origin-top-right absolute z-50 right-0 mt-2 w-36 rounded-md shadow-lg py-1 bg-white ring-1 ring-black ring-opacity-5 {windowDropdownMenuOpen
                ? 'visible'
                : 'invisible'}"
              role="menu"
              aria-orientation="vertical"
              aria-labelledby="window-menu"
            >
              <button
                on:click={toggleWindowVisibility("map")}
                class="block py-2 text-sm text-gray-700 hover:bg-gray-100 w-full"
                role="menuitem">Toggle Map</button
              >

              <button
                on:click={logout}
                class="block py-2 text-sm text-gray-700 hover:bg-gray-100 w-full"
                role="menuitem">Toggle Inventory</button
              >
            </div>
          </div>

          <button
            class="bg-gray-800 p-1 rounded-full text-gray-400 hover:text-white focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-800 focus:ring-white"
          >
            <span class="sr-only">View notifications</span>
            <!-- Heroicon name: bell -->
            <svg
              class="h-6 w-6"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              aria-hidden="true"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
              />
            </svg>
          </button>

          <!-- Profile dropdown -->
          <div class="ml-3 relative">
            <div>
              <button
                use:clickOutside={{
                  enabled: true,
                  cb: () =>
                    menuOpen ? (menuOpen = false) : (menuOpen = menuOpen),
                }}
                on:click={toggleMenu}
                class="max-w-xs bg-gray-800 rounded-full flex items-center text-sm focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-800 focus:ring-white"
                id="user-menu"
                aria-haspopup="true"
              >
                <span class="sr-only">Open character menu</span>
                <img
                  class="h-8 w-8 rounded-full"
                  src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
                  alt=""
                />
              </button>
            </div>
            <!--
                Profile dropdown panel, show/hide based on dropdown state.

                Entering: "transition ease-out duration-100"
                  From: "transform opacity-0 scale-95"
                  To: "transform opacity-100 scale-100"
                Leaving: "transition ease-in duration-75"
                  From: "transform opacity-100 scale-100"
                  To: "transform opacity-0 scale-95"
              -->
            <div
              in:scale={{ duration: 100, start: 0.95, easing: cubicOut }}
              out:scale={{ duration: 75, start: 0.95, easing: cubicIn }}
              class="origin-top-right absolute z-50 right-0 mt-2 w-36 rounded-md shadow-lg py-1 bg-white ring-1 ring-black ring-opacity-5 {menuOpen
                ? 'visible'
                : 'invisible'}"
              role="menu"
              aria-orientation="vertical"
              aria-labelledby="user-menu"
            >
              <button
                on:click={endSession}
                class="block py-2 text-sm text-gray-700 hover:bg-gray-100 w-full"
                role="menuitem">End session</button
              >

              <button
                on:click={logout}
                class="block py-2 text-sm text-gray-700 hover:bg-gray-100 w-full"
                role="menuitem">Sign out</button
              >
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</nav>
