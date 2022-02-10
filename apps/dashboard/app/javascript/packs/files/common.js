var actionsBtnTemplate = null;

$(document).ready(function(){
  actionsBtnTemplate = (function(){
    let template_str  = $('#actions-btn-template').html();
    return Handlebars.compile(template_str);
  })();  
});

// https://github.com/transloadit/uppy/blob/7ce58beeb620df3df0640cb369f5d71e3d3f751f/packages/%40uppy/utils/src/getDroppedFiles/utils/webkitGetAsEntryApi/getFilesAndDirectoriesFromDirectory.js
/**
 * Recursive function, calls the original callback() when the directory is entirely parsed.
 *
 * @param {FileSystemDirectoryReader} directoryReader
 * @param {Array} oldEntries
 * @param {Function} logDropError
 * @param {Function} callback - called with ([ all files and directories in that directoryReader ])
 */
 function getFilesAndDirectoriesFromDirectory (directoryReader, oldEntries, logDropError, { onSuccess }) {
    directoryReader.readEntries(
      (entries) => {
        const newEntries = [...oldEntries, ...entries]
        // According to the FileSystem API spec, getFilesAndDirectoriesFromDirectory() must be called until it calls the onSuccess with an empty array.
        if (entries.length) {
          setTimeout(() => {
            getFilesAndDirectoriesFromDirectory(directoryReader, newEntries, logDropError, { onSuccess })
          }, 0)
        // Done iterating this particular directory
        } else {
          onSuccess(newEntries)
        }
      },
      // Make sure we resolve on error anyway, it's fine if only one directory couldn't be parsed!
      (error) => {
        logDropError(error)
        onSuccess(oldEntries)
      }
    )
  }
  
  function getEmptyDirs(entry){
    return new Promise((resolve) => {
      if(entry.isFile){
        resolve([]);
      }
      else{
        // getFilesAndDirectoriesFromDirectory has no return value, so turn this into a promise
        getFilesAndDirectoriesFromDirectory(entry.createReader(), [], function(error){ console.error(error)}, {
          onSuccess: (entries) => {
            if(entries.length == 0){
              // this is an empty directory
              resolve([entry]);
            }
            else{
              Promise.all(entries.map(e => getEmptyDirs(e))).then((dirs) => resolve(_.flattenDeep(dirs)));
            }
          }
        })
      }
    });
  }
  