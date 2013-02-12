  var Enh_Resolver, Enh_Resolver_rec, My_Resolver, compare, count, my_resolver, my_resolver_rec, options;

  My_Resolver = require("../lib/resolver");

  options = {
    extensions: ['.js', '.coffee', '.eco'],
    modules: 'node_modules'
  };

  my_resolver = new My_Resolver(options);

  Enh_Resolver = require('enhanced-resolve');

  count = 50;

  my_resolver_rec = function(i, done) {
    if ((i += 1) > count) {
      return done();
    } else {
      return my_resolver.resolve('coffee-script', __dirname, function(err, filename) {
        return my_resolver_rec(i, done);
      });
    }
  };

  Enh_Resolver_rec = function(i, done) {
    if ((i += 1) > count) {
      return done();
    } else {
      return Enh_Resolver(__dirname, 'coffee-script', function(err, filename) {
        return Enh_Resolver_rec(i, done);
      });
    }
  };

  compare = {
    My_Resolver: function(done) {
      return my_resolver_rec(0, done);
    },
    Enh_Resolver: function(done) {
      return Enh_Resolver_rec(0, done);
    }
  };

  module.exports = {
    compare: compare,
    countPerLap: count
  };