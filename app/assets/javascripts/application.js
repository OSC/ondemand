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
//= require local_time
//= require_tree .

jQuery.fn.visible = function() {
    return this.css('visibility', 'visible');
};

jQuery.fn.invisible = function() {
    return this.css('visibility', 'hidden');
};

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
};

function start_joyride() {
    if ($('#joyride').length) {
        $('#joyride').joyride();
    }
}

$(document).ready(function(){

    start_joyride();

    $('[data-toggle="tooltip"]').tooltip();

    var table;

    if ($('#job-list-table').length) {
        table = $('#job-list-table').DataTable();

        if (($('.job-row').length == 0)) {
            update_display();
            start_joyride();
        }

        $('#job-list-table tbody').on('click', 'tr', function () {

            if ($(this).hasClass('active')) {
                $(this).removeClass('active');
            }
            else {
                table.$('tr.active').removeClass('active');
                $(this).addClass('active');
            }
            update_job_details_panel();
            update_display(active_var());
        });
    }

    if ($('#new-job-template-table').length) {
        table = $('#new-job-template-table').DataTable();


        $('#new-job-template-table tbody').on('click', 'tr', function () {
            if ($(this).hasClass('active')) {
                // do nothing
            }
            else {
                table.$('tr.active').removeClass('active');
                $(this).addClass('active');
            }
            update_new_job_display(active_row());
        });
    }

    if (table) {
        if (table.$('#' + selected_id).length > 0) {
            table.$('#' + selected_id).click();
        } else {
            table.$('tr:first').click();
        }
    };
});
