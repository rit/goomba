local lpeg = require "lpeg"
local pt = require "pt"


local M = {}

function fold(rows)
  local acc = rows[1]
  -- print(pt.pt(rows))
  for i=2, #rows, 2 do
    local op, right = rows[i], rows[i+1]
    if op == "-" then
      acc = acc - right
    elseif op == "+" then
      acc = acc + right
    elseif op == "*" then
      acc = acc * right
    elseif op == "/" then
      acc = acc / right
    end
  end
  return acc
end

local space = lpeg.S(" \n\t")^0
local OP = "(" * space
local CP = ")" * space
local nbr = lpeg.P("-")^-1 * lpeg.R("09")^1 / tonumber * space
local opA = lpeg.C(lpeg.S("+-")) * space
local opM = lpeg.C(lpeg.S("*/")) * space

local primary = lpeg.V"primary"
local term = lpeg.V"term"
local expr = lpeg.V"expr"

local g = lpeg.P{
  "expr",
  primary = space * nbr + (OP * expr * CP),
  term = space * lpeg.Ct(primary * (opM * primary)^0) / fold,
  expr = space *lpeg.Ct(term * (opA * term)^0) / fold
}
g = g * -1


function M.calc(input)
  return g:match(input)
end

return M
