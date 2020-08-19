<template>
  <div id="q-app">
    <router-view />
  </div>
</template>
<script lang="ts">
import { defineComponent } from '@vue/composition-api';

export default defineComponent({
  name: 'App',
  preFetch({ store }) {
    console.log('prefetch');
    store.dispatch('csrf/fetchCsrfToken').then(() => {
      return new Promise((resolve) => {
        resolve(store.dispatch('auth/syncStatus'))
      });
    });
  }
});
</script>
