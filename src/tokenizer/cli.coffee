TokenStream = require("./stream")
JsonStream = require("../json-stream")
options = require('../common-cli')

ts = new TokenStream(options.tokenrules)
js = new JsonStream.Stringify(options.beautify)
options.instrm
  .pipe(ts)
  .pipe(js)
  .pipe(options.outstrm)
