_ = require('lodash')
u = require('./utils')

signature = (name, type) -> "#{name}:#{type}"

defineUserlandVar = (scope, name, type, value) ->
  if _.has(scope, signature(name, type))
    throw "Identifier '#{name}' of type '#{type}' is already defined"

  scope[signature(name, type)] =
    type : type
    value : value

defineUserlandType = (scope, typename) ->
  if _.has(scope, typename)
    throw "Identifier '#{name}' is already defined"

  scope[typename] = (handler, scope, outer) ->
    varname = u.name(outer)
    values = handler(scope, u.value(outer))

    inst  : 'assign'
    type  : typename
    name  : varname
    value : values

simplePrimitive = (handler, scope, form) ->
  type = u.type(form)
  name = u.name(form)

  value = handler(scope, u.value(form))

  if _.has(value, 'ref') and not u.signMatch(name, type, scope)
    u.throw(form, "#{name} is not defined")

  defineUserlandVar(scope, name, type, value)

  _.merge(
    inst  : 'assign'
    type  : type
    name  : name
  , value)

complexPrimitive = (type) ->
  (handler, scope, form) ->
    typename = u.name(form)
    definition = handler(scope, u.value(form))
    defineUserlandType(scope, typename)

    inst: 'define'
    type: type
    name: typename
    definition: definition

valuesOfForm = (form) -> _.map(form.args, (a) -> a.value)

primitives = {}
primitives.byte = primitives.int = primitives.float = primitives.string =
  primitives.bool = primitives.char = primitives.regex = simplePrimitive

primitives.tuple = complexPrimitive('tuple')
primitives.array = complexPrimitive('array')
primitives.function = complexPrimitive('function')
primitives.quote = (handler, scope, form) ->
  inst:'list'
  value: _.tail(_.map(form.args, (a) -> a.value))

primitives.block = (handler, scope, form) ->
  inst: 'assign'
  type: 'block'
  value: 0

module.exports = primitives
