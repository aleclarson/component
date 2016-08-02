
var define = require('define')

define(exports, {

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
})
