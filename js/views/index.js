var LazyMap;

LazyMap = require("LazyMap");

module.exports = LazyMap({
  View: function() {
    return require("./View");
  },
  ImageView: function() {
    return require("./ImageView");
  },
  TextView: function() {
    return require("./TextView");
  },
  TextInput: function() {
    return require("./TextInput");
  },
  WebView: function() {
    return require("./WebView");
  },
  StaticRenderer: function() {
    return require("./StaticRenderer");
  }
});

//# sourceMappingURL=map/index.map
