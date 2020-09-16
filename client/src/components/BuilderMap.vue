<template>
  <div class="fit column">
    <div class="text-h6 text-center col-auto">{{ mapName }}</div>

    <q-separator />

    <div class="col">
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
    </div>

    <q-separator />

    <q-btn-group flat spread>
      <q-btn
        flat
        class="action-button"
        icon="fas fa-minus"
        @click="zoomOut"
        :disabled="zoomOutButtonDisabled"
      />
      <q-btn
        flat
        class="action-button"
        icon="fas fa-plus"
        @click="zoomIn"
        :disabled="zoomInButtonDisabled"
      />
    </q-btn-group>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';

export default {
  name: 'BuilderMap',
  props: ['id'],
  created() {
    // look at values to see if there is an id for the map
    // if there is an id check the database by using a getter to see if the data needs to be loaded
    // if data needs to be loaded make a call to server to fetch the data and have it set the map data once loaded
    // If there is no id the values can be left blank and nothing needs to be done
    console.log('map id');
    console.log(this.id);
  },
  data() {
    return {
      aspectRatio: { x: 16, y: 9 },
      lines: [{ id: 1, x1: 500, y1: 500, x2: 520, y2: 500 }],
      zoomMultipliers: [0.25, 0.5, 1, 2],
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
      return this.selectedMap.gridSize;
    },
    viewBoxXSize: function() {
      return this.mapSize * this.zoomMultiplier;
    },
    viewBoxYSize: function() {
      return this.mapSize * this.aspectRatioMultiplier * this.zoomMultiplier;
    },
    mapSize: function() {
      return this.selectedMap.mapSize;
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
      if (this.isMapUnderConstruction) {
        return this.mapUnderConstruction.name;
      } else {
        return this.selectedMap.name;
      }
    },
    workingArea: function() {
      if (this.isAreaUnderConstruction) {
        return this.areaUnderConstruction;
      } else {
        return this.selectedArea;
      }
    },
    squares: function() {
      return this.areas.map(area => ({
        key: area.id,
        x: area.mapX * this.gridSize + this.mapSize / 2,
        y: area.mapY * this.gridSize + this.mapSize / 2,
        width: area.mapSize,
        height: area.mapSize,
        fill: area.id === this.selectedArea.id ? 'green' : 'blue',
        name: area.name
      }));
    },
    ...mapGetters({
      areas: 'builder/areas',
      selectedMap: 'builder/selectedMap',
      selectedArea: 'builder/selectedArea',
      isAreaSelected: 'builder/isAreaSelected',
      isAreaUnderConstruction: 'builder/isAreaUnderConstruction',
      areaUnderConstruction: 'builder/areaUnderConstruction',
      isMapUnderConstruction: 'builder/isMapUnderConstruction',
      mapUnderConstruction: 'builder/mapUnderConstruction'
    })
  }
};
</script>

<style></style>
:key="square.key" :x="square.x" :y="square.y" :width="square.width"
:height="square.height" :fill="square.fill"
