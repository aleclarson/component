var LazyMap;

LazyMap = require("LazyMap");

module.exports = LazyMap({
  Type: function() {
    return require("./Type");
  },
  Component: function() {
    return require("./Component");
  },
  Style: function() {
    return require("./validators/Style");
  },
  Element: function() {
    return require("./validators/Element");
  },
  Children: function() {
    return require("./validators/Children");
  },
  Device: function() {
    return require("./utils/Device");
  }
});

//# sourceMappingURL=map/index.map
