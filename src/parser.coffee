_ = require("lodash")
ast = require("./manipulators")


# Construct a closure around the parser
create = (moduleName) ->
  do (moduleName) ->
    # Keeps track of current expression and
    # subparser if we are nested
    state = { expr: null, feeder: null, block: [] }

    # The feeder function takes tokens and
    # emits completed expressions to wrapper.expression
    wrapper = {}
    wrapper.onIsOpening  = (fn) -> wrapper.isOpening = fn ; wrapper
    wrapper.onIsClosing  = (fn) -> wrapper.isClosing = fn ; wrapper
    wrapper.onIsEof      = (fn) -> wrapper.isEof = fn ; wrapper

    wrapper.isOpening = (a) -> throw new Error("isOpening must be implemented")
    wrapper.isClosing = (a) -> throw new Error("isClosing must be implemented")
    wrapper.isEof = (a) -> throw new Error("isEof must be implemented")

    wrapper.feed = (token, cb) ->
      # If we have a subparser that needs to be feed
      # then we feed that instead of the parent.
      if state.feeder?
        state.feeder.feed(token, state.feeder.cb)
      else
        # Check if the token is a start token
        if wrapper.isOpening(token)
          # If we don't have an expression that we are
          # working on, we create a new one.
          if not state.expr?
            state.expr = ast.createExpr(token.line, token.column, moduleName)
          else
            # Turns out we already have an expression so we
            # create a new subparser to take care of the
            # subexpression
            state.feeder = create(moduleName+" >")
              .onIsOpening(wrapper.isOpening)
              .onIsClosing(wrapper.isClosing)
              .onIsEof(wrapper.isEof)

            # Feed the new parser with the first token - a parenthesis
            state.feeder.cb = (err, subexpr) ->
              if err?
                # Pass on error
                cb(err)
                # Make sure we kill the subparser
                state.feeder = null
              else
                # We extend our current hiearky with the new expression
                state.expr = ast.addSubExpression(state.expr, subexpr)

                # Make sure we kill the subparser
                state.feeder = null

            state.feeder.feed(token, state.feeder.cb)

        # If we are closing the expression
        else if wrapper.isClosing(token)
          # Problems
          if not state.expr?
            cb({msg:"Error: Ending delimiter don't match a starting delimiter", token:token})
          # No problems, let's close the expression and emit the
          # result back to our owner.
          else
            # Close it
            state.expr = ast.endExpr(state.expr, token.line, token.column)

            state.block.push(state.expr)
            # Bubble
            cb(null, state.expr)
            # Make sure we clean up after us
            state.expr = null

        # End of file
        else if wrapper.isEof(token)
          cb(null, null)
        # This is where we fill the expression with content
        else
          if not state.expr?
            cb(msg:"Error: Identifier outside of expression", token:token)
          else
            # Add items into the list
            state.expr = ast.addExprArg(state.expr, token.data, token.type, token.line, token.column)

    wrapper


module.exports =
  create:create
