-- ==========================================================
-- KIỂM TRA MÔI TRƯỜNG DELTA
-- ==========================================================

print("=":rep(50))
print("🔍 KIỂM TRA MÔI TRƯỜNG")
print("=":rep(50))

-- Kiểm tra các hàm
local functions = {
    "loadstring", "load", "loadfile",
    "writefile", "setclipboard", "makefolder",
    "game.HttpGet", "game:HttpGet",
    "pcall", "xpcall",
    "debug.getinfo", "debug.getupvalue"
}

for _, func in ipairs(functions) do
    local ok, result = pcall(function()
        if string.find(func, "%.") then
            local parts = {}
            for part in string.gmatch(func, "[^%.]+") do
                table.insert(parts, part)
            end
            local obj = _G
            for _, part in ipairs(parts) do
                obj = obj[part]
                if not obj then break end
            end
            return obj ~= nil
        else
            return _G[func] ~= nil
        end
    end)
    if ok then
        print("  " .. func .. ": " .. tostring(result))
    else
        print("  " .. func .. ": ERROR - " .. tostring(result))
    end
end

print("=":rep(50))
