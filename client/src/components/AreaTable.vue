<template>
  <div class="q-pa-md">
    <q-table
      title="Areas"
      :data="areas"
      :columns="areaTableColumns"
      row-key="id"
      flat
      bordered
      class="full-height"
      :selected.sync="selectedRow"
      selection="single"
    >
      <template v-slot:top>
        <q-btn
          color="primary"
          label="Add Area"
          @click="addArea"
          :disabled="addAreaButtonDisabled"
        />
        <q-space />
        <q-input
          borderless
          dense
          debounce="300"
          color="primary"
          v-model="areaTableFilter"
        >
          <template v-slot:append>
            <q-icon name="search" />
          </template>
        </q-input>
      </template>

      <template v-slot:header="props">
        <q-tr :props="props">
          <q-th v-for="col in props.cols" :key="col.name" :props="props">
            {{ col.label }}
          </q-th>
        </q-tr>
      </template>

      <template v-slot:body="props">
        <q-tr
          class="cursor-pointer"
          :props="props"
          @click.exact="toggleSingleRow(props.row)"
        >
          <q-td v-for="col in props.cols" :key="col.name" :props="props">
            <span v-if="col.name === 'actions'">
              <q-btn-group flat>
                <q-btn
                  flat
                  label="Edit"
                  icon="fas fa-pencil"
                  @click="editArea(props.row.id)"
                />
              </q-btn-group>
            </span>
            <span v-else>
              {{ col.value }}
            </span>
          </q-td>
        </q-tr>
      </template>
    </q-table>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';

const areaTableColumns = [
  { name: 'name', label: 'Name', field: 'name', sortable: true },
  {
    name: 'description',
    label: 'Description',
    field: 'description',
    sortable: false
  },
  { name: 'area', label: 'Area', field: 'area', sortable: true }
];

export default {
  name: 'AreaTable',
  props: [],
  components: {},
  created() {},
  computed: {
    addAreaButtonDisabled: function() {
      return !this.$store.getters['builder/isMapSelected'];
    },
    selectedRow: function() {
      if (this.$store.getters['builder/isAreaSelected']) {
        return [this.$store.getters['builder/selectedArea']];
      } else {
        return [];
      }
    },
    ...mapGetters({
      areas: 'builder/areas'
    })
  },
  data() {
    return {
      areaTableColumns,
      areaTableFilter: ''
    };
  },
  validations: {},
  methods: {
    addArea() {
      this.$store
        .dispatch('builder/selectArea', '')
        .then(() =>
          this.$store
            .dispatch('builder/putIsAreaUnderConstruction', true)
            .then(() => this.$emit('addArea'))
        );
    },
    editArea(areaId) {
      this.$store
        .dispatch('builder/selectArea', areaId)
        .then(() => this.$emit('editArea'));
    },
    toggleSingleRow(row) {
      this.$store.dispatch('builder/selectArea', row.id);
    }
  }
};
</script>

<style></style>
