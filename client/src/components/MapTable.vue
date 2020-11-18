<template>
    <q-table
      title="Maps"
      :data="maps"
      :columns="mapTableColumns"
      :visible-columns="visibleMapColumns"
      row-key="id"
      flat
      bordered
      class="fit"
      :selected.sync="selectedRow"
      :pagination="initialPagination"
      :rows-per-page-options="[0]"
      :pagination-label="getPaginationLabel"
    >
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
import { MapInterface } from 'src/store/map/state';
import { mapGetters } from 'vuex';
import mapState from '../store/map/state';

interface CommonColumnInterface {
  name: string;
  label: string;
  sortable: boolean;
  field: string;
}

const mapTableColumns = [
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
  data(): {
    mapTableColumns: CommonColumnInterface[];
    mapTableFilter: string;
    selectedRow: MapInterface[];
    initialPagination: { rowsPerPage: number };
    visibleMapColumns: string[];
  } {
    return {
      mapTableColumns,
      mapTableFilter: '',
      selectedRow: [],
      initialPagination: {
        rowsPerPage: 0
      },
      visibleMapColumns: ['name', 'description']
    };
  },
  computed: {
    ...mapGetters({
      maps: 'maps/listAll'
    })
  },
  methods: {
    addMap() {},
    editMap() {
      this.$emit('edit');
    },
    toggleSingleRow(row: MapInterface) {
      this.selectedRow = [row];
      this.$emit('select', row);
    },
    getPaginationLabel(start: number, end: number, total: number): string {
      return total.toString() + ' Map(s)';
    }
  }
};
</script>

<style lang="sass">
td.map-table-cell {  border-bottom-width: 1 !important; }
</style>
