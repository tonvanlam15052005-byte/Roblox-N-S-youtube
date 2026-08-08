-- ==========================================================
-- RESET MÔI TRƯỜNG - Khôi phục các hàm bị hỏng
-- ==========================================================

print("🔄 Đang reset môi trường...")

-- Lưu các hàm từ environment gốc (nếu có)
local env = getfenv()
local originalFunctions = {}

-- Tìm và khôi phục các hàm bị mất
local function restoreFunction(name, fallback)
    if env[name] == nil then
        -- Thử tìm trong _G
        if _G[name] ~= nil then
            env[name] = _G[name]
            print("  ✅ Khôi phục " .. name .. " từ _G")
        -- Thử tạo hàm giả
        elseif fallback then
            env[name] = fallback
            print("  ⚠️ Tạo hàm giả cho " .. name)
        else
            print("  ❌ Không thể khôi phục " .. name)
        end
    else
        print("  ✅ " .. name .. " đã tồn tại")
    end
end

-- Kiểm tra và khôi phục các hàm cần thiết
restoreFunction("loadstring", function(code) return loadstring(code) end)
restoreFunction("pcall", function(f, ...) return pcall(f, ...) end)
restoreFunction("xpcall", function(f, err) return xpcall(f, err) end)
restoreFunction("print", function(...) return print(...) end)
restoreFunction("getfenv", function() return getfenv() end)
restoreFunction("setfenv", function(env) return setfenv(env) end)
restoreFunction("game", game)
restoreFunction("HttpService", game:GetService("HttpService"))

print("✅ Reset hoàn tất!")
