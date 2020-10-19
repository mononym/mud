<template>
  <q-stepper v-model="step" vertical color="primary" animated header-nav>
    <q-step
      :name="1"
      title="Details"
      icon="fas fa-signature"
      :done="step > 1"
      :header-nav="step > 1 || !isNew"
      :caption="raceUnderConstruction.singular"
    >
      <q-form class="">
        <q-input
          v-model="raceUnderConstruction.singular"
          filled
          label="Singular"
          lazy-rules
          :rules="[val => (val && val.length > 0) || 'Please type something']"
        />

        <q-input
          v-model="raceUnderConstruction.plural"
          filled
          label="Plural"
          lazy-rules
          :rules="[val => (val && val.length > 0) || 'Please type something']"
        />

        <q-input
          v-model="raceUnderConstruction.adjective"
          filled
          label="Adjective"
          lazy-rules
          :rules="[val => (val && val.length > 0) || 'Please type something']"
        />

        <q-input
          v-model="raceUnderConstruction.description"
          filled
          label="Description"
          lazy-rules
          :rules="[val => (val && val.length > 0) || 'Please type something']"
          type="textarea"
        />
      </q-form>

      <q-stepper-navigation>
        <q-btn
          v-show="!isNew"
          :disabled="detailsContinueButtonDisabled"
          color="primary"
          label="Continue"
          @click="step = 2"
        />

        <q-btn v-show="!isNew" color="primary" label="Save" @click="update" />

        <q-btn v-show="isNew" color="primary" label="Create" @click="create" />

        <q-btn color="primary" label="Cancel" @click="cancel" />
      </q-stepper-navigation>
    </q-step>

    <q-step
      :name="2"
      title="Features"
      icon="fas fa-globe"
      :done="step > 2"
      :header-nav="step > 2 || !isNew"
    >
      <q-list dense class="relative-position">
        <q-item v-for="item in featureListItems" :key="item.id">
          <q-item-section top class="col-shrink gt-sm">
            <q-icon
              v-if="!item.attached"
              name="fas fa-plus"
              class="text-blue cursor-pointer"
              style="font-size: 1.5rem;"
              @click="linkFeature(item.id)"
            />
            <q-icon
              v-if="item.attached"
              name="fas fa-minus cursor-pointer"
              class="text-red"
              style="font-size: 1.5rem;"
              @click="unlinkFeature(item.id)"
            />
          </q-item-section>
          <q-item-section top class="col gt-sm">
            <q-item-label class="q-mt-sm">{{ item.name }}</q-item-label>
          </q-item-section>
        </q-item>
        <q-inner-loading :showing="linking">
          <q-spinner-gears size="50px" color="primary" />
        </q-inner-loading>
      </q-list>

      <q-stepper-navigation>
        <q-btn color="primary" label="Continue" @click="step = 3" />
        <q-btn
          flat
          color="primary"
          label="Back"
          class="q-ml-sm"
          @click="step = 1"
        />

        <q-btn color="primary" label="Cancel" @click="cancel" />
      </q-stepper-navigation>
    </q-step>

    <!-- <q-step
      :name="3"
      title="Description"
      icon="fas fa-signature"
      :done="step > 3"
      :header-nav="step > 3 || !isNew"
    >
      <q-input v-model="area.description" label="Description" type="textarea" />

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

        <q-btn color="primary" label="Cancel" @click="cancel" />
      </q-stepper-navigation>
    </q-step> -->
  </q-stepper>
</template>

<script lang="ts">
import { CharacterRaceFeatureInterface } from 'src/store/characterRaceFeature/state';
import { RaceInterface } from 'src/store/race/state';
import raceState from 'src/store/race/state';
import { Prop } from 'vue/types/options';

export default {
  name: 'RaceWizard',
  components: {},
  props: {
    race: {
      type: Object as Prop<RaceInterface>,
      default: { ...raceState }
    },
    features: {
      type: Array as Prop<CharacterRaceFeatureInterface[]>,
      default: function() {
        return [];
      }
    }
  },
  data(): {
    linking: boolean;
    raceUnderConstruction: RaceInterface;
    step: number;
  } {
    return {
      linking: false,
      raceUnderConstruction: { ...raceState },
      step: 1
    };
  },
  computed: {
    isNew: function(): boolean {
      return this.race.id == '';
    },
    detailsContinueButtonDisabled: function(): boolean {
      return (
        this.race.singular == '' ||
        this.race.plural == '' ||
        this.race.adjective == '' ||
        this.race.description == ''
      );
    },
    saveButtonDisabled: function(): boolean {
      return this.detailsContinueButtonDisabled;
    },
    featureListItems: function(): {
      id: string;
      name: string;
      attached: boolean;
    }[] {
      console.log('gheuhgfeuhgdfkghj');
      const featuresAttached = this.raceUnderConstruction.features;
      const attachedIds = featuresAttached.map(feature => feature.id);
      const featuresNotAttached = this.features.filter(
        feature => !attachedIds.includes(feature.id)
      );

      const attachedItems = featuresAttached.map(function(feature) {
        return { id: feature.id, name: feature.name, attached: true };
      });

      const unattachedItems = featuresNotAttached.map(function(feature) {
        return { id: feature.id, name: feature.name, attached: false };
      });

      const allItems = attachedItems.concat(unattachedItems);

      return allItems.sort(function(a, b) {
        if (a.name < b.name) {
          return -1;
        } else if (a.name == b.name) {
          return 0;
        } else {
          return 1;
        }
      });
    }
  },
  created() {
    this.raceUnderConstruction = this.race;
  },
  methods: {
    cancel() {
      this.$emit('cancel');
    },
    create() {
      this.$axios
        .post('/character_races', this.raceUnderConstruction)
        .then(result => {
          this.raceUnderConstruction = result.data;
          this.$emit('created', result.data);
        })
        .catch(function() {
          alert('Error saving');
        });
    },
    update() {
      this.$axios
        .patch(
          '/character_races/' + this.raceUnderConstruction.id,
          this.raceUnderConstruction
        )
        .then(result => {
          this.raceUnderConstruction = result.data;
          this.$emit('updated', result.data);
        })
        .catch(function() {
          alert('Error saving');
        });
    },
    linkFeature(featureId: string) {
      this.linking = true;
      const self = this;

      this.$axios
        .post('/character_races/link_feature', {
          character_race_id: this.raceUnderConstruction.id,
          character_race_feature_id: featureId
        })
        .then(function(result) {
          self.raceUnderConstruction = result.data;
          self.linking = false;
        });
    },
    unlinkFeature(featureId: string) {
      const self = this;

      this.$axios
        .post('/character_races/unlink_feature', {
          character_race_id: this.raceUnderConstruction.id,
          character_race_feature_id: featureId
        })
        .then(function(result) {
          self.raceUnderConstruction = result.data;
          self.linking = false;
        });
    }
  }
};
</script>

<style></style>
