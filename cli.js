#!/usr/bin/env node
var program = require('commander')
  , fs = require('fs')
  , path = require('path')
  , list = function (val) { return val.split(',') }
program
  .version(JSON.parse(fs.readFileSync(path.join(__dirname, 'package.json'), 'utf8')).version)
  .usage('[options]')
  .option('-p, --port <number>', 'port to use (default: 8080)')
  .option('-f, --folder <path>', 'root path (default: dev)')
  .option('-s, --static <path>', 'exports a static version (for ghpages)')
  .option('-e, --extensions <list>', 'extensions to match (default: js,coffee)', list)
  .option('-t, --test', 'runs karma on the folder')
  .option('-w, --watch', 'only with --test, runs karma in watch mode')
  .option('--browsers <list>', 'only with --test, sets browsers', list)
  .parse(process.argv)
require("./lib/index.js")(program)
