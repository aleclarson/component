var Property, StyleMap, assertType, typeMethods, typePhases, typeValues;

require("isDev");

assertType = require("assertType");

Property = require("Property");

StyleMap = require("./StyleMap");

module.exports = function(type) {
  type.defineValues(typeValues);
  type.defineMethods(typeMethods);
  type.willBuild(typePhases.willBuild);
  return 1;
};

typeValues = {
  _styles: null
};

typeMethods = {
  defineStyles: function(styles) {
    assertType(styles, Object);
    this._initStyleMap();
    this._styles.define(styles);
  },
  overrideStyles: function(styles) {
    assertType(styles, Object);
    this._initStyleMap();
    this._styles.override(styles);
  },
  _initStyleMap: function() {
    if (this._styles) {
      return;
    }
    return this._styles = StyleMap(this._kind && this._kind.styles);
  }
};

typePhases = {
  willBuild: function() {
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
  }
};

//# sourceMappingURL=../../../map/src/Component/StyleMixin.map
