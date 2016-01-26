stream = require("stream")
create = require("./index")

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

  scope : () -> @a.scope()

module.exports = AstStream
