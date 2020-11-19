<template>
  <div class="fit flex column q-pa-md">
    <q-form class="col">
      <q-btn-toggle
        v-model="linkDirection"
        spread
        no-caps
        :options="[
          { label: 'Incoming', value: 'incoming' },
          { label: 'Outgoing', value: 'outgoing' }
        ]"
      />
      <q-select
        v-model="mapForOtherArea"
        filled
        :options="mapOptions"
        color="teal"
        clearable
        options-selected-class="text-deep-orange"
        label="Map containing the other Area"
        emit-value
        :display-value="mapForOtherArea.name"
      />
      <q-select
        v-model="otherArea"
        filled
        :options="otherAreaOptions"
        color="teal"
        clearable
        options-selected-class="text-deep-orange"
        label="Area on the other side of the link"
        emit-value
        :display-value="otherArea.name"
      />
      <q-select
        v-model="workingLink.type"
        filled
        :options="['direction', 'object']"
        color="teal"
        clearable
        options-selected-class="text-deep-orange"
        label="Type"
      />
      <q-select
        v-show="workingLink.type == 'object'"
        v-model="workingLink.icon"
        filled
        :options="iconOptions"
        color="teal"
        clearable
        options-selected-class="text-deep-orange"
        emit-value
      >
        <template v-slot:option="scope">
          <q-item v-bind="scope.itemProps" v-on="scope.itemEvents">
            <q-item-section avatar>
              <q-icon :name="scope.opt.value" />
            </q-item-section>
            <q-item-section>
              <q-item-label>{{ scope.opt.label }}</q-item-label>
              <q-item-label caption>{{ scope.opt.description }}</q-item-label>
            </q-item-section>
          </q-item>
        </template>
        <template v-slot:selected>
          <q-icon :name="workingLink.icon" />
        </template>
      </q-select>
      <q-input
        v-model="workingLink.shortDescription"
        label="Short Description"
      />

      <q-input
        v-show="workingLink.type == 'object'"
        v-model="workingLink.longDescription"
        label="Long Description"
      />
      <q-input
        v-show="workingLink.type == 'object'"
        v-model="workingLink.departureText"
        label="Departure Text"
      />
      <q-input
        v-show="workingLink.type == 'object'"
        v-model="workingLink.arrivalText"
        label="Arrival Text"
      />
    </q-form>
    <q-btn-group spread class="col-shrink">
      <q-btn flat @click="save">Save</q-btn>
      <q-btn flat @click="cancel">Cancel</q-btn>
    </q-btn-group>
  </div>
</template>

<script lang="ts">
import { mapGetters, mapState } from 'vuex';
import linkState, { LinkInterface } from '../../store/link/state';
import { MapInterface } from '../../store/map/state';
import axios, { AxiosResponse } from 'axios';
import { Prop } from 'vue/types/options';
import areaState, { AreaInterface } from 'src/store/area/state';

interface IconOption {
  label: string;
  value: string;
  description: string;
  icon: string;
}

export default {
  name: 'LinkWizard',
  props: {
    link: {
      type: Object as Prop<LinkInterface>,
      required: true
    },
    map: {
      type: Object as Prop<MapInterface>,
      required: true
    },
    area: {
      type: Object as Prop<AreaInterface>,
      required: true
    },
    maps: {
      type: Array,
      required: true
    },
    areas: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      loadedAreas: [],
      otherArea: { ...areaState },
      mapForOtherArea: { ...mapState },
      linkDirection: 'outgoing',
      workingLink: { ...linkState },
      iconOptions: [
        {
          label: 'Door',
          value: 'fas fa-door-closed',
          description: 'Standard Door',
          icon: 'fas fa-door-closed'
        },
        {
          label: 'Gate',
          value: 'fas fa-dungeon',
          description: 'Gates of all types',
          icon: 'fas fa-dungeon'
        },
        {
          label: 'Archway',
          value: 'fas fa-archway',
          description: 'Archway',
          icon: 'fas fa-archway'
        },
        {
          label: 'Path',
          value: 'fas fa-wand',
          description:
            'An unpaved path. Smaller and less "formal" than a road.',
          icon: 'fas fa-wand'
        }
      ]
    };
  },
  computed: {
    mapOptions: function(): Array<Record<string, unknown>> {
      return this.maps.map(function(map) {
        return { label: map.name, value: map };
      });
    },
    otherAreaOptions: function(): Array<Record<string, unknown>> {
      if (
        this.mapForOtherArea.id != '' &&
        this.mapForOtherArea.id != this.loadedAreas[0].mapId
      ) {
        this.$axios
          .get('/areas/map/' + this.mapForOtherArea.id)
          .then(result => (this.loadedAreas = result.data));

        this.otherArea = { ...areaState };
      }

      return this.loadedAreas.map(function(area) {
        return { label: area.name, value: area };
      });
    },
    descriptionContinueButtonDisabled: function(): boolean {
      return (
        this.link.shortDescription === '' || this.link.longDescription === ''
      );
    },
    textContinueButtonDisabled: function(): boolean {
      return this.link.arrivalText === '' || this.link.departureText === '';
    },
    workingLinkFromArea: function(): AreaInterface {
      const result: AreaInterface[] = this.areas.filter(
        area => area.id == this.workingLink.fromId
      );

      if (result.length > 0) {
        return result[0];
      } else {
        return { ...areaState };
      }
    },
    workingLinkToArea: function(): AreaInterface {
      const result: AreaInterface[] = this.areas.filter(
        area => area.id == this.workingLink.toId
      );

      if (result.length > 0) {
        return result[0];
      } else {
        return { ...areaState };
      }
    },
    saveButtonDisabled: function(): boolean {
      return (
        this.link.shortDescription === '' ||
        this.link.longDescription === '' ||
        this.link.arrivalText === '' ||
        this.link.departureText === ''
      );
    },
    allowNameHeaderSelect: function(): boolean {
      return !this.isNew;
    },
    isNew: function(): boolean {
      return this.workingLink.id == '';
    },
    mapOptions: function(): Record<string, string> {
      return this.maps.map((map: Record<string, string>) => {
        map.label = map.name;
        map.value = map.id;
      });
    }
  },
  created() {
    this.workingLink = { ...this.link };
    this.loadedAreas = this.areas;
    this.mapForOtherArea = this.map;
  },
  methods: {
    cancel() {},
    save() {},
    saveLink() {
      const params = {
        link: {
          arrival_text: this.workingLink.arrivalText,
          departure_text: this.workingLink.departureText,
          short_description: this.workingLink.shortDescription,
          long_description: this.workingLink.longDescription,
          icon: this.workingLink.icon,
          to_id: this.workingLink.toId,
          from_id: this.workingLink.fromId
        }
      };
      let request;
      if (this.isNew) {
        request = this.$axios.post('/links', params);
      } else {
        const id: string = this.workingLink.id;
        request = this.$axios.patch('/links/' + id, params);
      }

      request
        .then(function(result: AxiosResponse) {
          this.$emit('saved', result.data);
        })
        .catch(function() {
          alert('Error saving');
        });
    }
  }
};
</script>

<style></style>
