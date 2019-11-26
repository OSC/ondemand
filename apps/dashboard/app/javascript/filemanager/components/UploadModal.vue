<template>
  <div class="container">
    <h1>Upload a file to <code>/users/PZS0002/mrodgers</code></h1>
    <form class="form-inline" enctype="multipart/form-data" action="/pun/dev/monorepo_dashboard/fs/upload//users/PZS0002/mrodgers" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="✓"><input type="hidden" name="authenticity_token" value="TODO">
        <div class="form-group">
        <label class="sr-only" for="file-upload">Select a file to upload</label>
        <div class="input-group">
          <div class="input-group-addon">Choose file</div>
          <input class="form-control" type="file" name="file_upload">
        </div>
      </div>
      <button type="submit" class="btn btn-primary">Submit</button>
    </form>
</div>
</template>

<script>
export default {
  name: 'UploadModal',
  // props: ['store'],
  data () {
    return {
    }
  },
  methods: {
  },
  mount() {
    // ajaxDoStuff...
  }
}
</script>

<style lang="css">
</style>