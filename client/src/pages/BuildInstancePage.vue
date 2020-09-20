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
  data() {
    return {
      scripts: [],
      splitterModel: 150,
      tab: 'world',
      regions: [
        {
          name: 'Placeholder',
          description: 'The initial region to build stuff in',
          slug: 'placeholder'
        }
      ]
    };
  },
  computed: {
    editLink: function(): string {
      let instanceId: string = this.$route.params.instance;
      return instanceId + '/region/placeholder/edit';
    },
    buildLink: function(): string {
      let instanceId: string = this.$route.params.instance;
      return instanceId + '/region/placeholder/build';
    }
  }
};
</script>
