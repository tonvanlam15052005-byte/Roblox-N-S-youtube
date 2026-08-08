-- ==========================================================
-- SCRIPT TỐI GIẢN - Kiểm tra môi trường
-- ==========================================================

print("=== KIỂM TRA MÔI TRƯỜNG ===")

-- 1. Kiểm tra loadstring
local success, result = pcall(function()
    return loadstring("return 'hello'")()
end)
print("loadstring: " .. tostring(success) .. " - " .. tostring(result))

-- 2. Kiểm tra pcall
success, result = pcall(function()
    return 1 + 1
end)
print("pcall: " .. tostring(success) .. " - " .. tostring(result))

-- 3. Kiểm tra game
success, result = pcall(function()
    return game:GetService("Players")
end)
print("game: " .. tostring(success) .. " - " .. tostring(result))

-- 4. Kiểm tra HttpService
success, result = pcall(function()
    return game:GetService("HttpService")
end)
print("HttpService: " .. tostring(success) .. " - " .. tostring(result))

-- 5. Kiểm tra writefile
success, result = pcall(function()
    return writefile ~= nil
end)
print("writefile: " .. tostring(success) .. " - " .. tostring(result))

print("=== KẾT THÚC ===")

-- Nếu script này báo lỗi, môi trường đã bị hỏng nặng
