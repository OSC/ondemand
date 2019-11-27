<template>
  <div>
    <v-client-table
      ref='dataTable'
      :data="store.file_system_entries"
      :columns="columns"
      :options="options"
    >
      <a slot="basename" slot-scope="{row}" :href="file_link(row.path)">{{ row.basename }}</a>
      <span slot="size" slot-scope="{row}">{{ file_size(row.size, {round: 0}) }}</span>
      <span slot="modified" slot-scope="{row}">{{ moment_unix(row.modified).format() }}</span>
    </v-client-table>
    <modals-container/>
  </div>
</template>

<script>
import {file_link} from '../helper'
import filesize from 'filesize'
import moment from 'moment'
import UploadModal from './UploadModal'

// polyfill for MAX_SAFE_INTEGER
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/MAX_SAFE_INTEGER
if (!Number.MAX_SAFE_INTEGER) {
    Number.MAX_SAFE_INTEGER = 9007199254740991; // Math.pow(2, 53) - 1;
}

export default {
  name: 'FilemanagerList',
  props: ['store'],
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
          perPage: Number.MAX_SAFE_INTEGER,
          perPageValues: [],
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
    this.$modal.show(UploadModal, { abc: 123 }, {})
  },

  beforeUpdate() {

  }
}
</script>

<style lang="css">
.VueTables__child-row-toggler {
    width: 16px;
    height: 16px;
    line-height: 16px;
    display: block;
    margin: auto;
    text-align: center;
}

.VueTables__child-row-toggler--closed::before {
    content: "+";
}

.VueTables__child-row-toggler--open::before {
    content: "-";
}
</style>