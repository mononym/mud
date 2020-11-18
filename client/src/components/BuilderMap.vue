<template>
  <q-card flat bordered class="fit flex column">
    <q-card-section class="col-shrink">
      <div class="text-h6 text-center">{{ mapName }}</div>
    </q-card-section>

    <q-card-section class="col-grow">
      <svg
        width="100%"
        height="100%"
        class=""
        :viewBox="viewbox"
        preserveAspectRatio="xMidYMid meet"
      >
        <line
          v-for="line in lines"
          :key="line.id"
          :x1="line.x1"
          :y1="line.y1"
          :x2="line.x2"
          :y2="line.y2"
          :stroke="line.stroke"
          stroke-width="2"
        />
        <rect
          v-for="square in squares"
          :key="square.key"
          :x="square.x"
          :y="square.y"
          :width="square.width"
          :height="square.height"
          :fill="square.fill"
          :class="readonly ? 'pointer' : 'cursor-pointer'"
          @click="selectArea(square.area)"
        >
          <title>{{ square.name }}</title>
        </rect>
      </svg>
    </q-card-section>

    <q-separator class="col-1px full-width" dark />

    <q-card-actions class="col-shrink">
      <q-btn
        flat
        class="action-button col"
        icon="fas fa-minus"
        :disabled="zoomOutButtonDisabled"
        @click="zoomOut"
      />
      <q-btn
        flat
        class="action-button col"
        icon="fas fa-plus"
        :disabled="zoomInButtonDisabled"
        @click="zoomIn"
      />
    </q-card-actions>
  </q-card>
</template>

<script lang="ts">
import { AreaInterface } from 'src/store/area/state';
import { LinkInterface } from 'src/store/link/state';
import { MapInterface } from 'src/store/map/state';
import { mapGetters } from 'vuex';
import { Prop } from 'vue/types/options';
import { PropOptions } from 'vue';

