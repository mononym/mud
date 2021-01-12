<script>
    import Menu from "../Menu.svelte";
    import MenuOption from "../MenuOption.svelte";
    import MenuDivider from "../MenuDivider.svelte";
    import { getContext } from "svelte";
    import { key } from "./state";

    const state = getContext(key);
    const { leftHandHasItem, rightHandHasItem } = state;

    export let showMenu = false;
    export let item;
    export let pos = { x: 0, y: 0 };

    function closeMenu() {
        showMenu = false;
    }
</script>

{#if showMenu}
    <Menu {...pos} on:click={closeMenu} on:clickoutside={closeMenu}>
        {#if item.wearableIsWorn}
            <MenuOption
                isDisabled={$leftHandHasItem && $rightHandHasItem}
                on:click={console.log}
                enabledTooltip="Take off the worn item"
                disabledTooltip="Cannot remove with full hands"
                text="remove" />
        {/if}
        {#if item.holdableIsHeld && item.isWearable}
            <MenuOption on:click={console.log} text="wear" />
        {/if}
        <MenuDivider />
        {#if item.containerId != null && item.containerId != undefined && item.containerId != '' && (!$leftHandHasItem || !$rightHandHasItem)}
            <MenuOption
                on:click={console.log}
                enabledTooltip="Remove item from container and hold it"
                disabledTooltip="Cannot get with full hands"
                text="get" />
            <MenuOption
                on:click={console.log}
                enabledTooltip="Remove item from container and drop it on the ground"
                disabledTooltip="Cannot discard with full hands"
                text="discard" />
        {/if}
    </Menu>
{/if}
