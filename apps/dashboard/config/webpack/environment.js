const { environment } = require('@rails/webpacker');
const config = environment.toWebpackConfig();

config.resolve.alias = {
 jquery: 'jquery/src/jquery',
 fa: '/app/javascript/packs/fa',
}

module.exports = environment
