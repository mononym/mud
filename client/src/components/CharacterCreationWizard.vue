<template>
  <div class="q-pa-md">
    <q-stepper
      v-model="step"
      vertical
      color="primary"
      animated
    >
      <q-step
        :name="1"
        title="Select an instance"
        icon="fas fa-dice-d20"
        :done="step > 1"
      >
        The available options for creating a character depend partly on the active
      features and configuration of the selected instance.

        <q-select v-model="selectedInstance" :options="instances" label="Instance:" />

        <q-stepper-navigation>
          <q-btn @click="step = 2" color="primary" label="Continue" />
        </q-stepper-navigation>
      </q-step>

      <q-step
        :name="2"
        title="Create an ad group"
        caption="Optional"
        icon="create_new_folder"
        :done="step > 2"
      >
        An ad group contains one or more ads which target a shared set of keywords.

        <q-stepper-navigation>
          <q-btn @click="step = 4" color="primary" label="Continue" />
          <q-btn flat @click="step = 1" color="primary" label="Back" class="q-ml-sm" />
        </q-stepper-navigation>
      </q-step>

      <q-step
        :name="3"
        title="Ad template"
        icon="assignment"
        disable
      >
        This step won't show up because it is disabled.
      </q-step>

      <q-step
        :name="4"
        title="Create an ad"
        icon="add_comment"
      >
        Try out different ad text to see what brings in the most customers, and learn how to
        enhance your ads using features like ad extensions. If you run into any problems with
        your ads, find out how to tell if they're running and how to resolve approval issues.

        <q-stepper-navigation>
          <q-btn color="primary" label="Finish" />
          <q-btn flat @click="step = 2" color="primary" label="Back" class="q-ml-sm" />
        </q-stepper-navigation>
      </q-step>
    </q-stepper>
  </div>
</template>

<script>
// import { validationMixin } from 'vuelidate'
// import { helpers, required } from 'vuelidate/lib/validators'

export default {
  name: 'CharacterCreationWizard',
  // mixins: [validationMixin],
  components: {},
  computed: {
    instances() {
      let instances = this.$store.getters['instances/listAll'];

      console.log(instances)
      return instances
    }
  },
  data() {
    return {
      step: 1,
      muds: [
        {
          label: 'Dragon Realms',
          value: 'dragon-realms',
          description: 'A place with adventure, and all that.',
          category: '1'
        }
      ],
      selectedInstance: null
    };
  },
  validations: {},
  methods: {}
};
</script>

<style>
#authFormWrapper {
  display: flex;
}
</style>
