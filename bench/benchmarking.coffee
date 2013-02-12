###
Try to use simple benchmarking
###

Benchmark = require 'benchmark'

My_Resolver = require "../lib/resolver"

options =
  extensions : [ '.js', '.coffee', '.eco' ]
  modules : 'node_modules'

my_resolver = new My_Resolver options


Enh_Resolver = require 'enhanced-resolve'

###
now test star
###

suite = new Benchmark.Suite

suite.add 'enhanced-resolve', ->
  Enh_Resolver __dirname, 'coffee-script', ->

suite.add 'async-resolve', ->
  my_resolver.resolve 'coffee-script', __dirname, ->

suite.on 'cycle', (event) ->
  console.log "#{event.target}"

suite.on 'complete', ->
  console.log "Fastest is |#{@filter('fastest').pluck 'name'}|"

suite.run async : on