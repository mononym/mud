<template>
  <div class="fit flex row wrap">
    <div class="full-width half-height">detail</div>
    <div
      v-show="bottomDisplay == 'table'"
      class="full-width half-height flex column"
    >
      <q-table
        title="Commands"
        :data="commands"
        :columns="commandColumns"
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
          @click="deleteCommand"
          >Delete</q-btn
        >
      </q-btn-group>
    </div>
    <div v-show="bottomDisplay == 'editor'" class="full-width half-height">
      <q-stepper v-model="step" vertical color="primary" animated>
        <q-step
          :name="1"
          title="Basic Details"
          icon="settings"
          :done="step > 1"
        >
          <EasyForm v-model="commandFormValue" v-bind="commandForm" />

          <q-stepper-navigation>
            <q-btn
              :disabled="detailsContinueButtonDisabled"
              color="primary"
              label="Continue"
              @click="step = 2"
            />
          </q-stepper-navigation>
        </q-step>

        <q-step
          :name="2"
          title="Define command structure"
          caption="The engine must be configured to parse each command explicitly"
          icon="create_new_folder"
          :done="step > 2"
        >
          An ad group contains one or more ads which target a shared set of
          keywords.

          <q-stepper-navigation>
            <q-btn color="primary" label="Finish" />
            <q-btn
              flat
              color="primary"
              label="Back"
              class="q-ml-sm"
              @click="step = 1"
            />
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
import { CommandInterface } from 'src/store/command/state';
import commandState from 'src/store/command/state';
import { LuaScriptInterface } from 'src/store/luaScripts/state';
import { mapGetters } from 'vuex';
import { EasyForm, EfBtn } from 'quasar-ui-easy-forms';

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
    commandForm: Record<string, unknown>;
    commandFormValue: Record<string, unknown>;
    commandUnderConstruction: CommandInterface;
    initialPagination: { rowsPerPage: number };
    selectedCommandRow: CommandInterface[];
    step: number;
  } {
    return {
      bottomDisplay: 'table',
      commandColumns,
      commandForm: { schema: [] },
      commandFormValue: {},
      commandUnderConstruction: { ...commandState },
      initialPagination: {
        rowsPerPage: 0
      },
      selectedCommandRow: [],
      step: 1
    };
  },
  computed: {
    isNew: function(): boolean {
      return this.commandUnderConstruction.id == '';
    },
    detailsContinueButtonDisabled: function(): boolean {
      if (!this.isNew) {
        return false;
      } else {
        return (
          this.commandFormValue.name == undefined ||
          this.commandFormValue.name == '' ||
          this.commandFormValue.description == undefined ||
          this.commandFormValue.description == '' ||
          this.commandFormValue.lua_script_id == undefined ||
          this.commandFormValue.lua_script_id == ''
        );
      }
    },
    commandButtonDisabled: function(): boolean {
      return this.selectedCommandRow.length == 0;
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
      this.defineCommandEditForm();
      this.bottomDisplay = 'editor';
    },
    editCommand(): void {},
    deleteCommand(): void {},
    defineCommandEditForm(): void {
      const self = this;

      this.commandForm = {
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
    }
  }
};
</script>
