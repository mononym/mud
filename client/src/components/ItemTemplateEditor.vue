<template>
  <div class="fit flex row wrap">
    <div class="half-width">Sample item to apply the template to</div>
    <div class="half-width">
      Display the template output of select/edited template
    </div>
    <div v-show="!editing" class="full-width">
      list the templates in a table
    </div>
    <div v-show="editing" class="full-width">edit the templates</div>
  </div>
</template>

<script lang="ts">
import { Prop } from 'vue/types/options';

export default {
  name: 'ItemTemplateEditor',
  components: {},
  props: {},
  data(): {
    editing: boolean;
  } {
    return {
      editing: false
    };
  },
  computed: {},
  created() {},
  methods: {}
};
</script>

<style lang="sass">
.half-width { width: 50% }
</style>
