const esbuild = require('esbuild');
const fs = require('fs');

// FIXME probably a better way to do this? build below already recognizes the filetypes.
const faDir = 'node_modules/@fortawesome/fontawesome-free/webfonts/';
fs.readdir(faDir, (err, files) => {
  if(err) throw `${faDir} has to exist for to compile. Did you run 'bin/setup'?`;

  files.forEach(file => {
    fs.copyFile(`${faDir}/${file}`, `app/assets/builds/${file}`, () => {});
  });
});

// could just glob and pass this in the cli, but glob support is shell dependant
entryPoints = filesFromDir('app/javascript');

function filesFromDir(dir) {
  return fs.readdirSync(dir).map((file) => {
    if(fs.lstatSync(`${dir}/${file}`).isDirectory()) {
      return filesFromDir(`${dir}/${file}`);
    } else {
      return `${dir}/${file}`;
    }
  }).flat(); // only works for 1 subdirectory
}

esbuild.build({
  entryPoints: entryPoints,
  bundle: true,
  sourcemap: true,
  format: 'esm',
  outdir: 'app/assets/builds',
  external: ['fs'],
  minify: process.env.RAILS_ENV == 'production' ? true : false,
}).catch((e) => console.error(e.message));

