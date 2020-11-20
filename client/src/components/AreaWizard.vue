<template>
  <div class="fit flex column q-pa-md">
    <div class="col">
      <q-form class="col">
        <q-input v-model="workingArea.name" label="Name" />

        <q-input v-model="workingArea.description" label="Description" />
        <q-input
          v-model.number="workingArea.mapX"
          type="number"
          filled
          label="Map X Coordinate"
        />
        <q-input
          v-model.number="workingArea.mapY"
          type="number"
          filled
          label="Map Y Coordinate"
        />
        <q-input
          v-model.number="workingArea.mapSize"
          type="number"
          filled
          label="Size of area in pixels on map"
        />
      </q-form>
    </div>
    <q-btn-group spread class="col-shrink">
      <q-btn flat @click="preview">Preview</q-btn>
      <q-btn :disabled="saveButtonDisabled" flat @click="save">Save</q-btn>
      <q-btn flat @click="cancel">Cancel</q-btn>
    </q-btn-group>
  </div>
</template>

<script lang="ts">
import areaState, { AreaInterface } from 'src/store/area/state';
import { MapInterface } from 'src/store/map/state';
import { Prop } from 'vue/types/options';

export default {
  name: 'AreaWizard',
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
    saveButtonDisabled: function(): boolean {
      return this.workingArea.name == '' || this.workingArea.description == '';
    },
  },
  created(): void {
    this.workingArea = { ...this.area };
    this.workingArea.mapId = this.map.id;
  },
  methods: {
    preview(): void {
      this.$emit('preview', {...this.workingArea});
    },
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
          map_size: this.workingArea.mapSize,
          instance_id: this.workingArea.instanceId
        }
      };

      let request;
      if (newArea) {
        request = this.$axios.post('/areas', params);
      } else {
        const id: string = this.area.id;
        request = this.$axios.patch('/areas/' + id, params);
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
