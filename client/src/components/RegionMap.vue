<template>
  <div class="fit column">
    <div class="text-h6 text-center col-auto">{{ regionName }}</div>
    
    <q-separator />
    
    <div class="col">
      <svg class="" style="display:block" :viewBox="viewbox" preserveAspectRatio="xMidYMid slice">
        <line v-for="line in lines" :x1="line.x1" :y1="line.y1" :x2="line.x2" :y2="line.y2" stroke="black"/>
        <rect v-for="square in squares" :x="square.x" :y="square.y" :width="square.size" :height="square.size" :fill="square.color"><title>{{ square.name }}</title></rect>
      </svg>
    </div>
    
    <q-separator />

    <q-btn-group flat spread>
      <q-btn flat class="action-button" icon="fas fa-minus" />
      <q-btn flat class="action-button" icon="fas fa-plus" />
    </q-btn-group>
  </div>
</template>

<script>

export default {
  name: 'WorldMap',
  data() {
    return {
      viewBoxX: 0,
      viewBoxY: 0,
      viewBoxSize: 1000,
      regionName: 'Placeholder Map Name',
      lines: [{x1: 0, y1: 0, x2: 0, y2: 0}],
      squares: [{x: 0, y: 0, size: 20, color: 'blue', name: 'Placeholder'},{x: 10, y: 1000, size: 20, color: 'red', name: 'Foo'}],
      mapSize: 500,
    };
  },
  computed: {
    viewbox: function() {
      return this.viewBoxX + ' ' + this.viewBoxY + ' ' + this.viewBoxSize + ' ' + this.viewBoxSize;
    }
  },
  mounted() {
  }
};
</script>

<style>
</style>
