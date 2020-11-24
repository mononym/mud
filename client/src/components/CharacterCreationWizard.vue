<template>
  <q-stepper v-model="step" vertical color="primary" class="fit overflow-auto">
    <q-step
      :name="1"
      title="Select a race"
      icon="fas fa-users"
      :done="step > 1"
      :caption="selectedRace"
    >
      <div class="q-pa-md">
        <q-carousel
          v-model="selectedRace"
          transition-prev="slide-right"
          transition-next="slide-left"
          animated
          control-color="primary"
          class="rounded-borders"
        >
          <q-carousel-slide
            v-for="race in Array.from(races.values())"
            :key="race.id"
            :name="race.singular"
            class="column no-wrap flex-center"
          >
            <q-img
              class=""
              :src="race.portrait"
              :alt="race.singular"
              :ratio="1"
              contain
            />
            <div class="q-mt-md text-center">
              {{ race.description }}
            </div>
          </q-carousel-slide>
        </q-carousel>

        <div class="row justify-center">
          <q-btn-toggle
            v-model="selectedRace"
            glossy
            :options="raceOptions"
            @click="selectRace"
          />
        </div>
      </div>

      <q-stepper-navigation>
        <q-btn color="primary" label="Continue" @click="step = 2" />
      </q-stepper-navigation>
    </q-step>

    <q-step
      :name="2"
      title="Choose physical features"
      icon="assignment"
      :done="step > 2"
    >
      <EasyForm v-model="featuresFormValue" v-bind="featuresForm" />

      <q-stepper-navigation>
        <q-btn
          v-show="mode == 'preview'"
          color="primary"
          label="Preview"
          @click="emitPreview"
        />
        <q-btn
          v-show="mode == 'edit'"
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
      v-if="mode == 'edit'"
      :name="3"
      title="Choose a name"
      icon="add_comment"
    >
      What is in a name? Everything! This is how other players will know and
      interact with you. There are few guidelines to a name. Just make it
      appropriate for a fantasy setting, and please avoid any names belonging to
      an existing IP.

      <q-input v-model="featuresFormValue.name" label="Name" />

      <q-stepper-navigation>
        <q-btn
          v-if="mode == 'edit'"
          color="primary"
          label="Create & Play"
          @click="createCharacter('play')"
        />
        <q-btn
          v-if="mode == 'edit'"
          color="primary"
          label="Create & View"
          disabled
          @click="createCharacter('view')"
        />
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
</template>

<script lang="ts">
import Vue from 'vue';
import { RaceInterface } from 'src/store/races/state';
import { mapGetters } from 'vuex';
import { EasyForm } from 'quasar-ui-easy-forms';
import {
  CharacterRaceFeatureOptionInterface,
  CharacterRaceFeatureOptionConditionInterface
} from 'src/store/characterRaceFeature/state';

interface RaceOption {
  label: string;
  value: string;
}

