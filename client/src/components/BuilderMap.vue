<template>
  <div class="q-pa-md col row">
    <q-card flat bordered class="col column">
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

      <q-card-actions class="col-shrink row">
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

<script>
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
    areaIndex: function() {
      const areaIndex = {};

      this.areas.forEach((area, index) => {
        areaIndex[area.id] = index;
      });

      return areaIndex;
    },
    zoomOutButtonDisabled: function() {
      return this.zoomMultierIndex == this.zoomMultipliers.length - 1;
    },
    zoomInButtonDisabled: function() {
      return this.zoomMultierIndex == 0;
    },
    zoomMultiplier: function() {
      return this.zoomMultipliers[this.zoomMultierIndex];
    },
    viewBoxX: function() {
      return this.xCenterPoint - this.viewBoxXSize / 2;
    },
    viewBoxY: function() {
      return this.yCenterPoint - this.viewBoxYSize / 2;
    },
    xCenterPoint: function() {
      if (this.isAreaSelected || this.isAreaUnderConstruction) {
        return this.workingArea.mapX * this.gridSize + this.mapSize / 2;
      } else {
        return this.mapSize / 2;
      }
    },
    yCenterPoint: function() {
      if (this.isAreaSelected || this.isAreaUnderConstruction) {
        return this.workingArea.mapY * this.gridSize + this.mapSize / 2;
      } else {
        return this.mapSize / 2;
      }
    },
    aspectRatioMultiplier: function() {
      return this.aspectRatio.y / this.aspectRatio.x;
    },
    gridSize: function() {
      return this.workingMap.gridSize;
    },
    viewBoxXSize: function() {
      return this.mapSize * this.zoomMultiplier;
    },
    viewBoxYSize: function() {
      return this.mapSize * this.aspectRatioMultiplier * this.zoomMultiplier;
    },
    mapSize: function() {
      return this.workingMap.mapSize;
    },
    viewbox: function() {
      return (
        this.viewBoxX +
        ' ' +
        this.viewBoxY +
        ' ' +
        this.viewBoxXSize +
        ' ' +
        this.viewBoxYSize
      );
    },
    mapName: function() {
      return this.workingMap.name;
    },
    lines: function() {
      const areaIndex = this.areaIndex;
      const gridSize = this.gridSize;
      const mapSize = this.mapSize;
      const areas = this.areas;

      return this.links.map(function(link) {
        const toArea = areas[areaIndex[link.toId]];
        const fromArea = areas[areaIndex[link.fromId]];

        return {
          id: link.id,
          x1: fromArea.mapX * gridSize + mapSize / 2,
          y1: fromArea.mapY * gridSize + mapSize / 2,
          x2: toArea.mapX * gridSize + mapSize / 2,
          y2: toArea.mapY * gridSize + mapSize / 2,
          stroke: 'white'
        };
      });
    },
    squares: function() {
      const gridSize = this.gridSize;
      const mapSize = this.mapSize;
      const workingArea = this.workingArea;

      return this.areas.map(area => ({
        key: area.id,
        x: area.mapX * gridSize + mapSize / 2 - area.mapSize / 2,
        y: area.mapY * gridSize + mapSize / 2 - area.mapSize / 2,
        width: area.mapSize,
        height: area.mapSize,
        fill: area.id === workingArea.id ? 'green' : 'blue',
        name: area.name
      }));
    },
    ...mapGetters({
      links: 'builder/allLinks',
      areas: 'builder/allAreas',
      isAreaSelected: 'builder/isAreaSelected',
      isAreaUnderConstruction: 'builder/isAreaUnderConstruction',
      isMapUnderConstruction: 'builder/isMapUnderConstruction',
      workingArea: 'builder/workingArea',
      workingMap: 'builder/workingMap'
    })
  },
  methods: {
    zoomIn() {
      this.zoomMultierIndex--;
    },
    zoomOut() {
      this.zoomMultierIndex++;
    },
    selectArea(areaId) {
      this.$store.dispatch(
        'builder/selectArea',
        this.areas[this.areaIndex[areaId]]
      );
    }
  }
};
</script>

<style></style>
:key="square.key" :x="square.x" :y="square.y" :width="square.width"
:height="square.height" :fill="square.fill"
