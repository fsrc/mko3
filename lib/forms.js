// Generated by CoffeeScript 1.10.0
(function() {
  var FormsStream, JsonStream, _, create, es, form, jsin, jsout, options, stream,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  stream = require("stream");

  _ = require("lodash");

  form = {
    createExprArg: function(value, type, line, column) {
      return {
        type: type,
        line: line,
        column: column,
        value: value
      };
    },
    createExpr: function(line, column, origin, args) {
      return {
        type: "EXPR",
        origin: origin,
        starts: {
          line: line,
          column: column
        },
        ends: null,
        args: args != null ? args : []
      };
    },
    addExprArg: function(expr, value, type, line, column) {
      return {
        type: expr.type,
        origin: expr.origin,
        starts: expr.starts,
        ends: null,
        args: expr.args.concat({
          type: type,
          line: line,
          column: column,
          value: value
        })
      };
    },
    addSubExpression: function(expr, subexpression) {
      return {
        type: expr.type,
        origin: expr.origin,
        starts: expr.starts,
        ends: null,
        args: expr.args.concat(subexpression)
      };
    },
    endExpr: function(expr, line, column) {
      return {
        type: expr.type,
        origin: expr.origin,
        starts: expr.starts,
        ends: {
          line: line,
          column: column
        },
        args: expr.args
      };
    }
  };

  create = function(moduleName) {
    return (function(moduleName) {
      var state, wrapper;
      state = {
        expr: null,
        feeder: null,
        block: []
      };
      wrapper = {};
      wrapper.onIsOpening = function(fn) {
        wrapper.isOpening = fn;
        return wrapper;
      };
      wrapper.onIsClosing = function(fn) {
        wrapper.isClosing = fn;
        return wrapper;
      };
      wrapper.onIsEof = function(fn) {
        wrapper.isEof = fn;
        return wrapper;
      };
      wrapper.isOpening = function(a) {
        throw new Error("isOpening must be implemented");
      };
      wrapper.isClosing = function(a) {
        throw new Error("isClosing must be implemented");
      };
      wrapper.isEof = function(a) {
        throw new Error("isEof must be implemented");
      };
      wrapper.feed = function(token, cb) {
        if (state.feeder != null) {
          return state.feeder.feed(token, state.feeder.cb);
        } else {
          if (wrapper.isOpening(token)) {
            if (state.expr == null) {
              return state.expr = form.createExpr(token.line, token.column, moduleName);
            } else {
              state.feeder = create(moduleName + " >").onIsOpening(wrapper.isOpening).onIsClosing(wrapper.isClosing).onIsEof(wrapper.isEof);
              state.feeder.cb = function(err, subexpr) {
                if (err != null) {
                  cb(err);
                  return state.feeder = null;
                } else {
                  state.expr = form.addSubExpression(state.expr, subexpr);
                  return state.feeder = null;
                }
              };
              return state.feeder.feed(token, state.feeder.cb);
            }
          } else if (wrapper.isClosing(token)) {
            if (state.expr == null) {
              return cb({
                msg: "Error: Ending delimiter don't match a starting delimiter",
                token: token
              });
            } else {
              state.expr = form.endExpr(state.expr, token.line, token.column);
              state.block.push(state.expr);
              cb(null, state.expr);
              return state.expr = null;
            }
          } else if (wrapper.isEof(token)) {
            return cb(null, null);
          } else {
            if (state.expr == null) {
              return cb({
                msg: "Error: Identifier outside of expression",
                token: token
              });
            } else {
              return state.expr = form.addExprArg(state.expr, token.data, token.type, token.line, token.column);
            }
          }
        }
      };
      return wrapper;
    })(moduleName);
  };

  FormsStream = (function(superClass) {
    extend(FormsStream, superClass);

    function FormsStream(tokenRules, name) {
      this.tokenRules = tokenRules;
      this.name = name;
      if (!this.name) {
        this.name = "root";
      }
      this.p = create(this.name).onIsOpening((function(_this) {
        return function(token) {
          return _this.tokenRules.DEL.open(token.data);
        };
      })(this)).onIsClosing((function(_this) {
        return function(token) {
          return _this.tokenRules.DEL.close(token.data);
        };
      })(this)).onIsEof((function(_this) {
        return function(token) {
          return token.type === _this.tokenRules.EOF.id;
        };
      })(this));
      FormsStream.__super__.constructor.call(this, {
        objectMode: true
      });
    }

    FormsStream.prototype._transform = function(token, enc, next) {
      if (this.tokenRules.isUseful(token.type)) {
        this.p.feed(token, (function(_this) {
          return function(err, expr) {
            if (err != null) {
              return next(err);
            }
            return _this.push(expr);
          };
        })(this));
      }
      return next();
    };

    return FormsStream;

  })(stream.Transform);

  if (module.parent != null) {
    module.exports = {
      create: create,
      Stream: ExpressionStream
    };
  } else {
    JsonStream = require("./json-stream");
    options = require('./common-cli');
    es = new FormsStream(options.tokenrules);
    jsin = new JsonStream.Parse();
    jsout = new JsonStream.Stringify(options.beautify);
    options.instrm.pipe(jsin).pipe(es).pipe(jsout).pipe(options.outstrm);
  }

}).call(this);