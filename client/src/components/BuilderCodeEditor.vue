<template>
  <div class="build-instance-wrapper flex row fit">
    <div v-show="pane == 'editor'" class="flex column col-shrink">
      <q-btn push color="secondary" @click="createNewScript">New</q-btn>
      <q-tree
        :nodes="treeNodes"
        node-key="label"
        selected-color="primary"
        :selected.sync="selected"
        class="col-250px q-mr-sm"
        no-connectors
        default-expand-all
        @update:selected="selectLuaScript"
      />
    </div>

    <q-card
      v-show="pane == 'editor'"
      flat
      bordered
      class="col-grow flex column"
    >
      <q-card-section class="q-pa-none col-shrink">
        <div class="text-h6 text-center">{{ selected }}</div>
      </q-card-section>

      <q-separator />

      <q-card-section class="q-pa-none col-grow">
        <codemirror
          ref="codeEditor"
          v-model="scriptUnderConstruction.code"
          class="fit codeEditor"
          :options="cmOptions"
        />
      </q-card-section>

      <q-separator />

      <q-card-actions align="around" class="action-container col-shrink">
        <q-btn flat class="action-button" @click="save">Save</q-btn>
        <q-btn flat class="action-button" @click="resetCode">Reset</q-btn>
      </q-card-actions>
    </q-card>

    <q-form v-if="pane == 'wizard'" class="fit">
      <q-input
        v-model="scriptUnderConstruction.name"
        filled
        label="Name"
        hint="Unique name of the script"
        lazy-rules
        :rules="[val => (val && val.length > 0) || 'Please type something']"
      />
      <q-input
        v-model="scriptUnderConstruction.description"
        filled
        label="Description"
        hint="Unique name of the script"
        lazy-rules
        :rules="[val => (val && val.length > 0) || 'Please type something']"
      />

      <q-select
        v-model="scriptUnderConstruction.type"
        :options="typeOptions"
        label="Type"
      />

      <div>
        <q-btn label="Save" color="primary" @click="save" />
        <q-btn
          label="Reset"
          type="reset"
          color="primary"
          flat
          class="q-ml-sm"
        />
        <q-btn label="Cancel" color="secondary" @click="cancelEdit" />
      </div>
    </q-form>
  </div>
</template>

<style lang="sass">
.build-instance-wrapper > div.tab-controller { height: 100% !important; width: 80px !important }
.build-instance-wrapper > .world-tab > div { height: 50% !important; width: 50% !important; }
.CodeMirror { height: 100% !important; width: 100% !important }
</style>

<script lang="ts">
import Vue from 'vue';
import { mapGetters } from 'vuex';
import { codemirror } from 'vue-codemirror';
import CodeMirror from 'codemirror/lib/codemirror.js';
import 'codemirror/lib/codemirror.css';
import 'codemirror/theme/ambiance.css';
import 'codemirror/mode/lua/lua.js';
import { LuaScriptState } from 'src/store/luaScripts/state';

interface LuaScriptInterface {
  id: string;
  name: string;
  code: string;
  type: string;
}

interface TreeNodeInterface {
  label: string;
  icon: string;
  selectable: boolean;
  children: TreeNodeInterface[];
}

export default {
  name: 'BuildCodeEditor',
  components: { codemirror },
  data(): {
    codeEditor: unknown;
    cmOptions: {
      tabSize: number;
      mode: string;
      theme: string;
      lineNumbers: boolean;
      line: boolean;
    };
    selected: string;
    headers: string[];
    pane: string;
    typeOptions: string[];
    scriptUnderConstruction: LuaScriptInterface;
  } {
    return {
      codeEditor: undefined,
      cmOptions: {
        tabSize: 2,
        mode: 'text/x-lua',
        theme: 'ambiance',
        lineNumbers: true,
        line: true
        // more CodeMirror options...
      },
      selected: '',
      headers: ['Commands', 'Scripts', 'Modules', 'Systems'],
      pane: 'editor',
      typeOptions: ['command', 'script', 'system', 'module'],
      scriptUnderConstruction: { ...LuaScriptState }
    };
  },
  computed: {
    editingNewScript: function(): boolean {
      return this.scriptUnderConstruction.id == '';
    },
    luaScriptIndex: function(): Record<string, number> {
      const scriptIndex = {};

      this.luaScripts.forEach(function(script, index) {
        scriptIndex[script.name] = index;
      });

      return scriptIndex;
    },
    treeNodes: function(): TreeNodeInterface[] {
      return [
        {
          label: 'Commands',
          selectable: false,
          icon: '',
          children: this.luaScripts
            .filter(function(script: LuaScriptInterface) {
              return script.type == 'command';
            })
            .map(function(script: LuaScriptInterface) {
              return {
                label: script.name,
                icon: 'fas fa-code'
              };
            })
        },
        {
          label: 'Scripts',
          selectable: false,
          icon: '',
          children: this.luaScripts
            .filter(function(script: LuaScriptInterface) {
              return script.type == 'script';
            })
            .map(function(script: LuaScriptInterface) {
              return {
                label: script.name,
                icon: 'fas fa-code'
              };
            })
        },
        {
          label: 'Systems',
          selectable: false,
          icon: '',
          children: this.luaScripts
            .filter(function(script: LuaScriptInterface) {
              return script.type == 'system';
            })
            .map(function(script: LuaScriptInterface) {
              return {
                label: script.name,
                icon: 'fas fa-code'
              };
            })
        },
        {
          label: 'Modules',
          selectable: false,
          icon: '',
          children: this.luaScripts
            .filter(function(script: LuaScriptInterface) {
              return script.type == 'module';
            })
            .map(function(script: LuaScriptInterface) {
              return {
                label: script.name,
                icon: 'fas fa-code'
              };
            })
        }
      ];
    },
    ...mapGetters({
      instanceBeingBuilt: 'instances/instanceBeingBuilt',
      luaScripts: 'luaScripts/all'
    })
  },
  created() {
    this.$store.dispatch(
      'luaScripts/loadForInstance',
      this.instanceBeingBuilt.id
    );
  },
  mounted() {
    this.codeEditor = this.$refs.codeEditor.codemirror;
  },
  methods: {
    refreshEditor() {
      setTimeout(() => {
        this.codeEditor.refresh();
      }, 10);
    },
    selectLuaScript(newScript: string) {
      this.scriptUnderConstruction = {
        ...this.luaScripts[this.luaScriptIndex[newScript]]
      };
      this.refreshEditor();
    },
    resetCode() {},
    createNewScript() {
      this.scriptUnderConstruction = { ...LuaScriptState };
      this.pane = 'wizard';
    },
    cancelEdit() {
      this.pane = 'editor';
      this.scriptUnderConstruction = { ...LuaScriptState };
    },
    buildNodeTree() {},
    save() {
      const params = {
        lua_script: {
          name: this.scriptUnderConstruction.name,
          description: this.scriptUnderConstruction.description,
          type: this.scriptUnderConstruction.type,
          instance_id: this.instanceBeingBuilt.id,
          code: this.scriptUnderConstruction.code
        }
      };

      let request;

      if (this.editingNewScript) {
        request = this.$axios.post('/lua_scripts', params);
      } else {
        request = this.$axios.patch(
          '/lua_scripts/' + this.scriptUnderConstruction.id,
          params
        );
      }

      request.then(result => {
        this.$store
          .dispatch('luaScripts/putScript', result.data)
          .catch(function() {
            alert('Error saving');
          });
      });
    }
  }
};
</script>
