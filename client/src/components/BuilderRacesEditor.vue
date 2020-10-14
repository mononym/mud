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
      <q-tab-panel class="" name="races">
        <div class="text-h6">Mails</div>
        Lorem ipsum dolor sit amet consectetur adipisicing elit.
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
          <q-form
            v-show="conditionView == 'editor'"
            class="col-6 q-gutter-md"
          >
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

interface CharacterFeatureColumns {
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

export default {
  name: 'BuildRacesEditor',
  components: {},
  data(): {
    tab: string;
    conditionSelectColumns: CharacterFeatureColumns[];
    characterFeatureColumns: CharacterFeatureColumns[];
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
  } {
    return {
      tab: 'races',
      conditionSelectColumns,
      characterFeatureColumns,
      characterFeatureOptionsColumns,
      featureOptionConditionColumns,
      features: [],
      featureIndex: {},
      visibleFeatureColumns: ['name', 'field', 'key', 'type'],
      visibleOptionConditionsColumns: [
        'key',
        'comparison',
        'select',
        'toggle',
        'range'
      ],
      visibleConditionFeatureColumns: ['value'],
      selectedFeatureRow: [],
      selectedOptionRow: [],
      selectedConditionRow: [],
      featureTopView: 'table',
      optionView: 'table',
      conditionView: 'table',
      featureUnderConstruction: { ...featureState },
      featureTypeOptions: ['range', 'select', 'toggle'],
      featureIsNew: false,
      conditionIsNew: false,
      optionIsNew: false,
      initialPagination: {
        rowsPerPage: 0
      },
      optionUnderConstruction: { ...OptionState },
      conditionUnderConstruction: { ...ConditionState },
      conditionOptionSelected: []
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
    })
  },
  created() {
    let self = this;

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
  mounted() {},
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

      console.log('herer');

      request
        .then(result => {
          if (this.featureIsNew) {
            Vue.set(this.featureIndex, result.data.id, this.features.length);

            this.features.push(result.data);
            this.featureIsNew = false;
            this.featureUnderConstruction = { ...featureState };
            this.featureTopView = 'table';
          } else {
            Vue.set(
              this.features,
              this.featureIndex[result.data.id],
              result.data
            );
            this.featureIsNew = false;
            this.featureUnderConstruction = { ...featureState };
            this.featureTopView = 'table';
          }
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
          console.log('sweong hwsrhskhjr');
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
    }
  }
};
</script>
