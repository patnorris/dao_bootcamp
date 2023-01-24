<script>
  export let post
</script>

<div class="post-preview">
  <h2>{post.id}</h2>
  <p>Proposer: {post.proposer.toString()}</p>
  <!-- <p>Status: {Object.keys(post.state)[0].toString() === "failed" ? post.state.failed : Object.keys(post.state)[0].toString()}</p> -->
  <p>Status: {Object.keys(post.state)[0].toString()} </p>
  <p>Yes Votes: {post.votes_yes.amount_e8s}</p>
  <p>No Votes: {post.votes_no.amount_e8s}</p>
  {#if post.payload.method == "change_dao_text"}
    <p>Change website text to: {post.proposal_text}</p>
  {:else if post.payload.method == "createSpace"}
    <p>Create new Community Space: {post.proposal_text}</p>
    <iframe id={post.id} srcdoc={post.proposal_text} title="Proposed Space HTML"></iframe>
  {:else if post.payload.method == "updateUserSpace"}
    <p>Update Community Space: {post.proposal_text}</p>
    <iframe id={post.id} srcdoc={JSON.parse(post.proposal_text).updatedSpaceData} title="Proposed Space HTML"></iframe>
  {/if}
</div>

<style>
  .post-preview {
    border: 1px solid white;
    border-radius: 10px;
    margin-bottom: 2vmin;
    padding: 2vmin;
  }
  h2 {
    color: white;
  }

  p {
    color: white;
  }
</style>
