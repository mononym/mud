<template>
  <div class="q-pa-none">
    <q-card flat bordered class="q-pa-none">
      <q-card-section class="q-plbr-none text-h6 text-center">
        {{ workingLinkFromArea.name }} to {{ workingLinkToArea.name }}
      </q-card-section>

      <q-card-section class="q-pa-none">
        <q-stepper
          v-model="step"
          class="q-pa-none"
          vertical
          color="primary"
          header-nav
        >
          <q-step
            :name="1"
            title="Visuals"
            icon="fas fa-eye"
            :done="step > 1"
            :header-nav="step > 1 || !isNew"
            :caption="workingLink.shortDescription"
          >
            <p>Icon for exit that players see</p>

            <q-form class="q-gutter-md">
              <q-select
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
                      <q-item-label caption>{{
                        scope.opt.description
                      }}</q-item-label>
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
                v-model="workingLink.longDescription"
                label="Long Description"
              />
            </q-form>

            <q-stepper-navigation>
              <q-btn
                :disabled="descriptionContinueButtonDisabled"
                color="primary"
                label="Continue"
                @click="step = 2"
              />
            </q-stepper-navigation>
          </q-step>

          <q-step
            :name="2"
            title="Arrival and Departure Strings"
            icon="fas fa-signature"
            :done="step > 2"
            :header-nav="step > 2 || !isNew"
          >
            <p>What players see when a character enters and leaves an area.</p>

            <q-form class="q-gutter-md">
              <q-input v-model="workingLink.arrivalText" label="Arrival Text" />

              <q-input
                v-model="workingLink.departureText"
                label="Departure Text"
              />
            </q-form>
            <q-stepper-navigation>
              <q-btn
                :disabled="descriptionContinueButtonDisabled"
                color="primary"
                label="Continue"
                @click="step = 3"
              />
              <q-btn
                flat
                color="primary"
                label="Back"
                class="q-ml-sm"
                @click="step = 1"
              />
            </q-stepper-navigation>
          </q-step>

          <q-step
            :name="3"
            title="Icon"
            icon="fas fa-signature"
            :done="step > 3"
            :header-nav="step > 3 || !isNew"
          >
            <div class="q-pa-lg"></div>

            <q-stepper-navigation>
              <q-btn
                flat
                color="primary"
                label="Back"
                class="q-ml-sm"
                @click="step = 2"
              />
            </q-stepper-navigation>
          </q-step>
        </q-stepper>
      </q-card-section>

      <q-card-actions align="around" class="q-pa-none">
        <q-btn
          v-if="!saveButtonDisabled"
          class=""
          label="Save"
          @click="saveLink"
        />
        <q-btn class="" label="Cancel" @click="cancel" />
      </q-card-actions>
    </q-card>
  </div>
</template>

<script lang="ts">
import { mapGetters } from 'vuex';
import linkState, { LinkInterface } from '../store/link/state';
import { MapInterface } from '../store/map/state';
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
      workingLink: { ...linkState },
      step: 1,
      icon: {
        label: '',
        value: '',
        description: '',
        icon: ''
      },
      localIcon: {
        label: '',
        value: '',
        description: '',
        icon: ''
      },
      iconOptions: [
        {
          label: '',
          value: '',
          description: '',
          icon: ''
        }
      ]
    };
  },
  computed: {
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
    this.iconOptions = [
      this.compassIcon(),
      this.closedDoorIcon(),
      this.openDoorIcon(),
      this.gateIcon(),
      this.archwayIcon()
    ];

    this.workingLink = { ...this.link };
  },
  methods: {
    emptyIcon(): IconOption {
      return {
        label: '',
        value: '',
        description: '',
        icon: ''
      };
    },
    compassIcon(): IconOption {
      return {
        label: 'Compass',
        value: 'fas fa-compass',
        description: 'Directional Exit',
        icon: 'fas fa-compass'
      };
    },
    closedDoorIcon(): IconOption {
      return {
        label: 'Closed Door',
        value: 'fas fa-door-closed',
        description: 'Standard Closed Door',
        icon: 'fas fa-door-closed'
      };
    },
    openDoorIcon(): IconOption {
      return {
        label: 'Open Door',
        value: 'fas fa-door-open',
        description: 'Standard Open Door',
        icon: 'fas fa-door-open'
      };
    },
    archwayIcon(): IconOption {
      return {
        label: 'Archway',
        value: 'fas fa-archway',
        description: 'Archway',
        icon: 'fas fa-archway'
      };
    },
    gateIcon(): IconOption {
      return {
        label: 'Gate',
        value: 'fas fa-dungeon',
        description: 'Gates of all types',
        icon: 'fas fa-dungeon'
      };
    },
    cancel() {
      this.$store
        .dispatch('builder/putIsLinkUnderConstruction', false)
        .then(() =>
          this.$store.dispatch('builder/putBottomRightPanel', 'areaTable')
        );
    },
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
