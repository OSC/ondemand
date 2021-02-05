const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

const config = environment.toWebpackConfig()

config.resolve.alias = {
 jquery: 'jquery/src/jquery'
}

module.exports = environment
