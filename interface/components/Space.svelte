<script>
  export let space
</script>

<div class="post-preview">
  <h2>{space.id}</h2>
  <iframe src={'https://vdfyi-uaaaa-aaaai-acptq-cai.raw.ic0.app/?spaceId=' + space.id} title="Community Space HTML"></iframe>
  <button onclick="window.open('https://vdfyi-uaaaa-aaaai-acptq-cai.raw.ic0.app/?spaceId={space.id}','_blank')">Visit Space</button>
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
