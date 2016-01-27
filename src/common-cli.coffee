# This code is only run when entry point is command line
fs = require('fs')

tokenRules = (tokenrules) ->
  if tokenrules == "built-in"
    require("../defines/tokens")
  else
    require(tokenrules)

inStream = (infile) ->
  if infile == "stdin"
    process.stdin
  else
    fs.createReadStream(infile)

outStream = (outfile) ->
  if outfile = "stdout"
    process.stdout
  else
    fs.createWriteStream(outfile)

# Set up command line arguments
argv = require('yargs')
  .usage("Usage: $0 [options]")
  .default('i', 'stdin')
    .alias('i', 'in')
    .describe('i', "Input file")
  .default('o', 'stdout')
    .alias('o', 'out')
    .describe('o', "Output file")
  .default('t', 'built-in')
    .alias('t', 'token-rules')
    .describe('t', "File with token rules")
  .boolean('s')
    .alias('s', 'include-scope')
    .describe('s', "Outputs any internal scope or state at the end")
  .boolean('b')
    .alias('b', 'beautify')
    .describe('b', "Beautify output (NOTE: Destroys JSON lines format)")
  .boolean('v')
    .alias('v', 'validify')
    .describe('v', "Outputs valid JSON instead of JSON lines format")
  .help('h')
    .alias('h', 'help')
  .epilog("Copyright 2016")
  .argv

module.exports =
  instrm : inStream(argv.i)
  outstrm : outStream(argv.o)
  tokenrules : tokenRules(argv.t)
  ast:
    includescope:argv.s
  json:
    beautify : argv.b
    validify : argv.v


