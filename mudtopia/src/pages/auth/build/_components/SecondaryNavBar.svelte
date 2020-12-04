<script>
  import { isActive, url } from "@roxi/routify";
</script>

<nav class="bg-gray-700 flex-shrink">
  <div class="mx-auto px-4">
    <div class="flex items-center justify-between h-16">
      <div class="flex">
        <div class="flex items-baseline space-x-4">
          <a
            href={$url('/auth/build/world')}
            class="px-3 py-2 rounded-md text-sm font-medium {$isActive('/auth/build/world') ? 'text-white bg-gray-900' : 'text-gray-300 hover:text-white hover:bg-gray-700'}">World</a>

          <a
            href={$url('/auth/build/races')}
            class="px-3 py-2 rounded-md text-sm font-medium {$isActive('/auth/build/races') ? 'text-white bg-gray-900' : 'text-gray-300 hover:text-white hover:bg-gray-700'}">Races</a>
        </div>
      </div>
    </div>
  </div>
</nav>
