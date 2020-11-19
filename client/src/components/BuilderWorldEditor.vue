<template>
  <div class="flex fit world-editor-wrapper">
    <div class="col flex column full-height">
      <div class="col">
        <builder-map
          :map="selectedMap"
          :areas="areas"
          :links="links"
          :mapareahighlights="mapAreaHighlights"
          :maplinkhighlights="mapLinkHighlights"
          :focusarea="focusArea"
          :readonly="view == 'map'"
          @selectArea="mapSelectArea"
        />
      </div>
      <div class="col">
        <map-table v-if="view == 'map'" @select="selectMap" />
        <area-table
          v-if="view == 'area'"
          :selectedrow="areaTableSelectedRow"
          @select="areaTableSelect"
          @create="areaTableCreate"
        />
      </div>
    </div>
    <div v-if="view == 'map'" class="col flex column">
      <q-card v-if="mapView == 'details'" class="col flex column">
        <q-card-section class="col-shrink">
          <div class="text-h6">{{ selectedMap.name }}</div>
        </q-card-section>

        <q-card-section class="col">
          {{ selectedMap.description }}
        </q-card-section>

        <q-separator class="col-1px" dark />

        <q-card-actions class="flex col-shrink">
          <q-btn
            class="col"
            flat
            :disabled="mapDetailsButtonsDisabled"
            @click="buildMap"
            >Build</q-btn
          >
          <q-btn
            class="col"
            flat
            :disabled="mapDetailsButtonsDisabled"
            @click="editMap"
            >Edit</q-btn
          >
          <q-btn
            class="col"
            flat
            :disabled="mapDetailsButtonsDisabled"
            @click="promptForDelete(selectedMap.name, deleteMap)"
            >Delete</q-btn
          >
        </q-card-actions>
      </q-card>
      <div v-if="mapView == 'edit'" class="col">
        <map-wizard
          :map="{ ...selectedMap }"
          @cancel="mapWizardCancel"
          @save="mapWizardSave"
        />
      </div>
    </div>
    <div v-if="view == 'area'" class="col flex column">
      <div class="col">
        <area-details
          v-if="areaView == 'details'"
          :area="{ ...selectedArea }"
          :areas="areas"
          :links="selectedAreaLinks"
        />
        <area-wizard
          v-if="areaView == 'edit'"
          :area="{ ...areaUnderConstruction }"
          :map="{ ...selectedMap }"
          :links="selectedAreaLinks"
          :areas="areas"
          @cancel="areaWizardCancel"
          @save="areaWizardSave"
        />
        <link-wizard
          v-if="areaView == 'link'"
          :area="{ ...selectedArea }"
          :map="{ ...selectedMap }"
          :link="{ ...selectedLink }"
          :maps="maps"
          :areas="areas"
          @cancel="linkWizardCancel"
          @save="linkWizardSave"
        />
      </div>
      <q-btn-group v-if="areaView == 'details'" spread class="col-shrink">
        <q-btn :disabled="areaDetailsButtonsDisabled" flat @click="linkArea"
          >Link</q-btn
        >
        <q-btn :disabled="areaDetailsButtonsDisabled" flat @click="editArea"
          >Edit</q-btn
        >
        <q-btn :disabled="areaDetailsButtonsDisabled" flat @click="cloneArea"
          >Clone</q-btn
        >
        <q-btn
          :disabled="areaDetailsButtonsDisabled"
          flat
          @click="promptForDelete(selectedArea.name, deleteArea)"
          >Delete</q-btn
        >
      </q-btn-group>
    </div>
  </div>
</template>

<style lang="sass">
.half-and-half { height: 50% !important; width: 50% !important; }
</style>

<script lang="ts">
import Vue from 'vue';
import { mapGetters } from 'vuex';

