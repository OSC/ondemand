document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('[data-name]').forEach(card => {
    const versions = card.querySelectorAll("[data-role='selectable-version']");
    const infoBox = card.querySelector("[data-role='module-info']");
    const dependenciesSpan = infoBox.querySelector("[data-role='module-dependencies']");
    const loadCmd = infoBox.querySelector("[data-role='module-load-command']");

    const defaultVersion = [...versions].find(v => v.dataset.default === 'true');
    if (defaultVersion) updateInfo(defaultVersion);

    versions.forEach(badge => {
      badge.addEventListener('click', () => {
        versions.forEach(v => v.classList.remove('selected-version'));
        badge.classList.add('selected-version');

        updateInfo(badge);
      });
    });

    function updateInfo(badge) {
      const module = badge.dataset.module;
      const version = badge.dataset.version;
      const deps = badge.dataset.dependencies || '-';

      dependenciesSpan.textContent = deps;
      loadCmd.textContent = `module load ${module}/${version}`;
    }
  });

  document.querySelectorAll('[data-role="copy-btn"]').forEach(button => {
    button.addEventListener('click', () => {
      const selector = button.getAttribute('data-clipboard-target');
      const target = document.querySelector(selector);
      if (!target) return;
  
      const text = target.textContent;
      navigator.clipboard.writeText(text)
        .then(() => {
          button.textContent = 'Copied!';
          setTimeout(() => button.textContent = 'Copy', 2000);
        })
        .catch(err => {
          console.error('Clipboard write failed:', err);
        });
    });
  });
});
