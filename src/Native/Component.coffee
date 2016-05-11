
# TODO: Convert this to use 'Component.Builder'!

require "isDev"

ReactElement = require "ReactElement"

{ isType, assertType } = require "type-utils"
{ throwFailure } = require "failure"

combine = require "combine"
define = require "define"
steal = require "steal"
sync = require "sync"

NativeProps = require "./Props"
Component = require "../Component"

module.exports =
NativeComponent = (name, render) ->

  assertType name, String
  assertType render, Function

  component = Component "NativeComponent_" + name,

    initValues: ->

      child: null

      _queuedProps: null

      _nativeProps: NativeProps @props, render.propTypes

    initListeners: ->

      @_nativeProps.didSet (newProps) =>

        guard =>
          if @child isnt null
            @child.setNativeProps newProps
          else @_queuedProps = newProps

        .fail (error) =>
          throwFailure error, { component: this, newProps }

    componentWillReceiveProps: (props) ->
      @_nativeProps.attach props

    componentWillUnmount: ->
      @_nativeProps.detach()

    onRef: (view) ->
      @child = view
      if view and @_queuedProps
        @child.setNativeProps @_queuedProps
        @_queuedProps = null

    render: ->
      props = @_nativeProps.values
      props.ref = (view) => @_onRef view
      ReactElement.createElement render, props

  # Must be after class creation, else it gets overwritten.
  component.propTypes = render.propTypes

  component
