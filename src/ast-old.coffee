#!/usr/bin/env coffee

stream = require("stream")
_      = require("lodash")

parseBool = (string) ->
  switch string.toLowerCase().trim()
    when "true", "yes", "1"
      return true
    when "false", "no", "0", null
      return false


# Create the parser, we need a state to manage this algorithm
create = () ->
  # Create a state
  do () ->
    userland = {}
    primitives = {}

    parsePrimitiveValue = (type, value) ->
      switch type
        when "byte", "int" then return parseInt(value)
        when "float" then return parseFloat(value)
        when "bool" then return parseBool(value)
        when "string", "char", "regex" then return value

    defineUserlandVar = (name, type, value) ->
      if _.has(userland, name)
        throw "Identifier '#{name}' is already defined"

      userland[name] =
        type : type
        value : value

    defineUserlandType = (typename, valuesExtractor) ->
      if _.has(userland, typename)
        throw "Identifier '#{name}' is already defined"

      userland[typename] = (outer) ->
        varname = outer.args[1].value
        values = valuesExtractor(outer.args[2])

        inst  : 'assign'
        type  : typename
        name  : varname
        value : values

    simplePrimitive = (form) ->
      type = form.args[0].value
      name = form.args[1].value

      value = parsePrimitiveValue(type, form.args[2].value)

      defineUserlandVar(name, type, value)

      inst  : 'assign'
      type  : type
      name  : name
      value : value

    primitives.byte = primitives.int = primitives.float = primitives.string =
      primitives.bool = primitives.char = primitives.regex = simplePrimitive

    valuesOfForm = (form) -> _.map(form.args, (a) -> a.value)

    complexPrimitive = (type, definitionExtractor, valueExtractor) ->
      (form) ->
        typename = form.args[1].value
        definition = definitionExtractor(form.args[2])
        defineUserlandType(typename, valueExtractor)

        inst: 'define'
        type: type
        name: typename
        definition: definition

    primitives.tuple = complexPrimitive('tuple', valuesOfForm, valuesOfForm)
    primitives.array = complexPrimitive('array', ((x) -> x.value), valuesOfForm)
    primitives.function = complexPrimitive('function', valuesOfForm, (x) -> x)
    primitives.block = (form) ->
      inst: 'assign'
      type: 'block'
      value: 0

    wrapper = {}
    handler = {}

    handler.exprForm = (form) ->
      if _.has(primitives, form.args[0].value)
        primitives[form.args[0].value](form)
      else if _.has(userland, form.args[0].value)
        userland[form.args[0].value](form)
      else
        throw "#{form.args[0].value} is not defined"

    handler.identForm = (form) ->

    handler.form = (form) ->
      if form.type == "EXPR"
        handler.exprForm(form)
      else if form.type == "IDENT"
        handler.identForm(form)
      else
        throw "Unknown form type #{form.type}"

    wrapper.astify = (form, cb) ->
      cb(null, handler.form(form))

    wrapper



# Included as a module in other projects
if module.parent?
  module.exports =
    create:create
    Stream:AstStream

# Run from the command line
else
  JsonStream = require("./json-stream")
  options = require('./common-cli')

  as = new AstStream(options.tokenrules)
  jsin = new JsonStream.Parse(options.beautify)
  jsout = new JsonStream.Stringify(options.beautify)
  options.instrm
    .pipe(jsin)
    .pipe(as)
    .pipe(jsout)
    .pipe(options.outstrm)

