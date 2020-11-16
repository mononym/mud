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
                  :to="'build/' + instance.slug"
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
import { mapGetters } from 'vuex';

export default {
  name: 'BuildDashboardPage',
  data() {
    return {
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
  computed: {
    ...mapGetters({
      instances: 'instances/listAll'
    })
  },
  created: function() {
    this.$store.dispatch('instances/loadAll');
  },
  methods: {
  }
};
</script>
