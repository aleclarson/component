
var define = require('define')

define(exports, {

  NativeValue: {
    lazy: function() {
      return require('./js/native/NativeValue');
    }
  },

  NativeComponent: {
    lazy: function() {
      return require('./js/native/NativeComponent');
    }
  },

  NativeMap: {
    lazy: function() {
      return require('./js/native/NativeMap');
    }
  },

  NativeProps: {
    lazy: function() {
      return require('./js/native/NativeComponent');
    }
  },

  NativeTransform: {
    lazy: function() {
      return require('./js/native/NativeTransform');
    }
  },

  NativeStyle: {
    lazy: function() {
      return require('./js/native/NativeStyle');
    }
  },
})
