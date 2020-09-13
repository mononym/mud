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
      :selected.sync="selected"
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
  props: ['id', 'mapId'],
  components: {},
  created() {
    if (this.mapId !== '') {
      this.populate();
    }

    // if (this.id !== '') {
    //   this.selected = [];
    //   this.selected.push({id: this.id, description: this.description, name: this.name});
    //   this.selectedAreaId = this.id
    // }
  },
  computed: {
    addAreaButtonDisabled: function() {
      return this.mapId === '';
    }
  },
  data() {
    return {
      areas: [],
      areaTableColumns,
      areaTableFilter: '',
      selectedAreaId: '',
      selected: []
    };
  },
  validations: {},
  methods: {
    populate() {
      this.$store
        .dispatch('areas/fetchAreasForMap', this.mapId)
        .then(areas => {
          this.areas = areas;
          this.selected = [];
        })
        .catch(() => {
          alert('Something went wrong attemping to load the areas.');
          this.areas = [];
        });
    },
    addArea() {
      console.log('emitting addArea');
      this.$emit('addArea');
    },
    editArea(areaId) {
      console.log('emitting edit');
      this.$emit('editArea', areaId);
    },
    toggleSingleRow(row) {
      console.log(row);
      this.selectedAreaId = row.id;
      this.selected = [];
      this.selected.push(row);
      this.$emit('selected', row.id);
    }
  },
  watch: {
    mapId(value, previousValue) {
      console.log('area table map id has changed');
      console.log(previousValue);
      console.log(value);
      this.populate();
    },
    id(value) {
      if (value !== this.selectedAreaId) {
        this.$store.dispatch('areas/fetchArea', value).then(area => {
          this.selected = [];
          this.selected.push(area);
        });
      }
    }
  }
};
</script>

<style></style>
