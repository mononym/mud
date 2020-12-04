<script>
  import { createEventDispatcher } from "svelte";

  const dispatch = createEventDispatcher();

  export let viewBox = "0 0 0 0";
  export let preserveAspectRatio = "xMidYMid meet";
  export let shapes = [];

  let shapes2 = [
    {
      type: "rect",
      x: 2490,
      y: 2490,
      width: 20,
      height: 20,
      fill: "blue",
      class: "cursor-pointer",
    },
  ];

  console.log(viewBox);

  function selectArea(area) {
    console.log("selectArea");
    console.log(area);

    dispatch("selectArea", area);
  }
</script>

<svg class="h-full w-full" {viewBox} {preserveAspectRatio}>
  {#each shapes2 as shape}
    {#if shape.type == 'line'}
      <line
        x1={shape.x1}
        y1={shape.y1}
        x2={shape.x2}
        y2={shape.y2}
        stroke={shape.stroke}
        stroke-dasharray={shape.strokeDashArray}
        stroke-width={shape.strokeWidth}
        style={shape.style} />
    {:else if shape.type == 'rect'}
      <rect
        on:click={selectArea(shape.area)}
        x={shape.x}
        y={shape.y}
        width={shape.width}
        height={shape.height}
        fill={shape.fill}
        class={shape.class} />
    {:else if shape.type == 'text'}
      <text
        fill={shape.fill}
        font-size={shape.fontSize}
        font-weight={shape.fontWeight}
        font-style={shape.fontStyle}
        font-family={shape.fontFamily}
        inline-size={shape.inlineSize}
        text-anchor={shape.textAnchor}
        transform={'translate(' + shape.x + ',' + shape.y + ') rotate(' + shape.rotate + ')'}>
        {shape.text}
      </text>
    {/if}
  {/each}
</svg>
