local round, floor, ceil, abs, min, max

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
            local args = {...}
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
            local args = {...}
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

return {
    round = round,
    floor = floor,
    ceil = ceil,
    abs = abs,
    min = min,
    max = max
}