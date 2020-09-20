<template>
  <div class="q-pa-none">
    <q-table
      title="Areas"
      :data="areas"
      :columns="areaTableColumns"
      row-key="id"
      flat
      bordered
      class="fit"
      :selected.sync="selectedRow"
      selection="single"
      :pagination="initialPagination"
      virtual-scroll
    >
      <template v-slot:top>
        <q-btn
          :disabled="addAreaButtonDisabled"
          color="primary"
          label="Add Area"
          @click="addArea"
        />
        <q-space />
        <q-input
          v-model="areaTableFilter"
          borderless
          dense
          debounce="300"
          color="primary"
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
          <q-td
            v-for="col in props.cols"
            :key="col.name"
            class="area-table-row"
            :props="props"
          >
            <span v-if="col.name === 'actions'">
              <q-btn-group flat spread>
                <q-btn
                  flat
                  label="Edit"
                  icon="fas fa-pencil"
                  @click="editArea(props.row)"
                />
                <q-btn
                  v-if="props.row.id !== selectedAreaId && selectedAreaId != ''"
                  flat
                  label="Link"
                  icon="fas fa-link"
                  @click.stop="linkArea(props.row)"
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

<script lang="ts">
import { mapGetters } from 'vuex';
import { AreaInterface } from 'src/store/area/state';

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
      areaTableFilter: '',
      initialPagination: {
        rowsPerPage: 0
      }
    };
  },
  computed: {
    addAreaButtonDisabled: function(): boolean {
      return !this.$store.getters['builder/isMapSelected'];
    },
    selectedAreaId: function(): string {
      return this.selectedArea.id;
    },
    selectedMapId: function(): string {
      return this.selectedMap.id;
    },
    selectedRow: function(): AreaInterface[] {
      return [this.$store.getters['builder/selectedArea']];
    },
    ...mapGetters({
      areas: 'builder/areas',
      selectedArea: 'builder/selectedArea',
      selectedMap: 'builder/selectedMap'
    })
  },
  methods: {
    editArea(area: AreaInterface) {
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
    linkArea(area: AreaInterface) {
      console.log(area.id);
    },
    toggleSingleRow(row: AreaInterface) {
      this.$store.dispatch('builder/selectArea', row);
      this.$store.dispatch('builder/clearSelectedLink');
    },
    deleteArea() {
      this.$emit('deleteArea');
    },
    addArea() {
      this.$emit('deleteArea');
    }
  }
};
</script>

<style lang="sass">
.q-table td, .q-table th {  white-space: normal !important; }

td.area-table-cell {  border-bottom-width: 1 !important; }
</style>
