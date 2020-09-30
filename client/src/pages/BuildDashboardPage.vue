<template>
  <q-page class="dashboardPage fit">
    <q-card flat bordered>
      <q-card-section>
        <div class="text-h6 text-center">Instances</div>
      </q-card-section>

      <q-separator />

      <q-card-section v-if="instances.length > 0">
        <div class="q-pa-md">
          <li v-for="instance in instances" :key="instance.id">
            <q-card flat bordered class="my-card bg-primary">
              <q-card-section>
                <div class="text-h6 text-center">{{ instance.name }}</div>
              </q-card-section>

              <q-separator />

              <q-card-section>
                <div class="text-h6 text-center">
                  {{ instance.description }}
                </div>
              </q-card-section>

              <q-separator />

              <q-card-actions align="around" class="action-container">
                <q-btn
                  flat
                  class="action-button"
                  :to="instance.buildLink"
                  @click="setInstanceBeingBuilt(instance.slug)"
                  >Build</q-btn
                >
              </q-card-actions>
            </q-card>
          </li>
        </div>
      </q-card-section>

      <q-separator v-if="instances.length > 0" />

      <q-card-actions align="around" class="action-container">
        <q-btn flat class="action-button" to="/build/instances/new"
          >Create Instance</q-btn
        >
      </q-card-actions>
    </q-card>
  </q-page>
</template>

<style lang="sass">
.table
  /* max height is important */
  .q-table__middle
    max-height: 200px

  .q-table__top,
  .q-table__bottom,
  thead tr:first-child th
    /* bg color is important for th; just specify one */
    background-color: #1d1d1d

  thead tr th
    position: sticky
    z-index: 1
  thead tr:first-child th
    top: 0

  /* this is when the loading indicator appears */
  &.q-table--loading thead tr:last-child th
    /* height of all previous header rows */
    top: 48px

.action-container
  padding: 0px

div.action-container button.action-button
  flex: 1
  padding: 8px

div.action-container a.action-button
  flex: 1
  padding: 8px
</style>

<script>
import Vue from 'vue';
import { InstanceInterface } from '../store/instance/state';
// const seed = [
//   {
//     name: 'Khandrish',
//     active: false,
//     race: 'Elf'
//   }
// ];

// we generate lots of rows here
let instances = [];
// for (let i = 0; i < 1000; i++) {
//   data = data.concat(seed.slice(0).map(r => ({ ...r })));
// }
// data.forEach((row, index) => {
//   row.index = index;
// });

// we are not going to change this array,
// so why not freeze it to avoid Vue adding overhead
// with state change detection
// Object.freeze(data);

export default {
  name: 'BuildDashboardPage',
  data() {
    return {
      instances,
      splitterModel: 150,

      pagination: {
        rowsPerPage: 0
      },
      columns: [
        {
          name: 'active',
          align: 'center',
          label: 'Active',
          field: 'active',
          sortable: true
        },
        {
          name: 'name',
          label: 'Character',
          field: 'name'
        },
        { name: 'race', label: 'Race', field: 'race', sortable: true }
      ],
      tab: 'quickActions'
    };
  },
  mounted: function() {
    this.$axios.get('/instances').then(response => {
      this.instances = response.data.map(function(instance) {
        instance['buildLink'] = 'build/' + instance.slug;

        return instance;
      });

      console.log('here');
      console.log(this.instances);

      this.$store.dispatch('builder/putInstances', response.data);
    });
  },
  methods: {
    setInstanceBeingBuilt(instanceSlug) {
      this.$store.dispatch('builder/putInstanceBeingBuilt', instanceSlug);
    }
  }
};
</script>
