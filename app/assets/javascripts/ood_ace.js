$( document ).ready(function () {

    // Do not load the ace editor if the element is not available
    // ex. for directory views
    if ( $( "#editor" ).length ) {
        // Initialize the ace editor
        var editor = ace.edit("editor");
        editor.setTheme( $( "#theme option:selected" ).val() );
        editor.session.setMode( "ace/mode/" + $( "#mode option:selected" ).val() );
        $( "#loading-notice" ).toggle();
        // Load the file via ajax
        var loadedContent = $.ajax({

            url: apiUrl,
            type: 'GET',
            success: function (data) {
                editorContent = data;
                editor.setValue(editorContent, -1);
                $( "#loading-notice" ).toggle();
            },
            error: function (request, status, error) {
                alert("An error occured attempting to load this file!\n" + error);
                $( "#loading-notice" ).toggle();
            }
        });

        // Disables/enables the save button
        editor.on("change", function () {
            $( "#save-button" ).prop("disabled", editor.session.getUndoManager().isClean());
        });

        // This will show a popup when the user tries to leave the page if there are changes.
        $(window).bind('beforeunload', function(){
            if (!editor.session.getUndoManager().isClean()) {
                return 'You have unsaved changes!';
            }
        });

        // Toggles a spinner in place of the save icon
        function toggleSaveSpinner() {
            $( "#save-icon" ).toggleClass("glyphicon-save");
            $( "#save-icon" ).toggleClass("glyphicon-refresh");
            $( "#save-icon" ).toggleClass("glyphicon-spin");
        }

        // Toggles a checkbox in place of the save icon
        function toggleSaveConfirmed() {
            $( "#save-icon" ).toggleClass("glyphicon-save");
            $( "#save-icon" ).toggleClass("glyphicon-saved");
        }

        // Change the font size
        $( "#fontsize" ).change(function() {
            editor.setFontSize( $( "#fontsize option:selected" ).val() );
            // TODO Save setting to cookie
        });

        // Change the key bindings
        $( "#keybindings" ).change(function() {
            editor.setKeyboardHandler( "ace/keyboard/" + $( "#keybindings option:selected" ).val() );
            // TODO Save setting to cookie
        });

        // Change the theme
        $( "#theme" ).change(function() {
            editor.setTheme( $( "#theme option:selected" ).val() );
            // TODO Save setting to cookie
        });

        // Change the mode
        $( "#mode" ).change(function() {
            editor.getSession().setMode( "ace/mode/" + $( "#mode option:selected" ).val() );
            // TODO Save setting to cookie
        });

        // Change the word wrap setting
        $( "#wordwrap" ).change(function() {
            editor.getSession().setUseWrapMode(this.checked);
            // TODO Save setting to cookie
        });

        // Save button onclick handler
        // sends the content to the cloudcmd api via PUT request
        $( "#save-button" ).click(function() {
            if (apiUrl !== "") {
                toggleSaveSpinner();
                $.ajax({
                    url: apiUrl,
                    type: 'PUT',
                    data: editor.getValue(),
                    success: function (data) {
                        toggleSaveSpinner();
                        toggleSaveConfirmed();
                        setTimeout(function () {
                          toggleSaveConfirmed();
                        }, 2000);

                        editor.session.getUndoManager().markClean();
                        $( "#save-button" ).prop("disabled", editor.session.getUndoManager().isClean());
                    },
                    error: function (request, status, error) {
                        alert("An error occured attempting to save this file!\n" + error);
                        toggleSaveSpinner();
                    }
                })

            } else {
                console.log("Can't save this!");
            }
        });

        // Mark the editor as clean after load.
        editor.session.getUndoManager().markClean();
    }

    // Disable the save button after the initial load
    // Modifying settings and adding data to the editor makes the UndoManager "dirty"
    // so we have to explicitly re-disable it on page ready.
    $( "#save-button" ).prop("disabled", true);});
