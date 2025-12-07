document.addEventListener("DOMContentLoaded", function() {
  const titleField = document.getElementById("launcher-title");
  const warning = document.getElementById("launcher-title-warning");
  let allTitles = [];
  const titlesElement = document.getElementById("launcher_titles");
  if (titlesElement) {
    try {
      allTitles = JSON.parse(titlesElement.value);
    } catch {}
  }

  if (titleField.value && launcherTitleExists(titleField.value)) showWarning();

  titleField.addEventListener("input", () => {
    const title = titleField.value;
    if (launcherTitleExists(title)) {
      showWarning();
    } else {
      hideWarning();
    }
  });

  function launcherTitleExists(title) {
    if (!title) return false;
    const normalized = title.trim().toLowerCase();
    return allTitles.map(n => n.toLowerCase()).includes(normalized);
  }

  function showWarning() {
    warning.textContent = "A launcher with this name already exists.";
    warning.style.display = "block";
  };

  function hideWarning() {
    warning.style.display = "none";
  };
});