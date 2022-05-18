'use strict';

jQuery(function (){
    const SPINNER_HTML =`<div class="app-launcher-spinner"><div class="spinner-border" role="status"></div></div>`;

    function showSpinner(event) {
        const $selectedLauncher = $(event.currentTarget);
        $selectedLauncher.before(SPINNER_HTML);
        $(".app-launcher-container").addClass("app-launcher-disabled");
        $("[data-toggle='launcher-button']").removeClass("app-launcher-hover");
    }

    $("[data-toggle='launcher-button'] a").each((index, element) => {
        const $launcherButton = $(element);
        $launcherButton.on("click", showSpinner);
    });

});