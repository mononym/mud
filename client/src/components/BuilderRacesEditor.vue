<template>
  <div class="fit">
    <q-tabs
      v-model="tab"
      dense
      class="text-grey"
      active-color="primary"
      indicator-color="primary"
      align="justify"
      narrow-indicator
    >
      <q-tab name="races" label="Races" />
      <q-tab name="features" label="Features" />
    </q-tabs>

    <q-separator />

    <q-tab-panels v-model="tab" class="tab-panel">
      <q-tab-panel class="flex column" name="races">
        <!-- Races Table -->
        <q-table
          title="Races"
          :data="races"
          :columns="raceColumns"
          :visible-columns="visibleRaceColumns"
          row-key="id"
          flat
          bordered
          class="col"
          :selected.sync="selectedRaceRow"
          :pagination="initialPagination"
          :rows-per-page-options="[0]"
          :pagination-label="getRacesPaginationLabel"
        >
          <template v-slot:body-cell="props">
            <q-td
              :props="props"
              class="cursor-pointer"
              @click.exact="toggleSingleRaceRow(props.row)"
            >
              {{ props.value }}
            </q-td>
          </template>
        </q-table>
        <q-btn-group spread class="col-shrink">
          <q-btn class="" flat @click="addRace">Add</q-btn>
          <q-btn :disabled="raceButtonsDisabled" class="" flat @click="editRace"
            >Edit</q-btn
          >
          <q-btn
            :disabled="raceButtonsDisabled"
            class=""
            flat
            @click="deleteRace"
            >Delete</q-btn
          >
        </q-btn-group>
        <!-- Race Details View -->
        <q-card v-show="raceBottomView == 'details'" class="col">
          <q-card-section horizontal>
            <q-img
              class="col-2"
              :src="selectedRace.portrait"
              :alt="selectedRace.singular"
            />

            <q-card-section class="col flex column">
              <q-card-section class="col-shrink">
                <p class="full-width text-h4">
                  {{ selectedRace.singular }}
                </p>
                <p>
                  {{ selectedRace.description }}
                </p>
              </q-card-section>
              <q-card-section class="col">
                <q-toolbar class="bg-primary text-white shadow-2">
                  <q-toolbar-title>Features</q-toolbar-title>
                </q-toolbar>
                <q-list dense>
                  <q-item
                    v-for="race in selectedRace.features"
                    v-show="raceIsSelected"
                    :key="race.id"
                  >
                    <q-item-section top class="col-2 gt-sm">
                      <q-item-label class="q-mt-sm">{{
                        race.name
                      }}</q-item-label>
                    </q-item-section>
                  </q-item>
                </q-list>
              </q-card-section>
            </q-card-section>
          </q-card-section>
        </q-card>
        <race-wizard
          v-if="raceBottomView == 'editor'"
          :race="{ ...raceUnderConstruction }"
          :features="features"
          @cancel="cancelRaceEdit"
          @created="createdRace"
          @updated="updatedRace"
        />
      </q-tab-panel>

      <q-tab-panel class="flex column" name="features">
        <!-- Top half spans 50% height and 100% width -->
        <div v-show="featureTopView == 'table'" class="col flex column">
          <q-table
            title="Features"
            :data="features"
            :columns="characterFeatureColumns"
            :visible-columns="visibleFeatureColumns"
            row-key="id"
            flat
            bordered
            class="col"
            :selected.sync="selectedFeatureRow"
            :pagination="initialPagination"
            :rows-per-page-options="[0]"
            :pagination-label="getFeaturesPaginationLabel"
          >
            <template v-slot:body-cell="props">
              <q-td
                :props="props"
                class="cursor-pointer"
                @click.exact="toggleSingleFeatureRow(props.row)"
              >
                {{ props.value }}
              </q-td>
            </template>
          </q-table>
          <q-btn-group spread class="col-shrink">
            <q-btn class="" flat @click="addFeature">Add</q-btn>
            <q-btn
              :disabled="featureButtonsDisabled"
              class=""
              flat
              @click="editFeature"
              >Edit</q-btn
            >
            <q-btn
              :disabled="featureButtonsDisabled"
              class=""
              flat
              @click="deleteFeature"
              >Delete</q-btn
            >
          </q-btn-group>
        </div>
        <!-- Top half spans 50% height and 100% width -->
        <q-form
          v-show="featureTopView == 'editor'"
          class="col-12 q-gutter-md"
          @submit="saveFeature"
        >
          <q-input
            v-model="featureUnderConstruction.name"
            filled
            label="Name"
            lazy-rules
            :rules="[val => (val && val.length > 0) || 'Please type something']"
          />

          <q-input
            v-model="featureUnderConstruction.key"
            filled
            label="Key"
            lazy-rules
            :rules="[val => (val && val.length > 0) || 'Please type something']"
          />

          <q-input
            v-model="featureUnderConstruction.field"
            filled
            label="Field"
            lazy-rules
            :rules="[val => (val && val.length > 0) || 'Please type something']"
          />

          <q-select
            v-model="featureUnderConstruction.type"
            :options="featureTypeOptions"
            label="Types"
          />

          <div>
            <q-btn label="Save" color="primary" @click="saveFeature" />
            <q-btn
              label="Cancel"
              color="primary"
              class="q-ml-sm"
              @click="cancelFeatureEdit"
            />
          </div>
        </q-form>

        <div class="col flex row bottom">
          <!-- Bottom half spans 50% height and 50% width -->
          <div v-show="optionView == 'table'" class="col-6 flex column">
            <q-table
              title="Options"
              :data="selectedFeatureOptions"
              :columns="characterFeatureOptionsColumns"
              :visible-columns="visibleFeatureOptionsColumns"
              flat
              bordered
              class="col"
              :selected.sync="selectedOptionRow"
              :pagination="initialPagination"
              :rows-per-page-options="[0]"
              :pagination-label="getOptionsPaginationLabel"
            >
              <template v-slot:body-cell="props">
                <q-td
                  :props="props"
                  class="cursor-pointer"
                  @click.exact="toggleSingleOptionRow(props.row)"
                >
                  {{ props.value }}
                </q-td>
              </template>
            </q-table>
            <q-btn-group spread class="col-shrink">
              <q-btn
                :disabled="optionAddButtonDisabled"
                class="col"
                flat
                @click="addOption"
                >Add</q-btn
              >
              <q-btn
                :disabled="optionButtonsDisabled"
                class="col"
                flat
                @click="editOption"
                >Edit</q-btn
              >
              <q-btn
                :disabled="optionButtonsDisabled"
                class="col"
                flat
                @click="deleteOption"
                >Delete</q-btn
              >
            </q-btn-group>
          </div>
          <!-- Bottom half spans 50% height and 50% width -->
          <q-form
            v-show="optionView == 'editor'"
            class="col-6 q-gutter-md"
            @submit="saveOption"
          >
            <q-input
              v-show="selectedFeatureType == 'select'"
              v-model="optionUnderConstruction.value"
              filled
              label="Value"
              lazy-rules
              :rules="[
                val => (val && val.length > 0) || 'Please type something'
              ]"
            />

            <q-input
              v-show="selectedFeatureType == 'range'"
              v-model="optionUnderConstruction.min"
              filled
              label="Min"
              lazy-rules
              type="number"
              :rules="[
                val => (val && val.length > 0) || 'Please type something'
              ]"
            />

            <q-input
              v-show="selectedFeatureType == 'range'"
              v-model="optionUnderConstruction.max"
              filled
              label="Max"
              type="number"
              lazy-rules
              :rules="[
                val => (val && val.length > 0) || 'Please type something'
              ]"
            />

            <q-toggle
              v-show="selectedFeatureType == 'toggle'"
              v-model="optionUnderConstruction.toggle"
              label="Toggle"
            />

            <div>
              <q-btn
                label="Save"
                color="primary"
                :disabled="optionSaveButtonDisabled"
                @click="saveOption"
              />
              <q-btn
                label="Cancel"
                color="primary"
                class="q-ml-sm"
                @click="cancelOptionEdit"
              />
            </div>
          </q-form>
          <!-- Bottom half spans 50% height and 50% width -->
          <div v-show="conditionView == 'table'" class="col-6 flex column">
            <q-table
              title="Conditions"
              :data="selectedOptionConditions"
              :columns="featureOptionConditionColumns"
              :visible-columns="visibleOptionConditionsColumns"
              flat
              bordered
              class="col"
              :selected.sync="selectedConditionRow"
              :pagination="initialPagination"
              :rows-per-page-options="[0]"
              :pagination-label="getConditionsPaginationLabel"
            >
              <template v-slot:body-cell="props">
                <q-td
                  :props="props"
                  class="cursor-pointer"
                  @click.exact="toggleSingleConditionRow(props.row)"
                >
                  {{ props.value }}
                </q-td>
              </template>
            </q-table>
            <q-btn-group stretch class="col-shrink">
              <q-btn
                :disabled="conditionAddButtonDisabled"
                class="col"
                flat
                @click="addCondition"
                >Add</q-btn
              >
              <q-btn
                :disabled="conditionButtonsDisabled"
                class="col"
                flat
                @click="editCondition"
                >Edit</q-btn
              >
              <q-btn
                :disabled="conditionButtonsDisabled"
                class="col"
                flat
                @click="deleteCondition"
                >Delete</q-btn
              >
            </q-btn-group>
          </div>
          <!-- Bottom half spans 50% height and 50% width -->
          <q-form v-show="conditionView == 'editor'" class="col-6 q-gutter-md">
            <q-select
              v-model="conditionUnderConstruction.key"
              :options="conditionKeyOptions"
              label="Key"
              option-value="key"
              option-label="key"
              emit-value
            />

            <q-select
              v-model="conditionUnderConstruction.comparison"
              :options="conditionComparisonTypeOptions"
              label="Comparison"
            />

            <q-table
              v-show="showConditionSelect"
              title="Values"
              :data="conditionSelectOptions"
              :columns="conditionSelectColumns"
              :visible-columns="visibleConditionFeatureColumns"
              row-key="value"
              selection="multiple"
              :selected.sync="conditionOptionSelected"
            />

            <q-slider
              v-show="showConditionRange"
              v-model="conditionUnderConstruction.range"
              :min="conditionRangeMinOption"
              :max="conditionRangeMaxOption"
              :step="1"
              label
              label-always
            />

            <q-toggle
              v-show="showConditionToggle"
              v-model="conditionUnderConstruction.toggle"
            />

            <div>
              <q-btn
                label="Save"
                color="primary"
                :disabled="conditionSaveButtonDisabled"
                @click="saveCondition"
              />
              <q-btn
                label="Cancel"
                color="primary"
                class="q-ml-sm"
                @click="cancelConditionEdit"
              />
            </div>
          </q-form>
        </div>
      </q-tab-panel>
    </q-tab-panels>
  </div>
