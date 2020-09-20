<template>
  <div class="q-pa-none">
    <q-card flat bordered class="q-pa-none">
      <q-card-section class="q-plbr-none text-h6 text-center">
        {{ workingLinkFromArea.name }} to {{ workingLinkToArea.name }}
      </q-card-section>

      <q-card-section class="q-pa-none">
        <q-stepper
          v-model="step"
          class="q-pa-none"
          vertical
          color="primary"
          header-nav
        >
          <q-step
            :name="1"
            title="Visuals"
            icon="fas fa-eye"
            :done="step > 1"
            :header-nav="step > 1 || !isNew"
            :caption="link.shortDescription"
          >
            <p>What players see</p>

            <q-form class="q-gutter-md">
              <q-select
                v-model="icon"
                filled
                :options="iconOptions"
                label="Standard"
                color="teal"
                clearable
                options-selected-class="text-deep-orange"
              >
                <template v-slot:before>
                  <q-icon :name="icon.icon" />
                </template>
                <template v-slot:option="scope">
                  <q-item v-bind="scope.itemProps" v-on="scope.itemEvents">
                    <q-item-section avatar>
                      <q-icon :name="scope.opt.icon" />
                    </q-item-section>
                    <q-item-section>
                      <q-item-label>{{ scope.opt.label }}</q-item-label>
                      <q-item-label caption>{{
                        scope.opt.description
                      }}</q-item-label>
                    </q-item-section>
                  </q-item>
                </template>
              </q-select>
              <q-input
                v-model="link.shortDescription"
                label="Short Description"
              />

              <q-input
                v-model="link.longDescription"
                label="Long Description"
              />
            </q-form>

            <q-stepper-navigation>
              <q-btn
                :disabled="descriptionContinueButtonDisabled"
                color="primary"
                label="Continue"
                @click="step = 2"
              />
            </q-stepper-navigation>
          </q-step>

          <q-step
            :name="2"
            title="Arrival and Departure Strings"
            icon="fas fa-signature"
            :done="step > 2"
            :header-nav="step > 2 || !isNew"
          >
            <p>What players see when a character enters and leaves an area.</p>

            <q-form class="q-gutter-md">
              <q-input v-model="link.arrivalText" label="Arrival Text" />

              <q-input v-model="link.departureText" label="Departure Text" />
            </q-form>
            <q-stepper-navigation>
              <q-btn
                :disabled="descriptionContinueButtonDisabled"
                color="primary"
                label="Continue"
                @click="step = 3"
              />
              <q-btn
                flat
                color="primary"
                label="Back"
                class="q-ml-sm"
                @click="step = 1"
              />
            </q-stepper-navigation>
          </q-step>

          <q-step
            :name="3"
            title="Icon"
            icon="fas fa-signature"
            :done="step > 3"
            :header-nav="step > 3 || !isNew"
          >
            <div class="q-pa-lg"></div>

            <q-stepper-navigation>
              <q-btn
                flat
                color="primary"
                label="Back"
                class="q-ml-sm"
                @click="step = 2"
              />
            </q-stepper-navigation>
          </q-step>
        </q-stepper>
      </q-card-section>

      <q-card-actions align="around" class="q-pa-none">
        <q-btn
          v-if="!saveButtonDisabled"
          class=""
          label="Save"
          @click="saveLink"
        />
        <q-btn class="" label="Cancel" @click="cancel" />
      </q-card-actions>
    </q-card>
  </div>
</template>

<script lang="ts">
import { mapGetters } from 'vuex';
import linkState from '../store/link/state';

interface IconOption {
  label: string;
  value: string;
  description: string;
  icon: string;
}

