# out: ../lib/index.js
path = require "path"
ip = require "ip"
fs = require "fs"
merge = require "webpack-merge"
ext = path.extname(__filename)
if ext == ".coffee"
  require "coffee-script/register"

fstools = require "./fstools"
karma = null

resolvePath = (args...)->
  tmp = path.resolve.apply(null,args)
  unless fstools.isDirectory(tmp)
    throw new Error "#{tmp} doesn't exist or is no directory"
  return tmp

getLocalWebpackCfg = (options) ->
  for dir in ["cwd","workingDir"]
    for extension in ["coffee","js","json"]
      filename = "#{options[dir]}/webpack.config.#{extension}"
      if fstools.isFile(filename)
        if extension == "coffee"
          require "coffee-script/register"
        return require filename
  return {}

getWebpackCfg = (options) ->
  localWebpackCfg = getLocalWebpackCfg(options)
  entry = if options.test then {} else {
    entry:
      index: ["#{options.libDir}/ceri-dev-client#{ext}"]
    output:
      path: options.static + "/"
      publicPath: ""
      filename: "[name]_bundle.js"
    }

  return merge require("#{options.libDir}/webpack.config")(options), entry, localWebpackCfg, {
      context: options.workingDir
    }

getLocalKarmaCfg = (options) ->
  for dir in ["cwd","workingDir"]
    for extension in ["coffee","js"]
      filename = "#{options[dir]}/karma.conf.#{extension}"
      if fstools.isFile(filename)
        if extension == "coffee"
          require "coffee-script/register"
        return karma.config.parseConfig(filename)
  return {}

getKarmaCfg = (options) ->
  localCfg = getLocalKarmaCfg(options)
  unless localCfg.files
    files = options.workingDir+"/**/*.+(#{options.extensions.join("|")})"
    localCfg.files = [files]
    localCfg.preprocessors = {}
    localCfg.preprocessors[files] = ["webpack", "sourcemap"]
  localCfg.autoWatch ?= options.watch == true
  localCfg.singleRun ?= options.watch != true
  localCfg.browsers = options.browsers if options.browsers
  cfg = karma.config.parseConfig path.resolve(options.libDir,"karma.config#{ext}"), localCfg
  cfg.webpack = merge getWebpackCfg(options), cfg.webpack
  return cfg

module.exports = (options) ->
  options = Object.assign {
    port:8080
    folder: "dev"
    extensions: ["js","coffee"]
    ext: ext
    ip: ip.address()
    libDir: __dirname
    pkgDir: resolvePath(__dirname, "..")
    cwd: process.cwd()
    static: ""
    test: false
    watch: false
    }, options
  options.workingDir = resolvePath(options.folder)
  options.static = path.resolve(options.static) if options.static
  if options.test
    karma = require "karma"
    server = new karma.Server getKarmaCfg(options)
    server.start()
  else
    webconf = getWebpackCfg(options)
    if options.static
      require("mkdirp").sync(options.static)
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
      if ext == ".coffee"
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
