local goomba = require "goomba"
local pt = require "pt"

describe("generating AST", function()
  local node_1 = {
        tag = "numeral",
        val = 1,
  }
  local node_2 = {
        tag = "numeral",
        val = 2,
  }
  local node_3 = {
        tag = "numeral",
        val = 3,
  }
  local node_4 = {
        tag = "numeral",
        val = 4,
  }

  it("can parse a number", function()
    local actual = goomba.parse("8")
    assert.are.same(actual, { tag = "numeral", val = 8 })

    local actual = goomba.parse("  28 ")
    assert.are.same(actual, { tag = "numeral", val = 28 })
  end)

  it("can parse a hex number", function()
    local actual = goomba.parse("0xFF")
    assert.are.same(actual, { tag = "numeral", val = 255 })

    local actual = goomba.parse("0x10")
    assert.are.same(actual, { tag = "numeral", val = 16 })
  end)

  it("parse operator", function()
    local actual = goomba.parse("20 + 30")
    assert.are.same(
      { tag = "binop", val = "add",
        left = { tag = "numeral", val = 20 },
        right = { tag = "numeral", val = 30 },
      },
      actual
    )

    local actual = goomba.parse("20 + 30 - 4")

    local left = { tag = "binop", val = "add",
      left = { tag = "numeral", val = 20 },
      right = { tag = "numeral", val = 30 },
    }
    local expected = {
      tag = "binop",
      val = "sub",
      left = left,
      right = {
        tag = "numeral",
        val = 4,
      },
    }
    assert.are.same(expected, actual)
  end)

  it("can parse multiplication", function()
    local ast = goomba.parse("1 * 2")
    local expected = {
      tag = "binop",
      val = "mul",
      left = node_1,
      right = node_2

    }
    assert.are.same(expected, ast)
  end)

  it("can parse multiplication", function()
    local ast = goomba.parse("4 / 2")
    local expected = {
      tag = "binop",
      val = "div",
      left = node_4,
      right = node_2

    }
    assert.are.same(expected, ast)
  end)

  it("parses parenthesized expression", function()
    local ast = goomba.parse("(2 + 4) / 3")
    local expected = {}
    assert.are.same("binop", ast.tag)
    assert.are.same("div", ast.val)
    assert.are.same(node_3, ast.right)
    assert.are.same(
      {
        tag = "binop",
        val = "add",
        left = node_2,
        right = node_4,
      },
      ast.left
    )
  end)

  it("matches remander operator", function()
    local ast = goomba.parse("3 % 2")
    local expected = {
      tag = "binop",
      val = "mod",
      left = node_3,
      right = node_2
    }
    assert.are.same(expected, ast)
  end)

  it("matches power operater", function()
    local ast = goomba.parse("3 ^ 2")
    local expected = {
      tag = "binop",
      val = "pow",
      left = node_3,
      right = node_2
    }
    assert.are.same(expected, ast)
  end)

  it("matches power operater precedence", function()
    local ast = goomba.parse("3 ^ 2 * 1")
    local expected = {
      tag = "binop",
      val = "mul",
      left = {
        tag = "binop",
        val = "pow",
        left = node_3,
        right = node_2
      },
      right = node_1
    }
    assert.are.same(expected, ast)
  end)

  it("parses the unary minus #focus", function()
    local ast = goomba.parse("2")
    assert.are.same(node_2, ast)

    ast = goomba.parse("-2")
    expected = {
      tag = "unary",
      val = "negation",
      target = node_2
    }
    assert.are.same(expected, ast)
  end)
end)


