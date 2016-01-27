_      = require("lodash")

exprPosition = (form) ->
  "[#{form.starts.line}:#{form.starts.column}-#{form.ends.line}:#{form.ends.column}]"
identPosition = (form) ->
  "[#{form.line}:#{form.column}]"


exports.parseBool = parseBool = (string) ->
  switch string.toLowerCase().trim()
    when "true", "yes", "1"
      return true
    when "false", "no", "0", null
      return false

testForm = (form) ->
  if not form?
    console.error("Compiler error!")
    console.error(new Error().stack)
    process.exit(1)


exports.signature = signature = (name, type) ->
  "#{name}:#{type}"

exports.callee = callee = (form) ->
  testForm(form)
  form.args[0].value

exports.type = type = (form) ->
  testForm(form)
  form.args[0].value

exports.name = name = (form) ->
  testForm(form)
  form.args[1].value

exports.value = value = (form) ->
  testForm(form)
  form.args[2]

exports.values = (form) ->
  testForm(form)
  _.drop(form.args, 2)

exports.calleeExists = calleeExists = (form, scopes...) ->
  calleeName = callee(form)
  _.some(scopes, (scope) -> _.has(scope, calleeName))

exports.calleeIsExpression = (form) ->
  form.args[0].type == 'EXPR'

exports.signMatch = (name, type, scopes...) ->
  _.some(scopes, (scope) -> _.has(scope, signature(name, type)))

exports.throw = (form, msg) ->
  if form.type == "EXPR"
    console.error "#{exprPosition(form)} in expression > #{msg}"
  else
    console.error "#{identPosition(form)} in #{form.type} with value #{form.value} > #{msg}"
  process.exit()
