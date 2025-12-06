document.addEventListener("DOMContentLoaded", function() {
  const selectAll = document.getElementById("select_all_launchers");
  const checkboxes = document.querySelectorAll(".launcher-checkbox");
  const nameField = document.getElementById("workflow_name");
  const warning = document.getElementById("workflow-name-warning");
  let allNames = [];
  const namesElement = document.getElementById("workflow-names");
  if (namesElement) {
    try {
      allNames = JSON.parse(namesElement.value);
    } catch {}
  }

  if (nameField.value && workflowNameExists(nameField.value)) showWarning();

  selectAll.addEventListener("change", function() {
    checkboxes.forEach(cb => cb.checked = selectAll.checked);
  });

  checkboxes.forEach(cb => {
    cb.addEventListener("change", function() {
      const allChecked = Array.from(checkboxes).every(x => x.checked);
      selectAll.checked = allChecked;
    });
  });

  nameField.addEventListener("input", () => {
    const name = nameField.value;
    if (workflowNameExists(name)) {
      showWarning();
    } else {
      hideWarning();
    }
  });

  function workflowNameExists(name) {
    if (!name) return false;
    const normalized = name.trim().toLowerCase();
    return allNames.map(n => n.toLowerCase()).includes(normalized);
  }

  function showWarning() {
    warning.textContent = "A workflow with this name already exists.";
    warning.style.display = "block";
  };

  function hideWarning() {
    warning.style.display = "none";
  };
});