describe("generating code", function()
  it("generates push instruction for numeral", function()
    local ast = { tag = "numeral", val = 8 }
    local actual = goomba.compile(ast)
    assert.are.same({"push", 8}, actual)

    local ast = goomba.parse("1+2")
    local actual = goomba.compile(ast)
    assert.are.same({"push", 1, "push", 2, "add"}, actual)

    local ast = goomba.parse("1-2")
    local actual = goomba.compile(ast)
    assert.are.same({"push", 1, "push", 2, "sub"}, actual)
  end)

  it("generates opcodes for multiplication", function()
    local ast = goomba.parse("2 * 4")
    local code = goomba.compile(ast)
    assert.are.same({"push", 2, "push", 4, "mul"}, code)
  end)

  it("generates opcodes for division", function()
    local ast = goomba.parse("4 / 2")
    local code = goomba.compile(ast)
    assert.are.same({"push", 4, "push", 2, "div"}, code)
  end)

  it("generates opcodes for modulo", function()
    local ast = goomba.parse("3 % 2")
    local code = goomba.compile(ast)
    assert.are.same({"push", 3, "push", 2, "mod"}, code)
  end)

  it("generates opcodes for power", function()
    local ast = goomba.parse("3 ^ 2")
    local code = goomba.compile(ast)
    assert.are.same({"push", 3, "push", 2, "pow"}, code)
  end)

  it("generates opcodes for negation", function()
    local ast = goomba.parse("-2")
    local code = goomba.compile(ast)
    assert.are.same({"push", 2, "negation"}, code)
  end)
end)


local function exec(expr)
  local ast = goomba.parse(expr)
  local code = goomba.compile(ast)
  return goomba.run(code, {})
end


describe("run", function()
  it("evalulate the stack", function()
    local code = {"push", 8}
    local stack = goomba.run(code, {})
    assert.are.same({8}, stack)
  end)

  it("adds", function()
    local code = {"push", 1, "push", 2, "add"}
    local stack = goomba.run(code, {})
    assert.are.same({3}, stack)
  end)

  it("adds multiple operations #focus", function()
    local stack = exec("1 + 2 + 3 + 4 + 5")
    assert.are.same({15}, stack)
  end)

  it("can do substraction", function()
    local stack = exec("1 + 2 - 3 + 4")
    assert.are.same({4}, stack)
  end)

  it("can do multiplication", function()
    local ast = goomba.parse("2 * 4")
    local code = goomba.compile(ast)
    local stack = goomba.run(code, {})
    assert.are.same({8}, stack)
  end)

  it("can do division", function()
    local ast = goomba.parse("8 / 4")
    local code = goomba.compile(ast)
    local stack = goomba.run(code, {})
    assert.are.same({2}, stack)
  end)

  it("supports priority", function()
    local ast = goomba.parse("6 - 8/4")
    local code = goomba.compile(ast)
    local stack = goomba.run(code, {})
    assert.are.same({4}, stack)
  end)

  it("supports parenthesized expression", function()
    local ast = goomba.parse("(2 + 4) / 3")
    local code = goomba.compile(ast)
    local stack = goomba.run(code, {})
    assert.are.same({2}, stack)
  end)

  it("supports modulo opcode", function()
    local ast = goomba.parse("3 % 2")
    local code = goomba.compile(ast)
    local stack = goomba.run(code, {})
    assert.are.same({1}, stack)
  end)

  it("supports power opcode", function()
    local ast = goomba.parse("3 ^ 2")
    local code = goomba.compile(ast)
    local stack = goomba.run(code, {})
    assert.are.same({9}, stack)
  end)

  it("supports negation #focus", function()
    local ast = goomba.parse("(-2) + 3 + (-4)")
    local code = goomba.compile(ast)
    local stack = goomba.run(code, {})
    assert.are.same({-3}, stack)
  end)

  it("supports negation #focus", function()
    local ast = goomba.parse("1 + 2 - 3")
    local code = goomba.compile(ast)
    local stack = goomba.run(code, {})
    assert.are.same({0}, stack)
  end)

  it("supports consecutive negation #focus", function()
    local ast = goomba.parse("-(-4)")
    local code = goomba.compile(ast)
    local stack = goomba.run(code, {})
    assert.are.same({4}, stack)
  end)

  it("consecutive negation needs to be wrapped in round brackets #focus", function()
    local ast = goomba.parse("--4)")
    assert.is_nil(ast)
  end)
end)
