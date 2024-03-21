jQuery(function (){
    function showSpinner() {
        $('body').addClass('modal-open');
        $('#full-page-spinner').removeClass('d-none');
    }

    $('.full-page-spinner').each((index, element) => {
        $(element).closest('form').on('submit', showSpinner);
    });
});