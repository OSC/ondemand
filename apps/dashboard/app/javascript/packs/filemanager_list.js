import Vue from 'vue/dist/vue.esm'
import FilemanagerList from '../components/filemanager/FilemanagerList'

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: '#filemanager-list',
    render: h => h(FilemanagerList, { props: { vue: Vue } })
  })
})