</template>

<style lang="sass">
.tab-panel {height: calc(100% - 37px)}
.q-tab-panel {padding: 0px}
</style>

<script lang="ts">
import Vue from 'vue';
import { mapGetters } from 'vuex';
import {
  CharacterRaceFeatureInterface,
  CharacterRaceFeatureOptionInterface,
  CharacterRaceFeatureOptionConditionInterface
} from 'src/store/characterRaceFeature/state';
import featureState from 'src/store/characterRaceFeature/state';
import {
  ConditionState,
  OptionState
} from 'src/store/characterRaceFeature/state';
import { RaceInterface } from 'src/store/race/state';
import raceState from 'src/store/race/state';
import RaceWizard from '../components/RaceWizard.vue';

interface CommonColumnInterface {
  name: string;
  required: boolean;
  label: string;
  sortable: boolean;
  align: string;
}

let characterFeatureColumns: [
  {
    name: 'name';
    required: true;
    label: 'Name';
    sortable: true;
    align: 'center';
  },
  {
    name: 'field';
    required: true;
    label: 'Field';
    sortable: true;
    align: 'center';
  },
  {
    name: 'key';
    required: true;
    label: 'Key';
    sortable: true;
    align: 'center';
  },
  {
    name: 'type';
    required: true;
    align: 'center';
    label: 'Type';
    sortable: true;
  }
];

