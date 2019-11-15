<template>
  <div
    id="app"
    class="col-12"
  >
    <div class="row">
      <div class="col-12">
        <form
          class="form-inline d-flex mx-1 justify-content-end"
          @submit.stop.prevent="doSearch"
        >
          <div class="input-group">
            <input
              v-model="quickSearch"
              type="search"
              placeholder="Quick search"
              class="form-control"
            >
            <div class="input-group-append">
              <button
                type="submit"
                class="btn btn-outline-secondary"
              >
                <i class="mdi mdi-magnify" /> Go
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <!-- Using the VdtnetTable component -->
    <vdtnet-table
      ref="table"
      :fields="fields"
      :opts="options"
      :select-checkbox="1"
      :vue="vue"
      :dataLoader="dataLoader"
      @edit="doAlertEdit"
      @delete="doAlertDelete"
      @reloaded="doAfterReload"
      @table-creating="doCreating"
      @table-created="doCreated"
    ></vdtnet-table>
  </div>
</template>

<script>
// this demonstrate with buttons and responsive master/details row
import VdtnetTable from '../VdtnetTable'
import 'datatables.net-bs'  // note *-bs4 versions exist
// import buttons and plugins
import 'datatables.net-buttons/js/dataTables.buttons.js'
import 'datatables.net-buttons/js/buttons.html5.js'
import 'datatables.net-buttons/js/buttons.print.js'
// import the rest
import 'datatables.net-buttons-bs'
import 'datatables.net-select-bs'
import 'datatables.net-select-bs/css/select.bootstrap.min.css'
import 'datatables.net-buttons-bs/css/buttons.bootstrap.min.css'

export default {
  name: 'FilemanagerList',
  components: { VdtnetTable },
  props: ['vue'],
  data() {
    const vm = this
    return {
      dataLoader: (cb) => {
        cb(window.FILESYSTEM_ENTRIES)
      },
      options: {
        buttons: ['copy', 'csv', 'print'],
        dom: "Btr<'row vdtnet-footer'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'pl>>",
        responsive: true,
        processing: true,
        searching: true,
        searchDelay: 1500,
        destroy: true,
        ordering: true,
        lengthChange: true,
        serverSide: true,
        fixedHeader: true,
        saveState: true,
        paging: false,  // Show all rows without paging
      },
      fields: {
        // id: { label: 'Select', sortable: true },
        basename: { label: 'Name', sortable: true, searchable: true, defaultOrder: 'desc' },
        size: { label: 'Size', sortable: true },
        modified: { label: 'Modified', sortable: true },
        owner: { label: 'Owner', sortable: true, searchable: true },
        group: { label: 'Group', sortable: true, searchable: true },
        permissions: { label: 'Permissions', sortable: true },
      },
      quickSearch: '',
      details: {}
    }
  },
  methods: {
    doLoadTable(cb) {
      // $.getJSON( 'https://jsonplaceholder.typicode.com/users', function( data ) {
      //   cb(data)
      // })
      cb(window.FILESYSTEM_ENTRIES)
    },
    doAlertEdit(data) {
      window.alert(`row edit click for item ID: ${data.id}`)
    },
    doAlertDelete(data, row, tr, target) {
      window.alert(`deleting item ID: ${data.id}`)
      // row.remove() doesn't work when serverside is enabled
      // so we fake it with dom remove
      tr.remove()
      const table = this.$refs.table
      setTimeout(() => {
        // simulate extra long running ajax
        table.reload()
      }, 1500)
    },
    doAfterReload(data, table) {
      // window.alert('data reloaded')
    },
    doCreating(comp, el) {
      console.log('creating')
    },
    doCreated(comp) {
      console.log('created')
    },
    doSearch() {
      this.$refs.table.search(this.quickSearch)
    },
    doExport(type) {
      const parms = this.$refs.table.getServerParams()
      parms.export = type
      window.alert('GET /api/v1/export?' + jQuery.param(parms))
    },
    formatCode(zipcode) {
      return zipcode.split('-')[0]
    }
  }
}
</script>

<style scoped>
</style>