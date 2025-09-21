local strlen, trim, ltrim, rtrim, strreplace, strpos, strtolower, strtoupper, strformat, strsplit

strlen = setmetatable(
    {
        type = "__function__",
        source = "strlen(text)\nReturns the length of the text"
    },
    {
        __call = function(self, text)
            return string.len(text)
        end
    }
)

trim = setmetatable(
    {
        type = "__function__",
        source = "trim(text)\nRemoves leading and trailing whitespace from text"
    },
    {
        __call = function(self, text)
            return (text:gsub("^%s*(.-)%s*$", "%1"))
        end
    }
)

ltrim = setmetatable(
    {
        type = "__function__",
        source = "ltrim(text)\nRemoves leading whitespace from text"
    },
    {
        __call = function(self, text)
            return (text:gsub("^%s*", ""))
        end
    }
)

rtrim = setmetatable(
    {
        type = "__function__",
        source = "rtrim(text)\nRemoves trailing whitespace from text"
    },
    {
        __call = function(self, text)
            return (text:gsub("%s*$", ""))
        end
    }
)

strreplace = setmetatable(
    {
        type = "__function__",
        source = "strreplace(text, find, replace)\nReplaces all occurrences of find with replace in text"
    },
    {
        __call = function(self, text, find, replace)
            return (text:gsub(find:gsub("[%(%)%.%%%+%-%*%?%[%^%$%]]", "%%%1"), replace))
        end
    }
)

strpos = setmetatable(
    {
        type = "__function__",
        source = "strpos(text, find)\nReturns the position of the first occurrence of find in text, or nil if not found"
    },
    {
        __call = function(self, text, find)
            local start = text:find(find, 1, true)
            return start
        end
    }
)

strtolower = setmetatable(
    {
        type = "__function__",
        source = "strtolower(text)\nConverts text to lowercase"
    },
    {
        __call = function(self, text)
            return string.lower(text)
        end
    }
)

strtoupper = setmetatable(
    {
        type = "__function__",
        source = "strtoupper(text)\nConverts text to uppercase"
    },
    {
        __call = function(self, text)
            return string.upper(text)
        end
    }
)

strformat = setmetatable(
    {
        type = "__function__",
        source = "strformat(format, ...)\nFormats a string using the given format and arguments"
    },
    {
        __call = function(self, format, ...)
            return string.format(format, ...)
        end
    }
)

strsplit = setmetatable(
    {
        type = "__function__",
        source = "strsplit(string, sep)\nSplits a string into an array using the sep separator."
    },
    {
        __call = function(self, str, sep)
            local result = {}
            for part in str:gmatch("[^" .. sep .. "]+") do
                table.insert(result, part)
            end
            return __ISOLATE__.createArray(result)
        end
    }
)

return {
    strlen = strlen,
    trim = trim,
    ltrim = ltrim,
    rtrim = rtrim,
    strreplace = strreplace,
    strpos = strpos,
    strtolower = strtolower,
    strtoupper = strtoupper,
    strformat = strformat,
    strsplit = strsplit
}
