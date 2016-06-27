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

var active_var = function() {
    return active_row().attr('id');
};

var active_row = function() {
    return $('tr.active');
};

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

    // Disable the buttons programatically on load
    if ($('#job-list-table').length > 0) {
        update_display();
    };

    $('#job-list-table tbody').on( 'click', 'tr', function () {
        
        if ( $(this).hasClass('active') ) {
            $(this).removeClass('active');
        }
        else {
            table.$('tr.active').removeClass('active');
            $(this).addClass('active');
        }
        update_missing_data_path_view();
        update_display(active_var());
    });

    var template_table = $('#new-job-template-table').DataTable();

    $('#new-job-template-table tbody').on( 'click', 'tr', function () {
        if ( $(this).hasClass('active') ) {
            // do nothing
        }
        else {
            template_table.$('tr.active').removeClass('active');
            $(this).addClass('active');
        }
        update_new_job_display(template_path());
    });

    table.$('tr:first').click();
    template_table.$('tr:first').click();
});


