<template>
  <div class="build-instance-wrapper flex row col wrap">
    <q-tabs v-model="tab" vertical class="text-teal tab-controller">
      <q-tab name="world" icon="fas fa-globe" label="World" />
      <q-tab name="code" icon="fas fa-code" label="Code" />
      <q-tab name="races" icon="fas fa-users" label="Races" />
      <q-tab name="commands" icon="fas fa-terminal" label="Commands" />
      <q-tab name="templates" icon="fas fa-file-alt" label="Templates" />
    </q-tabs>
    <div class="col fit code-tab" v-show="tab == 'code'">
      <builder-code-editor />
    </div>

    <div class="col fit world-tab flex row wrap" v-show="tab == 'world'">
      <builder-map />

      <area-details
        @editArea="editArea"
        @deleteLink="showDeleteLinkConfirmation"
      />

      <map-table
        v-show="bottomLeftPanel == 'mapTable'"
        @saved="mapSaved"
        @selected="mapSelected"
        @editMap="editMap"
        @addMap="addMap"
      />

      <map-wizard
        v-show="bottomLeftPanel == 'mapWizard'"
        @saved="mapSaved"
        @canceled="cancelMapEdit"
      />

      <area-table
        v-show="bottomRightPanel == 'areaTable'"
        @saved="areaSaved"
        @selected="areaSelected"
        @editArea="editArea"
        @addArea="addArea"
        @deleteArea="showDeleteAreaConfirmation"
      />

      <area-wizard
        v-show="bottomRightPanel == 'areaWizard'"
        @saved="areaSaved"
        @deleteArea="showDeleteAreaConfirmation"
        @canceled="cancelAreaEdit"
      />

      <link-details
        v-show="bottomRightPanel == 'linkDetails'"
        @saved="linkSaved"
        @editLink="editLink"
        @addLink="addLink"
        @deleteLink="showDeleteLinkConfirmation"
      />

      <link-wizard v-show="bottomRightPanel == 'linkWizard'" />
    </div>

    <q-dialog v-model="confirmDeleteArea" persistent>
      <q-card>
        <q-card-section class="row items-center">
          <q-avatar icon="fas fa-trash" color="primary" text-color="white" />
          <span class="q-ml-sm"
            >Confirm deletion of area: {{ selectedArea.name }}</span
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

    <q-dialog v-model="confirmDeleteLink" persistent>
      <q-card>
        <q-card-section class="row items-center">
          <q-avatar icon="fas fa-trash" color="primary" text-color="white" />
          <span class="q-ml-sm"
            >Confirm deletion of link: {{ selectedLink.name }}</span
          >
        </q-card-section>

        <q-card-actions align="right">
          <q-btn
            v-close-popup
            flat
            label="Delete"
            color="primary"
            @click="deleteLink"
          />
          <q-btn v-close-popup flat label="Cancel" color="primary" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<style lang="sass">
.build-instance-wrapper > div.tab-controller { height: 100% !important; width: 100px !important }
.build-instance-wrapper > .world-tab > div { height: 50% !important; width: 50% !important; }
.CodeMirror { height: 100% !important; width: 100% !important }
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
import BuilderCodeEditor from '../components/BuilderCodeEditor.vue';
import Vue from 'vue';
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
    LinkWizard,
    BuilderCodeEditor
  },
  data() {
    return {
      codeEditor: undefined,
      loading: false,
      areaSplitterModel: 50,
      mapSplitterModel: 50,
      splitterModel: 50,
      confirmDeleteArea: false,
      confirmDeleteLink: false,
      tab: 'world',
      code: '',
      cmOptions: {
        tabSize: 2,
        mode: 'text/x-lua',
        theme: 'ambiance',
        lineNumbers: true,
        line: true
        // more CodeMirror options...
      },
      selected: 'Food',
      luaScripts: [],
      groupedLuaScripts: [],
      luaScriptIndex: {},
      headers: ['Commands', 'Scripts', 'Modules', 'Systems']
    };
  },
  computed: {
    ...mapGetters({
      selectedArea: 'builder/selectedArea',
      selectedMap: 'builder/selectedMap',
      selectedLink: 'builder/selectedLink',
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
    deleteLink() {
      this.$store.dispatch('builder/deleteLink');
    },
    showDeleteLinkConfirmation() {
      this.confirmDeleteLink = true;
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
    },
    selectLuaScript(newScript) {
      console.log(newScript);
      this.code = this.luaScripts[this.luaScriptIndex[newScript]].code;
    }
  }
};
</script>
