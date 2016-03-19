
{ assert, assertType } = require "type-utils"

ReactEasing = require "Easing"

module.exports =
Easing = (namePath) ->
  assertType namePath, String
  result = Easing.cache[namePath]
  return result if result?
  names = namePath.split "."
  name = names.pop()
  result = ReactEasing[name]
  assert result?, { name, reason: "Invalid easing name!" }
  for name in names.reverse()
    easing = ReactEasing[name]
    assert easing?, { name, reason: "Invalid easing name!" }
    result = easing result
  Easing.cache[namePath] = result

Easing.cache = Object.create null
Easing.bezier = ReactEasing.bezier
