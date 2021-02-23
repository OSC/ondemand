function toggle_data_options(attr) {
  $("#batch_connect_session_context_" + attr).change(function() {
    let d = "option" + capitalize_words("for-" + attr + "-" + this.value);
    $("[data-option-for-"+ attr + "-" + this.value + "]").each(function() {
      $(this).toggle($(this).data(d));
    });  
  });
}

function update_min_max(cores_attr, change_attr, min_val, max_val) {
  $("#batch_connect_session_context_" + change_attr).change(function() {
    $("#batch_connect_session_context_" + cores_attr).attr("min", min_val);
    $("#batch_connect_session_context_" + cores_attr).attr("max", max_val);
  });
}