interface CharacterFeatureOptionsColumns {
  name: string;
  required: boolean;
  label: string;
  sortable: boolean;
  align: string;
}

let characterFeatureOptionsColumns: [
  {
    name: 'value';
    required: false;
    label: 'Value';
    sortable: true;
    align: 'center';
    field: 'value';
  },
  {
    name: 'min';
    required: false;
    align: 'center';
    label: 'Min';
    sortable: false;
    field: 'min';
  },
  {
    name: 'max';
    required: false;
    align: 'center';
    label: 'Max';
    sortable: false;
  },
  {
    name: 'toggle';
    required: false;
    align: 'center';
    label: 'Toggle';
    sortable: false;
  }
];

let featureOptionConditionColumns: [
  {
    name: 'key';
    required: false;
    align: 'center';
    label: 'Key';
    sortable: true;
    field: 'key';
  },
  {
    name: 'comparison';
    required: false;
    label: 'Comparison';
    sortable: true;
    align: 'center';
    field: 'comparison';
  },
  {
    name: 'values';
    required: false;
    align: 'center';
    label: 'Values';
    sortable: false;
    field: 'values';
  }
];

let conditionSelectColumns: [
  {
    name: 'value';
    required: false;
    align: 'center';
    label: 'Value';
    sortable: true;
    field: 'value';
  }
];

