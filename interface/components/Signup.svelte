<script>
  import { daoActor, principal } from "../stores"
  import { get } from "svelte/store"
  import mot from "../assets/mot.png"
  let input_username = "Input your username"

  let input

  async function create_account(payload) {
    let dao = get(daoActor)
    if (!dao) {
      return
    }
    let res = await dao.create_account(payload)
    if (res.Ok) {
      return res.Ok
    } else {
      throw new Error(res.Err)
    }
  }

  let promise = create_account(input)

  function handleCreateClick(payload) {
    input = payload
    promise = create_account(input)
  }
</script>

<div class="votemain">
  {#if $principal}
    <img src={mot} class="bg" alt="logo" />
    <h1 class="slogan">Sign up for the DAO</h1>
    <input
      bind:value={input_username}
      placeholder="Input your username"
    />
    <button on:click={handleCreateClick(input_username)}>Sign up!</button>
    {#await promise}
      <p style="color: white">...waiting</p>
    {:then account}
      <p style="color: white">Congrats, account created! Your username is {account}</p>
    {:catch error}
      <p style="color: red">{error.message}</p>
    {/await}
  {:else}
    <p class="example-disabled">Connect with a wallet to sign up for the DAO</p>
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
