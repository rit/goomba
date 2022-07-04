local summation = require "summation"
local calc = summation.calc

describe("summation", function()
  it("can add", function()
    local actual = calc("1+2")
    assert.are.equal(actual, 3)
  end)

  it("can add with extra spaces", function()
    local actual = calc("1 +  2 + 4   ")
    assert.are.equal(actual, 7)
  end)
end)
