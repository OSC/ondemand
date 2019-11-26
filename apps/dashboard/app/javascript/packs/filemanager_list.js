import Vue from 'vue/dist/vue.esm'
import {ServerTable, ClientTable, Event} from 'vue-tables-2'
import VModal from 'vue-js-modal'

Vue.use(ClientTable, {}, false, 'bootstrap3', 'default')
Vue.use(VModal, { dynamic: true })

import FilemanagerList from '../filemanager/components/FilemanagerList'
import TableButtons from '../filemanager/components/TableButtons'

Vue.component('table-buttons', TableButtons)

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: '#filemanager-list',
    // window.STORE is rendered server side
    render: h => h(FilemanagerList, { props: { store: window.STORE } })
  })
})
