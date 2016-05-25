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
      var render;
      render = require("View");
      return NativeComponent("View", render);
    }
  },
  ImageView: {
    lazy: function() {
      var render;
      render = require("Image");
      return NativeComponent("ImageView", render);
    }
  },
  TextView: {
    lazy: function() {
      var render;
      render = require("Text");
      return NativeComponent("TextView", render);
    }
  },
  TextInput: {
    lazy: function() {
      var render;
      render = require("TextInput");
      return NativeComponent("TextInput", render);
    }
  },
  WebView: {
    lazy: function() {
      var render;
      render = require("WebView");
      return NativeComponent("WebView", render);
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
