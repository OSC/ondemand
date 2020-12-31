const { environment } = require('@rails/webpacker')
const coffee = require('./loaders/coffee')

const webpack = require('webpack')
const fileLoader = require('./loaders/file-loader')

environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    _: 'lodash',
    Popper: '@popperjs/core'
  })
)

environment.loaders.get('file').use.find(item => item.loader === 'file-loader').options.publicPath = (process.env.RAILS_RELATIVE_URL_ROOT || '') + '/packs'
environment.loaders.prepend('coffee', coffee)
environment.loaders.prepend('file-loader', fileLoader)

module.exports = environment
