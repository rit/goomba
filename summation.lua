local lpeg = require "lpeg"

local nbr = lpeg.R("09")
local space = lpeg.P(" ")
local plus = lpeg.P("+")
local sum = nbr * (space^0 * plus * space^0 * nbr)^0

local matched = sum:match("1 + 2 + 3")
print(matched)

local matched = sum:match("1 + 2 + 3 + 4")
print(matched)

local matched = sum:match("1")
print(matched)
