<script>
  import { AuthStore } from "../stores/auth";
  import { push } from "svelte-spa-router";

  let email = "";

  function authenticate() {
    AuthStore.initLoginWithEmail(email).then(() => push("#/token"));
  }
</script>

<div class="h-full flex flex-col justify-center">
  <i class="fas fa-dice-d20 text-gray-500 text-4xl self-center" />
  <h2
    class="mt-6 text-center text-3xl font-extrabold text-gray-500 self-center">
    Enter your email to start the sign in process
  </h2>
  <form class="mt-8 space-y-6 self-center w-96" on:submit|preventDefault={authenticate}>
    <input type="hidden" name="remember" value="true" />
    <div class="rounded-md shadow-sm -space-y-px">
      <div>
        <label for="email" class="sr-only">Email address</label>
        <input
          id="email"
          name="email"
          type="email"
          required
          class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
          placeholder="Email address"
          bind:value={email} />
      </div>
    </div>

    <div>
      <button
        type="submit"
        class="group relative w-full flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-primary text-base font-medium text-black hover:bg-primary-light focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-dark">
        <span class="absolute left-0 inset-y-0 flex items-center pl-3">
          <i class="fas fa-lock" />
        </span>
        Start Sign in
      </button>
    </div>
  </form>
</div>
