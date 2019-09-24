var assert = require('assert'),
    rest = require('cloudcmd/lib/server/rest'),
    path = require('path'),
    fs   = require('fs-extra'), // use fs-extra for removeSync
    home = process.env.HOME,
    scratch = process.env.SCRATCH,
    fixtures_path = path.resolve(__dirname, 'fixtures/'),
    hometmp, scratchtmp;

function s(p){
  return path.join(p, '/');
}

function assert_exists(){
  var p = path.join(...arguments);
  assert.ok(fs.existsSync(p), "does not exist: " + p);
}

function assert_data_dir_exists(p){
  assert_exists(p);
  assert_exists(p, 'emptydir');
  assert_exists(p, 'emptyfile.txt');
  assert_exists(p, 'test.txt');
  assert_exists(p, 'testdir');
  assert_exists(p, 'testdir', 'emptydir');
  assert_exists(p, 'testdir', 'test.txt');
}


describe('fixtures', function(){
  it('data dir exists', function(){
      var data = path.join(fixtures_path, 'data');
      assert_data_dir_exists(data);
  });
});

describe('copy', function(){
  beforeEach(function(){
    if(home)
      hometmp = fs.mkdtempSync(path.join(home, '/oodfilestest-'));
    if(scratch)
      scratchtmp = fs.mkdtempSync(path.join(scratch, '/oodfilestest-'));
  });

  afterEach(function(){
    if(hometmp){
      fs.removeSync(hometmp, {recursive: true});
      hometmp = null;
    }
    if(scratchtmp){
      fs.removeSync(scratchtmp, {recursive: true});
      scratchtmp = null;
    }
  });

  it('copies from fixture to home dir', function(done){
    if(hometmp == null)
      this.skip();

    rest.copy(s(fixtures_path), s(hometmp), ["data"], function(){
      assert_data_dir_exists(path.join(hometmp, 'data'));
      done();
    });
  });

  it('copies from fixture to scratch', function(done){
    if(scratchtmp == null)
      this.skip();


    rest.copy(s(fixtures_path), s(scratchtmp), ["data"], function(){
      assert_data_dir_exists(path.join(scratchtmp, 'data'));
      done();
    });
  });

  it('copies from scratch to scratch', function(done){
    if(scratchtmp == null)
      this.skip();


    var target = path.join(scratchtmp, 'target');
    fs.mkdirSync(target);

    rest.copy(s(fixtures_path), s(scratchtmp), ["data"], function(){
      rest.copy(s(scratchtmp), s(target), ["data"], function(){
        assert_data_dir_exists(path.join(target, 'data'));
        done();
      });
    });
  });

  it('copies from scratch to home dir', function(done){
    if(scratchtmp == null)
      this.skip();


    rest.copy(s(fixtures_path), s(scratchtmp), ["data"], function(){
      rest.copy(s(scratchtmp), s(hometmp), ["data"], function(){
        assert_data_dir_exists(path.join(hometmp, 'data'));
        done();
      });
    });
  });
});
