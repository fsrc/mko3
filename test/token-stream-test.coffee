stream           = require('stream')
TokenStream      = require("../src/token-stream")
ExpressionStream = require("../src/expression-stream")
JsonStream       = require("../src/json-stream")

TOK = require("../defines/tokens")

streamify = (text) ->
  s = new stream.Readable()
  s.push(text)
  s.push(null)
  return s

source = streamify("""
; Declare a function
(function tripple-byte-fun (byte-type byte-type byte-type))
(define tripple-byte-fun my-add ((a b)
  (block entry
    (sub a b))))

(function single-byte-fun (byte-type))
(define single-byte-fun main (()
  (block entry
    (my-add 3 4))))
""")

ts = new TokenStream(TOK)
es = new ExpressionStream('main', TOK)

source
  .pipe(ts)
  .pipe(es)
  .pipe(new JsonStream.Stringify(true))
  .pipe(process.stdout)
