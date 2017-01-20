// Generated by CoffeeScript 1.11.1
var AnimatedValue, Shape, Type, assertType, has, isType, type;

AnimatedValue = require("Animated").AnimatedValue;

assertType = require("assertType");

isType = require("isType");

Shape = require("Shape");

Type = require("Type");

has = require("has");

type = Type("PropValidator");

type.defineValues(function() {
  return {
    types: {},
    defaults: {},
    allKeys: [],
    requiredKeys: {}
  };
});

type.defineMethods({
  define: function(propConfigs) {
    var allKeys, defaults, key, propConfig, propType, ref, requiredKeys, types;
    assertType(propConfigs, Object);
    ref = this, types = ref.types, defaults = ref.defaults, allKeys = ref.allKeys, requiredKeys = ref.requiredKeys;
    for (key in propConfigs) {
      propConfig = propConfigs[key];
      if (0 > allKeys.indexOf(key)) {
        allKeys.push(key);
      }
      if (!isType(propConfig, Object)) {
        types[key] = propConfig;
        continue;
      }
      if (propConfig.required) {
        requiredKeys[key] = true;
      } else if (has(propConfig, "default")) {
        defaults[key] = propConfig["default"];
      }
      if (!(propType = propConfig.type)) {
        continue;
      }
      types[key] = isType(propType, Object) ? Shape(propType) : propType;
    }
  },
  setDefaults: function(values) {
    var allKeys, defaults, key, ref, value;
    assertType(values, Object);
    ref = this, defaults = ref.defaults, allKeys = ref.allKeys;
    for (key in values) {
      value = values[key];
      if (0 > allKeys.indexOf(key)) {
        allKeys.push(key);
      }
      defaults[key] = value;
    }
  }
});

type.defineBoundMethods({
  validate: function(props) {
    var allKeys, defaults, i, key, len, prop, propType, ref, requiredKeys, types;
    assertType(props, Object);
    ref = this, types = ref.types, defaults = ref.defaults, allKeys = ref.allKeys, requiredKeys = ref.requiredKeys;
    for (i = 0, len = allKeys.length; i < len; i++) {
      key = allKeys[i];
      prop = props[key];
      if (prop === void 0) {
        if (defaults[key] !== void 0) {
          props[key] = prop = defaults[key];
        } else {
          if (!requiredKeys[key]) {
            continue;
          }
        }
      }
      if (propType = types[key]) {
        if (prop instanceof AnimatedValue) {
          assertType(prop.get(), propType, "props." + key);
        } else {
          assertType(prop, propType, "props." + key);
        }
      }
    }
    return props;
  }
});

module.exports = type.build();
