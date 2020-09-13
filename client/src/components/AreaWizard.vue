<template>
  <div class="q-pa-md">
    <q-stepper v-model="step" vertical color="primary" animated>
      <q-step
        :name="1"
        title="Name"
        icon="fas fa-signature"
        :done="step > 1"
        :caption="area.name"
      >
        Choose the name of the area. Does not have to be unique.

        <q-input v-model="area.name" label="Name" />

        <q-stepper-navigation>
          <q-btn
            :disabled="nameContinueButtonDisabled"
            @click="step = 2"
            color="primary"
            label="Continue"
          />
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
            v-model="selectedMapOption"
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
        <q-input
          v-model="area.description"
          label="Description"
          type="textarea"
        />

        <q-stepper-navigation>
          <q-btn
            :disabled="saveButtonDisabled"
            color="primary"
            label="Save"
            @click="saveArea"
          />

          <q-btn
            flat
            @click="step = 2"
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
import Vue from 'vue';

export default {
  name: 'AreaWizard',
  props: ['id', 'mapId'],
  components: {},
  created() {
    if (this.id !== '') {
      this.$store
        .dispatch('areas/fetchArea', this.id)
        .then(area => {
          this.area = area;
        })
        .catch(() => {
          alert('Something went wrong attemping to load the selected area.');
        });
    }

    if (this.mapId !== '') {
      this.area.mapId = this.mapId
    }
  },
  computed: {
    selectedMapOption: {
      // getter
      get: function() {
        if (this.selectedMapOptionValue !== '') {
          return this.selectedMapOptionValue;
        } else {
          const map = this.$store.getters['maps/getMapById'](this.mapId);
          return { label: map.name, value: map.id };
        }
      },
      // setter
      set: function(selectedOption) {
        this.area.mapId = selectedOption.value;
        this.selectedMapOptionValue = selectedOption;
        this.$emit('mapSelected', selectedOption.value);
      }
    },
    nameContinueButtonDisabled: function() {
      return this.area.name === '';
    },
    saveButtonDisabled: function() {
      return this.area.name === '' || this.area.description === '';
    },
    selectedMapName: function() {
      if (this.mapId !== '') {
        const map = this.$store.getters['maps/getMapById'](this.mapId);

        return map.name;
      } else {
        return '';
      }
    },
    mapOptions: function() {
      console.log('computing mapOptions');

      let mapOptions = this.$store.getters['maps/listAll'];

      mapOptions = mapOptions.map(map => ({ label: map.name, value: map.id }));

      return mapOptions;
    }
  },
  data() {
    return {
      map: '',
      step: 1,
      selectedMapOptionValue: '',
      area: {
        id: '',
        name: '',
        mapId: '',
        description: ''
      }
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
    },
    saveArea() {
      console.log('saveArea()');
      const params = {
        area: {id: this.area.id, name: this.area.name, map_id: this.area.mapId, description: this.area.description}
      };

      let request;

      if (this.id === '') {
        request = this.$axios.post('/areas', params);
      } else {
        request = this.$axios.patch('/areas/' + this.id, params);
      }

      request
        .then(result => {
          this.$store.commit('areas/putArea', result.data);
          this.$emit('saved', result.data.id);
        })
        .catch(function() {
          alert('Error saving');
        });
    }
  },
  watch: {
    mapId(value) {
      if (this.selectedMapOptionValue !== '' && value !== this.selectedMapOptionValue.value) {
        this.selectedMapOptionValue = '';
      }
    }
  }
};
</script>

<style></style>
