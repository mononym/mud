<script language="typescript">
  import { goto, params } from "@roxi/routify";
  import { Circle2 } from "svelte-loading-spinners";
  import { CharactersStore } from "../../../stores/characters";
  const { characters } = CharactersStore;
  import { MudClientStore } from "../../../stores/mudClient";
  const {
    characterInitialized,
    characterInitializing,
    selectedCharacter,
    wsToken,
  } = MudClientStore;

  import { onMount } from "svelte";
  import { Socket } from "phoenix";
  import StoryWindow from "./_components/StoryWindow.svelte";
  import LayoutItemWrapper from "./_components/LayoutItemWrapper.svelte";

  let socket;
  let channel;

  onMount(async () => {
    const character = $characters.filter(
      (character) => character.id == $params.id
    )[0];

    // Happens if loaded up into this page rather than into dashboard first
    if (character == undefined) {
      $goto("../dashboard");
      return
    }

    await MudClientStore.initializeCharacter(character);

    socket = new Socket("wss://localhost:4000/socket", {
      params: { character_id: character.id, token: $wsToken },
    });

    socket.connect();
    channel = socket.channel(`character:${character.id}`);
    channel.on("output:story", function (msg) {
      console.log("Got message for story", msg);
    });

    channel.join();
  });

  //
  // UI stuff
  //

  let canvas;
  let element;
  const mouse = {
    x: 0,
    y: 0,
    startX: 0,
    startY: 0,
  };

  function mouseDown(e) {
    if (e.target.id === "container") {
      const rects = [...canvas.querySelectorAll(".selection")];

      if (rects) {
        for (const rect of rects) {
          canvas.removeChild(rect);
        }
      }

      mouse.startX = mouse.x;
      mouse.startY = mouse.y;
      element = document.createElement("div");
      element.className = "selection";
      element.style.border = "1px dashed black";
      element.style.position = "absolute";
      element.style.left = mouse.x + "px";
      element.style.top = mouse.y + "px";
      canvas.appendChild(element);
    }
  }

  function setMousePosition(e) {
    const ev = e || window.event;

    if (ev.pageX) {
      mouse.x = ev.pageX + window.pageXOffset;
      mouse.y = ev.pageY + window.pageYOffset;
    } else if (ev.clientX) {
      mouse.x = ev.clientX + document.body.scrollLeft;
      mouse.y = ev.clientY + document.body.scrollTop;
    }
  }

  function mouseMove(e) {
    setMousePosition(e);
    if (element) {
      element.style.width = Math.abs(mouse.x - mouse.startX) + "px";
      element.style.height = Math.abs(mouse.y - mouse.startY) + "px";
      element.style.left =
        mouse.x - mouse.startX < 0 ? mouse.x + "px" : mouse.startX + "px";
      element.style.top =
        mouse.y - mouse.startY < 0 ? mouse.y + "px" : mouse.startY + "px";
    }
  }

  function mouseUp(e) {
    element = null;

    const rect = canvas.querySelector(".selection");
    const boxes = [...canvas.querySelectorAll(".item")];

    if (rect) {
      const inBounds = [];

      for (const box of boxes) {
        if (isInBounds(rect, box)) {
          inBounds.push(box);
        } else {
          box.style.boxShadow = "none";
          box.classList.remove("selected");
        }
      }

      if (inBounds.length >= 2) {
        for (const box of inBounds) {
          box.style.boxShadow = "0 0 3pt 3pt hsl(141, 53%, 53%)";
          box.classList.add("selected");
        }
      }

      if (rect) canvas.removeChild(canvas.querySelector(".selection"));
    }
  }

  function isInBounds(obj1, obj2) {
    const a = obj1.getBoundingClientRect();
    const b = obj2.getBoundingClientRect();

    return (
      a.x < b.x + b.width &&
      a.x + a.width > b.x &&
      a.y < b.y + b.height &&
      a.y + a.height > b.y
    );
  }
</script>

<style>
  #container {
    background: lightgray;
    height: 100vh;
  }
  .item {
    display: flex;
    justify-content: center;
    align-items: center;
    position: absolute;
    background: lightblue;
    cursor: pointer;
    border-radius: 5px;
    padding: 10px;
    touch-action: none;
    transition: box-shadow 0.5s;
    overflow: hidden;
  }
  .item:hover {
    -webkit-box-shadow: 0px 10px 15px 0px rgba(0, 0, 0, 0.1);
    -moz-box-shadow: 0px 10px 15px 0px rgba(0, 0, 0, 0.1);
    box-shadow: 0px 10px 15px 0px rgba(0, 0, 0, 0.1);
  }
  .item:nth-child(1) {
    top: 100px;
    left: 100px;
  }
  .item:nth-child(2) {
    top: 30px;
    left: 300px;
  }
  .item:nth-child(3) {
    top: 400px;
    left: 320px;
  }
</style>

<div class="h-full w-full flex flex-col overflow-hidden justify-center">
  {#if !$characterInitialized || $characterInitializing}
    <div class="flex-1 flex flex-col justify-center items-center">
      <Circle2 />
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
        Initializing
        {$selectedCharacter.name == '' ? 'Character' : $selectedCharacter.name}
      </h2>
    </div>
  {:else if $characterInitialized}
    <div
      bind:this={canvas}
      id="container"
      class="w-full"
      on:mouseup={mouseUp}
      on:mousedown={mouseDown}
      on:mousemove={mouseMove}>
      <div class="item" data-x="0" data-y="0">
        <div class="commandlineWrapper h-full w-full flex">
          <button
            class="hover:bg-gray-400 hover:text-white text-gray-200 bg-transparent border border-solid border-gray-400 active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
            type="button"
            style="transition: all .15s ease">
            <i class="fas fa-comment-alt" />
          </button>
          <textarea class="flex-grow" style="resize:none" />
        </div>
      </div>
      <LayoutItemWrapper id="storyWindowWrapper" height={600} width={800}>
        <StoryWindow />
      </LayoutItemWrapper>
    </div>
  {/if}
</div>
