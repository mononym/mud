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
        <line
          v-for="stroke in strokes"
          :key="stroke.id"
          :x1="stroke.x1"
          :y1="stroke.y1"
          :x2="stroke.x2"
          :y2="stroke.y2"
          :stroke="stroke.stroke"
          stroke-dasharray="5,5"
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
        <text
          v-for="label in labels"
          :key="label.id"
          :fill="label.fill"
          :font-size="label.size + 'px'"
          :font-weight="label.weight"
          :font-style="label.style"
          :font-family="label.family"
          :inline-size="label.inlineSize"
          text-anchor="middle"
          :transform="
            'translate(' +
              label.x +
              ',' +
              label.y +
              ') rotate(' +
              label.rotate +
              ')'
          "
        >
          {{ label.text }}
        </text>
      </svg>
    </q-card-section>

    <!-- <rect x="50" y="20" width="150" height="150"
  style="fill:blue;stroke:pink;stroke-width:5;fill-opacity:0.1;stroke-opacity:0.9" /> -->

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
import { LabelInterface, MapInterface } from 'src/store/map/state';
import { mapGetters } from 'vuex';
import { Prop } from 'vue/types/options';
import { PropOptions } from 'vue';

function buildSquare(
  area: AreaInterface,
  gridSize: number,
  viewSize: number,
  fill: string,
  x: number,
  y: number,
  size: number
): Record<string, unknown> {
  console.log('buildsquare');
  return {
    key: area.id,
    x: x * gridSize + viewSize / 2 - size / 2,
    y: -y * gridSize + viewSize / 2 - size / 2,
    width: size,
    height: size,
    fill: fill,
    name: area.name,
    area: area
  };
}

function buildText(
  label: LabelInterface,
  gridSize: number,
  viewSize: number
): Record<string, unknown> {
  return {
    key: label.id,
    x: label.x * gridSize + viewSize / 2,
    y: -label.y * gridSize + viewSize / 2,
    text: label.text,
    fill: label.color,
    size: label.size,
    weight: label.weight,
    style: label.style,
    rotate: label.rotation,
    family: label.family,
    inlineSize: label.inlineSize
  };
}