import BuilderMap from '../components/BuilderMap.vue';
import AreaWizard from '../components/AreaWizard.vue';
import AreaTable from '../components/AreaTable.vue';
import MapTable from '../components/MapTable.vue';
import MapWizard from '../components/MapWizard.vue';
import LinkDetails from '../components/LinkDetails.vue';
import LinkWizard from '../components/builder/LinkWizard.vue';
import { MapInterface } from 'src/store/map/state';
import mapState from 'src/store/map/state';
import { AreaInterface } from 'src/store/area/state';
import areaState from 'src/store/area/state';
import linkState, { LinkInterface } from 'src/store/link/state';
import { AxiosResponse } from 'axios';
import AreaDetails from '../components/builder/AreaDetails.vue';

interface CommonColumnInterface {
  name: string;
  required: boolean;
  label: string;
  sortable: boolean;
  align: string;
}

const linkTableColumns = [
  {
    name: 'shortDescription',
    label: 'Short Description',
    field: 'shortDescription',
    sortable: true,
    required: true,
    align: 'left'
  },
  {
    name: 'longDescription',
    label: 'Long Description',
    field: 'longDescription',
    sortable: true,
    required: true,
    align: 'left'
  },
  {
    name: 'departureText',
    label: 'Departure Text',
    field: 'departureText',
    sortable: true,
    required: true,
    align: 'left'
  },
  {
    name: 'arrivalText',
    label: 'Arrival Text',
    field: 'arrivalText',
    sortable: true,
    required: true,
    align: 'left'
  },
  {
    name: 'icon',
    label: 'Icon',
    field: 'icon',
    sortable: false,
    required: true,
    align: 'left'
  },
  {
    name: 'to',
    label: 'To',
    field: 'toId',
    sortable: true,
    required: true,
    align: 'left'
  },
  {
    name: 'from',
    label: 'From',
    field: 'fromId',
    sortable: true,
    required: true,
    align: 'left'
  }
];

const mapTableColumns = [
  {
    name: 'name',
    label: 'Name',
    field: 'name',
    sortable: true,
    required: true,
    align: 'left'
  },
  {
    name: 'description',
    label: 'Description',
    field: 'description',
    sortable: false,
    required: true,
    align: 'left'
  }
];

const areaTableColumns = [
  {
    name: 'name',
    label: 'Name',
    field: 'name',
    sortable: true,
    required: true,
    align: 'left'
  },
  {
    name: 'description',
    label: 'Description',
    field: 'description',
    sortable: false,
    required: true,
    align: 'left'
  }
];

