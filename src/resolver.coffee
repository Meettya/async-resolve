###
This class implement node.js require.resolve() behavior, with some enhancements:
  - resolve by given 'basedir'
  - do it async (really async, no one sync function used)

Also it support additional extensions (may be set in constructor).

May be used as successor of https://github.com/substack/node-resolve.
Not drop-in, but mostly worked with some changes
###

fs      = require 'fs'
path    = require 'path'
_       = require 'lodash'
async   = require 'async'

# to reduce async logic 
{ EventEmitter } = require 'events'

class Resolver

  # move it out to config file, may be - think about it
  # taken from `ls -1 lib` from https://github.com/joyent/node at commit bda45a8be1e80bb79343db019e450c1ded2382eb
  CORE_MODULES_LIST = [
    '_debugger'
    '_linklist'
    '_stream_duplex'
    '_stream_passthrough'
    '_stream_readable'
    '_stream_transform'
    '_stream_writable'
    'assert'
    'buffer'
    'child_process'
    'cluster'
    'console'
    'constants'
    'crypto'
    'dgram'
    'dns'
    'domain'
    'events'
    'freelist'
    'fs'
    'http'
    'https'
    'module'
    'net'
    'os'
    'path'
    'punycode'
    'querystring'
    'readline'
    'repl'
    'stream'
    'string_decoder'
    'sys'
    'timers'
    'tls'
    'tty'
    'url'
    'util'
    'vm'
    'zlib'
  ]

  # speed up searching
  CORE_MODULES = _.reduce CORE_MODULES_LIST, ( (memo, val) -> memo[val] = true; memo ), {}

  # events names convention
  MODULE_FOUND      = 'module.found'
  MODULE_NOT_FOUND  = 'module.not_found'
  ERROR             = 'error'

  ###
  May used with options, default are:

  options =
    log : off
    extensions  : ['.js', '.json', '.node']

  as base I use settings from https://github.com/substack/node-resolve
  ###
  constructor: (@_options_={}) ->
    # for debugging 
    @_do_logging_ = if @_options_.log? and @_options_.log is on and console?.log? then yes else no

    @_event_bus_ = new EventEmitter()

    @_node_modules_dirname_ = @_options_.modules ? 'node_modules'

    # TODO add ensure and test func. both
    @_known_ext_ = @_options_.extensions ? ['.js', '.json', '.node']
    @_dir_load_steps_ = ['package.json'].concat @_buildDirLoadSteps @_known_ext_

  ###
  Alias to resolveAbsolutePath()
  ###
  resolve : (args...) ->
    @resolveAbsolutePath args...

  ###
  This method create absolute path for file loader
  ###
  resolveAbsolutePath : (path_name, basedir, main_cb) ->
 
    # at first add our event listeners
    @_prepareEventsListeners path_name, basedir, main_cb

    # than go to async hell
    # decide on first symbol must be safe (not sure about Win, but WTF? )
    switch path_name.charAt 0
      when '.', path.sep 
        @_debug 'This is file or directory', path_name
        @_processFileOrDirectory path_name, basedir
      else 
        @_debug 'This is module', path_name
        @_processModule path_name, basedir

  ###
  This method will used to add extensions, keep based untouched
  ###
  addExtensions : (extensions...) ->
    @_known_ext_ = @_known_ext_.concat extensions
    @_dir_load_steps_ = @_dir_load_steps_.concat @_buildDirLoadSteps extensions

  ###
  This method get internal state, may be used in tests and debug
  ###
  getState : ->
    log : @_do_logging_
    extensions  : @_known_ext_
    dir_load_steps : @_dir_load_steps_
    modules :  @_node_modules_dirname_

  ###
  This module prepare EventBus for results
  ###
  _prepareEventsListeners : (path_name, basedir, main_cb) ->

    @_event_bus_.on MODULE_FOUND, (file_name) => 
      @_debug 'MODULE_FOUND FROM EVENT'
      main_cb null, file_name

    @_event_bus_.on MODULE_NOT_FOUND, =>
      @_debug 'MODULE_NOT_FOUND FROM EVENT'
      err = new Error "Cannot find module |#{path_name}| at basedir |#{basedir}|"
      err.code = 'MODULE_NOT_FOUND'
      main_cb err  

    @_event_bus_.on ERROR, (message) =>
      main_cb new Error message  

  ###
  This internal method create directory resolution patterns in correct steps
  ###
  _buildDirLoadSteps : (extensions) ->
    _.map extensions, (val) -> "index#{val}"

  ###
  Short-cut debugging
  ###
  _debug : (args...) ->
    if @_do_logging_ then console.log args...
    null

  ###
  This method process module
  ###
  _processModule : (path_name, basedir) ->
    # at first make sure it is not core modules
    if CORE_MODULES[path_name]
      return @_event_bus_.emit MODULE_FOUND, path_name

    # or search in any 'node_modules' dirs
    detector = (val, cb) ->
      test_path = path.resolve val, path_name
      fs.exists test_path, (res) -> cb res

    async.detect @_buildNodeModulesPathes(basedir), detector, (detected_path) =>
      @_processFileOrDirectory path_name, detected_path

  ###
  Build all possible node_modules dirs for selected dir
  code was adapted from node\lib\module.js
  ###
  _buildNodeModulesPathes : (from) ->
    parts = from.split path.sep

    all_paths = for tip, idx in parts when tip isnt @_node_modules_dirname_
      path.join path.sep, parts.slice(0, idx + 1)..., @_node_modules_dirname_

    all_paths.reverse()

  ###
  This internal method resolve situation if more than one file was defined in directory
  In this case resolution will be based on extension order
  ###
  _resolveFileByExtentionOrder : (files) ->
    for ext in @_known_ext_
      return res if ( res = _.find files, (val) ->
        ext is path.extname val )

  ###
  This method process file or directory
  ###
  _processFileOrDirectory : (path_name, basedir) ->
    path_name = path.resolve basedir, path_name
    
    path_prefix = path.dirname path_name
    path_suffix = path.basename path_name

    # find out our paths to find out something
    @_processPath path_prefix, path_suffix, (filtered) =>
      @_debug '_processFileOrDirectory filtered', filtered

      switch filtered.length
        when 0 
          @_debug 'Not found'
          @_event_bus_.emit MODULE_NOT_FOUND
        when 1  
          @_debug 'find one'
          @_processGodsend path.resolve path_prefix, filtered[0]
        else
          @_debug 'find some files, resolve by extension order', filtered
          first_filtered = @_resolveFileByExtentionOrder filtered
          @_processGodsend path.resolve path_prefix, first_filtered
        
  ###
  This method look closer to our godsend and find out what is it really
  ###
  _processGodsend : (thing_path) ->
    fs.stat thing_path, (err, stat_obj) =>
      return @_event_bus_.emit ERROR, err if err

      if stat_obj.isFile()
        @_debug 'WAY!!! its file!!!'
        @_event_bus_.emit MODULE_FOUND, thing_path
      else if stat_obj.isDirectory()
        @_debug 'HM, big directory, not bad :)'
        @_processDirectory thing_path
      else 
        @_debug 'WTF?? Cant process it, sorry'
        @_event_bus_.emit MODULE_NOT_FOUND

  ###
  This method process directory as node.js resolve
  ###
  _processDirectory : (dir_path) ->
    fs.readdir dir_path, (err, dir) =>
      return @_event_bus_.emit ERROR, err if err

      # yes, steps first, to save order and work with first element
      filtered = @_multiGrep @_dir_load_steps_, dir
      @_debug '_processDirectory filtered', filtered

      switch file_name = filtered[0]
        when undefined
          @_debug 'Nothing finded, not a module'
          @_event_bus_.emit MODULE_NOT_FOUND
        when 'package.json'
          @_debug 'this is |package.json|'
          @_tryProcessJSON dir_path, file_name, filtered[1..]      
        else
          @_debug 'just return file', path.resolve dir_path, file_name
          @_event_bus_.emit MODULE_FOUND, path.resolve dir_path, file_name   

  ###
  This method load and parse JSON for 'main' part
  while package.json may be invalid or main is missing 
  - some boilerplate code needed 
  ###
  _tryProcessJSON : (dir_path, file_name, other_file_names) ->

    json_path = path.resolve dir_path, file_name

    fs.readFile json_path, (err, data) =>
      return @_event_bus_.emit ERROR, err if err

      json = null
      try 
        json = JSON.parse data
      catch err
        return @_event_bus_.emit ERROR, err
    
      if main_path = json?.main
        # now resolve main from json
        @_processFileOrDirectory main_path, path.dirname json_path
      else if other_file_names.length
        @_debug 'package.json missed |main|, return ', path.resolve dir_path, other_file_names[0]
        @_event_bus_.emit MODULE_FOUND, path.resolve dir_path, other_file_names[0]        
      else
        @_debug 'package.json missed |main| and no index.* founded'
        @_event_bus_.emit ERROR, "broken module: no main in |#{json_path}|, nor index.* files in |#{dir_path}|"

  ###
  This method process path to find something in path
  ###
  # TODO! cache it and, yes, cache invalidation logic too :(
  _processPath : (path_prefix, path_suffix, cb) ->
    @_debug '_processPath', path_prefix, path_suffix
    patterns = _.map @_known_ext_, (ext) -> "#{path_suffix}#{ext}"

    fs.readdir path_prefix, (err, dir) =>
      return @_event_bus_.emit ERROR, err if err

      cb @_multiGrep dir, [path_suffix].concat patterns

  ###
  This method was multi-grep - filter all values, matched by any pattern
  ###
  _multiGrep : (values, patterns) ->
    _.filter values, (val) ->
      _.any patterns, (patt) -> 
        val is patt


module.exports = Resolver

