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

// Change maps, following the name scheme <cause_field><result_field>s
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

// Create change maps from formNodeType option attributes
for (let option of formNodeType.children) {
  // For each attribute of the option...
  for (let attr of option.attributes) {
    // Get cluster name string or undefined if not following pattern
    const optionForCluster = attr.name.match(/^data-option-for-cluster-(.*)/)?.[1];
    // Put string stating 'min', 'max', or undefined in minOrMaxCores. Put name of cluster in clusterName
    const [, minOrMaxCores, clusterName] = attr.name.match(/^data-(min|max)-num-cores-for-cluster-(.*)/) || [];
    if (optionForCluster) {
      // If attribute specifies that an option is or isn't for a cluster
      // Add option element to set of options to show or hide when specified cluster is active
      addClusterToMap(optionForCluster);
      if (attr.value == 'true') {
        // If data-option-for-cluster-x='true', add to show set
        clusterNodeTypes[optionForCluster].show.add(option);
      } else if (attr.value == 'false') {
        // If data-option-for-cluster-x='false', add to hide set
        clusterNodeTypes[optionForCluster].hide.add(option);
      }
    } else if (minOrMaxCores) {
      // If attribute specifies a min/max-num-cores...
      // Ensure cluster in changeMap
      addClusterToMap(clusterName);
      // Add option to set of options to show when cluster selected
      clusterNodeTypes[clusterName].show.add(option);
      // Ensure nodeType in changeMap
      addNodeTypeToMap(clusterName, option.value);
      // Set minCores or maxCores of cluster, nodeType pair
      nodeTypeNumCores[clusterName][option.value][`${minOrMaxCores}Cores`] = Number(attr.value);
    }
  }
}

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
  // Enable and remove 'display:none' from options in show list
  clusterNodeTypes[formCluster.value]['show'].forEach((option) => {
    option.disabled = false;
    option.style.display = '';
  }); 
  clusterNodeTypes[formCluster.value]['hide'].forEach((option) => {
    // If disabling the currently selected option, change to first option in 'show' set
    if (option.value == formNodeType.value) formNodeType.value = [...clusterNodeTypes[formCluster.value]['show']][0].value;
    // Disable and add 'display:none' to options in hide list
    option.disabled = true;
    option.style.display = 'none';
  });
  // Update numCores based on new cluster and nodeType pair
  updateNumCores();
}
// Run updateNodeTypes on load
updateNodeTypes();
// UpdateNodeTypes when cluster changes
formCluster.addEventListener('change', updateNodeTypes);