export default {
  name: 'BuilderWorldEditor',
  components: {
    AreaWizard,
    AreaTable,
    BuilderMap,
    LinkDetails,
    LinkWizard,
    MapTable,
    MapWizard,
    AreaDetails
  },
  data(): {
    selectedMap: MapInterface;
    // Area stuff
    areaTableColumns: CommonColumnInterface[];
    areaTableSelectedRow: AreaInterface[];
    selectedArea: AreaInterface;
    areaUnderConstruction: AreaInterface;
    // Link stuff
    selectedLink: LinkInterface;
    linkTableColumns: CommonColumnInterface[];
    linkTableSelectedRow: LinkInterface[];
    // UI stuff
    bottomLeftPanel: string;
    bottomRightPanel: string;
    topRightPanel: string;
    view: string;
    mapView: string;
    areaView: string;
    // Common Table Stuff
    initialPagination: { rowsPerPage: number };
    // Map Table Stuff
    mapTableColumns: CommonColumnInterface[];
    mapTableVisibleColumns: string[];
    mapTableSelectedRow: MapInterface[];
    mapUnderConstruction: MapInterface;
    // Map stuff
    mapAreaHighlights: Record<string, string>;
    mapLinkHighlights: Record<string, string>;
  } {
    return {
      selectedMap: { ...mapState },
      // Area Table stuff
      areaTableColumns,
      areaTableSelectedRow: [],
      selectedArea: { ...areaState },
      areaUnderConstruction: { ...areaState },
      // Link stuff
      selectedLink: { ...linkState },
      linkTableColumns,
      linkTableSelectedRow: [],
      // UI stuff
      bottomLeftPanel: 'mapTable',
      bottomRightPanel: 'areaTable',
      topRightPanel: 'linkTable',
      view: 'map',
      mapView: 'details',
      areaView: 'details',
      // Common Table Stuff
      initialPagination: {
        rowsPerPage: 0
      },
      // Map Table Stuff
      mapTableColumns,
      mapTableVisibleColumns: ['name', 'description'],
      mapTableSelectedRow: [],
      mapUnderConstruction: { ...mapState },
      // Map stuff
      mapAreaHighlights: {},
      mapLinkHighlights: {}
    };
  },
  computed: {
    // Map Stuff
    mapDetailsButtonsDisabled: function(): boolean {
      return this.selectedMap.id == '';
    },
    areaTableButtonsDisabled: function(): boolean {
      return this.selectedArea.id == '';
    },
    selectedAreaLinks: function(): LinkInterface[] {
      if (this.selectedArea.id == '') {
        return [];
      } else {
        return this.links.filter(
          link =>
            link.toId == this.selectedArea.id ||
            link.fromId == this.selectedArea.id
        );
      }
    },
    linkButtonsDisabled(): boolean {
      return this.linkTableSelectedRow.length == 0;
    },
    focusArea: function(): string {
      if (this.selectedArea.id == '') {
        return '';
      } else {
        return this.selectedArea.id;
      }
    },
    mapForm: function(): Record<string, unknown> {
      return {
        schema: [
          {
            id: 'name',
            component: 'QInput',
            label: 'Name',
            required: true
          },
          {
            id: 'description',
            component: 'QInput',
            label: 'Description',
            subLabel: 'A description of the area the map represents.'
          },
          {
            id: 'mapSize',
            component: 'QSlider',
            label: 'Map Size',
            subLabel:
              'The total area available for the map. Impacts zooming behaviour',
            // component props:
            min: 100,
            max: 10000,
            labelAlways: true,
            default: 5000,
            step: 100
          }
        ]
      };
    },
    // Area stuff
    areaDetailsButtonsDisabled: function(): boolean {
      return this.selectedArea.id == '';
    },
    areaNameIndex(): Record<string, string> {
      const index = {};
      this.areas.forEach(area => (index[area.id] = area.name));
      return index;
    },
    // mapsLoaded: function(): boolean {
    //   console.log('mapsLoaded');
    //   if (this.instanceLoaded == true) {
    //     this.$store.dispatch(
    //       'maps/loadForInstance',
    //       this.instanceBeingBuilt.id
    //     );

    //     return true;
    //   } else {
    //     return false;
    //   }
    // },
    ...mapGetters({
      instanceBeingBuilt: 'instances/instanceBeingBuilt',
      maps: 'maps/listAll',
      areas: 'areas/listAll',
      links: 'links/listAll'
    })
  },
  created() {
    this.$store.dispatch('areas/clear');
    this.$store.dispatch('links/clear');
    this.$store.dispatch('maps/loadForInstance', this.instanceBeingBuilt.id);
  },
  methods: {
    // Map stuff
    deleteMap(): void {
      this.$store.dispatch('maps/deleteMap', this.selectedMap.id).then(() => {
        this.selectedMap = { ...mapState };
        this.selectedArea = { ...areaState };
        this.focusArea = '';
        this.mapTableSelectedRow = [];
        this.$store.dispatch('areas/clear');
        this.$store.dispatch('links/clear');
        this.mapLinkHighlights = {};
        this.mapAreaHighlights = {};
        this.mapView = 'details';
      });
    },
    buildMap(): void {
      this.view = 'area';
    },
    editMap(): void {
      this.mapView = 'edit';
    },
    mapWizardCancel(): void {
      this.mapUnderConstruction = { ...this.selectedMap };
      this.mapView = 'details';
    },
    mapWizardSave(map: MapInterface): void {
      this.$store.dispatch('maps/putMap', map);
      this.selectedMap = map;
      this.mapUnderConstruction = { ...mapState };
      this.mapView = 'details';
    },
    selectMap(map: MapInterface): void {
      this.$store
        .dispatch('areas/loadForMap', map.id)
        .then(() => {
          return this.$store.dispatch('links/loadForMap', map.id);
        })
        .then(() => (this.selectedMap = map));
    },
    mapTableGetPaginationLabel(
      start: number,
      end: number,
      total: number
    ): string {
      return total.toString() + ' Map(s)';
    },
    // Area stuff
    areaWizardSave(area: AreaInterface): void {
      this.$store.dispatch('areas/putArea', area);
      this.selectedArea = area;
      this.areaTableSelectedRow = [area];
      this.areaView = 'details';
    },
    areaWizardCancel(): void {
      this.selectedArea = this.areaTableSelectedRow[0];
      this.areaView = 'details';
    },
    linkArea(): void {
      this.selectedArea = this.areaTableSelectedRow[0];
      this.areaView = 'link';
    },
    areaTableSelect(area: AreaInterface): void {
      this.mapSelectArea(area);
    },
    areaDetailsSelectLink(link: LinkInterface): void {
      this.mapLinkHighlights = {};
      this.mapLinkHighlights[link.id] = 'green';
      this.selectedLink = link;
    },
    areaWizardSaveArea(area: AreaInterface): void {
      this.$store.dispatch('areas/putArea', area).then(() => {
        if (area.id != this.selectedArea.id) {
          this.mapLinkHighlights = {};
          this.mapAreaHighlights = {};
          this.mapAreaHighlights[area.id] = 'green';
        }
        this.areaUnderConstruction = { ...areaState };
        this.areaTableSelectedRow = [area];
        this.selectedArea = area;
        this.bottomRightPanel = 'areaTable';
      });
    },
    areaWizardCancelEdit(): void {
      this.bottomRightPanel = 'areaTable';
    },
    mapSelectArea(area: AreaInterface): void {
      if (area.id != this.selectedArea.id) {
        this.mapLinkHighlights = {};
        this.mapAreaHighlights = {};
        this.mapAreaHighlights[area.id] = 'green';
        this.areaTableSelectedRow = [area];
        this.selectedArea = this.areaTableSelectedRow[0];
      }
    },
    areaTableCreate(): void {
      this.selectedArea = { ...areaState };
      this.areaView = 'edit';
    },
    cloneArea(): void {
      this.areaUnderConstruction = { ...this.selectedArea };
      this.areaUnderConstruction.id = '';
      this.areaView = 'edit';
    },
    editArea(): void {
      this.areaUnderConstruction = { ...this.selectedArea };
      this.areaView = 'edit';
    },
    deleteArea(): void {
      this.$store
        .dispatch('areas/deleteArea', this.selectedArea.id)
        .then(() => {
          this.selectedArea = { ...areaState };
          this.areaTableSelectedRow = [];
        });
    },
    // Link stuff
    linkWizardCancel(link: LinkInterface): void {
      this.areaView = 'details';
    },
    linkWizardSave(link: LinkInterface): void {
      this.$store.dispatch('links/putLink', link).then(() => {
        this.areaView = 'details';
      });
    },
    linkTableToggleSingleRow(row: LinkInterface) {
      this.linkTableSelectedRow = [row];
    },
    createLink(): void {
      this.selectedLink = { ...linkState };
      this.topRightPanel = 'linkWizard';
    },
    editLink(): void {
      this.topRightPanel = 'linkWizard';
    },
    deleteLink(): void {
      this.$store
        .dispatch('links/deleteLink', this.selectedLink.id)
        .then(() => {
          this.selectedLink = { ...linkState };
          this.linkTableSelectedRow = [];
        });
    },
    // Common stuff
    promptForDelete(name: string, callback) {
      this.$q
        .dialog({
          title: "Delete '" + name + "'?",
          message: "Type '" + name + "' to continue with deletion.",
          prompt: {
            model: '',
            isValid: val => val == name, // << here is the magic
            type: 'text' // optional
          },
          cancel: true,
          persistent: true
        })
        .onOk(() => {
          callback();
        });
    }
  }
};
</script>
