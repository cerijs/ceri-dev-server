path = require "path"
webpack = require "webpack"
module.exports = (config) ->
  config.set
    frameworks: ["mocha","chai-dom","sinon-chai","ceri"]
    plugins: [
      require("karma-sinon-chai")
      require("karma-chai-dom")
      require("karma-chrome-launcher")
      require("karma-firefox-launcher")
      require("karma-mocha")
      require("karma-webpack")
      require("karma-ceri")
      require("karma-sourcemap-loader")
    ]
    browsers: ["Chromium","Firefox"]
