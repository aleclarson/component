
var define = require('define');
var sync = require('sync');

var exports = require('./index');

var globalExports = {};
sync.keys(exports, function(key) {
  globalExports[key] = {
    get: function() {
      return exports[key];
    }
  };
});

define(global, globalExports);
