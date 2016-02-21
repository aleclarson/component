
var define = require('define');

define(global, function() {
  this.options = { frozen: true };
  this(require('./js/src/index'));
  this(require('./js/src/React'));
});
