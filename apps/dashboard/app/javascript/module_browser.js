import { debounce } from 'lodash';
import { hide, show } from './utils.js';

document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('[data-name]').forEach(card => {
    const versions = card.querySelectorAll("[data-role='selectable-version']");
    const infoBox = card.querySelector("[data-role='module-info']");
    const dependenciesContainer = infoBox.querySelector("[data-role='module-dependencies']");
    const loadCmdBox = infoBox.querySelector("[data-role='module-load-command']");

    versions.forEach(targetVersion => {
      targetVersion.addEventListener('click', () => {
        versions.forEach(v => v.classList.remove('active'));
        targetVersion.classList.add('active');
        updateVersionInfo(targetVersion);
      });
    });

    /** 
     * Updates dependency groups and load command based on the selected version.
     */
    function updateVersionInfo(selectedVersion) {
      const module = selectedVersion.dataset.module;
      const version = selectedVersion.dataset.version;
      const rawDeps = selectedVersion.dataset.dependencies;
      let depGroups = [];

      try {
        depGroups = JSON.parse(rawDeps);
      } catch {
        depGroups = [];
      }

      if (!Array.isArray(depGroups) || depGroups.length === 0) {
        loadCmdBox.textContent = `module load ${module}/${version}`;
        return;
      }
      
      const radioName = `dep-${module}`;
      const noneInput = infoBox.querySelector(`#dep_none_${module}`);

      // Clear previous radio buttons
      dependenciesContainer.innerHTML = '';

      // Create a radio button for each dependency group
      depGroups.forEach((group, index) => {

        const id = `${module}_depgrp_${index}`;
        const labelText = group.join(' + ');

        const wrapper = document.createElement('div');
        wrapper.className = 'form-check form-check-inline';

        const input = document.createElement('input');
        input.type = 'radio';
        input.name = radioName;
        input.className = 'form-check-input';
        input.id = id;
        input.value = group.join(' ');

        const label = document.createElement('label');
        label.className = 'form-check-label';
        label.setAttribute('for', id);
        label.textContent = labelText;

        wrapper.appendChild(input);
        wrapper.appendChild(label);
        dependenciesContainer.appendChild(wrapper);

        input.addEventListener('change', updateLoadCommand);
      });

      if (noneInput) {
        noneInput.checked = true;
        noneInput.addEventListener('change', updateLoadCommand);
      }

      updateLoadCommand();

      function updateLoadCommand() {
        const selected = infoBox.querySelector(`input[name="${radioName}"]:checked`)?.value || '';
        const depsPart = selected ? `${selected} ` : '';
        loadCmdBox.textContent = `module load ${depsPart}${module}/${version}`;
      }
    }
  });

  /*
    Copies the text content of the target element to the clipboard
  */
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

  /*
    Toggles the style of the module info box when expanded
  */
  document.querySelectorAll('[data-name]').forEach(card => {
    const toggleBtn = card.querySelector('[data-bs-target]');
    const collapse = card.querySelector('[id^="collapse_"]');

    collapse.addEventListener('shown.bs.collapse', () => {
      card.classList.add('expanded');
      toggleBtn.classList.add('active');
    });

    collapse.addEventListener('hidden.bs.collapse', () => {
      card.classList.remove('expanded');
      toggleBtn.classList.remove('active');
    });
  });

  /*
    Module search and filter
  */
  const moduleSearch = document.getElementById('module_search');
  const clusterFilter = document.getElementById('cluster_filter');

  function filterModules() {
    const searchQuery = moduleSearch.value.trim().toLowerCase();
    const selectedCluster = clusterFilter.value;

    const modules = document.querySelectorAll('[data-name][data-clusters]');
    let resultsCount = 0;
    modules.forEach(function (module) {
      const name = module.getAttribute('data-name').toLowerCase();
      const clusters = module.getAttribute('data-clusters').split(',');

      const searchMatches = name.includes(searchQuery);
      const clusterMatches = !selectedCluster || clusters.includes(selectedCluster);

      if (searchMatches && clusterMatches) {
        show(module);
        resultsCount++;
      } else {
        hide(module);
      }
    });

    // Update visible module count
    const resultsCountElem = document.getElementById('module_results_count');
    if (resultsCountElem) {
      resultsCountElem.textContent = `Showing ${resultsCount} results`;
    }
  }

  moduleSearch.addEventListener('input', debounce(filterModules, 300));
  clusterFilter.addEventListener('change', filterModules);
});
