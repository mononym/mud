<template>
  <div class="fit flex row wrap">
    <div class="half-width half-height">
      <character-creation-wizard
        mode="preview"
        @preview="characterSelectedForPreview"
      />
    </div>
    <div class="half-width half-height">
      <q-skeleton v-if="showPreviewPlaceholder" class="fit" type="rect" />
      <p v-if="!showPreviewPlaceholder">
        {{ templatePreview }}
      </p>
    </div>
    <div v-show="editing == false" class="full-width flex column half-height">
      <q-table
        title="Templates"
        :data="templates"
        :columns="templateColumns"
        :visible-columns="visibleColumns"
        flat
        bordered
        class="col"
        :selected.sync="selectedTemplateRow"
        :pagination="initialPagination"
        :rows-per-page-options="[0]"
        :pagination-label="getTemplatesPaginationLabel"
      >
        <template v-slot:body-cell="props">
          <q-td
            :props="props"
            class="cursor-pointer"
            @click.exact="toggleSingleRow(props.row)"
          >
            {{ props.value }}
          </q-td>
        </template>
      </q-table>
      <q-btn-group stretch class="col-shrink">
        <q-btn class="col" flat @click="add">Add</q-btn>
        <q-btn :disabled="buttonsDisabled" class="col" flat @click="edit"
          >Edit</q-btn
        >
        <q-btn
          :disabled="buttonsDisabled"
          class="col"
          flat
          @click="promptForDelete"
          >Delete</q-btn
        >
      </q-btn-group>
    </div>
    <q-form
      v-show="editing == true"
      class="q-gutter-md full-width half-height"
      @submit="save"
    >
      <q-input
        v-model="templateUnderConstruction.name"
        filled
        label="Name"
        hint="Must be unique"
        lazy-rules
        :rules="[val => (val && val.length > 0) || 'Please type something']"
      />

      <q-input
        v-model="templateUnderConstruction.description"
        filled
        label="Description"
        type="textarea"
        lazy-rules
        :rules="[val => (val && val.length > 0) || 'Please type something']"
      />

      <q-input
        v-model="templateUnderConstruction.template"
        filled
        label="Template"
        type="textarea"
        lazy-rules
        :rules="[val => (val && val.length > 0) || 'Please type something']"
      />

      <div>
        <q-btn label="Submit" type="submit" color="primary" />
      </div>
    </q-form>
  </div>
</template>

<script lang="ts">
import Vue from 'vue';
import { mapGetters } from 'vuex';
import { CharacterTemplateInterface } from 'src/store/characterTemplate/state';
import templateState from 'src/store/characterTemplate/state';
import CharacterCreationWizard from '../components/CharacterCreationWizard.vue';

interface CommonColumnInterface {
  name: string;
  required: boolean;
  label: string;
  sortable: boolean;
  align: string;
}

let templateColumns: [
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
    sortable: true;
    align: 'center';
  },
  {
    name: 'template';
    required: true;
    label: 'Template';
    sortable: true;
    align: 'center';
  }
];

