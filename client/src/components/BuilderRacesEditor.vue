<template>
  <q-card class="flex column">
    <q-card-section class="q-pa-none col-grow flex column">
      <q-tabs
        v-model="tab"
        dense
        class="text-grey col-shrink"
        active-color="primary"
        indicator-color="primary"
        align="justify"
        narrow-indicator
      >
        <q-tab name="races" label="Races" />
        <q-tab name="features" label="Features" />
      </q-tabs>

      <q-separator />

      <q-tab-panels v-model="tab" class="col-grow">
        <q-tab-panel name="races">
          <div class="text-h6">Mails</div>
          Lorem ipsum dolor sit amet consectetur adipisicing elit.
        </q-tab-panel>

        <q-tab-panel name="features">
          <div v-show="featureView == 'table'">
            <q-table
              title="Character Features"
              :data="features"
              :columns="characterFeatureColumns"
              :visible-columns="visibleFeatureColumns"
              row-key="id"
              flat
              bordered
              class="fit"
              :selected.sync="selectedRow"
              virtual-scroll
            >
              <template v-slot:top>
                <q-btn
                  class="q-ma-sm"
                  color="primary"
                  label="Add Feature"
                  @click="addFeature"
                />
                <q-btn
                  class="q-ma-sm"
                  color="primary"
                  label="Edit Feature"
                  @click="editFeature"
                  :disabled="disableFeatureButtons"
                />
                <q-btn
                  class="q-ma-sm"
                  color="primary"
                  label="Delete feature"
                  @click="deleteFeature"
                  :disabled="disableFeatureButtons"
                />
              </template>
              <template v-slot:body="props">
                <q-tr
                  :props="props"
                  class="cursor-pointer"
                  @click.exact="toggleSingleRow(props.row)"
                >
                  <q-td key="name" :props="props">
                    {{ props.row.name }}
                  </q-td>
                  <q-td key="type" :props="props">
                    {{ props.row.type }}
                  </q-td>
                  <q-td key="options" :props="props">
                    <q-badge color="purple">
                      {{ props.row.options }}
                    </q-badge>
                  </q-td>
                </q-tr>
              </template>
            </q-table>
          </div>
          <div v-show="featureView == 'editor'">
            <q-form @submit="saveFeatureOption" class="q-gutter-md">
              <q-input
                filled
                v-model="featureUnderConstruction.name"
                label="Feature Name"
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
                <q-btn
                  @click="saveFeatureOption"
                  label="Save"
                  color="primary"
                />
                <q-btn
                  @click="cancelFeatureEdit"
                  label="Cancel"
                  color="primary"
                  class="q-ml-sm"
                />
              </div>
            </q-form>
          </div>
        </q-tab-panel>
      </q-tab-panels>
    </q-card-section>
  </q-card>
</template>

<style lang="sass">
.build-instance-wrapper > div.tab-controller { height: 100% !important; width: 80px !important }
.build-instance-wrapper > .world-tab > div { height: 50% !important; width: 50% !important; }
.CodeMirror { height: 100% !important; width: 100% !important }
</style>

<script lang="ts">
import Vue from 'vue';
import { mapGetters } from 'vuex';
import { CharacterRaceFeatureInterface } from 'src/store/characterRaceFeature/state';
import featureState from 'src/store/characterRaceFeature/state';

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
    name: 'type';
    align: 'center';
    label: 'Type';
    field: 'type';
    sortable: true;
  },
  {
    name: 'options';
    align: 'center';
    label: 'Options';
    field: 'options';
    sortable: false;
  }
];

export default {
  name: 'BuildRacesEditor',
  components: {},
  data(): {
    tab: string;
    characterFeatureColumns: unknown;
    features: CharacterRaceFeatureInterface[];
    visibleFeatureColumns: string[];
    selectedRow: CharacterRaceFeatureInterface[];
    featureView: string;
    featureUnderConstruction: CharacterRaceFeatureInterface;
    featureIsNew: boolean;
    featureTypeOptions: string[];
    featureIndex: Record<string, number>;
  } {
    return {
      tab: 'races',
      characterFeatureColumns,
      features: [],
      featureIndex: {},
      visibleFeatureColumns: ['name', 'type'],
      selectedRow: [],
      featureView: 'table',
      featureUnderConstruction: { ...featureState },
      featureTypeOptions: ['range', 'select'],
      featureIsNew: false
    };
  },
  computed: {
    disableFeatureButtons: function(): boolean {
      return this.selectedRow.length == 0;
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
  mounted() {
    // this.codeEditor = this.$refs.codeEditor.codemirror;
  },
  methods: {
    cancelFeatureEdit() {
      this.featureView = 'table';
      this.featureIsNew = false;
      this.featureUnderConstruction = { ...featureState };
    },
    saveFeatureOption() {
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

      console.log('herer')

      request
        .then(result => {
          if (this.featureIsNew) {
            Vue.set(this.featureIndex, result.data.id, this.features.length);

            this.features.push(result.data);
            this.featureIsNew = false;
            this.featureUnderConstruction = { ...featureState };
            this.featureView = 'table';
          } else {
            Vue.set(
              this.features,
              this.featureIndex[result.data.id],
              result.data
            );
            this.featureIsNew = false;
            this.featureUnderConstruction = { ...featureState };
            this.featureView = 'table';
          }
        })
        .catch(function() {
          alert('Error saving');
        })
        .then();
    },
    addFeature() {
      this.featureIsNew = true;
      this.featureView = 'editor';
    },
    editFeature() {
      this.featureUnderConstruction = this.selectedRow[0];
      this.featureIsNew = false;
      this.featureView = 'editor';
    },
    deleteFeature() {
      console.log('deleteFeature');
    },
    filter() {
      console.log('filter');
    },
    toggleSingleRow(row: CharacterRaceFeatureInterface) {
      this.selectedRow = [row];
    }
    //   refreshEditor() {
    //     setTimeout(() => {
    //       this.codeEditor.refresh();
    //     }, 10);
    //   },
    //   selectLuaScript(newScript: string) {
    //     this.code = this.luaScripts[this.luaScriptIndex[newScript]].code;
    //     this.refreshEditor();
    //   },
    //   createNewScript() {
    //     this.pane = 'wizard';
    //     this.editingNewScript = false;
    //   },
    //   buildNodeTree() {
    //   },
    //   onSubmit() {
    //     const params = {
    //       map: {
    //         name: this.wizard.name,
    //         description: this.wizard.description,
    //         type: this.wizard.type
    //       }
    //     };
    //     let request;
    //     if (this.editingNewScript) {
    //       request = this.$axios.post('/lua_scripts', params);
    //     } else {
    //       request = this.$axios.patch('/lua_scripts/' + this.wizard.id, params);
    //     }
    //     request
    //       .then(result => {
    //         if (this.editingNewScript) {
    //           Vue.set(this.luaScriptIndex, result.data.id, this.luaScripts.length);
    //           this.luaScripts.push(result.data)
    //           this.selected = result.data.name
    //           this.$store.dispatch('builder/selectMap', result.data).then(() => {
    //             this.$store.dispatch('builder/putMap', result.data).then(() => {
    //               this.$emit('saved');
    //             });
    //           });
    //         } else {
    //           this.$store.dispatch('builder/updateMap', result.data).then(() => {
    //             this.$emit('saved');
    //           });
    //         }
    //       })
    //       .catch(function() {
    //         alert('Error saving');
    //       })
    //       .finally(function() {
    //         this.$store.dispatch('builder/putIsMapUnderConstruction', false);
    //       });
    //   }
  }
};
</script>
