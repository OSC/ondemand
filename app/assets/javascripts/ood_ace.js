$( document ).ready(function () {

    // Do not load the ace editor if the element is not available
    // ex. for directory views
    if ( $( "#editor" ).length ) {
        // Initialize the ace editor
        var editor = ace.edit("editor");
        setOptions();
        editor.setReadOnly(true);
        $( "#loading-notice" ).toggle();
        var loading = true;
        // Load the file via ajax
        var loadedContent = $.ajax({
            url: apiUrl,
            type: 'GET',
            success: function (data) {
                editorContent = data;
                $("#editor").text(editorContent);
                editor.destroy();
                editor = ace.edit("editor");
                initializeEditor();
                $( "#loading-notice" ).toggle();
                setBeforeUnloadState();
                loading = false;
            },
            error: function (request, status, error) {
                alert("An error occured attempting to load this file!\n" + error);
                $( "#loading-notice" ).toggle();
            }
        });
        function initializeEditor() {

            // Disables/enables the save button and binds the window popup if there are changes
            editor.on("change", function() {
                // The dirtyCounter is an undocumented array in the UndoManager
                // Changing the editor only modifies the dirtyCounter after the event is over,
                // so we set it manually on change to apply the proper unload state
                // https://github.com/ajaxorg/ace/blob/4a55188fdb0eee9e2d3854f175e67408a1e47655/lib/ace/undomanager.js#L164
                editor.session.getUndoManager().dirtyCounter++;
                setBeforeUnloadState();
            });

            // Mark the editor as clean after load.
            editor.session.getUndoManager().markClean();

            // Disable the save button after the initial load
            // Modifying settings and adding data to the editor makes the UndoManager "dirty"
            // so we have to explicitly re-disable it on page ready.
            $( "#save-button" ).prop("disabled", true);
        };

        function setSaveButtonState() {
            $( "#save-button" ).prop("disabled", editor.session.getUndoManager().isClean());
        };

        function setBeforeUnloadState() {
            if ( loading ) {
                editor.session.getUndoManager().markClean();
            };

            setSaveButtonState();

            window.onbeforeunload = function (e) {
                if (!editor.session.getUndoManager().isClean()) {
                    return 'You have unsaved changes!';
                } else {
                    // return nothing
                };
            };
        };

        // Toggles a spinner in place of the save icon
        function toggleSaveSpinner() {
            $( "#save-icon" ).toggleClass("glyphicon-save");
            $( "#save-icon" ).toggleClass("glyphicon-refresh");
            $( "#save-icon" ).toggleClass("glyphicon-spin");
        };

        // Toggles a checkbox in place of the save icon
        function toggleSaveConfirmed() {
            $( "#save-icon" ).toggleClass("glyphicon-save");
            $( "#save-icon" ).toggleClass("glyphicon-saved");
        };

        // Change the font size
        $( "#fontsize" ).change(function() {
            editor.setFontSize( $( "#fontsize option:selected" ).val() );
            setCookie( 'fontsize', $( "#fontsize option:selected" ).val(), 9999 );
        });

        // Change the key bindings
        $( "#keybindings" ).change(function() {
            editor.setKeyboardHandler( $( "#keybindings option:selected" ).val() );
            setCookie( 'keybindings', $( "#keybindings option:selected" ).val(), 9999 );
        });

        // Change the theme
        $( "#theme" ).change(function() {
            editor.setTheme( $( "#theme option:selected" ).val() );
            setCookie( 'theme', $( "#theme option:selected" ).val(), 9999 );
        });

        // Change the mode
        $( "#mode" ).change(function() {
            editor.getSession().setMode( "ace/mode/" + $( "#mode option:selected" ).val() );
            setCookie( 'mode', $( "#mode option:selected" ).val(), 9999 );
        });

        // Change the word wrap setting
        $( "#wordwrap" ).change(function() {
            editor.getSession().setUseWrapMode(this.checked);
            setCookie( 'wordwrap', $( "#wordwrap" ).is(':checked'), 9999 );
        });

        // Save button onclick handler
        // sends the content to the cloudcmd api via PUT request
        $( "#save-button" ).click(function() {
            if (apiUrl !== "") {
                $( "#save-button" ).prop("disabled", true);
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
                        setBeforeUnloadState();
                    },
                    error: function (request, status, error) {
                        alert("An error occured attempting to save this file!\n" + error);
                        toggleSaveSpinner();
                    }
                });
            } else {
                console.log("Can't save this!");
            };
        });

        function setOptions() {
            $( "#keybindings" ).val(getCookie('keybindings') || 'ace');
            editor.setKeyboardHandler( $( "#keybindings option:selected" ).val() );
            $( "#fontsize" ).val(getCookie('fontsize') || '12px');
            editor.setFontSize( $( "#fontsize option:selected" ).val() );
            $( "#mode" ).val(getCookie('mode') || "text");
            editor.session.setMode( "ace/mode/" + $( "#mode option:selected" ).val() );
            $( "#theme" ).val(getCookie('theme') || "ace/theme/solarized_light");
            editor.setTheme( $( "#theme option:selected" ).val() );
            $( "#wordwrap" ).prop("checked", getCookie('wordwrap') === "true");
            editor.getSession().setUseWrapMode( $( "#wordwrap" ).is(':checked'));
        };

        initializeEditor();
    }
});
