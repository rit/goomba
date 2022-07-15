local goomba = require "goomba"

describe("generating AST", function()
  it("can parse a number", function()
    local actual = goomba.parse("8")
    assert.are.equal(actual, 8)

    local actual = goomba.parse(" 28")
    assert.are.equal(actual, 28)
  end)
end)
