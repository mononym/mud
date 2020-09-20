<template>
  <div class="q-pa-none">
    <q-card class="fit flex column" flat bordered>
      <q-card-section class="col-shrink">
        <p class="text-h6 text-center">
          {{ workingLink.name }}
        </p>
      </q-card-section>

      <q-card-section class="q-pa-none col-auto">
        <q-tabs v-model="tab" class="text-teal" dense align="justify">
          <q-tab name="description" label="Description" />
          <q-tab name="links" label="Links" />
        </q-tabs>
      </q-card-section>

      <q-card-section class="q-pa-none col">
        <p v-show="tab == 'description'" class="q-pa-sm">
          {{ workingLink.shortDescription }}
        </p>
      </q-card-section>

      <q-separator class="col-1px" inset />

      <q-card-actions align="around" class="col-auto">
        <q-btn class="col" flat label="New" />
      </q-card-actions>
    </q-card>
  </div>
</template>

<script lang="ts">
import { mapGetters } from 'vuex';
import { AreaInterface } from 'src/store/area/state';

export default {
  name: 'LinkDetails',
  components: {},
  data() {
    return {
      confirmDelete: false,
      tab: 'description'
    };
  },
  computed: {
    normalizedLinks: function(): Record<string, unknown>[] {
      const areaIndex: Record<string, number> = this.areaIndex;

      // this.areas.forEach((area: AreaInterface, index: number) => {
      //   areaIndex[area.id] = index;
      // });

      const areas = this.areas;
      const links = this.links.map((link: Record<string, string>) => {
        link.toName = areas[areaIndex[link.toId]].name;
        link.fromName = areas[areaIndex[link.fromId]].name;

        return link;
      });

      return links;
    },
    ...mapGetters({
      isLinkUnderConstruction: 'builder/isLinkUnderConstruction',
      isLinkUnderConstructionNew: 'builder/isLinkUnderConstructionNew',
      workingLink: 'builder/workingLink',
      links: 'builder/workingAreaLinks',
      areas: 'builder/areas',
      areaIndex: 'builder/areaIndex'
    })
  },
  methods: {
    editLink() {
      this.$store.dispatch('builder/putIsLinkUnderConstructionNew', false);
      this.$store.dispatch('builder/putIsLinkUnderConstruction', true);
      this.$store.dispatch('builder/putLinkUnderConstruction', {
        ...this.workingLink
      });
    },
    cloneLink() {
      this.$store.dispatch('builder/putIsAreaUnderConstructionNew', true);
      this.$store.dispatch('builder/putIsAreaUnderConstruction', true);
      this.$store.dispatch('builder/putAreaUnderConstruction', {
        ...this.workingLink
      });
    },
    deleteLink() {
      this.$emit('deleteArea');
    }
  }
};
</script>

<style></style>
