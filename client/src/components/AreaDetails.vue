<template>
  <div class="q-pa-md fit">
    <q-card flat bordered class="fit column">
      <q-card-section>
        <div v-if="isAreaSelected || isAreaUnderConstruction" class="text-h6">{{ selectedArea.name }}</div>
      </q-card-section>

      <q-card-section class="q-pt-none col">
        <p v-if="isAreaSelected || isAreaUnderConstruction">{{ selectedArea.description }}</p>
      </q-card-section>

      <q-separator inset />

      <q-card-actions>
        <q-btn flat @click="editArea" :disabled="buttonsDisabled">Edit</q-btn>
        <q-btn flat :disabled="buttonsDisabled" @click="confirmDelete = true">Delete</q-btn>
      </q-card-actions>
    </q-card>

    <q-dialog v-model="confirmDelete" persistent>
      <q-card>
        <q-card-section class="row items-center">
          <q-avatar icon="fas fa-trash" color="primary" text-color="white" />
          <span class="q-ml-sm">Confirm deletion of room: {{ selectedArea.name }}</span>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Delete" color="primary" v-close-popup @click="deleteArea"/>
          <q-btn flat label="Cancel" color="primary" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
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
      return !this.isAreaSelected
    },
    ...mapGetters({
      area: 'builder/selectedArea',
      isAreaSelected: 'builder/isAreaSelected',
      isAreaUnderConstruction: 'builder/isAreaUnderConstruction',
      areaUnderConstruction: 'builder/areaUnderConstruction'
    })
  },
  methods: {
    editArea() {
      this.$emit('editArea');
    },
    deleteArea() {
      this.selectedArea = defaultArea
      this.$store.dispatch('builder/deleteArea')
    }
  },
  watch: {
    areaUnderConstruction: function (area) {
      if (this.isAreaUnderConstruction) {
        this.selectedArea = area
      }
    },
    area: function (area) {
      if (this.isAreaSelected) {
        this.selectedArea = area
      }
    },
    isAreaSelected: function () {
      if (!this.isAreaSelected && !this.isAreaUnderConstruction) {
        this.selectedArea = defaultArea
      }
    },
    isAreaUnderConstruction: function () {
      if (!this.isAreaSelected && !this.isAreaUnderConstruction) {
        this.selectedArea = defaultArea
      }
    },
  }
};
</script>

<style>
</style>
