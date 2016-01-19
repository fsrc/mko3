expect     = require("chai").expect
tokenRules = require("../defines/tokens")
tokenizer  = require("../src/tokenizer")

describe "Tokenizer", () ->
  it "converts the text input to parsable tokens", () ->
    t = tokenizer.create(tokenRules)

