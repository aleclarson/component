
ReactElement = require "ReactElement"

{ throwFailure } = require "failure"

{ isType } = require "type-utils"

{ sync } = require "io"

combine = require "combine"
define = require "define"
steal = require "steal"

NativeProps = require "./NativeProps"
Component = require "./Component"

module.exports =
NativeComponent = (name, render) ->

  component = Component "NativeComponent_" + name,

    initValues: ->

      child: null

      _nativeProps: NativeProps @props, render.propTypes, (newProps) =>

        @_newValues.push newProps if @props.DEBUG # TODO: if __DEV__

        try @child.setNativeProps newProps
        catch error then throwFailure error, { component: this }

    init: ->
      _initDebug.call this # if __DEV__

    componentWillReceiveProps: (props) ->
      @_nativeProps.attach props

    componentWillUnmount: ->
      @_nativeProps.detach()

    render: ->
      props = @_nativeProps.values
      props.ref = (view) => @child = view
      ReactElement.createElement render, props

  # Must be after class creation, else it gets overwritten.
  component.propTypes = render.propTypes

  component

_initDebug = ->

  { props } = this

  define this, ->

    @options = { enumerable: no, frozen: yes }
    @
      _initialValues: (props if props.DEBUG)

      _newValues: []

      _findNewValue: (key) ->
        newValues = []
        key = key.split "."
        sync.each @_newValues, (values) ->
          index = 0
          while index < key.length
            values = values[key[index++]]
            break unless values?
          newValues.push values if values?
        newValues
