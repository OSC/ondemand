jQuery(function (){
    function showSpinner() {
        $('body').addClass('modal-open');
        $('#full-page-spinner').removeClass('d-none');
    }

    $('.full-page-spinner').each((index, element) => {
        const $element = $(element);
        if($element.is('a')) {
            $element.on('click', showSpinner);
        } else {
            $element.closest('form').on('submit', showSpinner);
        }
    });
});