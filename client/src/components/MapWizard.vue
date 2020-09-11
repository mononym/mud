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
        Choose the name of the map. Must be a unique name.

        <q-input v-model="name" label="Name" />

        <q-stepper-navigation>
          <q-btn :disabled="nameContinueDisabled" @click="step = 2" color="primary" label="Continue" />
        </q-stepper-navigation>
      </q-step>

      <q-step
        :name="2"
        title="Description"
        icon="fas fa-signature"
        :done="step > 2"
      >
        <q-input v-model="description" label="Description" type="textarea" />

        <q-stepper-navigation>
          <q-btn color="primary" label="Save" @click="saveMap" />
          <q-btn
            :disabled="saveDisabled"
            flat
            @click="step = 1"
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
import { isNull } from 'util';

export default {
  name: 'MapWizard',
  components: {},
  created() {
    // look at values to see if there is an id for the map
    // if there is an id check the database by using a getter to see if the data needs to be loaded
    // if data needs to be loaded make a call to server to fetch the data and have it set the map data once loaded
    // If there is no id the values can be left blank and nothing needs to be done
    if (this.id !== '') {
      this.$store
        .dispatch('maps/fetchMap', this.id)
        .then(map => {
          this.id = map.id;
          this.name = map.name;
          this.description = map.description;
        })
        .catch(() => {
          alert('Something went wrong attemping to load the selected map.');
          this.id = '';
        });
    }
  },
  computed: {
    nameContinueDisabled() {
      return this.name === '';
    },
    saveDisabled() {
      return this.description === '';
    }
  },
  data() {
    return {
      id: '',
      name: '',
      description: '',
      step: 1
    };
  },
  validations: {},
  methods: {
    saveMap() {
      console.log('saveMap()');
      const params = { map: { name: this.name, description: this.description } };

      if (this.id === '') {
        this.$axios
          .post('/maps', params)
          .then(result => {
            this.$store.commit('maps/putMap', result.data);
            this.$emit('saved', result.data.id);
          })
          .catch(function() {
            alert('Error saving');
          });
      } else {
        this.$axios
          .patch('/maps/' + this.id, params)
          .then(result => {
            this.$store.commit('maps/putMap', result.data);
            this.$emit('saved', result.data.id);
          })
          .catch(function() {
            alert('Error saving');
          });
      }
    }
  }
};
</script>

<style></style>
