local lpeg = require "lpeg"
local push = table.insert
local pop = table.remove

-- opcodes
local PUSH = "push"
local ADD = "add"
local SUB = "sub"
local MUL = "mul"
local DIV = "div"
local MOD = "mod"


local function hex2dec(nbr)
  return tonumber(nbr, 16)
end

local function nodeNumeral(nbr)
  return { tag = "numeral", val = tonumber(nbr) }
end

local supportedOps = {
  ["+"] = ADD,
  ["-"] = SUB,
  ["*"] = MUL,
  ["/"] = DIV,
  ["%"] = MOD,
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
    local newtree = nodes[i]
    local left = tree
    local right = nodes[i+1]
    newtree["left"] = left
    newtree["right"] = right
    tree = newtree
  end
  return tree
end

local space = lpeg.S(" \n\t")^0
local ORB = "(" * space -- open round bracket
local CRB = ")" * space -- closing round bracket

local decimal = lpeg.R("09")^1 * space
local hexnum = lpeg.P("0x") * lpeg.C(lpeg.R("09", "af", "AF")^1) * space / hex2dec
local numeral = (hexnum + decimal) / nodeNumeral
local opA = lpeg.C(lpeg.S("+-")) * space / nodeBinop
local opM = lpeg.C(lpeg.S("*/%")) * space / nodeBinop

local term = lpeg.V"term"
local expr = lpeg.V"expr"
local factor = lpeg.V"factor"
local g = lpeg.P {"expr",
  factor = numeral + ORB * expr * CRB,
  term = lpeg.Ct(factor * (opM * factor)^0) / foldBin,
  expr = space * lpeg.Ct(term * (opA * term)^0) / foldBin,
}



-- Generate the AST
local function parse(input)
  return g:match(input)
end


-- Generate the opcodes (instruction sets)
-- Return a list i.e., { "push", 34 }
-- code is a FIFO list
local function code_expr(state, node)
  --[[
  local pt = require "pt"
  print(pt.pt(state))
  --]]
  local code = state.code
  if node.tag == "numeral" then
    push(code, PUSH)
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
    if op == PUSH then
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
    elseif op == MOD then
      local right = pop(stack)
      local left = pop(stack)
      push(stack, left % right)
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
