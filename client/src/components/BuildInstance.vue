<template>
  <div class="col flex">
    <div v-if="loadingInstance">loading</div>
    <div
      v-if="!loadingInstance"
      class="build-instance-wrapper flex row col wrap"
    >
      <q-tabs v-model="tab" vertical class="text-teal tab-controller">
        <q-tab name="world" icon="fas fa-globe" label="World" />
        <q-tab name="code" icon="fas fa-code" label="Code" />
        <q-tab name="races" icon="fas fa-users" label="Races" />
        <q-tab name="commands" icon="fas fa-terminal" label="Commands" />
        <q-tab name="templates" icon="fas fa-file-alt" label="Templates" />
      </q-tabs>
      <div v-if="tab == 'code'" class="col code-tab">
        <builder-code-editor />
      </div>

      <div v-if="tab == 'races'" class="col races-tab">
        <builder-races-editor />
      </div>

      <div v-if="tab == 'world'" class="col world-tab">
        <builder-world-editor />
      </div>

      <div v-if="tab == 'commands'" class="col commands-tab">
        <builder-commands-editor />
      </div>

      <div v-if="tab == 'templates'" class="col templates-tab">
        <builder-templates-editor />
      </div>
    </div>
  </div>
</template>

<style lang="sass">
.build-instance-wrapper > div.tab-controller { height: 100% !important; width: 100px !important }
</style>

<script lang="ts">
import BuilderCodeEditor from '../components/BuilderCodeEditor.vue';
import BuilderRacesEditor from '../components/BuilderRacesEditor.vue';
import BuilderTemplatesEditor from '../components/BuilderTemplatesEditor.vue';
import BuilderCommandsEditor from '../components/BuilderCommandsEditor.vue';
import BuilderWorldEditor from '../components/BuilderWorldEditor.vue';

export default {
  name: 'BuildInstance',
  components: {
    BuilderCodeEditor,
    BuilderRacesEditor,
    BuilderTemplatesEditor,
    BuilderCommandsEditor,
    BuilderWorldEditor
  },
  data(): {
    loadingInstance: boolean;
    tab: string;
  } {
    return {
      loadingInstance: true,
      tab: 'world'
    };
  },
  created() {
    console.log('89qu9879183u192837912873192837');
    this.$store
      .dispatch('instances/ensureLoaded', this.$route.params.instance)
      .then(() => {
        return this.$store.dispatch(
          'instances/putInstanceBeingBuilt',
          this.$route.params.instance
        );
      })
      .then(() => {
        this.loadingInstance = false;
      });
  }
};
</script>
