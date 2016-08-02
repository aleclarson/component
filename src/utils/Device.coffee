
Dimensions = require "Dimensions"
inArray = require "in-array"
define = require "define"
sync = require "sync"

define exports,

  name: null

  specific: (devices) ->
    value = devices[currentDevice]
    value = devices.else unless value?
    value

  size: get: ->
    { width, height } = Dimensions.get "window"
    { width, height }

  width: get: ->
    Dimensions.get("window").width

  height: get: ->
    Dimensions.get("window").height

  scale: get: ->
    Dimensions.get("window").scale

  round: (value) ->
    Math.round(value * screenScale) / screenScale

devices =
  iPad:     [768, 1024]
  iPhone4:  [320, 480]
  iPhone5:  [320, 568]
  iPhone6:  [375, 667]
  iPhone6P: [414, 736]

isDevice = (a, b) ->
  inArray(a, b.width) and inArray(a, b.height)

sync.each devices, (screenSize, deviceName) ->
  isCurrentDevice = isDevice screenSize, exports.screenSize.get()
  exports[deviceName] = isCurrentDevice
  exports.name = deviceName if isCurrentDevice
