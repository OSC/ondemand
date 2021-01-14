const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
}))

const coffee = require('./loaders/coffee')
environment.loaders.prepend('coffee', coffee)

const config = environment.toWebpackConfig()

config.resolve.alias = {
 jquery: 'jquery/src/jquery'
}

module.exports = environment
