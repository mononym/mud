<template>
  <q-page class="flex flex-center">
    <instance-creation-wizard />
  </q-page>
</template>

<style></style>

<script>
import InstanceCreationWizard from '../components/InstanceCreationWizard.vue';

export default {
  name: 'InstanceCreationPage',
  components: { InstanceCreationWizard }
};
</script>
