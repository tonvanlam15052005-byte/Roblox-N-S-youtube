-- ==========================================================
-- KIỂM TRA MÔI TRƯỜNG (CHỈ DÙNG PRINT)
-- ==========================================================

print("=== KIỂM TRA MÔI TRƯỜNG ===")

-- Kiểm tra các hàm
local tests = {
    "loadstring", "load", "print", "pcall", "xpcall",
    "getfenv", "setfenv", "debug"
}

for _, name in ipairs(tests) do
    local status = _G[name] ~= nil
    print(name .. ": " .. tostring(status))
end

-- Kiểm tra debug
if debug then
    print("debug.getinfo: " .. tostring(debug.getinfo ~= nil))
    print("debug.getregistry: " .. tostring(debug.getregistry ~= nil))
end

print("=== KẾT THÚC ===")
