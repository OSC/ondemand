// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require js-routes
//= require_tree .

active_var = function() {
    return $('tr.active').attr('id');
}

function joinRoot(route){
    var arr = []
    arr.push(ROOT_PATH)
    arr.push(route)
    var separator = '/';
    var replace   = new RegExp(separator+'{1,}', 'g');
    return arr.join(separator).replace(replace, separator);
}

$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip();

    var table = $('#job-list-table').DataTable();

    $('#job-list-table tbody').on( 'click', 'tr', function () {
        if ( $(this).hasClass('active') ) {
            $(this).removeClass('active');
        }
        else {
            table.$('tr.active').removeClass('active');
            $(this).addClass('active');

        }
        update_display(active_var());
    });

    table.$('tr:first').click();
});



