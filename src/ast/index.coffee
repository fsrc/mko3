_      = require("lodash")
u     = require("./utils")


# Create the parser, we need a state to manage this algorithm
create = () ->
  # Create a state
  do () ->
    primitives = require('./primitives')
    handler = {}
    wrapper = {}

    handler.EXPR = (evaluator, scope, form) ->
      console.dir form
      if u.calleeExists(form, primitives)
        primitives[u.callee(form)](evaluator, scope, form)

      else if u.calleeExists(form, scope)
        scope[u.callee(form)].reg(evaluator, scope, form)

      else if u.calleeIsExpression(form)
        u.throw(form, "Can not use an expression as callee")

      else
        console.error "f===================="
        console.error form
        u.throw(form, "'#{u.callee(form)}' is not defined")

    handler.REGEX = (handler, parentScope, form) ->
      value:form.value

    handler.BOOL = (handler, parentScope, form) ->
      value:u.parseBool(form.value)

    handler.IDENT = (handler, parentScope, form) ->
      ref:form.value

    handler.INT = (handler, parentScope, form) -> value:parseInt(form.value)
    handler.NUM = (handler, parentScope, form) -> value:parseFloat(form.value)
    handler.STR = (handler, parentScope, form) -> value:form.value

    handleForm = (parentScope, form) ->
      if _.has(handler, form.type)
        handler[form.type](handleForm, parentScope, form)
      else
        console.dir form
        u.throw(form, "faulty form")

    globalScope = {}
    wrapper.scope = () -> globalScope
    wrapper.astify = (form, cb) ->
      cb(null, handleForm(globalScope, form))

    wrapper


module.exports = create
