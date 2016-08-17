var LazyMap;

LazyMap = require("LazyMap");

module.exports = LazyMap({
  NativeValue: function() {
    return require("./NativeValue");
  },
  NativeComponent: function() {
    return require("./NativeComponent");
  },
  NativeMap: function() {
    return require("./NativeMap");
  },
  NativeProps: function() {
    return require("./NativeProps");
  },
  NativeStyle: function() {
    return require("./NativeStyle");
  },
  NativeTransform: function() {
    return require("./NativeTransform");
  }
});

//# sourceMappingURL=map/index.map
