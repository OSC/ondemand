<template>
	<v-client-table
        ref='dataTable'
		:data="tableData"
		:columns="columns"
		:options="options"
	></v-client-table>
</template>

<script>
export default {
  name: 'FilemanagerList',
  props: ['tableData'],
  data () {
    return {
		columns: ['basename', 'size', 'modified', 'owner', 'group', 'permissions'],
        dataTable: null,
        options: {
            // see the options API
        }
    }
  },
  mounted () {
    this.dataTable = this.$refs.dataTable;
  }
}
</script>

<style lang="css">
</style>