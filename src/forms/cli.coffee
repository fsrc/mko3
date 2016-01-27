FormsStream = require("./stream")
JsonStream = require("../json-stream")
options = require('../common-cli')

es = new FormsStream(options.tokenrules)
jsin = new JsonStream.Parse()
jsout = new JsonStream.Stringify(
  prettyprint:options.beautify
  validify:options.validify)
options.instrm
  .pipe(jsin)
  .pipe(es)
  .pipe(jsout)
  .pipe(options.outstrm)

