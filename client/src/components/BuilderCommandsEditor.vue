<template>
  <div class="fit flex row wrap">
    <div class="full-width half-height">detail</div>
    <div
      v-show="bottomDisplay == 'table'"
      class="full-width half-height flex column"
    >
      <q-table
        title="Commands"
        :data="tableCommands"
        :columns="commandColumns"
        :visible-columns="visibleCommandColumns"
        row-key="id"
        flat
        bordered
        class="col"
        :selected.sync="selectedCommandRow"
        :pagination="initialPagination"
        :rows-per-page-options="[0]"
        :pagination-label="getCommandsPaginationLabel"
      >
        <template v-slot:body-cell="props">
          <q-td
            :props="props"
            class="cursor-pointer"
            @click.exact="toggleSingleCommandRow(props.row)"
          >
            {{ props.value }}
          </q-td>
        </template>
      </q-table>
      <q-btn-group spread class="col-shrink">
        <q-btn class="" flat @click="addCommand">Add</q-btn>
        <q-btn
          :disabled="commandButtonDisabled"
          class=""
          flat
          @click="editCommand"
          >Edit</q-btn
        >
        <q-btn
          :disabled="commandButtonDisabled"
          class=""
          flat
          @click="promptForDeleteCommand"
          >Delete</q-btn
        >
      </q-btn-group>
    </div>
    <div v-if="bottomDisplay == 'editor'" class="full-width half-height">
      <q-stepper
        v-model="step"
        vertical
        color="primary"
        animated
        class="fit overflow-auto"
      >
        <q-step
          :name="1"
          title="Basic Details"
          icon="settings"
          :done="step > 1"
          :caption="commandFormValue.name + ': ' + commandFormValue.description"
        >
          <EasyForm v-model="commandUnderConstruction" v-bind="commandForm" />

          <q-stepper-navigation>
            <q-btn
              :disabled="detailsContinueButtonDisabled"
              color="primary"
              label="Continue"
              @click="continueToSegments"
            />
            <q-btn color="primary" label="Cancel" @click="cancelEdit" />
          </q-stepper-navigation>
        </q-step>

        <q-step
          :name="2"
          title="Define command structure"
          caption="The engine must be configured to parse each command explicitly"
          icon="create_new_folder"
          :done="step > 2"
        >
          <div class="fit flex row">
            <q-card
              v-for="segment in commandUnderConstruction.segments"
              :key="segment.id"
              class="my-card bg-secondary text-white col-shrink full-height"
            >
              <q-card-section>
                <div class="text-h6">Segment</div>
              </q-card-section>

              <q-card-section>
                Type: {{ segment.type }}
                <q-popup-edit
                  v-model="segment.type"
                  buttons
                  persistent
                  :disable="segment.type == 'command'"
                >
                  <q-select
                    v-model="segment.type"
                    :options="['text', 'item']"
                    label="Type"
                  />
                </q-popup-edit>
              </q-card-section>

              <q-card-section>
                Key: {{ segment.key }}
                <q-popup-edit
                  v-model="segment.key"
                  buttons
                  persistent
                  :disable="segment.type == 'command'"
                >
                  <q-input
                    v-model="segment.key"
                    dense
                    autofocus
                    hint="The key the segment will be saved as in the context"
                  />
                </q-popup-edit>
              </q-card-section>

              <q-card-section
                v-if="segment.type == 'text' || segment.type == 'command'"
              >
                Match: {{ segment.match }}
                <q-popup-edit v-model="segment.match" buttons persistent>
                  <q-input
                    v-model="segment.match"
                    dense
                    autofocus
                    hint="Must be a valid regex expression"
                  />
                </q-popup-edit>
              </q-card-section>

              <q-card-section
                v-if="segment.type == 'text' || segment.type == 'item'"
              >
                Follows: {{ segment.follows.join(', ') }}
                <q-popup-edit v-model="segment.follows" buttons persistent>
                  <q-select
                    v-model="segment.follows"
                    filled
                    multiple
                    :options="followsOptions(segment.key)"
                    counter
                    hint="Number of segments followed: "
                    style="width: 250px"
                  />
                </q-popup-edit>
              </q-card-section>

              <q-card-section v-if="segment.type == 'text'">
                Greedy: {{ segment.greedy }}
                <q-popup-edit v-model="segment.greedy" buttons persistent>
                  <q-toggle v-model="segment.greedy" label="Greedy" />
                </q-popup-edit>
              </q-card-section>

              <q-card-section v-if="segment.type == 'text'">
                Multiple Behavior: {{ segment.multiple }}
                <q-popup-edit
                  v-model="segment.multiple"
                  buttons
                  persistent
                  @save="multipleSelectionUpdated(segment.id)"
                >
                  <q-btn-toggle
                    v-model="segment.multiple"
                    toggle-color="primary"
                    :options="[
                      { label: 'None', value: 'none' },
                      { label: 'Merge', value: 'merge' },
                      { label: 'Unique', value: 'unique' }
                    ]"
                  />
                </q-popup-edit>
              </q-card-section>

              <q-card-section
                v-if="segment.type == 'text' && segment.multiple == 'true'"
              >
                Drop Whitespace: {{ segment.dropWhitespace }}
                <q-popup-edit
                  v-model="segment.dropWhitespace"
                  buttons
                  persistent
                >
                  <q-toggle
                    v-model="segment.dropWhitespace"
                    label="Drop Whitespace"
                  />
                </q-popup-edit>
              </q-card-section>

              <q-card-section v-if="segment.type == 'text'">
                Transformer: {{ segment.transformer }}
                <q-popup-edit v-model="segment.transformer" buttons persistent>
                  <q-select
                    v-model="segment.transformer"
                    :options="transformerOptions(segment.multiple)"
                    label="Transformer"
                  />
                </q-popup-edit>
              </q-card-section>

              <q-separator v-if="segment.type != 'command'" dark />

              <q-card-actions v-if="segment.type != 'command'">
                <q-btn flat @click="promptForDeleteSegment(segment.id)"
                  >Delete</q-btn
                >
              </q-card-actions>
            </q-card>
          </div>

          <q-stepper-navigation>
            <q-btn color="primary" label="Add Segment" @click="addSegment" />
            <q-btn color="primary" label="Finish" @click="saveCommand" />
            <q-btn
              flat
              color="primary"
              label="Back"
              class="q-ml-sm"
              @click="step = 1"
            />
            <q-btn color="primary" label="Cancel" @click="cancelEdit" />
          </q-stepper-navigation>
        </q-step>
      </q-stepper>
    </div>
  </div>
