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
      return NativeComponent(render);
    }
  },
  ImageView: {
    lazy: function() {
      var render;
      render = require("Image");
      return NativeComponent(render);
    }
  },
  TextView: {
    lazy: function() {
      var render;
      render = require("Text");
      return NativeComponent(render);
    }
  },
  TextInput: {
    lazy: function() {
      var render;
      render = require("TextInput");
      return NativeComponent(render);
    }
  },
  WebView: {
    lazy: function() {
      var render;
      render = require("WebView");
      return NativeComponent(render);
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
