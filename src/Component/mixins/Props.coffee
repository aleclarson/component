
module.exports = (type) ->

  type.defineValues typeValues

  type.defineProperties typeProps

  type.defineMethods typeMethods

  type.initInstance typePhases.initInstance

typeValues =

  _contextType: null

  _propTypes: null

  _propDefaults: null

typeProps =

  contextType:
    get: -> @_contextType
    set: (contextType) ->

      assert not @_contextType, "'contextType' is already defined!"

      assertType contextType, Component.Type

      @_contextType = contextType

      # TODO: Implement 'contextType'
      @_viewType

  propTypes:

    get: -> @_propTypes

    set: (propTypes) ->

      assert not @_propTypes, "'propTypes' is already defined!"

      assertType propTypes, Object

      @_propTypes = propTypes

      @initType (type) ->
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

      assert not @_propDefaults, "'propDefaults' is already defined!"

      assertType propDefaults, Object

      @_propDefaults = propDefaults

      @initType (type) ->
        type.propDefaults = propDefaults

      unless @_propTypes
        @createProps (props) ->
          return props or {}

      @initProps (props) ->

        assertType props, Object

        mergeDefaults props, propDefaults

        return props

typeMethods =

  createProps: (fn) ->
    assertType fn, Function
    @_phases.initProps.unshift fn
    return

  initProps: (fn) ->
    assertType fn, Function
    @_phases.initProps.push fn
    return

typePhases =

  initInstance: ->
    @_phases.initProps = []
    @willBuild instancePhases.willBuild

instancePhases =

  willBuild: ->

    phases = @_phases.initProps

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

    @_viewType.initType (type) ->
      define type, "_processProps", processProps
