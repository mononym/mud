<script>
    import tippy from "tippy.js";
    import "tippy.js/dist/tippy.css";
    import { onMount, getContext } from "svelte";
    import { key } from "../utils/menu";

    export let isDisabled = false;
    export let text = "";
    export let disabledTooltip = "";
    export let enabledTooltip = "";

    $: currentTooltip = isDisabled ? disabledTooltip : enabledTooltip;

    import { createEventDispatcher } from "svelte";
    const dispatch = createEventDispatcher();

    const { dispatchClick } = getContext(key);

    const handleClick = (e) => {
        if (isDisabled) return;

        dispatch("click");
        dispatchClick();
    };

    onMount(() => {
        if (text != "") {
            tippy(`.MenuOption${text}`, {
                content: currentTooltip,
            });
        }
    });
</script>

<style>
    div {
        padding: 4px 15px;
        cursor: default;
        font-size: 14px;
        display: flex;
        align-items: center;
        grid-gap: 5px;
    }
    div:hover {
        background: #0002;
    }
    div.disabled {
        color: #0006;
    }
    div.disabled:hover {
        background: white;
    }
</style>

<div
    class={`MenuOption${text}`}
    class:disabled={isDisabled}
    on:click={handleClick}
    data-tooltip={isDisabled ? disabledTooltip : enabledTooltip}>
    {#if text}
        {text}
    {:else}
        <slot />
    {/if}
</div>
