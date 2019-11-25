<template>
	<v-client-table
    ref='dataTable'
		:data="tableData"
		:columns="columns"
		:options="options"
	> 
    <a slot="basename" slot-scope="{row}" :href="file_link(row.path)">{{ row.basename }}</a>
    <span slot="size" slot-scope="{row}">{{ file_size(row.size, {round: 0}) }}</span>
    <span slot="modified" slot-scope="{row}">{{ moment_unix(row.modified).format() }}</span>
  </v-client-table>
</template>

<script>
import {file_link} from '../helper'
import filesize from 'filesize'
import moment from 'moment'

export default {
  name: 'FilemanagerList',
  props: ['tableData'],
  data () {
    return {
		columns: ['basename', 'size', 'modified', 'owner', 'group', 'permissions'],
        dataTable: null,
        options: {
          childRow: 'table-buttons',
          columnsClasses: {
            modified:    'hidden-xs hidden-sm',
            owner:       'hidden-xs hidden-sm',
            group:       'hidden-xs hidden-sm',
            permissions: 'hidden-xs hidden-sm hidden-md',
          },
          perPage: 100,
          perPageValues: [10, 100, 250]
        }
    }
  },
  methods: {
    file_link: file_link,
    file_size: filesize,
    moment_unix: moment.unix,
  },
  mounted () {
    this.dataTable = this.$refs.dataTable;
  }
}
</script>

<style lang="css">
</style>