'use strict';

/*
batch_connect.js
Handles batch connect form logic.
When a field is changed, update other fields based on limits written in DOM attributes

Dom <option> elements in the nodeType select field have attributes like 
data-option-for-cluster-owens="true"
data-option-for-cluster-pitzer="false"
or
data-min-num-cores-for-cluster-owens="1"
data-max-num-cores-for-cluster-owens="28"

These are processed into changeMaps clusterNodeTypes and nodeTypeNumCores.
The changeMaps are used to determine what changes should be made after a field is updated.
*/

// Form fields
const formCluster = document.getElementById('batch_connect_session_context_cluster');
const formNodeType = document.getElementById('batch_connect_session_context_node_type');
const formNumCores = document.getElementById('batch_connect_session_context_num_cores');

// Change maps
// Map of nodeTypes to hide/show when specified cluster is updated
let clusterNodeTypes = {};
// Map of min/max cores to update when specified cluster/nodeType is updated
let nodeTypeNumCores = {};


// Ensure that the cluster name is in the changeMap
function addClusterToMap(cluster) {
  // Create empty sets in clusterNodeTypes[cluster].hide and clusterNodeTypes[cluster].show if undefined
  clusterNodeTypes[cluster] ??= {
    // The sets here will contain references to nodeType DOM option elements to hide or show when a given cluster is selected
    'hide': new Set(),
    'show': new Set()
  };
}

// Ensure that the nodeType is in the changeMap
function addNodeTypeToMap(cluster, nodeType) {
  // Set default min/maxCores if cluster/nodeType pair is undefined
  nodeTypeNumCores[cluster] ??= {};
  nodeTypeNumCores[cluster][nodeType] ??= {
    'minCores': 1,
    'maxCores': 100
  };
}

// Create changeMap from option attributes
// Select all form fields by getting all elements whose id begins with 'batch_connect_session_context'
document.querySelectorAll("[id^='batch_connect_session_context']").forEach((formField) => {
  // If formField specifies a select field, populate map of options to show when cluster is set AND minMaxNodes when nodeType is set
  if (formField.tagName == 'SELECT') {
    // For option in formField...
    for (let option of formField.children) {
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
            clusterNodeTypes[cluster].show.add(option);
          } else if (attr.value == 'false') {
            // If data-option-for-cluster-x='false', add to hide set
            clusterNodeTypes[cluster].hide.add(option);
          }
        } else if (attr.name.startsWith('data-min-num-cores-for-cluster-')) {
          // If 'data-min-num-cores-for-cluster-x' attribute is present, 
          const cluster = attr.name.replace('data-min-num-cores-for-cluster-', '');
          // Ensure cluster in changeMap
          addClusterToMap(cluster);
          // Add option to set of options to show when cluster selected
          clusterNodeTypes[cluster].show.add(option);
          // Ensure nodeType in changeMap
          addNodeTypeToMap(cluster, option.value);
          // Set minCores of cluster, nodeType pair
          nodeTypeNumCores[cluster][option.value].minCores = Number(attr.value);
        } else if (attr.name.startsWith('data-max-num-cores-for-cluster-')) {
          const cluster = attr.name.replace('data-max-num-cores-for-cluster-', '');
          // Ensure cluster in changeMap
          addClusterToMap(cluster);
          // Add option to set of options to show when cluster selected
          clusterNodeTypes[cluster].show.add(option);
          // Ensure nodeType in changeMap
          addNodeTypeToMap(cluster, option.value);
          // Set maxCores of cluster, nodeType pair
          nodeTypeNumCores[cluster][option.value].maxCores = Number(attr.value);
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
  formNumCores.min = nodeTypeNumCores[formCluster.value][formNodeType.value].minCores;
  formNumCores.max = nodeTypeNumCores[formCluster.value][formNodeType.value].maxCores;
  // If current value out of range, set to closest value in range
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
  clusterNodeTypes[formCluster.value]['show'].forEach((option) => option.style.display = '' ); 
  clusterNodeTypes[formCluster.value]['hide'].forEach((option) => {
    // Add 'display:none' to options in hide list
    option.style.display = 'none';
    // If currently selected option is now disabled, change to first option in 'show' set
    if (option.value == formNodeType.value) formNodeType.value = [...clusterNodeTypes[formCluster.value]['show']][0].value;
  });
  // Update numCores based on new cluster and nodeType pair
  updateNumCores();
}
// Run updateNodeTypes on load
updateNodeTypes();
// UpdateNodeTypes when cluster changes
formCluster.addEventListener('change', updateNodeTypes);
