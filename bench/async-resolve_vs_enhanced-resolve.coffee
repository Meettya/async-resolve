###
run many times so that we can abstract out the overhead of promise creation.
###

My_Resolver = require "../lib/resolver"

options =
  extensions : [ '.js', '.coffee', '.eco' ]
  modules : 'node_modules'

my_resolver = new My_Resolver options

Enh_Resolver = require 'enhanced-resolve'

count = 50

my_resolver_rec = (i, done) ->
  if ( i += 1) > count
    done()
  else
    my_resolver.resolve 'coffee-script', __dirname, (err, filename) ->
      my_resolver_rec i, done

Enh_Resolver_rec = (i, done) ->
  if ( i += 1) > count
    done()
  else
    Enh_Resolver __dirname, 'coffee-script', (err, filename) ->
      Enh_Resolver_rec i, done

compare = 

  My_Resolver : (done) ->
    my_resolver_rec 0, done

  Enh_Resolver : (done) ->
    Enh_Resolver_rec 0, done


module.exports = {compare, countPerLap : count }