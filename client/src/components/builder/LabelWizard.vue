<template>
  <div class="fit flex column q-pa-md">
    <q-form class="col">
      <q-input v-model="workingLabel.text" label="Text of the label" />
      <q-input
        v-model.number="workingLabel.x"
        type="number"
        filled
        label="Map X Coordinate"
      />
      <q-input
        v-model.number="workingLabel.y"
        type="number"
        filled
        label="Map Y Coordinate"
      />
      <q-slider
        v-model="workingLabel.size"
        color="green"
        :min="10"
        :step="1"
        :max="50"
        snap
        markers
        label
        label-always
        :label-value="'font-size: ' + workingLabel.size + 'px'"
      />
      <q-input
        v-model="workingLabel.color"
        filled
        :rules="['anyColor']"
        label="Text Color"
        class="my-input"
      >
        <template v-slot:append>
          <q-icon name="colorize" class="cursor-pointer">
            <q-popup-proxy transition-show="scale" transition-hide="scale">
              <q-color v-model="workingLabel.color" />
            </q-popup-proxy>
          </q-icon>
        </template>
      </q-input>
      <q-select
        v-model="workingLabel.style"
        filled
        :options="['normal', 'italic', 'oblique']"
        color="teal"
        options-selected-class="text-deep-orange"
        label="The font style"
      />
      <q-select
        v-model="workingLabel.weight"
        filled
        :options="['normal', 'bold', 'bolder', 'lighter']"
        color="teal"
        options-selected-class="text-deep-orange"
        label="The font weight"
      />
      <q-select
        v-model="workingLabel.family"
        filled
        :options="['sans-serif', 'serif', 'cursive', 'fantasy', 'monospace']"
        color="teal"
        options-selected-class="text-deep-orange"
        label="The font family"
      />
      <q-slider
        v-model="workingLabel.rotation"
        color="green"
        :min="0"
        :step="1"
        :max="360"
        snap
        label
        label-always
        :label-value="'rotation: ' + workingLabel.rotation + ' degrees'"
      />
      <q-input
        v-model.number="workingLabel.inlineSize"
        type="number"
        filled
        label="Inline Size"
        hint="Determined where, in pixels, text wraps"
      />
    </q-form>
    <q-btn-group spread class="col-shrink">
      <q-btn flat @click="previewLabel">Preview</q-btn>
      <q-btn flat @click="save">Save</q-btn>
      <q-btn flat @click="cancel">Cancel</q-btn>
    </q-btn-group>
  </div>
</template>

<script lang="ts">
import { mapGetters, mapState } from 'vuex';
import linkState, { LinkInterface } from '../../store/link/state';
import {
  LabelInterface,
  LabelState,
  MapInterface
} from '../../store/map/state';
import axios, { AxiosResponse } from 'axios';
import { Prop } from 'vue/types/options';
import areaState, { AreaInterface } from 'src/store/area/state';

export default {
  name: 'LabelWizard',
  props: {
    label: {
      type: Object as Prop<LabelInterface>,
      required: true
    }
  },
  data() {
    return {
      workingLabel: { ...LabelState }
    };
  },
  created() {
    this.workingLabel = { ...this.label };
  },
  methods: {
    previewLabel() {
      this.$emit('preview', this.workingLabel);
    },
    cancel() {
      this.$emit('cancel');
    },
    save() {
      this.$emit('save', this.workingLabel);
    }
  }
};
</script>

<style></style>
