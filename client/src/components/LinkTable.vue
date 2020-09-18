<template>
  <div class="q-pa-md col column">
    <q-table
      title="Links"
      :data="links"
      :columns="linkTableColumns"
      row-key="id"
      flat
      bordered
      class="col"
      :selected.sync="selectedRow"
      selection="single"
    >
      <template v-slot:top>
        <q-btn
          color="primary"
          label="Add Link"
          @click="addLink"
          :disabled="addLinkButtonDisabled"
        />
        <q-space />
        <q-input
          borderless
          dense
          debounce="300"
          color="primary"
          v-model="linkTableFilter"
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
          <q-td
            class="link-table-row"
            v-for="col in props.cols"
            :key="col.name"
            :props="props"
          >
            <span v-if="col.name === 'actions'">
              <q-btn-group flat spread>
                <q-btn
                  flat
                  label="Edit"
                  icon="fas fa-pencil"
                  @click="editLink(props.row)"
                />
                <q-btn
                  flat
                  label="Link"
                  icon="fas fa-link"
                  v-on:click.stop="linkLink(props.row)"
                  v-if="props.row.id !== selectedLinkId && selectedLinkId != ''"
                />
                <q-btn
                  flat
                  label="Delete"
                  icon="fas fa-trash"
                  @click="deleteLink"
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
import linkState from '../store/link/state';

const linkTableColumns = [
  { name: 'actions', label: 'Actions', field: 'actions', sortable: false },
  {
    name: 'shortDescription',
    label: 'Short Description',
    field: 'shortDescription',
    sortable: true
  },
  {
    name: 'longDescription',
    label: 'Long Description',
    field: 'longDescription',
    sortable: true
  },
  {
    name: 'departureText',
    label: 'Departure Text',
    field: 'departureText',
    sortable: true
  },
  {
    name: 'arrivalText',
    label: 'Arrival Text',
    field: 'arrivalText',
    sortable: true
  },
  { name: 'icon', label: 'Icon', field: 'icon', sortable: false },
  { name: 'toId', label: 'To', field: 'toId', sortable: false },
  { name: 'fromId', label: 'From', field: 'fromId', sortable: false }
];

export default {
  name: 'LinkTable',
  components: {},
  data() {
    return {
      linkTableColumns,
      linkTableFilter: ''
    };
  },
  computed: {
    addLinkButtonDisabled: function() {
      return !this.$store.getters['builder/isMapSelected'];
    },
    selectedLinkId: function() {
      return this.selectedLink.id;
    },
    selectedMapId: function() {
      return this.selectedMap.id;
    },
    selectedRow: function() {
      return [this.$store.getters['builder/selectedLink']];
    },
    ...mapGetters({
      links: 'builder/allLinks',
      selectedLink: 'builder/selectedLink',
      selectedMap: 'builder/selectedMap'
    })
  },
  created() {},
  validations: {},
  methods: {
    addLink() {
      const newLink = { ...linkState };
      newLink.mapId = this.selectedMapId;
      console.log('newlink');
      console.log(newLink);
      this.$store.dispatch('builder/putIsLinkUnderConstructionNew', true);
      this.$store.dispatch('builder/putIsLinkUnderConstruction', true);
      this.$store.dispatch('builder/putLinkUnderConstruction', newLink);

      this.$emit('addLink');
    },
    editLink(link) {
      this.$store.dispatch('builder/selectLink', link).then(() =>
        this.$store
          .dispatch('builder/putIsLinkUnderConstructionNew', false)
          .then(() =>
            this.$store
              .dispatch('builder/putIsLinkUnderConstruction', true)
              .then(() =>
                this.$store
                  .dispatch('builder/putLinkUnderConstruction', {
                    ...this.selectedLink
                  })
                  .then(() => this.$emit('editLink'))
              )
          )
      );
    },
    linkLink(linkId) {
      console.log('link to link: ' + linkId);
    },
    toggleSingleRow(row) {
      this.$store.dispatch('builder/selectLink', row);
    },
    deleteLink() {
      this.$emit('deleteLink');
    }
  }
};
</script>

<style lang="sass">
.q-table td, .q-table th {  white-space: normal !important; }

td.link-table-cell {  border-bottom-width: 1 !important; }
</style>
