var fs = require('fs');
const termSchemes   = require('term-schemes');
const path      = require('path');

var themeDir = path.join(__dirname, "public", "themes");
var lightDir = path.join(themeDir, "light");
var darkDir = path.join(themeDir, "dark");

var finalSchemeLight = [];
var finalSchemeDark = [];

function getSchemeObjects(dir) {
  var schemes = [];

  try {
    fs.readdirSync(dir).forEach(function(file) {
      if(! /^\..*/.test(file)) {
      fileInfo = path.parse(file);
        schemes.push({name: fileInfo.name, file: fileInfo.base, ext: fileInfo.ext, dir: dir});
      }      
    });
    return schemes;
  } catch (err) {
    return [];
  }
}

function getSchemeFilesArray() {

    return Object.keys(schemeObjects).map(i => schemeObjects[i])
}

function rgbToHexMath (num) { 
  var hex = Number(num).toString(16);
  if (hex.length < 2) {
       hex = "0" + hex;
  }
  return hex;
};

function hexConverter (array) {
    var red = array[0];
    var green = array[1];
    var blue = array[2];

    return `#${rgbToHexMath(red)}${rgbToHexMath(green)}${rgbToHexMath(blue)}`.toUpperCase();
}

function parseFile(fileObject) {
    
    const ext = fileObject.ext;
    const file = fileObject.dir + "/" + fileObject.file;
    const raw = String(fs.readFileSync(file));

    const schemes = {
      ".itermcolors": termSchemes.iterm2,
      ".colorscheme": termSchemes.konsole,
      ".colors": termSchemes.remmina,
      ".terminal":termSchemes.terminal,
      ".config": termSchemes.terminator,
      ".config_0": termSchemes.tilda,
      ".theme": termSchemes.xfce,
      ".txt": termSchemes.termite,
      ".Xresources": termSchemes.xresources,
      ".xresources": termSchemes.xresources,
      ".xrdb": termSchemes.xresources,
    }
    try {
      return schemes[ext](raw)
    } catch (err) {
      return {error: "unknown file type."}
    }
}

function convertSchemeObject(obj) {
    newSchemeObj = {};
    colorArray = [];
    for (var key of Object.keys(obj)) {
       if(isNaN(key) === false) {
           
           colorArray.push(hexConverter(obj[key]));
       
        } else if (isNaN(key)) {
            newSchemeObj[key] = hexConverter(obj[key]);
        }

    }

    newSchemeObj["colorPaletteOverrides"] = colorArray;

    return newSchemeObj;
}

var	lightSchemes = getSchemeObjects(lightDir);
var darkSchemes = getSchemeObjects(darkDir);



     lightSchemes.forEach(e => {
      var fileObject = e;
     	var theSchemeObject = parseFile(fileObject);
     	var schemeColorConverter = convertSchemeObject(theSchemeObject);
        finalSchemeLight.push({"name": e.name, "scheme": schemeColorConverter});
     });

     darkSchemes.forEach(e => {
      var fileObject = e;
      var theSchemeObject = parseFile(fileObject);
      var schemeColorConverter = convertSchemeObject(theSchemeObject);
        finalSchemeDark.push({"name": e.name, "scheme": schemeColorConverter});    
     });

fs.writeFile('public/javascripts/themes.js', 'brightThemes = ', function (err) {
  if (err) throw err;
  console.log('Saved!');
});

const themeFile = fs.createWriteStream('public/javascripts/themes.js', { flags: 'a' });

themeFile.write(JSON.stringify(finalSchemeLight, null, "\t"));
themeFile.write(';');
themeFile.write('\n darkThemes = ');
themeFile.write(JSON.stringify(finalSchemeDark, null, "\t"));
themeFile.write(';');

themeFile.end();



