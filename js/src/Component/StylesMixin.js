var Property, StyleMap, assertType, frozen, instImpl, isType, typeImpl;

assertType = require("assertType");

Property = require("Property");

isType = require("isType");

StyleMap = require("./StyleMap");

frozen = Property.frozen;

module.exports = function(type) {
  type.defineValues(typeImpl.values);
  type.defineMethods(typeImpl.methods);
  return type.initInstance(typeImpl.initInstance);
};

typeImpl = {};

typeImpl.values = {
  _styles: null
};

typeImpl.methods = {
  defineStyles: function(newStyles) {
    var styles;
    assertType(newStyles, Object);
    styles = this._styles || this._createStyles();
    styles.define(newStyles);
  },
  overrideStyles: function(newStyles) {
    var styles;
    assertType(newStyles, Object);
    styles = this._styles || this._createStyles();
    styles.override(newStyles);
  },
  _createStyles: function() {
    var kind;
    kind = this._delegate._kind;
    return this._styles = StyleMap(kind && kind.styles);
  }
};

typeImpl.initInstance = function() {
  return this._willBuild.push(instImpl.willBuild);
};

instImpl = {};

instImpl.willBuild = function() {
  var delegate, inherited, styles;
  styles = this._styles;
  delegate = this._delegate;
  if (delegate._kind) {
    inherited = delegate._kind.styles;
  }
  if (!(styles || !inherited)) {
    styles = inherited;
  }
  if (!isType(styles, StyleMap)) {
    return;
  }
  delegate.defineStatics({
    styles: styles
  });
  if (!inherited) {
    return delegate.definePrototype({
      styles: {
        get: function() {
          styles = this.constructor.styles.bind(this);
          frozen.define(this, "styles", styles);
          return styles;
        }
      }
    });
  }
};

//# sourceMappingURL=../../../map/src/Component/StylesMixin.map
