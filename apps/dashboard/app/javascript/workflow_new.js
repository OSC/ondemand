document.addEventListener("DOMContentLoaded", () => {
  const select = document.getElementById("existing_workflow_select");
  const nameField = document.getElementById("workflow_name");
  const descField = document.getElementById("workflow_description");
  const copyField = document.getElementById("copy_from_id");
  const form = document.querySelector("form");
  const saveButton = form.querySelector('input[type="submit"]');


  const existingNames = Array.from(select.options)
    .filter(opt => opt.value)
    .map(opt => opt.value.toLowerCase());

  console.log("Existing workflow names:", existingNames);

  select.addEventListener("change", (e) => {
    const selected = e.target.selectedOptions[0];
    if (selected && selected.value) { 
      nameField.value = selected.dataset.name;
      descField.value = selected.dataset.description || "";
      copyField.value = selected.value;
    } else {
      nameField.value = "";
      descField.value = "";
      copyField.value = "";
    }
  });

  form.addEventListener("submit", (e) => {
    const currentName = nameField.value.trim().toLowerCase();
    if (existingNames.includes(currentName)) {
      e.preventDefault();
      alert("A workflow with this name already exists. Please choose another name.");
      // Re-enable the button after alert is closed
      setTimeout(() => {
        saveButton.removeAttribute('disabled');
      }, 100);
    }
  });
});