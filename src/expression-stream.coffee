stream = require("stream")
parser = require("./parser")

class ExpressionStream extends stream.Transform
  constructor: (@name, @tokenRules) ->
    @p = parser.create(@name)
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

module.exports = ExpressionStream
