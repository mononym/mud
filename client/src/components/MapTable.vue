<template>
  <div class="q-pa-md">
    <q-table
      title="Maps"
      :data="maps"
      :columns="mapTableColumns"
      row-key="id"
      flat
      bordered
      class="full-height"
      :selected.sync="selectedRow"
      selection="single"
    >
      <template v-slot:top>
        <q-btn color="primary" label="Add Map" @click="addMap" />
        <q-space />
        <q-input
          borderless
          dense
          debounce="300"
          color="primary"
          v-model="mapTableFilter"
        >
          <template v-slot:append>
            <q-icon name="search" />
          </template>
        </q-input>
      </template>

      <template v-slot:header="props">
        <q-tr :props="props">
          <q-th v-for="col in props.cols" :key="col.name" :props="props">
            {{ col.label }}
          </q-th>
        </q-tr>
      </template>

      <template v-slot:body="props">
        <q-tr
          class="cursor-pointer"
          :props="props"
          @click.exact="toggleSingleRow(props.row)"
        >
          <q-td v-for="col in props.cols" :key="col.name" :props="props">
            <span v-if="col.name === 'actions'">
              <q-btn-group flat>
                <q-btn
                  flat
                  label="Edit"
                  icon="fas fa-pencil"
                  @click="editMap(props.row.id)"
                />
              </q-btn-group>
            </span>
            <span v-else>
              {{ col.value }}
            </span>
          </q-td>
        </q-tr>
      </template>
    </q-table>
  </div>
</template>

<script>
import { set } from '@vue/composition-api';
import Vue from 'vue';
import { isNull } from 'util';
import { mapGetters } from 'vuex';

const mapTableColumns = [
  { name: 'actions', label: 'Actions', field: 'actions', sortable: false },
  { name: 'name', label: 'Name', field: 'name', sortable: true },
  {
    name: 'description',
    label: 'Description',
    field: 'description',
    sortable: false
  }
];

export default {
  name: 'MapTable',
  components: {},
  created() {
    this.$store.dispatch('builder/fetchMaps');
  },
  computed: {
    selectedRow: function() {
      if (this.$store.getters['builder/isMapSelected']) {
        return [this.$store.getters['builder/selectedMap']];
      } else {
        return [];
      }
    },
    ...mapGetters({
      maps: 'builder/maps'
    })
  },
  data() {
    return {
      mapTableColumns,
      mapTableFilter: ''
    };
  },
  validations: {},
  methods: {
    addMap() {
      this.$store
        .dispatch('builder/clearAreas')
        .then(() => this.$emit('addMap'));
    },
    editMap(mapId) {
      this.$store.dispatch('builder/fetchAreasForMap', mapId);
      this.$store
        .dispatch('builder/selectMap', mapId)
        .then(() => this.$emit('editMap'));
    },
    toggleSingleRow(row) {
      // this.$store
      //   .dispatch('builder/clearAreas')
      //   .then(() =>
          this.$store
            .dispatch('builder/selectMap', row.id)
            .then(() =>
              this.$store.dispatch('builder/fetchAreasForMap', row.id)
            )
        // );
    }
  }
};
</script>

<style></style>
