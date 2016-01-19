stream     = require('stream')
tokenizer  = require("../src/tokenizer")
parser     = require("../src/parser")
JsonStream = require("../src/json-stream")

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

ts = new tokenizer.Stream(TOK)
es = new parser.Stream(TOK, "main")
js = new JsonStream.Stringify(true)

source
  .pipe(ts)
  .pipe(es)
  .pipe(js)
  .pipe(process.stdout)
