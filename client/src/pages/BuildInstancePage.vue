<template>
  <q-page class="build-instance-page col-grow flex">
    <build-instance />
  </q-page>
</template>

<style lang="sass">
.build-instance-page
  max-height: calc(100vh - 50px) !important
</style>

<script lang="ts">
import BuildInstance from '../components/BuildInstance.vue';

export default {
  name: 'BuildInstancePage',
  components: { BuildInstance },
};
</script>
