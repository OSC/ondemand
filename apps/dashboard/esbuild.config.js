const esbuild = require('esbuild');
const fs = require('fs');

const faDir = 'node_modules/@fortawesome/fontawesome-free/webfonts/';

// could just glob and pass this in the cli, but glob support is shell dependant
const entryPoints = filesFromDir('app/javascript');
const buildDir = 'app/assets/builds';

function filesFromDir(dir) {
  return fs.readdirSync(dir).map((file) => {
    if(fs.lstatSync(`${dir}/${file}`).isDirectory()) {
      return filesFromDir(`${dir}/${file}`);
    } else {
      return `${dir}/${file}`;
    }
  }).flat(); // only works for 1 subdirectory
}

const prepPlugin = {
  name: 'prep-build-dir',
  setup(build) {
    build.onStart(() => {
      fs.rmSync(buildDir, { recursive: true, force: true });
      fs.mkdirSync(buildDir);
      fs.copyFileSync('tmp/.keep', `${buildDir}/.keep`);

      // FIXME probably a better way to do this? build below already recognizes the filetypes.
      fs.readdir(faDir, (err, files) => {
        if(err) throw `${faDir} has to exist for assets to compile. Did you run 'bin/setup'?`;

        files.forEach(file => {
          fs.copyFileSync(`${faDir}/${file}`, `${buildDir}/${file}`);
        });
      });
    })
  },
}

// don't package minified javascript
const minifiedSrcResolvePlugin = {
  name: 'minifiedSrcResolvePlugin',
  setup(build) {
    // Redirect all paths starting with "images/" to "./public/images/"
  build.onResolve({ filter: /preact|exifr.*/ }, args => {

      const preactBase = `${__dirname}/node_modules/preact`;
      const lookup = {
        'preact': `${preactBase}/src/index.js`,
        'preact/hooks': `${preactBase}/hooks/src/index.js`,
        'exifr/dist/mini.esm.mjs': `${__dirname}/node_modules/exifr/src/bundles/mini.mjs`,
      }

      for (const [key, value] of Object.entries(lookup)) {
        if(args.path == key) {
          return { path: value }
        }
      }
    })
  },
}

esbuild.build({
  entryPoints: entryPoints,
  bundle: true,
  sourcemap: true,
  format: 'esm',
  outdir: buildDir,
  external: ['fs'],
  plugins: [prepPlugin, minifiedSrcResolvePlugin],
  minify: process.env.RAILS_ENV == 'production' ? true : false,
}).catch((e) => console.error(e.message));

