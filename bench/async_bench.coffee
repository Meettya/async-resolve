###
Try out async_bench
###

ben = require 'ben'

My_Resolver = require "../lib/resolver"

options =
  extensions : [ '.js', '.coffee', '.eco' ]
  modules : 'node_modules'

my_resolver = new My_Resolver options

Enh_Resolver = require 'enhanced-resolve'

my_resolver_fn = (done) ->
  my_resolver.resolve 'coffee-script', __dirname, ->
    done()

enhanced_resolver_fn = (done) ->
  Enh_Resolver __dirname, 'coffee-script', ->
    done()

###

ben.async 50, my_resolver_fn, (ms) ->
    console.log "async-resolve: #{ms} milliseconds per iteration"
###

ben.async 50, enhanced_resolver_fn, (ms) ->
    console.log "enhanced-resolve: #{ms} milliseconds per iteration"

###