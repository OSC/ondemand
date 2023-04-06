'use strict';

/*
batch_connect.js
Handles batch connect form logic

Dom <option> elements have attributes like 
data-option-for-cluster-owens="true"
or
data-min-num-cores-for-cluster-owens="1"

When an option is selected, we handle events based on the data-* attributes and the current values
If an option has data-option-for-*="true", it will be hidden when the value it specifies is not set. If it is set, it will be shown again

*/
/* 
  changeMap - Map that defines how fields are changed when a key is changed
  Ex: {
    'cluster': { // When cluster field is changed 
      'owens': {
        show: [ // Array of options to show in node type field
          'gpu',
          'hugemem',
          'debug'
        ],
        hide: [], // Array of options to hide when
        'hugemem': {
          'minCores': 48,
          'maxCores': 48
        }
      },
      'pitzer': [...]
    },
    'nodeType': {
      'owens/hugemem': {
        'minCores': 48,
        'maxCores': 48
      }
    }
  }
*/

// Form fields
const formCluster = document.getElementById('batch_connect_session_context_cluster');
const formNumCores = document.getElementById('batch_connect_session_context_num_cores');
const formNodeType = document.getElementById('batch_connect_session_context_node_type');

let clusterChanges = {};
let nodeTypeChanges = {};
let changeMap = {
  'cluster': {},
  'nodeType': {}
};


// Ensure that the cluster name is in the changeMap
function addClusterToMap(cluster) {
  // Create empty sets in changeMap.cluster.hide and changeMap.cluster.show if undefined
  changeMap.cluster[cluster] ??= {
    'hide': new Set(),
    'show': new Set()
  };
}

// Ensure that the nodeType is in the changeMap
function addNodeTypeToMap(cluster, nodeType) {
  // Set default min/maxCores if cluster/nodeType pair is undefined
  changeMap.nodeType[cluster] ??= {};
  changeMap.nodeType[cluster][nodeType] ??= {
    'minCores': 1,
    'maxCores': 100
  };
}

// Create changeMap from option attributes
// Select all form fields by getting all elements whose id begins with 'batch_connect_session_context'
const selectQuery = "[id^='batch_connect_session_context']";
document.querySelectorAll(selectQuery).forEach((formField) => {
  // If formField specifies a select field, populate map of options to show when cluster is set AND minMaxNodes when nodeType is set
  if (formField.tagName == 'SELECT') {
    const formFieldOptions = formField.children;
    // For option in formField...
    for (let i=0; i < formFieldOptions.length; i++) {
      const option = formFieldOptions[i];
      // For each attribute of the option...
      for (let attr of option.attributes) {
        // If attribute specifies a cluster where option will be shown...
        if (attr.name.startsWith('data-option-for-cluster-')) {
          // Add option element to list of options to show or hide when specified cluster is active
          const cluster = attr.name.replace('data-option-for-cluster-', '');
          // Ensure cluster in changeMap
          addClusterToMap(cluster);
          if (attr.value == 'true') {
            // If data-option-for-cluster-x='true', add to show set
            changeMap.cluster[cluster].show.add(option);
          } else if (attr.value == 'false') {
            // If data-option-for-cluster-x='false', add to hide set
            changeMap.cluster[cluster].hide.add(option);
          }
        } else if (attr.name.startsWith('data-min-num-cores-for-cluster-')) {
          // If 'data-min-num-cores-for-cluster-x' attribute is present, 
          const cluster = attr.name.replace('data-min-num-cores-for-cluster-', '');
          // Ensure cluster in changeMap
          addClusterToMap(cluster);
          // Show option when cluster selected
          changeMap.cluster[cluster].show.add(option); // May or may not be necessary to add to show here
          // Ensure nodeType in changeMap
          addNodeTypeToMap(cluster, option.value);
          // Set minCores of cluster, nodeType pair
          changeMap.nodeType[cluster][option.value].minCores = Number(attr.value);
        } else if (attr.name.startsWith('data-max-num-cores-for-cluster-')) {
          const cluster = attr.name.replace('data-max-num-cores-for-cluster-', '');
          // Ensure cluster in changeMap
          addClusterToMap(cluster);
          // Show option when cluster selected
          changeMap.cluster[cluster].show.add(option);
          // Ensure nodeType in changeMap
          addNodeTypeToMap(cluster, option.value);
          // Set maxCores of cluster, nodeType pair
          changeMap.nodeType[cluster][option.value].maxCores = Number(attr.value);
        }
      }
    }
  }
});


/*
  Update min/max and current value of numCores based on selected cluster and nodeType
*/
function updateNumCores() {
  // On nodeType change, set min/max cores
  formNumCores.min = changeMap.nodeType[formCluster.value][formNodeType.value].minCores;
  formNumCores.max = changeMap.nodeType[formCluster.value][formNodeType.value].maxCores;
  if (formNumCores.value > formNumCores.max) formNumCores.value = formNumCores.max;
  else if (formNumCores.value < formNumCores.min) formNumCores.value = formNumCores.min;
}
// Run updateNodeCores on load
updateNumCores();
// UpdateNumCores when nodeType changes
formNodeType.addEventListener('change', updateNumCores);


/*
  Update contents of nodeType selection based on cluster selected
*/
function updateNodeTypes() {
  // Remove 'display:none' from options in show list
  changeMap.cluster[formCluster.value]['show'].forEach((option) => option.style.display = '' ); 
  changeMap.cluster[formCluster.value]['hide'].forEach((option) => {
    // Add 'display:none' to options in hide list
    option.style.display = 'none';
    // If currently selected option is now disabled, change to first option in 'show' set
    if (option.value == formNodeType.value) formNodeType.value = [...changeMap.cluster[formCluster.value]['show']][0].value;
  });
  // Update numCores based on new cluster and nodeType pair
  updateNumCores();
}
// Run updateNodeTypes on load
updateNodeTypes();
// UpdateNodeTypes when cluster changes
formCluster.addEventListener('change', updateNodeTypes);
