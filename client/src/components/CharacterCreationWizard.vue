<template>
  <div class="q-pa-md">
    <q-stepper v-model="step" vertical color="primary" animated>
      <q-step
        :name="1"
        title="Select a race"
        icon="fas fa-users"
        :done="step > 1"
        :caption="race"
      >
        The choice of character race can impact the experience of playing the
        game, from choice of feats to interactions with NPC's.

        <div class="q-pa-md">
          <q-carousel
            v-model="race"
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
              v-model="race"
              :options="[
                { label: 'Elf', value: 'Elf' },
                { label: 'Human', value: 'Human' },
                { label: 'Dwarf', value: 'Dwarf' },
                { label: 'Gnome', value: 'Gnome' },
                { label: 'Half Elf', value: 'Half Elf' },
                { label: 'Half Dwarf', value: 'Half Dwarf' },
                { label: 'Half Giant', value: 'Half Giant' },
                { label: 'Shapeshifter', value: 'Shapeshifter' },
                { label: 'Halfling', value: 'Halfling' }
              ]"
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
        :caption="selectedAge"
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
              label="Hair Colour"
            />
            <q-select
              v-model="selectedHairLength"
              :options="hairlengths"
              label="Hair Length"
            />
            <q-select
              v-model="selectedHairStyle"
              :options="hairstyles"
              label="Hair Style"
            />
            <q-select
              v-model="selectedEyeColor"
              :options="eyecolors"
              label="Eye Colour"
            />
            <q-select
              v-model="selectedSkinColor"
              :options="skincolors"
              label="Skin Colour"
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

         <q-input v-model="name" label="Standard" />

        <q-stepper-navigation>
          <q-btn color="primary" label="Finish" />
          <q-btn
            flat
            @click="step = 4"
            color="primary"
            label="Back"
            class="q-ml-sm"
          />
        </q-stepper-navigation>
      </q-step>
    </q-stepper>
  </div>
</template>

<script>
import { set } from '@vue/composition-api';
import { defineComponent } from '@vue/composition-api'
import Vue from 'vue';
// import { validationMixin } from 'vuelidate'
// import { helpers, required } from 'vuelidate/lib/validators'

