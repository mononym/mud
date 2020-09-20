<template>
  <div class="q-pa-none">
    <q-card class="fit flex column" flat bordered>
      <q-card-section class="col-shrink q-pb-none">
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

      <q-card-section class="q-pa-none col">
        <p v-show="tab == 'description'" class="q-pa-sm">{{ workingArea.description }}</p>
        <link-table v-show="tab == 'links'" />
      </q-card-section>

      <q-separator class="col-1px full-width" inset />

      <q-card-actions align="around" class="col-auto">
        <q-btn
          class="col"
          flat
          label="New"
          :disabled="buttonsDisabled"
          @click="newArea"
        />
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
  </div>
</template>

<script lang="ts">
import { mapGetters } from 'vuex';
import defaultArea from '../store/area/state';
import LinkTable from '../components/LinkTable.vue';
import areaState from '../store/area/state';

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
      workingArea: 'builder/workingArea',
      selectedMapId: 'builder/selectedMapId'
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
    },
    newArea() {
      this.$emit('deleteArea');
    },
    addArea() {
      const newArea = { ...areaState };
      newArea.mapId = this.selectedMapId;
      this.$store.dispatch('builder/putIsAreaUnderConstructionNew', true);
      this.$store.dispatch('builder/putIsAreaUnderConstruction', true);
      this.$store.dispatch('builder/putAreaUnderConstruction', newArea);
    }
  }
};
</script>

<style lang="sass"></style>
