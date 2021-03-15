<script language="typescript">
  import Confirm from "../Confirm.svelte";
  import TemplateList from "./templates/TemplateList.svelte";
  import TemplateDetails from "./templates/TemplateDetails.svelte";
  import TemplateEditor from "./templates/TemplateEditor.svelte";
  import { onMount } from "svelte";
  import { Circle2 } from "svelte-loading-spinners";
  import { WorldBuilderStore } from "./state";
  const {
    createNewTemplate,
    loadTemplates,
    loadingTemplates,
    templateview,
  } = WorldBuilderStore;

  let showDeletePrompt = false;
  let deleteCallback;
  let deleteMatchString = "";
  $: newTemplateButtonDisabled = $templateview != "details";

  onMount(async () => {
    loadTemplates();
  });
</script>

<div class="h-full w-full overflow-hidden flex flex-col">
  {#if $loadingTemplates}
    <div class="flex-1 flex flex-col justify-center items-center">
      <Circle2 />
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
        Loading Templates
      </h2>
    </div>
  {:else}
    <div class="h-full flex flex-1">
      <div class="h-full max-h-full flex-1">
        <div class="h-1/2 max-h-1/2 w-full">
          <p class="text-white text-center align-center">
            Templateping Window Preview
          </p>
        </div>
        <div class="h-1/2 max-h-1/2 w-full overflow-hidden flex flex-col">
          <TemplateList />

          <div class="flex-shrink flex">
            <button
              on:click={createNewTemplate}
              disabled={newTemplateButtonDisabled}
              type="button"
              class="flex-1 rounded-l-md {newTemplateButtonDisabled
                ? 'text-gray-600 bg-gray-500'
                : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {newTemplateButtonDisabled
                ? 'cursor-not-allowed'
                : 'cursor-pointer'}">New Template</button
            >
          </div>
        </div>
      </div>
      <div class="h-full max-h-full flex-1">
        {#if $templateview == "details"}
          <TemplateDetails />
        {:else if $templateview == "edit"}
          <TemplateEditor />
        {/if}
      </div>
      <Confirm
        show={showDeletePrompt}
        callback={deleteCallback}
        matchString={deleteMatchString}
      />
    </div>
  {/if}
</div>
