ceri = require "ceri/lib/wrapper"
module.exports = (obj) ->
  obj.mixins ?= []
  obj.mixins.push require("ce/structure")
  obj.mixins.push require("ce/tests")
  return ceri(obj)