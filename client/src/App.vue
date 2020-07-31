<template>
  <div id="q-app">
    <router-view />
  </div>
</template>
<script lang="ts">
import { defineComponent } from '@vue/composition-api';

export default defineComponent({
  name: 'App',
  preFetch({ store, currentRoute }) {
    console.log('prefetch');
    store.dispatch('csrf/fetchCsrfToken').then(() => {
      void store.dispatch('auth/syncStatus');
    });
  }
});
</script>
