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
            stroke="black"
          />
          <rect
            v-for="square in squares"
            :key="square.key"
            :x="square.x"
            :y="square.y"
            :width="square.width"
            :height="square.height"
            :fill="square.fill"
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
          @click="zoomOut"
          :disabled="zoomOutButtonDisabled"
        />
        <q-btn
          flat
          class="action-button col"
          icon="fas fa-plus"
          @click="zoomIn"
          :disabled="zoomInButtonDisabled"
        />
      </q-card-actions>
    </q-card>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';

export default {
  name: 'BuilderMap',
  created() {},
  data() {
    return {
      aspectRatio: { x: 16, y: 9 },
      lines: [{ id: 1, x1: 500, y1: 500, x2: 520, y2: 500 }],
      zoomMultipliers: [0.06, 0.125, 0.25, 0.5, 1, 2],
      zoomMultierIndex: 2
    };
  },
  methods: {
    zoomIn() {
      this.zoomMultierIndex--;
    },
    zoomOut() {
      this.zoomMultierIndex++;
    }
  },
  computed: {
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
    squares: function() {
      return this.areas.map(area => ({
        key: area.id,
        x: area.mapX * this.gridSize + this.mapSize / 2,
        y: area.mapY * this.gridSize + this.mapSize / 2,
        width: area.mapSize,
        height: area.mapSize,
        fill: area.id === this.workingArea.id ? 'green' : 'blue',
        name: area.name
      }));
    },
    ...mapGetters({
      areas: 'builder/areas',
      isAreaSelected: 'builder/isAreaSelected',
      isAreaUnderConstruction: 'builder/isAreaUnderConstruction',
      isMapUnderConstruction: 'builder/isMapUnderConstruction',
      workingArea: 'builder/workingArea',
      workingMap: 'builder/workingMap'
    })
  }
};
</script>

<style></style>
:key="square.key" :x="square.x" :y="square.y" :width="square.width"
:height="square.height" :fill="square.fill"
