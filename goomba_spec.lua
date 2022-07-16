local goomba = require "goomba"

describe("generating AST", function()
  local node_1 = {
        tag = "numeral",
        val = 1,
  }
  local node_2 = {
        tag = "numeral",
        val = 2,
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

  it("can parse multiplication #focus", function()
    local ast = goomba.parse("1 * 2")
    local expected = {
      tag = "binop",
      val = "mul",
      left = node_1,
      right = node_2

    }
    assert.are.same(expected, ast)
  end)

  it("can parse multiplication #focus", function()
    local ast = goomba.parse("4 / 2")
    local expected = {
      tag = "binop",
      val = "div",
      left = node_4,
      right = node_2

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

  it("generates opcodes for multiplication #focus", function()
    local ast = goomba.parse("2 * 4")
    local code = goomba.compile(ast)
    assert.are.same({"push", 2, "push", 4, "mul"}, code)
  end)

  it("generates opcodes for division #focus", function()
    local ast = goomba.parse("4 / 2")
    local code = goomba.compile(ast)
    assert.are.same({"push", 4, "push", 2, "div"}, code)
  end)
end)


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

  it("adds multiple operations", function()
    local ast = goomba.parse("1 + 2 + 3 + 4 + 5")
    local code = goomba.compile(ast)
    local stack = goomba.run(code, {})
    assert.are.same({15}, stack)
  end)

  it("can do substraction", function()
    local ast = goomba.parse("1 + 2 - 3 + 4")
    local code = goomba.compile(ast)
    local stack = goomba.run(code, {})
    assert.are.same({4}, stack)
  end)
end)
