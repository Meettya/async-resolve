  var My_Resolver, my_resolver, options, path;


  path = require('path');

  My_Resolver = require("../lib/resolver");

  options = {
    extensions: ['.js', '.coffee', '.eco'],
    modules: 'node_modules'
  };

  my_resolver = new My_Resolver(options);

  my_resolver.resolve('coffee-script', __dirname, function(err, filename) {
    console.log(err);
    return console.log(filename);
  });

  /*
  Enh_Resolver = require 'enhanced-resolve'
  
  Enh_Resolver __dirname, 'coffee-script', (err, filename) ->
    console.log err
    console.log 'enh', filename
  */
