#!/usr/bin/env coffee

stream = require("stream")
_      = require("lodash")

# Create the tokenizer, we need a state to manage this algorithm
create = () ->
  # Create a state
  do () ->
    wrapper = {}
    handler = {}

    handler.exprForm = (form) ->
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


# Wrapped in a stream
class AstStream extends stream.Transform
  constructor: () ->
    @a = create()
    super({objectMode:true})

  _transform: (obj, enc, next) ->
    @a.astify(obj, (err, node) =>
      return next(err) if err?
      @push(node))
    next()


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

