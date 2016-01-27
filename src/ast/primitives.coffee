_ = require('lodash')
u = require('./utils')

primitives = {}

defineUserlandVar = (scope, name, type, value) ->
  if _.has(scope, u.signature(name, type))
    throw "Identifier '#{name}' of type '#{type}' is already defined"

  scope[u.signature(name, type)] = _.merge(type : type, value)

defineUserlandType = (scope, typename) ->
  if _.has(scope, typename)
    throw "Identifier '#{name}' is already defined"

  scope[typename] =
    type:'usertype'
    reg: (handler, scope, outer) ->
      varname = u.name(outer)
      values = handler(scope, u.value(outer))

      scope[u.signature(varname, typename)] = _.merge(type : typename, values)

      inst  : 'assign'
      type  : typename
      name  : varname
      value : values

simplePrimitive = (handler, scope, form) ->
  type = u.type(form)
  name = u.name(form)

  value = handler(scope, u.value(form))

  if _.has(value, 'ref') and not u.signMatch(value.ref, type, primitives, scope)
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

primitives.byte =
  primitives.int =
  primitives.float =
  primitives.string =
  primitives.bool =
  primitives.char =
  primitives.regex =
  simplePrimitive

primitives.tuple = complexPrimitive('tuple')
primitives.array = complexPrimitive('array')
primitives.function = complexPrimitive('function')
primitives.quote = (handler, scope, form) ->
  inst:'list'
  value: _.tail(_.map(form.args, (a) -> handler(scope, a)))

primitives.block = (handler, scope, form) ->
  subscope = _.cloneDeep(scope)
  block = _.map(u.values(form), (subform) -> handler(subscope, subform))

  defineUserlandVar(scope, u.name(form), 'block', block)

  inst: 'assign'
  type: 'block'
  name: u.name(form)
  block: block

module.exports = primitives
