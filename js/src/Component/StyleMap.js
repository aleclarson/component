var Property, PureObject, StyleMap, Type, applyPreset, assert, assertType, assign, cloneObject, emptyObject, fillValue, frozen, has, inArray, isConstructor, parseTransform, run, sync, type;

require("isDev");

isConstructor = require("isConstructor");

cloneObject = require("cloneObject");

emptyObject = require("emptyObject");

PureObject = require("PureObject");

assertType = require("assertType");

fillValue = require("fillValue");

Property = require("Property");

inArray = require("in-array");

assert = require("assert");

Type = require("Type");

sync = require("sync");

has = require("has");

run = require("run");

frozen = Property({
  frozen: true
});

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
            frozen.define(styles, styleName, function() {
              return _this._buildStyle(styleName, contextStyles, context, arguments);
            });
          }
          return style;
        };
      })(this));
    }
    sync.keys(this._styleNames, (function(_this) {
      return function(styleName) {
        return frozen.define(styles, styleName, function() {
          return _this._buildStyle(styleName, contextStyles, context, arguments);
        });
      };
    })(this));
    return styles;
  },
  define: function(styles) {
    var style, styleName;
    for (styleName in styles) {
      style = styles[styleName];
      this._styleNames[styleName] = true;
      this._parseStyle(styleName, style || emptyObject);
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
        computedValues[key] = parseTransform(value, key);
        if (has(constantValues, key)) {
          delete constantValues[key];
        }
      } else {
        assert(value !== void 0, "Invalid style value: '" + styleName + "." + key + "'");
        constantValues[key] = parseTransform(value, key);
        if (has(computedValues, key)) {
          delete computedValues[key];
        }
      }
    }
  },
  _buildStyle: function(styleName, contextStyles, context, args) {
    var style;
    style = {
      transform: []
    };
    this._buildConstantStyle(style, this._constantStyles[styleName]);
    this._buildComputedStyle(style, this._computedStyles[styleName], context, args);
    if (contextStyles) {
      this._buildContextStyle(style, contextStyles[styleName]);
    }
    if (!style.transform.length) {
      delete style.transform;
    }
    return style;
  },
  _buildConstantStyle: function(style, values) {
    var isTransform, key, ref, value;
    if (!values) {
      return;
    }
    for (key in values) {
      ref = values[key], value = ref.value, isTransform = ref.isTransform;
      if (!isTransform) {
        style[key] = value;
      } else {
        style.transform.push(assign({}, key, value));
      }
    }
  },
  _buildComputedStyle: function(style, values, context, args) {
    var isTransform, key, ref, value;
    if (!values) {
      return;
    }
    for (key in values) {
      ref = values[key], value = ref.value, isTransform = ref.isTransform;
      value = value.apply(context, args);
      if (!isTransform) {
        style[key] = value;
      } else {
        style.transform.push(assign({}, key, value));
      }
    }
  },
  _buildContextStyle: function(style, values) {
    var isTransform, key, ref, value;
    for (key in values) {
      ref = values[key], value = ref.value, isTransform = ref.isTransform;
      if (!isTransform) {
        style[key] = value;
      } else {
        style.transform.push(assign({}, key, value));
      }
    }
  }
});

type.defineStatics({
  _presets: Object.create(null),
  addPreset: function(presetName, style) {
    var preset;
    assertType(presetName, String);
    assertType(style, [Object, Function]);
    if (isConstructor(style, Object)) {
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

parseTransform = run(function() {
  var keys;
  keys = ["scale", "translateX", "translateY", "rotate"];
  return function(value, key) {
    return {
      value: value,
      isTransform: inArray(keys, key)
    };
  };
});

assign = function(obj, key, value) {
  obj[key] = value;
  return obj;
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

//# sourceMappingURL=../../../map/src/Component/StyleMap.map
