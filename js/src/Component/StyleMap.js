var Property, PureObject, StyleMap, TRANSFORMS, Type, applyPreset, assert, assertType, cloneObject, fillValue, has, pairKeyValue, sync, type;

require("isDev");

cloneObject = require("cloneObject");

PureObject = require("PureObject");

assertType = require("assertType");

fillValue = require("fillValue");

Property = require("Property");

assert = require("assert");

Type = require("Type");

sync = require("sync");

has = require("has");

type = Type("StyleMap");

type.defineValues({
  _styles: function() {
    return Object.create(null);
  },
  _constantStyles: function() {
    return Object.create(null);
  },
  _computedStyles: function() {
    return Object.create(null);
  }
});

type.initInstance(function(inherited) {
  if (!inherited) {
    return;
  }
  assertType(inherited, StyleMap);
  return sync.keys(inherited._styles, (function(_this) {
    return function(styleName) {
      var style;
      _this._styles[styleName] = true;
      style = inherited._constantStyles[styleName];
      if (style) {
        _this._constantStyles[styleName] = cloneObject(style);
      }
      style = inherited._computedStyles[styleName];
      if (style) {
        return _this._computedStyles[styleName] = cloneObject(style);
      }
    };
  })(this));
});

type.defineMethods({
  bind: function(context) {
    var computedStyles, constantStyles, prop, styles;
    prop = Property({
      frozen: isDev
    });
    styles = Object.create(null);
    constantStyles = this._constantStyles;
    computedStyles = this._computedStyles;
    sync.keys(this._styles, (function(_this) {
      return function(styleName) {
        return prop.define(styles, styleName, function() {
          return _this._buildStyle(styleName, context, arguments);
        });
      };
    })(this));
    return styles;
  },
  define: function(styles) {
    var style, styleName;
    for (styleName in styles) {
      style = styles[styleName];
      if (!style) {
        continue;
      }
      this._styles[styleName] = true;
      this._parseStyle(styleName, style);
    }
  },
  override: function(styles) {
    var computedStyles, constantStyles, style, styleName;
    constantStyles = this._constantStyles;
    computedStyles = this._computedStyles;
    for (styleName in styles) {
      style = styles[styleName];
      assert(constantStyles[styleName] || computedStyles[styleName], {
        reason: "Could not find style to override: '" + styleName + "'"
      });
      delete constantStyles[styleName];
      delete computedStyles[styleName];
      if (!style) {
        continue;
      }
      this._parseStyle(styleName, style);
    }
  },
  _parseStyle: function(styleName, style) {
    var computedValues, constantValues, key, value;
    assertType(style, Object);
    constantValues = fillValue(this._constantStyles, styleName, PureObject.create);
    computedValues = fillValue(this._computedStyles, styleName, PureObject.create);
    for (key in style) {
      value = style[key];
      if (StyleMap._presets[key]) {
        applyPreset(key, value, constantValues);
        continue;
      }
      if (value instanceof Function) {
        computedValues[key] = value;
        if (has(constantValues, key)) {
          delete constantValues[key];
        }
      } else {
        assert(value !== void 0, "Invalid style value: '" + styleName + "." + key + "'");
        constantValues[key] = value;
        if (has(computedValues, key)) {
          delete computedValues[key];
        }
      }
    }
  },
  _buildStyle: function(styleName, context, args) {
    var computedValues, constantValues, key, style, transform, value;
    style = {};
    constantValues = this._constantStyles[styleName];
    if (constantValues) {
      for (key in constantValues) {
        value = constantValues[key];
        if (TRANSFORMS[key]) {
          if (!transform) {
            transform = [];
          }
          transform.push(pairKeyValue(key, value));
        } else {
          style[key] = value;
        }
      }
    }
    computedValues = this._computedStyles[styleName];
    if (computedValues) {
      for (key in computedValues) {
        value = computedValues[key];
        value = value.apply(context, args);
        if (TRANSFORMS[key]) {
          if (!transform) {
            transform = [];
          }
          transform.push(pairKeyValue(key, value));
        } else {
          style[key] = value;
        }
      }
    }
    if (transform) {
      style.transform = transform;
    }
    return style;
  }
});

type.defineStatics({
  _presets: Object.create(null),
  addPreset: function(presetName, createStyle) {
    assertType(presetName, String);
    assertType(createStyle, Function);
    StyleMap._presets[presetName] = createStyle;
  }
});

module.exports = StyleMap = type.build();

TRANSFORMS = {
  scale: 1,
  translateX: 1,
  translateY: 1,
  rotate: 1
};

applyPreset = function(presetName, presetArg, constantValues) {
  var createStyle, key, style, value;
  createStyle = StyleMap._presets[presetName];
  style = createStyle(presetArg);
  assertType(style, Object, "style");
  for (key in style) {
    value = style[key];
    assert(value !== void 0, "Invalid style value: '" + presetName + "." + key + "'");
    constantValues[key] = value;
  }
};

pairKeyValue = function(key, value) {
  var pair;
  pair = {};
  pair[key] = value;
  return pair;
};

//# sourceMappingURL=../../../map/src/Component/StyleMap.map
