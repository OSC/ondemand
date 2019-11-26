<template>
    <td>
      <a class="btn btn-primary" :href="file_link('/download' + data.path)" download="1">Download</a>
      <a class="btn btn-primary" href="#">Copy</a>
      <a class="btn btn-primary" href="#">Move/Rename</a>
      <a class="btn btn-danger" href="#">Delete</a>
    </td>
</template>

<script>
import {file_link} from '../helper'

export default {
  name: 'table-buttons',
  props: ['data', 'index', 'column'],
  // data () {
  //   return {
  //   }
  // },
  methods: {
    file_link: file_link
  }
}
</script>

<style lang="css">
</style>
