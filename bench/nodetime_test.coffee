###
try to use nodetime
###

require('nodetime').profile()

My_Resolver = require "../lib/resolver"

options =
  extensions : [ '.js', '.coffee', '.eco' ]
  modules : 'node_modules'

my_resolver = new My_Resolver options

count = 50

my_resolver_rec = (i, res) ->
  if ( i += 1) > count
    res.writeHead 200, 'Content-Type': 'text/plain'
    res.end "done\n"
  else
    my_resolver.resolve 'coffee-script', __dirname, (err, filename) ->
      my_resolver_rec i, res


http = require 'http'

server = http.createServer (req, res) ->

  my_resolver_rec 0, res

server.listen 8080, '127.0.0.1'

console.log '[%s] Server running at http://127.0.0.1:8080/', process.pid