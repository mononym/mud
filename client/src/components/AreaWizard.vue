<template>
  <div class="q-pa-md">
    <q-stepper v-model="step" vertical color="primary" animated>
      <q-step
        :name="1"
        title="Name"
        icon="fas fa-signature"
        :done="step > 1"
        :caption="name"
      >
        Choose the name of the area. Does not have to be unique.

        <q-input v-model="name" label="Name" />

        <q-stepper-navigation>
          <q-btn @click="step = 2" color="primary" label="Continue" />
        </q-stepper-navigation>
      </q-step>

      <q-step
        :name="2"
        title="Map Settings"
        icon="fas fa-globe"
        :done="step > 2"
        :caption="selectedMapName"
      >
        <q-form class="q-gutter-md">
            <q-select
              v-model="selectedMap"
              :options="mapOptions"
              label="Map"
            />
        </q-form>

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
        title="Description"
        icon="fas fa-signature"
        :done="step > 3"
      >
        The description is what the players see

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
        title="Scenery"
        icon="fas fa-mountain"
        :done="step > 4"
      >
        Pieces of scenery are special items that belong to a room.

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
        title="Links"
        icon="fas fa-link"
        :done="step > 5"
      >
        Set up connections between rooms, such as obvious exits, audio/visual links, portals, and so on.

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

      <q-step :name="6" title="Scripts" icon="fas fa-code">

        Scripts

        <q-stepper-navigation>
          <q-btn color="primary" label="Create" @click="createCharacter" />
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

<script>
import { set } from '@vue/composition-api';
import Vue from 'vue';

export default {
  name: 'AreaWizard',
  props: ['mapId'],
  components: {},
  created() {
    // this.fetchCharacterCreationData();
  },
  computed: {
    selectedMap: {
      // getter
      get: function() {
        // console.log(this.haircolors);
        // if (this.map === '' && this.maps.length > 0) {
        //   return this.randomElement(this.haircolors);
        // } else if (this.haircolor !== '') {
        //   return this.haircolor;
        // } else {
        //   return '';
        // }
        return this.map;
      },
      // setter
      set: function(selectedMap) {
        this.map = selectedMap;
      }
    }
   },
  data() {
    return {
      age: '0',
      name: '',
      haircolor: '',
      eyecolor: '',
      selectedEyeAccentColor: '',
      hairlength: '',
      hairstyle: '',
      skincolor: '',
      races: {},
      selectedRace: '',
      eyeColorTypes: ['solid', 'complete heterochromia', 'segmental heterochromia', 'central heterochromia'],
      selectedEyeColorType: 'solid',
      height: '',
      map: ''
    };
  },
  validations: {},
  methods: {
    fetchCharacterCreationData() {
      void this.$axios.get('characters/get-creation-data').then(result => {
        console.log(result);
        console.log(this.randomElement(result.data));
        Vue.set(this, 'races', result.data);
        Vue.set(
          this,
          'selectedRace',
          this.randomElement(Object.values(result.data)).singular
        );
      });

      return true;
    }
  }
};
</script>

<style>

</style>
