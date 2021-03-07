<script>
    import { onDestroy, onMount } from "svelte";
    import Menu from "../Menu.svelte";
    import MenuOption from "../MenuOption.svelte";
    import MenuDivider from "../MenuDivider.svelte";

    let pos = { x: 0, y: 0 };
    let showMenu = false;
    export let target;

    $: target, setupHotkeyWatcher();

    function closeMenu() {
        showMenu = false;
    }

    onMount(() => {
        setupHotkeyWatcher();
    });

    onDestroy(() => {
        teardownHotkeyWatcher();
    });

    function setupHotkeyWatcher() {
        if (target == undefined) return;
        target.addEventListener("contextmenu", showInventoryRightClickMenu);
    }

    function teardownHotkeyWatcher() {
        if (target == undefined) return;
        target.el.removeEventListener(
            "contextmenu",
            showInventoryRightClickMenu
        );
    }

    async function showInventoryRightClickMenu(event) {
        event.stopPropagation();

        if (showMenu) {
            showMenu = false;
            await new Promise((res) => setTimeout(res, 100));
        }

        console.log(event);

        pos = { x: event.offsetX, y: event.offsetY };
        showMenu = true;
    }
</script>

{#if showMenu}
    <Menu {...pos} on:click={closeMenu} on:clickoutside={closeMenu}>
        <MenuOption on:click={console.log} text="Do nothing" />
        <MenuOption on:click={console.log} text="Do nothing, but twice" />
        <MenuDivider />
        <MenuOption
            isDisabled={true}
            on:click={console.log}
            text="Whoops, disabled!" />
        <MenuOption on:click={console.log}>
            <span>Look! An icon!</span>
        </MenuOption>
    </Menu>
{/if}
