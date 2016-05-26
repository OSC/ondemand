$( document ).ready(function () {

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

    $( "#theme" ).change(function() {
        editor.setTheme( $( "#theme option:selected" ).val() );
        // TODO Save setting to cookie
    });

    $( "#mode" ).change(function() {
        editor.getSession().setMode( "ace/mode/" + $( "#mode option:selected" ).val() );
        // TODO Save setting to cookie
    });

    $( "#wordwrap" ).change(function() {
        editor.getSession().setUseWrapMode(this.checked);
        // TODO Save setting to cookie
    });

    $( "#reset-button" ).click(function() {
        editor.setValue(editorContent, -1);
    });

    $( "#save-button" ).click(function() {
        if (apiUrl !== "") {
            $.ajax({
                url: apiUrl,
                type: 'PUT',
                data: editor.getValue(),
                success: function (data) {
                    $( "#save-button" ).fadeOut(function() {
                        $( "#save-button" ).html('<span class="glyphicon glyphicon-saved" aria-hidden="true"></span> Saved!').fadeIn();
                        setTimeout(function() {
                            $( "#save-button" ).fadeOut(function() {
                                $("#save-button").html('<span class="glyphicon glyphicon-save" aria-hidden="true"></span> Save').fadeIn();
                            })
                        }, 2000);
                    });


                },
                error: function (request, status, error) {
                    alert("An error occured attempting to save this file!\n" + error);
                }
            })
        } else {
            console.log("Can't save this!");
        }
    });

})

