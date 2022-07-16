local lpeg = require "lpeg"
local pt = require "pt"
local push = table.insert
local pop = table.remove


local function hex(nbr)
  return tonumber(nbr, 16)
end
 

local space = lpeg.S(" \n\t")^0
local decimal = lpeg.R("09")^1 * space
local hexnum = lpeg.P("0x") * lpeg.C(lpeg.R("09", "af", "AF")^1) * space / hex
local numeral = hexnum + decimal


local function node(nbr)
  return { tag = "numeral", val = tonumber(nbr) }
end

local supportedOps = {
  ["+"] = "add",
  ["-"] = "sub",
}
local function nodeBinop(op)
  return {
    tag = "binop",
    val = supportedOps[op]
  }
end

local function foldBin(nodes)
  local tree = nodes[1]
  for i=2, #nodes, 2 do
    newtree = nodes[i]
    left = tree
    right = nodes[i+1]
    newtree["left"] = left
    newtree["right"] = right
    tree = newtree
  end
  return tree
end


local opA = lpeg.C(lpeg.S("+-")) * space
local n = numeral / node 
local g = space * lpeg.Ct(n * ((opA / nodeBinop) * n)^0) / foldBin


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
      push(stack, code[pc])
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
