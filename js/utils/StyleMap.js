// Generated by CoffeeScript 1.12.4
var OneOf, StyleMap, StylePresets, Type, addTransform, assertType, bind, cloneObject, emptyObject, frozen, has, parseTransform, sync, testTransform, type;

require("isDev");

frozen = require("Property").frozen;

cloneObject = require("cloneObject");

emptyObject = require("emptyObject");

assertType = require("assertType");

OneOf = require("OneOf");

Type = require("Type");

sync = require("sync");

bind = require("bind");

has = require("has");

StylePresets = require("./StylePresets");

type = Type("StyleMap");

type.defineValues(function() {
  return {
    _styleNames: Object.create(null),
    _constantStyles: Object.create(null),
    _computedStyles: Object.create(null)
  };
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
    var base, base1, computedStyle, constantStyle, key, presetStyle, value;
    assertType(styleName, String);
    assertType(style, Object);
    constantStyle = (base = this._constantStyles)[styleName] != null ? base[styleName] : base[styleName] = Object.create(null);
    computedStyle = (base1 = this._computedStyles)[styleName] != null ? base1[styleName] : base1[styleName] = Object.create(null);
    for (key in style) {
      value = style[key];
      if (value instanceof Function) {
        computedStyle[key] = parseTransform(value, key);
        if (has(constantStyle, key)) {
          delete constantStyle[key];
        }
      } else if (StylePresets.has(key)) {
        presetStyle = StylePresets.call(key, value);
        sync.each(presetStyle, function(value, key) {
          constantStyle[key] = parseTransform(value, key);
          if (has(computedStyle, key)) {
            return delete computedStyle[key];
          }
        });
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
      if (value == null) {
        continue;
      }
      if (isTransform) {
        addTransform(values.transform, key, value);
      } else {
        values[key] = value;
      }
    }
  },
  _applyComputedStyle: function(values, style, context, args) {
    var isTransform, key, presetStyle, ref, value;
    if (!style) {
      return;
    }
    for (key in style) {
      ref = style[key], value = ref.value, isTransform = ref.isTransform;
      value = value.apply(context, args);
      if (value == null) {
        continue;
      }
      if (StylePresets.has(key)) {
        presetStyle = StylePresets.call(key, value);
        sync.each(presetStyle, function(value, key) {
          if (value == null) {
            return;
          }
          if (testTransform(value, key)) {
            return addTransform(values.transform, key, value);
          } else {
            return values[key] = value;
          }
        });
        continue;
      }
      if (isTransform) {
        addTransform(values.transform, key, value);
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
        addTransform(values.transform, key, value);
      } else {
        values[key] = value;
      }
    }
  }
});

module.exports = StyleMap = type.build();

addTransform = function(array, key, value) {
  var obj;
  obj = {};
  obj[key] = value;
  array.push(obj);
};

testTransform = (function() {
  var validator;
  validator = OneOf("scale perspective translateX translateY rotateX rotateY rotateZ");
  return bind.method(validator, "test");
})();

parseTransform = function(value, key) {
  return {
    value: value,
    isTransform: testTransform(key)
  };
};