jQuery(function (){
  $(document).on('input change', '#module_search, #cluster_filter', function () {
    const searchQuery = $('#module_search').val().toLowerCase();
    const selectedCluster = $('#cluster_filter').val();

    $('[data-name][data-clusters]').each(function () {
      const name = $(this).data('name');
      const clusters = $(this).data('clusters').split(',');

      const searchMatches = name.includes(searchQuery);
      const clusterMatches = !selectedCluster || clusters.includes(selectedCluster);

      $(this).toggle(searchMatches && clusterMatches);
    });
  });
});
