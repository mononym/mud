<template>
  <div class="build-instance-wrapper flex row col wrap">
    <q-tabs v-model="tab" vertical class="text-teal tab-controller col-50px">
      <q-tab name="world" icon="fas fa-globe" label="World" />
      <q-tab
        name="code"
        icon="fas fa-code"
        label="Code"
        @click="refreshEditor"
      />
    </q-tabs>
    <div class="col fit code-tab flex row" v-show="tab == 'code'">
      <q-tree
        :nodes="luaScripts"
        node-key="label"
        selected-color="primary"
        :selected.sync="selected"
        accordion
        class="col-250px"
      />

      <q-card flat bordered class="col-grow flex column">
        <q-card-section class="q-pa-none col-shrink">
          <div class="text-h6 text-center">{{ selected }}</div>
        </q-card-section>

        <q-separator />

        <q-card-section class="q-pa-none col-grow">
          <codemirror
            ref="codeEditor"
            v-model="code"
            class="fit codeEditor"
            :options="cmOptions"
          />
        </q-card-section>

        <q-separator />

        <q-card-actions align="around" class="action-container col-shrink">
          <q-btn flat class="action-button">Save</q-btn>
          <q-btn flat class="action-button">Cancel</q-btn>
          <q-btn flat class="action-button">Clone</q-btn>
        </q-card-actions>
      </q-card>
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
.build-instance-wrapper > div.tab-controller { height: 100% !important; width: 80px !important }
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
import { mapGetters } from 'vuex';
import { codemirror } from 'vue-codemirror';
import CodeMirror from 'codemirror/lib/codemirror.js';
import 'codemirror/lib/codemirror.css';
import 'codemirror/theme/ambiance.css';
import 'codemirror/mode/lua/lua.js';

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
    codemirror
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
      code: 'print("Hello, Robert(o)!")',
      cmOptions: {
        tabSize: 2,
        mode: 'text/x-lua',
        theme: 'ambiance',
        lineNumbers: true,
        line: true
        // more CodeMirror options...
      },
      selected: 'Food',
      luaScripts: [
        {
          label: 'Commands',
          children: [
            {
              label: 'Food',
              icon: 'restaurant_menu'
            },
            {
              label: 'Room service',
              icon: 'room_service'
            },
            {
              label: 'Room view',
              icon: 'photo'
            }
          ]
        },
        {
          label: 'Scripts',
          children: [
            {
              label: 'Food',
              icon: 'restaurant_menu'
            },
            {
              label: 'Room service',
              icon: 'room_service'
            },
            {
              label: 'Room view',
              icon: 'photo'
            }
          ]
        },
        {
          label: 'Systems',
          children: [
            {
              label: 'Food',
              icon: 'restaurant_menu'
            },
            {
              label: 'Room service',
              icon: 'room_service'
            },
            {
              label: 'Room view',
              icon: 'photo'
            }
          ]
        },
        {
          label: 'Modules',
          children: [
            {
              label: 'Food',
              icon: 'restaurant_menu'
            },
            {
              label: 'Room service',
              icon: 'room_service'
            },
            {
              label: 'Room view',
              icon: 'photo'
            }
          ]
        }
      ]
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
    let self = this;

    this.$axios.get('/lua_scripts').then(function(results) {
      self.luaScripts = [
        {
          label: 'Commands',
          children: results.data.Commands.map(function(cmd) {
            return {
              label: cmd.name,
              icon: 'fas fa-code'
            };
          })
        },
        {
          label: 'Scripts',
          children: results.data.Scripts.map(function(cmd) {
            return {
              label: cmd.name,
              icon: 'fas fa-code'
            };
          })
        },
        {
          label: 'Systems',
          children: results.data.Systems.map(function(cmd) {
            return {
              label: cmd.name,
              icon: 'fas fa-code'
            };
          })
        },
        {
          label: 'Modules',
          children: results.data.Modules.map(function(cmd) {
            return {
              label: cmd.name,
              icon: 'fas fa-code'
            };
          })
        }
      ];
    });
  },
  mounted() {
    this.codeEditor = this.$refs.codeEditor.codemirror;
  },
  methods: {
    refreshEditor() {
      setTimeout(() => {
        this.codeEditor.refresh();
      }, 10);
    },
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
    }
  }
};
</script>
