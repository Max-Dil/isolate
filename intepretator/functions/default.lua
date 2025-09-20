local print, pcall, time, clock, type, tostring, tonumber, next, error, foreach

do
    local serializeTable
    function serializeTable(tbl, indent, visited)
        local function serializeValue(value, indent, visited)
            if _G.type(value) == "table" then
                return serializeTable(value, indent, visited)
            elseif _G.type(value) == "string" then
                return string.format("%q", value)
            elseif _G.type(value) == "nil" then
                return "nil"
            elseif _G.type(value) == "boolean" then
                return tostring(value)
            else
                return tostring(value)
            end
        end

        indent = indent or 0
        visited = visited or {}
        local indentStr = string.rep("  ", indent)
        local result = "{\n"

        if visited[tbl] then
            return indentStr .. "[cyclic table]"
        end
        visited[tbl] = true

        local first = true
        for key, value in pairs(tbl) do
            if not first then
                result = result .. ",\n"
            end
            first = false

            local keyStr
            if _G.type(key) == "string" and key:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
                keyStr = key
            else
                keyStr = "[" .. serializeValue(key, indent + 1, visited) .. "]"
            end

            local valueStr = serializeValue(value, indent + 1, visited)
            result = result .. indentStr .. "  " .. keyStr .. " = " .. valueStr
        end

        result = result .. "\n" .. indentStr .. "}"
        visited[tbl] = nil
        return result
    end

    local origPrint = _G.print
    print = setmetatable({ type = "__function__", source = "print(arg1, ...arg)\nOutputs a message to the console." },
        {
            __call = function(self, ...)
                local t = { ... }
                for index, value in ipairs(t) do
                    if _G.type(value) == "table" then
                        if value.type and value.type == "__function__" then
                            t[index] = "(Function)\nlink: " ..
                                tostring(value) ..
                                "\nsource:\n" .. (value.source or "Not found") .. "\n(end Function)"
                        else
                            t[index] = tostring(value) .. "\nbody: " .. serializeTable(value) .. "\n(end)"
                        end
                    else
                        t[index] = tostring(value)
                    end
                end
                origPrint(table.concat(t, " "))
            end
        }
    )
end

pcall = setmetatable(
    { type = "__function__", source =
    "pcall(func, ...arg)\nCalls function with arguments in protected mode, returns {success, result_or_error}" },
    {
        __call = function(self, func, ...)
            if _G.type(func) ~= "table" or func.type ~= "__function__" then
                _G.error("pcall: First argument must be a function", 2)
            end
            local args = { ... }
            local success, result = _G.pcall(function()
                return func(unpack(args))
            end)
            return __ISOLATE__.createArray({ success, result })
        end
    }
)

time = setmetatable({ type = "__function__", source = "time([date])\nReturns the current time in seconds" },
    {
        __call = function(self, date)
            return os.time(date)
        end
    }
)

clock = setmetatable({ type = "__function__", source = "clock()\nReturns the current time in milliseconds" },
    {
        __call = function(self)
            return os.clock()
        end
    }
)

type = setmetatable({ type = "__function__", source = "type(object)\nReturns the type of the variable" },
    {
        __call = function(self, object)
            local _type = _G.type(object)

            if _type == "table" then
                if object.type and object.type == "__function__" then
                    _type = "function"
                elseif __ISOLATE__.analizy_array(object) then
                    _type = "array"
                end
            end

            return _type
        end
    }
)

tostring = setmetatable({ type = "__function__", source = "tostring(value)\nConverts the value to a string" },
    {
        __call = function(self, value)
            return _G.tostring(value)
        end
    }
)

tonumber = setmetatable({ type = "__function__", source = "tonumber(value)\nConverts the value to a number" },
    {
        __call = function(self, value)
            return _G.tonumber(value)
        end
    }
)

next = setmetatable(
    { type = "__function__", source = "next(table, [index])\nReturns the following key-value pair in the table." },
    {
        __call = function(self, table, index)
            return __ISOLATE__.createArray({ _G.next(table, index) })
        end
    }
)

error = setmetatable(
    { type = "__function__", source = "error(message, [level])\nCauses an error with the specified message.." },
    {
        __call = function(self, message, level)
            _G.error(message, level)
        end
    }
)

foreach = setmetatable(
    { type = "__function__", source =
    "foreach(table or array, callback)\nIt goes through a table or array and calls a callback(key or index, value) for each element." },
    {
        __call = function(self, table, callback)
            if _G.type(table) ~= "table" then
                _G.error("foreach accepts only arrays or tables", 2)
            end

            if type(table) == "table" then
                for key, value in pairs(table) do
                    callback(key, value)
                end
            else
                for index, value in ipairs(table) do
                    callback(index, value)
                end
            end
        end
    }
)

return {
    print = print,
    pcall = pcall,
    time = time,
    clock = clock,
    type = type,
    tostring = tostring,
    tonumber = tonumber,
    next = next,
    error = error,
    foreach = foreach,
}
