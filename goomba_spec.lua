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

  it("parse operator #focus", function()
    local actual = goomba.parse("20 + 30")
    assert.are.same(actual,
      { tag = "binop", val = "add",
        left = { tag = "numeral", val = 20 },
        right = { tag = "numeral", val = 30 },
      }
    )
  end)
end)


describe("generating code", function()
  it("generates push instruction for numeral", function()
    local ast = { tag = "numeral", val = 8 }
    local actual = goomba.compile(ast)
    assert.are.same({"push", 8}, actual)
  end)
end)


describe("run", function()
  it("evalulate the stack", function()
    local code = {"push", 8}
    local stack = goomba.run(code, {})
    assert.are.same({8}, stack)
  end)
end)