export default {
  name: 'BuilderMap',
  props: {
    readonly: {
      type: Boolean,
      default: false
    },
    focusarea: {
      type: String,
      required: true
    },
    map: {
      type: Object as Prop<MapInterface>,
      required: true
    },
    areas: <PropOptions<AreaInterface[]>>{
      type: Array,
      required: true,
      default: () => []
    },
    links: <PropOptions<LinkInterface[]>>{
      type: Array,
      required: true,
      default: () => []
    },
    mapareahighlights: {
      type: Object,
      required: true
    },
    maplinkhighlights: {
      type: Object,
      required: true
    }
  },
  data(): {
    aspectRatio: { x: number; y: number };
    zoomMultipliers: number[];
    zoomMultierIndex: number;
  } {
    return {
      aspectRatio: { x: 16, y: 9 },
      zoomMultipliers: [0.06, 0.125, 0.25, 0.5, 1, 2],
      zoomMultierIndex: 2
    };
  },
  computed: {
    areaIndex: function(): Record<string, number> {
      const areaIndex: Record<string, number> = {};

      this.areas.forEach((area: AreaInterface, index: number) => {
        areaIndex[area.id] = index;
      });

      return areaIndex;
    },
    zoomOutButtonDisabled: function(): boolean {
      return this.zoomMultierIndex == this.zoomMultipliers.length - 1;
    },
    zoomInButtonDisabled: function(): boolean {
      return this.zoomMultierIndex == 0;
    },
    zoomMultiplier: function(): number {
      return this.zoomMultipliers[this.zoomMultierIndex];
    },
    viewBoxX: function(): string {
      return (this.xCenterPoint - this.viewBoxXSize / 2).toString();
    },
    viewBoxY: function(): string {
      return (this.yCenterPoint - this.viewBoxYSize / 2).toString();
    },
    xCenterPoint: function(): number {
      if (this.areaIndex[this.focusarea] != undefined) {
        return (
          this.areas[this.areaIndex[this.focusarea]].mapX * this.gridSize +
          this.mapSize / 2
        );
      } else {
        return this.mapSize / 2;
      }
    },
    yCenterPoint: function(): number {
      if (this.areaIndex[this.focusarea] != undefined) {
        return (
          -(this.areas[this.areaIndex[this.focusarea]].mapY) * this.gridSize +
          this.mapSize / 2
        );
      } else {
        return this.mapSize / 2;
      }
    },
    aspectRatioMultiplier: function(): number {
      return this.aspectRatio.y / this.aspectRatio.x;
    },
    gridSize: function(): number {
      return this.map.gridSize;
    },
    viewBoxXSize: function(): number {
      return this.mapSize * this.zoomMultiplier;
    },
    viewBoxYSize: function(): number {
      return this.mapSize * this.aspectRatioMultiplier * this.zoomMultiplier;
    },
    mapSize: function(): number {
      return this.map.mapSize;
    },
    viewbox: function(): string {
      return `${this.viewBoxX.toString()} ${this.viewBoxY.toString()} ${this.viewBoxXSize.toString()} ${this.viewBoxYSize.toString()}`;
    },
    mapName: function(): string {
      return this.map.name;
    },
    lines: function(): Record<string, unknown>[] {
      // To take care of the case of displaying incorrect lines/squares configuration while map is loading
      if (this.map.id == '') {
        return [];
      }
      const areaIndex = this.areaIndex;
      const gridSize = this.map.gridSize;
      const mapSize = this.mapSize;
      const areas = this.areas;
      const self = this;

      return (
        this.links
          .filter(
            link =>
              areas[areaIndex[link.toId]] != undefined &&
              areas[areaIndex[link.fromId]] != undefined
          )
          .map(function(link: LinkInterface) {
            const toArea = areas[areaIndex[link.toId]];
            const fromArea = areas[areaIndex[link.fromId]];

            return {
              id: link.id,
              x1: fromArea.mapX * gridSize + mapSize / 2,
              y1: -(fromArea.mapY) * gridSize + mapSize / 2,
              x2: toArea.mapX * gridSize + mapSize / 2,
              y2: -(toArea.mapY) * gridSize + mapSize / 2,
              stroke: self.maplinkhighlights[link.id] || 'white'
            };
          })
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          .sort(function(firstLink: any, secondLink: any) {
            if (self.maplinkhighlights[firstLink.id] != undefined) {
              return 1;
            } else if (self.maplinkhighlights[secondLink.id] != undefined) {
              return -1;
            } else {
              return 0;
            }
          })
      );
    },
    squares: function(): Record<string, unknown>[] {
      // To take care of the case of displaying incorrect lines/squares configuration while map is loading
      if (this.map.id == '') {
        return [];
      }

      const gridSize = this.gridSize;
      const mapSize = this.mapSize;
      const self = this;

      return this.areas.map(function(area: AreaInterface) {
        return {
          key: area.id,
          x: area.mapX * gridSize + mapSize / 2 - area.mapSize / 2,
          y: -(area.mapY) * gridSize + mapSize / 2 - area.mapSize / 2,
          width: area.mapSize,
          height: area.mapSize,
          fill: self.mapareahighlights[area.id] || 'blue',
          name: area.name,
          area: area
        };
      });
    },
    ...mapGetters({
      instanceBeingBuilt: 'instances/instanceBeingBuilt'
      // isAreaSelected: 'builder/isAreaSelected',
      // isAreaUnderConstruction: 'builder/isAreaUnderConstruction',
      // isMapUnderConstruction: 'builder/isMapUnderConstruction',
      // workingArea: 'builder/workingArea',
      // workingLink: 'builder/workingLink'
    })
  },
  methods: {
    zoomIn(): void {
      this.zoomMultierIndex--;
    },
    zoomOut() {
      this.zoomMultierIndex++;
    },
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    selectArea(area: AreaInterface) {
      if (!this.readonly) {
        this.$emit('selectArea', area);
      }
      // if (areaId !== this.workingArea.id) {
      //   const id: string = areaId.toString();
      //   this.$store.dispatch(
      //     'builder/selectArea',
      //     this.areas[this.areaIndex[id]]
      //   );

      //   this.$store.dispatch('builder/clearSelectedLink');
      // }
    }
  }
};
</script>

<style>
.builder-map-wrapper {
  height: 50%;
  width: 50%;
}
</style>
