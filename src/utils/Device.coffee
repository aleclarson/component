
Dimensions = require "Dimensions"
inArray = require "in-array"
Type = require "Type"

type = Type "Device"

type.defineGetters

  size: ->
    size = Dimensions.get "window"
    width: size.width
    height: size.height

  width: ->
    Dimensions.get("window").width

  height: ->
    Dimensions.get("window").height

  scale: ->
    Dimensions.get("window").scale

type.defineMethods

  specific: (obj) ->
    value = obj[@name]
    value ? obj.else

  round: (value) ->
    {scale} = this
    Math.round(value * scale) / scale

module.exports = Device = type.construct()

isCurrentDevice = (a, b) ->
  inArray(a, b.width) and inArray(a, b.height)

registerDevices = (devices) ->
  for name, size of devices
    if Device[name] = isCurrentDevice size, Device.size
      Device.name = name
  return

registerDevices
  iPad: [768, 1024]
  iPhone4: [320, 480]
  iPhone5: [320, 568]
  iPhone6: [375, 667]
  iPhone6P: [414, 736]