export default {
  name: 'BuilderMap',
  props: {
    showmapareapreview: {
      type: Boolean,
      default: false
    },
    readonly: {
      type: Boolean,
      default: false
    },
    focusarea: {
      type: String,
      required: false,
      default: ''
    },
    maplinkpreviewarea: {
      type: String,
      required: true
    },
    mapareapreview: {
      type: Object as Prop<AreaInterface>,
      required: true
    },
    maplabelpreview: {
      type: Object as Prop<LabelInterface>,
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
          this.viewSize / 2
        );
      } else {
        return this.viewSize / 2;
      }
    },
    yCenterPoint: function(): number {
      if (this.areaIndex[this.focusarea] != undefined) {
        return (
          -this.areas[this.areaIndex[this.focusarea]].mapY * this.gridSize +
          this.viewSize / 2
        );
      } else {
        return this.viewSize / 2;
      }
    },
    aspectRatioMultiplier: function(): number {
      return this.aspectRatio.y / this.aspectRatio.x;
    },
    gridSize: function(): number {
      return this.map.gridSize;
    },
    viewBoxXSize: function(): number {
      return this.viewSize * this.zoomMultiplier;
    },
    viewBoxYSize: function(): number {
      return this.viewSize * this.aspectRatioMultiplier * this.zoomMultiplier;
    },
    viewSize: function(): number {
      return this.map.viewSize;
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
      const viewSize = this.viewSize;
      const areas = this.areas;
      const self = this;

      const links = this.links
        .filter(
          link =>
            areas[areaIndex[link.toId]] != undefined &&
            areas[areaIndex[link.fromId]] != undefined
        )
        .map(function(link: LinkInterface) {
          const toArea = areas[areaIndex[link.toId]];
          const fromArea = areas[areaIndex[link.fromId]];
          let fromMapX = fromArea.mapX;
          let fromMapY = fromArea.mapY;
          let toMapX = toArea.mapX;
          let toMapY = toArea.mapY;

          // Handle links to external areas
          // External areas will be included and must use their local position which is specified in the link
          if (toArea.mapId != fromArea.mapId) {
            const link = self.links.find(link => link.toId == toArea.id);

            console.log('different maps');

            if (toArea.mapId != self.map.id) {
              toMapX = link.localToX;
              toMapY = link.localToY;
            } else {
              fromMapX = link.localFromX;
              fromMapY = link.localFromY;
            }
          }

          return {
            id: link.id,
            x1: fromMapX * gridSize + viewSize / 2,
            y1: -fromMapY * gridSize + viewSize / 2,
            x2: toMapX * gridSize + viewSize / 2,
            y2: -toMapY * gridSize + viewSize / 2,
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
        });

      return links;
    },
    squares: function(): Record<string, unknown>[] {
      // To take care of the case of displaying incorrect lines/squares configuration while map is loading
      if (this.map.id == '') {
        return [];
      }

      const gridSize = this.gridSize;
      const viewSize = this.viewSize;
      const self = this;
      const areas = this.areas;

      const squares = areas.map(function(area: AreaInterface) {
        let mapX = area.mapX;
        let mapY = area.mapY;
        let size = area.mapSize;
        // Handle links to external areas
        // External areas will be included and must use their local position which is specified in the link
        if (area.mapId != self.map.id) {
          const link = self.links.find(link => link.toId == area.id);
          mapX = link.localToX;
          mapY = link.localToY;
          size = link.localToSize;
        }

        const color =
          self.maplinkpreviewarea == area.id ||
          self.mapareapreview.id == area.id
            ? 'orange'
            : self.mapareahighlights[area.id] || 'blue';

        return buildSquare(area, gridSize, viewSize, color, mapX, mapY, size);
      });

      if (this.showmapareapreview) {
        squares.push(
          buildSquare(
            this.mapareapreview,
            gridSize,
            viewSize,
            'orange',
            this.mapareapreview.mapX,
            this.mapareapreview.mapY,
            this.mapareapreview.mapSize
          )
        );
      }

      return squares;
    },
    strokes: function(): Record<string, unknown>[] {
      // To take care of the case of displaying incorrect lines/squares configuration while map is loading
      if (this.focusarea == '' && this.maplinkpreviewarea == '') {
        return [];
      }

      const toArea = this.areas[this.areaIndex[this.maplinkpreviewarea]];
      const fromArea = this.areas[this.areaIndex[this.focusarea]];
      const gridSize = this.gridSize;
      const viewSize = this.viewSize;
      const self = this;

      let mapX = toArea.mapX;
      let mapY = toArea.mapY;
      // Handle links to external areas
      // External areas will be included and must use their local position which is specified in the link
      if (toArea.mapId != fromArea.mapId) {
        const link = self.links.find(link => link.toId == area.id);
        mapX = link.localToX;
        mapY = link.localToY;
      }

      return [
        {
          id: 'preview',
          x1: fromArea.mapX * gridSize + viewSize / 2,
          y1: -fromArea.mapY * gridSize + viewSize / 2,
          x2: mapX * gridSize + viewSize / 2,
          y2: -mapY * gridSize + viewSize / 2,
          stroke: 'orange'
        }
      ];
    },
    labels: function(): Record<string, unknown>[] {
      const gridSize = this.gridSize;
      const viewSize = this.viewSize;
      let previewLabelPreviewedAlready = false;
      const self = this;
      const labels = this.map.labels.map(function(label: LabelInterface) {
        if (label.id == self.maplabelpreview.id) {
          previewLabelPreviewedAlready = true;
          return buildText(self.maplabelpreview, gridSize, viewSize);
        } else {
          return buildText(label, gridSize, viewSize);
        }
      });

      if (!previewLabelPreviewedAlready && this.maplabelpreview.id != '') {
        labels.push(buildText(self.maplabelpreview, gridSize, viewSize));
      }

      return labels;
    },
    ...mapGetters({
      instanceBeingBuilt: 'instances/instanceBeingBuilt'
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
