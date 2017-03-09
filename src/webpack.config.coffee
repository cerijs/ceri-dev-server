HtmlWebpackPlugin = require('html-webpack-plugin')
UglifyJSPlugin = require "uglifyjs-webpack-plugin"
path = require "path"
webpack = require "webpack"
module.exports = (options) -> {
  entry: {}
  devtool: "source-map"#if !options.static then "cheap-eval-source-map" else "source-map"
  output:
    publicPath: ""
    filename: "[name]_bundle.js"
  module:
    rules: [
      { test: /\.html$/, use: "html-loader"}
      { test: /\.coffee$/, use: "coffee-loader"}
      { test: /\.css$/, use: ["style-loader","css-loader"] }
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
      options.modulesDir
    ]
  plugins: [
    new webpack.DefinePlugin "process.env.NODE_ENV": JSON.stringify(if !options.static then "development" else "production")
    new UglifyJSPlugin
      compress:
        dead_code: true
        warnings: false
      mangle: !!options.static
      beautify: !options.static
      sourceMap: true
    new HtmlWebpackPlugin
      filename: 'index.html'
      template: path.resolve(options.libDir,"../index.html")
      inject: true
  ]
}
