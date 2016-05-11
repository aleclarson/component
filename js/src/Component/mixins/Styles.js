var StyleMap, typeMethods, typeProps;

StyleMap = require("../StyleMap");

module.exports = function(type) {
  type.defineProperties(typeProps);
  return type.defineMethods(typeMethods);
};

typeProps = {
  _styles: {
    lazy: function() {
      var inheritedStyles, styles;
      inheritedStyles = this._kind ? this._kind.styles : null;
      styles = StyleMap(inheritedStyles);
      this.didBuild(function(type) {
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
