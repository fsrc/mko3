AstStream = require("./stream")
JsonStream = require("../json-stream")
options = require('../common-cli')

as = new AstStream(options.ast)
jsin = new JsonStream.Parse(options.beautify)
jsout = new JsonStream.Stringify(options.json)
options.instrm
  .pipe(jsin)
  .pipe(as)
  .pipe(jsout)
  .pipe(options.outstrm)
