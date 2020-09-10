<template>
  <q-page class="dashboardPage">
    <div class="dashboardContainer row full-width">
      <q-splitter
        class="dashboardSplitter full-width"
        v-model="splitterModel"
        unit="px"
        disable
      >
        <template v-slot:before>
          <q-tabs v-model="tab" vertical class="dashboardTabs text-teal">
            <q-tab
              name="regions"
              icon="fas fa-globe"
              label="Regions"
              class="dashboardTab"
            />
            <q-tab
              name="lua"
              icon="fas fa-code"
              label="Lua Scripts"
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
          >
            <q-tab-panel name="regions">
              <div class="q-pa-md row">
                <q-list bordered>
                  <q-item
                    class="col-shrink"
                    v-for="region in regions"
                    :key="region.name"
                    clickable
                    v-ripple
                  >
                    <q-item-section avatar>
                      <q-avatar color="primary" text-color="white">
                        {{ region.name.charAt(0).toUpperCase() }}
                      </q-avatar>
                    </q-item-section>

                    <q-item-section>
                      <q-item-label>{{ region.name }}</q-item-label>
                      <q-item-label caption lines="2">{{
                        region.description
                      }}</q-item-label>
                    </q-item-section>

                    <q-item-section>
                      <q-btn-group push>
                        <q-btn
                          push
                          label="edit"
                          icon="fas fa-pencil"
                          :to="region.editLink"
                        />
                        <q-btn
                          push
                          label="build"
                          icon="fas fa-hammer"
                          :to="region.buildLink"
                        />
                      </q-btn-group>
                    </q-item-section>
                  </q-item>
                </q-list>
              </div>
            </q-tab-panel>

            <q-tab-panel name="lua">
              <q-card flat bordered class="my-card bg-primary">
                <q-card-section> </q-card-section>

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
    </div>
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
import WorldMap from '../components/WorldMap.vue';

export default {
  name: 'BuildInstancePage',
  computed: {},
  components: { WorldMap },
  data() {
    return {
      scripts: [],
      splitterModel: 150,
      tab: 'regions',
      regions: [
        {
          name: 'Placeholder',
          description: 'The initial region to build stuff in',
          slug: 'placeholder',
          editLink: this.$route.params.instance + '/region/placeholder/edit',
          buildLink: this.$route.params.instance + '/region/placeholder/build'
        }
      ]
    };
  }
};
</script>
