_      = require("lodash")
stream = require("stream")

class StringifyStream extends stream.Transform
  constructor: (@prettyprint) ->
    super({ objectMode: true })
  _transform: (obj, enc, next) ->
    jasonstr = if @prettyprint
      JSON.stringify(obj, null, 2)
    else
      JSON.stringify(obj)
    @push(jasonstr + "\n")
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

