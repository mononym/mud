<template>
  <q-table
    title="Areas"
    :data="areas"
    :columns="areaTableColumns"
    row-key="id"
    flat
    bordered
    class="fit"
    :selected.sync="selectedrow"
    selection="single"
    :rows-per-page-options="[0]"
    :pagination="initialPagination"
    virtual-scroll
    :pagination-label="getPaginationLabel"
  >
    <template v-slot:top>
      <q-btn color="primary" label="Create New Area" @click="createArea" />
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

    <template v-slot:body-cell="props">
      <q-td
        :props="props"
        class="cursor-pointer"
        @click.exact="toggleSingleRow(props.row)"
      >
        {{ props.value }}
      </q-td>
    </template>
  </q-table>
</template>

<script lang="ts">
import { mapGetters } from 'vuex';
import { AreaInterface } from 'src/store/area/state';

const areaTableColumns = [
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
  props: {
    selectedrow: {
      type: Array,
      required: true
    }
  },
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
    selectedAreaId: function(): string {
      return this.selectedArea.id;
    },
    selectedMapId: function(): string {
      return this.selectedMap.id;
    },
    ...mapGetters({
      areas: 'areas/listAll',
      selectedArea: 'builder/selectedArea',
      selectedMap: 'builder/selectedMap'
    })
  },
  methods: {
    editArea(area: AreaInterface) {},
    linkArea(area: AreaInterface) {
      console.log(area.id);
    },
    toggleSingleRow(row: AreaInterface) {
      this.$emit('select', row);
    },
    createArea() {
      this.$emit('create');
    },
    getPaginationLabel(start: number, end: number, total: number): string {
      return total.toString() + ' Area(s)';
    }
  }
};
</script>

<style lang="sass">
.q-table td, .q-table th {  white-space: normal !important; }

td.area-table-cell {  border-bottom-width: 1 !important; }
</style>
