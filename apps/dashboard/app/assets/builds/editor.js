"use strict";
(() => {
  // app/javascript/packs/editor.js
  var KEY_PREFIX = "ood_editor_store_";
  function normalizeKey(key) {
    return `${KEY_PREFIX}${key}`;
  }
  function setLocalStorage(key, value) {
    localStorage.setItem(normalizeKey(key), value);
    return null;
  }
  function getLocalStorage(key) {
    return localStorage.getItem(normalizeKey(key));
  }
  function setUserPreference(key, value) {
    return setLocalStorage(normalizeKey(key), value);
  }
  function getUserPreference(key) {
    return getLocalStorage(normalizeKey(key));
  }
  jQuery(function() {
    $('[data-toggle="tooltip"]').tooltip();
    const editorElement = document.querySelector("#editor");
    const apiUrl = editorElement.dataset.api;
    const filePath = editorElement.dataset.path;
    if ($("#editor").length) {
      let initializeEditor = function() {
        editor.on("change", function() {
          editor.session.getUndoManager().dirtyCounter++;
          setBeforeUnloadState();
        });
        editor.session.getUndoManager().markClean();
        $("#save-button").prop("disabled", true);
        editor.focus();
      }, setSaveButtonState = function() {
        $("#save-button").prop("disabled", editor.session.getUndoManager().isClean());
      }, setBeforeUnloadState = function() {
        if (loading) {
          editor.session.getUndoManager().markClean();
        }
        ;
        setSaveButtonState();
        window.onbeforeunload = function(e) {
          if (!editor.session.getUndoManager().isClean()) {
            return "You have unsaved changes!";
          } else {
          }
          ;
        };
      }, toggleSaveSpinner = function() {
        $("#save-icon").toggleClass("glyphicon-save");
        $("#save-icon").toggleClass("glyphicon-refresh");
        $("#save-icon").toggleClass("glyphicon-spin");
      }, toggleSaveConfirmed = function() {
        $("#save-icon").toggleClass("glyphicon-save");
        $("#save-icon").toggleClass("glyphicon-saved");
      }, setKeyBinding = function() {
        var binding = $("#keybindings option:selected").val();
        if (binding == "default") {
          binding = null;
        }
        editor.setKeyboardHandler(binding);
      }, setModeFromModelist = function() {
        var modelist = ace.require("ace/ext/modelist").getModeForPath(filePath);
        $("#mode").val(modelist.name);
        editor.session.setMode(modelist.mode);
      }, setOptions = function() {
        $("#keybindings").val(getUserPreference("keybindings") || "default");
        setKeyBinding();
        $("#fontsize").val(getUserPreference("fontsize") || "12px");
        editor.setFontSize($("#fontsize option:selected").val());
        $("#mode").val(getUserPreference("mode") || "text");
        editor.session.setMode("ace/mode/" + $("#mode option:selected").val());
        $("#theme").val(getUserPreference("theme") || "ace/theme/solarized_light");
        editor.setTheme($("#theme option:selected").val());
        $("#wordwrap").prop("checked", getUserPreference("wordwrap") === "true");
        editor.getSession().setUseWrapMode($("#wordwrap").is(":checked"));
      };
      $("#error").hide();
      const editor = ace.edit("editor");
      const loading = false;
      setOptions();
      initializeEditor();
      setBeforeUnloadState();
      editor.setReadOnly(false);
      ;
      ;
      ;
      ;
      ;
      ;
      $("#fontsize").on("change", function() {
        editor.setFontSize($("#fontsize option:selected").val());
        setUserPreference("fontsize", $("#fontsize option:selected").val());
      });
      $("#keybindings").on("change", function() {
        setKeyBinding();
        setUserPreference("keybindings", $("#keybindings option:selected").val());
      });
      $("#theme").on("change", function() {
        editor.setTheme($("#theme option:selected").val());
        setUserPreference("theme", $("#theme option:selected").val());
      });
      $("#mode").on("change", function() {
        editor.getSession().setMode("ace/mode/" + $("#mode option:selected").val());
        setUserPreference("mode", $("#mode option:selected").val());
      });
      $("#wordwrap").on("change", function() {
        editor.getSession().setUseWrapMode(this.checked);
        setUserPreference("wordwrap", $("#wordwrap").is(":checked"));
      });
      $("#save-button").on("click", function() {
        if (apiUrl !== "") {
          $("#save-button").prop("disabled", true);
          toggleSaveSpinner();
          $.ajax({
            url: apiUrl,
            type: "PUT",
            data: editor.getValue(),
            contentType: "text/plain",
            success: function(data) {
              toggleSaveSpinner();
              toggleSaveConfirmed();
              setTimeout(function() {
                toggleSaveConfirmed();
              }, 2e3);
              editor.session.getUndoManager().markClean();
              $("#save-button").prop("disabled", editor.session.getUndoManager().isClean());
              setBeforeUnloadState();
            },
            error: function(request, status, error) {
              alert("An error occured attempting to save this file!\n" + error);
              toggleSaveSpinner();
            }
          });
        } else {
          console.log("Can't save this!");
        }
        ;
      });
      ;
      ;
      initializeEditor();
    }
  });
})();
//# sourceMappingURL=editor.js.map
