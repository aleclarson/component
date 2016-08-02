
require('AppRegistry');

var define = require('define');

define(exports, {
  Component: require('./js/Component'),

  // views
  View: require('./js/views/View'),
  ImageView: {
    lazy: function() {
      return require('./js/views/ImageView');
    }
  },
  TextView: {
    lazy: function() {
      return require('./js/views/TextView');
    }
  },
  TextInput: {
    lazy: function() {
      return require('./js/views/TextInput');
    }
  },
  WebView: {
    lazy: function() {
      return require('./js/views/WebView');
    }
  },
  StaticRenderer: {
    lazy: function() {
      return require('./js/views/StaticRenderer');
    }
  },

  // validators
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

  // native
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
});
