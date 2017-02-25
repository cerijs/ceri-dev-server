# out: ../lib/routes-loader.coffee
fs = require "fs"
path = require "path"
fstools = require "./fstools"
loaderUtils = require "loader-utils"

module.exports = (source, map) ->
  options = loaderUtils.getOptions(@)
  
  getStructure = (currentPath) ->
    entries = fs.readdirSync(currentPath)
    structure = {name: path.basename(currentPath),folders: [],components: []}
    for entry in entries
      entryPath = path.resolve(currentPath,entry)
      if fstools.isDirectory(entryPath)
        folder = getStructure(entryPath)
        if folder.components.length > 0 or folder.folders.length > 0
          structure.folders.push folder
      else
        ext = path.extname(entry)
        for target in options.extensions
          if ext == "."+target
            structure.components.push name:path.basename(entry,ext), path: entryPath, ext: ext
    return structure

  structureToRoutes = (structure,rootpath="") ->
    routes = ""
    for folder in structure.folders
      routes += structureToRoutes(folder,rootpath+"/"+folder.name)
    for comp in structure.components
      routeName = rootpath.replace(path.sep,"/")+"/"+comp.name
      routePath = comp.path.replace(/\\/g,"\\\\")
      routes += "  \"#{routeName}\": require(\"#{routePath}\"),\n"
    return routes


  structure = getStructure(options.workingDir)
  routes = structureToRoutes(structure)
  routes = "routes = {\n#{routes}\n};"
  cb = @async?() || @callback
  cb(null,source.replace(/getRoutes\(\);/g,routes),map)

  