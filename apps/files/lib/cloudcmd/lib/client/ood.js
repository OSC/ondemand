
// Event handler activates on page load
jQuery12('body').on('panel_initialized', function(e){
    document.getElementById("checkbox-dotfiles").checked = ( getCookie('dotfiles') === 'true' );
    dotfiles();
    document.getElementById("checkbox-ownermode").checked = ( getCookie('ownermode') === 'true' );
    ownerMode();

    showTerminalButton();
    showFileEditButton();
});

// Event handler activates after the panel update
jQuery12('body').on('panel_dir_updated', function(e){
    document.getElementById("checkbox-dotfiles").checked = ( getCookie('dotfiles') === 'true' );
    dotfiles();
    document.getElementById("checkbox-ownermode").checked = ( getCookie('ownermode') === 'true' );
    ownerMode();

    showTerminalButton();
    showFileEditButton();
});

function showTerminalButton(){
    // If the shell is available, show the button.
    if(OOD.shell != null && OOD.shell != ""){
        document.getElementById("terminal-button").classList.remove("hidden");
    }
}

function showFileEditButton() {
    // If the file-editor is available, show the button.
    if(OOD.file_editor != null && OOD.file_editor != ""){
        document.getElementById("editor-button").classList.remove("hidden");
    }
}

function currentPathIsDirectory(){
    return DOM.getCurrentSize() == "dir";
}

// display the ood terminal in a new window
function terminal(ssh_host) {
    if(ssh_host != undefined) {
      window.open(encodeURI(ssh_host + DOM.getCurrentDirPath()));
    }
    else if(OOD.shell != null && OOD.shell != ""){
      window.open(encodeURI(OOD.shell + DOM.getCurrentDirPath()));
    }
    else{
      console.log("shell url prefix is not set. See osc-fileexplorer README to configure environment variables.");
    }
}

function ood_editor(){
    if(currentPathIsDirectory()){
        DOM.Dialog.alert("Files App", "Please select a file to edit");
    }
    else{
        if(OOD.file_editor != null && OOD.file_editor != ""){
          window.open(encodeURI(OOD.file_editor + DOM.getCurrentPath()));
        }
        else{
          console.log("file_editor url prefix is not set. See osc-fileexplorer README to configure environment variables.");
        }
    }
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
    document.cookie = cname + "=" + cvalue + "; " + expires + "; path=" + CloudCmd.PREFIX + ";secure;"
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
                path	    = CloudCmd.PREFIX + '/oodzip' + path;
            else
                path        = prefixUr + FS + path + '?download=' + Date.now();

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
