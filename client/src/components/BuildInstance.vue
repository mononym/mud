<template>
  <div class="flex col row">
    <div class="flex col column">
      <div class="col column flex">
        <builder-map />
      </div>
      <div class="col column flex">
        <q-tab-panels
          v-model="bottomLeftPanel"
          animated
          class="rounded-borders col column flex"
        >
          <q-tab-panel class="col column flex q-pa-none" name="mapTable">
            <map-table
              @saved="mapSaved"
              @selected="mapSelected"
              @editMap="editMap"
              @addMap="addMap"
            />
          </q-tab-panel>

          <q-tab-panel class="col column flex q-pa-none" name="wizard">
            <map-wizard @saved="mapSaved" @canceled="cancelMapEdit" />
          </q-tab-panel>
        </q-tab-panels>
      </div>
    </div>

    <div class="flex col column">
      <div class="col flex column">
        <area-details @editArea="editArea" />
      </div>

      <div class="col flex column">
        <q-tab-panels
          v-model="bottomRightPanel"
          animated
          class="rounded-borders col flex column"
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

          <q-tab-panel class="col column flex q-pa-none" name="areaWizard">
            <area-wizard
              @saved="areaSaved"
              @deleteArea="showDeleteAreaConfirmation"
              @canceled="cancelAreaEdit"
            />
          </q-tab-panel>

          <q-tab-panel class="col column flex q-pa-none" name="linkDetails">
            <link-details
              @saved="linkSaved"
              @editLink="editLink"
              @addLink="addLink"
              @deleteLink="showDeleteLinkConfirmation"
            />
          </q-tab-panel>

          <q-tab-panel class="col column flex q-pa-none" name="linkWizard">
            <link-wizard />
          </q-tab-panel>
        </q-tab-panels>
      </div>
    </div>

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
            v-close-popup
            flat
            label="Delete"
            color="primary"
            @click="deleteArea"
          />
          <q-btn v-close-popup flat label="Cancel" color="primary" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<style lang="sass">
.buildInstanceSplitter { max-height: calc(100vh - 50px) }
</style>

<script>
import BuilderMap from '../components/BuilderMap.vue';
import AreaWizard from '../components/AreaWizard.vue';
import AreaTable from '../components/AreaTable.vue';
import MapWizard from '../components/MapWizard.vue';
import MapTable from '../components/MapTable.vue';
import AreaDetails from '../components/AreaDetails.vue';
import LinkDetails from '../components/LinkDetails.vue';
import LinkWizard from '../components/LinkWizard.vue';
import { mapGetters } from 'vuex';

export default {
  name: 'BuildInstance',
  components: {
    AreaDetails,
    AreaTable,
    AreaWizard,
    MapTable,
    MapWizard,
    BuilderMap,
    LinkDetails,
    LinkWizard
  },
  data() {
    return {
      loading: false,
      areaSplitterModel: 50,
      mapSplitterModel: 50,
      splitterModel: 50,
      confirmDeleteArea: false
    };
  },
  computed: {
    ...mapGetters({
      selectedArea: 'builder/selectedArea',
      selectedMap: 'builder/selectedMap',
      bottomLeftPanel: 'builder/bottomLeftPanel',
      bottomRightPanel: 'builder/bottomRightPanel'
    })
  },
  created() {
    this.$store.dispatch('builder/fetchMaps');
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
    linkSelected() {
      // this.bottomRightPanel = 'table';
    },
    linkSaved() {
      // this.bottomRightPanel = 'linkWizard';
    },
    addLink() {
      this.bottomRightPanel = 'linkWizard';
    },
    editLink() {
      // this.bottomRightPanel = 'table';
    },
    showDeleteLinkConfirmation() {
      this.confirmDeleteArea = true;
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
