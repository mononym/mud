<template>
  <div class="flex row wrap fit world-editor-wrapper">
    <builder-map
      :map="selectedMap"
      :areas="areas"
      :links="links"
      :mapareahighlights="mapAreaHighlights"
      :maplinkhighlights="mapLinkHighlights"
      :focusarea="focusArea"
      @selectArea="mapSelectArea"
    />

    <area-details
      :area="selectedArea"
      :areas="areas"
      :links="selectedAreaLinks"
      @selectLink="areaDetailsSelectLink"
      @editArea="areaDetailsEditArea"
    />

    <map-table v-if="bottomLeftPanel == 'mapTable'" @select="selectMap" />

    <map-wizard v-if="bottomLeftPanel == 'mapWizard'" />

    <div v-if="bottomRightPanel == 'areaTable'" class="flex column">
      <q-table
        title="Areas"
        :data="areas"
        :columns="areaTableColumns"
        row-key="id"
        flat
        bordered
        class="col"
        :selected.sync="areaTableSelectedRow"
        selection="single"
        :pagination="initialPagination"
        virtual-scroll
      >
        <template v-slot:body-cell="props">
          <q-td
            :props="props"
            class="cursor-pointer"
            @click.exact="areaTableToggleSingleRow(props.row)"
          >
            {{ props.value }}
          </q-td>
        </template>
      </q-table>
      <q-btn-group spread class="col-shrink">
        <q-btn class="" flat @click="createArea">Create</q-btn>
        <q-btn
          :disabled="areaTableButtonsDisabled"
          class=""
          flat
          @click="editArea"
          >Edit</q-btn
        >
        <q-btn
          :disabled="areaTableButtonsDisabled"
          class=""
          flat
          @click="promptForDelete(selectedArea.name, deleteArea)"
          >Delete</q-btn
        >
      </q-btn-group>
    </div>

    <area-wizard
      v-if="bottomRightPanel == 'areaWizard'"
      :area="{ ...selectedArea }"
      :map="selectedMap"
      @saved="areaWizardSaveArea"
      @cancel="areaWizardCancelEdit"
    />

    <link-details v-if="bottomRightPanel == 'linkDetails'" />

    <link-wizard v-if="bottomRightPanel == 'linkWizard'" />
  </div>
</template>

<style lang="sass">
.world-editor-wrapper > div { height: 50% !important; width: 50% !important; }
</style>

<script lang="ts">
import Vue from 'vue';
import { mapGetters } from 'vuex';

import BuilderMap from '../components/BuilderMap.vue';
import AreaWizard from '../components/AreaWizard.vue';
import MapWizard from '../components/MapWizard.vue';
import MapTable from '../components/MapTable.vue';
import AreaDetails from '../components/AreaDetails.vue';
import LinkDetails from '../components/LinkDetails.vue';
import LinkWizard from '../components/LinkWizard.vue';
import { MapInterface } from 'src/store/map/state';
import mapState from 'src/store/map/state';
import { AreaInterface } from 'src/store/area/state';
import areaState from 'src/store/area/state';
import linkState, { LinkInterface } from 'src/store/link/state';

interface CommonColumnInterface {
  name: string;
  required: boolean;
  label: string;
  sortable: boolean;
  align: string;
}

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
    AreaDetails,
    AreaWizard,
    MapWizard,
    BuilderMap,
    LinkDetails,
    LinkWizard,
    MapTable
  },
  data(): {
    selectedMap: MapInterface;
    // Area stuff
    areaTableColumns: CommonColumnInterface[];
    areaTableSelectedRow: AreaInterface[];
    selectedArea: AreaInterface;
    // Link stuff
    selectedLink: LinkInterface;
    // UI stuff
    bottomLeftPanel: string;
    bottomRightPanel: string;
    // Common Table Stuff
    initialPagination: { rowsPerPage: number };
    // Map Table Stuff
    mapTableColumns: CommonColumnInterface[];
    mapTableVisibleColumns: string[];
    mapTableSelectedRow: MapInterface[];
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
      // Link stuff
      selectedLink: { ...linkState },
      // UI stuff
      bottomLeftPanel: 'mapTable',
      bottomRightPanel: 'areaTable',
      // Common Table Stuff
      initialPagination: {
        rowsPerPage: 0
      },
      // Map Table Stuff
      mapTableColumns,
      mapTableVisibleColumns: ['name', 'description'],
      mapTableSelectedRow: [],
      // Map stuff
      mapAreaHighlights: {},
      mapLinkHighlights: {}
    };
  },
  computed: {
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
    areaTableButtonsDisabled: function(): boolean {
      return this.selectedArea.id == '';
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
    this.$store.dispatch('maps/loadForInstance', this.instanceBeingBuilt.id);
  },
  methods: {
    // Map stuff
    editMap(): void {
      this.bottomRightPanel = 'areaTable';

      this.bottomLeftPanel = 'wizard';
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
    areaDetailsSelectLink(link: LinkInterface): void {
      this.mapLinkHighlights = {};
      this.mapLinkHighlights[link.id] = 'green';
    },
    areaTableSelectArea(area: AreaInterface): void {
      this.mapSelectArea(area);
    },
    areaDetailsEditArea(): void {
      this.bottomRightPanel = 'areaWizard';
    },
    areaWizardSaveArea(area: AreaInterface): void {
      this.$store.dispatch('areas/putArea', area).then(() => {
        if (area.id != this.selectedArea.id) {
          this.mapLinkHighlights = {};
          this.mapAreaHighlights = {};
          this.mapAreaHighlights[area.id] = 'green';
        }
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
        this.areaTableSelectedRow = this.areas.filter(ar => ar.id == area.id);
        this.selectedArea = this.areaTableSelectedRow[0];
      }
    },
    createArea(): void {
      this.selectedArea = { ...areaState };
      this.bottomRightPanel = 'areaWizard';
    },
    editArea(): void {
      this.$store
        .dispatch('builder/putIsAreaUnderConstruction', true)
        .then(() => (this.bottomRightPanel = 'areaWizard'));
    },
    deleteArea(): void {
      this.$store
        .dispatch('areas/deleteArea', this.selectedArea.id)
        .then(() => {
          this.selectedArea = { ...areaState };
          this.areaTableSelectedRow = [];
        });
    },
    areaTableToggleSingleRow(row: AreaInterface) {
      this.areaTableSelectedRow = [row];
      this.areaTableSelectArea(row);
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
