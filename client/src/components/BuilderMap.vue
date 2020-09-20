<template>
  <div class="q-pa-none">
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
            class="cursor-pointer"
            @click="selectArea(square.key)"
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
  </div>
</template>

<script lang="ts">
import { AreaInterface } from 'src/store/area/state';
import { LinkInterface } from 'src/store/link/state';
import { mapGetters } from 'vuex';

export default {
  name: 'BuilderMap',
  data() {
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
      if (this.isAreaSelected || this.isAreaUnderConstruction) {
        return this.workingArea.mapX * this.gridSize + this.mapSize / 2;
      } else {
        return this.mapSize / 2;
      }
    },
    yCenterPoint: function(): number {
      if (this.isAreaSelected || this.isAreaUnderConstruction) {
        return this.workingArea.mapY * this.gridSize + this.mapSize / 2;
      } else {
        return this.mapSize / 2;
      }
    },
    aspectRatioMultiplier: function(): number {
      return this.aspectRatio.y / this.aspectRatio.x;
    },
    gridSize: function(): number {
      return this.workingMap.gridSize;
    },
    viewBoxXSize: function(): number {
      return this.mapSize * this.zoomMultiplier;
    },
    viewBoxYSize: function(): number {
      return this.mapSize * this.aspectRatioMultiplier * this.zoomMultiplier;
    },
    mapSize: function(): number {
      return this.workingMap.mapSize;
    },
    viewbox: function(): string {
      return `${this.viewBoxX.toString()} ${this.viewBoxY.toString()} ${this.viewBoxXSize.toString()} ${this.viewBoxYSize.toString()}`;
    },
    mapName: function(): string {
      return this.workingMap.name;
    },
    lines: function(): Record<string, unknown>[] {
      const areaIndex = this.areaIndex;
      const map = this.workingMap;
      const gridSize = this.workingMap.gridSize;
      const mapSize = this.mapSize;
      const areas = this.areas;
      const workingLink = this.workingLink;

      return (
        this.links
          .map(function(link: LinkInterface) {
            const toArea = areas[areaIndex[link.toId]];
            const fromArea = areas[areaIndex[link.fromId]];
            let stroke;

            if (
              (workingLink.toId == link.fromId &&
                workingLink.fromId == link.toId) ||
              link.id == workingLink.id
            ) {
              stroke = 'red';
            } else {
              stroke = 'white';
            }

            return {
              id: link.id,
              x1: fromArea.mapX * gridSize + mapSize / 2,
              y1: fromArea.mapY * gridSize + mapSize / 2,
              x2: toArea.mapX * gridSize + mapSize / 2,
              y2: toArea.mapY * gridSize + mapSize / 2,
              stroke: stroke
            };
          })
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          .sort(function(firstLink: any, secondLink: any) {
            if (
              firstLink.id !== workingLink.id &&
              secondLink.id !== workingLink.id
            ) {
              return 0;
            } else if (firstLink.id == workingLink.id) {
              return 1;
            } else {
              return 0;
            }
          })
      );
    },
    squares: function(): Record<string, unknown>[] {
      const gridSize = this.gridSize;
      const mapSize = this.mapSize;
      const workingArea = this.workingArea;

      return this.areas.map(function(area: AreaInterface) {
        return {
          key: area.id,
          x: area.mapX * gridSize + mapSize / 2 - area.mapSize / 2,
          y: area.mapY * gridSize + mapSize / 2 - area.mapSize / 2,
          width: area.mapSize,
          height: area.mapSize,
          fill: area.id === workingArea.id ? 'green' : 'blue',
          name: area.name
        };
      });
    },
    ...mapGetters({
      links: 'builder/links',
      areas: 'builder/areas',
      isAreaSelected: 'builder/isAreaSelected',
      isAreaUnderConstruction: 'builder/isAreaUnderConstruction',
      isMapUnderConstruction: 'builder/isMapUnderConstruction',
      workingArea: 'builder/workingArea',
      workingMap: 'builder/workingMap',
      workingLink: 'builder/workingLink'
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
    selectArea(areaId: any) {
      if (areaId !== this.workingArea.id) {
        const id: string = areaId.toString();
        this.$store.dispatch(
          'builder/selectArea',
          this.areas[this.areaIndex[id]]
        );

        this.$store.dispatch('builder/clearSelectedLink');
      }
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
