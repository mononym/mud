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
        <q-btn flat :disabled="buttonsDisabled">Delete</q-btn>
      </q-card-actions>
    </q-card>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import defaultArea from '../store/area/state';

export default {
  name: 'AreaDetails',
  data() {
    return {
      selectedArea: defaultArea
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
    }
  }
};
</script>

<style>
</style>
