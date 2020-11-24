<template>
  <q-card class="fit flex column" flat bordered>
    <q-card-section class="col-shrink q-pb-none">
      <p class="text-h6 text-center">
        {{ area.name }}
      </p>
    </q-card-section>

    <q-card-section class="q-pa-none col-auto">
      {{ area.description }}
    </q-card-section>

    <q-card-section v-show="showCard" class="q-pa-none col-auto flex">
      <div class="col">
        <q-toolbar class="bg-primary text-white shadow-2">
          <q-toolbar-title>Incoming Links</q-toolbar-title>
        </q-toolbar>
        <q-list bordered separator>
          <q-item
            v-for="incoming in incomingLinks"
            :key="incoming.id"
            clickable
            :active="incoming.id == highlightedLink"
            @click="highlightLink(incoming)"
          >
            <q-item-section avatar>
              <q-icon color="primary" :name="incoming.icon" />
            </q-item-section>

            <q-item-section>{{ incoming.arrivalText }}</q-item-section>
            <q-item-section top side>
              <div class="text-grey-8 q-gutter-xs">
                <q-btn flat icon="fas fa-edit" @click="editLink(incoming)" />
                <q-btn
                  flat
                  icon="fas fa-trash"
                  @click="
                    promptForDelete(incoming.arrivalText, deleteLink, incoming)
                  "
                />
              </div>
            </q-item-section>
          </q-item>
        </q-list>
      </div>
      <div class="col">
        <q-toolbar class="bg-primary text-white shadow-2">
          <q-toolbar-title>Outgoing Links</q-toolbar-title>
        </q-toolbar>
        <q-list bordered separator>
          <q-item
            v-for="outgoing in outgoingLinks"
            :key="outgoing.id"
            clickable
            :active="outgoing.id == highlightedLink"
            @click="highlightLink(outgoing)"
          >
            <q-item-section avatar>
              <q-icon color="primary" :name="outgoing.icon" />
            </q-item-section>

            <q-item-section>{{ outgoing.shortDescription }}</q-item-section>
            <q-item-section top side>
              <div class="text-grey-8 q-gutter-xs">
                <q-btn flat icon="fas fa-edit" @click="editLink(outgoing)" />
                <q-btn
                  flat
                  icon="fas fa-trash"
                  @click="
                    promptForDelete(outgoing.shortDescription, deleteLink, outgoing)
                  "
                />
              </div>
            </q-item-section>
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
      highlightedLink: '',
      link: null
    };
  },
  computed: {
    showCard(): boolean {
      console.log('show');
      return this.area.id != '';
    },
    incomingLinks(): LinkInterface[] {
      return this.links.filter(link => link.toId == this.area.id);
    },
    outgoingLinks(): LinkInterface[] {
      return this.links.filter(link => link.fromId == this.area.id);
    }
  },
  methods: {
    highlightLink(link: LinkInterface) {
      this.highlightedLink = link.id;
      this.$emit('highlightLink', link.id);
    },
    createLink() {
      this.$emit('highlightLink', '');
      this.$emit('createLink');
    },
    deleteLink(link: LinkInterface) {
      this.$emit('highlightLink', '');
      this.$emit('deleteLink', link);
    },
    editLink(link: LinkInterface) {
      this.$emit('editLink', link);
    },
    // Common stuff
    promptForDelete(name: string, callback, link) {
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
          callback(link);
        });
    }
  }
};
</script>

<style lang="sass"></style>
