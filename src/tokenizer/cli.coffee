TokenStream = require("./stream")
JsonStream = require("../json-stream")
options = require('../common-cli')

ts = new TokenStream(options.tokenrules)
js = new JsonStream.Stringify(
  prettyprint:options.beautify
  validify:options.validify)
options.instrm
  .pipe(ts)
  .pipe(js)
  .pipe(options.outstrm)
