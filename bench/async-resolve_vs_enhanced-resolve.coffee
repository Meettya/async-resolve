###
run many times so that we can abstract out the overhead of promise creation.
###

_ = require 'lodash'

My_Resolver = require "../lib/resolver"

options =
  extensions : [ '.js', '.coffee', '.eco' ]
  modules : 'node_modules'

my_resolver = new My_Resolver options

Enh_Resolver = require 'enhanced-resolve'

count = 100

compare = 

  My_Resolver : (done) ->
    test_done = _.after count, done()
    for i in [0...count] by 1
      my_resolver.resolve 'coffee-script', __dirname, (err, filename) ->
        test_done
      null
    null

  Enh_Resolver : (done) ->
    test_done = _.after count, done()
    for i in [0...count] by 1
      Enh_Resolver __dirname, 'coffee-script', (err, filename) ->
        test_done
      null
    null


module.exports = {compare, countPerLap : count }