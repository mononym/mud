<template>
  <div class="fit">
    <q-tabs
      v-model="tab"
      dense
      class="text-grey"
      active-color="primary"
      indicator-color="primary"
      align="justify"
      narrow-indicator
    >
      <q-tab name="item" label="Item" />
      <q-tab name="character" label="Character" />
    </q-tabs>

    <q-separator />

    <q-tab-panels v-model="tab" class="tab-panel">
      <q-tab-panel class="flex column" name="item">
        <item-template-editor />
      </q-tab-panel>

      <q-tab-panel class="flex column" name="character">
        <character-template-editor />
      </q-tab-panel>
    </q-tab-panels>
  </div>
</template>

<style lang="sass"></style>

<script lang="ts">
import Vue from 'vue';
import CharacterTemplateEditor from '../components/CharacterTemplateEditor.vue';
import ItemTemplateEditor from '../components/ItemTemplateEditor.vue';

export default {
  name: 'BuilderTemplatesEditor',
  components: { CharacterTemplateEditor, ItemTemplateEditor },
  data(): {
    tab: string;
  } {
    return {
      tab: 'character'
    };
  },
  computed: {},
  created() {},
  // mounted() {},
  methods: {}
};
</script>
