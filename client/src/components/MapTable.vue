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
                  @click="editMap(props.row)"
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
import mapState from '../store/map/state';

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
  computed: {
    selectedRow: function() {
      return [this.$store.getters['builder/selectedMap']];
    },
    ...mapGetters({
      maps: 'builder/maps',
      selectedMap: 'builder/selectedMap'
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
        .dispatch('builder/putIsMapUnderConstructionNew', true)
        .then(() =>
          this.$store
            .dispatch('builder/putIsMapUnderConstruction', true)
            .then(() =>
              this.$store
                .dispatch('builder/putMapUnderConstruction', { ...mapState })
                .then(() =>
                  this.$store.dispatch('builder/resetAreas', { ...mapState })
                )
                .then(() => this.$emit('addMap'))
            )
        );
    },
    editMap(map) {
      this.$store.dispatch('builder/selectMap', map).then(() =>
        this.$store
          .dispatch('builder/putIsMapUnderConstructionNew', false)
          .then(() =>
            this.$store
              .dispatch('builder/putIsMapUnderConstruction', true)
              .then(() =>
                this.$store
                  .dispatch('builder/putMapUnderConstruction', this.selectedMap)
                  .then(() =>
                    this.$store.dispatch('builder/fetchAreasForMap', map.id)
                  )
                  .then(() => this.$emit('editMap'))
              )
          )
      );
    },
    toggleSingleRow(row) {
      if (this.selectedMap.id !== row.id) {
        this.$store.dispatch('builder/selectMap', row).then(() => {
          this.$store
            .dispatch('builder/fetchAreasForMap', row.id)
            .then(() => this.$emit('selected'));
        });
      }
    }
  }
};
</script>

<style></style>
