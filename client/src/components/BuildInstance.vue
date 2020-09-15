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
                <map-wizard @saved="mapSaved" @canceled="cancelMapEdit" />
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
                  @deleteArea="showDeleteAreaConfirmation"
                />
              </q-tab-panel>

              <q-tab-panel name="wizard">
                <area-wizard
                  @saved="areaSaved"
                  @mapSelected="areaMapSelected"
                  @deleteArea="showDeleteAreaConfirmation"
                  @canceled="cancelAreaEdit"
                />
              </q-tab-panel>
            </q-tab-panels>
          </div>
        </div>
      </template>
    </q-splitter>

    <q-dialog v-model="confirmDeleteArea" persistent>
      <q-card>
        <q-card-section class="row items-center">
          <q-avatar icon="fas fa-trash" color="primary" text-color="white" />
          <span class="q-ml-sm"
            >Confirm deletion of room: {{ selectedArea.name }}</span
          >
        </q-card-section>

        <q-card-actions align="right">
          <q-btn
            flat
            label="Delete"
            color="primary"
            v-close-popup
            @click="deleteArea"
          />
          <q-btn flat label="Cancel" color="primary" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import RegionMap from '../components/RegionMap.vue';
import AreaWizard from '../components/AreaWizard.vue';
import AreaTable from '../components/AreaTable.vue';
import MapWizard from '../components/MapWizard.vue';
import MapTable from '../components/MapTable.vue';
import AreaDetails from '../components/AreaDetails.vue';
import { mapGetters } from 'vuex';

export default {
  name: 'BuildInstance',
  computed: {
    ...mapGetters({
      selectedArea: 'builder/selectedArea',
      selectedMap: 'builder/selectedMap'
    })
  },
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
      splitterModel: 50,
      confirmDeleteArea: false
    };
  },
  methods: {
    addMap() {
      this.mapPanel = 'wizard';
    },
    addArea() {
      this.areaPanel = 'wizard';
    },
    cancelAreaEdit() {
      this.areaPanel = 'table';
    },
    cancelMapEdit() {
      this.mapPanel = 'table';
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
    showDeleteAreaConfirmation() {
      this.confirmDeleteArea = true;
    },
    deleteArea() {
      this.$store.dispatch('builder/deleteArea');
    },
    editMap() {
      if (this.selectedArea.mapId !== this.selectedMap.id) {
        this.$store.dispatch('builder/selectArea', '');
      }

      this.areaPanel = 'table';

      this.mapPanel = 'wizard';
    },
    editArea() {
      this.$store
        .dispatch('builder/putIsAreaUnderConstruction', true)
        .then(() => (this.areaPanel = 'wizard'));
    },
    areaSaved() {
      this.areaPanel = 'table';
    }
  }
};
</script>
