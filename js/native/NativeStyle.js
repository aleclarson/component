var NativeMap, NativeTransform, Style, Type, flattenStyle, type;

flattenStyle = require("flattenStyle");

Type = require("Type");

NativeTransform = require("./NativeTransform");

NativeMap = require("./NativeMap");

Style = require("../validators/Style");

type = Type("NativeStyle");

type.inherits(NativeMap);

type.defineArgs({
  values: Style.isRequired
});

type.createInstance(function() {
  return NativeMap({});
});

type.initInstance(function(values) {
  return this.attach(values);
});

type.overrideMethods({
  attach: function(newValues) {
    if (Array.isArray(newValues)) {
      newValues = flattenStyle(newValues);
    }
    return this.__super(arguments);
  },
  __attachValue: function(value, key) {
    if (key === "transform") {
      if (!Array.isArray(value)) {
        return;
      }
      if (this.__nativeMaps[key]) {
        return;
      }
      value = NativeTransform(value);
    }
    return this.__super(arguments);
  }
});

module.exports = type.build();

//# sourceMappingURL=map/NativeStyle.map
