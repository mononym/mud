<script>
  import { createEventDispatcher } from "svelte";
  import interact from "interactjs";

  const dispatch = createEventDispatcher();

  export let viewBox = "0 0 0 0";
  export let preserveAspectRatio = "xMidYMid meet";
  export let shapes = [];
  export let gridSize = 10;
  export let gridStrokeColor = "gray";
  export let gridSmallStrokeWidth = "0.5";
  export let gridLargeStrokeWidth = "1";
  export let showGrid = false;

  let mapX;
  let mapY;
  let mapHeight;
  let mapWidth;

  interact(".draggableSvg").draggable({
    inertia: true,
    listeners: {
      start(event) {
        console.log("start");
        console.log(event);
        console.log(event.type, event.target);
        mapX = event.target.viewBox.baseVal.x;
        mapY = event.target.viewBox.baseVal.y;
        mapHeight = event.target.viewBox.baseVal.height;
        mapWidth = event.target.viewBox.baseVal.width;
        dispatch("startDragMap");
      },
      move(event) {
        console.log("move");
        console.log(event.target.viewBox);
        // const newx = (mapX -= event.dx * zoomMultiplier); // multiply delta by zoom level?
        // const newy = (mapY -= event.dy * zoomMultiplier);
        // console.log(newx);
        // console.log(newy);
        // console.log(mapHeight);
        // console.log(mapWidth);
        dispatch("dragMap", { x: -event.dx, y: -event.dy });
      },
    },
  });

  function selectArea(area) {
    dispatch("selectArea", area);
  }
</script>

<svg class="draggableSvg h-full w-full" {viewBox} {preserveAspectRatio}>
  <defs>
    <pattern
      id="smallGrid"
      width={gridSize}
      height={gridSize}
      patternUnits="userSpaceOnUse"
    >
      <path
        d="M {gridSize} 0 L 0 0 0 {gridSize}"
        fill="none"
        stroke={gridStrokeColor}
        stroke-width={gridSmallStrokeWidth}
      />
    </pattern>
    <pattern
      id="grid"
      width={gridSize * 10}
      height={gridSize * 10}
      patternUnits="userSpaceOnUse"
      patternTransform="translate({gridSize * 5},{gridSize * 5})"
    >
      <rect
        width={gridSize * 10}
        height={gridSize * 10}
        fill="url(#smallGrid)"
      />
      <path
        d="M {gridSize * 10} 0 L 0 0 0 {gridSize * 10}"
        fill="none"
        stroke={gridStrokeColor}
        stroke-width={gridLargeStrokeWidth}
      />
    </pattern>
  </defs>

  {#if showGrid}
    <rect
      x="-500000"
      y="-500000"
      width="1000000px"
      height="1000000px"
      fill="url(#grid)"
    />
  {/if}

  {#each shapes as shape}
    {#if shape.type == "path"}
      {#if shape.hasMarker}
        <defs>
          <marker
            id="markerArrow-{shape.id}"
            markerWidth={shape.lineWidth * 2}
            markerHeight={shape.lineWidth * 2}
            refX={shape.lineWidth * 2 + shape.markerOffset}
            refY={shape.lineWidth}
            orient="auto"
          >
            <polygon
              points="0 0, {shape.lineWidth *
                2} {shape.lineWidth}, 0 {shape.lineWidth * 2}"
              fill={shape.markerColor}
            />
          </marker>
        </defs>
      {/if}
      <path
        id={shape.id}
        d="M {shape.x1} {shape.y1} L {shape.x2} {shape.y2}"
        stroke={shape.lineColor}
        stroke-dasharray={shape.lineDash}
        stroke-width={shape.lineWidth}
        marker-end={shape.hasMarker ? `url(#markerArrow-${shape.id})` : ""}
      />
      {#if shape.label != undefined && shape.label != ""}
        <text
          fill={shape.labelColor}
          text-anchor="middle"
          x={shape.labelX}
          y={shape.labelY}
          dominant-baseline="central"
          font-family={shape.labelFontFamily || "fantasy, sans-sarif"}
          font-weight={shape.labelFontWeight || "normal"}
          font-style={shape.labelFontFamily || "normal"}
          font-size={shape.labelFontSize}
          transform={shape.labelTransform}
        >
          {#each shape.label as label, i}
            <tspan
              x={shape.labelX}
              y={shape.labelY}
              dy="{i * shape.labelFontSize}px"
            >
              {label}
            </tspan>
          {/each}
        </text>
      {/if}
    {:else if shape.type == "rect"}
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
        id={shape.area.id}
      >
        <title>{shape.name}</title>
      </rect>
    {:else if shape.type == "text"}
      <text
        fill={shape.labelColor}
        text-anchor="middle"
        x={shape.labelX}
        y={shape.labelY}
        dominant-baseline="central"
        font-size={shape.labelFontSize}
        font-family={shape.labelFontFamily || "fantasy, sans-sarif"}
        font-weight={shape.labelFontWeight || "normal"}
        font-style={shape.labelFontFamily || "normal"}
        transform={shape.labelTransform}
      >
        {#each shape.label as label, i}
          <tspan
            x={shape.labelX}
            y={shape.labelY}
            dy="{i * shape.labelFontSize}px"
          >
            {label}
          </tspan>
        {/each}
      </text>
    {/if}
  {/each}
</svg>
