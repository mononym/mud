<template>
  <div class="q-pa-md fit">
    <q-card flat bordered class="fit column">
      <q-card-section>
        <p class="text-h6 text-center">
          {{ workingArea.name }}
        </p>
      </q-card-section>

      <q-card-section>
        <q-tabs v-model="tab" class="text-teal" dense align="justify">
          <q-tab name="description" label="Description" />
          <q-tab name="links" label="Links" />
        </q-tabs>
      </q-card-section>

      <q-card-section class="q-pt-none col">
        <q-tab-panels
          v-model="tab"
          animated
          transition-prev="jump-up"
          transition-next="jump-up"
          class="col-grow full-height row"
        >
          <q-tab-panel class="col row q-pa-none" name="description">
            <p>{{ workingArea.description }}</p>
          </q-tab-panel>

          <q-tab-panel class="col row q-pa-none" name="links">
            <link-table />
          </q-tab-panel>
        </q-tab-panels>
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
