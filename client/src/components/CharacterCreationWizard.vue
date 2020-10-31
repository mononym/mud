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
            v-for="race in races"
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

      <q-input v-model="name" label="Name" />

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
import { RaceInterface } from 'src/store/race/state';
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

const clearFields = (fieldIds, fieldInput) => {
  fieldIds.forEach(id => fieldInput({ id, value: '' }));
};

export default {
  name: 'CharacterCreationWizard',
  props: {
    mode: {
      type: String,
      default: 'edit'
    }
  },
  components: { EasyForm },
  data(): {
    featuresForm: Record<string, unknown>;
    featuresFormValue: Record<string, unknown>;
    name: string;
    races: Record<string, RaceInterface>;
    selectedRace: string;
    step: number;
  } {
    return {
      featuresForm: { schema: [] },
      featuresFormValue: {},
      name: '',
      races: {},
      selectedRace: '',
      step: 1
    };
  },
  // conditions: [
  // %{
  //   "key" => "hair-length",
  //   "select" => ["long", "short", "shoulder-length"],
  //   "comparison" => "in"
  // }
  computed: {
    raceOptions: function(): RaceOption[] {
      console.log('computing raceOptions');

      if (this.races != {}) {
        const races = this.races;
        var result = Object.keys(races).map(function(race) {
          return { label: races[race].singular, value: races[race].singular };
        });

        return result;
      } else {
        return [];
      }
    },
    ...mapGetters({
      instanceBeingBuilt: 'builder/instanceBeingBuilt'
    })
  },
  watch: {
    // featuresFormValue: function(newFormValues, oldFormValues) {
    //   console.log('featuresFormValue***************************');
    //   console.log(newFormValues);
    //   const features = this.races[this.selectedRace].features;
    //   for (const property in newFormValues) {
    //     if (property != 'schema' && newFormValues[property] != undefined) {
    //       const feature = features.find(feature => feature.key == property);
    //       switch (feature.type) {
    //         case 'select': {
    //           const option: CharacterRaceFeatureOptionInterface = feature.options.find(
    //             option =>
    //               option.value == newFormValues[property]
    //                 ? newFormValues[property].value
    //                 : undefined
    //           );
    //           if (
    //             option != undefined &&
    //             !this.filterFeatureOption(option.conditions, newFormValues)
    //           ) {
    //             this.featuresFormValue[property] = undefined;
    //           }
    //           break;
    //         }
    //         case 'range':
    //           break;
    //         default:
    //       }
    //     }
    //   }
    // iterate through all of the values in the new form
    // check the key for the value and grab the feature from the race
    // check the conditions for the selected feature option to see if they still pass
    // if conditions pass leave everything alone, otherwise set offending value to undefined
    // if (newSelectedRace !== oldSelectedRace) {
    //   this.featuresFormValue = { schema: [] };
    // }
    // },
    // selectedRace: function(newSelectedRace, oldSelectedRace) {
    //   if (newSelectedRace !== oldSelectedRace) {
    //     this.featuresFormValue = { schema: [] };
    //   }
    // }
  },
  created() {
    // fetch the data when the view is created and the data is
    // already being observed
    this.fetchCharacterCreationData();
    this.selectRace();
  },
  methods: {
    selectRace: function(): unknown {
      const self = this;

      this.featuresForm = {
        // Build the schema for the form based on the race selected
        schema: this.races[this.selectedRace].features
          .map(function(feature) {
            let component: string;
            let props = {};

            console.log(feature.name);

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
      console.log('filterFeatureOption');
      // console.log(conditions);
      // console.log(selectedFeatures);
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
      console.log('checkCondition');
      console.log(condition);
      console.log(selectedFeatures);
      console.log(condition.comparison);
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
    fetchCharacterCreationData() {
      // void this.$axios.get('characters/get-creation-data')

      // console.log('params');
      // console.log(this.$route.params);

      void this.$axios
        .get('/character_races/instance/' + this.instanceBeingBuilt.id)
        .then(result => {
          const data: RaceInterface[] = result.data;
          const races = data.reduce(
            (obj: Record<string, unknown>, race: RaceInterface) => (
              (obj[race.singular] = race), obj
            ),
            {}
          );
          Vue.set(this, 'races', races);
          Vue.set(this, 'selectedRace', this.randomElement(data).singular);
        });

      return true;
    },
    randomElement<T>(array: T[]): T {
      return array[Math.floor(Math.random() * array.length)];
    },
    createCharacter(action: string) {
      console.log('createCharacter');
      // const values = {
      //     age: this.selectedAge,
      //     eye_accent_color: this.selectedEyeAccentColor,
      //     eye_color: this.selectedEyeColor,
      //     eye_color_type: this.selectedEyeColorType,
      //     hair_color: this.selectedHairColor,
      //     hair_length: this.selectedHairLength,
      //     hair_style: this.selectedHairStyle,
      //     height: this.selectedHeight,
      //     name: this.name,
      //     race: this.selectedRace,
      //     skin_color: this.selectedSkinColor
      //   };

      //   const store = this.$store;
      //   const router = this.$router;

      //   void this.$axios
      //     .post('characters/create', values)
      //     .then(function(result: AxiosResponse) {
      //       store
      //         .dispatch('characters/addCharacter', result.data)
      //         .then(function() {
      //           let slug: string = result.data.slug;
      //           let url: string =
      //             action == 'view' ? '/characters/' + slug : '/play/' + slug;
      //           router.push(url);
      //         });
      //       // if successful, redirect to the character overview screen which will have a quick link to play the character
      //       // effectively it will be the character's dashboard, showing off statistics and information about the character
      //       // as well as being able to view inventory and vault contents and quest progress and messages and so on
      //     });
    }
  }
};
</script>

<style>
#authFormWrapper {
  display: flex;
}
</style>
