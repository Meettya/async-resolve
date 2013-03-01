###
Test suite for node AND browser in one file
So, we are need some data from global
Its so wrong, but its OK for test
###
# resolve require from [window] or by require() 
_ = @_ ? require 'lodash'

async = require 'async'

path  = require 'path'
fs    = require 'fs'

lib_path = GLOBAL?.lib_path || ''

Resolver = require "#{lib_path}resolver"

fixtureRoot  = path.join __dirname, "fixtures"
fixtures     = path.join fixtureRoot, "default"

project_root = path.join __dirname, '..'

fixturesResolver = path.join fixtureRoot, 'resolver'


examples = [

  {   #0
    path_name : './substractor'
    parent : fixtures
    file_name : path.join fixtures, 'substractor.js'
  },
  {   #1
    path_name : 'summator'
    parent : path.join fixtureRoot, 'other_modules'
    file_name : path.join fixtureRoot, 'other_modules/summator/lib/summator.coffee'
  },
  {   #2
    path_name : './summator'
    parent : path.join fixtureRoot, 'other_modules'
    file_name : path.join fixtureRoot, 'other_modules/summator/lib/summator.coffee'  
  },
  {   #3
    path_name : './'
    parent : fixtures
    file_name : path.join fixtures, 'index.coffee'
  },
  {   #4
    path_name : 'mocha'
    parent : fixtures
    file_name : path.join project_root, 'node_modules/mocha/index.js'
  },
  {   #5
    path_name : 'path'
    parent : fixtures
    file_name : 'path'
  },
  {   #6
    path_name : './two_children'
    parent : fixtureRoot
    file_name : path.join fixtureRoot, 'two_children/index.coffee'
  },
  {   #7
    path_name : './sub_dir'
    parent : fixtures
    file_name : path.join fixtures, 'sub_dir/multiplier.coffee'
  },
]

#TODO! also need web_modules substitution
# hm... may be in another module and this is classical node.js resolver ?
# and add 'MODULE_NOT_FOUND' error, as node.js do it

