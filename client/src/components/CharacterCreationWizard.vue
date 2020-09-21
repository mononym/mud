<template>
  <div class="q-pa-md">
    <q-stepper v-model="step" vertical color="primary" animated>
      <q-step
        :name="1"
        title="Select a race"
        icon="fas fa-users"
        :done="step > 1"
        :caption="selectedRace"
      >
        The choice of character race can impact the experience of playing the
        game, from choice of feats to interactions with NPC's.

        <div class="q-pa-md">
          <q-carousel
            v-model="selectedRace"
            transition-prev="slide-right"
            transition-next="slide-left"
            animated
            control-color="primary"
            class="rounded-borders"
          >
            <q-carousel-slide name="Elf" class="column no-wrap flex-center">
              <q-icon name="style" color="primary" size="56px" />
              <div class="q-mt-md text-center">
                {{ lorem }}
              </div>
            </q-carousel-slide>
            <q-carousel-slide name="Human" class="column no-wrap flex-center">
              <q-icon name="live_tv" color="primary" size="56px" />
              <div class="q-mt-md text-center">
                {{ lorem }}
              </div>
            </q-carousel-slide>
            <q-carousel-slide name="Dwarf" class="column no-wrap flex-center">
              <q-icon name="layers" color="primary" size="56px" />
              <div class="q-mt-md text-center">
                {{ lorem }}
              </div>
            </q-carousel-slide>
            <q-carousel-slide name="Gnome" class="column no-wrap flex-center">
              <q-icon name="terrain" color="primary" size="56px" />
              <div class="q-mt-md text-center">
                {{ lorem }}
              </div>
            </q-carousel-slide>
            <q-carousel-slide
              name="Half Elf"
              class="column no-wrap flex-center"
            >
              <q-icon name="terrain" color="primary" size="56px" />
              <div class="q-mt-md text-center">
                {{ lorem }}
              </div>
            </q-carousel-slide>
            <q-carousel-slide
              name="Half Dwarf"
              class="column no-wrap flex-center"
            >
              <q-icon name="terrain" color="primary" size="56px" />
              <div class="q-mt-md text-center">
                {{ lorem }}
              </div>
            </q-carousel-slide>
            <q-carousel-slide
              name="Half Giant"
              class="column no-wrap flex-center"
            >
              <q-icon name="terrain" color="primary" size="56px" />
              <div class="q-mt-md text-center">
                {{ lorem }}
              </div>
            </q-carousel-slide>
            <q-carousel-slide
              name="Shapeshifter"
              class="column no-wrap flex-center"
            >
              <q-icon name="terrain" color="primary" size="56px" />
              <div class="q-mt-md text-center">
                {{ lorem }}
              </div>
            </q-carousel-slide>
            <q-carousel-slide
              name="Halfling"
              class="column no-wrap flex-center"
            >
              <q-icon name="terrain" color="primary" size="56px" />
              <div class="q-mt-md text-center">
                {{ lorem }}
              </div>
            </q-carousel-slide>
          </q-carousel>

          <div class="row justify-center">
            <q-btn-toggle
              glossy
              v-model="selectedRace"
              :options="raceOptions"
            />
          </div>
        </div>

        <q-stepper-navigation>
          <q-btn @click="step = 2" color="primary" label="Continue" />
        </q-stepper-navigation>
      </q-step>

      <q-step
        :name="2"
        title="Choose an age"
        icon="create_new_folder"
        :done="step > 2"
        :caption="selectedAge.toString()"
      >
        A character's age has no practical effect on gameplay, and is purely for
        roleplay.

        <div class="q-pa-md">
          <q-slider
            v-model="selectedAge"
            :min="minAge"
            :max="maxAge"
            :step="1"
            label
            label-always
            markers
            color="light-green"
          />
        </div>

        <q-stepper-navigation>
          <q-btn @click="step = 3" color="primary" label="Continue" />
          <q-btn
            flat
            @click="step = 1"
            color="primary"
            label="Back"
            class="q-ml-sm"
          />
        </q-stepper-navigation>
      </q-step>

      <q-step
        :name="3"
        title="Choose physical features"
        icon="assignment"
        :done="step > 3"
      >
        A character's physical features have no practical effect on gameplay,
        and are purely for roleplay.

        <div class="q-pa-md" style="max-width: 400px">
          <q-form class="q-gutter-md">
            <q-select
              v-model="selectedHairColor"
              :options="haircolors"
              label="Hair Color"
            />
            <q-select
              v-model="selectedHairLength"
              :options="hairlengths"
              label="Hair Length"
            />
            <q-select
              v-show="notBald"
              v-model="selectedHairStyle"
              :options="hairstyles"
              label="Hair Style"
            />
            <q-select
              v-model="selectedEyeColorType"
              :options="eyeColorTypes"
              label="Eye Color Type"
            />
            <q-select
              v-model="selectedEyeColor"
              :options="eyecolors"
              label="Eye Color"
            />
            <q-select
              v-if="showEyeAccentColor"
              v-model="selectedEyeAccentColor"
              :options="eyecolors"
              label="Eye Accent Color"
            />
            <q-select
              v-model="selectedSkinColor"
              :options="skincolors"
              label="Skin Color"
            />
            <q-select
              v-model="selectedHeight"
              :options="heights"
              label="Height"
            />
          </q-form>
        </div>

        <q-stepper-navigation>
          <q-btn @click="step = 4" color="primary" label="Continue" />
          <q-btn
            flat
            @click="step = 2"
            color="primary"
            label="Back"
            class="q-ml-sm"
          />
        </q-stepper-navigation>
      </q-step>

      <q-step
        :name="4"
        title="Choose a background"
        icon="add_comment"
        :done="step > 4"
      >
        Backgrounds have no impact beyond giving a character a boost in specific
        skill areas in the very beginning. For example, someone with a generic
        "fighter" type background would have more advanced combat and weapons
        skills than someone who had a generic "alchemist" or "mage" type
        background. The boosts provided in the beginning are large enough to
        make a difference in helping a character along the start of their
        journey but are small enough not to make a difference in the long run.
        There is no "wrong" background and not taking a "correct" background
        will not hinder your character in any way. If unsure what to choose,
        just leave it on the default 'Adventurer' background.

        <q-stepper-navigation>
          <q-btn @click="step = 5" color="primary" label="Continue" />
          <q-btn
            flat
            @click="step = 3"
            color="primary"
            label="Back"
            class="q-ml-sm"
          />
        </q-stepper-navigation>
      </q-step>

      <q-step
        :name="5"
        title="Choose feats"
        icon="add_comment"
        :done="step > 5"
      >
        How do your Elven abilities manifest themselves?

        <q-separator />

        What are your character's unique abilities?

        <q-stepper-navigation>
          <q-btn @click="step = 6" color="primary" label="Continue" />
          <q-btn
            flat
            @click="step = 4"
            color="primary"
            label="Back"
            class="q-ml-sm"
          />
        </q-stepper-navigation>
      </q-step>

      <q-step :name="6" title="Choose a name" icon="add_comment">
        What is in a name? Everything! This is how other players will know and
        interact with you. There are few guidelines to a name. Just make it
        appropriate for a fantasy setting, and please avoid any names belonging
        to an existing IP.

        <q-input v-model="name" label="Name" />

        <q-stepper-navigation>
          <q-btn
            color="primary"
            label="Create & Play"
            @click="createCharacter('play')"
          />
          <q-btn
            color="primary"
            label="Create & View"
            disabled
            @click="createCharacter('view')"
          />
          <q-btn
            flat
            @click="step = 5"
            color="primary"
            label="Back"
            class="q-ml-sm"
          />
        </q-stepper-navigation>
      </q-step>
    </q-stepper>
  </div>
