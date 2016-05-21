
assertType = require "assertType"
Reaction = require "reaction"
isType = require "isType"
assert = require "assert"
define = require "define"
guard = require "guard"
Type = require "Type"

Component = require ".."

type = Type "ComponentTypeBuilder"

type.inherits Type.Builder

type.overrideMethods

  inherits: (kind) ->
    @__super arguments
    # @_viewType.inherits
    return

type.addMixins [
  require "./ViewMixin"
  require "../StyleMixin"
  require "../NativeValueMixin"
  require "../ListenerMixin"
]

module.exports = type.build()
