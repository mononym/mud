<template>
  <q-card v-show="area.id != ''" class="fit flex column" flat bordered>
    <q-card-section class="col-shrink q-pb-none">
      <p class="text-h6 text-center">
        {{ area.name }}
      </p>
    </q-card-section>

    <q-card-section class="q-pa-none col-auto">
      {{ area.description }}
    </q-card-section>

    <q-card-section class="q-pa-none col-auto flex">
      <div class="col">
        <q-toolbar class="bg-primary text-white shadow-2">
          <q-toolbar-title>Incoming Links</q-toolbar-title>
        </q-toolbar>
        <q-list bordered separator>
          <q-item v-for="link in incomingLinks" :key="link.id">
            <q-item-section avatar>
              <q-icon color="primary" :name="link.icon" />
            </q-item-section>

            <q-item-section>{{ link.arrivalText }}</q-item-section>
          </q-item>
        </q-list>
      </div>
      <div class="col">
        <q-toolbar class="bg-primary text-white shadow-2">
          <q-toolbar-title>Outgoing Links</q-toolbar-title>
        </q-toolbar>
        <q-list bordered separator>
          <q-item v-for="link in outgoingLinks" :key="link.id">
            <q-item-section avatar>
              <q-icon color="primary" :name="link.icon" />
            </q-item-section>

            <q-item-section>{{ link.shortDescription }}</q-item-section>
          </q-item>
        </q-list>
      </div>
    </q-card-section>
  </q-card>
</template>

<script lang="ts">
import { mapGetters } from 'vuex';
import defaultArea, { AreaInterface } from '../../store/area/state';
import areaState from '../../store/area/state';
import { Prop, PropOptions } from 'vue/types/options';
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
    // link: {
    //   type: Object as Prop<LinkInterface>,
    //   required: true
    // },
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
      selectedArea: defaultArea,
      confirmDelete: false,
      tab: 'description',
      link: null,
      initialPagination: {
        rowsPerPage: 0
      },
      icons: {
        'door-closed': 'fas fa-door-closed',
        'door-open': 'fas fa-door-closed'
      }
    };
  },
  computed: {
    areaNameIndex(): Record<string, string> {
      const index = {};
      this.areas.forEach(area => (index[area.id] = area.name));
      return index;
    },
    incomingLinks(): LinkInterface[] {
      return this.links.filter(link => link.toId == this.area.id);
    },
    outgoingLinks(): LinkInterface[] {
      return this.links.filter(link => link.fromId == this.area.id);
    },
    linkTableSelectedRow(): LinkInterface[] {
      // if (this.link.id != '') {
      //   return [this.link];
      // } else {
      return [];
      // }
    },
    linkButtonsDisabled(): boolean {
      return this.linkTableSelectedRow.length == 0;
    },
    ...mapGetters({
      selectedLink: 'builder/selectedLink',
      isLinkSelected: 'builder/isLinkSelected'
    })
  },
  methods: {
    linkTableToggleSingleRow(row: LinkInterface) {
      this.$emit('selectLink', row);
    },
    createLink() {
      this.$emit('createLink');
    },
    deleteLink() {
      this.$emit('deleteLink');
    },
    editLink() {
      this.$emit('editLink');
    },
    linkTableGetPaginationLabel(
      start: number,
      end: number,
      total: number
    ): string {
      return total.toString() + ' Link(s)';
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

<style lang="sass"></style>
