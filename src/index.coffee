# out: ../lib/index.js
path = require "path"
ip = require "ip"
fs = require "fs"
merge = require "webpack-merge"

ext = path.extname(__filename)
if ext == ".coffee"
  require "coffee-script/register"

fstools = require "./fstools"


resolvePath = (args...)->
  tmp = path.resolve.apply(null,args)
  unless fstools.isDirectory(tmp)
    throw new Error "#{tmp} doesn't exist or is no directory"
  return tmp

module.exports = (options) ->
  options = Object.assign {
    port:8080
    folder: "dev"
    extensions: ["js","coffee"]
    ext: ext
    ip: ip.address()
    libDir: __dirname
    modulesDir: resolvePath(__dirname,"../node_modules")
    static: ""
    test: false
    watch: false
    }, options
  options.workingDir = resolvePath(options.folder)
  options.static = resolvePath(options.static) if options.static
  if options.test
    karma = require "karma"
    files = options.workingDir+"/**/*.+(#{options.extensions.join("|")})"
    cfg = 
      preprocessors: {}
      files: [files]
      autoWatch: options.watch == true
      singleRun: options.watch != true
    cfg.browsers = options.browsers if options.browsers
    cfg.preprocessors[files] = ["webpack"]
    cfg = karma.config.parseConfig path.resolve(options.libDir,"karma.config#{ext}"), cfg
    server = new karma.Server cfg
    server.start()
  else
    for extension in ["coffee","js","json"]
      filename = "#{options.workingDir}/webpack.config.#{extension}"
      if fstools.isFile(filename)
        if extension == "coffee"
          require "coffee-script/register"
        webconf = require filename
        break
    webconf ?= {}
    webconf = merge require("#{options.libDir}/webpack.config")(options), {
      entry:
        index: ["#{options.libDir}/ceri-dev-client#{ext}"]
      output:
        path: options.static + "/"
      },
      webconf, {
        context: options.workingDir
      }
    if options.static
      webpack = require "webpack"
      compiler = webpack(webconf)
      compiler.run (err, stats) ->
        throw err if err
        console.log stats.toString(colors: true)
        if stats.hasErrors() or stats.hasWarnings()
          console.log "please fix the warnings and errors with webpack first"
    else
      koa = require("koa")
      koa = new koa()
      koaHotDevWebpack = require "koa-hot-dev-webpack"
      koa.use require("koa-static")(options.workingDir,index:false)
      koa.use koaHotDevWebpack(webconf)
      chokidar = require "chokidar"
      chokidar.watch(options.libDir,ignoreInitial: true)
      .on "all", (event, path) ->
        koaHotDevWebpack.invalidate()
      chokidar.watch(options.workingDir,ignoreInitial: true)
      .on "add", (event, path) ->
        koaHotDevWebpack.invalidate()
      if options.koa
        return koa
      else
        server = require("http").createServer(koa.callback())
        server.listen options.port, ->
          console.log "listening on http://#{options.ip}:#{options.port}/"
        return server
if process.argv[0] == "coffee"
  module.exports()
