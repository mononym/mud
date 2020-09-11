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
    </q-table>
  </div>
</template>

<script>
import { set } from '@vue/composition-api';
import Vue from 'vue';
import { isNull } from 'util';

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
  components: {},
  created() {
    if (this.id !== '') {
      this.$store
        .dispatch('maps/fetchMaps', this.id)
        .then(maps => {
          console.log('fetch result')
          console.log(maps)
          this.maps = maps;
        })
        .catch(() => {
          alert('Something went wrong attemping to load the maps.');
          this.maps = [];
        })
        .finally(() => {
          this.loading = false;
        });
    }
  },
  computed: {},
  data() {
    return {
      loading: false,
      maps: [],
      mapTableColumns,
      mapTableFilter: ''
    };
  },
  validations: {},
  methods: {
    addMap() {
      this.$emit('addMap');
    },
    editMap(mapId) {
      this.$emit('editMap', mapId);
    }
  }
};
</script>

<style></style>
