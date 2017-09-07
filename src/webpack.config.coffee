HtmlWebpackPlugin = require('html-webpack-plugin')
BabiliPlugin = require("babili-webpack-plugin")
ExtractTextPlugin = require("extract-text-webpack-plugin")
path = require "path"
webpack = require "webpack"
fs = require "fs"

os = require "os"
HappyPack = require "happypack"
happyThreadPool = HappyPack.ThreadPool size: os.cpus().length



module.exports = (options) -> 
  plugins = [
    new HappyPack
      id: "coffee"
      threadPool: happyThreadPool
      loaders: [ "coffee-loader" ]
    new HappyPack
      id: "ceri"
      threadPool: happyThreadPool
      loaders: [ "ceri-loader" ]
  ]
  if options.test
    env = "test"
  else if options.static
    env = "production"
  else
    env = "development"
  plugins.push new webpack.DefinePlugin "process.env.NODE_ENV": JSON.stringify(env)
  if env == "production"
    plugins.push new BabiliPlugin 
    plugins.push new ExtractTextPlugin("styles.css")
    plugins.push new webpack.optimize.ModuleConcatenationPlugin()

  unless options.test
    plugins.push new HtmlWebpackPlugin
      filename: 'index.html'
      template: path.resolve(options.libDir,"../index.html")
      inject: true
    
  getStyleLoader = (name) ->
    loaders = ["css-loader"]
    unless name == "css"
      loaders.push "#{name}-loader"
    unless env == "production"
      loaders.unshift("style-loader")
      try
        require.resolve "#{name}-loader"
      catch
        return loaders
      plugins.push new HappyPack
        id: name
        threadPool: happyThreadPool
        loaders: loaders
      return "happypack/loader?id=#{name}"
    else
      return ExtractTextPlugin.extract {fallback: "style-loader", use: loaders}
      
  return {
  devtool: if !options.static then "inline-source-map" else "source-map"
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
      { test: /\.coffee$/, use: "happypack/loader?id=coffee"}
      {
        test: /ceri-dev-client/
        enforce: "post" 
        options: options
        loader: path.resolve(options.libDir,"./routes-loader")
      }
      {
        test: /\.(js|coffee)$/
        use: "happypack/loader?id=ceri"
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
