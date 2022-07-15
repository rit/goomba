local lpeg = require "lpeg"

local space = lpeg.S(" \n\t")^0
local numeral = lpeg.R("09")^1

local g = space * numeral / tonumber * space

local function node(nbr)
  return { tag = "numeral", val = nbr }
end


-- Generate the AST
local function parse(input)
  return g:match(input)
end


-- Generate the opcodes (instruction sets)
-- Return a list i.e., { "push", 34 }
local function compile(ast)
end

local function run()
end

return {
  parse = parse
}
