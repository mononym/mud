<template>
  <q-card v-show="map.id != ''" class="fit flex column" flat bordered>
    <q-card-section class="col-shrink q-pb-none">
      <p class="text-h6 text-center">
        {{ map.name }}
      </p>
    </q-card-section>

    <q-card-section class="q-pa-none col-auto">
      {{ map.description }}
    </q-card-section>

    <q-card-section class="q-pa-none col-auto flex">
      <div class="col">
        <q-toolbar class="bg-primary text-white shadow-2">
          <q-toolbar-title>Labels</q-toolbar-title>
          <q-space />
          <q-btn flat @click="createLabel">Create Label</q-btn
        >
        </q-toolbar>
        <q-list bordered separator>
          <q-item
            v-for="label in map.labels"
            :key="label.id"
            :active="label.id == selectedLabel.id"
          >
            <q-item-section>{{ label.text }}</q-item-section>
            <q-item-section top side>
              <div class="text-grey-8 q-gutter-xs">
                <q-btn flat icon="fas fa-edit" @click="editLabel(label)" />
                <q-btn
                  flat
                  icon="fas fa-trash"
                  @click="promptForDelete('label', deleteLabel, label.id)"
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
import { LabelInterface, LabelState, MapInterface } from 'src/store/map/state';

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
  name: 'MapDetails',
  components: {},
  props: {
    map: {
      type: Object as Prop<MapInterface>,
      required: true
    }
  },
  data() {
    return {
      selectedLabel: { ...LabelState }
    };
  },
  computed: {},
  methods: {
    createLabel() {
      this.selectedLabel = { ...LabelState };
      this.$emit('createLabel');
    },
    deleteLabel(labelId: string) {
      this.$emit('deleteLabel', labelId);
    },
    editLabel(label: LabelInterface) {
      this.$emit('editLabel', label);
    },
    // Common stuff
    promptForDelete(name: string, callback, labelId: string) {
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
          callback(labelId);
        });
    }
  }
};
</script>

<style lang="sass"></style>
