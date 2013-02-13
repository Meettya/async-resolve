  var Enh_Resolver, My_Resolver, compare, count, my_resolver, options, _;

  _ = require('lodash');

  My_Resolver = require("../lib/resolver");

  options = {
    extensions: ['.js', '.coffee', '.eco'],
    modules: 'node_modules'
  };

  my_resolver = new My_Resolver(options);

  Enh_Resolver = require('enhanced-resolve');

  count = 150;

  compare = {
    My_Resolver: function(done) {
      var i, test_done, _i;
      test_done = _.after(count, done());
      for (i = _i = 0; _i < count; i = _i += 1) {
        my_resolver.resolve('coffee-script', __dirname, function(err, filename) {
          return test_done;
        });
        null;
      }
      return null;
    },
    Enh_Resolver: function(done) {
      var i, test_done, _i;
      test_done = _.after(count, done());
      for (i = _i = 0; _i < count; i = _i += 1) {
        Enh_Resolver(__dirname, 'coffee-script', function(err, filename) {
          return test_done;
        });
        null;
      }
      return null;
    }
  };

  module.exports = {
    compare: compare,
    countPerLap: count
  };