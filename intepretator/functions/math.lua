local round, floor, ceil, abs, min, max, sqrt, pow, sin, rad, deg, log, random, randomseed, cos, tan

round = setmetatable(
    {
        type = "__function__",
        source = "round(number, [decimals])\nRounds number to the nearest integer or specified decimal places"
    },
    {
        __call = function(self, num, decimals)
            if type(num) ~= "number" then
                error("round: First argument must be a number", 2)
            end
            decimals = decimals or 0
            if type(decimals) ~= "number" then
                error("round: Second argument must be a number", 2)
            end
            local mult = 10 ^ decimals
            return math.floor(num * mult + 0.5) / mult
        end
    }
)

floor = setmetatable(
    {
        type = "__function__",
        source = "floor(number)\nReturns the largest integer less than or equal to number"
    },
    {
        __call = function(self, num)
            if type(num) ~= "number" then
                error("floor: Argument must be a number", 2)
            end
            return math.floor(num)
        end
    }
)

ceil = setmetatable(
    {
        type = "__function__",
        source = "ceil(number)\nReturns the smallest integer greater than or equal to number"
    },
    {
        __call = function(self, num)
            if type(num) ~= "number" then
                error("ceil: Argument must be a number", 2)
            end
            return math.ceil(num)
        end
    }
)

abs = setmetatable(
    {
        type = "__function__",
        source = "abs(number)\nReturns the absolute value of number"
    },
    {
        __call = function(self, num)
            if type(num) ~= "number" then
                error("abs: Argument must be a number", 2)
            end
            return math.abs(num)
        end
    }
)

min = setmetatable(
    {
        type = "__function__",
        source = "min(...)\nReturns the minimum value from a list of numbers"
    },
    {
        __call = function(self, ...)
            local args = { ... }
            if #args == 0 then
                error("min: At least one number must be provided", 2)
            end
            for i, v in ipairs(args) do
                if type(v) ~= "number" then
                    error("min: All arguments must be numbers", 2)
                end
            end
            return math.min(...)
        end
    }
)

max = setmetatable(
    {
        type = "__function__",
        source = "max(...)\nReturns the maximum value from a list of numbers"
    },
    {
        __call = function(self, ...)
            local args = { ... }
            if #args == 0 then
                error("max: At least one number must be provided", 2)
            end
            for i, v in ipairs(args) do
                if type(v) ~= "number" then
                    error("max: All arguments must be numbers", 2)
                end
            end
            return math.max(...)
        end
    }
)

sqrt = setmetatable(
    {
        type = "__function__",
        source = "sqrt(number)\nReturns the square root of a number"
    },
    {
        __call = function(self, num)
            if type(num) ~= "number" then
                error("sqrt: Argument must be a number", 2)
            end
            return math.sqrt(num)
        end
    }
)

pow = setmetatable(
    {
        type = "__function__",
        source = "pow(base, exp)\nRaises the base number to the power of exp"
    },
    {
        __call = function(self, base, exp)
            if type(base) ~= "number" then
                error("pow: Argument must be a number", 2)
            end
            return base ^ exp
        end
    }
)

sin = setmetatable(
    {
        type = "function",
        source = "sin(number)\nReturns the sine of a number in radians"
    },
    {
        __call = function(self, num)
            if type(num) ~= "number" then
                error("sin: Argument must be a number", 2)
            end
            return math.sin(num)
        end
    }
)

cos = setmetatable(
    {
        type = "function",
        source = "cos(number)\nReturns the cosine of a number in radians"
    },
    {
        __call = function(self, num)
            if type(num) ~= "number" then
                error("cos: Argument must be a number", 2)
            end
            return math.cos(num)
        end
    }
)

tan = setmetatable(
    {
        type = "function",
        source = "tan(number)\nReturns the tangent of a number in radians"
    },
    {
        __call = function(self, num)
            if type(num) ~= "number" then
                error("tan: Argument must be a number", 2)
            end
            return math.tan(num)
        end
    }
)
rad = setmetatable(
    {
        type = "function",
        source = "rad(degrees)\nConverts degrees to radians"
    },
    {
        __call = function(self, degrees)
            if type(degrees) ~= "number" then
                error("rad: Argument must be a number", 2)
            end
            return math.rad(degrees)
        end
    }
)
deg = setmetatable(
    {
        type = "function",
        source = "deg(radians)\nConverts radians to degrees"
    },
    {
        __call = function(self, radians)
            if type(radians) ~= "number" then
                error("deg: Argument must be a number", 2)
            end
            return math.deg(radians)
        end
    }
)
log = setmetatable(
    {
        type = "function",
        source =
        "log(number, [base])\nReturns the logarithm of number to the given base (natural log if base is omitted)"
    },
    {
        __call = function(self, num, base)
            if type(num) ~= "number" then
                error("log: First argument must be a number", 2)
            end
            if base ~= nil and type(base) ~= "number" then
                error("log: Base must be a number", 2)
            end
            if base then
                return math.log(num) / math.log(base)
            else
                return math.log(num)
            end
        end
    }
)

random = setmetatable(
    {
        type = "function",
        source =
        "random([min, max])\nReturns a random number. If no arguments, between 0 and 1; if one argument, integer from 1 to min; if two, integer from min to max"
    },
    {
        __call = function(self, min, max)
            if min ~= nil and type(min) ~= "number" then
                error("random: Arguments must be numbers", 2)
            end
            if max ~= nil and type(max) ~= "number" then
                error("random: Arguments must be numbers", 2)
            end
            if min == nil and max == nil then
                return math.random()
            elseif max == nil then
                return math.random(min)
            else
                return math.random(min, max)
            end
        end
    }
)

randomseed = setmetatable(
    {
        type = "function",
        source = "randomseed(seed)\nSets the seed for the random number generator"
    },
    {
        __call = function(self, seed)
            if type(seed) ~= "number" then
                error("randomseed: Seed must be a number", 2)
            end
            math.randomseed(seed)
        end
    }
)

return {
    round = round,
    floor = floor,
    ceil = ceil,
    abs = abs,
    min = min,
    max = max,
    sqrt = sqrt,
    pow = pow,
    sin = sin,
    cos = cos,
    tan = tan,
    rad = rad,
    deg = deg,
    log = log,
    random = random,
    randomseed = randomseed
}