</template>

<style lang="sass">
.half-height {height: 50%}
</style>

<script lang="ts">
import Vue from 'vue';
import { CommandInterface, SegmentState } from 'src/store/command/state';
import commandState from 'src/store/command/state';
import { LuaScriptInterface } from 'src/store/luaScripts/state';
import { mapGetters } from 'vuex';
import { EasyForm, EfBtn } from 'quasar-ui-easy-forms';
import { v4 as uuidv4 } from 'uuid';

interface CommonColumnInterface {
  name: string;
  required: boolean;
  label: string;
  sortable: boolean;
  align: string;
}

let commandColumns: [
  {
    name: 'name';
    required: true;
    label: 'Name';
    sortable: true;
    align: 'center';
  },
  {
    name: 'description';
    required: true;
    label: 'Description';
    sortable: false;
    align: 'center';
  }
];

export default {
  name: 'BuilderCommandsEditor',
  components: { EasyForm, EfBtn },
  data(): {
    bottomDisplay: string;
    commandColumns: CommonColumnInterface[];
    commandFormValue: Record<string, unknown>;
    commandUnderConstruction: CommandInterface;
    initialPagination: { rowsPerPage: number };
    selectedCommandRow: CommandInterface[];
    step: number;
    visibleCommandColumns: string[];
  } {
    return {
      bottomDisplay: 'table',
      commandColumns,
      commandFormValue: {},
      commandUnderConstruction: { ...commandState },
      initialPagination: {
        rowsPerPage: 0
      },
      selectedCommandRow: [],
      step: 1,
      visibleCommandColumns: ['name', 'description']
    };
  },
  computed: {
    tableCommands: function(): CommandInterface[] {
      return this.commands.map(command => {
        const desc = command.description;
        delete command.description;
        command.description = desc;

        return command;
      });
    },
    isNew: function(): boolean {
      return this.commandUnderConstruction.id == '';
    },
    detailsContinueButtonDisabled: function(): boolean {
      if (!this.isNew) {
        return false;
      } else {
        return (
          this.commandUnderConstruction.name == '' ||
          this.commandUnderConstruction.description == '' ||
          this.commandUnderConstruction.lua_script_id == ''
        );
      }
    },
    commandButtonDisabled: function(): boolean {
      return this.selectedCommandRow.length == 0;
    },
    commandForm: function(): Record<string, unknown> {
      const self = this;

      return {
        schema: [
          {
            id: 'name',
            component: 'QInput',
            label: 'Name',
            required: true
          },
          {
            id: 'description',
            component: 'QInput',
            label: 'Description',
            subLabel: 'A short blurb to help distinguish between commands.'
          },
          {
            id: 'lua_script_id',
            component: 'QSelect',
            label: 'Script',
            subLabel: 'Which script is executed when this command is run?',
            // component props:
            evaluatedProps: ['disabled', 'options'],
            'option-value': 'id',
            'option-label': 'value',
            'emit-value': true,
            'map-options': true,
            options: () => {
              return self.scripts.map(function(script: LuaScriptInterface) {
                return {
                  label: script.name,
                  value: script.name,
                  id: script.id
                };
              });
            },
            disabled: () => {
              return self.scripts.length == 0;
            }
          }
        ]
      };
    },
    ...mapGetters({
      commands: 'commands/all',
      instanceBeingBuilt: 'instances/instanceBeingBuilt',
      scripts: 'luaScripts/allCommandScripts'
    })
  },
  created() {
    this.$store.dispatch(
      'luaScripts/loadForInstance',
      this.instanceBeingBuilt.id
    );

    void this.$axios
      .get('/commands/instance/' + this.instanceBeingBuilt.id)
      .then(result => {
        return this.$store.dispatch('commands/putCommands', result.data);
      });
  },
  methods: {
    getCommandsPaginationLabel(
      start: number,
      end: number,
      total: number
    ): string {
      return total.toString() + ' Command(s)';
    },
    toggleSingleCommandRow(row: CommandInterface) {
      this.selectedCommandRow = [row];
    },
    addCommand(): void {
      this.bottomDisplay = 'editor';
    },
    addSegment(): void {
      this.commandUnderConstruction.segments.push({
        ...SegmentState,
        id: uuidv4()
      });
    },
    followsOptions(segmentKey: string): string[] {
      return this.commandUnderConstruction.segments
        .map(segment => segment.key)
        .filter(key => key != '' && key != segmentKey);
    },
    transformerOptions(multiple: string): string[] {
      if (multiple == 'unique') {
        return ['none', 'downcase', 'to_integer'];
      } else if (multiple == 'merge') {
        return ['none', 'join_with_space', 'join_with_space_downcase'];
      } else {
        return ['none', 'downcase', 'to_integer'];
      }
    },
    multipleSelectionUpdated(segmentId: string): void {
      this.commandUnderConstruction.segments = this.commandUnderConstruction.segments.map(
        segment => {
          if (segment.id == segmentId) {
            const options = this.transformerOptions(segment.multiple);

            if (options.includes(segment.transformer)) {
              return segment;
            } else {
              segment.transformer = 'none';

              return segment;
            }
          } else {
            return segment;
          }
        }
      );
    },
    cancelEdit(): void {
      this.bottomDisplay = 'table';
      this.commandUnderConstruction = { ...commandState };
    },
    editCommand(): void {
      this.bottomDisplay = 'editor';
      this.commandUnderConstruction = this.selectedCommandRow[0];
    },
    deleteCommand(): void {
      this.$store.dispatch(
        'commands/deleteCommand',
        this.selectedCommandRow[0].id
      );
    },
    deleteSegment(segmentId: string): void {
      this.commandUnderConstruction.segments = this.commandUnderConstruction.segments.filter(
        segment => segment.id != segmentId
      );
    },
    promptForDeleteSegment(segmentId: string) {
      let index = this.commandUnderConstruction.segments.findIndex(
        segment => segment.id == segmentId
      );

      const key = this.commandUnderConstruction.segments[index].key;

      this.$q
        .dialog({
          title: "Delete '" + key + "'?",
          message: "Type '" + key + "' to continue with deletion.",
          prompt: {
            model: '',
            isValid: val => val == key, // << here is the magic
            type: 'text' // optional
          },
          cancel: true,
          persistent: true
        })
        .onOk(() => {
          this.deleteSegment(segmentId);
        });
    },
    promptForDeleteCommand() {
      let name = '';

      if (this.selectedCommandRow.length > 0) {
        name = this.selectedCommandRow[0].name;
      }

      this.$q
        .dialog({
          title: "Delete '" + name + "'?",
          message: "Type '" + name + "' to continue with deletion.",
          prompt: {
            model: '',
            isValid: val => val == name, // << here is the magic
            type: 'text' // optional
          },
          cancel: true,
          persistent: true
        })
        .onOk(() => {
          this.deleteCommand();
        });
    },
    continueToSegments(): void {
      if (this.isNew) {
        const newSegment = { ...SegmentState, id: uuidv4() };
        newSegment.type = 'command';
        newSegment.key = 'command';

        this.commandUnderConstruction.segments = [newSegment];
      }

      this.step = 2;
    },
    saveCommand() {
      console.log('saving');
      this.commandUnderConstruction.instance_id = this.instanceBeingBuilt.id;

      let request;
      const self = this;

      if (this.isNew) {
        request = this.$axios.post('/commands', this.commandUnderConstruction);
      } else {
        request = this.$axios.patch(
          '/commands/' + this.commandUnderConstruction.id,
          this.commandUnderConstruction
        );
      }

      request
        .then(result => {
          this.$store.dispatch('commands/putCommand', result.data);

          this.bottomDisplay = 'table';
        })
        .catch(function() {
          alert('Error saving');
        });
    }
  }
};
</script>
