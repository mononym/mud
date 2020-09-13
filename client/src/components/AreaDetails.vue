<template>
  <div class="q-pa-md fit">
    <q-card flat bordered class="fit column">
      <q-card-section>
        <div class="text-h6">{{ this.area.name }}</div>
      </q-card-section>

      <q-card-section class="q-pt-none col">
        {{ this.area.description }}
      </q-card-section>

      <q-separator inset />

      <q-card-actions>
        <q-btn flat @click="editArea" :disabled="buttonsDisabled">Edit</q-btn>
        <q-btn flat :disabled="buttonsDisabled">Delete</q-btn>
      </q-card-actions>
    </q-card>
  </div>
</template>

<script>

export default {
  name: 'AreaDetails',
  props: ['id'],
  components: {
  },
  created() {
    if (this.id !== '') {
      this.loadArea()
    }
  },
  data() {
    return {
      area: {id: '', name: '', description: '', mapId: ''}
    };
  },
  computed: {
    buttonsDisabled() {
      return this.id === ''
    }
  },
  methods: {
    loadArea() {
      console.log('loadArea()');
      console.log(this.id);

      this.$store.dispatch('areas/fetchArea', this.id).then(area => this.area = area)
    },
    editArea(areaId) {
      this.$emit('editArea', this.id);
    },
  },
  watch: {
    id(value) {
      if (value !== '') {
        this.loadArea()
      }
    }
  }
};
</script>

<style>
</style>
