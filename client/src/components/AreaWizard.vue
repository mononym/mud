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
import { mapGetters } from 'vuex';

export default {
  name: 'AreaWizard',
  props: [],
  components: {},
  created() {
    if (this.$store.getters['builder/isAreaSelected']) {
      this.area = { ...this.$store.getters['builder/selectedArea'] };
    }
  },
  computed: {
    selectedMapOption: {
      // getter
      get: function() {
        const map = this.$store.getters['builder/selectedMap'];
        return { label: map.name, value: map.id };
      },
      // setter
      set: function(selectedOption) {
        this.$store
          .dispatch('builder/selectMap', selectedOption.value)
          .then(() => {
            // this.$store.dispatch('builder/fetchAreasForMap', selectedOption.value)
          });
        this.area.mapId = selectedOption.value;

        if (this.originalMapId === '') {
          this.originalMapId = selectedOption.value;
          this.mapChanged = true;
        } else if (this.originalMapId === selectedOption.value) {
          this.originalMapId = '';
          this.mapChanged = false;
        }
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
        const map = this.$store.getters['maps/getMapById'];

        return map.name;
      } else {
        return '';
      }
    },
    mapOptions: function() {
      return this.maps.map(map => ({ label: map.name, value: map.id }));
    },
    ...mapGetters({
      maps: 'builder/maps',
      cloneSelectedArea: 'builder/cloneSelectedArea'
    })
  },
  data() {
    return {
      originalMapId: '',
      mapChanged: false,
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
      const params = {
        area: {
          name: this.area.name,
          map_id: this.area.mapId,
          description: this.area.description
        }
      };

      let request;
      const isNew = !this.$store.getters['builder/isAreaSelected'];

      if (isNew || this.cloneSelectedArea) {
        request = this.$axios.post('/areas', params);
      } else {
        request = this.$axios.patch('/areas/' + this.area.id, params);
      }

      this.$store.dispatch('builder/putIsAreaUnderConstruction', false);

      if (this.mapChanged) {
        request.then((result) => {
          this.$store
            .dispatch('builder/fetchAreasForMap', this.area.mapId)
            .then(() =>
              this.$store
                .dispatch('builder/selectArea', result.data.id)
                .then(() => this.$emit('saved'))
            );
        });
      } else {
        request
          .then(result => {
            if (isNew || this.cloneSelectedArea) {
              this.$store.dispatch('builder/putCloneSelectedArea', false);

              this.$store.dispatch('builder/putArea', result.data).then(() => {
                this.$store
                  .dispatch('builder/selectArea', result.data.id)
                  .then(() => {
                    this.$emit('saved');
                  });
              });
            } else {
              this.$store
                .dispatch('builder/updateArea', result.data)
                .then(() => {
                  this.$emit('saved');
                });
            }
          })
          .catch(function() {
            alert('Error saving');
          });
      }
    }
  },
  watch: {
    area: {
      handler(area) {
        console.log('watch area');
        console.log({ ...area });
        this.$store.dispatch('builder/putAreaUnderConstruction', { ...area });
        console.log('dispatched');
      },
      deep: true
    }
  }
};
</script>

<style></style>
