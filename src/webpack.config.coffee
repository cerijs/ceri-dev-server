HtmlWebpackPlugin = require('html-webpack-plugin')
BabiliPlugin = require("babili-webpack-plugin")
ExtractTextPlugin = require("extract-text-webpack-plugin")
path = require "path"
webpack = require "webpack"
fs = require "fs"

module.exports = (options) -> 
  return {
  entry: {}
  devtool: if !options.static then "cheap-module-eval-source-map" else "source-map"
  output:
    publicPath: ""
    filename: "[name]_bundle.js"
  module:
    rules: [
      { test: /\.woff(\d*)\??(\d*)$/, use: "url-loader?limit=10000&mimetype=application/font-woff" }
      { test: /\.ttf\??(\d*)$/,    use: "file-loader" }
      { test: /\.eot\??(\d*)$/,    use: "file-loader" }
      { test: /\.svg\??(\d*)$/,    use: "file-loader" }
      { test: /\.css$/, use: ExtractTextPlugin.extract({
        fallback: "style-loader",
        use: ["css-loader"] })
        }
      { test: /\.scss$/, use: ExtractTextPlugin.extract({
        fallback: "style-loader",
        use: ["css-loader","sass-loader"]})
        }
      { test: /\.styl$/, use: ExtractTextPlugin.extract({
        fallback: "style-loader",
        use: ["css-loader","stylus-loader"]})
        }
      { test: /\.html$/, use: "html-loader"}
      { test: /\.coffee$/, use: "coffee-loader"}
      {
        test: /ceri-dev-client/
        enforce: "post" 
        options: options
        loader: path.resolve(options.libDir,"./routes-loader")
      }
      {
        test: /\.(js|coffee)$/
        use: "ceri-loader"
        enforce: "post"
        exclude: /node_modules/
      }
    ]
  resolve:
    extensions: [".js", ".json", ".coffee"]
    alias:
      ce: path.dirname(require.resolve("ceri"))
  resolveLoader:
    extensions: [".js", ".coffee"]
    modules:[
      "web_loaders"
      "web_modules"
      "node_loaders"
      "node_modules"
      path.resolve(options.pkgDir, "./node_modules")
      path.resolve(fs.realpathSync(options.pkgDir),"..")
    ]
  plugins: [
    new webpack.DefinePlugin "process.env.NODE_ENV": JSON.stringify(if !options.static then "development" else "production")
    new BabiliPlugin {},
      test: if options.static then /.js$/i else /\.not\.js$/i
    new HtmlWebpackPlugin
      filename: 'index.html'
      template: path.resolve(options.libDir,"../index.html")
      inject: true
    new ExtractTextPlugin("styles.css")
    new webpack.optimize.ModuleConcatenationPlugin()
  ]
  watchOptions:
    aggregateTimeout: 500
}
