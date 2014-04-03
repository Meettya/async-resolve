[![Build Status](https://secure.travis-ci.org/Meettya/async-resolve.png)](http://travis-ci.org/Meettya/async-resolve)
[![Dependency Status](https://gemnasium.com/Meettya/async-resolve.svg)](https://gemnasium.com/Meettya/async-resolve)



# async-resolve

This module a fastest async and configurable `requre.resolve()` implementation.

## Installation

```bash
$ npm install async-resolve
```

## Usage

Resolve absolute path for given [file|directory|module] in given basedir in asynchronous manner.

```javascript
var Resolver = require('async-resolve');
var resolver_obj = new Resolver();
resolver_obj.resolve('module', __dirname, function(err, filename) {
  return console.log(filename);
});
```

## Methods

```javascript
var Resolver = require('async-resolve');
```

### new Resolver(opts)

The resolver object may be configured on creation time:

```javascript
options = {
  // default: ['.js', '.json', '.node'] - specify allowed filetypes, note that the
  // order matters. in this example index.js is prioritized over index.coffee
  extensions: ['.js', '.coffee', '.eco'],
  // default : false - make searching verbose for debug and tests
  log: true
  // default : 'node_modules' - its 'node_modules' directory names, may be changed
  modules : 'other_modules'
};
resolver_obj = new Resolver(options);
```

### resolve(pkg, basedir, cb)

Resolve `pkg` in `basedir` on node.js-based [algorithm](http://nodejs.org/api/modules.html#modules_all_together) 

```javascript
resolver_obj.resolve('module', __dirname, function(err, filename) {
  return console.log(filename);
});
```

### addExtensions(exts)

also resolver object may be configured after creation:

```javascript
resolver_obj.addExtensions('.jade');
```

### getState()

All options may be inspected (for testing and debug):

```javascript
resolver_obj.getState();
/*
{
  log: true,
  modules : 'other_modules',
  extensions: [ '.js', '.coffee', '.eco', '.jade' ],
  dir_load_steps: [
   'package.json',
   'index.js',
   'index.coffee',
   'index.eco',
   'index.jade' 
   ] 
}
*/
```

### isCoreModule()

Return `true` if filename is node.js core module or `false` otherwise.

```javascript
resolver_obj.isCoreModule('util'); // -> true
```
This method use internal module names table for fast lookup, not IO.

## Similar modules

* [resolve](https://github.com/substack/node-resolve)
* [resolveIt](https://github.com/jhamlet/node-resolveit)
* [enhanced-resolve](https://github.com/webpack/enhanced-resolve)
* [localizer](https://github.com/AndreasMadsen/localizer)

## Test

```bash
$ cake test
```

## Benchmark

In short `async-resolve` 2.4 times as fast as `enhanced-resolve`.

My benchmark [results](https://github.com/Meettya/async-resolve/blob/master/Benchmarking.md).

Build you own in 2 steps:

1. do  `$ npm install` at root module folder
3. run `$ coffee ./bench/async-resolve_vs_other.coffee` from root module folder

## License

Copyright (c) 2013 Dmitrii Karpich

MIT (https://raw.github.com/Meettya/async-resolve/master/LICENSE)

