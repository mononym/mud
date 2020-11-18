<template>
  <div class="fit flex column">
    <div class="col">
      <EasyForm v-model="mapUnderConstruction" v-bind="mapForm" />
    </div>
    <q-btn-group spread class="col-shrink">
      <q-btn :disabled="saveDisabled" flat @click="save">Save</q-btn>
      <q-btn flat @click="cancel">Cancel</q-btn>
    </q-btn-group>
  </div>
</template>

<script lang="ts">
import { Prop } from 'vue/types/options';
import mapState, { MapInterface } from 'src/store/map/state';
import { EasyForm } from 'quasar-ui-easy-forms';

export default {
  name: 'MapWizard',
  components: { EasyForm },
  props: {
    map: {
      type: Object as Prop<MapInterface>,
      required: true
    }
  },
  data(): {
    mapUnderConstruction: MapInterface;
  } {
    return {
      mapUnderConstruction: { ...mapState }
    };
  },
  computed: {
    saveDisabled(): boolean {
      return (
        this.mapUnderConstruction.name == '' ||
        this.mapUnderConstruction.description == ''
      );
    },
    mapForm: function(): Record<string, unknown> {
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
            subLabel: 'A description of the area the map represents.'
          },
          // {
          //   id: 'mapSize',
          //   component: 'QSlider',
          //   label: 'Map Size',
          //   subLabel:
          //     'The total area available for the map. Impacts zooming behaviour',
          //   // component props:
          //   min: 100,
          //   max: 10000,
          //   labelAlways: true,
          //   default: 5000,
          //   step: 100
          // },
          // {
          //   id: 'gridSize',
          //   component: 'QSlider',
          //   label: 'Grid Size',
          //   subLabel:
          //     'The pixel separation of the grid lines. Impacts how rooms are placed in relation to each other',
          //   // component props:
          //   min: 10,
          //   max: 100,
          //   labelAlways: true,
          //   default: 50,
          //   step: 10
          // },
          // {
          //   id: 'maxZoom',
          //   component: 'QSlider',
          //   label: 'Max Zoom',
          //   subLabel:
          //     'The largest the map can be made when viewing. Must be lower than Min Zoom.',
          //   // component props:
          //   min: 100,
          //   max: 10000,
          //   labelAlways: true,
          //   default: 500,
          //   step: 100
          // },
          // {
          //   id: 'minZoom',
          //   component: 'QSlider',
          //   label: 'Min Zoom',
          //   subLabel:
          //     'The smallest the map can be made when viewing. Must be higher than Max Zoom.',
          //   // component props:
          //   min: 100,
          //   max: 10000,
          //   labelAlways: true,
          //   default: 5000,
          //   step: 100
          // },
          // {
          //   id: 'defaultZoom',
          //   component: 'QSlider',
          //   label: 'Default Zoom',
          //   subLabel: 'The default zoom level when a map is opened',
          //   // component props:
          //   min: 500,
          //   max: 10000,
          //   labelAlways: true,
          //   default: 5000,
          //   step: 100
          // }
        ]
      };
    }
  },
  created() {
    this.mapUnderConstruction = { ...this.map };
  },
  methods: {
    cancel() {
      this.$emit('cancel');
    },
    save() {
      const params = {
        map: {
          name: this.mapUnderConstruction.name,
          description: this.mapUnderConstruction.description,
          map_size: this.mapUnderConstruction.mapSize,
          grid_size: this.mapUnderConstruction.gridSize,
          max_zoom: this.mapUnderConstruction.maxZoom,
          min_zoom: this.mapUnderConstruction.minZoom,
          default_zoom: this.mapUnderConstruction.defaultZoom
        }
      };

      let request;
      let id: string = this.map.id;

      if (this.mapUnderConstruction.id == '') {
        request = this.$axios.post('/maps', params);
      } else {
        request = this.$axios.patch('/maps/' + id, params);
      }

      request
        .then(result => {
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