describe 'Resolver:', ->

  pf_obj = null

  options =
    extensions : [ '.js', '.coffee', '.eco' ]
    modules : 'other_modules'
    #log : on

  beforeEach ->
    pf_obj = new Resolver options
 

  describe 'addExtensions()', ->

    it 'should add some new extensions to settings, keep previously seated', ->
      pf_obj.addExtensions '.jade'

      state = 
        log: off
        extensions: [ '.js', '.coffee', '.eco', '.jade' ]
        modules : 'other_modules'
        dir_load_steps: [
         'package.json',
         'index.js',
         'index.coffee',
         'index.eco',
         'index.jade' 
         ] 

      pf_obj.getState().should.to.be.eql state

  describe 'resolve() is aslias for resolveAbsolutePath()', ->

    it 'should work as resolveAbsolutePath()', (done) ->
      res_fn = (err, file_name) ->
        expect(err).to.be.null
        #console.log 'err ', err
        #console.log 'file_name ', file_name
        
        file_name.should.to.be.eql examples[2].file_name
        done()

      pf_obj.resolve examples[2].path_name, examples[2].parent, res_fn


  describe 'resolveAbsolutePath() *async*', ->

    it 'should find file with absolute path and parent "." (here) ', (done) ->
      res_fn = (err, file_name) ->
        expect(err).to.be.null
        #console.log 'err ', err
        #console.log 'file_name ', file_name
        file_name.should.to.be.eql examples[0].file_name
        done()

      pf_obj.resolveAbsolutePath examples[0].file_name, '.', res_fn

    it 'should find file with relative path and parent ', (done) ->
      res_fn = (err, file_name) ->
        expect(err).to.be.null
        #console.log 'err ', err
        #console.log 'file_name ', file_name
        file_name.should.to.be.eql examples[0].file_name
        done()

      pf_obj.resolveAbsolutePath examples[0].path_name, examples[0].parent, res_fn

    it 'should find directory with module name and parent (package.json)', (done) ->
      res_fn = (err, file_name) ->
        expect(err).to.be.null
        #console.log 'err ', err
        #console.log 'file_name ', file_name
        
        file_name.should.to.be.eql examples[1].file_name
        done()

      pf_obj.resolveAbsolutePath examples[1].path_name, examples[1].parent, res_fn

    it 'should find directory with relative path and parent (package.json)', (done) ->
      res_fn = (err, file_name) ->
        expect(err).to.be.null
        #console.log 'err ', err
        #console.log 'file_name ', file_name
        
        file_name.should.to.be.eql examples[2].file_name
        done()

      pf_obj.resolveAbsolutePath examples[2].path_name, examples[2].parent, res_fn

    it 'should find directory with relative path and parent (index.coffee)', (done) ->
      res_fn = (err, file_name) ->
        expect(err).to.be.null
        #console.log 'err ', err
        #console.log 'file_name ', file_name
        file_name.should.to.be.eql examples[3].file_name
        done()

      pf_obj.resolveAbsolutePath examples[3].path_name, examples[3].parent, res_fn

    it 'should find npm module in upper folder', (done) ->

      local_pf_obj = new Resolver()

      res_fn = (err, file_name) ->
        expect(err).to.be.null
        #console.log 'err ', err
        #console.log 'file_name ', file_name
        file_name.should.to.be.eql examples[4].file_name
        done()

      local_pf_obj.resolveAbsolutePath examples[4].path_name, examples[4].parent, res_fn

    it 'should return core modules if it required', (done) ->
      res_fn = (err, file_name) ->
        expect(err).to.be.null
        #console.log 'err ', err
        #console.log 'file_name ', file_name
        file_name.should.to.be.eql examples[5].file_name
        done()

      pf_obj.resolveAbsolutePath examples[5].path_name, examples[5].parent, res_fn

    it 'should resolve module-like dir with package.json without \'main\' section in it', (done) ->
      res_fn = (err, file_name) ->
        expect(err).to.be.null
        #console.log 'err ', err
        #console.log 'file_name ', file_name
        file_name.should.to.be.eql examples[6].file_name
        done()

      pf_obj.resolveAbsolutePath examples[6].path_name, examples[6].parent, res_fn

    it 'should return error if dir is not module', (done) ->
      res_fn = (err, file_name) ->
        expect(err).not.to.be.null
        #console.log 'err ', err
        #console.log 'file_name ', file_name
        expect(file_name).not.to.be.eql examples[7].file_name
        done()

      pf_obj.resolveAbsolutePath examples[7].path_name, examples[7].parent, res_fn

    it 'should return error if nonexistent file require', (done) ->
      res_fn = (err, file_name) ->
        expect(err).not.to.be.null
        #console.log 'err ', err
        #console.log 'file_name ', file_name
        expect(file_name).to.be.undefined
        done()

      pf_obj.resolveAbsolutePath './nonexistent', examples[0].parent, res_fn

  describe 'isCoreModule()', ->

    it 'should return |true| if module is core module', ->
      pf_obj.isCoreModule('path').should.to.be.true
      pf_obj.isCoreModule('util').should.to.be.true

    it 'should return |false| if module is NOT core module', ->
      pf_obj.isCoreModule('paths').should.to.be.false
      pf_obj.isCoreModule(examples[0].path_name).should.to.be.false

  describe 'resolveAbsolutePath() must pass some \'resolve\' (\'node-resolve\') tests:', ->

    describe 'pass \'foo\' tests', ->

      it 'should resolve |./foo|', (done) ->
        res_fn = (err, file_name) ->
          expect(err).to.be.null
          #console.log 'err ', err
          #console.log 'file_name ', file_name
          file_name.should.to.be.eql path.join fixturesResolver, '/foo.js'
          done()

        pf_obj.resolveAbsolutePath './foo', fixturesResolver, res_fn

      it 'should resolve |./foo.js|', (done) ->
        res_fn = (err, file_name) ->
          expect(err).to.be.null
          #console.log 'err ', err
          #console.log 'file_name ', file_name
          file_name.should.to.be.eql path.join fixturesResolver, '/foo.js'
          done()

        pf_obj.resolveAbsolutePath './foo.js', fixturesResolver, res_fn     

      it 'should return error on resolve |foo|', (done) ->
        res_fn = (err, file_name) ->
          expect(err).to.be.not.null
          #console.log 'err ', err
          #console.log 'file_name ', file_name
          expect(file_name).to.be.undefined
          done()

        pf_obj.resolveAbsolutePath 'foo', fixturesResolver, res_fn  

    describe 'pass \'bar\' test', ->

      it 'should resolve |foo| in other_modules dir', (done) ->
        res_fn = (err, file_name) ->
          expect(err).to.be.null
          #console.log 'err ', err
          #console.log 'file_name ', file_name
          res = path.join fixturesResolver, 'bar', 'other_modules', 'foo', 'index.js'
          file_name.should.to.be.eql res
          done()

        pf_obj.resolveAbsolutePath 'foo', path.join( fixturesResolver, 'bar'), res_fn   

    describe 'pass \'baz\' test', ->

      it 'should resolve |./baz|', (done) ->
        res_fn = (err, file_name) ->
          expect(err).to.be.null
          #console.log 'err ', err
          #console.log 'file_name ', file_name
          res = path.join fixturesResolver, 'baz', 'quux.js'
          file_name.should.to.be.eql res
          done()

        pf_obj.resolveAbsolutePath './baz', fixturesResolver, res_fn   
       
    describe 'pass \'biz\' test', ->

      base_dir = path.join fixturesResolver, 'biz', 'other_modules'

      it 'should resolve |./grux|', (done) ->
        res_fn = (err, file_name) ->
          expect(err).to.be.null
          #console.log 'err ', err
          #console.log 'file_name ', file_name
          res = path.join base_dir, 'grux', 'index.js'
          file_name.should.to.be.eql res
          done()

        pf_obj.resolveAbsolutePath './grux', base_dir, res_fn   

      it 'should resolve |tiv|', (done) ->
        res_fn = (err, file_name) ->
          expect(err).to.be.null
          #console.log 'err ', err
          #console.log 'file_name ', file_name
          res = path.join base_dir, 'tiv', 'index.js'
          file_name.should.to.be.eql res
          done()

        pf_obj.resolveAbsolutePath 'tiv', path.join( base_dir, 'grux'), res_fn   

      it 'should resolve |grux|', (done) ->
        res_fn = (err, file_name) ->
          expect(err).to.be.null
          #console.log 'err ', err
          #console.log 'file_name ', file_name
          res = path.join base_dir, 'grux', 'index.js'
          file_name.should.to.be.eql res
          done()

        pf_obj.resolveAbsolutePath 'grux', path.join( base_dir, 'tiv'), res_fn   

    describe 'pass \'normalize\' test', ->

      base_dir = path.join fixturesResolver, 'biz', 'other_modules'

      it 'should resolve |../grux|', (done) ->
        res_fn = (err, file_name) ->
          expect(err).to.be.null
          #console.log 'err ', err
          #console.log 'file_name ', file_name
          res = path.join base_dir, 'grux', 'index.js'
          file_name.should.to.be.eql res
          done()

        pf_obj.resolveAbsolutePath '../grux', path.join( base_dir, 'grux'), res_fn   
       
    describe 'pass \'cup\' test (work with additional extentions)', ->

      it 'should resolve |./cup|', (done) ->
        res_fn = (err, file_name) ->
          expect(err).to.be.null
          #console.log 'err ', err
          #console.log 'file_name ', file_name
          res = path.join fixturesResolver, 'cup.coffee'
          file_name.should.to.be.eql res
          done()

        pf_obj.resolveAbsolutePath './cup', fixturesResolver, res_fn   

      it 'should resolve |./cup.coffee| without extensions used', (done) ->
        local_pf_obj = new Resolver()

        res_fn = (err, file_name) ->
          expect(err).to.be.null
          #console.log 'err ', err
          #console.log 'file_name ', file_name
          res = path.join fixturesResolver, 'cup.coffee'
          file_name.should.to.be.eql res
          done()

        local_pf_obj.resolveAbsolutePath './cup.coffee', fixturesResolver, res_fn   

      it 'should return error on resolve |./cup| (.coffee) without extensions used', (done) ->
        local_pf_obj = new Resolver()

        res_fn = (err, file_name) ->
          expect(err).not.to.be.null
          #console.log 'err ', err
          #console.log 'file_name ', file_name
          expect(file_name).to.be.undefined
          done()

        local_pf_obj.resolveAbsolutePath './cup', fixturesResolver, res_fn          

    describe 'pass \'mug\' test', ->

      it 'should resolve |./mug| as .js without extentions used', (done) ->
        local_pf_obj = new Resolver()

        res_fn = (err, file_name) ->
          expect(err).to.be.null
          res = path.join fixturesResolver, 'mug.js'
          file_name.should.to.be.eql res
          done()

        local_pf_obj.resolveAbsolutePath './mug', fixturesResolver, res_fn         

      it 'should resolve |./mug| as .coffee if it first in extensions', (done) ->
        local_pf_obj = new Resolver extensions : [ '.coffee', '.js' ]

        res_fn = (err, file_name) ->
          expect(err).to.be.null
          res = path.join fixturesResolver, 'mug.coffee'
          file_name.should.to.be.eql res
          done()

        local_pf_obj.resolveAbsolutePath './mug', fixturesResolver, res_fn 

      it 'should resolve |./mug| as .js if it first in extensions', (done) ->
        local_pf_obj = new Resolver extensions : [ '.js', '.coffee' ]

        res_fn = (err, file_name) ->
          expect(err).to.be.null
          res = path.join fixturesResolver, 'mug.js'
          file_name.should.to.be.eql res
          done()

        local_pf_obj.resolveAbsolutePath './mug', fixturesResolver, res_fn 

    # test for other path not ported - I don't need this behavior right now :)

  describe 'Stress test suite:', ->

    describe 'in case of many different async resolve', ->

      it 'should allways return some results', (done) ->

        fixtureTwoChildren = path.join fixtureRoot, './two_children'

        test_suite = [
            {
              name : './two_children'
              dir  : fixtureRoot
            },
            {
              name : './index'
              dir  : fixtureTwoChildren
            },
            {
              name : './substractor'
              dir  : fixtureTwoChildren
            },
            {
              name : './summator'
              dir  : fixtureTwoChildren
            }, 
            {
              name : './power'
              dir  : fixtureTwoChildren
            }
        ]

        dep_tree = [
          [test_suite[0]]
          [test_suite[1]]
          [test_suite[2], test_suite[3]]
          [test_suite[4]]
          [test_suite[4]]

        ]

        inner_iteratot_fn = (item, inner_iter_cb) ->
          pf_obj.resolve item.name, item.dir, inner_iter_cb

        out_iterator_fn = (items, out_iter_cb) ->
          async.map items, inner_iteratot_fn, out_iter_cb

        mapper = (n, par_cb) -> async.map _.shuffle(dep_tree), out_iterator_fn, par_cb

        async.times 20, mapper, (err, results) ->
          expect(err).to.be.null
        
          for item in results
            (_.flatten item, true).should.to.have.length 6

          done()
          



