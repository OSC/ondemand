// FIXME: taken from https://github.com/rails/webpacker/issues/2140
// can't seem to get anything else to respond to the root url /pun/<thing>/<app>
// so let's open this config up and redefine those things. We don't use or care about WEBPACKER_ASSET_HOST
if (process.env.RAILS_RELATIVE_URL_ROOT || process.env.WEBPACKER_RELATIVE_URL_ROOT) {
  const config = require('@rails/webpacker/package/config');
  const path = require('path');
  const root = process.env.WEBPACKER_RELATIVE_URL_ROOT || process.env.RAILS_RELATIVE_URL_ROOT || '/';
  config.publicPath = path.join(root, `${config.public_output_path}/`);
  config.publicPathWithoutCDN = path.join(root, `${config.public_output_path}/`);
}

const { environment } = require('@rails/webpacker');
const config = environment.toWebpackConfig();
const { merge } = require('webpack-merge');

config.resolve.alias = {
 jquery: 'jquery/src/jquery',
 fa: '/app/javascript/packs/fa',
 batchConnect: '/apps/javascript/packs/batchConnect'
};

const faPath = "~@fortawesome/fontawesome-free/webfonts/";
const sassOptions = {
  additionalData: `$fa-font-path: '${faPath}';`,
  sourceMap: true,
};

const SASSLoader = environment.loaders.get('sass').use.find(el => el.loader === 'sass-loader');
SASSLoader.options = merge(SASSLoader.options, sassOptions);

module.exports = environment
