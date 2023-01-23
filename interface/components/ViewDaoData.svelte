<script>
  import Space from "./Space.svelte"
  import { Principal } from "@dfinity/principal";
  import { get } from "svelte/store"
  import { daoActor, principal } from "../stores"

  async function get_dao_data() {
    let dao = get(daoActor);
    if (!dao) {
      return
    }
    let daoTextPayload = {
      method : "get_dao_text",
      canister_id : Principal.fromText("uajro-ayaaa-aaaai-acpva-cai"),
      message : [],
    };
    var daoText = await dao.call_webpage_canister(daoTextPayload);
    daoText = daoText.ok[0];

    let daoSpacesPayload = {
      method : "getCallerSpaces",
      canister_id : Principal.fromText("vee64-zyaaa-aaaai-acpta-cai"),
      message : [],
    };
    var daoSpaces = await dao.call_spaces_canister(daoSpacesPayload);
    daoSpaces = daoSpaces.ok[0];
    return { daoText,  daoSpaces};
  }
  let promise = get_dao_data()
</script>

{#if $principal}
  {#await promise}
    <p>Loading DAO Data...</p>
  {:then daoData}
  <div>
    <div id="daoText">
      <h1>DAO Text</h1>
      <p>{daoData.daoText}</p>
    </div>
    <div id="daoSpaces">
      <h1>DAO Spaces</h1>
      {#each daoData.daoSpaces as space}
        <Space {space} />
      {/each}
    </div>
  </div>
  {:catch error}
    <p style="color: red">{error.message}</p>
  {/await}
{:else}
  <p class="example-disabled">Connect with a wallet to see the DAO data</p>
{/if}

<style>
  h1 {
    color: white;
    font-size: 10vmin;
    font-weight: 700;
  }

  #proposals {
    display: flex;
    flex-direction: column;
    width: 100%;
    margin-left: 10vmin;
  }
</style>
