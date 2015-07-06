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

AsyncCache      = require 'async-cache'
CoreModulesList = require './core_list'


module.exports = class Resolver

  # speed up searching
  CORE_MODULES = _.reduce CoreModulesList, ( (memo, val) -> memo[val] = true; memo ), {}

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

    @_node_modules_dirname_ = @_options_.modules ? 'node_modules'

    # TODO add ensure and test func. both
    @_known_ext_ = @_options_.extensions ? ['.js', '.json', '.node']
    @_dir_load_steps_ = ['package.json'].concat @_buildDirLoadSteps @_known_ext_

    @_fs_ = 
      stat      : @_buildCachedFunction 'fs.stat'
      readdir   : @_buildCachedFunction 'fs.readdir'
      exists    : @_buildCachedFunction 'fs.exists'
      readFile  : @_buildCachedFunction 'fs.readFile'

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
    res_cb = @_buldResultCallback path_name, basedir, main_cb

    # than go to async hell
    # decide on first symbol must be safe (not sure about Win, but WTF? )
    switch path_name.charAt 0
      when '.', path.sep 
        @_debug 'This is file or directory', path_name
        @_processFileOrDirectory path_name, basedir, res_cb
      else 
        @_debug 'This is module', path_name
        @_processModule path_name, basedir, res_cb

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
  This method chech is filename is core module
  ###
  isCoreModule : (filename) ->
    CORE_MODULES[filename]?

  ###
  This internal method create res_cb - result callback
  its wrapper form main_cb with some checker, bulded as event emmiter substitutor
  to fix bug - events are global and shared to all async execution, 
  and, yes, its case some numbers returns
  ###
  _buldResultCallback : (path_name, basedir, main_cb) =>

    (event_name, in_data) =>
      switch event_name
        when MODULE_FOUND
          @_debug 'MODULE_FOUND FROM EVENT'
          main_cb null, in_data
        when MODULE_NOT_FOUND
          @_debug 'MODULE_NOT_FOUND FROM EVENT'
          err = new Error "Cannot find module |#{path_name}| at basedir |#{basedir}|"
          err.code = 'MODULE_NOT_FOUND'
          main_cb err
        when ERROR
          main_cb new Error in_data
        else
          @_debug "WTF!!?? unknow event #{event_name}"
          main_cb new Error "can`t do |#{event_name}|"

  ###
  This method buld cached function
  ###
  _buildCachedFunction : (function_name) ->
    # yap, magic here
    max = if function_name is 'fs.readFile' then 100 else 1000
    maxAge = 1000 * 5
    load = switch function_name
      when 'fs.stat'      then (key, cb) -> fs.stat     key, cb
      when 'fs.readdir'   then (key, cb) -> fs.readdir  key, cb
      when 'fs.exists'    then (key, cb) -> fs.exists   key, cb
      when 'fs.readFile'  then (key, cb) -> fs.readFile key, cb
      else
        throw Error "WTF!!?? unknow cached function name #{function_name}"
    
    new AsyncCache {max, maxAge, load}
          
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
  _processModule : (path_name, basedir, res_cb) ->
    # at first make sure it is not core modules
    if @isCoreModule path_name
      return res_cb MODULE_FOUND, path_name

    # or search in any 'node_modules' dirs
    detector = (val, cb) =>
      test_path = path.resolve val, path_name
      @_fs_.exists.get test_path, (res) -> cb res

    detect_series = (int_res_cb, try_path, other_paths...) =>
      unless try_path
        return int_res_cb MODULE_NOT_FOUND

      detector try_path, (is_exist) =>
        if is_exist
          @_processFileOrDirectory path_name, try_path, int_res_cb
        else
          detect_series int_res_cb, other_paths...

    detect_series res_cb, @_buildNodeModulesPathes(basedir)...

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
  _processFileOrDirectory : (path_name, basedir, res_cb) ->
    path_name = path.resolve basedir, path_name
    
    path_prefix = path.dirname path_name
    path_suffix = path.basename path_name

    # find out our paths to find out something
    @_processPath path_prefix, path_suffix, res_cb, (filtered) =>
      @_debug '_processFileOrDirectory filtered', filtered

      switch filtered.length
        when 0 
          @_debug 'Not found'
          res_cb MODULE_NOT_FOUND
        when 1  
          @_debug 'find one'
          @_processGodsend path.resolve(path_prefix, filtered[0]), res_cb
        else
          @_debug 'find some files, resolve by extension order', filtered
          first_filtered = @_resolveFileByExtentionOrder filtered
          @_processGodsend path.resolve(path_prefix, first_filtered), res_cb
        
  ###
  This method look closer to our godsend and find out what is it really
  ###
  _processGodsend : (thing_path, res_cb) ->
    @_fs_.stat.get thing_path, (err, stat_obj) =>
      return res_cb ERROR, err if err

      if stat_obj.isFile()
        @_debug 'WAY!!! its file!!!'
        res_cb MODULE_FOUND, thing_path
      else if stat_obj.isDirectory()
        @_debug 'HM, big directory, not bad :)'
        @_processDirectory thing_path, res_cb
      else 
        @_debug 'WTF?? Cant process it, sorry'
        res_cb MODULE_NOT_FOUND

  ###
  This method process directory as node.js resolve
  ###
  _processDirectory : (dir_path, res_cb) ->
    @_fs_.readdir.get dir_path, (err, dir) =>
      return res_cb ERROR, err if err

      # yes, steps first, to save order and work with first element
      filtered = @_multiGrep @_dir_load_steps_, dir
      @_debug '_processDirectory filtered', filtered

      switch file_name = filtered[0]
        when undefined
          @_debug 'Nothing finded, not a module'
          res_cb MODULE_NOT_FOUND
        when 'package.json'
          @_debug 'this is |package.json|'
          @_tryProcessJSON dir_path, file_name, filtered[1..], res_cb    
        else
          @_debug 'just return file', path.resolve dir_path, file_name
          res_cb MODULE_FOUND, path.resolve dir_path, file_name   

  ###
  This method load and parse JSON for 'main' part
  while package.json may be invalid or main is missing 
  - some boilerplate code needed 
  ###
  _tryProcessJSON : (dir_path, file_name, other_file_names, res_cb) ->

    json_path = path.resolve dir_path, file_name

    @_fs_.readFile.get json_path, (err, data) =>
      return res_cb ERROR, err if err

      json = null
      try 
        json = JSON.parse data
      catch err
        return res_cb ERROR, err
    
      if main_path = json?.main
        # now resolve main from json
        @_processFileOrDirectory main_path, path.dirname(json_path), res_cb
      else if other_file_names.length
        @_debug 'package.json missed |main|, return ', path.resolve dir_path, other_file_names[0]
        res_cb MODULE_FOUND, path.resolve dir_path, other_file_names[0]        
      else
        @_debug 'package.json missed |main| and no index.* founded'
        res_cb ERROR, "broken module: no main in |#{json_path}|, nor index.* files in |#{dir_path}|"

  ###
  This method process path to find something in path
  ###
  # TODO! cache it and, yes, cache invalidation logic too :(
  _processPath : (path_prefix, path_suffix, res_cb, cb) ->
    @_debug '_processPath', path_prefix, path_suffix
    patterns = _.map @_known_ext_, (ext) -> "#{path_suffix}#{ext}"

    @_fs_.readdir.get path_prefix, (err, dir) =>
      return res_cb ERROR, err if err

      cb @_multiGrep dir, [path_suffix].concat patterns

  ###
  This method was multi-grep - filter all values, matched by any pattern
  ###
  _multiGrep : (values, patterns) ->
    _.filter values, (val) ->
      _.any patterns, (patt) -> 
        val is patt
