<template>
  <div class="q-pa-md fit">
    <q-card flat bordered class="fit column">
      <q-card-section>
        <div v-if="isAreaSelected || isAreaUnderConstruction" class="text-h6">
          {{ workingArea.name }}
        </div>
      </q-card-section>

      <q-card-section class="q-pt-none col">
        <p v-if="isAreaSelected || isAreaUnderConstruction">
          {{ workingArea.description }}
        </p>
      </q-card-section>

      <q-separator inset />

      <q-card-actions>
        <q-btn flat @click="editArea" :disabled="buttonsDisabled">Edit</q-btn>
        <q-btn flat @click="cloneArea" :disabled="buttonsDisabled">Clone</q-btn>
        <q-btn flat :disabled="buttonsDisabled" @click="deleteArea"
          >Delete</q-btn
        >
      </q-card-actions>
    </q-card>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import defaultArea from '../store/area/state';

export default {
  name: 'AreaDetails',
  data() {
    return {
      selectedArea: defaultArea,
      confirmDelete: false
    };
  },
  computed: {
    buttonsDisabled() {
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

<style></style>
