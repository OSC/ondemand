
// display the osc terminal in a new window
function terminal() {
    var terminal_path = '/pun/sys/shell/ssh/oakley';
    window.open(terminal_path + DOM.getCurrentDirPath());
}

// Update the css display tags on hidden files to hide or display
function dotfiles() {
    if (!isDotfilesChecked()) {
        jQuery12( ".files li.dotfile" ).remove();
    }
}

// Show the owner and mode details when the box is checked.
function ownerMode() {
    jQuery12('body').toggleClass('hide-owner-mode', !isOwnerModeChecked());
}

// Return state of dotfiles checkbox
function isDotfilesChecked() {
    return document.getElementById("checkbox-dotfiles").checked;
}

// Return state of file details checkbox
function isOwnerModeChecked() {
    return document.getElementById("checkbox-ownermode").checked;
}

// Sets the cookie when the dotfiles box is checked
// then, call dotfiles() to update the css
// since we're deleting the dotfiles when we hide them, we need to refresh when the user clicks
function dotfilesChecked() {
    if (isDotfilesChecked()) {
        setCookie('dotfiles', true, 9999);
        CloudCmd.refresh();
    } else {
        setCookie('dotfiles', false, 9999);
    }
    dotfiles();
}

// Sets the cookie when the owner/mode box is checked
function ownerModeChecked() {
    isOwnerModeChecked() ? setCookie('ownermode', true, 9999) : setCookie('ownermode', false, 9999);
    ownerMode();
}

// getCookie and setCookie methods borrowed from
// http://www.w3schools.com/js/js_cookies.asp
function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    var expires = "expires="+d.toUTCString();
    document.cookie = cname + "=" + cvalue + "; " + expires;
}

// getCookie and setCookie methods borrowed from
// http://www.w3schools.com/js/js_cookies.asp
function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
}

// publicize download method from lib/client/menu.js
function download() {
    var TIME        = 30 * 1000,
        prefixUr    = CloudCmd.PREFIX_URL,
        FS          = CloudFunc.FS,
        PACK        = '/pack',
        date        = Date.now(),
        files       = DOM.getActiveFiles();

    if (!files.length)
        DOM.Dialog.alert.noFiles();
    else
        files.forEach(function(file) {
            var element,
                selected    = DOM.isSelected(file),
                path        = DOM.getCurrentPath(file),
                id          = DOM.load.getIdBySrc(path),
                isDir       = DOM.isCurrentIsDir(file);

            CloudCmd.log('downloading file ' + path + '...');

            if (isDir)
                path        = prefixUr + PACK + path + '.tar.gz';
            else
                path        = prefixUr + FS + path + '?download';

            element     = DOM.load({
                id          : id + '-' + date,
                name        : 'iframe',
                async       : false,
                className   : 'hidden',
                src         : path
            });

            setTimeout(function() {
                document.body.removeChild(element);
            }, TIME);

            if (selected)
                DOM.toggleSelectedFile(file);
        });
}