export default {
  name: 'LinkWizard',
  components: {},
  data() {
    return {
      originalMapId: '',
      mapChanged: false,
      map: '',
      step: 1,
      icon: {
        label: '',
        value: '',
        description: '',
        icon: ''
      },
      selectedMapOptionValue: '',
      link: { ...linkState },
      iconOptions: [
        {
          label: '',
          value: '',
          description: '',
          icon: ''
        }
      ]
    };
  },
  computed: {
    descriptionContinueButtonDisabled: function(): boolean {
      return (
        this.link.shortDescription === '' || this.link.longDescription === ''
      );
    },
    textContinueButtonDisabled: function(): boolean {
      return this.link.arrivalText === '' || this.link.departureText === '';
    },
    saveButtonDisabled: function(): boolean {
      return (
        this.link.shortDescription === '' ||
        this.link.longDescription === '' ||
        this.link.arrivalText === '' ||
        this.link.departureText === ''
      );
    },
    allowNameHeaderSelect: function(): boolean {
      return !this.isNew;
    },
    selectedMapName: function(): string {
      return this.selectedMap.name;
    },
    mapOptions: function(): Record<string, string> {
      return this.maps.map((map: Record<string, string>) => {
        map.label = map.name;
        map.value = map.id;
      });
    },
    ...mapGetters({
      maps: 'builder/maps',
      linkUnderConstruction: 'builder/linkUnderConstruction',
      selectedLink: 'builder/selectedLink',
      workingLink: 'builder/workingLink',
      selectedMap: 'builder/selectedMap',
      isNew: 'builder/isLinkUnderConstructionNew',
      workingLinkToArea: 'builder/workingLinkToArea',
      workingLinkFromArea: 'builder/workingLinkFromArea'
    })
  },
  watch: {
    link: {
      // This will let Vue know to look inside the array
      deep: true,

      // We have to move our method to a handler field
      handler() {
        this.$store.dispatch(
          'builder/putLinkUnderConstruction',
          Object.assign({}, this.link)
        );
      }
    }
  },
  created() {
    this.link = Object.assign({}, this.linkUnderConstruction);

    this.iconOptions = [
      this.compassIcon(),
      this.closedDoorIcon(),
      this.openDoorIcon(),
      this.gateIcon(),
      this.archwayIcon()
    ];

    switch (this.link.icon) {
      case '':
        this.icon = this.emptyIcon();
        break;
      case 'compass':
        this.icon = this.compassIcon();
        break;
      case 'door-closed':
        this.icon = this.closedDoorIcon();
        break;
      case 'archway':
        this.icon = this.archwayIcon();
        break;
      case 'gate':
        this.icon = this.gateIcon();
        break;
      default:
    }
  },
  methods: {
    emptyIcon(): IconOption {
      return {
        label: '',
        value: '',
        description: '',
        icon: ''
      };
    },
    compassIcon(): IconOption {
      return {
        label: 'Compass',
        value: 'compass',
        description: 'Directional Exit',
        icon: 'fas fa-compass'
      };
    },
    closedDoorIcon(): IconOption {
      return {
        label: 'Closed Door',
        value: 'door-closed',
        description: 'Standard Closed Door',
        icon: 'fas fa-door-closed'
      };
    },
    openDoorIcon(): IconOption {
      return {
        label: 'Open Door',
        value: 'door-open',
        description: 'Standard Open Door',
        icon: 'fas fa-door-open'
      };
    },
    archwayIcon(): IconOption {
      return {
        label: 'Archway',
        value: 'archway',
        description: 'Archway',
        icon: 'fas fa-archway'
      };
    },
    gateIcon(): IconOption {
      return {
        label: 'Gate',
        value: 'gate',
        description: 'Gates of all types',
        icon: 'fas fa-dungeon'
      };
    },
    cancel() {
      this.$store
        .dispatch('builder/putIsLinkUnderConstruction', false)
        .then(() =>
          this.$store.dispatch('builder/putBottomRightPanel', 'areaTable')
        );
    },
    saveLink() {
      this.link.icon = this.icon.value;
      // const params = {
      //   link: {
      //     name: this.link.name,
      //     map_id: this.link.mapId,
      //     shortDescription: this.link.shortDescription,
      //     longDescription: this.link.longDescription
      //   }
      // };
      // let request;
      // if (this.isNew) {
      //   request = this.$axios.post('/links', params);
      // } else {
      //   const id: string = this.workingLink.id;
      //   request = this.$axios.patch('/links/' + id, params);
      //   if (this.mapChanged) {
      //     request.then(result => {
      //       this.$store
      //         .dispatch('builder/fetchDataForMap', this.link.mapId)
      //         .then(() =>
      //           this.$store
      //             .dispatch('builder/selectLink', result.data)
      //             .then(() => this.$emit('saved'))
      //         );
      //     });
      //   } else {
      //     request
      //       .then(result => {
      //         if (this.isNew) {
      //           this.$store
      //             .dispatch('builder/putLink', result.data)
      //             .then(() => {
      //               this.$store
      //                 .dispatch('builder/selectLink', result.data)
      //                 .then(() =>
      //                   this.$store.dispatch(
      //                     'builder/putIsLinkUnderConstruction',
      //                     false
      //                   )
      //                 )
      //                 .then(() => {
      //                   this.$emit('saved');
      //                 });
      //             });
      //         } else {
      //           this.$store
      //             .dispatch('builder/updateLink', result.data)
      //             .then(() =>
      //               this.$store.dispatch(
      //                 'builder/putIsLinkUnderConstruction',
      //                 false
      //               )
      //             )
      //             .then(() => {
      //               this.$emit('saved');
      //             });
      //         }
      //       })
      //       .catch(function() {
      //         alert('Error saving');
      //       });
      //   }
      // }
    }
  }
};
</script>

<style></style>
