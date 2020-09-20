<template>
  <div class="q-pa-none fit">
    <q-table
      title="Links"
      :data="normalizedLinks"
      :columns="linkTableColumns"
      row-key="id"
      flat
      bordered
      dense
      class="fit sticky-header-table"
      :selected.sync="selectedRow"
      selection="single"
      :pagination="initialPagination"
      virtual-scroll
      :rows-per-page-options="[0]"
      :pagination-label="getPaginationLabel"
    >
      <template v-slot:top>
        <q-space />
        <q-input
          v-model="linkTableFilter"
          borderless
          dense
          debounce="300"
          color="primary"
        >
          <template v-slot:append>
            <q-icon name="search" />
          </template>
        </q-input>
      </template>

      <template v-slot:header="props">
        <q-tr :props="props">
          <q-th v-for="col in props.cols" :key="col.name" :props="props">
            {{ col.label }}
          </q-th>
        </q-tr>
      </template>

      <template v-slot:body="props">
        <q-tr
          class="cursor-pointer"
          :props="props"
          @click.exact="toggleSingleRow(props.row)"
        >
          <q-td
            v-for="col in props.cols"
            :key="col.name"
            class="link-table-row"
            :props="props"
          >
            <span v-if="col.name === 'actions'">
              <q-btn-group flat spread>
                <q-btn
                  flat
                  label="Edit"
                  icon="fas fa-pencil"
                  @click.stop="editLink(props.row)"
                />
                <q-btn
                  flat
                  label="Clone"
                  icon="fas fa-pencil"
                  @click="cloneLink(props.row)"
                />
                <q-btn
                  flat
                  label="Delete"
                  icon="fas fa-trash"
                  @click="deleteLink"
                />
              </q-btn-group>
            </span>

            <span v-else-if="col.name === 'icon'">
              <q-icon :name="props.row.icon" />
            </span>

            <span v-else>
              {{ col.value }}
            </span>
          </q-td>
        </q-tr>
      </template>
    </q-table>
  </div>
</template>

<script lang="ts">
import { mapGetters } from 'vuex';
import linkState from '../store/link/state';
import { LinkInterface } from 'src/store/link/state';
import { AreaInterface } from 'src/store/area/state';
import Vue from 'vue';

const linkTableColumns = [
  { name: 'actions', label: 'Actions', field: 'actions', sortable: false },
  {
    name: 'shortDescription',
    label: 'Short Description',
    field: 'shortDescription',
    sortable: true
  },
  {
    name: 'longDescription',
    label: 'Long Description',
    field: 'longDescription',
    sortable: true
  },
  {
    name: 'departureText',
    label: 'Departure Text',
    field: 'departureText',
    sortable: true
  },
  {
    name: 'arrivalText',
    label: 'Arrival Text',
    field: 'arrivalText',
    sortable: true
  },
  { name: 'icon', label: 'Icon', field: 'icon', sortable: false },
  { name: 'to', label: 'To', field: 'toName', sortable: true },
  { name: 'from', label: 'From', field: 'fromName', sortable: true }
];

export default Vue.extend({
  name: 'LinkTable',
  components: {},
  data() {
    return {
      linkTableColumns,
      linkTableFilter: '',
      selectedRow: new Array<LinkInterface>(),
      initialPagination: {
        rowsPerPage: 0
      }
    };
  },
  computed: {
    buttonsDisabled: function(): boolean {
      return !this.isLinkSelected;
    },
    workingLinkId: function(): string {
      return this.workingLink.id;
    },
    normalizedLinks: function(): Record<string, unknown>[] {
      const areaIndex: Record<string, number> = {};

      this.areas.forEach((area: AreaInterface, index: number) => {
        areaIndex[area.id] = index;
      });

      const areas = this.areas;

      const links = this.links.map((link: Record<string, string>) => {
        link.toName = areas[areaIndex[link.toId]].name;
        link.fromName = areas[areaIndex[link.fromId]].name;

        return link;
      });

      return links;
    },
    ...mapGetters({
      links: 'builder/workingAreaLinks',
      workingLink: 'builder/workingLink',
      areas: 'builder/areas',
      isLinkSelected: 'builder/isLinkSelected'
    })
  },
  methods: {
    getPaginationLabel(start: number, end: number, total: number) {
      return total.toString() + ' Links';
    },
    addLink() {
      const newLink = { ...linkState };
      void this.$store.dispatch('builder/putIsLinkUnderConstructionNew', true);
      void this.$store.dispatch('builder/putIsLinkUnderConstruction', true);
      void this.$store.dispatch('builder/putLinkUnderConstruction', newLink);
    },
    editLink(link: LinkInterface) {
      void this.$store.dispatch('builder/startEditingLink', link);
      const selectedRow: LinkInterface[] = [];
      selectedRow.push(link);
      this.selectedRow = selectedRow;
    },
    cloneLink(link: LinkInterface) {
      void this.$store.dispatch('builder/putIsLinkUnderConstructionNew', true);
      void this.$store.dispatch('builder/putIsLinkUnderConstruction', true);
      void this.$store.dispatch('builder/putLinkUnderConstruction', {
        ...link
      });
    },
    toggleSingleRow(row: LinkInterface) {
      const selectedRow: LinkInterface[] = [];
      selectedRow.push(row);
      this.selectedRow = selectedRow;
      void this.$store.dispatch('builder/selectLink', row).then(() => {
        void this.$store.dispatch('builder/putBottomRightPanel', 'linkDetails');
      });
    },
    deleteLink() {
      this.$emit('deleteLink');
    }
  }
});
</script>

<style lang="sass">
.q-table td, .q-table th {  white-space: normal !important; }

td.link-table-cell {  border-bottom-width: 1 !important; }

.link-table-wrapper {  max-height: 100% }

.sticky-header-table
  /* height or max-height is important */
  max-height: 100%

  .q-table__top,
  .q-table__bottom,
  thead tr:first-child th
    /* bg color is important for th; just specify one */
    background-color: #1D1D1D

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
