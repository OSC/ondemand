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


const preactSrcResolvePlugin = {
  name: 'preactSrcResolve',
  setup(build) {
    // Redirect all paths starting with "images/" to "./public/images/"
    build.onResolve({ filter: /preact/ }, args => {
      const basePath = `${__dirname}/node_modules/preact`;
      if (args.path == 'preact') {
        return { path: `${basePath}/src/index.js` }
      } else if(args.path == 'preact/hooks') {
        return { path: `${basePath}/hooks/src/index.js` }
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
  plugins: [prepPlugin, preactSrcResolvePlugin],
  minify: process.env.RAILS_ENV == 'production' ? true : false,
}).catch((e) => console.error(e.message));

