// Generated by CoffeeScript 1.12.4
var Device, Dimensions, Platform, Type, inArray, isCurrentDevice, registerDevices, type;

Dimensions = require("Dimensions");

Platform = require("Platform");

inArray = require("in-array");

Type = require("Type");

type = Type("Device");

type.defineValues({
  name: "",
  _window: Dimensions.get("window")
});

type.createFrozenValue("isMobile", function() {
  if (Platform.OS !== "web") {
    return true;
  }
  return /Mobi|iP(hone|od|ad)|Android|BlackBerry/.test(navigator.userAgent);
});

if (Platform.OS === "web") {
  type.initInstance(function() {
    var border;
    if (window.devicePixelRatio && devicePixelRatio >= 2) {
      border = document.createElement("div");
      border.style.border = ".5px solid transparent";
      document.body.appendChild(border);
      if (border.offsetHeight > 1) {
        console.warn("Hairline width not supported.");
      }
      document.body.removeChild(border);
    }
    window.addEventListener("resize", (function(_this) {
      return function() {
        _this._window = Dimensions.get("window");
      };
    })(this));
  });
}

type.defineGetters({
  size: function() {
    return {
      width: this.width,
      height: this.height
    };
  },
  width: function() {
    return this._window.width;
  },
  height: function() {
    return this._window.height;
  },
  scale: function() {
    return this._window.scale;
  }
});

type.defineMethods({
  specific: function(obj) {
    var value;
    value = obj[this.name];
    return value != null ? value : obj["else"];
  },
  round: function(value) {
    var scale;
    scale = this.scale;
    return Math.round(value * scale) / scale;
  }
});

module.exports = Device = type.construct();

isCurrentDevice = function(a, b) {
  return inArray(a, b.width) && inArray(a, b.height);
};

registerDevices = function(devices) {
  var deviceSize, name, size;
  deviceSize = Device.size;
  for (name in devices) {
    size = devices[name];
    if (Device[name] = isCurrentDevice(size, deviceSize)) {
      Device.name = name;
    }
  }
};

registerDevices((function() {
  var isApple;
  if (Platform.OS === "web") {
    isApple = /iP(hone|od|ad)/.test(navigator.userAgent);
  } else {
    isApple = Platform.OS === "ios";
  }
  if (isApple) {
    return {
      iPad: [768, 1024],
      iPhone4: [320, 480],
      iPhone5: [320, 568],
      iPhone6: [375, 667],
      iPhone6P: [414, 736]
    };
  }
})());

registerDevices;
