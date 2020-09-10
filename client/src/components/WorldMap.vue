<template>
  <q-card flat bordered class="my-card bg-primary">
    <q-card-section>
      <div class="text-h6 text-center">{{ regionName }}</div>
    </q-card-section>
    
    <q-separator />
    
    <q-card-section class="column justify-center">
      <svg :height="svgParentHeight" :width="svgParentWidth" :viewBox="viewbox" preserveAspectRatio="xMidYMid slice">
        <line v-for="line in lines" :x1="line.x1" :y1="line.y1" :x2="line.x2" :y2="line.y2" stroke="white"/>
        <rect v-for="square in squares" :x="square.x" :y="square.y" :width="square.size" :height="square.size" :fill="square.color"><title>{{ square.name }}</title></rect>
      </svg>
    </q-card-section>

    <q-card-actions align="around" class="action-container">
      <q-btn flat class="action-button"><q-icon name="fas fa-minus" /></q-btn>
      <q-btn flat class="action-button"><q-icon name="fas fa-plus" /></q-btn>
    </q-card-actions>
  </q-card>
</template>

<script>

export default {
  name: 'WorldMap',
  data() {
    return {
      viewBoxX: 0,
      viewBoxY: 0,
      viewBoxSize: 500,
      regionName: 'Placeholder Region Name',
      lines: [{x1: 0, y1: 10, x2: 50, y2: 10}],
      squares: [{x: 0, y: 0, size: 20, color: 'blue', name: 'Placeholder'}],
      mapSize: 500,
      parentHeight: 0
    };
  },
  computed: {
    viewbox: function() {
      return this.viewBoxX + ' ' + this.viewBoxY + ' ' + this.viewBoxSize + ' ' + this.viewBoxSize;
    },
    svgParentHeight: function() {
      // console.log(this.$parent)
      // const parent = this.$parent
      // if (parent) {
      // console.log('paretn')
      //   console.log(parent)
      //   console.log(parent.$el.clientHeight)
      // return this.$parent.$el.clientHeight + 'px';
      // } else {
        return '400px'
      // }
    },
    svgParentWidth: function() {
      // console.log(this.$parent)
      // if (this.$parent.$el) {
      //   console.log(this.$parent.$el)
      //   console.log(this.$parent.$el.clientWidth)
      // return this.$parent.$el.clientWidth + 'px';
      // } else {
        return '400px'
      // }
    }
  },
  mounted() {
  }
};
</script>

<style>
</style>
