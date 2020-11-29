<script>
  import axios from "axios";

  let token = "";

  function authenticate() {
    console.log(token);
    axios
      .post("/authenticate/token", { token: token })
      .then((response) => console.log(response));
  }
</script>

<style>
</style>

<!-- component -->
<div
  class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
  <div class="max-w-md w-full space-y-8">
    <div>
      <img
        class="mx-auto h-12 w-auto"
        src="https://tailwindui.com/img/logos/workflow-mark-indigo-600.svg"
        alt="Workflow" />
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
        Enter the Token sent to the provided email
      </h2>
    </div>
    <form
      class="mt-8 space-y-6"
      action="http://localhost:4000/authenticate/email"
      method="POST">
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
          on:click={authenticate}
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
