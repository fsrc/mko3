_      = require("lodash")
stream = require("stream")

class StringifyStream extends stream.Transform
  constructor: (@options) ->
    @first = true
    @separator = "\n"
    @separator = ",\n" if @options.validify
    super({ objectMode: true })

  _flush:(next) ->
    @push "]" if @options.validify
    next()

  _transform: (obj, enc, next) ->
    prefix = ""
    if @options.validify
      if @first
        prefix = "["
        @first = false
      else
        prefix = ","

    jasonstr = if @options.prettyprint
      JSON.stringify(obj, null, 2)
    else
      JSON.stringify(obj)

    @push(prefix + jasonstr + "\n")
    next()

class ParseStream extends stream.Transform
  constructor: () ->
    super({ objectMode: true })
  _transform: (obj, enc, next) ->
    _.chain(obj.toString().split('\n'))
      .dropRight()
      .map((line) -> JSON.parse(line))
      .map((obj) => @push(obj))
      .value()
    next()

exports.Stringify = StringifyStream
exports.Parse = ParseStream

