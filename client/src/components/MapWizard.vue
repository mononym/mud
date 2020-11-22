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
          {
            id: 'viewSize',
            component: 'QSlider',
            label: 'Map Size',
            subLabel:
              'The total area available for the map. Impacts zooming behaviour',
            // component props:
            min: 1000,
            max: 10000,
            labelAlways: true,
            default: 5000,
            step: 100
          },
          {
            id: 'gridSize',
            component: 'QSlider',
            label: 'Grid Size',
            subLabel:
              'The pixel separation of the grid lines. Impacts how rooms are placed in relation to each other',
            // component props:
            min: 10,
            max: 100,
            labelAlways: true,
            default: 50,
            step: 10
          }
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
          view_size: this.mapUnderConstruction.viewSize,
          grid_size: this.mapUnderConstruction.gridSize,
          labels: this.mapUnderConstruction.labels
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
