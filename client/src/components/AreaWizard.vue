<template>
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

      <q-input v-model="workingArea.name" label="Name" />

      <q-stepper-navigation>
        <q-btn
          :disabled="nameContinueButtonDisabled"
          color="primary"
          label="Continue"
          @click="step = 2"
        />

        <q-btn
          v-if="!saveButtonDisabled"
          color="primary"
          label="Save"
          @click="save"
        />

        <q-btn color="primary" label="Cancel" @click="cancel" />
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
          v-model="workingArea.mapId"
          :options="maps"
          option-label="name"
          option-value="id"
          :display-value="
            maps[mapsIndex[workingArea.mapId]] != undefined
              ? maps[mapsIndex[workingArea.mapId]].name
              : ''
          "
          label="Map"
          emit-value
        />
      </q-form>

      <q-stepper-navigation>
        <q-btn color="primary" label="Continue" @click="step = 3" />
        <q-btn
          flat
          color="primary"
          label="Back"
          class="q-ml-sm"
          @click="step = 1"
        />

        <q-btn
          v-if="!saveButtonDisabled"
          color="primary"
          label="Save"
          @click="save"
        />

        <q-btn color="primary" label="Cancel" @click="cancel" />
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
        v-model="workingArea.description"
        label="Description"
        type="textarea"
      />

      <q-stepper-navigation>
        <q-btn
          :disabled="saveButtonDisabled"
          color="primary"
          label="Save"
          @click="save"
        />

        <q-btn
          flat
          color="primary"
          label="Back"
          class="q-ml-sm"
          @click="step = 2"
        />

        <q-btn color="primary" label="Cancel" @click="cancel" />
      </q-stepper-navigation>
    </q-step>
  </q-stepper>
</template>

<script lang="ts">
import { mapGetters } from 'vuex';
import areaState, { AreaInterface } from 'src/store/area/state';
import { MapInterface } from 'src/store/map/state';
import { Prop } from 'vue/types/options';

export default {
  name: 'AreaWizard',
  props: {
    area: {
      type: Object as Prop<AreaInterface>,
      required: true
    },
    map: {
      type: Object as Prop<MapInterface>,
      required: true
    }
  },
  data(): {
    step: number;
    workingArea: AreaInterface;
  } {
    return {
      step: 1,
      workingArea: { ...areaState }
    };
  },
  computed: {
    mapsIndex: function(): Record<string, number> {
      const mapIndex = {};

      this.maps.forEach(function(map, index) {
        mapIndex[map.id] = index;
      });

      return mapIndex;
    },
    nameContinueButtonDisabled: function(): boolean {
      return this.workingArea.name == '';
    },
    saveButtonDisabled: function(): boolean {
      return (
        this.workingArea.name == '' ||
        this.workingArea.description == '' ||
        this.workingArea.mapId == ''
      );
    },
    allowNameHeaderSelect: function() {
      return this.area.id != '';
    },
    isNew: function() {
      return this.area.id == '';
    },
    selectedMapName: function() {
      return this.map.name;
    },
    mapOptions: function() {
      return this.maps.map(function(map) {
        return {
          label: map.name,
          value: map.id
        };
      });
    },
    ...mapGetters({
      maps: 'maps/listAll'
    })
  },
  created(): void {
    this.workingArea = { ...this.area };
    this.workingArea.mapId = this.map.id;
  },
  methods: {
    cancel(): void {
      this.$emit('cancel');
    },
    save(): void {
      const newArea = this.area.id == '';

      const params = {
        area: {
          name: this.area.name,
          map_id: this.area.mapId,
          description: this.area.description
        }
      };

      let request;
      if (newArea) {
        request = this.$axios.post('/areas', params);
      } else {
        request = this.$axios.patch('/areas/' + this.area.id, params);
      }

      // The area was created in a different map than it started out in.
      // if (this.area.mapId != this.map.id) {
      request
        .then(result => {
          // emit that a thing was saved so that everything can be adjusted
          this.$emit('saved', result.data);
        })
        // } else {
        //   request
        //     .then(result => {
        //       if (this.isNew) {
        //         this.$store
        //           .dispatch('builder/putArea', result.data)
        //           .then(() => {
        //             this.$store
        //               .dispatch('builder/selectArea', result.data)
        //               .then(() =>
        //                 this.$store.dispatch(
        //                   'builder/putIsAreaUnderConstruction',
        //                   false
        //                 )
        //               )
        //               .then(() => {
        //                 this.$emit('saved');
        //               });
        //           });
        //       } else {
        //         this.$store
        //           .dispatch('builder/updateArea', result.data)
        //           .then(() =>
        //             this.$store.dispatch(
        //               'builder/putIsAreaUnderConstruction',
        //               false
        //             )
        //           )
        //           .then(() => {
        //             this.$emit('saved');
        //           });
        //       }
        //     })
        .catch(function() {
          alert('Error saving');
        });
    }
    // },
    // watch: {
    //   area: {
    //     // This will let Vue know to look inside the array
    //     deep: true,
    //     // We have to move our method to a handler field
    //     handler() {
    //       this.$store.dispatch(
    //         'builder/putAreaUnderConstruction',
    //         Object.assign({}, this.area)
    //       );
    //     }
  }
};
</script>

<style></style>
