
Dimensions = require "Dimensions"
Platform = require "Platform"
inArray = require "in-array"
Type = require "Type"

type = Type "Device"

type.defineValues

  name: ""

  _window: Dimensions.get "window"

type.createFrozenValue "isMobile", ->
  return yes if Platform.OS isnt "web"
  return /Mobi|iP(hone|od|ad)|Android|BlackBerry/.test navigator.userAgent

if Platform.OS is "web"
  type.initInstance ->

    if window.devicePixelRatio and devicePixelRatio >= 2
      border = document.createElement "div"
      border.style.border = ".5px solid transparent"
      document.body.appendChild border
      if border.offsetHeight > 1
        console.warn "Hairline width not supported."
      document.body.removeChild border

    window.addEventListener "resize", =>
      @_window = Dimensions.get "window"
      return
    return

type.defineGetters

  size: -> {@width, @height}

  width: -> @_window.width

  height: -> @_window.height

  scale: -> @_window.scale

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
  deviceSize = Device.size
  for name, size of devices
    if Device[name] = isCurrentDevice size, deviceSize
      Device.name = name
  return

registerDevices do ->

  if Platform.OS is "web"
    isApple = /iP(hone|od|ad)/.test navigator.userAgent
    # isAndroid = /Android/.test navigator.userAgent

  else
    isApple = Platform.OS is "ios"
    # isAndroid = not isApple

  if isApple
    iPad: [768, 1024]
    iPhone4: [320, 480]
    iPhone5: [320, 568]
    iPhone6: [375, 667]
    iPhone6P: [414, 736]

registerDevices
