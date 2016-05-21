#
# module.exports = (type) ->
#   type.defineMethods typeMethods
#
# typeMethods =
#
#   defineReactions: (reactions) ->
#
#     assertType reactions, Object
#
#     unless @_hasReactions
#       @_hasReactions = yes
#
#       @_initInstance ->
#         define this, "__reactions", Object.create null
#
#       @willMount ->
#         component = this
#         for key, reaction of @__reactions
#           guard -> reaction.start()
#           .fail (error) -> throwFailure error, { key, reaction, component }
#         return
#
#       @willUnmount ->
#         for key, reaction of @__reactions
#           reaction.stop()
#         return
#
#     prop = Property { frozen: yes }
#
#     @_initInstance (args) ->
#
#       Reaction.inject.push "autoStart", yes
#
#       for key, createReaction of reactions
#
#         assertType createReaction, Function, key
#
#         value = createReaction.apply this, args
#
#         continue if value is undefined
#
#         unless isType value, Reaction
#           value = Reaction.sync value
#
#         assert @__reactions[key] is undefined,
#           reason: "Conflicting reactions are both named '#{key}'."
#
#         @__reactions[key] = value
#
#         prop.define this, key, value
#
#       Reaction.inject.pop "autoStart"