export default {
  name: 'CharacterCreationWizard',
  components: { EasyForm },
  props: {
    mode: {
      type: String,
      default: 'edit'
    }
  },
  data(): {
    featuresForm: Record<string, unknown>;
    featuresFormValue: Record<string, unknown>;
    name: string;
    selectedRace: string;
    step: number;
  } {
    return {
      featuresForm: { schema: [] },
      featuresFormValue: {},
      name: '',
      selectedRace: '',
      step: 1
    };
  },
  computed: {
    raceOptions: function(): RaceOption[] {
      console.log('computing raceOptions');

      const options = [];

      for (let [key, race] of this.races) {
        options.push({
          label: race.singular,
          value: race.singular
        });
      }

      return options;
    },
    ...mapGetters({
      instanceBeingBuilt: 'instances/instanceBeingBuilt',
      races: 'races/allMap'
    })
  },
  watch: {},
  created() {
    this.$store
      .dispatch('races/loadForInstance', this.instanceBeingBuilt.id)
      .then(() => {
        if (this.races.size > 0) {
          Vue.set(
            this,
            'selectedRace',
            this.randomElement(Array.from(this.races.values())).singular
          );

          this.selectRace();
        }
      });
  },
  methods: {
    selectRace: function(): unknown {
      const self = this;

      this.featuresForm = {
        // Build the schema for the form based on the race selected
        schema: this.races
          .get(this.selectedRace)
          .features.map(function(feature) {
            let component: string;
            let props = {};

            // Which functions we inject into the form depend on the type of feature we are showing
            switch (feature.type) {
              case 'select': {
                component = 'QSelect';

                props = {
                  filled: true,
                  evaluatedProps: ['options', 'showCondition'],
                  // Only show the select if it has options to display
                  showCondition: (val, { formData, fieldInput }) => {
                    const options = feature.options.filter(function(opt) {
                      return self.filterFeatureOption(opt.conditions, formData);
                    });

                    if (options.length == 0) {
                      // Sometimes an option is selected and then due to a change elsewhere that option is no longer viable.
                      // Because this field no longer has any viable options, do a blind overwrite of any potential selected
                      // value.
                      fieldInput({ id: feature.key, value: '' });
                      return false;
                    } else {
                      return true;
                    }
                  },
                  // Only show options which pass all conditions based on the current data in the form
                  options: (val, { formData, fieldInput }) => {
                    const options = feature.options.filter(function(opt) {
                      return self.filterFeatureOption(opt.conditions, formData);
                    });

                    if (
                      options.length > 0 &&
                      (val == '' || val == null || val == undefined)
                    ) {
                      const randomIndex = Math.floor(
                        Math.random() * options.length
                      );

                      fieldInput({
                        id: feature.key,
                        value: options[randomIndex].value
                      });
                    }

                    return options.map(function(opt) {
                      return { label: opt.value, value: opt.value };
                    });
                  },
                  emitValue: true
                };

                break;
              }
              case 'range': {
                const max: number = feature.options[0].max;
                const min: number = feature.options[0].min;

                component = 'QSlider';
                props = {
                  default: Math.floor(Math.random() * (max - min + 1) + min),
                  min: min,
                  max: max,
                  labelAlways: true
                };
                break;
              }
              default:
                component = 'QToggle';
            }

            return {
              id: feature.key,
              component: component,
              label: feature.field,
              ...props
            };
          })
          .filter(val => val != undefined)
      };
    },
    emitPreview(): void {
      this.$emit('preview', this.featuresFormValue);
    },
    filterFeatureOption(
      conditions: CharacterRaceFeatureOptionConditionInterface[],
      selectedFeatures: Record<string, string>
    ): boolean {
      const self = this;

      if (conditions.length == 0) {
        return true;
      } else {
        return conditions.every(function(condition) {
          return self.checkCondition(condition, selectedFeatures);
        });
      }
    },
    checkCondition(
      condition: CharacterRaceFeatureOptionConditionInterface,
      selectedFeatures: Record<string, string>
    ): boolean {
      switch (condition.comparison) {
        case 'in':
          // console.log(selectedFeatures[condition.key]);
          return selectedFeatures[condition.key] != undefined
            ? condition.select.includes(selectedFeatures[condition.key])
            : false;

        case 'not in':
          return selectedFeatures[condition.key] != undefined
            ? !condition.select.includes(selectedFeatures[condition.key])
            : false;

        // case 'equals':
        //   return selectedFeatures[condition.key] != undefined
        //     ? condition.toggle == selectedFeatures[condition.key].value
        //     : false;

        default:
          return false;
      }
    },
    randomElement<T>(array: T[]): T {
      return array[Math.floor(Math.random() * array.length)];
    },
    createCharacter(action: string) {
      console.log('createCharacter');
      const values = {
        age: this.featuresFormValue.age,
        primary_eye_color: this.featuresFormValue.primaryEyeColor,
        secondary_eye_color: this.featuresFormValue.seconaryEyeColor,
        eye_color_type: this.featuresFormValue.selectedEyeColorType,
        hair_color: this.featuresFormValue.selectedHairColor,
        hair_length: this.featuresFormValue.selectedHairLength,
        hair_style: this.featuresFormValue.selectedHairStyle,
        height: this.featuresFormValue.selectedHeight,
        name: this.featuresFormValue.name,
        race: this.featuresFormValue.selectedRace,
        skin_color: this.featuresFormValue.selectedSkinColor
      };

      const store = this.$store;
      const router = this.$router;

      void this.$axios
        .post('characters/create', this.featuresFormValue)
        .then(function(result: AxiosResponse) {
          store
            .dispatch('characters/addCharacter', result.data)
            .then(function() {
              let slug: string = result.data.slug;
              let url: string =
                action == 'view' ? '/characters/' + slug : '/play/' + slug;
              router.push(url);
            });
          // if successful, redirect to the character overview screen which will have a quick link to play the character
          // effectively it will be the character's dashboard, showing off statistics and information about the character
          // as well as being able to view inventory and vault contents and quest progress and messages and so on
        });
    }
  }
};
</script>

<style>
#authFormWrapper {
  display: flex;
}
</style>
