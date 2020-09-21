<template>
  <q-page class="dashboardPage col flex row">
    <q-splitter
      class="dashboardSplitter col flex-1"
      v-model="splitterModel"
      unit="px"
      disable
    >
      <template v-slot:before>
        <q-tabs v-model="tab" vertical class="dashboardTabs text-teal fit">
          <q-tab
            name="quickActions"
            icon="fas fa-stopwatch"
            label="Quick Actions"
            class="dashboardTab"
          />
          <q-tab
            v-if="showDevTab"
            name="instances"
            icon="fas fa-dice-d20"
            label="Instances"
            class="dashboardTab"
          />
          <q-tab
            name="muds"
            icon="fas fa-comments"
            label="Forums"
            class="dashboardTab"
          />
        </q-tabs>
      </template>

      <template v-slot:after>
        <q-tab-panels
          v-model="tab"
          animated
          transition-prev="jump-up"
          transition-next="jump-up"
          class="fit"
        >
          <q-tab-panel name="quickActions">
            <q-card flat bordered class="bg-primary">

              <q-card-section>
                <div class="text-h6 text-center">Characters</div>
              </q-card-section>
              
              <q-separator />
              
              <q-card-section v-if="characters.length > 0">
                <div class="q-pa-md">
                  <q-table
                    class="table"
                    :data="characters"
                    :columns="columns"
                    table-style="max-height: 400px"
                    row-key="index"
                    virtual-scroll
                    :pagination.sync="pagination"
                    :rows-per-page-options="[0]"
                  />
                </div>
              </q-card-section>

              <q-separator v-if="characters.length > 0" />

              <q-card-actions align="around" class="action-container">
                <q-btn flat class="action-button" to="/characters/new"
                  >Create Character</q-btn
                >
              </q-card-actions>
            </q-card>
          </q-tab-panel>

          <q-tab-panel name="muds">
            <q-card flat bordered class="my-card bg-primary">
              <q-card-section>
                <div class="q-pa-md">
                  <q-table
                    title="Quickplay"
                    class="table"
                    :data="characters"
                    :columns="columns"
                    table-style="max-height: 400px"
                    row-key="index"
                    virtual-scroll
                    :pagination.sync="pagination"
                    :rows-per-page-options="[0]"
                  />
                </div>
              </q-card-section>

              <q-separator />

              <q-card-actions align="around" class="action-container">
                <q-btn flat class="action-button">Create MUD</q-btn>
                <q-btn flat class="action-button">Dismiss</q-btn>
              </q-card-actions>
            </q-card>
          </q-tab-panel>
        </q-tab-panels>
      </template>
    </q-splitter>
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
// const seed = [
//   {
//     name: 'Khandrish',
//     active: false,
//     race: 'Elf'
//   }
// ];

// we generate lots of rows here
let characters = [];
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
  name: 'DashboardPage',
  computed: {
    showDevTab() {
      return this.$store.getters['settings/getDeveloperFeatureOn'];
    },
    hasCharacters() {
      return length(this.characters)
    },
    characters2() {
      return this.$store.getters['characters/listByPlayerId'];
    },
  },
  data() {
    return {
      characters,
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
  }
};
</script>