export default {
  name: 'CharacterTemplateEditor',
  components: { CharacterCreationWizard },
  props: {},
  data(): {
    editing: boolean;
    featuresForPreview: Record<string, unknown>;
    initialPagination: { rowsPerPage: number };
    isNew: boolean;
    selectedTemplateRow: CharacterTemplateInterface[];
    templateColumns: CommonColumnInterface[];
    templates: unknown[];
    templateIndex: Record<string, number>;
    templatePreview: string;
    templateUnderConstruction: CharacterTemplateInterface;
    visibleColumns: string[];
  } {
    return {
      editing: false,
      featuresForPreview: {},
      initialPagination: {
        rowsPerPage: 0
      },
      isNew: false,
      selectedTemplateRow: [],
      templateColumns,
      templates: [],
      templateIndex: {},
      templatePreview: '',
      templateUnderConstruction: { ...templateState },
      visibleColumns: ['name', 'description', 'template']
    };
  },
  computed: {
    showPreviewPlaceholder: function(): boolean {
      return this.templatePreview == '';
    },
    // templatePreview: function(): string {
    //   if (
    //     this.selectedTemplateRow.length == 0 ||
    //     this.featuresForPreview == {}
    //   ) {
    //     return '';
    //   } else {
    //     return this.$axios
    //       .post('/character_templates/preview', {
    //         template_id: this.selectedTemplateRow[0].id,
    //         features: this.featuresForPreview
    //       })
    //       .then(response => {
    //         return response.preview;
    //       });
    //   }
    // },
    buttonsDisabled: function(): boolean {
      return this.selectedTemplateRow.length == 0;
    },
    ...mapGetters({
      instanceBeingBuilt: 'instances/instanceBeingBuilt'
    })
  },
  created() {
    let self = this;

    this.$axios
      .get('/character_templates/instance/' + this.instanceBeingBuilt.id)
      .then(function(results) {
        console.log('templates');
        console.log(results);

        // This explicit mapping is so that the keys in the object are in a deterministic
        // order, which impacts how the data is displayed in the data table.
        self.templates = results.data.map(function(
          template: CharacterTemplateInterface
        ) {
          return {
            id: template.id,
            name: template.name,
            description: template.description,
            template: template.template,
            instance_id: template.instance_id,
            features: template.features
          };
        });

        self.templates.forEach((template, index) => {
          Vue.set(self.templateIndex, template.id, index);
        });
      });
  },
  methods: {
    maybeTriggerPreview(): void {
      if (
        this.selectedTemplateRow.length > 0 &&
        this.featuresForPreview != {}
      ) {
        const self = this;

        this.$axios
          .post('/character_templates/preview', {
            template_id: this.selectedTemplateRow[0].id,
            features: this.featuresForPreview
          })
          .then(response => {
            self.templatePreview = response.data.preview;
          });
      }
    },
    characterSelectedForPreview(features: Record<string, unknown>): void {
      this.featuresForPreview = features;
      this.maybeTriggerPreview();
    },
    getTemplatesPaginationLabel(
      start: number,
      end: number,
      total: number
    ): string {
      return total.toString() + ' Template(s)';
    },
    toggleSingleRow(row: CharacterTemplateInterface) {
      this.selectedTemplateRow = [row];
      this.maybeTriggerPreview();
    },
    add() {
      this.editing = true;
      this.isNew = true;
      this.templateUnderConstruction = { ...templateState };
    },
    edit() {
      this.editing = true;
      this.isNew = false;
      this.templateUnderConstruction = { ...this.selectedTemplateRow[0] };
    },
    deleteTemplate() {
      const self = this;

      self.$axios
        .delete('/character_templates/' + self.selectedTemplateRow[0].id)
        .then(function() {
          self.templates.splice(
            self.templateIndex[self.selectedTemplateRow[0].id],
            1
          );

          self.selectedTemplateRow = [];
          self.templateIndex = {};
          self.templates.forEach((template, index) => {
            Vue.set(self.templateIndex, template.id, index);
          });

          self.cancelEdit();
        })
        .catch(function() {
          alert('Error when fetching maps');
        });
    },
    cancelEdit() {
      this.editing = false;
      this.isNew = false;
      this.templateUnderConstruction = { ...templateState };
    },
    save() {
      this.templateUnderConstruction.instance_id = this.instanceBeingBuilt.id;

      let request;
      const self = this;

      if (this.isNew) {
        request = this.$axios.post(
          '/character_templates',
          this.templateUnderConstruction
        );
      } else {
        request = this.$axios.patch(
          '/character_templates/' + this.templateUnderConstruction.id,
          this.templateUnderConstruction
        );
      }

      request
        .then(result => {
          if (self.isNew) {
            Vue.set(this.templateIndex, result.data.id, this.templates.length);
            self.templates.push(result.data);
            self.selectedTemplateRow = [result.data];
          } else {
            Vue.set(
              this.templates,
              this.templateIndex[result.data.id],
              result.data
            );

            self.selectedTemplateRow = [result.data];
          }

          self.cancelEdit();
        })
        .catch(function() {
          alert('Error saving');
        });
    },
    promptForDelete() {
      let name = '';

      if (this.selectedTemplateRow.length > 0) {
        name = this.selectedTemplateRow[0].name;
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
          this.deleteTemplate();
        });
    }
  }
};
</script>

<style lang="sass">
.half-width { width: 50% }
.half-height { height: 50% }
</style>
