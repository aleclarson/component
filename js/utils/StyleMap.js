var PureObject, StyleMap, Type, assertType, assign, callPreset, cloneObject, emptyObject, fillValue, frozen, has, inArray, isTransformKey, isType, parseTransform, presets, sync, type;

require("isDev");

frozen = require("Property").frozen;

cloneObject = require("cloneObject");

emptyObject = require("emptyObject");

PureObject = require("PureObject");

assertType = require("assertType");

fillValue = require("fillValue");

inArray = require("in-array");

isType = require("isType");

Type = require("Type");

sync = require("sync");

has = require("has");

type = Type("StyleMap");

type.defineValues({
  _styleNames: function() {
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
  return sync.keys(inherited._styleNames, (function(_this) {
    return function(styleName) {
      var style;
      _this._styleNames[styleName] = true;
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
    var contextStyles, props, styleNames, styles;
    styleNames = this._styleNames;
    styles = Object.create(null);
    props = context.props;
    if (props && props.styles) {
      contextStyles = sync.map(props.styles, (function(_this) {
        return function(style, styleName) {
          style = sync.map(style, parseTransform);
          if (!_this._styleNames[styleName]) {
            frozen.define(styles, styleName, {
              value: function() {
                return _this._getValues(styleName, contextStyles, context, arguments);
              }
            });
          }
          return style;
        };
      })(this));
    }
    sync.keys(this._styleNames, (function(_this) {
      return function(styleName) {
        return frozen.define(styles, styleName, {
          value: function() {
            return _this._getValues(styleName, contextStyles, context, arguments);
          }
        });
      };
    })(this));
    return styles;
  },
  define: function(styles) {
    var style, styleName;
    assertType(styles, Object);
    for (styleName in styles) {
      style = styles[styleName];
      if (this._styleNames[styleName]) {
        throw Error("Cannot define an existing style: '" + styleName + "'");
      }
      this._styleNames[styleName] = true;
      this._parseStyle(styleName, style || emptyObject);
    }
  },
  append: function(styles) {
    var style, styleName;
    assertType(styles, Object);
    for (styleName in styles) {
      style = styles[styleName];
      if (!this._styleNames[styleName]) {
        throw Error("Cannot append to undefined style: '" + styleName + "'");
      }
      this._parseStyle(styleName, style || emptyObject);
    }
  },
  override: function(styles) {
    var computedStyles, constantStyles, style, styleName;
    assertType(styles, Object);
    constantStyles = this._constantStyles;
    computedStyles = this._computedStyles;
    for (styleName in styles) {
      style = styles[styleName];
      if (!(constantStyles[styleName] || computedStyles[styleName])) {
        throw Error("Cannot override an undefined style: '" + styleName + "'");
      }
      delete constantStyles[styleName];
      delete computedStyles[styleName];
      if (!style) {
        continue;
      }
      this._parseStyle(styleName, style);
    }
  },
  build: function(contextStyles, context, args) {
    var styles;
    if (contextStyles == null) {
      contextStyles = {};
    }
    assertType(contextStyles, Object);
    assertType(args, Array.Maybe);
    styles = {};
    sync.keys(this._styleNames, (function(_this) {
      return function(styleName) {
        return styles[styleName] = _this._getValues(styleName, contextStyles[styleName], context, args);
      };
    })(this));
    return styles;
  },
  _parseStyle: function(styleName, style) {
    var computedStyle, constantStyle, key, value;
    assertType(styleName, String);
    assertType(style, Object);
    constantStyle = fillValue(this._constantStyles, styleName, PureObject.create);
    computedStyle = fillValue(this._computedStyles, styleName, PureObject.create);
    for (key in style) {
      value = style[key];
      if (value instanceof Function) {
        computedStyle[key] = parseTransform(value, key);
        if (has(constantStyle, key)) {
          delete constantStyle[key];
        }
      } else if (StyleMap._presets[key]) {
        sync.each(callPreset(key, value), function(value, key) {
          if (value == null) {
            throw TypeError("Invalid style value for key: '" + styleName + "." + key + "'");
          }
          constantStyle[key] = value;
          if (has(computedStyle, key)) {
            return delete computedStyle[key];
          }
        });
      } else if (value == null) {
        throw TypeError("Invalid style value for key: '" + styleName + "." + key + "'");
      } else {
        constantStyle[key] = parseTransform(value, key);
        if (has(computedStyle, key)) {
          delete computedStyle[key];
        }
      }
    }
  },
  _getValues: function(styleName, contextStyles, context, args) {
    var values;
    values = {
      transform: []
    };
    this._applyConstantStyle(values, this._constantStyles[styleName]);
    this._applyComputedStyle(values, this._computedStyles[styleName], context, args);
    if (contextStyles) {
      this._applyContextStyle(values, contextStyles[styleName]);
    }
    if (!values.transform.length) {
      delete values.transform;
    }
    return values;
  },
  _applyConstantStyle: function(values, style) {
    var isTransform, key, ref, value;
    if (!style) {
      return;
    }
    for (key in style) {
      ref = style[key], value = ref.value, isTransform = ref.isTransform;
      if (isTransform) {
        values.transform.push(assign({}, key, value));
      } else {
        values[key] = value;
      }
    }
  },
  _applyComputedStyle: function(values, style, context, args) {
    var isTransform, key, ref, value;
    if (!style) {
      return;
    }
    for (key in style) {
      ref = style[key], value = ref.value, isTransform = ref.isTransform;
      value = value.apply(context, args);
      if (value === void 0) {
        continue;
      }
      if (StyleMap._presets[key]) {
        sync.each(callPreset(key, value), function(arg, key) {
          var isTransform, value;
          value = arg.value, isTransform = arg.isTransform;
          if (value == null) {
            throw TypeError("Invalid style value for key: '" + key + "'");
          }
          if (isTransform) {
            return values.transform.push(assign({}, key, value));
          } else {
            return values[key] = value;
          }
        });
      } else if (isTransform) {
        values.transform.push(assign({}, key, value));
      } else {
        values[key] = value;
      }
    }
  },
  _applyContextStyle: function(values, style) {
    var isTransform, key, ref, value;
    for (key in style) {
      ref = style[key], value = ref.value, isTransform = ref.isTransform;
      if (isTransform) {
        values.transform.push(assign({}, key, value));
      } else {
        values[key] = value;
      }
    }
  }
});

type.defineStatics({
  _presets: Object.create(null),
  addPreset: function(presetName, style) {
    var preset;
    assertType(presetName, String);
    assertType(style, Object.or(Function));
    if (isType(style, Object)) {
      style = sync.map(style, parseTransform);
      preset = function() {
        return style;
      };
    } else {
      preset = function() {
        var values;
        values = style.apply(this, arguments);
        return sync.map(values, parseTransform);
      };
    }
    StyleMap._presets[presetName] = preset;
  },
  addPresets: function(presets) {
    var createStyle, presetName;
    for (presetName in presets) {
      createStyle = presets[presetName];
      this.addPreset(presetName, createStyle);
    }
  }
});

module.exports = StyleMap = type.build();

assign = function(obj, key, value) {
  obj[key] = value;
  return obj;
};

isTransformKey = (function() {
  var keys;
  keys = ["scale", "translateX", "translateY", "rotate"];
  return function(key) {
    return inArray(keys, key);
  };
})();

parseTransform = function(value, key) {
  return {
    value: value,
    isTransform: isTransformKey(key)
  };
};

callPreset = function(presetName, presetArg) {
  var style;
  style = StyleMap._presets[presetName](presetArg);
  assertType(style, Object);
  return style;
};

presets = require("./StylePresets");

StyleMap.addPresets(presets);

//# sourceMappingURL=map/StyleMap.map
