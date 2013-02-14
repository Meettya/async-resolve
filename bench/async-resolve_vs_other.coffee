###
run many times so that we can abstract out the overhead of promise creation.
###

_ = require 'lodash'

AsyncResolve = require "../lib/resolver"
options =
  extensions : [ '.js', '.coffee', '.eco' ]
  modules : 'node_modules'
async_resolver = new AsyncResolve options

enhanced_resolver = require 'enhanced-resolve'

localizer = require 'localizer'
localizer_resolver = localizer()

node_resolve = require 'resolve'

count = 100

compare = 

  'async-resolve' : (done) ->
    test_done = _.after count, done()
    for i in [0...count] by 1
      async_resolver.resolve 'coffee-script', __dirname, (err, filename) ->
        test_done
      null
    null

  'enhanced-resolve' : (done) ->
    test_done = _.after count, done()
    for i in [0...count] by 1
      enhanced_resolver __dirname, 'coffee-script', (err, filename) ->
        test_done
      null
    null

  'localizer' : (done) ->
    test_done = _.after count, done()
    for i in [0...count] by 1
      localizer_resolver __dirname, 'coffee-script', (err, filename) ->
        test_done
      null
    null

  'node-resolve *sync*' : (done) ->
    for i in [0...count] by 1
      node_resolve.sync 'coffee-script'
      null
    done()

module.exports = {compare, countPerLap : count }