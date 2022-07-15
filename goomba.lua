local lpeg = require "lpeg"

local space = lpeg.S(" \n\t")^0
local numeral = lpeg.R("09")^1


local function node(nbr)
  return { tag = "numeral", val = tonumber(nbr) }
end


local g = space * numeral / node * space


-- Generate the AST
local function parse(input)
  return g:match(input)
end


-- Generate the opcodes (instruction sets)
-- Return a list i.e., { "push", 34 }
local function compile(ast)
  if ast.tag == "numeral" then
    return { "push", ast.val }
  end
end

local function run(code, stack)
  local pc = 1
  while pc <= #code do
    local op = code[pc]
    if op == "push" then
      pc = pc + 1
      table.insert(stack, code[pc])
    else
      error("Opcode not supported")
    end
    pc = pc + 1
  end

  return stack
end

return {
  parse = parse,
  compile = compile,
  run = run
}
