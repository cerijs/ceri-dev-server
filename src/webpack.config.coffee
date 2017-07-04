HtmlWebpackPlugin = require('html-webpack-plugin')
BabiliPlugin = require("babili-webpack-plugin")
ExtractTextPlugin = require("extract-text-webpack-plugin")
path = require "path"
webpack = require "webpack"
fs = require "fs"

module.exports = (options) -> 
  plugins = []
  if options.test
    env = "test"
  else if options.static
    env = "production"
  else
    env = "development"
  plugins.push new webpack.DefinePlugin "process.env.NODE_ENV": JSON.stringify(env)
  plugins.push new BabiliPlugin if options.static
  unless options.test
    plugins.push new HtmlWebpackPlugin
      filename: 'index.html'
      template: path.resolve(options.libDir,"../index.html")
      inject: true
    plugins.push new ExtractTextPlugin("styles.css")
    plugins.push new webpack.optimize.ModuleConcatenationPlugin()
  getStyleLoader = (name) ->
    loaders = ["css-loader"]
    unless name == "css"
      loaders.push "#{name}-loader"
    unless options.test
      return ExtractTextPlugin.extract {fallback: "style-loader", use: loaders}
    else
      loaders.unshift("style-loader")
      return loaders
  return {
  devtool: if !options.static then "cheap-module-eval-source-map" else "source-map"
  module:
    rules: [
      { test: /\.woff(\d*)\??(\d*)$/, use: "url-loader?limit=10000&mimetype=application/font-woff" }
      { test: /\.ttf\??(\d*)$/,    use: "file-loader" }
      { test: /\.eot\??(\d*)$/,    use: "file-loader" }
      { test: /\.svg\??(\d*)$/,    use: "file-loader" }
      { test: /\.css$/, use: getStyleLoader("css") }
      { test: /\.scss$/, use: getStyleLoader("sass") }
      { test: /\.styl$/, use: getStyleLoader("stylus") }
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
  plugins: plugins
  watchOptions:
    aggregateTimeout: 500
}
