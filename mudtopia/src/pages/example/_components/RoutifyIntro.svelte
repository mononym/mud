<script>
  import { url } from "@roxi/routify";
  import { Circle2 } from "svelte-loading-spinners";
</script>

<div
  class="min-h-screen flex flex-col items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
  <Circle2 />
  <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
    Routify Starter!
  </h2>
  <p class="text-gray-200">To see an example app, go to <a class="text-blue-400" href={$url('/login')}>/example</a></p>
  <p class="text-gray-200">
    To delete the example app, simply delete the <span class="text-green-400">./src/pages/example</span> folder.
  </p>
</div>
