  var AsyncResolve, assert, async_resolver, compare, count, enhanced_resolver, expected, localizer, localizer_resolver, node_resolve, options, _;

  _ = require('lodash');

  assert = require('assert');

  expected = '/Users/meettya/github/async-resolve/node_modules/coffee-script/lib/coffee-script/coffee-script.js';

  AsyncResolve = require("../lib/resolver");

  options = {
    extensions: ['.js', '.coffee', '.eco'],
    modules: 'node_modules'
  };

  async_resolver = new AsyncResolve(options);

  enhanced_resolver = require('enhanced-resolve');

  localizer = require('localizer');

  localizer_resolver = localizer();

  node_resolve = require('resolve');

  count = 100;

  compare = {
    'async-resolve': function(done) {
      var i, test_done, _i;

      test_done = _.after(count, done);
      for (i = _i = 0; _i < count; i = _i += 1) {
        async_resolver.resolve('coffee-script', __dirname, function(err, filename) {
          return test_done();
        });
        null;
      }
      return null;
    },
    'enhanced-resolve': function(done) {
      var i, test_done, _i;

      test_done = _.after(count, done);
      for (i = _i = 0; _i < count; i = _i += 1) {
        enhanced_resolver(__dirname, 'coffee-script', function(err, filename) {
          return test_done();
        });
        null;
      }
      return null;
    },
    'localizer': function(done) {
      var i, test_done, _i;

      test_done = _.after(count, done);
      for (i = _i = 0; _i < count; i = _i += 1) {
        localizer_resolver(__dirname, 'coffee-script', function(err, filename) {
          return test_done();
        });
        null;
      }
      return null;
    },
    'node-resolve *async*': function(done) {
      var i, test_done, _i;

      test_done = _.after(count, done);
      for (i = _i = 0; _i < count; i = _i += 1) {
        node_resolve('coffee-script', {
          basedir: __dirname
        }, function(err, filename) {
          // this fail
          // assert.strictEqual(filename, expected, 'filename not resolved');
          return test_done();
        });
        null;
      }
      return null;
    },
    'node-resolve *sync*': function(done) {
      var i, _i;

      for (i = _i = 0; _i < count; i = _i += 1) {
        filename = node_resolve.sync('coffee-script');
        // this will pass
        // assert.strictEqual(filename, expected, 'filename not resolved');        
        null;
      }
      return done();
    }
  };

  module.exports = {
    compare: compare,
    countPerLap: count
  };

  require("bench").runMain();
