stream = require("stream")
create = require("./index")

# Wrapped in a stream
class FormsStream extends stream.Transform
  constructor: (@tokenRules, @name) ->
    @name = "root" if not @name
    @p = create(@name)
      .onIsOpening((token) => @tokenRules.DEL.open(token.data))
      .onIsClosing((token) => @tokenRules.DEL.close(token.data))
      .onIsEof((token) => token.type == @tokenRules.EOF.id)
    super({objectMode:true})

  _transform: (token, enc, next) ->
    if @tokenRules.isUseful(token.type)
      @p.feed(token, (err, expr) =>
        return next(err) if err?
        @push(expr))
    next()

module.exports = FormsStream