export default {
  name: 'CharacterCreationWizard',
  // mixins: [validationMixin],
  components: {},
  created() {
    // fetch the data when the view is created and the data is
    // already being observed
    this.fetchCharacterCreationData();
  },
  computed: {
    selectedHairColor: {
      // getter
      get: function() {
        console.log('computing selectedHairColor get');
        console.log(this.haircolors);
        if (this.haircolor === '' && this.haircolors.length > 0) {
          return this.randomElement(this.haircolors);
        } else if (this.haircolor !== '') {
          return this.haircolor;
        } else {
          return '';
        }
      },
      // setter
      set: function(selectedColor) {
        console.log('computing selectedHairColor set');
        console.log(selectedColor);
        console.log(this.haircolor);
        this.haircolor = selectedColor;
        console.log(this.haircolor);
      }
    },
    haircolors: function() {
      console.log('computing haircolors');
      console.log(this.race);
      if (this.race === '') {
        return [];
      } else {
        console.log(this.races[this.race]);
        return this.races[this.race].hair_colors;
      }
    },
    hairlengths: function() {
      console.log('computing hairlengths');
      console.log(this.race);
      if (this.race === '') {
        return [];
      } else {
        console.log(this.races[this.race]);
        return this.races[this.race].hair_lengths;
      }
    },
    selectedHairLength: {
      // getter
      get: function() {
        console.log('computing selectedHairLength get');
        console.log(this.hairlengths);
        if (this.hairlength === '' && this.hairlengths.length > 0) {
          return this.randomElement(this.hairlengths);
        } else if (this.hairlength !== '') {
          return this.hairlength;
        } else {
          return '';
        }
      },
      // setter
      set: function(selectedLength) {
        console.log('computing selectedHairLength set');
        console.log(selectedLength);
        console.log(this.hairlength);
        this.hairlength = selectedLength;
        console.log(this.hairlength);
      }
    },
    selectedSkinColor: {
      // getter
      get: function() {
        console.log('computing selectedSkinColor get');
        console.log(this.skincolors);
        if (this.skincolor === '' && this.skincolors.length > 0) {
          return this.randomElement(this.skincolors);
        } else if (this.skincolor !== '') {
          return this.skincolor;
        } else {
          return '';
        }
      },
      // setter
      set: function(selectedColor) {
        console.log('computing selectedSkinColor set');
        console.log(selectedColor);
        console.log(this.skincolor);
        this.skincolor = selectedColor;
        console.log(this.skincolor);
      }
    },
    selectedEyeColor: {
      // getter
      get: function() {
        console.log('computing selectedEyeColor get');
        console.log(this.eyecolors);
        if (this.eyecolor === '' && this.eyecolors.length > 0) {
          return this.randomElement(this.eyecolors);
        } else if (this.eyecolor !== '') {
          return this.eyecolor;
        } else {
          return '';
        }
      },
      // setter
      set: function(selectedColor) {
        console.log('computing selectedEyeColor set');
        console.log(selectedColor);
        console.log(this.selectedColor);
        this.eyecolor = selectedColor;
        console.log(this.eyecolor);
      }
    },
    eyecolors: function() {
      console.log('computing eyecolors');
      console.log(this.race);
      if (this.race === '') {
        return [];
      } else {
        console.log(this.races[this.race]);
        return this.races[this.race].eye_colors;
      }
    },
    skincolors: function() {
      console.log('computing skincolors');
      console.log(this.race);
      if (this.race === '') {
        return [];
      } else {
        console.log(this.races[this.race]);
        return this.races[this.race].skin_colors;
      }
    },
    hairstyles: function() {
      console.log('computing hairstyles');
      console.log(this.hairlength);
      if (this.race === '' || this.hairlength === '') {
        return [];
      } else {
        console.log(this.races[this.race]);
        let styles = this.races[this.race].hair_styles;
        styles = styles
          .filter(style => style.lengths.includes(this.hairlength))
          .map(style => style.style)
          .sort();
        return styles;
      }
    },
    selectedHairStyle: {
      // getter
      get: function() {
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
      set: function(selectedStyle) {
        console.log('computing selectedHairStyle set');
        console.log(selectedStyle);
        console.log(this.selectedStyle);
        this.hairstyle = selectedStyle;
        console.log(this.hairstyle);
      }
    },
    maxAge: function() {
      console.log('computing maxAge');
      if (this.race === '') {
        return 60;
      } else {
        console.log(this.races[this.race]);
        return this.races[this.race].age_max;
      }
    },
    minAge: function() {
      console.log('computing minAge');
      if (this.race === '') {
        return 18;
      } else {
        console.log(this.races[this.race]);
        let age  = this.races[this.race].age_min;
        return age;
      }
    },
    notBald: function() {
      return this.hairlength !== 'bald'
    },
    selectedAge: {
    // getter
      get: function () {
        if (this.age === '0') {
          return Math.floor(Math.random() * (this.maxAge - this.minAge + 1) + this.minAge).toString();
        } else {
          return this.age;
        }
      },
    // setter
      set: function (newAge) {
        this.age = newAge.toString()
      }
    }
  },
  data() {
    return {
      lorem:
        'Lorem ipsum dolor, sit amet consectetur adipisicing elit. Itaque voluptatem totam, architecto cupiditate officia rerum, error dignissimos praesentium libero ab nemo provident incidunt ducimus iusto perferendis porro earum. Totam, numquam?',
      step: 1,
      muds: [
        {
          label: 'Dragon Realms',
          value: 'dragon-realms',
          description: 'A place with adventure, and all that.',
          category: '1'
        }
      ],
      age: '0',
      name: '',
      haircolor: '',
      // haircolors: [],
      eyecolor: '',
      // eyecolors: [],
      hairlength: '',
      // hairlengths: [],
      hairstyle: '',
      // hairstyles: [],
      skincolor: '',
      // skincolors: [],
      races: {},
      race: ''
    };
  },
  validations: {},
  methods: {
    fetchCharacterCreationData() {
      void this.$axios.get('characters/get-creation-data').then(result => {
        console.log(result);
        console.log(this.randomElement(result.data));
        // set(this, 'races', result.data)
        Vue.set(this, 'races', result.data);
        Vue.set(
          this,
          'race',
          this.randomElement(Object.values(result.data)).singular
        );
        // this.races = result.data
      });

      return true;
    },
    randomElement(array) {
      return array[Math.floor(Math.random() * array.length)];
    }
  }
};
</script>

<style>
#authFormWrapper {
  display: flex;
}
</style>