let raceColumns: [
  {
    name: 'singular';
    required: false;
    align: 'center';
    label: 'Singlular';
    sortable: true;
    field: 'singular';
  },
  {
    name: 'plural';
    required: false;
    align: 'center';
    label: 'Plural';
    sortable: true;
    field: 'plural';
  },
  {
    name: 'adjective';
    required: false;
    align: 'center';
    label: 'Adjective';
    sortable: true;
    field: 'adjective';
  },
  {
    name: 'description';
    required: false;
    align: 'center';
    label: 'Description';
    sortable: true;
    field: 'description';
  }
];

export default {
  name: 'BuildRacesEditor',
  components: { RaceWizard },
  data(): {
    tab: string;
    conditionSelectColumns: CommonColumnInterface[];
    characterFeatureColumns: CommonColumnInterface[];
    characterFeatureOptionsColumns: CharacterFeatureOptionsColumns[];
    featureOptionConditionColumns: CharacterFeatureOptionsColumns[];
    features: CharacterRaceFeatureInterface[];
    visibleFeatureColumns: string[];
    visibleOptionConditionsColumns: string[];
    visibleConditionFeatureColumns: string[];
    selectedFeatureRow: CharacterRaceFeatureInterface[];
    selectedOptionRow: CharacterRaceFeatureOptionInterface[];
    selectedConditionRow: CharacterRaceFeatureOptionConditionInterface[];
    featureTopView: string;
    optionView: string;
    conditionView: string;
    featureUnderConstruction: CharacterRaceFeatureInterface;
    optionUnderConstruction: CharacterRaceFeatureOptionInterface;
    conditionUnderConstruction: CharacterRaceFeatureOptionConditionInterface;
    featureIsNew: boolean;
    conditionIsNew: boolean;
    optionIsNew: boolean;
    featureTypeOptions: string[];
    featureIndex: Record<string, number>;
    initialPagination: { rowsPerPage: number };
    conditionOptionSelected: CharacterRaceFeatureOptionInterface[];
    // Race stuff
    raceColumns: CommonColumnInterface[];
    raceIndex: Record<string, number>;
    raceIsNew: boolean;
    races: RaceInterface[];
    raceUnderConstruction: RaceInterface;
    selectedRaceRow: RaceInterface[];
    visibleRaceColumns: string[];
    raceBottomView: string;
  } {
    return {
      // Common stuff
      tab: 'races',
      initialPagination: {
        rowsPerPage: 0
      },
      // Feature stuff
      characterFeatureColumns,
      features: [],
      featureIndex: {},
      visibleFeatureColumns: ['name', 'field', 'key', 'type'],
      selectedFeatureRow: [],
      featureTypeOptions: ['range', 'select', 'toggle'],
      featureTopView: 'table',
      featureIsNew: false,
      featureUnderConstruction: { ...featureState },
      // Option stuff
      characterFeatureOptionsColumns,
      selectedOptionRow: [],
      optionView: 'table',
      optionIsNew: false,
      optionUnderConstruction: { ...OptionState },
      // Condition Stuff
      conditionSelectColumns,
      featureOptionConditionColumns,
      visibleConditionFeatureColumns: ['value'],
      visibleOptionConditionsColumns: [
        'key',
        'comparison',
        'select',
        'toggle',
        'range'
      ],
      selectedConditionRow: [],
      conditionView: 'table',
      conditionIsNew: false,
      conditionUnderConstruction: { ...ConditionState },
      conditionOptionSelected: [],
      // Races stuff
      visibleRaceColumns: ['singular', 'plural', 'adjective', 'description'],
      raceColumns,
      selectedRaceRow: [],
      races: [],
      raceIndex: {},
      raceIsNew: false,
      raceUnderConstruction: { ...raceState },
      raceBottomView: 'details'
    };
  },
  computed: {
    optionSaveButtonDisabled: function(): boolean {
      return (
        (this.selectedFeatureType == 'select' &&
          this.optionUnderConstruction.value == '') ||
        (this.selectedFeatureType == 'range' &&
          this.optionUnderConstruction.min >
            this.optionUnderConstruction.max) ||
        // will be a toggle type which has no check, can be saved in either true or false position
        false
      );
    },
    conditionSaveButtonDisabled: function(): boolean {
      return (
        this.conditionUnderConstruction.key == '' ||
        this.conditionUnderConstruction.comparison == ''
      );
    },
    showConditionRange: function(): boolean {
      return (
        this.conditionFeature.type == 'range' &&
        this.conditionFeature.key !== ''
      );
    },
    showConditionSelect: function(): boolean {
      return (
        this.conditionFeature.type == 'select' &&
        this.conditionFeature.key !== ''
      );
    },
    showConditionToggle: function(): boolean {
      return (
        this.conditionFeature.type == 'toggle' &&
        this.conditionFeature.key !== ''
      );
    },
    conditionFeature: function(): CharacterRaceFeatureInterface {
      if (this.conditionUnderConstruction.key != '') {
        return this.getFeatureByKey(this.conditionUnderConstruction.key);
      } else {
        return { ...featureState };
      }
    },
    conditionRangeMaxOption: function(): number {
      if (this.conditionFeature.type == 'range') {
        return this.conditionFeature.options[0].max;
      } else {
        return 0;
      }
    },
    conditionRangeMinOption: function(): number {
      if (this.conditionFeature.type == 'range') {
        return this.conditionFeature.options[0].min;
      } else {
        return 0;
      }
    },
    conditionSelectOptions: function(): CharacterRaceFeatureOptionInterface[] {
      if (this.conditionFeature.type == 'select') {
        console.log('tuyriughr');
        return this.conditionFeature.options;
      } else {
        return [];
      }
    },
    conditionComparisonTypeOptions: function(): string[] {
      if (this.conditionFeature.type == 'range') {
        return ['==', '!=', '<', '>', '<=', '>='];
      } else if (this.conditionFeature.type == 'select') {
        return ['in', 'not in'];
      } else if (this.conditionFeature.type == 'toggle') {
        return ['=='];
      } else {
        return [];
      }
    },
    conditionKeyOptions: function(): CharacterRaceFeatureInterface[] {
      if (this.selectedFeatureRow.length > 0) {
        return this.features.filter(
          feature => feature.id != this.selectedFeatureRow[0].id
        );
      } else {
        return [];
      }
    },
    selectedFeatureOptions: function(): CharacterRaceFeatureOptionInterface[] {
      if (this.selectedFeatureRow.length > 0) {
        return this.selectedFeatureRow[0].options;
      } else {
        return [];
      }
    },
    selectedFeatureType: function(): string {
      if (this.selectedFeatureRow.length > 0) {
        return this.selectedFeatureRow[0].type;
      } else {
        return '';
      }
    },
    optionAddButtonDisabled: function(): boolean {
      return (
        this.selectedFeatureRow.length == 0 ||
        (this.selectedFeatureType !== 'select' &&
          this.selectedFeatureRow[0].options.length > 0)
      );
    },
    conditionAddButtonDisabled: function(): boolean {
      return this.selectedOptionRow.length == 0;
    },
    conditionButtonsDisabled: function(): boolean {
      return this.selectedConditionRow.length == 0;
    },
    optionButtonsDisabled: function(): boolean {
      return this.selectedOptionRow.length == 0;
    },
    featureButtonsDisabled: function(): boolean {
      return this.selectedFeatureRow.length == 0;
    },
    selectedFeatureRowName: function(): string {
      if (this.selectedFeatureRow.length > 0) {
        return this.selectedFeatureRow[0].name;
      } else {
        return '';
      }
    },
    selectedOptionConditions: function(): CharacterRaceFeatureOptionConditionInterface[] {
      if (this.selectedOptionRow.length > 0) {
        return this.selectedOptionRow[0].conditions.map(function(condition) {
          return {
            id: condition.id,
            key: condition.key,
            comparison: condition.comparison,
            toggle: condition.toggle,
            select: condition.select,
            range: condition.range
          };
        });
      } else {
        return [];
      }
    },
    visibleFeatureOptionsColumns: function(): string[] {
      if (this.selectedFeatureRow.length > 0) {
        const type = this.selectedFeatureRow[0].type;

        if (type == 'select') {
          return ['value'];
        } else if (type == 'range') {
          return ['min', 'max'];
        } else if (type == 'toggle') {
          return ['toggle'];
        } else {
          return [];
        }
      } else {
        return [];
      }
    },
    disableFeatureButtons: function(): boolean {
      return this.selectedFeatureRow.length == 0;
    },
    disableOptionButtons: function(): boolean {
      return this.selectedOptionRow.length == 0;
    },
    ...mapGetters({
      instanceBeingBuilt: 'builder/instanceBeingBuilt'
    }),
    // Race stuff
    selectedRace: function(): RaceInterface {
      if (this.selectedRaceRow.length > 0) {
        return this.selectedRaceRow[0];
      } else {
        return { ...raceState };
      }
    },
    raceIsSelected: function(): boolean {
      return this.selectedRaceRow.length > 0;
    },
    raceButtonsDisabled: function(): boolean {
      return this.selectedRaceRow.length == 0;
    }
  },
  created() {
    let self = this;

    this.$axios.get('/character_races').then(function(results) {
      console.log('races');
      console.log(results);

      // This explicit mapping is so that the keys in the object are in a deterministic
      // order, which impacts how the data is displayed in the data table.
      self.races = results.data.map(function(race: RaceInterface) {
        return {
          id: race.id,
          singular: race.singular,
          plural: race.plural,
          adjective: race.adjective,
          description: race.description,
          portrait: race.portrait,
          features: race.features,
          instance_id: race.instance_id
        };
      });

      // self.races = results.data;

      self.races.forEach((race, index) => {
        Vue.set(self.raceIndex, race.id, index);
      });
    });

    this.$axios.get('/character_race_features').then(function(results) {
      console.log('character_race_features');
      console.log(results);

      // This explicit mapping is so that the keys in the object are in a deterministic
      // order, which impacts how the data is displayed in the data table.
      self.features = results.data.map(function(
        feature: CharacterRaceFeatureInterface
      ) {
        return {
          id: feature.id,
          name: feature.name,
          key: feature.key,
          field: feature.field,
          type: feature.type,
          options: feature.options
        };
      });

      self.features.forEach((feature, index) => {
        Vue.set(self.featureIndex, feature.id, index);
      });
    });
  },
  // mounted() {},
  methods: {
    getFeatureByKey(key: string): CharacterRaceFeatureInterface {
      return (
        this.features.find(feature => feature.key == key) || { ...featureState }
      );
    },
    getOptionsPaginationLabel(
      start: number,
      end: number,
      total: number
    ): string {
      return total.toString() + ' Option(s)';
    },
    getFeaturesPaginationLabel(
      start: number,
      end: number,
      total: number
    ): string {
      return total.toString() + ' Feature(s)';
    },
    getConditionsPaginationLabel(
      start: number,
      end: number,
      total: number
    ): string {
      return total.toString() + ' Condition(s)';
    },
    cancelConditionEdit() {
      this.conditionView = 'table';
      this.conditionIsNew = false;
      this.conditionUnderConstruction = { ...ConditionState };
    },
    cancelOptionEdit() {
      this.optionView = 'table';
      this.optionIsNew = false;
      this.optionUnderConstruction = { ...OptionState };

      this.featureUnderConstruction = { ...featureState };
    },
    cancelFeatureEdit() {
      this.featureTopView = 'table';
      this.featureIsNew = false;
      this.featureUnderConstruction = { ...featureState };
    },
    saveCondition() {
      console.log('oiureoiutre');

      this.conditionUnderConstruction.select = this.conditionOptionSelected.map(
        option => option.value
      );

      if (this.conditionIsNew) {
        this.optionUnderConstruction.conditions.push(
          this.conditionUnderConstruction
        );
      } else {
        const self = this;
        const updatedConditions = this.optionUnderConstruction.conditions.map(
          function(condition) {
            if (condition.id == self.conditionUnderConstruction.id) {
              return self.conditionUnderConstruction;
            } else {
              return condition;
            }
          }
        );

        this.optionUnderConstruction.conditions = updatedConditions;
      }

      this.saveOption();
      this.cancelConditionEdit();
    },
    saveOption() {
      if (this.optionIsNew) {
        this.featureUnderConstruction.options.push(
          this.optionUnderConstruction
        );
      } else {
        const self = this;
        const updatedOptions = this.featureUnderConstruction.options.map(
          function(option) {
            if (option.id == self.optionUnderConstruction.id) {
              return self.optionUnderConstruction;
            } else {
              return option;
            }
          }
        );

        this.featureUnderConstruction.options = updatedOptions;
      }

      this.saveFeature();
      this.cancelOptionEdit();
    },
    saveFeature() {
      let request;

      if (this.featureIsNew) {
        this.featureUnderConstruction.instance_id = this.instanceBeingBuilt.id;

        if (
          this.featureUnderConstruction.type == 'range' ||
          this.featureUnderConstruction.type == 'toggle'
        ) {
          this.featureUnderConstruction.options.push({ ...OptionState });
        }

        request = this.$axios.post(
          '/character_race_features',
          this.featureUnderConstruction
        );
      } else {
        request = this.$axios.patch(
          '/character_race_features/' + this.featureUnderConstruction.id,
          this.featureUnderConstruction
        );
      }

      request
        .then(result => {
          if (this.featureIsNew) {
            Vue.set(this.featureIndex, result.data.id, this.features.length);

            this.features.push(result.data);
          } else {
            Vue.set(
              this.features,
              this.featureIndex[result.data.id],
              result.data
            );
          }

          this.featureIsNew = false;
          this.featureUnderConstruction = { ...featureState };
          this.featureTopView = 'table';
        })
        .catch(function() {
          alert('Error saving');
        })
        .then();
    },
    addFeature() {
      this.featureIsNew = true;
      this.featureTopView = 'editor';
      this.cancelConditionEdit();
      this.cancelOptionEdit();
    },
    editFeature() {
      this.featureUnderConstruction = this.selectedFeatureRow[0];
      this.featureIsNew = false;
      this.featureTopView = 'editor';
      this.cancelConditionEdit();
      this.cancelOptionEdit();
    },
    deleteFeature() {
      const self = this;

      self.$axios
        .delete('/character_race_features/' + self.selectedFeatureRow[0].id)
        .then(function() {
          self.features.splice(
            self.featureIndex[self.selectedFeatureRow[0].id],
            1
          );

          self.selectedFeatureRow = [];
          self.featureIndex = {};
          self.features.forEach((feature, index) => {
            Vue.set(self.featureIndex, feature.id, index);
          });
        })
        .catch(function() {
          alert('Error when fetching maps');
        });

      this.cancelConditionEdit();
      this.cancelOptionEdit();
      this.cancelFeatureEdit();
    },
    addCondition() {
      this.featureUnderConstruction = this.selectedFeatureRow[0];
      this.optionUnderConstruction = this.selectedOptionRow[0];
      this.featureIsNew = false;
      this.optionIsNew = false;
      this.conditionIsNew = true;
      this.conditionView = 'editor';
    },
    addOption() {
      this.featureUnderConstruction = this.selectedFeatureRow[0];
      this.featureIsNew = false;
      this.optionIsNew = true;
      this.optionView = 'editor';
      this.cancelConditionEdit();
    },
    editOption() {
      this.featureUnderConstruction = this.selectedFeatureRow[0];
      this.featureIsNew = false;
      this.optionUnderConstruction = this.selectedOptionRow[0];
      this.optionIsNew = false;
      this.optionView = 'editor';
      this.cancelConditionEdit();
    },
    editCondition() {
      this.featureUnderConstruction = this.selectedFeatureRow[0];
      this.featureIsNew = false;
      this.optionUnderConstruction = this.selectedOptionRow[0];
      this.optionIsNew = false;
      this.conditionUnderConstruction = this.selectedConditionRow[0];
      this.conditionIsNew = false;
      this.conditionView = 'editor';
    },
    deleteOption() {
      this.featureUnderConstruction = this.selectedFeatureRow[0];
      this.optionUnderConstruction = this.selectedOptionRow[0];
      // remove option from the options and save the feature
      const self = this;
      console.log('asjhdaskjhd');
      const updatedOptions = this.selectedFeatureOptions.filter(function(
        option
      ) {
        return option.id != self.optionUnderConstruction.id;
      });

      this.featureUnderConstruction.options = updatedOptions;

      this.saveFeature();
      this.selectedConditionRow = [];
      this.cancelConditionEdit();
      this.selectedOptionRow = [];
      this.cancelOptionEdit();
    },
    deleteCondition() {
      this.featureUnderConstruction = this.selectedFeatureRow[0];
      this.optionUnderConstruction = this.selectedOptionRow[0];
      this.conditionUnderConstruction = this.selectedConditionRow[0];

      const self = this;
      console.log('asjhdaskjhd');
      const updatedConditions = this.selectedOptionConditions.filter(function(
        condition
      ) {
        return condition.id != self.conditionUnderConstruction.id;
      });

      this.optionUnderConstruction.conditions = updatedConditions;

      this.saveOption();
      this.selectedConditionRow = [];
      this.cancelConditionEdit();
    },
    filter() {
      console.log('filter');
    },
    toggleSingleFeatureRow(row: CharacterRaceFeatureInterface) {
      this.selectedFeatureRow = [row];
      Vue.set(this, 'selectedOptionRow', []);
    },
    toggleSingleOptionRow(row: CharacterRaceFeatureOptionInterface) {
      Vue.set(this.selectedOptionRow, 0, row);
    },
    toggleSingleConditionRow(row: CharacterRaceFeatureOptionInterface) {
      Vue.set(this.selectedConditionRow, 0, row);
    },
    // ******************
    // Races stuff
    // ******************
    getRacesPaginationLabel(start: number, end: number, total: number): string {
      return total.toString() + ' Race(s)';
    },
    toggleSingleRaceRow(row: RaceInterface) {
      this.selectedRaceRow = [row];
      this.cancelRaceEdit();
    },
    editRace() {
      this.raceUnderConstruction = { ...this.selectedRaceRow[0] };
      this.raceIsNew = false;
      this.raceBottomView = 'editor';
    },
    addRace() {
      this.raceUnderConstruction = { ...raceState };
      this.raceIsNew = true;
      this.raceBottomView = 'editor';
    },
    cancelRaceEdit() {
      this.raceBottomView = 'details';
      this.raceIsNew = false;
      this.raceUnderConstruction = { ...raceState };
    },
    raceSaved(race: RaceInterface) {
      let request;

      if (this.raceIsNew) {
        this.raceUnderConstruction.instance_id = this.instanceBeingBuilt.id;

        request = this.$axios.post(
          '/character_races',
          this.raceUnderConstruction
        );
      } else {
        request = this.$axios.patch(
          '/character_races/' + this.raceUnderConstruction.id,
          this.raceUnderConstruction
        );
      }

      request
        .then(result => {
          if (this.raceIsNew) {
            Vue.set(this.raceIndex, result.data.id, this.races.length);

            this.races.push(result.data);
            this.raceIsNew = false;
            this.raceUnderConstruction = { ...raceState };
          } else {
            Vue.set(this.races, this.raceIndex[result.data.id], result.data);
            this.raceUnderConstruction = { ...raceState };
          }

          this.raceIsNew = false;
          this.raceBottomView = 'details';
          this.selectedRaceRow = [result.data];
        })
        .catch(function() {
          alert('Error saving');
        })
        .then();
    },
    createdRace(race: RaceInterface) {
      Vue.set(this.raceIndex, race.id, this.races.length);

      this.races.push(race);
      this.raceIsNew = false;
      this.raceUnderConstruction = { ...raceState };
      this.cancelRaceEdit();
    },
    updatedRace(race: RaceInterface) {
      console.log('updatedRace');
      Vue.set(this.races, this.raceIndex[race.id], race);
      this.raceUnderConstruction = { ...raceState };
      this.selectedRaceRow = [race];
      this.cancelRaceEdit();
    },
    deleteRace() {
      const self = this;

      self.$axios
        .delete('/character_races/' + self.selectedRaceRow[0].id)
        .then(function() {
          self.races.splice(self.raceIndex[self.selectedRaceRow[0].id], 1);

          self.selectedRaceRow = [];
          self.raceIndex = {};
          self.races.forEach((race, index) => {
            Vue.set(self.raceIndex, race.id, index);
          });
        });

      this.cancelRaceEdit();
    }
  }
};
</script>
