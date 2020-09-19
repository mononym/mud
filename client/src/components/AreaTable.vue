<template>
  <div class="q-pa-md col column">
    <q-table
      title="Areas"
      :data="areas"
      :columns="areaTableColumns"
      row-key="id"
      flat
      bordered
      class="col"
      :selected.sync="selectedRow"
      selection="single"
    >
      <template v-slot:top>
        <q-btn
          color="primary"
          label="Add Area"
          @click="addArea"
          :disabled="addAreaButtonDisabled"
        />
        <q-space />
        <q-input
          borderless
          dense
          debounce="300"
          color="primary"
          v-model="areaTableFilter"
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
          <q-td class="area-table-row" v-for="col in props.cols" :key="col.name" :props="props">
            <span v-if="col.name === 'actions'">
              <q-btn-group flat spread>
                <q-btn
                  flat
                  label="Edit"
                  icon="fas fa-pencil"
                  @click="editArea(props.row)"
                />
                <q-btn
                  flat
                  label="Link"
                  icon="fas fa-link"
                  v-on:click.stop="linkArea(props.row)"
                  v-if="props.row.id !== selectedAreaId && selectedAreaId != ''"
                />
                <q-btn
                  flat
                  label="Delete"
                  icon="fas fa-trash"
                  @click="deleteArea"
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
import { mapGetters } from 'vuex';
import areaState from '../store/area/state';

const areaTableColumns = [
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
  name: 'AreaTable',
  components: {},
  data() {
    return {
      areaTableColumns,
      areaTableFilter: ''
    };
  },
  computed: {
    addAreaButtonDisabled: function() {
      return !this.$store.getters['builder/isMapSelected'];
    },
    selectedAreaId: function() {
      return this.selectedArea.id;
    },
    selectedMapId: function() {
      return this.selectedMap.id;
    },
    selectedRow: function() {
      return [this.$store.getters['builder/selectedArea']];
    },
    ...mapGetters({
      areas: 'builder/internalAreas',
      selectedArea: 'builder/selectedArea',
      selectedMap: 'builder/selectedMap'
    })
  },
  created() {},
  validations: {},
  methods: {
    addArea() {
      const newArea = { ...areaState };
      newArea.mapId = this.selectedMapId;
      console.log('newarea');
      console.log(newArea);
      this.$store.dispatch('builder/putIsAreaUnderConstructionNew', true);
      this.$store.dispatch('builder/putIsAreaUnderConstruction', true);
      this.$store.dispatch('builder/putAreaUnderConstruction', newArea);

      this.$emit('addArea');
    },
    editArea(area) {
      this.$store.dispatch('builder/selectArea', area).then(() =>
        this.$store
          .dispatch('builder/putIsAreaUnderConstructionNew', false)
          .then(() =>
            this.$store
              .dispatch('builder/putIsAreaUnderConstruction', true)
              .then(() =>
                this.$store
                  .dispatch('builder/putAreaUnderConstruction', {
                    ...this.selectedArea
                  })
                  .then(() => this.$emit('editArea'))
              )
          )
      );
    },
    linkArea(areaId) {
      console.log('link to area: ' + areaId);
    },
    toggleSingleRow(row) {
      this.$store.dispatch('builder/selectArea', row);
    },
    deleteArea() {
      this.$emit('deleteArea');
    }
  }
};
</script>

<style lang="sass">
.q-table td, .q-table th {  white-space: normal !important; }

td.area-table-cell {  border-bottom-width: 1 !important; }
</style>
