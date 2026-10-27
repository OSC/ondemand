document.addEventListener("DOMContentLoaded", function() {
  const selectAll = document.getElementById("select_all_launchers");
  const checkboxes = document.querySelectorAll(".launcher-checkbox");

  selectAll.addEventListener("change", function() {
    checkboxes.forEach(cb => cb.checked = selectAll.checked);
  });

  checkboxes.forEach(cb => {
    cb.addEventListener("change", function() {
      const allChecked = Array.from(checkboxes).every(x => x.checked);
      selectAll.checked = allChecked;
    });
  });
});