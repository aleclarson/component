var Property, StyleMap, assertType, typeImpl;

require("isDev");

assertType = require("assertType");

Property = require("Property");

StyleMap = require("./StyleMap");

module.exports = function(type) {
  type.defineProperties(typeImpl.properties);
  type.defineMethods(typeImpl.methods);
  return type.willBuild(typeImpl.willBuild);
};

typeImpl = {};

typeImpl.properties = {
  _styles: {
    lazy: function() {
      return StyleMap(this._kind && this._kind.styles);
    }
  }
};

typeImpl.methods = {
  defineStyles: function(styles) {
    assertType(styles, Object);
    this._styles.define(styles);
  },
  overrideStyles: function(styles) {
    assertType(styles, Object);
    this._styles.override(styles);
  }
};

typeImpl.willBuild = function() {
  var inherited, prop, styles;
  styles = this._styles;
  inherited = this._kind && this._kind.styles;
  if (!styles) {
    if (!inherited) {
      return;
    }
    styles = inherited;
  }
  this.defineStatics({
    styles: styles
  });
  if (!inherited) {
    prop = Property({
      frozen: isDev
    });
    return this.defineProperties({
      styles: {
        get: function() {
          styles = this.constructor.styles.bind(this);
          return prop.define(this, "styles", styles);
        }
      }
    });
  }
};

//# sourceMappingURL=../../../map/src/Component/StyleMixin.map
