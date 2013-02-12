#!/usr/bin/env coffee

path = require 'path'

My_Resolver = require "../src/resolver"

options =
  extensions : [ '.js', '.coffee', '.eco' ]
  modules : 'node_modules'

my_resolver = new My_Resolver options


my_resolver.resolve 'coffee-script', __dirname, (err, filename) ->
  console.log err
  console.log filename

###
Enh_Resolver = require 'enhanced-resolve'

Enh_Resolver __dirname, 'coffee-script', (err, filename) ->
  console.log err
  console.log 'enh', filename

###