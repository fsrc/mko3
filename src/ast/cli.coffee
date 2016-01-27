AstStream = require("./stream")
JsonStream = require("../json-stream")
options = require('../common-cli')

as = new AstStream(options.tokenrules)
jsin = new JsonStream.Parse(options.beautify)
jsout = new JsonStream.Stringify(options.beautify)
options.instrm
  .pipe(jsin)
  .pipe(as)
  .on('end', () ->
    console.error("SCOPE")
    console.error(as.scope()))
  .pipe(jsout)
  .pipe(options.outstrm)
