
OneOf = require "OneOf"

StyleTransform = OneOf "scale perspective translateX translateY rotateX rotateY rotateZ"

StyleTransform.parse = (value, key) ->
  {value, isTransform: StyleTransform.test key}

module.exports = StyleTransform
