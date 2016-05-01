module.exports = {
  NativeValue: {
    lazy: function() {
      return require("./Value");
    }
  },
  NativeComponent: {
    lazy: function() {
      return require("./Component");
    }
  },
  NativeMap: {
    lazy: function() {
      return require("./Map");
    }
  },
  NativeProps: {
    lazy: function() {
      return require("./Component");
    }
  },
  NativeTransform: {
    lazy: function() {
      return require("./Transform");
    }
  },
  NativeStyle: {
    lazy: function() {
      return require("./Style");
    }
  }
};

//# sourceMappingURL=../../../map/src/Native/index.map
