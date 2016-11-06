
{AnimatedValue} = require "Animated"
{frozen} = require "Property"

ValueMapper = require "ValueMapper"
isDev = require "isDev"

module.exports = (type) ->
  type.defineMethods {defineAnimatedValues}

defineAnimatedValues = (values) ->
  mapValues = ValueMapper values, defineAnimatedValue
  @_delegate._phases.init.push (args) ->
    mapValues this, args
  return

defineAnimatedValue = (obj, key, value) ->
  return if value is undefined

  unless value instanceof AnimatedValue
    value = AnimatedValue value, obj.constructor.name + "." + key

  if isDev
  then frozen.define obj, key, {value}
  else obj[key] = value
