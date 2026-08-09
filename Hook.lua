-- ==========================================================
-- KIỂM TRA MÔI TRƯỜNG DELTA
-- ==========================================================

print("=":rep(50))
print("🔍 KIỂM TRA MÔI TRƯỜNG")
print("=":rep(50))

local tests = {
    {name = "loadstring", func = function() return type(loadstring) end},
    {name = "print", func = function() return type(print) end},
    {name = "pcall", func = function() return type(pcall) end},
    {name = "game:HttpGet", func = function() return type(game.HttpGet) or type(game:HttpGet) end},
    {name = "writefile", func = function() return type(writefile) end},
    {name = "setclipboard", func = function() return type(setclipboard) end},
    {name = "debug", func = function() return type(debug) end},
    {name = "_G", func = function() return type(_G) end},
}

for _, test in ipairs(tests) do
    local ok, result = pcall(test.func)
    if ok then
        print("  " .. test.name .. ": " .. tostring(result))
    else
        print("  " .. test.name .. ": ERROR - " .. tostring(result))
    end
end

print("=":rep(50))
