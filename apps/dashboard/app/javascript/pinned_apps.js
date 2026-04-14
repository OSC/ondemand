'use strict';

jQuery(function (){
    const SPINNER_HTML =`<div class="app-launcher-spinner"><div class="spinner-border" role="status"></div></div>`;
    const pinnedAppsSearch = document.getElementById('pinned-apps-search');
    const pinnedAppItems = Array.from(document.querySelectorAll('.pinned-app-checkbox-item'));
    const selectAllBtn = document.getElementById('select-all-pinned-apps');
    const clearAllBtn = document.getElementById('clear-all-pinned-apps');

    function showSpinner(event) {
        const $selectedLauncher = $(event.currentTarget);
        $selectedLauncher.before(SPINNER_HTML);
        $(".app-launcher-container").addClass("app-launcher-disabled");
        $("[data-toggle='launcher-button'], [data-bs-toggle='launcher-button']").removeClass("app-launcher-hover");
    }

    function hideSpinner() {
        $(".app-launcher-container").removeClass("app-launcher-disabled");
        $("[data-toggle='launcher-button'], [data-bs-toggle='launcher-button']").addClass("app-launcher-hover");
        $("div.app-launcher-spinner").remove();
    }

    $("[data-toggle='launcher-button'] .launcher-click, [data-bs-toggle='launcher-button'] .launcher-click").each((index, element) => {
        const $launcherButton = $(element);
        $launcherButton.on("click", showSpinner);
    });

    function filteredItems() {
        return pinnedAppItems.filter((item) => item.style.display !== 'none');
    }

    function setCheckedForVisible(checked) {
        filteredItems().forEach((item) => {
            const checkbox = item.querySelector("input[type='checkbox']");
            if (checkbox) {
                checkbox.checked = checked;
            }
        });
    }

    if (pinnedAppsSearch) {
        pinnedAppsSearch.addEventListener('input', () => {
            const query = pinnedAppsSearch.value.trim().toLowerCase();
            pinnedAppItems.forEach((item) => {
                const title = item.dataset.appTitle || '';
                const token = item.dataset.appToken || '';
                const isMatch = query.length === 0 || title.includes(query) || token.includes(query);
                item.style.display = isMatch ? '' : 'none';
            });
        });
    }

    if (selectAllBtn) {
        selectAllBtn.addEventListener('click', () => setCheckedForVisible(true));
    }

    if (clearAllBtn) {
        clearAllBtn.addEventListener('click', () => setCheckedForVisible(false));
    }

    /*
    Back button fix. Because of browser page caching, spinner is shown when back is click
    This event will trigger every time the page is shown, removing the spinner if present.
     */
    $(window).on('pageshow', hideSpinner)

});