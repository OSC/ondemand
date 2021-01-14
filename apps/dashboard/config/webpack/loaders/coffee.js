module.exports = {
  test: /\.coffee$/,
  loader: 'coffee-loader',
  options: {
    transpile: {
      presets: ['@babel/env'],
    },
  },
}
