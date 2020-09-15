<template>
  <div class="q-pa-md">
    <q-stepper v-model="step" vertical color="primary" animated header-nav>
      <q-step
        :name="1"
        title="Name"
        icon="fas fa-signature"
        :done="step > 1"
        :header-nav="step > 1 || !isNew"
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

          <q-btn
            v-if="!saveButtonDisabled"
            color="primary"
            label="Save"
            @click="saveArea"
          />

          <q-btn
            color="primary"
            label="Cancel"
            @click="cancel"
          />
        </q-stepper-navigation>
      </q-step>

      <q-step
        :name="2"
        title="Map Settings"
        icon="fas fa-globe"
        :done="step > 2"
        :header-nav="step > 2 || !isNew"
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

          <q-btn
            v-if="!saveButtonDisabled"
            color="primary"
            label="Save"
            @click="saveArea"
          />

          <q-btn
            color="primary"
            label="Cancel"
            @click="cancel"
          />
        </q-stepper-navigation>
      </q-step>

      <q-step
        :name="3"
        title="Description"
        icon="fas fa-signature"
        :done="step > 3"
        :header-nav="step > 3 || !isNew"
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

          <q-btn
            color="primary"
            label="Cancel"
            @click="cancel"
          />
        </q-stepper-navigation>
      </q-step>
    </q-stepper>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';

export default {
  name: 'AreaWizard',
  components: {},
  created() {
    if (this.isNew) {
      this.area = Object.assign({}, this.areaUnderConstruction);
    } else {
      this.area = Object.assign({}, this.selectedArea);
    }
  },
  computed: {
    selectedMapOption: {
      // getter
      get: function() {
        return { label: this.selectedMap.name, value: this.selectedMap.id };
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
      return this.area.name === '' || this.area.description === '' || this.area.mapId === '';
    },
    allowNameHeaderSelect: function() {
      return !this.isNew;
    },
    selectedMapName: function() {
      return this.selectedMap.name
    },
    mapOptions: function() {
      return this.maps.map(map => ({ label: map.name, value: map.id }));
    },
    ...mapGetters({
      maps: 'builder/maps',
      areaUnderConstruction: 'builder/areaUnderConstruction',
      selectedArea: 'builder/selectedArea',
      selectedMap: 'builder/selectedMap',
      isNew: 'builder/isAreaUnderConstructionNew'
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
        name: '',
        mapId: '',
        description: ''
      }
    };
  },
  methods: {
    cancel() {
      this.$store
        .dispatch('builder/putIsAreaUnderConstruction', false)
        .then(() =>
          this.$store.dispatch(
            'builder/putAreaUnderConstruction',
            this.selectedArea
          ).then(() => this.$emit('canceled'))
        );
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

      if (this.isNew) {
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
            if (this.isNew) {
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
    step: function () {
      this.$store.dispatch('builder/putAreaUnderConstruction', Object.assign({}, this.area))
    }
  }
};
</script>

<style></style>
