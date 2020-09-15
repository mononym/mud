<template>
  <div class="q-pa-md">
    <q-stepper v-model="step" vertical color="primary" animated>
      <q-step
        :name="1"
        title="Name"
        icon="fas fa-signature"
        :done="step > 1"
        :caption="map.name"
      >
        Choose the name of the map. Must be a unique name.

        <q-input v-model="map.name" label="Name" />

        <q-stepper-navigation>
          <q-btn
            :disabled="nameContinueDisabled"
            @click="step = 2"
            color="primary"
            label="Continue"
          />

          <q-btn color="primary" label="Cancel" @click="cancel" />
        </q-stepper-navigation>
      </q-step>

      <q-step
        :name="2"
        title="Description"
        icon="fas fa-signature"
        :done="step > 2"
      >
        <q-input
          v-model="map.description"
          label="Description"
          type="textarea"
        />

        <q-stepper-navigation>
          <q-btn
            :disabled="descriptionButtonsDisabled"
            @click="step = 3"
            color="primary"
            label="Continue"
          />
          <q-btn
            flat
            @click="step = 1"
            color="primary"
            label="Back"
            class="q-ml-sm"
          />

          <q-btn color="primary" label="Cancel" @click="cancel" />
        </q-stepper-navigation>
      </q-step>

      <q-step :name="3" title="Config" icon="fas fa-gear" :done="step > 3">
        <q-slider
          v-model="map.mapSize"
          :min="500"
          :max="1000000"
          :step="100"
          snap
          label
          color="purple"
        />

        <q-stepper-navigation>
          <q-btn color="primary" label="Save" @click="saveMap" />
          <q-btn
            flat
            @click="step = 2"
            color="primary"
            label="Back"
            class="q-ml-sm"
          />

          <q-btn color="primary" label="Cancel" @click="cancel" />
        </q-stepper-navigation>
      </q-step>
    </q-stepper>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';

export default {
  name: 'MapWizard',
  components: {},
  created() {
    if (this.isNew) {
      this.map = Object.assign({}, this.mapUnderConstruction);
    } else {
      this.map = Object.assign({}, this.selectedMap);
    }
  },
  computed: {
    nameContinueDisabled() {
      return this.map.name === '';
    },
    descriptionButtonsDisabled() {
      return this.map.description === '';
    },
    saveDisabled() {
      return this.map.description === '';
    },
    ...mapGetters({
      mapUnderConstruction: 'builder/mapUnderConstruction',
      selectedMap: 'builder/selectedMap',
      isNew: 'builder/isMapUnderConstructionNew'
    })
  },
  data() {
    return {
      step: 1,
      map: {
        id: '',
        name: '',
        description: '',
        mapSize: 0,
        gridSize: 0,
        maxZoom: 0,
        minZoom: 0,
        defaultZoom: 0
      }
    };
  },
  methods: {
    cancel() {
      this.$store
        .dispatch('builder/putIsMapUnderConstruction', false)
        .then(() =>
          this.$store.dispatch('builder/fetchAreasForMap', this.selectedMap.id)
        )
        .then(() => this.$emit('canceled'));
    },
    saveMap() {
      const params = {
        map: {
          name: this.map.name,
          description: this.map.description
          // map_size: this.map.map_size,
          // grid_size: this.map.grid_size,
          // max_zoom: this.map.max_zoom
        }
      };

      let request;

      if (this.isNew) {
        request = this.$axios.post('/maps', params);
      } else {
        request = this.$axios.patch('/maps/' + this.map.id, params);
      }

      request
        .then(result => {
          this.$store.commit('maps/putMap', result.data);
          this.$emit('saved');
        })
        .catch(function() {
          alert('Error saving');
        });
    }
  },
  watch: {
    step: function() {
      this.$store.dispatch(
        'builder/putMapUnderConstruction',
        Object.assign({}, this.map)
      );
    }
  }
};
</script>

<style></style>
