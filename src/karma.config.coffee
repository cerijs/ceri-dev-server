path = require "path"
webpack = require "webpack"
module.exports = (config) ->
  config.set
    webpack:
      #devtool: 'cheap-eval-source-map'
      resolveLoader:
        modules:[
          "web_loaders"
          "web_modules"
          "node_loaders"
          "node_modules"
        ]
      resolve:
        extensions: [".js",".coffee",".json"]
        alias:
          ce: path.dirname(require.resolve("ceri"))
      module:
        rules: [
          { test: /\.woff(\d*)\??(\d*)$/, use: "url-loader?limit=10000&mimetype=application/font-woff" }
          { test: /\.ttf\??(\d*)$/,    use: "file-loader" }
          { test: /\.eot\??(\d*)$/,    use: "file-loader" }
          { test: /\.svg\??(\d*)$/,    use: "file-loader" }
          { test: /\.css$/, use: ["style-loader","css-loader"] }
          { test: /\.scss$/, use: ["style-loader","css-loader","sass-loader"]}
          { test: /\.styl$/, use: ["style-loader","css-loader","stylus-loader"]}
          { test: /\.html$/, use: "html-loader"}
          { test: /\.coffee$/, use: "coffee-loader"}
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
