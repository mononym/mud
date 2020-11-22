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
        options-selected-class="text-deep-orange"
        label="Area on the other side of the link"
        emit-value
        @input="previewLink"
      >
        <template v-slot:selected>
          {{ otherArea.name }}
        </template>
      </q-select>
      <q-input
        v-show="linkDirection == 'outgoing'"
        v-model.number="workingLink.localToX"
        type="number"
        filled
        label="Map X Coordinate"
      />
      <q-input
        v-show="linkDirection == 'outgoing'"
        v-model.number="workingLink.localToY"
        type="number"
        filled
        label="Map Y Coordinate"
      />
      <q-input
        v-show="linkDirection == 'outgoing'"
        v-model.number="workingLink.localToSize"
        type="number"
        filled
        label="Size of area in pixels on map"
      />
      <q-input
        v-show="mapForOtherArea.id != map.id && linkDirection == 'incoming'"
        v-model.number="workingLink.localFromX"
        type="number"
        filled
        label="Map X Coordinate"
      />
      <q-input
        v-show="mapForOtherArea.id != map.id && linkDirection == 'incoming'"
        v-model.number="workingLink.localFromY"
        type="number"
        filled
        label="Map Y Coordinate"
      />
      <q-input
        v-show="mapForOtherArea.id != map.id && linkDirection == 'incoming'"
        v-model.number="workingLink.localFromSize"
        type="number"
        filled
        label="Size of area in pixels on map"
      />
      <q-select
        v-model="workingLink.type"
        filled
        :options="['direction', 'object']"
        color="teal"
        options-selected-class="text-deep-orange"
        label="Type"
      />
      <q-select
        v-show="workingLink.type == 'object'"
        v-model="workingLink.icon"
        filled
        :options="iconOptions"
        color="teal"
        options-selected-class="text-deep-orange"
        emit-value
        label="Icon"
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
      <q-select
        v-show="workingLink.type == 'direction'"
        v-model="workingLink.shortDescription"
        filled
        :options="[
          'north',
          'south',
          'east',
          'west',
          'northeast',
          'northwest',
          'southwest',
          'southeast',
          'up',
          'down',
          'in',
          'out'
        ]"
        color="teal"
        options-selected-class="text-deep-orange"
        label="Short Description"
      />
      <q-input
        v-show="workingLink.type == 'object'"
        v-model.lazy="workingLink.shortDescription"
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
      <q-input v-model="workingLink.arrivalText" label="Arrival Text" />
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
    otherarea: {
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
      otherAreaForValidation: { ...this.areaState },
      loadedAreas: [],
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
      ],
      otherArea: { ...areaState }
    };
  },
  computed: {
    mapOptions: function(): Array<Record<string, unknown>> {
      return this.maps.map(function(map) {
        return { label: map.name, value: map };
      });
    },
    otherAreaName: function(): string {
      return this.otherArea.name;
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
    }
  },
  watch: {
    otherarea: function(newArea: AreaInterface) {
      if (newArea.id != this.otherAreaForValidation.id) {
        this.otherAreaForValidation = newArea;
        this.otherArea = newArea;
      }
    }
  },
  created() {
    this.workingLink = { ...this.link };
    this.loadedAreas = this.areas;
    this.mapForOtherArea = this.map;
    this.otherAreaForValidation = this.otherArea;

    if (this.workingLink.id != '') {
      const otherAreaId =
        this.area.id == this.link.toId ? this.link.fromId : this.link.toId;

      this.otherArea = this.areas.filter(area => area.id == otherAreaId)[0];

      this.$emit('preview', this.otherArea.id);

      if (this.workingLink.toId == this.area.id) {
        this.linkDirection = 'incoming';
      }
    }
  },
  // updated() {
  //   if (this.otherarea.id != this.otherAreaForValidation.id) {
  //     this.otherAreaForValidation = this.otherarea
  //     this.otherArea = this.otherarea
  //   }
  // },
  methods: {
    previewLink(area: AreaInterface) {
      if (this.mapForOtherArea.id == this.map.id) {
        this.$emit('preview', area.id);
      }
    },
    cancel() {
      this.$emit('cancel');
    },
    save() {
      const fromId =
        this.linkDirection == 'incoming' ? this.otherArea.id : this.area.id;
      const toId =
        this.linkDirection == 'outgoing' ? this.otherArea.id : this.area.id;
      const icon =
        this.workingLink.type == 'direction'
          ? 'fas fa-compass'
          : this.workingLink.icon;

      const isNew = this.workingLink.id == '';
      const params = {
        link: {
          arrival_text: this.workingLink.arrivalText,
          departure_text: this.workingLink.departureText,
          short_description: this.workingLink.shortDescription,
          long_description: this.workingLink.longDescription,
          icon: icon,
          to_id: toId,
          from_id: fromId,
          type: this.workingLink.type
        }
      };
      let request;
      if (isNew) {
        request = this.$axios.post('/links', params);
      } else {
        const id: string = this.workingLink.id;
        request = this.$axios.patch('/links/' + id, params);
      }

      const self = this;

      request
        .then(function(result: AxiosResponse) {
          self.$emit('highlightLink', 'result.data.id');
          self.$emit('save', result.data);
        })
        .catch(function() {
          alert('Error saving');
        });
    }
  }
};
</script>

<style></style>
