
{AnimatedValue} = require "Animated"

assertType = require "assertType"
isType = require "isType"
Shape = require "Shape"
Type = require "Type"
has = require "has"

type = Type "PropValidator"

type.defineValues ->

  types: {}

  defaults: {}

  allKeys: []

  requiredKeys: {}

type.defineMethods

  # Pre-existing prop configs WILL get clobbered.
  define: (propConfigs) ->
    assertType propConfigs, Object
    {types, defaults, allKeys, requiredKeys} = this
    for key, propConfig of propConfigs
      allKeys.push key if 0 > allKeys.indexOf key

      unless isType propConfig, Object
        types[key] = propConfig
        continue

      if propConfig.required
        requiredKeys[key] = yes

      else if has propConfig, "default"
        defaults[key] = propConfig.default

      continue unless propType = propConfig.type
      types[key] =
        if isType propType, Object
        then Shape propType
        else propType

    return

  setDefaults: (values) ->
    assertType values, Object
    {defaults, allKeys} = this
    for key, value of values
      allKeys.push key if 0 > allKeys.indexOf key
      defaults[key] = value
    return

type.defineBoundMethods

  validate: (props) ->
    assertType props, Object
    {types, defaults, allKeys, requiredKeys} = this
    for key in allKeys
      prop = props[key]

      # Check for undefined props.
      if prop is undefined

        # Use the default value (if one exists).
        if defaults[key] isnt undefined
          props[key] = prop = defaults[key]

        else
          # Avoid type checking unless required.
          continue unless requiredKeys[key]

      if propType = types[key]
        if prop instanceof AnimatedValue
        then prop.type = propType
        else assertType prop, propType, "props." + key

    return props

module.exports = type.build()
