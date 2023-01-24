'use strict';

jQuery(function (){
    const SPINNER_HTML =`<div class="app-launcher-spinner"><div class="spinner-border" role="status"></div></div>`;

    function showSpinner(event) {
        const $selectedLauncher = $(event.currentTarget);
        $selectedLauncher.before(SPINNER_HTML);
        $(".app-launcher-container").addClass("app-launcher-disabled");
        $("[data-toggle='launcher-button']").removeClass("app-launcher-hover");
    }

    function hideSpinner() {
        $(".app-launcher-container").removeClass("app-launcher-disabled");
        $("[data-toggle='launcher-button']").addClass("app-launcher-hover");
        $("div.app-launcher-spinner").remove();
    }

    $("[data-toggle='launcher-button'] .launcher-click").each((index, element) => {
        const $launcherButton = $(element);
        $launcherButton.on("click", showSpinner);
    });

    /*
    Back button fix. Because of browser page caching, spinner is shown when back is click
    This event will trigger everytime the page is shown, removing the spinner if present.
     */
    $(window).on('pageshow', hideSpinner)

});