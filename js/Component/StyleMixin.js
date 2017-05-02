// Generated by CoffeeScript 1.12.4
var Builder, StyleMap, assertType, frozen, instMixin, isType, mixin;

frozen = require("Property").frozen;

assertType = require("assertType");

Builder = require("Builder");

isType = require("isType");

StyleMap = require("../utils/StyleMap");

mixin = Builder.Mixin();

mixin.defineMethods({
  defineStyles: function(styles) {
    var cache;
    assertType(styles, Object);
    cache = this._styles || this._createStyles();
    cache.define(styles);
  },
  appendStyles: function(styles) {
    var cache;
    assertType(styles, Object);
    cache = this._styles || this._createStyles();
    cache.append(styles);
  },
  overrideStyles: function(styles) {
    var cache;
    assertType(styles, Object);
    cache = this._styles || this._createStyles();
    cache.override(styles);
  },
  _createStyles: function() {
    var kind, styles;
    kind = this._delegate._kind;
    styles = StyleMap(kind && kind.styles);
    frozen.define(this, "_styles", {
      value: styles
    });
    return styles;
  }
});

mixin.initInstance(function() {
  return this.addMixins([instMixin.apply]);
});

module.exports = mixin.apply;

instMixin = Builder.Mixin();

instMixin.willBuild(function() {
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
  if (delegate !== this) {
    this.defineStatics({
      styles: styles
    });
  }
  if (!inherited) {
    return delegate.definePrototype({
      styles: {
        get: function() {
          styles = this.constructor.styles.bind(this);
          frozen.define(this, "styles", {
            value: styles
          });
          return styles;
        }
      }
    });
  }
});
