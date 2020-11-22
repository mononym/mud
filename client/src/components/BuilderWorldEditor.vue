<template>
  <div class="flex fit world-editor-wrapper">
    <div class="col flex column full-height">
      <div class="col">
        <builder-map
          :map="{ ...selectedMap }"
          :areas="areas"
          :links="links"
          :mapareahighlights="mapAreaHighlights"
          :maplinkhighlights="mapLinkHighlights"
          :maplinkpreviewarea="mapLinkPreviewArea"
          :mapareapreview="{ ...areaUnderConstruction }"
          :maplabelpreview="{ ...labelUnderConstruction }"
          :showmapareapreview="showMapAreaPreview"
          :focusarea="focusArea"
          :readonly="view == 'map' || areaView != 'details'"
          @selectArea="mapSelectArea"
        />
      </div>
      <div class="col">
        <map-table v-show="view == 'map'" @select="selectMap" />
        <area-table
          v-if="view == 'area'"
          :selectedrow="areaTableSelectedRow"
          @select="areaTableSelect"
          @create="areaTableCreate"
        />
      </div>
    </div>
    <div v-if="view == 'map'" class="col flex column">
      <div v-if="mapView == 'details'" class="col">
        <map-details
          :map="{ ...selectedMap }"
          @createLabel="mapDetailsCreateLabel"
          @editLabel="mapDetailsEditLabel"
          @deleteLabel="mapDetailsDeleteLabel"
          @highlightLabel="mapDetailsHighlightLabel"
        />
      </div>

      <div v-if="mapView != 'details'" class="col">
        <map-wizard
          v-if="mapView == 'edit'"
          :map="{ ...mapUnderConstruction }"
          @cancel="mapWizardCancel"
          @save="mapWizardSave"
        />
        <label-wizard
          v-if="mapView == 'label'"
          :label="{ ...labelUnderConstruction }"
          @cancel="labelWizardCancel"
          @save="labelWizardSave"
          @preview="labelWizardPreview"
        />
      </div>

      <q-btn-group v-if="mapView == 'details'" spread class="col-shrink">
        <q-btn flat @click="createMap">Create</q-btn>
        <q-btn :disabled="mapDetailsButtonsDisabled" flat @click="buildMap"
          >Build</q-btn
        >
        <q-btn :disabled="mapDetailsButtonsDisabled" flat @click="editMap"
          >Edit</q-btn
        >
        <q-btn
          :disabled="mapDetailsButtonsDisabled"
          flat
          @click="promptForDelete(selectedMap.name, deleteMap)"
          >Delete</q-btn
        >
      </q-btn-group>
    </div>
    <div v-if="view == 'area'" class="col flex column">
      <div class="col">
        <area-details
          v-show="areaView == 'details'"
          :area="{ ...selectedArea }"
          :areas="areas"
          :links="selectedAreaLinks"
          @editLink="areaDetailsEditLink"
          @deleteLink="areaDetailsDeleteLink"
          @highlightLink="areaDetailsHighlightLink"
        />
        <area-wizard
          v-if="areaView == 'edit'"
          :area="{ ...areaUnderConstruction }"
          :map="{ ...selectedMap }"
          @cancel="areaWizardCancel"
          @save="areaWizardSave"
          @preview="areaWizardPreview"
        />
        <link-wizard
          v-if="areaView == 'link'"
          :area="{ ...selectedArea }"
          :otherarea="{ ...linkWizardOtherArea }"
          :map="{ ...selectedMap }"
          :link="{ ...linkUnderConstruction }"
          :maps="maps"
          :areas="areas"
          @cancel="linkWizardCancel"
          @save="linkWizardSave"
          @preview="linkWizardPreview"
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
    <q-page-sticky
      v-show="view == 'area'"
      position="top-left"
      :offset="[110, 10]"
    >
      <q-btn fab icon="fas fa-reply" color="primary" @click="backToMapView" />
    </q-page-sticky>
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
import MapDetails from '../components/builder/MapDetails.vue';
import LinkWizard from '../components/builder/LinkWizard.vue';
import LabelWizard from '../components/builder/LabelWizard.vue';
import { LabelState, LabelInterface, MapInterface } from 'src/store/map/state';
import mapState from 'src/store/map/state';
import { AreaInterface } from 'src/store/area/state';
import areaState from 'src/store/area/state';
import linkState, { LinkInterface } from 'src/store/link/state';
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
    LinkWizard,
    MapTable,
    MapWizard,
    AreaDetails,
    MapDetails,
    LabelWizard
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
    linkUnderConstruction: LinkInterface;
    linkTableColumns: CommonColumnInterface[];
    linkTableSelectedRow: LinkInterface[];
    linkingAreas: boolean;
    linkWizardOtherArea: AreaInterface;
    creatingNewLink: boolean;
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
    mapLinkPreviewArea: string;
    showMapAreaPreview: boolean;
    // Map stuff
    labelUnderConstruction: LabelInterface;
    mapAreaHighlights: Record<string, string>;
    mapLinkHighlights: Record<string, string>;
    selectedLabel: string;
  } {
    return {
      selectedMap: { ...mapState },
      // Area Table stuff
      areaTableColumns,
      areaTableSelectedRow: [],
      selectedArea: { ...areaState },
      areaUnderConstruction: { ...areaState },
      labelUnderConstruction: { ...LabelState },
      // Link stuff
      selectedLink: { ...linkState },
      linkTableColumns,
      linkTableSelectedRow: [],
      linkingAreas: false,
      linkWizardOtherArea: { ...areaState },
      creatingNewLink: false,
      linkUnderConstruction: { ...linkState },
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
      showMapAreaPreview: false,
      // Map stuff
      mapAreaHighlights: {},
      mapLinkHighlights: {},
      mapLinkPreviewArea: '',
      selectedLabel: ''
    };
  },
  computed: {
    // Map Stuff
    mapDetailsButtonsDisabled: function(): boolean {
      return this.selectedMap.id == '';
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
    focusArea: function(): string {
      if (this.selectedArea.id == '') {
        return '';
      } else {
        return this.selectedArea.id;
      }
    },
    // Area stuff
    areaDetailsButtonsDisabled: function(): boolean {
      return this.selectedArea.id == '';
    },
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
    labelWizardPreview(label: LabelInterface): void {
      console.log('preview');
      if (label.id == '') {
        label.id = 'preview';
      }

      this.labelUnderConstruction = { ...label };
    },
    labelWizardCancel(): void {
      this.labelUnderConstruction = { ...LabelState };
      this.mapView = 'details';
    },
    mapDetailsCreateLabel(): void {
      this.labelUnderConstruction = { ...LabelState };
      this.mapView = 'label';
    },
    mapDetailsEditLabel(label: LabelInterface): void {
      this.labelUnderConstruction = { ...label };
      this.mapView = 'label';
    },
    labelWizardSave(label: LabelInterface): void {
      const map: MapInterface = { ...this.selectedMap };

      const params = {
        id: map.id,
        description: map.description,
        name: map.name,
        viewSize: map.viewSize,
        gridSize: map.gridSize,
        labels: map.labels.filter(lab => lab.id != label.id)
      };

      params.labels.push(label);

      this.saveMap(params);
      this.selectedMap = params;
      this.labelUnderConstruction = { ...LabelState };
      this.mapView = 'details';
    },
    mapDetailsDeleteLabel(labelId: string): void {
      this.selectedMap.labels = this.selectedMap.labels.filter(function(label) {
        return label.id != labelId;
      });

      this.saveMap(this.selectedMap);
    },
    mapDetailsHighlightLabel(labelId: string): void {
      this.selectedLabel = labelId;
    },
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
    createMap(): void {
      this.selectedMap = { ...mapState };
      this.mapUnderConstruction = { ...this.selectedMap };
      this.mapUnderConstruction.instanceId = this.instanceBeingBuilt.id;
      this.mapView = 'edit';
    },
    buildMap(): void {
      this.view = 'area';
    },
    editMap(): void {
      this.mapUnderConstruction = { ...this.selectedMap };
      this.mapView = 'edit';
    },
    mapWizardCancel(): void {
      this.mapUnderConstruction = { ...mapState };
      this.mapView = 'details';
    },
    mapWizardSave(map: MapInterface): void {
      this.saveMap(map);
      this.selectedMap = { ...map };
      this.mapUnderConstruction = { ...mapState };
      this.mapView = 'details';
    },
    saveMap(map: MapInterface): void {
      const params = {
        map: {
          id: map.id,
          name: map.name,
          description: map.description,
          view_size: map.viewSize,
          grid_size: map.gridSize,
          labels: map.labels
        }
      };

      let request;
      let id: string = map.id;

      if (map.id == '') {
        request = this.$axios.post('/maps', params);
      } else {
        request = this.$axios.patch('/maps/' + id, params);
      }

      request
        .then(result => {
          this.$store.dispatch('maps/putMap', result.data);
        })
        .catch(function() {
          alert('Error saving');
        });
    },
    selectMap(map: MapInterface): void {
      this.mapLinkHighlights = {};
      this.mapAreaHighlights = {};
      this.$store
        .dispatch('areas/loadForMap', map.id)
        .then(() => {
          return this.$store.dispatch('links/loadForMap', map.id);
        })
        .then(() => (this.selectedMap = { ...map }));
    },
    backToMapView(): void {
      this.mapLinkPreviewArea = '';
      this.mapLinkHighlights = {};
      this.mapAreaHighlights = {};
      this.areaTableSelectedRow = [];
      this.selectedArea = { ...areaState };
      this.areaUnderConstruction = { ...areaState };
      this.selectedLink = { ...linkState };
      this.linkTableSelectedRow = [];
      this.showMapAreaPreview = false;
      this.areaView = 'details';
      this.view = 'map';
    },
    // Area stuff
    areaWizardCancel(): void {
      this.showMapAreaPreview = false;
      this.selectedArea = this.areaTableSelectedRow[0];
      this.areaUnderConstruction = { ...areaState };
      this.areaView = 'details';
    },
    linkArea(): void {
      this.mapLinkHighlights = {};
      this.selectedArea = this.areaTableSelectedRow[0];
      this.areaView = 'link';
    },
    areaTableSelect(area: AreaInterface): void {
      this.mapLinkHighlights = {};
      this.mapSelectArea(area);
    },
    areaDetailsEditLink(link: LinkInterface): void {
      this.linkUnderConstruction = link;
      this.areaView = 'link';
    },
    areaWizardSave(area: AreaInterface): void {
      this.$store.dispatch('areas/putArea', area).then(() => {
        if (area.id != this.selectedArea.id) {
          this.mapLinkHighlights = {};
          this.mapAreaHighlights = {};
          this.mapAreaHighlights[area.id] = 'green';
        }
        this.showMapAreaPreview = false;
        this.areaUnderConstruction = { ...areaState };
        this.areaTableSelectedRow = [area];
        this.selectedArea = area;
        this.areaView = 'details';
      });
    },
    mapSelectArea(area: AreaInterface): void {
      if (
        area.id != this.selectedArea.id &&
        this.mapLinkPreviewArea == '' &&
        !this.creatingNewLink
      ) {
        this.mapLinkHighlights = {};
        this.mapAreaHighlights = {};
        this.mapAreaHighlights[area.id] = 'green';
        this.areaTableSelectedRow = [area];
        this.selectedArea = this.areaTableSelectedRow[0];
      } else if (this.mapLinkPreviewArea != '' || this.creatingNewLink) {
        this.linkWizardOtherArea = area;
        this.mapLinkPreviewArea = area.id;
      }
    },
    areaTableCreate(): void {
      this.mapLinkHighlights = {};
      this.mapAreaHighlights = {};
      this.areaTableSelectedRow = [];
      this.selectedArea = { ...areaState };
      this.areaUnderConstruction = { ...areaState };
      this.areaUnderConstruction.instanceId = this.instanceBeingBuilt.id;
      this.showMapAreaPreview = true;
      this.areaView = 'edit';
    },
    areaWizardPreview(area: AreaInterface): void {
      this.areaUnderConstruction = area;
    },
    cloneArea(): void {
      this.mapAreaHighlights = {};
      this.areaTableSelectedRow = [];
      this.areaUnderConstruction = { ...this.selectedArea };
      this.areaUnderConstruction.id = '';
      this.selectedArea = { ...areaState };
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
    areaDetailsDeleteLink(link: LinkInterface): void {
      this.$store.dispatch('links/deleteLink', link.id);
    },
    areaDetailsHighlightLink(linkId: string): void {
      this.mapLinkHighlights = {};
      this.mapLinkHighlights[linkId] = 'green';
    },
    // Link stuff
    linkWizardPreview(areaId: string): void {
      this.mapLinkPreviewArea = areaId;
    },
    linkWizardCancel(): void {
      this.linkUnderConstruction = { ...linkState };
      this.mapLinkPreviewArea = '';
      this.creatingNewLink = false;
      this.areaView = 'details';
    },
    linkWizardSave(link: LinkInterface): void {
      this.$store.dispatch('links/putLink', link).then(() => {
        this.mapLinkPreviewArea = '';
        this.creatingNewLink = false;
        this.linkUnderConstruction = { ...linkState };
        this.areaView = 'details';
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
