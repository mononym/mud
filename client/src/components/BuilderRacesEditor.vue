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
        <div class="col top">
          <!-- Top half spans 50% height and 100% width -->
          <div v-show="featureTopView == 'table'" class="flex column">
              <q-table
                title="Character Features"
                :data="features"
                :columns="characterFeatureColumns"
                :visible-columns="visibleFeatureColumns"
                row-key="id"
                flat
                bordered
                class="col-grow"
                virtual-scroll
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
              label="Feature Name"
              lazy-rules
              :rules="[
                val => (val && val.length > 0) || 'Please type something'
              ]"
            />

            <q-input
              v-model="featureUnderConstruction.key"
              filled
              label="Feature Key"
              lazy-rules
              :rules="[
                val => (val && val.length > 0) || 'Please type something'
              ]"
            />

            <q-input
              v-model="featureUnderConstruction.field"
              filled
              label="Feature Field"
              lazy-rules
              :rules="[
                val => (val && val.length > 0) || 'Please type something'
              ]"
            />

            <q-select
              v-model="featureUnderConstruction.type"
              :options="featureTypeOptions"
              label="Standard"
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
        </div>

        <div class="col flex row bottom">
          <!-- Bottom half spans 50% height and 50% width -->
          <q-card v-show="optionView == 'table'" class="col-6 flex column">
            <q-table
              title="Feature Options"
              :data="selectedFeatureOptions"
              :columns="characterFeatureOptionsColumns"
              :visible-columns="visibleFeatureOptionsColumns"
              flat
              bordered
              virtual-scroll
              class="col-grow"
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
            <q-card-actions class="col-shrink flex row">
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
            </q-card-actions>
          </q-card>
          <!-- Bottom half spans 50% height and 50% width -->
          <q-form
            v-show="optionView == 'editor'"
            class="col-6 q-gutter-md"
            @submit="saveFeatureOption"
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
              :rules="[
                val => (val && val.length > 0) || 'Please type something'
              ]"
            />

            <q-input
              v-show="selectedFeatureType == 'range'"
              v-model="optionUnderConstruction.max"
              filled
              label="Max"
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
              <q-btn label="Save" color="primary" @click="saveFeatureOption" />
              <q-btn
                label="Cancel"
                color="primary"
                class="q-ml-sm"
                @click="cancelOptionEdit"
              />
            </div>
          </q-form>
          <!-- Bottom half spans 50% height and 50% width -->
          <q-card v-show="conditionView == 'table'" class="col-6 flex column">
            <q-table
              title="Option Conditions"
              :data="selectedOptionConditions"
              :columns="featureOptionConditionColumns"
              :visible-columns="visibleOptionConditionsColumns"
              flat
              bordered
              virtual-scroll
              class="col-grow"
              :selected.sync="selectedOptionConditionRow"
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
            <q-card-actions class="flex row col-shrink">
              <q-btn :disabled="conditionAddButtonDisabled" class="col" flat
                >Add</q-btn
              >
              <q-btn :disabled="conditionButtonsDisabled" class="col" flat
                >Edit</q-btn
              >
              <q-btn :disabled="conditionButtonsDisabled" class="col" flat
                >Delete</q-btn
              >
            </q-card-actions>
          </q-card>
          <!-- Bottom half spans 50% height and 50% width -->
          <q-form
            v-show="conditionView == 'editor'"
            class="col-6 q-gutter-md"
            @submit="saveFeature"
          >
            <q-input
              v-model="featureUnderConstruction.name"
              filled
              label="Key"
              lazy-rules
              :rules="[
                val => (val && val.length > 0) || 'Please type something'
              ]"
            />

            <q-select
              v-model="featureUnderConstruction.type"
              :options="featureTypeOptions"
              label="Comparison"
            />

            <q-input
              v-model="featureUnderConstruction.field"
              filled
              label="Values"
              lazy-rules
              :rules="[
                val => (val && val.length > 0) || 'Please type something'
              ]"
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

