<script>
  import { createEventDispatcher } from "svelte";

  const dispatch = createEventDispatcher();

  export let viewBox = "0 0 0 0";
  export let preserveAspectRatio = "xMidYMid meet";
  export let shapes = [];

  function selectArea(area) {
    dispatch("selectArea", area);
  }
</script>

<svg
  class="h-full w-full"
  transition="1s ease-in-out"
  {viewBox}
  {preserveAspectRatio}>
  {#each shapes as shape}
    {#if shape.type == 'path'}
      {#if shape.hasMarker}
        <defs>
          <marker
            id="markerArrow-{shape.id}"
            markerWidth={shape.lineWidth * 2}
            markerHeight={shape.lineWidth * 2}
            refX={shape.lineWidth * 2 + shape.markerOffset}
            refY={shape.lineWidth}
            orient="auto">
            <!-- <path d="M2,2 L2,13 L8,7 L2,2" style="fill: {shape.markerColor};" /> -->
            <!-- <polygon points="10 0, 10 7, 0 3.5" fill={shape.markerColor} /> -->
            <polygon
              points="0 0, {shape.lineWidth * 2} {shape.lineWidth}, 0 {shape.lineWidth * 2}"
              fill={shape.markerColor} />
          </marker>
        </defs>
      {/if}
      <path
        id={shape.id}
        d="M {shape.x1} {shape.y1} L {shape.x2} {shape.y2}"
        stroke={shape.lineColor}
        stroke-dasharray={shape.lineDash}
        stroke-width={shape.lineWidth}
        marker-end={shape.hasMarker ? `url(#markerArrow-${shape.id})` : ''} />
      {#if shape.label != undefined && shape.label != ''}
        <text
          fill={shape.labelColor}
          text-anchor="middle"
          x={shape.labelX}
          y={shape.labelY}
          dominant-baseline="central"
          font-size={shape.labelFontSize}
          transform={shape.labelTransform}>
          {#each shape.label as label, i}
            <tspan
              x={shape.labelX}
              y={shape.labelY}
              dy="{i * shape.labelFontSize}px">
              {label}
            </tspan>
          {/each}
        </text>
      {/if}
    {:else if shape.type == 'rect'}
      <rect
        on:click={selectArea(shape.area)}
        x={shape.x}
        y={shape.y}
        width={shape.width}
        height={shape.height}
        rx={shape.corners}
        fill={shape.fill}
        stroke-width={shape.borderWidth}
        stroke={shape.borderColor}
        class={shape.cls}
        id={shape.area.id}>
        <title>{shape.name}</title>
      </rect>
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
