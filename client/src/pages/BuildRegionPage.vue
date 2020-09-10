<template>
  <q-page class="buildRegionPage row">
    <div class="dashboardContainer col">
      <q-splitter
        class="dashboardSplitter col full-height"
        v-model="splitterModel"
        unit="%"
        disable
      >
        <template v-slot:before>
          <div class="column full-height">
            <div class="col">
              <q-tab-panels v-model="mapPanel" animated class="shadow-2 rounded-borders fit">
                <q-tab-panel class="overflow-hidden" name="map">
                  <region-map/>
                </q-tab-panel>

                <q-tab-panel name="mapWizard">
                  <div class="text-h6">Map Wizard</div>
                  Wizard goes here
                </q-tab-panel>
              </q-tab-panels>
            </div>
            <div class="col">
              <q-table
                title="Maps"
                :data="maps"
                :columns="map_table_columns"
                row-key="name"
                flat
                bordered
                class="full-height"
              >
              <template v-slot:top>
                <q-btn color="primary" :disable="loading" label="Add Map" @click="addMap" />
                <q-space />
                <q-input borderless dense debounce="300" color="primary" v-model="filter">
                  <template v-slot:append>
                    <q-icon name="search" />
                  </template>
                </q-input>
              </template>
              </q-table>
            </div>
          </div>
        </template>

        <template v-slot:after>
          <div class="column full-height">
            <div class="col">
              <q-tab-panels v-model="areaPanel" animated class="shadow-2 rounded-borders">
                <q-tab-panel name="overview">
                  <q-card flat bordered>
                    <q-card-section>
                      <div class="text-h6">{{ selectedAreaName }}</div>
                    </q-card-section>

                    <q-card-section class="q-pt-none">
                      Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
                      tempor incididunt ut labore et dolore magna aliqua.
                    </q-card-section>

                    <q-separator inset />

                    <q-card-actions>
                      <q-btn flat>Edit</q-btn>
                      <q-btn flat>Action 2</q-btn>
                    </q-card-actions>
                  </q-card>
                </q-tab-panel>

                <q-tab-panel name="wizard">
                  <div class="text-h6">Area Wizard</div>
                  Wizard goes here
                </q-tab-panel>
              </q-tab-panels>
            </div>
            <div class="col">
              <q-table
                title="Areas"
                :data="areas"
                :columns="area_table_columns"
                row-key="name"
                flat
                bordered
                class="full-height"
              >
              <template v-slot:top>
                <q-btn color="primary" :disable="loading" label="Add Area" @click="addArea" />
                <q-space />
                <q-input borderless dense debounce="300" color="primary" v-model="filter">
                  <template v-slot:append>
                    <q-icon name="search" />
                  </template>
                </q-input>
              </template>
              </q-table>
            </div>
          </div>
        </template>
      </q-splitter>
    </div>
  </q-page>
</template>

<style lang="sass">
.my-sticky-header-table
  /* height or max-height is important */
  height: 310px

  .q-table__top,
  .q-table__bottom,
  thead tr:first-child th
    /* bg color is important for th; just specify one */
    background-color: #c1f4cd

  thead tr th
    position: sticky
    z-index: 1
  thead tr:first-child th
    top: 0

  /* this is when the loading indicator appears */
  &.q-table--loading thead tr:last-child th
    /* height of all previous header rows */
    top: 48px
</style>

<script>
import RegionMap from '../components/RegionMap.vue';

const area_table_columns = [
  { name: 'name', label: 'Name', field: 'name', sortable: true },
  { name: 'description', label: 'Description', field: 'description', sortable: false },
  { name: 'map', label: 'Map', field: 'map', sortable: true }
]
  
  const areas = [
          {
            id: 'asd',
            name: 'Alwazihiri Fortress, Western Battlements',
            description: 'The massive walls tower over the countryside, offering an unobstructed view.',
            map: 'Alwazihiri Fortress and Surroundings',
          },
          {
            id: 'aswd',
            name: 'Alwazihiri Fortress, Eastern Battlements',
            description: 'The massive walls tower over the countryside, offering an unobstructed view.',
            map: 'Alwazihiri Fortress and Surroundings',
          },
          {
            id: 'ased',
            name: 'Alwazihiri Fortress, Northern Battlements',
            description: 'The massive walls tower over the countryside, offering an unobstructed view.',
            map: 'Alwazihiri Fortress and Surroundings',
          },
          {
            id: 'asdd',
            name: 'Alwazihiri Fortress, Soutern Battlements',
            description: 'The massive walls tower over the countryside, offering an unobstructed view.',
            map: 'Alwazihiri Fortress and Surroundings',
          },
  ]

const map_table_columns = [
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
  name: 'BuildRegionPage',
  splitterModel: 50,
  computed: {
    selectedAreaName() {
      return 'Test Name';
    },
    selectedAreaDescription() {
      return 'Test Description';
    }
   },
  components: { RegionMap },
  data() {
    return {
      areas,
      area_table_columns,
      maps,
      map_table_columns,
      mapPanel: 'map',
      areaPanel: 'overview'
    };
  }
};
</script>
