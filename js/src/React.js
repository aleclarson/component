var NativeComponent;

NativeComponent = require("./NativeComponent");

module.exports = {
  View: {
    lazy: function() {
      return NativeComponent("View", require("View"));
    }
  },
  ImageView: {
    lazy: function() {
      return NativeComponent("ImageView", require("Image"));
    }
  },
  TextView: {
    lazy: function() {
      return NativeComponent("TextView", require("Text"));
    }
  },
  TextInput: {
    lazy: function() {
      return NativeComponent("TextInput", require("TextInput"));
    }
  },
  WebView: {
    lazy: function() {
      return NativeComponent("WebView", require("WebView"));
    }
  },
  StaticRenderer: {
    lazy: function() {
      var StaticRenderer;
      StaticRenderer = require("StaticRenderer");
      StaticRenderer.displayName = "StaticRenderer";
      return (require("ReactElement")).createFactory(StaticRenderer);
    }
  },
  Easing: {
    lazy: function() {
      return require("./Easing");
    }
  },
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
  }
};

//# sourceMappingURL=../../map/src/React.map
