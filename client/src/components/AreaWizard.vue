<template>
  <div class="fit flex column">
    <div class="col">
      <EasyForm v-model="workingArea" v-bind="areaForm" />
    </div>
    <q-btn-group spread class="col-shrink">
      <q-btn :disabled="saveDisabled" flat @click="save">Save</q-btn>
      <q-btn flat @click="cancel">Cancel</q-btn>
    </q-btn-group>
  </div>
</template>

<script lang="ts">
import { mapGetters } from 'vuex';
import areaState, { AreaInterface } from 'src/store/area/state';
import { MapInterface } from 'src/store/map/state';
import { Prop } from 'vue/types/options';
import { EasyForm } from 'quasar-ui-easy-forms';


export default {
  name: 'AreaWizard',
  components: { EasyForm },
  props: {
    area: {
      type: Object as Prop<AreaInterface>,
      required: true
    },
    map: {
      type: Object as Prop<MapInterface>,
      required: true
    }
  },
  data(): {
    step: number;
    workingArea: AreaInterface;
  } {
    return {
      step: 1,
      workingArea: { ...areaState }
    };
  },
  computed: {
    saveDisabled(): boolean {
      return this.workingArea.name == '' || this.workingArea.description == '';
    },
    areaForm: function(): Record<string, unknown> {
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
            subLabel: 'The text description of the room',
            // component props:
            autogrow: true
          },
          {
            id: 'mapX',
            component: 'QSlider',
            label: 'Map X Coordinate',
            subLabel: 'The center of the map is (0,0)',
            // component props:
            min: -500,
            max: 500,
            labelAlways: true,
            default: 0
          },
          {
            id: 'mapY',
            component: 'QSlider',
            label: 'Map Y Coordinate',
            subLabel: 'The center of the map is (0,0)',
            // component props:
            min: -500,
            max: 500,
            "label-always": true,
            default: 0
          },
          {
            id: 'mapSize',
            component: 'QSlider',
            label: 'Map Size',
            subLabel: 'How large, in pixels, the area will appear on a map',
            // component props:
            min: 0,
            max: 1000,
            labelAlways: true,
            default: 0
          }
        ]
      };
    },
    mapsIndex: function(): Record<string, number> {
      const mapIndex = {};

      this.maps.forEach(function(map: MapInterface, index: number) {
        mapIndex[map.id] = index;
      });

      return mapIndex;
    },
    nameContinueButtonDisabled: function(): boolean {
      return this.workingArea.name == '';
    },
    saveButtonDisabled: function(): boolean {
      return (
        this.workingArea.name == '' ||
        this.workingArea.description == '' ||
        this.workingArea.mapId == ''
      );
    },
    allowNameHeaderSelect: function() {
      return this.area.id != '';
    },
    isNew: function() {
      return this.area.id == '';
    },
    selectedMapName: function() {
      return this.map.name;
    },
    mapOptions: function() {
      return this.maps.map(function(map) {
        return {
          label: map.name,
          value: map.id
        };
      });
    },
    ...mapGetters({
      maps: 'maps/listAll'
    })
  },
  created(): void {
    this.workingArea = { ...this.area };
    this.workingArea.mapId = this.map.id;
  },
  methods: {
    cancel(): void {
      this.$emit('cancel');
    },
    save(): void {
      const newArea = this.area.id == '';

      const params = {
        area: {
          name: this.workingArea.name,
          map_id: this.workingArea.mapId,
          description: this.workingArea.description,
          map_x: this.workingArea.mapX,
          map_y: this.workingArea.mapY,
          map_size: this.workingArea.mapSize
        }
      };

      let request;
      if (newArea) {
        request = this.$axios.post('/areas', params);
      } else {
        request = this.$axios.patch('/areas/' + this.area.id, params);
      }

      // The area was created in a different map than it started out in.
      // if (this.area.mapId != this.map.id) {
      request
        .then(result => {
          // emit that a thing was saved so that everything can be adjusted
          this.$emit('save', result.data);
        })
        .catch(function() {
          alert('Error saving');
        });
    }
  }
};
</script>

<style></style>
