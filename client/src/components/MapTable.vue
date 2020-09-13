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
      :selected.sync="selected"
      selection="single"
    >
      <template v-slot:top>
        <q-btn
          color="primary"
          :disable="loading"
          label="Add Map"
          @click="addMap"
        />
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
                <q-btn flat label="Edit" icon="fas fa-pencil" @click="editMap(props.row.id)" />
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
  props: ['id'],
  components: {},
  created() {
    this.$store
      .dispatch('maps/fetchMaps')
      .then(maps => {
        console.log('fetch result');
        console.log(maps);
        this.maps = maps;
      })
      .catch(() => {
        alert('Something went wrong attemping to load the maps.');
        this.maps = [];
      })
      .finally(() => {
        this.loading = false;
      })

    if (this.id !== '') {
      this.selected = [];
      this.selected.push({id: this.id, description: this.description, name: this.name});
      this.selectedMapId = this.id
    }
  },
  computed: {
    // selected() {
    //   return 'Test Name';
    // }
  },
  data() {
    return {
      loading: false,
      maps: [],
      mapTableColumns,
      mapTableFilter: '',
      selectedMapId: '',
      selected: []
    };
  },
  validations: {},
  methods: {
    addMap() {
      console.log('emitting addMap')
      this.$emit('addMap');
    },
    editMap(mapId) {
      console.log('emitting edit')
      this.$emit('editMap', mapId);
    },
    toggleSingleRow(row) {
      console.log(row)
      this.selectedMapId = row.id
      this.selected = [];
      this.selected.push(row);
      this.$emit('selected', row.id);
    }
  },
  watch: {
    id(value) {
      if (value !== this.selectedMapId) {
        this.$store.dispatch('maps/fetchMap', value).then(map => {
        this.selected = [];
        this.selected.push(map)
      });
      }
    }
  }
};
</script>

<style></style>
