var Device, Dimensions, define, devices, inArray, isDevice, sync;

Dimensions = require("Dimensions");

inArray = require("in-array");

define = require("define");

sync = require("sync");

define(Device = exports, {
  name: null,
  specific: function(devices) {
    var value;
    value = devices[Device.name];
    if (value == null) {
      value = devices["else"];
    }
    return value;
  },
  size: {
    get: function() {
      var height, ref, width;
      ref = Dimensions.get("window"), width = ref.width, height = ref.height;
      return {
        width: width,
        height: height
      };
    }
  },
  width: {
    get: function() {
      return Dimensions.get("window").width;
    }
  },
  height: {
    get: function() {
      return Dimensions.get("window").height;
    }
  },
  scale: {
    get: function() {
      return Dimensions.get("window").scale;
    }
  },
  round: function(value) {
    return Math.round(value * Device.scale) / Device.scale;
  }
});

devices = {
  iPad: [768, 1024],
  iPhone4: [320, 480],
  iPhone5: [320, 568],
  iPhone6: [375, 667],
  iPhone6P: [414, 736]
};

isDevice = function(a, b) {
  return inArray(a, b.width) && inArray(a, b.height);
};

sync.each(devices, function(screenSize, deviceName) {
  if (Device[deviceName] = isDevice(screenSize, Device.size)) {
    return Device.name = deviceName;
  }
});

//# sourceMappingURL=map/Device.map
