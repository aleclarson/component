var NativeComponent;

NativeComponent = require("../Native/Component");

module.exports = {
  Element: {
    lazy: function() {
      return require("./Element");
    }
  },
  Children: {
    lazy: function() {
      return require("./Children");
    }
  },
  Style: {
    lazy: function() {
      return require("./Style");
    }
  },
  View: {
    lazy: function() {
      return require("./View");
    }
  },
  ImageView: {
    lazy: function() {
      return require("./ImageView");
    }
  },
  TextView: {
    lazy: function() {
      return require("./TextView");
    }
  },
  StaticRenderer: {
    lazy: function() {
      var StaticRenderer;
      StaticRenderer = require("StaticRenderer");
      StaticRenderer.displayName = "StaticRenderer";
      return require("ReactElement").createFactory(StaticRenderer);
    }
  },
  InteractionManager: {
    lazy: function() {
      return require("InteractionManager");
    }
  }
};

//# sourceMappingURL=../../../map/src/React/index.map
