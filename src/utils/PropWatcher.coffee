
{AnimatedValue} = require "Animated"

Type = require "Type"
sync = require "sync"

type = Type "PropWatcher"

type.defineValues ->

  _values: {}

  _listeners: {}

type.defineMethods

  add: (key, callback) ->

    if listener = @_listeners[key]
      @_listeners[key] = ->
        listener.apply this, arguments
        callback.apply this, arguments
      return

    @_listeners[key] = callback
    return

  start: (props, context) ->
    values = @_values
    sync.each @_listeners, (listener, key) ->
      return unless value = props[key]
      return unless value instanceof AnimatedValue
      value.didSet (value) ->
        listener.call context, value, values[key]
        values[key] = value
        return
      return
    return

  update: (props, context) ->
    for key, value of props
      continue unless listener = @_listeners[key]
      listener.call context, value, @_values[key]
      @_values[key] = value
    return

module.exports = type.build()
