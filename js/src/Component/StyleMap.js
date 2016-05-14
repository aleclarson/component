var StyleMap, Type, assert, assertType, define, type;

assertType = require("assertType");

assert = require("assert");

define = require("define");

Type = require("Type");

type = Type("StyleMap");

type.defineValues({
  _constantValues: function() {
    return Object.create(null);
  },
  _computedValues: function() {
    return Object.create(null);
  }
});

type.initInstance(function(inherited) {
  var key, ref, ref1, results, value;
  if (!inherited) {
    return;
  }
  assertType(inherited, StyleMap);
  ref = inherited._constantValues;
  for (key in ref) {
    value = ref[key];
    this._constantValues[key] = value;
  }
  ref1 = inherited._computedValues;
  results = [];
  for (key in ref1) {
    value = ref1[key];
    results.push(this._computedValues[key] = value);
  }
  return results;
});

type.defineMethods({
  bind: function(context) {
    var computedNames, constantNames, self, styles;
    self = this;
    styles = Object.create(null);
    computedNames = Object.keys(this._computedValues);
    computedNames.forEach(function(styleName) {
      return define(styles, styleName, {
        value: function() {
          return self._compute(styleName, context, arguments);
        },
        frozen: true
      });
    });
    constantNames = Object.keys(this._constantValues);
    constantNames.forEach(function(styleName) {
      if (self._computedValues[styleName]) {
        return;
      }
      return define(styles, styleName, {
        get: function() {
          return self._constantValues[styleName];
        },
        frozen: true
      });
    });
    return styles;
  },
  define: function(styles) {
    var base, base1, base2, i, key, len, presetName, ref, style, styleName, value, values;
    for (styleName in styles) {
      style = styles[styleName];
      if (style.presets) {
        values = (base = this._constantValues)[styleName] != null ? base[styleName] : base[styleName] = Object.create(null);
        ref = style.presets;
        for (i = 0, len = ref.length; i < len; i++) {
          presetName = ref[i];
          this._applyPreset(presetName, values);
        }
        delete style.presets;
      }
      for (key in style) {
        value = style[key];
        if (value instanceof Function) {
          values = (base1 = this._computedValues)[styleName] != null ? base1[styleName] : base1[styleName] = Object.create(null);
          values[key] = value;
        } else {
          assert(value !== void 0, "Invalid style value: '" + styleName + "." + key + "'");
          values = (base2 = this._constantValues)[styleName] != null ? base2[styleName] : base2[styleName] = Object.create(null);
          values[key] = value;
        }
      }
    }
  },
  override: function(styles) {
    var computedValues, constantValues, i, key, len, presetName, ref, style, styleName, value;
    for (styleName in styles) {
      style = styles[styleName];
      assert(this._constantValues[styleName] || this._computedValues[styleName], {
        reason: "Could not find style to override: '" + styleName + "'"
      });
      this._constantValues[styleName] = constantValues = Object.create(null);
      this._computedValues[styleName] = computedValues = Object.create(null);
      if (style.presets) {
        ref = style.presets;
        for (i = 0, len = ref.length; i < len; i++) {
          presetName = ref[i];
          this._applyPreset(presetName, constantValues);
        }
        delete style.presets;
      }
      for (key in style) {
        value = style[key];
        if (value instanceof Function) {
          computedValues[key] = value;
        } else {
          assert(value !== void 0, "Invalid style value: '" + styleName + "." + key + "'");
          constantValues[key] = value;
        }
      }
    }
  },
  _applyPreset: function(presetName, style) {
    var key, preset, value;
    preset = StyleMap._presets[presetName];
    assert(preset, "Invalid style preset: '" + presetName + "'");
    for (key in preset) {
      value = preset[key];
      assert(value !== void 0, "Invalid style value: '" + presetName + "." + key + "'");
      style[key] = value;
    }
  },
  _compute: function(styleName, context, args) {
    var constantValues, key, ref, style, value;
    style = {};
    ref = this._computedValues[styleName];
    for (key in ref) {
      value = ref[key];
      style[key] = value.apply(context, args);
    }
    constantValues = this._constantValues[styleName];
    if (constantValues) {
      for (key in constantValues) {
        value = constantValues[key];
        style[key] = value;
      }
    }
    return style;
  }
});

type.defineStatics({
  _presets: Object.create(null),
  addPreset: function(presetName, style) {
    assertType(style, Object);
    StyleMap._presets[presetName] = style;
  }
});

module.exports = StyleMap = type.build();

//# sourceMappingURL=../../../map/src/Component/StyleMap.map
