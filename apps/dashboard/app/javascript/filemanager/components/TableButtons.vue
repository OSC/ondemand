<template>
    <td>
      <a class="btn btn-primary" href="#" target="_blank">Download</a>
      <a class="btn btn-primary" href="#" target="_blank">Copy</a>
      <a class="btn btn-primary" href="#" target="_blank">Move/Rename</a>
      <a class="btn btn-danger" href="#" target="_blank">Delete</a>
    </td>
</template>

<script>

export default {
  name: 'table-buttons',
  props: ['data', 'index', 'column'],
  // data () {
  //   return {
  //   }
  // },
  // methods: {
  // }
}
</script>

<style lang="css">
</style>
