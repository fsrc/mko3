stream    = require("stream")
tokenizer = require("./tokenizer")

class TokenStream extends stream.Transform
  constructor: (tokenRules) ->
    @t = tokenizer.create(tokenRules)
    super({objectMode:true})

  _transform: (chunk, enc, next) ->
    @t.tokenize(chunk.toString(), (err, token) =>
      return next(err) if err?
      @push(token))
    next()

module.exports = TokenStream
