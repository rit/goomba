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
    end
  end
  return acc
end

local space = lpeg.S(" \n\t")^0
local nbr = lpeg.P("-")^-1 * lpeg.R("09")^1 / tonumber * space
local opA = lpeg.C(lpeg.S("+-")) * space
local parser = space *lpeg.Ct(nbr * (opA * nbr)^0) / fold * -1


function M.calc(input)
  return parser:match(input)
end

return M
