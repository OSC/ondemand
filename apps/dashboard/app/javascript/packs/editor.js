'use strict';

const KEY_PREFIX = "ood_editor_store_";

function normalizeKey(key) {
  return `${KEY_PREFIX}${key}`;
}

// Set localStorage. Adds a key prefix to reduce overlap likelihood.
function setLocalStorage(key, value) {
  localStorage.setItem(normalizeKey(key), value);
  return null;
}

// Get localStorage. Adds a key prefix added by setter.
function getLocalStorage(key) {
  return localStorage.getItem(normalizeKey(key));
}

// Set a user preference key to a specific value.
function setUserPreference(key, value) {
  return setLocalStorage(normalizeKey(key), value);
}

// Get the current value of the key from preferences.
function getUserPreference(key) {
  return getLocalStorage(normalizeKey(key));
}

jQuery(function () {

  $('[data-toggle="tooltip"]').tooltip();

  const editorElement = document.querySelector('#editor');
  const apiUrl = editorElement.dataset.api;
  const filePath = editorElement.dataset.path;

  // Do not load the ace editor if the element is not available
  // ex. for directory views
  if ($('#editor').length) {
    $('#error').hide();
    // Initialize the ace editor
    const editor = ace.edit("editor");
    const loading = false;

    setOptions();
    initializeEditor();
    setBeforeUnloadState();
    editor.setReadOnly(false);

    function initializeEditor() {

      // Disables/enables the save button and binds the window popup if there are changes
      editor.on("change", function () {
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
      $("#save-button").prop("disabled", true);

      // Set the caret at inside the editor on load.
      editor.focus();
    };

    function setSaveButtonState() {
      $("#save-button").prop("disabled", editor.session.getUndoManager().isClean());
    };

    function setBeforeUnloadState() {
      if (loading) {
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
      $("#save-icon").toggleClass("glyphicon-save");
      $("#save-icon").toggleClass("glyphicon-refresh");
      $("#save-icon").toggleClass("glyphicon-spin");
    };

    // Toggles a checkbox in place of the save icon
    function toggleSaveConfirmed() {
      $("#save-icon").toggleClass("glyphicon-save");
      $("#save-icon").toggleClass("glyphicon-saved");
    };

    // Sets the key binding to the selected option
    function setKeyBinding() {
      var binding = $("#keybindings option:selected").val();
      if (binding == "default") {
        binding = null;
      }
      editor.setKeyboardHandler(binding);
    };

    // Change the font size
    $("#fontsize").on('change', function () {
      editor.setFontSize($("#fontsize option:selected").val());
      setUserPreference('fontsize', $("#fontsize option:selected").val());
    });

    // Change the key bindings
    $("#keybindings").on('change', function () {
      setKeyBinding();
      setUserPreference('keybindings', $("#keybindings option:selected").val());
    });

    // Change the theme
    $("#theme").on('change', function () {
      editor.setTheme($("#theme option:selected").val());
      setUserPreference('theme', $("#theme option:selected").val());
    });

    // Change the mode
    $("#mode").on('change', function () {
      editor.getSession().setMode("ace/mode/" + $("#mode option:selected").val());
      setUserPreference('mode', $("#mode option:selected").val());
    });

    // Change the word wrap setting
    $("#wordwrap").on('change', function () {
      editor.getSession().setUseWrapMode(this.checked);
      setUserPreference('wordwrap', $("#wordwrap").is(':checked'));
    });

    // Save button onclick handler
    // sends the content to the cloudcmd api via PUT request
    $("#save-button").on('click', function () {
      if (apiUrl !== "") {
        $("#save-button").prop("disabled", true);
        toggleSaveSpinner();
        $.ajax({
          url: apiUrl,
          type: 'PUT',
          data: editor.getValue(),
          headers: {
            'Content-Type': 'text/plain',
            'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
          },
          success: function (data) {
            toggleSaveSpinner();
            toggleSaveConfirmed();
            setTimeout(function () {
              toggleSaveConfirmed();
            }, 2000);

            editor.session.getUndoManager().markClean();
            $("#save-button").prop("disabled", editor.session.getUndoManager().isClean());
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

    // Automatically Sets the dropdown and mode to the modelist option
    function setModeFromModelist() {
      var modelist = ace.require("ace/ext/modelist").getModeForPath(filePath);
      $("#mode").val(modelist.name);
      editor.session.setMode(modelist.mode);
    };


    function setOptions() {
      $("#keybindings").val(getUserPreference('keybindings') || "default");
      setKeyBinding();
      $("#fontsize").val(getUserPreference('fontsize') || '12px');
      editor.setFontSize($("#fontsize option:selected").val());
      $("#mode").val(getUserPreference('mode') || "text");
      editor.session.setMode("ace/mode/" + $("#mode option:selected").val());
      $("#theme").val(getUserPreference('theme') || "ace/theme/solarized_light");
      editor.setTheme($("#theme option:selected").val());
      $("#wordwrap").prop("checked", getUserPreference('wordwrap') === "true");
      editor.getSession().setUseWrapMode($("#wordwrap").is(':checked'));
    };

    initializeEditor();
  }
});
