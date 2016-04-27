
ReactElement = require "ReactElement"

{ isType, assertType } = require "type-utils"
{ throwFailure } = require "failure"

combine = require "combine"
define = require "define"
steal = require "steal"
isDev = require "isDev"
sync = require "sync"

NativeProps = require "./NativeProps"
Component = require "./Component"

module.exports =
NativeComponent = (name, render) ->

  assertType name, String
  assertType render, Function

  component = Component "NativeComponent_" + name,

    initValues: ->

      child: null

      _newProps: null

      _nativeProps: NativeProps @props, render.propTypes, (newProps) =>
        if isDev
          try @setNativeProps newProps
          catch error then throwFailure error, { component: this, newProps }
        else @setNativeProps newProps

    setNativeProps: (newProps) ->
      return @child.setNativeProps newProps if @child?
      @_newProps = newProps

    componentWillReceiveProps: (props) ->
      @_nativeProps.attach props

    componentWillUnmount: ->
      @_nativeProps.detach()

    render: ->

      props = @_nativeProps.values

      props.ref = (view) =>
        @child = view
        if view and @_newProps
          @child.setNativeProps @_newProps
          @_newProps = null

      ReactElement.createElement render, props

  # Must be after class creation, else it gets overwritten.
  component.propTypes = render.propTypes

  component
