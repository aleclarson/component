var StyleMap, typeMethods, typeProps;

StyleMap = require("../StyleMap");

module.exports = function(type) {
  type.defineProperties(typeProps);
  return type.defineMethods(typeMethods);
};

typeProps = {
  _styles: {
    lazy: function() {
      var styles;
      styles = StyleMap(this._kind.styles);
      this.initType(function(type) {
        return type.styles = styles;
      });
      this.initInstance(function() {
        return this.styles = styles.build(this);
      });
      return styles;
    }
  }
};

typeMethods = {
  defineStyles: function(styles) {
    assertType(styles, Object);
    this._styles.define(styles);
  },
  overrideStyles: function(styles) {
    assertType(styles, Object);
    this._styles.override(styles);
  }
};

//# sourceMappingURL=../../../../map/src/Component/mixins/Styles.map
