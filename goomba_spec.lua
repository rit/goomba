local goomba = require "goomba"

describe("generating AST", function()
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
end)


describe("generating code #focus", function()
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
end)


describe("run", function()
  it("evalulate the stack", function()
    local code = {"push", 8}
    local stack = goomba.run(code, {})
    assert.are.same({8}, stack)
  end)
end)
