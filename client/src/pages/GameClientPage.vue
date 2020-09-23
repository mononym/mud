<template>
  <q-page class="col no-scroll game-client-page">
    <grid-layout
      :layout.sync="layout"
      :col-num="numColumns"
      :max-rows="maxNumRows"
      :row-height="rowHeight"
      :is-draggable="true"
      :is-resizable="true"
      :is-mirrored="false"
      :vertical-compact="true"
      :margin="marginString"
      :use-css-transforms="true"
      :parent="true"
      :lock-aspect-ratio="true"
      id="gameClientLayout"
      class="fit"
    >
      <grid-item
        v-for="item in layout"
        :x="item.x"
        :y="item.y"
        :w="item.w"
        :h="item.h"
        :i="item.i"
        :key="item.i"
        :static="false"
        style="background-color: blue"
        class="game-client-window"
      >
        {{ item.i }}
      </grid-item>
    </grid-layout>
  </q-page>
</template>

<style lang="sass">
.vue-grid-item {background-color: blue}
main.q-page.game-client-page {max-height: calc(100vh - 50px)}
.game-client-window {max-height: calc(100% - 20px)}
</style>

<script lang="ts">
import VueGridLayout from 'vue-grid-layout';
import { Socket, SocketType } from 'phoenix';

interface LayoutInterface {
  x: number;
  y: number;
  w: number;
  h: number;
  i: string;
}

interface WindowInterface {
  key: string;
  title: string;
  layout: LayoutInterface;
}

export default {
  name: 'LandingPage',
  components: { VueGridLayout },
  data(): {
    marginX: number;
    marginY: number;
    numColumns: number;
    maxNumRows: number;
    rowHeight: number;
    windows: WindowInterface[];
    phoenixJsUrl: string;
    connection: Record<string, any>;
  } {
    return {
      marginX: 10,
      marginY: 10,
      numColumns: 12,
      maxNumRows: 12,
      rowHeight: 150,
      windows: [
        {
          key: 'story',
          title: 'Story',
          layout: { x: 0, y: 0, w: 12, h: 12, i: 'story' }
        }
      ],
      phoenixJsUrl: 'phoenix.js',
      connection: {}
    };
  },
  computed: {
    characterSlug: function(): string {
      return this.$route.params.slug;
    },
    layout: function(): LayoutInterface[] {
      return this.windows.map(map => map.layout);
    },
    marginString: function(): number[] {
      return [this.marginX, this.marginY];
    }
    // socket: function(): SocketType {
    //   return new Socket('ws://localhost:4000/socket', {
    //     params: { userToken: 'foo' }
    //   });
    // },
    // channel: function(): SocketType {
    //   return this.socket.channel('character:' + this.characterSlug);
    // }
  },
  mounted() {
    this.calculateRowHeight();

    this.connection.socket = new Socket('ws://localhost:4000/socket', {
      params: { token: 'foo' }
    });
    this.connection.socket.connect();

    // console.log(this.connection);

    // console.log('character:' + this.characterSlug);

    this.connection.channel = this.connection.socket.channel(
      'character:' + this.characterSlug
    );
    this.connection.channel.join();

    // console.log(this.connection);

    // this.connection.channel.push('ping');
    this.connection.channel.on('output:story', function(
      msg: Record<string, any>
    ) {
      console.log('Got message for story', msg);
    });

    // let channel = socket.channel('room:123', { token: roomToken });
    // this.connection.channel.on('pong', function(msg: Record<string, any>) {
    //   console.log('Got message', msg.text);
    //   alert(msg.text);
    // });
    // $input.onEnter(e => {
    //   channel
    //     .push('new_msg', { body: e.target.val }, 10000)
    //     .receive('ok', msg => console.log('created message', msg))
    //     .receive('error', reasons => console.log('create failed', reasons))
    //     .receive('timeout', () => console.log('Networking issue...'));
    // });
  },
  methods: {
    calculateRowHeight() {
      console.log('here');
      const el = document.getElementById('gameClientLayout');
      this.rowHeight =
        el !== null ? Math.floor(el.clientHeight / this.maxNumRows) : 0;
    },
    connectChannel() {
      // this.channel = this.socket.channel('character:' + this.characterSlug);
      // this.channel.on('pong', function(msg: string) {
      //   console.log('Got message', msg);
      // });
      // this.$input.onEnter(e => {
      //   channel
      //     .push('new_msg', { body: e.target.val }, 10000)
      //     .receive('ok', msg => console.log('created message', msg))
      //     .receive('error', reasons => console.log('create failed', reasons))
      //     .receive('timeout', () => console.log('Networking issue...'));
      // });
    }
  }
};
</script>
