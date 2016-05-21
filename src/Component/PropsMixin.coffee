
mergeDefaults = require "mergeDefaults"
assertType = require "assertType"
assert = require "assert"
define = require "define"
guard = require "guard"

module.exports = (type) ->

  type.defineValues typeValues

  type.definePrototype typePrototype

  type.initInstance typePhases.initInstance

typeValues =

  _propTypes: null

  _propDefaults: null

  _initProps: -> []

typePrototype =

  propTypes:
    get: -> @_propTypes
    set: (propTypes) ->

      assertType propTypes, Object
      assert not @_propTypes, "'propTypes' is already defined!"

      @_propTypes = propTypes

      @_didBuild.push (type) ->
        type.propTypes = propTypes

      unless @_propDefaults
        @createProps (props) ->
          return props or {}

      @initProps (props) ->

        return if isDev

        assertType props, Object

        guard ->
          validateTypes props, propTypes

        .fail (error) ->
          throwFailure error, { method: "_processProps", element: this, props, propTypes }

        return props

  propDefaults:
    get: -> @_propDefaults
    set: (propDefaults) ->

      assertType propDefaults, Object
      assert not @_propDefaults, "'propDefaults' is already defined!"

      @_propDefaults = propDefaults

      @_didBuild.push (type) ->
        type.propDefaults = propDefaults

      unless @_propTypes
        @createProps (props) ->
          return props or {}

      @initProps (props) ->

        assertType props, Object

        mergeDefaults props, propDefaults

        return props

  createProps: (fn) ->
    assertType fn, Function
    @_initProps.unshift fn
    return

  initProps: (fn) ->
    assertType fn, Function
    @_initProps.push fn
    return

typePhases =

  initInstance: ->
    @_willBuild.push instancePhases.willBuild

instancePhases =

  willBuild: ->

    phases = @_initProps

    return if phases.length is 0

    if phases.length is 1
      phase = phases[0]
      processProps = (props) ->
        phase.call null, props

    else
      processProps = (props) ->
        for phase in phases
          props = phase.call null, props
        return props

    @_didBuild.push (type) ->
      define type, "_processProps", processProps
