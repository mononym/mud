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
          v-model="code"
          class="fit codeEditor"
          :options="cmOptions"
        />
      </q-card-section>

      <q-separator />

      <q-card-actions align="around" class="action-container col-shrink">
        <q-btn flat class="action-button">Save</q-btn>
        <q-btn flat class="action-button">Cancel</q-btn>
        <q-btn flat class="action-button">Clone</q-btn>
      </q-card-actions>
    </q-card>

    <q-form v-show="pane == 'wizard'" @submit="onSubmit" class="fit">
      <q-input
        v-model="wizard.name"
        filled
        label="Name"
        hint="Unique name of the script"
        lazy-rules
        :rules="[val => (val && val.length > 0) || 'Please type something']"
      />
      <q-input
        v-model="wizard.description"
        filled
        label="Description"
        hint="Unique name of the script"
        lazy-rules
        :rules="[val => (val && val.length > 0) || 'Please type something']"
      />

      <q-select v-model="wizard.type" :options="typeOptions" label="Type" />

      <div>
        <q-btn label="Submit" type="submit" color="primary" />
        <q-btn
          label="Reset"
          type="reset"
          color="primary"
          flat
          class="q-ml-sm"
        />
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
    code: string;
    cmOptions: {
      tabSize: number;
      mode: string;
      theme: string;
      lineNumbers: boolean;
      line: boolean;
    };
    selected: string;
    luaScripts: LuaScriptInterface[];
    treeNodes: TreeNodeInterface[];
    luaScriptIndex: Record<string, number>;
    headers: string[];
    pane: string;
    wizard: {
      id: string;
      name: string;
      description: string;
      type: string;
    };
    typeOptions: string[];
    editingNewScript: boolean;
  } {
    return {
      codeEditor: undefined,
      code: '',
      cmOptions: {
        tabSize: 2,
        mode: 'text/x-lua',
        theme: 'ambiance',
        lineNumbers: true,
        line: true
        // more CodeMirror options...
      },
      selected: '',
      luaScripts: [],
      treeNodes: [],
      luaScriptIndex: {},
      headers: ['Commands', 'Scripts', 'Modules', 'Systems'],
      pane: 'editor',
      wizard: {
        id: '',
        name: '',
        description: '',
        type: ''
      },
      typeOptions: ['Commands', 'Scripts', 'Systems', 'Modules'],
      editingNewScript: false
    };
  },
  computed: {
    ...mapGetters({})
  },
  created() {
    let self = this;

    this.$axios.get('/lua_scripts').then(function(results) {
      self.treeNodes = [
        {
          label: 'Commands',
          selectable: false,
          icon: '',
          children: results.data.Commands.map(function(
            script: LuaScriptInterface
          ) {
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
          children: results.data.Scripts.map(function(
            script: LuaScriptInterface
          ) {
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
          children: results.data.Systems.map(function(
            script: LuaScriptInterface
          ) {
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
          children: results.data.Modules.map(function(
            script: LuaScriptInterface
          ) {
            return {
              label: script.name,
              icon: 'fas fa-code'
            };
          })
        }
      ];

      self.luaScripts = results.data.Commands.concat(results.data.Scripts)
        .concat(results.data.Systems)
        .concat(results.data.Modules);

      self.luaScripts.forEach((script, index) => {
        Vue.set(self.luaScriptIndex, script.name, index);
      });
    });
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
      this.code = this.luaScripts[this.luaScriptIndex[newScript]].code;
      this.refreshEditor();
    },
    createNewScript() {
      this.pane = 'wizard';
      this.editingNewScript = false;
    },
    buildNodeTree() {

    },
    onSubmit() {
      const params = {
        map: {
          name: this.wizard.name,
          description: this.wizard.description,
          type: this.wizard.type
        }
      };

      let request;

      if (this.editingNewScript) {
        request = this.$axios.post('/lua_scripts', params);
      } else {
        request = this.$axios.patch('/lua_scripts/' + this.wizard.id, params);
      }

      request
        .then(result => {
          if (this.editingNewScript) {
            Vue.set(this.luaScriptIndex, result.data.id, this.luaScripts.length);

            this.luaScripts.push(result.data)
            this.selected = result.data.name
            this.$store.dispatch('builder/selectMap', result.data).then(() => {
              this.$store.dispatch('builder/putMap', result.data).then(() => {
                this.$emit('saved');
              });
            });
          } else {
            this.$store.dispatch('builder/updateMap', result.data).then(() => {
              this.$emit('saved');
            });
          }
        })
        .catch(function() {
          alert('Error saving');
        })
        .finally(function() {
          this.$store.dispatch('builder/putIsMapUnderConstruction', false);
        });
    }
  }
};
</script>
