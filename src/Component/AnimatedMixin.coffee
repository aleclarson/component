
{AnimatedValue} = require "Animated"
{frozen} = require "Property"

ValueMapper = require "ValueMapper"
isDev = require "isDev"

module.exports = (type) ->
  type.defineMethods methods

methods =

  defineAnimatedValues: (values) ->
    mapValues = createValueMapper values, no
    @_delegate._phases.init.push (args) ->
      mapValues this, args
    return

  defineNativeValues: (values) ->
    mapValues = createValueMapper values, yes
    @_delegate._phases.init.push (args) ->
      mapValues this, args
    return

createValueMapper = (values, isNative) ->
  return ValueMapper values, (obj, key, value) ->
    if value isnt undefined
      value = AnimatedValue value, {isNative}
      if isDev
      then frozen.define obj, key, {value}
      else obj[key] = value
    return
