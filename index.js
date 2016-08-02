
var define = require('define');

define(exports, {

  Type: require('./js/type/Type'),

  Component: require('./js/Component'),

  Device: {
    value: require('./js/utils/Device')
  },

  Children: {
    lazy: function() {
      return require('./js/validators/Children');
    }
  },

  Element: {
    lazy: function() {
      return require('./js/validators/Element');
    }
  },

  Style: {
    lazy: function() {
      return require('./js/validators/Style');
    }
  },
});
