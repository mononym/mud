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
            <region-map />
          </div>
          <div class="col">
            <q-tab-panels
              v-model="mapPanel"
              animated
              class="shadow-2 rounded-borders fit"
            >
              <q-tab-panel class="overflow-hidden" name="table">
                <map-table
                  @saved="mapSaved"
                  @selected="mapSelected"
                  @editMap="editMap"
                  @addMap="addMap"
                />
              </q-tab-panel>

              <q-tab-panel name="wizard">
                <map-wizard @saved="mapSaved" />
              </q-tab-panel>
            </q-tab-panels>
          </div>
        </div>
      </template>

      <template v-slot:after>
        <div class="column full-height">
          <div class="col">
            <area-details @editArea="editArea" />
          </div>
          <div class="col">
            <q-tab-panels
              v-model="areaPanel"
              animated
              class="shadow-2 rounded-borders fit row"
            >
              <q-tab-panel name="table" class="col">
                <area-table
                  @saved="areaSaved"
                  @selected="areaSelected"
                  @editArea="editArea"
                  @addArea="addArea"
                />
              </q-tab-panel>

              <q-tab-panel name="wizard">
                <area-wizard
                  @saved="areaSaved"
                  @mapSelected="areaMapSelected"
                />
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
import AreaTable from '../components/AreaTable.vue';
import MapWizard from '../components/MapWizard.vue';
import MapTable from '../components/MapTable.vue';
import AreaDetails from '../components/AreaDetails.vue';

export default {
  name: 'BuildInstance',
  computed: {},
  components: {
    AreaDetails,
    AreaTable,
    AreaWizard,
    MapTable,
    MapWizard,
    RegionMap
  },
  data() {
    return {
      areaPanel: 'table',
      loading: false,
      mapPanel: 'table',
      splitterModel: 50
    };
  },
  methods: {
    addMap() {
      this.mapPanel = 'wizard';
    },
    addArea() {
      this.areaPanel = 'wizard';
    },
    mapSaved() {
      this.mapPanel = 'table';
    },
    mapSelected() {
      this.areaPanel = 'table';
    },
    areaSelected() {
      // this.areaPanel = 'table';
    },
    areaMapSelected() {
      // this.areaPanel = 'table';
    },
    editMap(mapId) {
      if (
        this.$store.getters('builder/selectedArea').mapId !==
        this.$store.getters('builder/selectedMapId')
      ) {
        this.$store.dispatch('builder/selectArea', '');
      }

      this.areaPanel = 'table';

      this.mapPanel = 'wizard';
    },
    editArea(areaId) {
      console.log(areaId);
      console.log(this.areaPanel);
      // if (areaId === this.selectedArea && this.areaPanel !== 'wizard') {
      this.areaPanel = 'wizard';
      // } else if (areaId !== this.selectedArea) {
      //   this.selectedArea = areaId;
      // this.areaPanel = 'wizard';
      // }
    },
    areaSaved() {
      this.areaPanel = 'table';
    }
  }
};
</script>
