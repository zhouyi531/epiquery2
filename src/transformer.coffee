fs     = require 'fs'
config = require './config.coffee'
log    = require 'simplog'
path   = require 'path'

loadedTransforms = {}

# given the name of a response transformation (file name), load it from the 
# proper location
getRequestedTransform = (transformName, cb) ->
  # if the requestor asks for a tranform, we'll go ahead and load it
  if transformName
    log.debug "loading requested response transform: #{transformName}"
    try
      # calculate the path for the transform location, so that we can 
      # clear the cache, templates are loaded on each execution so the expectation
      # will be the same for the transforms
      transformPath = path.join(config.responseTransformDirectory, transformName)
      log.debug "full path to transform: #{transformPath}"
      cb(null, require(transformPath))
      loadedTransforms[transformPath] = transformPath
      return true
    catch e
      log.error "error loading transform: #{transformName}\n #{e}"
      cb(new Error("failed to load transform #{transformName}"))
      return false

clearCache = () ->
  log.info "clearing response transformation cache"
  removeCacheEntry = (transformPath) ->
    log.debug "removing transformation #{transformPath} from cache"
    delete(require.cache[transformPath])
  removeCacheEntry(transformPath) for own transformPath, _ of loadedTransforms
  loadedTransforms = {}

initialize = () ->
  clearCache()

module.exports.getRequestedTransform = getRequestedTransform
module.exports.init = initialize