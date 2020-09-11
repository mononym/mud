<template>
  <div class="q-pa-md fit">
    <q-splitter
      class="dashboardSplitter col full-height"
      v-model="splitterModel"
      unit="%"
    >
      <template v-slot:before>
        <div class="column full-height">
          <div class="col">
            <region-map/>
          </div>
          <div class="col">
            <q-tab-panels v-model="mapPanel" animated class="shadow-2 rounded-borders fit">
              <q-tab-panel class="overflow-hidden" name="table">
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
                  <q-btn color="primary" :disable="loading" label="Add Map" @click="addMap" />
                  <q-space />
                  <q-input borderless dense debounce="300" color="primary" v-model="mapTableFilter">
                    <template v-slot:append>
                      <q-icon name="search" />
                    </template>
                  </q-input>
                </template>
                </q-table>
              </q-tab-panel>

              <q-tab-panel name="wizard">
                <map-wizard/>
              </q-tab-panel>
            </q-tab-panels>

          </div>
        </div>
      </template>

      <template v-slot:after>
        <div class="column full-height">
          <div class="col">
            <q-card flat bordered class="fit column">
              <q-card-section>
                <div class="text-h6">{{ selectedAreaName }}</div>
              </q-card-section>

              <q-card-section class="q-pt-none col">
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
                tempor incididunt ut labore et dolore magna aliqua.
              </q-card-section>

              <q-separator inset />

              <q-card-actions>
                <q-btn flat>Edit</q-btn>
              </q-card-actions>
            </q-card>
          </div>
          <div class="col">
            <q-tab-panels v-model="areaPanel" animated class="shadow-2 rounded-borders fit row">
              <q-tab-panel name="table" class="col">
                <q-table
                  title="Areas"
                  :data="areas"
                  :columns="areaTableColumns"
                  row-key="id"
                  flat
                  bordered
                  class="full-height"
                >
                <template v-slot:top>
                  <q-btn color="primary" :disable="loading" label="Add Area" @click="addArea" />
                  <q-space />
                  <q-input borderless dense debounce="300" color="primary" v-model="areaTableFilter">
                    <template v-slot:append>
                      <q-icon name="search" />
                    </template>
                  </q-input>
                </template>
                </q-table>
              </q-tab-panel>

              <q-tab-panel name="wizard">
                <area-wizard/>
              </q-tab-panel>
            </q-tab-panels>
          </div>
        </div>
      </template>
    </q-splitter>
  </div>
</template>

<script>
import RegionMap from '../components/RegionMap.vue';
import AreaWizard from '../components/AreaWizard.vue';
import MapWizard from '../components/MapWizard.vue';

const areaTableColumns = [
  { name: 'name', label: 'Name', field: 'name', sortable: true },
  { name: 'description', label: 'Description', field: 'description', sortable: false },
  { name: 'map', label: 'Map', field: 'map', sortable: true },
  { name: 'characters', label: 'Characters', field: 'characterCount', sortable: true },
  { name: 'items', label: 'Items', field: 'itemCount', sortable: true }
]
  
  const areas = [
          {
            id: 'asd',
            name: 'Alwazihiri Fortress, Western Battlements',
            description: 'The massive walls tower over the countryside, offering an unobstructed view.',
            map: 'Alwazihiri Fortress and Surroundings',
            characterCount: 2,
            itemCount: 10,
          },
          {
            id: 'aswd',
            name: 'Alwazihiri Fortress, Eastern Battlements',
            description: 'The massive walls tower over the countryside, offering an unobstructed view.',
            map: 'Alwazihiri Fortress and Surroundings',
            characterCount: 0,
            itemCount: 1,
          },
          {
            id: 'ased',
            name: 'Alwazihiri Fortress, Northern Battlements',
            description: 'The massive walls tower over the countryside, offering an unobstructed view.',
            map: 'Alwazihiri Fortress and Surroundings',
            characterCount: 22,
            itemCount: 100,
          },
          {
            id: 'asdd',
            name: 'Alwazihiri Fortress, Soutern Battlements',
            description: 'The massive walls tower over the countryside, offering an unobstructed view.',
            map: 'Alwazihiri Fortress and Surroundings',
            characterCount: 12,
            itemCount: 110,
          },
  ]

const mapTableColumns = [
  { name: 'name', label: 'Name', field: 'name', sortable: true },
  { name: 'description', label: 'Description', field: 'description', sortable: false },
  { name: 'areas', label: 'Areas', field: 'area_count', sortable: true },
  { name: 'characters', label: 'Characters', field: 'character_count', sortable: true }
]

const maps = [
        {
          id: 'asd',
          name: 'Alwazihiri Fortress, Western Battlements',
          description: 'The massive walls tower over the countryside, offering an unobstructed view.',
          area_count: 2,
          character_count: 10,
        },
        {
          id: 'adsd',
          name: 'Alwazihiri Fortress, Western Battlements',
          description: 'The massive walls tower over the countryside, offering an unobstructed view.',
          area_count: 4,
          character_count: 1,
        },
        {
          id: 'asfd',
          name: 'Alwazihiri Fortress, Western Battlements',
          description: 'The massive walls tower over the countryside, offering an unobstructed view.',
          area_count: 34,
          character_count: 0,
        },
        {
          id: 'asgd',
          name: 'Alwazihiri Fortress, Western Battlements',
          description: 'The massive walls tower over the countryside, offering an unobstructed view.',
          area_count: 23,
          character_count: 104,
        },
        {
          id: 'rasd',
          name: 'Alwazihiri Fortress, Western Battlements',
          description: 'The massive walls tower over the countryside, offering an unobstructed view.',
          area_count: 24,
          character_count: 35,
        },
]

export default {
  name: 'BuildInstance',
  computed: {
    selectedAreaName() {
      return 'Test Name';
    },
    selectedAreaDescription() {
      return 'Test Description';
    }
   },
  components: { AreaWizard, MapWizard, RegionMap },
  data() {
    return {
      areaPanel: 'table',
      areas,
      areaTableColumns,
      areaTableFilter: '',
      loading: false,
      mapPanel: 'table',
      maps,
      mapTableColumns,
      mapTableFilter: '',
      splitterModel: 25,
    };
  },
  methods: {
    addMap() {
      this.mapPanel = 'wizard'
    },
    addArea() {
      this.areaPanel = 'wizard'
    }
  }
};
</script>
