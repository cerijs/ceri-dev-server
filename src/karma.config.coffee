path = require "path"
webpack = require "webpack"
module.exports = (config) ->
  config.set
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
