<template>
  <q-page class="dashboardPage row">
    <q-splitter
      class="dashboardSplitter col"
      v-model="splitterModel"
      unit="px"
      disable
    >
      <template v-slot:before>
        <q-tabs v-model="tab" vertical class="dashboardTabs text-teal">
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
          class="fit"
        >
          <q-tab-panel name="world">
            <build-instance/>
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
