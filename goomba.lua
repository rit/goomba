local lpeg = require "lpeg"
local pt = require "pt"
local push = table.insert
local pop = table.remove


local function hex2dec(nbr)
  return tonumber(nbr, 16)
end
 

local function node(nbr)
  return { tag = "numeral", val = tonumber(nbr) }
end

local supportedOps = {
  ["+"] = "add",
  ["-"] = "sub",
  ["*"] = "mul",
  ["/"] = "div",
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

local space = lpeg.S(" \n\t")^0
local decimal = lpeg.R("09")^1 * space
local hexnum = lpeg.P("0x") * lpeg.C(lpeg.R("09", "af", "AF")^1) * space / hex2dec
local numeral = (hexnum + decimal) / node
local opA = lpeg.C(lpeg.S("+-")) * space
local opM = lpeg.C(lpeg.S("*/")) * space
local term = lpeg.Ct(numeral * ((opM / nodeBinop) * numeral)^0) / foldBin
local g = space * lpeg.Ct(term * ((opA / nodeBinop) * term)^0) / foldBin


-- Generate the AST
local function parse(input)
  return g:match(input)
end


-- Generate the opcodes (instruction sets)
-- Return a list i.e., { "push", 34 }
-- code is a FIFO list
local function code_expr(state, node)
  local code = state.code
  if node.tag == "numeral" then
    push(code, "push")
    push(code, node.val)
  elseif node.tag == "binop" then
    code_expr(state, node.left)
    code_expr(state, node.right)
    push(code, node.val) -- should this be pushed first?
  end
end


local function compile(ast)
  local state = {
    code = {}
  }
  code_expr(state, ast)
  return state.code
end

-- stack is a LIFO
local function run(code, stack)
  local pc = 1
  while pc <= #code do
    local op = code[pc]
    if op == "push" then
      pc = pc + 1
      push(stack, code[pc])
    elseif op == "add" then
      local right = pop(stack)
      local left = pop(stack)
      push(stack, left + right)
    elseif op == "sub" then
      local right = pop(stack)
      local left = pop(stack)
      push(stack, left - right)
    elseif op == "mul" then
      local right = pop(stack)
      local left = pop(stack)
      push(stack, left * right)
    elseif op == "div" then
      local right = pop(stack)
      local left = pop(stack)
      push(stack, left / right)
    else
      error(string.format("Opcode `%s` not supported", op))
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
