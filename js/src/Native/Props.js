var Children, NativeMap, NativeStyle, Style, Type, isType, type;

isType = require("isType");

Type = require("Type");

NativeStyle = require("./Style");

NativeMap = require("./Map");

Children = require("../React/Children");

Style = require("../React/Style");

type = Type("NativeProps");

type.inherits(NativeMap);

type.argumentTypes = {
  props: Object,
  propTypes: Object.Maybe
};

type.createInstance(function() {
  return NativeMap({});
});

type.defineValues({
  _propTypes: function(_, propTypes) {
    return propTypes;
  }
});

type.initInstance(function(props) {
  return this.attach(props);
});

type.defineMethods({
  __attachValue: function(value, key) {
    if (this._propTypes) {
      type = this._propTypes[key];
    }
    if ((type === Children) || (key === "children")) {
      this.__values[key] = value;
      return;
    }
    if ((type === Style) || (key === "style")) {
      if (value == null) {
        return;
      }
      if (this.__nativeMaps[key]) {
        return;
      }
      value = NativeStyle(value);
    }
    return NativeMap.prototype.__attachValue.call(this, value, key);
  }
});

module.exports = type.build();

//# sourceMappingURL=../../../map/src/Native/Props.map
