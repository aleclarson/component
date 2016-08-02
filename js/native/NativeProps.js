var Children, NativeMap, NativeStyle, Style, Type, fromArgs, isType, type;

fromArgs = require("fromArgs");

isType = require("isType");

Type = require("Type");

NativeStyle = require("./NativeStyle");

NativeMap = require("./NativeMap");

Children = require("../validators/Children");

Style = require("../validators/Style");

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
  _propTypes: fromArgs(1)
});

type.initInstance(function(props) {
  return this.attach(props);
});

type.overrideMethods({
  __attachValue: function(value, key) {
    if (this._propTypes) {
      type = this._propTypes[key];
    }
    if (type === Children) {
      this.__values[key] = value;
      return;
    }
    if (type === Style) {
      if (value == null) {
        return;
      }
      if (this.__nativeMaps[key]) {
        return;
      }
      value = NativeStyle(value);
    }
    return this.__super(arguments);
  }
});

module.exports = type.build();

//# sourceMappingURL=map/NativeProps.map
