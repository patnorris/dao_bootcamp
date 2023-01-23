<script>
  import { daoActor, principal } from "../stores"
  import { get } from "svelte/store"
  import mot from "../assets/seagull_attack.png"
  import { Principal } from "@dfinity/principal";

  let choosenproposal = "Input your proposal"

  let summary

  let proposalTypes = [
		{ id: 1, text: `Update Webpage Text` },
		{ id: 2, text: `Create Community Space` },
		{ id: 3, text: `Update Community Space` }
	];

	let selected = "";

  let createProposalResult;

  async function create_proposal(proposalText) {
    let dao = get(daoActor)
    if (!dao || !selected) {
      return
    }
    let proposalPayload = {
      method : "",
      canister_id : Principal.fromText("uajro-ayaaa-aaaai-acpva-cai"),
      message : [],
    };
    if (selected.id == 1) { //"webpage_text"
      proposalPayload.method = "change_dao_text";
      proposalPayload.canister_id = Principal.fromText("uajro-ayaaa-aaaai-acpva-cai");
      var myblob = new Blob([proposalText], {
          type: 'text/plain'
      });
      let blobArray = await myblob.arrayBuffer();
      let blobUint = new Uint8Array(blobArray);
      proposalPayload.message = [...blobUint];
    } else if (selected.id == 2) { //"create_space"
      proposalPayload.method = "createSpace";
      proposalPayload.canister_id = Principal.fromText("vee64-zyaaa-aaaai-acpta-cai");
      var myblob = new Blob([proposalText], {
          type: 'text/plain'
      });
      let blobArray = await myblob.arrayBuffer();
      let blobUint = new Uint8Array(blobArray);
      proposalPayload.message = [...blobUint];
    } else if (selected.id == 3) { //"update_space"
      proposalPayload.method = "updateUserSpace";
      proposalPayload.canister_id = Principal.fromText("vee64-zyaaa-aaaai-acpta-cai");
      var myblob = new Blob([proposalText], {
          type: 'text/plain'
      });
      let blobArray = await myblob.arrayBuffer();
      let blobUint = new Uint8Array(blobArray);
      proposalPayload.message = [...blobUint]; //TODO: needs to be of type UpdateMetadataValuesInput
      /* public type UpdateMetadataValuesInput = {
        id: TokenId;
        updatedOwnerName: Text;
        updatedOwnerContactInfo: Text;
        updatedSpaceDescription: Text;
        updatedSpaceName: Text;
        updatedSpaceData: Text;
      }; */
    } else {
      return;
    }

    let res = await dao.submit_proposal(proposalPayload, proposalText)
    if (res.ok) {
      return res.ok
    } else {
      throw new Error(res.err)
    }
  }

  //let promise = create_proposal(summary)

  async function handleCreateClick(payload) {
    document.getElementById("waitParagraph").removeAttribute("hidden");
    summary = payload
    createProposalResult = await create_proposal(summary)
  }
</script>

<div class="votemain">
  {#if $principal}
    <img src={mot} class="bg" alt="logo" />
    <h1 class="slogan">Create a proposal</h1>
    <form on:submit|preventDefault={handleCreateClick(choosenproposal)}>
      <select bind:value={selected} on:change="{() => choosenproposal = ''}">
        {#each proposalTypes as proposalType}
          <option value={proposalType}>
            {proposalType.text}
          </option>
        {/each}
      </select>
      <input
        bind:value={choosenproposal}
        placeholder="Input your proposal summary here"
      />
      {#if (selected.id === 2 || selected.id === 3) && choosenproposal !== "Input your proposal"}
        <iframe srcdoc={choosenproposal} title="Proposed Space HTML"></iframe>
      {/if}
      <button type=submit >Create!</button>
    </form>
    {#if selected !== "" && choosenproposal !== "Input your proposal"}
      <p id="waitParagraph" hidden style="color: white">...waiting</p>
      {#if createProposalResult}
        <p style="color: white">Proposal created with payload {createProposalResult}</p>
      {/if}
      <!-- {#await promise}
        <p style="color: white">...waiting</p>
      {:then proposal}
        <p style="color: white">Proposal created with payload {proposal}</p>
      {:catch error}
        <p style="color: red">{error.message}</p>
      {/await} -->
    {/if}
  {:else}
    <p class="example-disabled">Connect with a wallet to access this example</p>
  {/if}
</div>

<style>
  input {
    width: 100%;
    padding: 12px 20px;
    margin: 8px 0;
    display: inline-block;
    border: 1px solid #ccc;
    border-radius: 4px;
    box-sizing: border-box;
  }

  .bg {
    height: 55vmin;
    animation: pulse 3s infinite;
  }

  .votemain {
    display: flex;
    flex-direction: column;
    justify-content: center;
  }

  button {
    background-color: #4caf50;
    border: none;
    color: white;
    padding: 15px 32px;
    text-align: center;
    text-decoration: none;
    display: inline-block;
    font-size: 16px;
    margin: 4px 2px;
    cursor: pointer;
  }
</style>
