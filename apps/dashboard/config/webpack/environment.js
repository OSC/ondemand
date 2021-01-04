const { environment } = require('@rails/webpacker')
const coffee = require('./loaders/coffee')
const webpack = require('webpack')
const { resolve } = require('path')

environment.config.merge({
  resolve: {
    alias: {
      images: resolve('app/assets/images'),
    },
  },
})

environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery',
  })
)

environment.loaders.get('file').use.find(item => item.loader === 'file-loader').options.publicPath = (process.env.RAILS_RELATIVE_URL_ROOT || '') + '/packs'
environment.loaders.prepend('coffee', coffee)

module.exports = environment
