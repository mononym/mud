<template>
  <div class="fit column">
    <div class="text-h6 text-center col-auto">{{ selectedMap.name }}</div>
    
    <q-separator />
    
    <div class="col">
      <svg width="100%" height="100%" class="" :viewBox="viewbox" preserveAspectRatio="xMidYMid slice">
        <line v-for="line in lines" :key="line.id" :x1="line.x1" :y1="line.y1" :x2="line.x2" :y2="line.y2" stroke="black"/>
        <rect v-for="square in squares" :key="square.id" :x="square.x" :y="square.y" :width="square.size" :height="square.size" :fill="square.color"><title>{{ square.name }}</title></rect>
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
import { mapGetters } from 'vuex'

export default {
  name: 'WorldMap',
  props: ['id'],
  created() {
    // look at values to see if there is an id for the map
    // if there is an id check the database by using a getter to see if the data needs to be loaded
    // if data needs to be loaded make a call to server to fetch the data and have it set the map data once loaded
    // If there is no id the values can be left blank and nothing needs to be done
    console.log('map id')
    console.log(this.id)
  },
  data() {
    return {
      viewBoxX: 0,
      viewBoxY: 0,
      viewBoxSize: 1000,
      regionName: 'Placeholder Map Name',
      lines: [{id: 1, x1: 500, y1: 500, x2: 520, y2: 500}],
      squares: [{id: 2, x: 500, y: 500, size: 20, color: 'blue', name: 'Placeholder'},{id: 3, x: 530, y: 530, size: 20, color: 'red', name: 'Foo'}],
      mapSize: 500,
      map: null
    };
  },
  computed: {
    viewbox: function() {
      return this.viewBoxX + ' ' + this.viewBoxY + ' ' + this.viewBoxSize + ' ' + this.viewBoxSize;
    },
    // selectedMapName: function() {
    //   if (this.selectedMap !== undefined) {
    //     return this.selectedMap.name
    //   } else {
    //     return ''
    //   }
    // },
    ...mapGetters({
      selectedMap: 'builder/selectedMap'
    })
  },
  watch: {
    id(value, previousValue) {
      this.$store.dispatch('maps/fetchMap', value).then((map) => {this.map = map})
    }
  },
  mounted() {
  }
};
</script>

<style>
</style>
