
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
      value = props[key]
      return if value is undefined
      if value instanceof AnimatedValue
        values[key] = value.get()
        value.didSet (value) ->
          listener.call context, value, values[key]
          values[key] = value
          return
      else
        values[key] = value
      return
    return

  update: (props, context) ->
    values = @_values
    listeners = @_listeners
    for key, value of props
      continue unless listener = listeners[key]
      continue if value is oldValue = values[key]
      listener.call context, value, oldValue
      values[key] = value
    return

module.exports = type.build()
