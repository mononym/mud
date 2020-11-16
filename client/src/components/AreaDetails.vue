<template>
  <q-card class="fit flex column" flat bordered>
    <q-card-section class="col-shrink q-pb-none">
      <p class="text-h6 text-center">
        {{ area.name }}
      </p>
    </q-card-section>

    <q-card-section class="q-pa-none col-auto">
      <q-tabs v-model="tab" class="text-teal" dense align="justify">
        <q-tab name="description" label="Description" />
        <q-tab name="links" label="Links" />
      </q-tabs>
    </q-card-section>

    <q-card-section class="q-pa-none col">
      <p v-show="tab == 'description'" class="q-pa-sm">
        {{ area.description }}
      </p>
      <div
        v-show="tab == 'links'" class="fit flex column"
      >
      <q-table
        title="Links"
        :data="links"
        :columns="linkTableColumns"
        row-key="id"
        flat
        bordered
        class="col"
        :selected.sync="linkTableSelectedRow"
        selection="single"
        :pagination="initialPagination"
        virtual-scroll
      >
        <template v-slot:body-cell="props">
          <q-td
            :props="props"
            class="cursor-pointer"
            @click.exact="linkTableToggleSingleRow(props.row)"
          >
            {{ props.value }}
          </q-td>
        </template>
        <template v-slot:body-cell-to="props">
          <q-td
            :props="props"
            class="cursor-pointer"
            @click.exact="linkTableToggleSingleRow(props.row)"
          >
            <span v-if="areaNameIndex[props.value] != undefined">{{
              areaNameIndex[props.value]
            }}</span>
            <q-icon v-else name="fas fa-exclamation-triangle" class="text-red" />
          </q-td>
        </template>
        <template v-slot:body-cell-from="props">
          <q-td
            :props="props"
            class="cursor-pointer"
            @click.exact="linkTableToggleSingleRow(props.row)"
          >
            <span v-if="areaNameIndex[props.value] != undefined">{{
              areaNameIndex[props.value]
            }}</span>
            <q-icon v-else name="fas fa-exclamation-triangle" class="text-red" />
          </q-td>
        </template>
      </q-table>
      <q-btn-group spread class="col-shrink">
        <q-btn class="" flat @click="createLink">Create</q-btn>
        <q-btn
          :disabled="linkButtonsDisabled"
          class=""
          flat
          @click="editLink"
          >Edit</q-btn
        >
        <q-btn
          :disabled="linkButtonsDisabled"
          class=""
          flat
          @click="promptForDelete(selectedArea.name, deleteLink)"
          >Delete</q-btn
        >
      </q-btn-group>
      </div>
    </q-card-section>
  </q-card>
</template>

<script lang="ts">
import { mapGetters } from 'vuex';
import defaultArea, { AreaInterface } from '../store/area/state';
import areaState from '../store/area/state';
import { Prop } from 'vue/types/options';
import { LinkInterface } from 'src/store/link/state';

const linkTableColumns = [
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
  { name: 'to', label: 'To', field: 'toId', sortable: true },
  { name: 'from', label: 'From', field: 'fromId', sortable: true }
];

interface CommonColumnInterface {
  name: string;
  required: boolean;
  label: string;
  sortable: boolean;
  align: string;
}

export default {
  name: 'AreaDetails',
  components: {},
  props: {
    area: {
      type: Object as Prop<AreaInterface>,
      required: true
    },
    links: <PropOptions<LinkInterface[]>>{
      type: Array,
      required: true,
      default: () => []
    },
    areas: <PropOptions<AreaInterface[]>>{
      type: Array,
      required: true,
      default: () => []
    }
  },
  data() {
    return {
      linkTableColumns,
      linkTableSelectedRow: [],
      selectedArea: defaultArea,
      confirmDelete: false,
      tab: 'description',
      link: null,
      initialPagination: {
        rowsPerPage: 0
      }
    };
  },
  computed: {
    areaNameIndex(): Record<string, string> {
      const index = {};
      this.areas.forEach(area => (index[area.id] = area.name));
      return index;
    },
    linkButtonsDisabled(): boolean {
      return this.linkTableSelectedRow.length == 0
    },
    ...mapGetters({
      selectedLink: 'builder/selectedLink',
      isLinkSelected: 'builder/isLinkSelected'
    })
  },
  methods: {
    linkTableToggleSingleRow(row: LinkInterface) {
      this.linkTableSelectedRow = [row];
      this.$emit('selectLink', row);
    },
    createLink() {
      this.$emit('deleteLink');
    },
    deleteLink() {
      this.$emit('deleteLink');
    },
    editLink() {
      this.$emit('deleteLink');
    },
    linkTableGetPaginationLabel(
      start: number,
      end: number,
      total: number
    ): string {
      return total.toString() + ' Link(s)';
    }
  }
};
</script>

<style lang="sass"></style>
