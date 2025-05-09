import { hide, show } from './utils.js';

document.addEventListener('DOMContentLoaded', function () {
  const moduleSearch = document.getElementById('module_search');
  const clusterFilter = document.getElementById('cluster_filter');

  function filterModules() {
    const searchQuery = moduleSearch.value.toLowerCase();
    const selectedCluster = clusterFilter.value;

    const modules = document.querySelectorAll('[data-name][data-clusters]');
    modules.forEach(function (module) {
      const name = module.getAttribute('data-name').toLowerCase();
      const clusters = module.getAttribute('data-clusters').split(',');

      const searchMatches = name.includes(searchQuery);
      const clusterMatches = !selectedCluster || clusters.includes(selectedCluster);

      if (searchMatches && clusterMatches) {
        show(module);
      } else {
        hide(module);
      }
    });
  }

  moduleSearch.addEventListener('input', filterModules);
  clusterFilter.addEventListener('change', filterModules);
});