</template>

<script lang="ts">
import Vue from 'vue';
import { RaceInterface } from 'src/store/race/state';
import { AxiosResponse } from 'axios';

interface RaceOption {
  label: string;
  value: string;
}

export default {
  name: 'CharacterCreationWizard',
  components: {},
  data(): {
    step: number;
    age: number;
    haircolor: string;
    eyecolor: string;
    selectedEyeAccentColor: string;
    hairlength: string;
    hairstyle: string;
    skincolor: string;
    races: Record<string, RaceInterface>;
    selectedRace: string;
    eyeColorTypes: string[];
    selectedEyeColorType: string;
    height: string;
    lorem: string;
    name: string;
  } {
    return {
      lorem:
        'Lorem ipsum dolor, sit amet consectetur adipisicing elit. Itaque voluptatem totam, architecto cupiditate officia rerum, error dignissimos praesentium libero ab nemo provident incidunt ducimus iusto perferendis porro earum. Totam, numquam?',
      step: 1,
      age: 0,
      name: '',
      haircolor: '',
      // haircolors: [],
      eyecolor: '',
      selectedEyeAccentColor: '',
      // eyecolors: [],
      hairlength: '',
      // hairlengths: [],
      hairstyle: '',
      // hairstyles: [],
      skincolor: '',
      // skincolors: [],
      races: {},
      selectedRace: '',
      eyeColorTypes: [
        'solid',
        'complete heterochromia',
        'segmental heterochromia',
        'central heterochromia'
      ],
      selectedEyeColorType: 'solid',
      height: ''
    };
  },
  computed: {
    selectedHairColor: {
      // getter
      get: function(): string {
        if (this.haircolor === '' && this.haircolors.length > 0) {
          return this.randomElement(this.haircolors);
        } else if (this.haircolor !== '') {
          return this.haircolor;
        } else {
          return '';
        }
      },
      // setter
      set: function(selectedColor: string) {
        this.haircolor = selectedColor;
      }
    },
    haircolors: function(): string[] {
      if (this.selectedRace === '') {
        return [];
      } else {
        return this.races[this.selectedRace].hairColors;
      }
    },
    hairlengths: function(): string[] {
      if (this.selectedRace === '') {
        return [];
      } else {
        console.log(this.races[this.selectedRace]);
        return this.races[this.selectedRace].hairLengths;
      }
    },
    selectedHairLength: {
      // getter
      get: function(): string {
        if (this.hairlength === '' && this.hairlengths.length > 0) {
          return this.randomElement(this.hairlengths);
        } else if (this.hairlength !== '') {
          return this.hairlength;
        } else {
          return '';
        }
      },
      // setter
      set: function(selectedLength: string) {
        this.hairlength = selectedLength;
      }
    },
    selectedSkinColor: {
      // getter
      get: function(): string {
        if (this.skincolor === '' && this.skincolors.length > 0) {
          return this.randomElement(this.skincolors);
        } else if (this.skincolor !== '') {
          return this.skincolor;
        } else {
          return '';
        }
      },
      // setter
      set: function(selectedColor: string) {
        this.skincolor = selectedColor;
      }
    },
    selectedEyeColor: {
      // getter
      get: function(): string {
        if (this.eyecolor === '' && this.eyecolors.length > 0) {
          return this.randomElement(this.eyecolors);
        } else if (this.eyecolor !== '') {
          return this.eyecolor;
        } else {
          return '';
        }
      },
      // setter
      set: function(selectedColor: string) {
        this.eyecolor = selectedColor;
      }
    },
    selectedHeight: {
      // getter
      get: function(): string {
        if (this.height === '' && this.heights.length > 0) {
          return this.randomElement(this.heights);
        } else if (this.height !== '') {
          return this.height;
        } else {
          return '';
        }
      },
      // setter
      set: function(selectedHeight: string) {
        this.height = selectedHeight;
      }
    },
    heights: function(): string[] {
      console.log('computing heights');
      console.log(this.selectedRace);
      if (this.selectedRace === '') {
        return [];
      } else {
        console.log(this.races[this.selectedRace]);
        return this.races[this.selectedRace].heights;
      }
    },
    eyecolors: function(): string[] {
      console.log('computing eyecolors');
      console.log(this.selectedRace);
      if (this.selectedRace === '') {
        return [];
      } else {
        console.log(this.races[this.selectedRace]);
        return this.races[this.selectedRace].eyeColors;
      }
    },
    skincolors: function(): string[] {
      console.log('computing skincolors');
      console.log(this.selectedRace);
      if (this.selectedRace === '') {
        return [];
      } else {
        console.log(this.races[this.selectedRace]);
        return this.races[this.selectedRace].skinColors;
      }
    },
    hairstyles: function(): string[] {
      if (this.selectedRace === '' || this.hairlength === '') {
        return [];
      } else {
        let styles = this.races[this.selectedRace].hairStyles;

        return styles
          .filter(style => style.lengths.includes(this.hairlength))
          .map(style => style.style)
          .sort();
      }
    },
    selectedHairStyle: {
      // getter
      get: function(): string {
        console.log('computing selectedHairStyle get');
        console.log(this.hairstyles);
        if (this.hairstyle === '' && this.hairstyles.length > 0) {
          return this.randomElement(this.hairstyles);
        } else if (this.hairstyle !== '') {
          return this.hairstyle;
        } else {
          return '';
        }
      },
      // setter
      set: function(selectedStyle: string) {
        this.hairstyle = selectedStyle;
      }
    },
    maxAge: function(): number {
      console.log('computing maxAge');
      if (this.selectedRace === '') {
        return 60;
      } else {
        console.log(this.races[this.selectedRace]);
        return this.races[this.selectedRace].ageMax;
      }
    },
    minAge: function(): number {
      console.log('computing minAge');
      if (this.selectedRace === '') {
        return 18;
      } else {
        const races = this.races;
        let age: number = races[this.selectedRace].ageMin;
        return age;
      }
    },
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
    notBald: function(): boolean {
      return this.hairlength !== 'bald';
    },
    showEyeAccentColor: function(): boolean {
      return this.selectedEyeColorType !== 'solid';
    },
    selectedAge: {
      // getter
      get: function(): number {
        const max: number = this.maxAge;
        const min: number = this.minAge;
        if (this.age === 0) {
          return Math.floor(Math.random() * (max - min + 1) + min);
        } else {
          return this.age;
        }
      },
      // setter
      set: function(newAge: string) {
        this.age = parseInt(newAge);
      }
    }
  },
  created() {
    // fetch the data when the view is created and the data is
    // already being observed
    this.fetchCharacterCreationData();
  },
  methods: {
    fetchCharacterCreationData() {
      void this.$axios.get('characters/get-creation-data').then(result => {
        const data: RaceInterface[] = result.data;
        const races = result.data.reduce(
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
      const values = {
        age: this.selectedAge,
        eye_accent_color: this.selectedEyeAccentColor,
        eye_color: this.selectedEyeColor,
        eye_color_type: this.selectedEyeColorType,
        hair_color: this.selectedHairColor,
        hair_length: this.selectedHairLength,
        hair_style: this.selectedHairStyle,
        height: this.selectedHeight,
        name: this.name,
        race: this.selectedRace,
        skin_color: this.selectedSkinColor
      };

      const store = this.$store;
      const router = this.$router;

      void this.$axios
        .post('characters/create', values)
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
