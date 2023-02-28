/**
 * Generates a filename that doesn't match that of an existing file in the current
 * directory. Will append "_copy" if a file with the same name exists and append 
 * `_${n}` where n is an integer increasing from 1 until a filename is found that 
 * doesn't currently exist.
 *
 * @param      {string}  originalName   The original file name
 * @returns    {string}  safeName       The file name edited to prevent overwriting
 */
export function dupSafeName(originalName) {
  const currentFilenames = history.state.currentFilenames;
  const extIndex = originalName.lastIndexOf('.');
  let newName, extension;
  if (extIndex == -1) {
    // If no extension or directory, disregard extension
    newName = originalName;
    extension = '';
  } else {
    newName = originalName.slice(0, extIndex);
    extension = originalName.slice(extIndex);
  }
  // If originalName in cur dir, try `${originalName}_copy`.
  if (currentFilenames.includes(newName + extension)) {
    newName += '_copy';
    // If `${originalName}_copy` exists, try `${originalName}_copy_{n}' starting at n=1 until a file doesn't exist
    if (currentFilenames.includes(newName + extension)) {
      let copyNumber = 1;
      newName += `_${copyNumber}`;
      while (currentFilenames.includes(newName + extension)) {
        copyNumber++;
        newName = newName.slice(0, newName.lastIndexOf('_') + 1) + copyNumber;
      }
    }
  }
  return `${newName}${extension}`
}
