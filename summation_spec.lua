local summation = require "summation"
local calc = summation.calc

describe("summation", function()
  it("can add", function()
    local actual = calc("1+2")
    assert.are.equal(actual, 3)
  end)

  it("can add with extra spaces", function()
    local actual = calc("-1 +  2 + 4  + 2")
    assert.are.equal(actual, 7)
  end)

  it("can substrac", function()
    local actual = calc("3   - 2 ")
    assert.are.equal(actual, 1)
  end)


  it("can multiply", function()
    local actual = calc("2 * 2")
    assert.are.equal(actual, 4)
  end)

  it("can multiplication with addition", function()
    local actual = calc("2 * 2 + 1")
    assert.are.equal(actual, 5)

    local actual = calc("1 + 2 * 2 + 1")
    assert.are.equal(actual, 6)
  end)

  it("can do division", function()
    local actual = calc("4 / 2")
    assert.are.equal(actual, 2)
  end)

  it("understands parenthesis", function()
    local actual = calc("    4 * (2 + 1)")
    assert.are.equal(actual, 12)

    local actual = calc("    4 * ( 2 + 1)")
    assert.are.equal(actual, 12)
  end)

end)
