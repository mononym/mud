<template>
  <q-card class="col-grow flex column" flat bordered>
    <q-card-section class="q-pb-none col-auto">
      <p class="text-h6 text-center">
        {{ workingArea.name }}
      </p>
    </q-card-section>

    <q-card-section class="q-pa-none col-auto">
      <q-tabs v-model="tab" class="text-teal" dense align="justify">
        <q-tab name="description" label="Description" />
        <q-tab name="links" label="Links" />
      </q-tabs>
    </q-card-section>

    <q-card-section class="area-panel q-pa-none col flex column">
      <q-tab-panels
        v-model="tab"
        animated
        transition-prev="jump-up"
        transition-next="jump-up"
        class="tab-panel col flex column"
      >
        <q-tab-panel class="q-pa-none col" name="description">
          <p>{{ workingArea.description }}</p>
        </q-tab-panel>

        <q-tab-panel class="q-pa-none col flex column" name="links">
          <link-table />
        </q-tab-panel>
      </q-tab-panels>
    </q-card-section>

    <q-separator class="col-1px" inset />

    <q-card-actions align="around" class="col-auto">
      <q-btn class="col" flat :disabled="buttonsDisabled" @click="editArea"
        >Edit</q-btn
      >
      <q-btn class="col" flat :disabled="buttonsDisabled" @click="cloneArea"
        >Clone</q-btn
      >
      <q-btn class="col" flat :disabled="buttonsDisabled" @click="deleteArea"
        >Delete</q-btn
      >
    </q-card-actions>
  </q-card>
</template>

<script lang="ts">
import { mapGetters } from 'vuex';
import defaultArea from '../store/area/state';
import LinkTable from '../components/LinkTable.vue';

export default {
  name: 'AreaDetails',
  components: { LinkTable },
  data() {
    return {
      selectedArea: defaultArea,
      confirmDelete: false,
      tab: 'description'
    };
  },
  computed: {
    buttonsDisabled(): boolean {
      return !this.isAreaSelected || this.isAreaUnderConstruction;
    },
    ...mapGetters({
      isAreaSelected: 'builder/isAreaSelected',
      isAreaUnderConstruction: 'builder/isAreaUnderConstruction',
      workingArea: 'builder/workingArea'
    })
  },
  methods: {
    editArea() {
      this.$store.dispatch('builder/putIsAreaUnderConstructionNew', false);
      this.$store.dispatch('builder/putIsAreaUnderConstruction', true);
      this.$store.dispatch('builder/putAreaUnderConstruction', {
        ...this.workingArea
      });
      this.$emit('editArea');
    },
    cloneArea() {
      this.$store.dispatch('builder/putIsAreaUnderConstructionNew', true);
      this.$store.dispatch('builder/putIsAreaUnderConstruction', true);
      this.$store.dispatch('builder/putAreaUnderConstruction', {
        ...this.workingArea
      });
      this.$emit('editArea');
    },
    deleteArea() {
      this.$emit('deleteArea');
    }
  }
};
</script>

<style lang="sass">
.area-panels { max-height: calc(100% - 100px) !important}
.tab-panels { max-height: 100% !important}
</style>
