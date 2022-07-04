local lpeg = require "lpeg"
local pt = require "pt"


local M = {}

function fold(rows)
  local acc = rows[1]
  for i=2, #rows do
    acc = acc + rows[i]
  end
  return acc
end

local space = lpeg.S(" \n\t")^0
local nbr = lpeg.R("09")^1 / tonumber * space
local plus = lpeg.P("+") * space
local parser = space * lpeg.Ct(nbr * (plus * nbr)^0) / fold * -1


function M.calc(input)
  return parser:match(input)
end

return M
