
var define = require('define');

define(exports, function() {
  this.options = { frozen: true };
  this(require('./js/src/index'));
  this(require('./js/src/React'));
});
