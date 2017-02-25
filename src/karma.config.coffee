path = require "path"
webpack = require "webpack"
module.exports = (config) ->
  config.set
    webpack:
      devtool: 'cheap-eval-source-map'
      resolve:
        extensions: [".js",".coffee",".json"]
        alias:
          ce: path.dirname(require.resolve("ceri"))
      module:
        rules: [
          { test: /\.coffee$/, loader: "coffee-loader" }
          { test: /\.css$/, loader: "style-loader!css-loader" }
          {
            test: /\.(js|coffee)$/
            use: "ceri-loader"
            enforce: "post"
            exclude: /node_modules/
          }
        ]
      plugins: [
        new webpack.DefinePlugin "process.env.NODE_ENV": JSON.stringify('test')
      ]
    frameworks: ["mocha","chai-dom","chai-spies","chai","ceri"]
    plugins: [
      require("karma-chai")
      require("karma-chai-dom")
      require("karma-chrome-launcher")
      require("karma-firefox-launcher")
      require("karma-mocha")
      require("karma-webpack")
      require("karma-chai-spies")
      require("karma-ceri")
    ]
    browsers: ["Chromium","Firefox"]
