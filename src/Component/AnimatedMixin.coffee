
{AnimatedValue} = require "Animated"
{frozen} = require "Property"

module.exports = (type) ->
  type.defineMethods methods

methods =

  defineAnimatedValues: (values) ->
    @_delegate._values.push defineAnimatedValue, values
    return

  defineNativeValues: (values) ->
    @_delegate._values.push defineNativeValue, values
    return

defineAnimatedValue = (obj, key, value) ->
  frozen.define obj, key,
    value: AnimatedValue value

defineNativeValue = (obj, key, value) ->
  frozen.define obj, key,
    value: AnimatedValue value, {isNative: yes}
