<script>
  import { AuthStore } from "../stores/auth";
  import { push } from "svelte-spa-router";

  let token = "";

  function validate() {
    AuthStore.completeLoginWithToken(token).then(() => push("/dashboard"));
  }
</script>

<style>
</style>

<!-- component -->
<div
  class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
  <div class="max-w-md w-full space-y-8">
    <div class="flex flex-col">
      <i class="fas fa-dice-d20 text-6xl flex-shrink self-center" />
      <h2
        class="mt-6 text-center text-3xl font-extrabold text-gray-900 flex-1 self-center">
        Enter the Token sent to the provided email
      </h2>
    </div>
    <form class="mt-8 space-y-6" on:submit|preventDefault={validate}>
      <input type="hidden" name="remember" value="true" />
      <div class="rounded-md shadow-sm -space-y-px">
        <div>
          <label for="token" class="sr-only">Token</label>
          <input
            id="token"
            name="token"
            required
            class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
            placeholder="Token"
            bind:value={token} />
        </div>
      </div>

      <div>
        <button
          on:click={validate}
          type="button"
          class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
          <span class="absolute left-0 inset-y-0 flex items-center pl-3">
            <i class="fas fa-lock" />
          </span>
          Complete Sign in
        </button>
      </div>
    </form>
  </div>
</div>
