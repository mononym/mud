<template>
  <q-splitter
    class="buildInstanceSplitter col"
    v-model="splitterModel"
    unit="%"
  >
    <template v-slot:before>
      <q-splitter
        class="mapSplitter col-grow row"
        v-model="mapSplitterModel"
        unit="%"
        horizontal
      >
        <template v-slot:before>
          <div class="col full-height column">
            <builder-map />
          </div>
        </template>

        <template v-slot:after>
          <q-tab-panels
            v-model="bottomLeftPanel"
            animated
            class="rounded-borders full-height column"
          >
            <q-tab-panel class="col column flex q-pa-none" name="table">
              <map-table
                @saved="mapSaved"
                @selected="mapSelected"
                @editMap="editMap"
                @addMap="addMap"
              />
            </q-tab-panel>

            <q-tab-panel class="col column flex" name="wizard">
              <map-wizard @saved="mapSaved" @canceled="cancelMapEdit" />
            </q-tab-panel>
          </q-tab-panels>
        </template>
      </q-splitter>
    </template>

    <template v-slot:after>
      <q-splitter
        class="areaSplitter col-grow row"
        v-model="areaSplitterModel"
        unit="%"
        horizontal
      >
        <template v-slot:before>
          <div class="col full-height column">
            <area-details @editArea="editArea" />
          </div>
        </template>

        <template v-slot:after>
          <q-tab-panels
            v-model="bottomRightPanel"
            animated
            class="rounded-borders full-height column"
          >
            <q-tab-panel name="areaTable" class="col column flex q-pa-none">
              <area-table
                @saved="areaSaved"
                @selected="areaSelected"
                @editArea="editArea"
                @addArea="addArea"
                @deleteArea="showDeleteAreaConfirmation"
              />
            </q-tab-panel>

            <q-tab-panel class="col column flex" name="areaWizard">
              <area-wizard
                @saved="areaSaved"
                @mapSelected="areaMapSelected"
                @deleteArea="showDeleteAreaConfirmation"
                @canceled="cancelAreaEdit"
              />
            </q-tab-panel>

            <q-tab-panel class="col column flex" name="linkTable">
              <link-table
                @saved="linkSaved"
                @selected="linkSelected"
                @editLink="editLink"
                @addLink="addLink"
                @deleteLink="showDeleteLinkConfirmation"
              />
            </q-tab-panel>
          </q-tab-panels>
        </template>
      </q-splitter>
    </template>
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
  </q-splitter>
</template>

<style lang="sass">
#map-table { padding-bottom: 0px !important; padding-top: 0px !important }

.buildInstanceSplitter { max-height: calc(100vh - 50px) }
</style>

<script>
import BuilderMap from '../components/BuilderMap.vue';
import AreaWizard from '../components/AreaWizard.vue';
import AreaTable from '../components/AreaTable.vue';
import MapWizard from '../components/MapWizard.vue';
import MapTable from '../components/MapTable.vue';
import AreaDetails from '../components/AreaDetails.vue';
import { mapGetters } from 'vuex';

export default {
  name: 'BuildInstance',
  created() {
    this.$store.dispatch('builder/fetchMaps');
  },
  components: {
    AreaDetails,
    AreaTable,
    AreaWizard,
    MapTable,
    MapWizard,
    BuilderMap
  },
  data() {
    return {
      bottomRightPanel: 'table',
      loading: false,
      bottomLeftPanel: 'table',
      areaSplitterModel: 50,
      mapSplitterModel: 50,
      splitterModel: 50,
      confirmDeleteArea: false
    };
  },
  computed: {
    ...mapGetters({
      selectedArea: 'builder/selectedArea',
      selectedMap: 'builder/selectedMap'
    })
  },
  methods: {
    addMap() {
      this.bottomLeftPanel = 'wizard';
    },
    addArea() {
      this.bottomRightPanel = 'areaWizard';
    },
    cancelAreaEdit() {
      this.bottomRightPanel = 'areaTable';
    },
    cancelMapEdit() {
      this.bottomLeftPanel = 'table';
    },
    mapSaved() {
      this.bottomLeftPanel = 'table';
    },
    mapSelected() {
      this.bottomRightPanel = 'areaTable';
    },
    areaSelected() {
      // this.bottomRightPanel = 'table';
    },
    showDeleteAreaConfirmation() {
      this.confirmDeleteArea = true;
    },
    deleteArea() {
      this.$store.dispatch('builder/deleteArea');
    },
    editMap() {
      this.bottomRightPanel = 'areaTable';

      this.bottomLeftPanel = 'wizard';
    },
    editArea() {
      this.$store
        .dispatch('builder/putIsAreaUnderConstruction', true)
        .then(() => (this.bottomRightPanel = 'areaWizard'));
    },
    areaSaved() {
      this.bottomRightPanel = 'areaTable';
    }
  }
};
</script>