export default {
  name: 'BuildRacesEditor',
  components: {},
  data(): {
    tab: string;
    characterFeatureColumns: CharacterFeatureColumns[];
    characterFeatureOptionsColumns: CharacterFeatureOptionsColumns[];
    featureOptionConditionColumns: CharacterFeatureOptionsColumns[];
    features: CharacterRaceFeatureInterface[];
    visibleFeatureColumns: string[];
    visibleOptionConditionsColumns: string[];
    selectedFeatureRow: CharacterRaceFeatureInterface[];
    selectedOptionRow: CharacterRaceFeatureOptionInterface[];
    selectedOptionConditionRow: CharacterRaceFeatureOptionConditionInterface[];
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
    selectedFeatureOptions: CharacterRaceFeatureOptionInterface[];
    initialPagination: { rowsPerPage: number };
  } {
    return {
      tab: 'races',
      characterFeatureColumns,
      characterFeatureOptionsColumns,
      featureOptionConditionColumns,
      features: [],
      selectedFeatureOptions: [],
      featureIndex: {},
      visibleFeatureColumns: ['name', 'field', 'key', 'type'],
      visibleOptionConditionsColumns: ['key', 'comparison', 'values'],
      selectedFeatureRow: [],
      selectedOptionRow: [],
      selectedOptionConditionRow: [],
      featureTopView: 'table',
      optionView: 'table',
      conditionView: 'table',
      featureUnderConstruction: { ...featureState },
      featureTypeOptions: ['range', 'select'],
      featureIsNew: false,
      conditionIsNew: false,
      optionIsNew: false,
      initialPagination: {
        rowsPerPage: 0
      },
      optionUnderConstruction: { ...OptionState },
      conditionUnderConstruction: { ...ConditionState }
    };
  },
  computed: {
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
      return this.selectedOptionConditionRow.length == 0;
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
            values: condition.values
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
    saveFeatureOption() {
      if (this.optionIsNew) {
        this.featureUnderConstruction.options.push(
          this.optionUnderConstruction
        );
      } else {
        const updatedOptions = this.selectedFeatureOptions.map(function(
          option
        ) {
          if (option.id == this.optionUnderConstruction.id) {
            return this.optionUnderConstruction;
          } else {
            return option;
          }
        });

        this.featureUnderConstruction.options = updatedOptions;
      }

      this.saveFeature();
      this.cancelOptionEdit();
    },
    saveFeature() {
      let request;

      if (this.featureIsNew) {
        this.featureUnderConstruction.instance_id = this.instanceBeingBuilt.id;
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
    },
    editFeature() {
      this.featureUnderConstruction = this.selectedFeatureRow[0];
      this.featureIsNew = false;
      this.featureTopView = 'editor';
    },
    deleteFeature() {
      console.log('deleteFeature');
    },
    addOption() {
      this.featureUnderConstruction = this.selectedFeatureRow[0];
      this.featureIsNew = false;
      this.optionIsNew = true;
      this.optionView = 'editor';
    },
    editOption() {
      this.featureUnderConstruction = this.selectedFeatureRow[0];
      this.featureIsNew = false;
      this.optionUnderConstruction = this.selectedOptionRow[0];
      this.optionIsNew = false;
      this.optionView = 'editor';
    },
    deleteOption() {
      console.log('deleteOption');
    },
    filter() {
      console.log('filter');
    },
    toggleSingleFeatureRow(row: CharacterRaceFeatureInterface) {
      this.selectedFeatureRow = [row];
      Vue.set(this, 'selectedFeatureOptions', row.options);
      Vue.set(this, 'selectedOptionRow', []);
    },
    toggleSingleOptionRow(row: CharacterRaceFeatureOptionInterface) {
      Vue.set(this.selectedOptionRow, 0, row);
    },
    toggleSingleConditionRow(row: CharacterRaceFeatureOptionInterface) {
      Vue.set(this.selectedOptionConditionRow, 0, row);
    }
  }
};
</script>
