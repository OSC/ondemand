import Vue from 'vue/dist/vue.esm'
import {ServerTable, ClientTable, Event} from 'vue-tables-2';
Vue.use(ClientTable, {}, false, 'bootstrap3', 'default')

import FilemanagerList from '../components/filemanager/FilemanagerList'

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: '#filemanager-list',
    // FILESYSTEM_ENTRIES is rendered server side
    render: h => h(FilemanagerList, { props: { tableData: FILESYSTEM_ENTRIES } })
  })
})
