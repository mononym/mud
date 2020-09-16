<template>
  <q-page class="build-instance-page col column">
    <q-splitter
      class="dashboardSplitter col-grow row"
      v-model="splitterModel"
      unit="px"
      disable
    >
      <template v-slot:before>
        <q-tabs
          v-model="tab"
          vertical
          class="dashboardTabs text-teal col-shrink"
        >
          <q-tab
            name="world"
            icon="fas fa-globe"
            label="World"
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
          class="col-grow full-height row"
        >
          <q-tab-panel class="col row p-a-none" name="world">
            <build-instance />
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
  </q-page>
</template>

<style lang="sass">
.build-instance-page
  max-height: calc(100vh - 50px) !important
</style>

<script>
import BuildInstance from '../components/BuildInstance.vue';
import WorldMap from '../components/WorldMap.vue';

export default {
  name: 'BuildInstancePage',
  computed: {},
  components: { BuildInstance, WorldMap },
  data() {
    return {
      scripts: [],
      splitterModel: 150,
      tab: 'world',
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
