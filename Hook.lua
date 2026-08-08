-- ==========================================================
-- SCRIPT HOOK AN TOÀN - CHỈ DÙNG HÀM CÓ SẴN
-- ==========================================================

print("=":rep(50))
print("🔧 CÀI HOOK AN TOÀN (KHÔNG DEBUG)")
print("=":rep(50))

-- ========================================
-- 1. KIỂM TRA HÀM HỖ TRỢ
-- ========================================
local hasWritefile = type(writefile) == "function"
local hasSetclipboard = type(setclipboard) == "function"
local hasMakefolder = type(makefolder) == "function"
local hasHttpGet = type(game.HttpGet) == "function" or type(game:HttpGet) == "function"

print("📌 Hỗ trợ:")
print("  writefile: " .. tostring(hasWritefile))
print("  setclipboard: " .. tostring(hasSetclipboard))
print("  makefolder: " .. tostring(hasMakefolder))
print("  HttpGet: " .. tostring(hasHttpGet))

-- ========================================
-- 2. HÀM LƯU CODE (AN TOÀN)
-- ========================================
local function saveCode(code, label)
    if not code or type(code) ~= "string" or #code < 50 then
        return
    end
    
    -- Lưu vào _G
    _G.DECODED = code
    _G.LAST_CODE = code
    
    print("🎯 LƯU CODE (" .. label .. "): " .. #code .. " bytes")
    
    -- Copy clipboard
    if hasSetclipboard then
        pcall(setclipboard, code)
        print("  📋 Copied to clipboard")
    end
    
    -- Ghi file
    if hasWritefile then
        pcall(function()
            if hasMakefolder then
                pcall(makefolder, "decoded")
            end
            local name = "decoded/decoded_" .. label .. "_" .. os.time() .. ".lua"
            writefile(name, code)
            print("  💾 Saved: " .. name)
        end)
    end
end

-- ========================================
-- 3. HOOK LOADSTRING (ĐƠN GIẢN, AN TOÀN)
-- ========================================
local oldLoadstring = loadstring

loadstring = function(code, chunkname)
    -- Lưu code
    if code and type(code) == "string" and #code > 100 then
        saveCode(code, "loadstring")
    end
    
    -- Gọi hàm gốc
    return oldLoadstring(code, chunkname)
end

print("✅ Hook loadstring đã cài!")

-- ========================================
-- 4. HOOK LOAD (NẾU CÓ)
-- ========================================
if type(load) == "function" then
    local oldLoad = load
    load = function(code, chunkname, mode, env)
        if code and type(code) == "string" and #code > 100 then
            saveCode(code, "load")
        end
        return oldLoad(code, chunkname, mode, env)
    end
    print("✅ Hook load đã cài!")
end

-- ========================================
-- 5. HOOK GAME:HTTPGET (ĐỂ BẮT SCRIPT TẢI TỪ WEB)
-- ========================================
if type(game.HttpGet) == "function" then
    local oldHttpGet = game.HttpGet
    game.HttpGet = function(self, url, cache)
        print("🌐 HttpGet: " .. url)
        local result = oldHttpGet(self, url, cache)
        if result and type(result) == "string" and #result > 100 then
            -- Kiểm tra xem có phải script Lua không
            if string.find(result, "function") or string.find(result, "loadstring") then
                saveCode(result, "httpget")
            end
        end
        return result
    end
    print("✅ Hook game.HttpGet đã cài!")
end

-- ========================================
-- 6. HOOK GAME:HTTPGET (CÁCH 2)
-- ========================================
if type(game:HttpGet) == "function" then
    local oldHttpGet = game.HttpGet or game:HttpGet
    game.HttpGet = function(self, url, cache)
        print("🌐 HttpGet (method): " .. url)
        local result = oldHttpGet(self, url, cache)
        if result and type(result) == "string" and #result > 100 then
            if string.find(result, "function") or string.find(result, "loadstring") then
                saveCode(result, "httpget_method")
            end
        end
        return result
    end
    print("✅ Hook game:HttpGet đã cài!")
end

print("=":rep(50))
print("✅ TẤT CẢ HOOK ĐÃ SẴN SÀNG!")
print("=":rep(50))

-- ========================================
-- 7. CHẠY SCRIPT V8
-- ========================================

local v8Url = "https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua"

print("🔄 Đang tải script V8...")

local success, response = pcall(function()
    if type(game:HttpGet) == "function" then
        return game:HttpGet(v8Url)
    elseif type(game.HttpGet) == "function" then
        return game.HttpGet(game, v8Url)
    else
        error("Không có hàm HttpGet")
    end
end)

if success and response then
    print("✅ Tải thành công (" .. #response .. " bytes)")
    
    print("🔄 Đang chạy script V8...")
    local chunk, err = loadstring(response)
    if chunk then
        local ok, err2 = pcall(chunk)
        if ok then
            print("✅ Script V8 đã chạy xong!")
        else
            print("❌ Lỗi khi chạy: " .. tostring(err2))
        end
    else
        print("❌ Lỗi loadstring: " .. tostring(err))
    end
else
    print("❌ Lỗi tải script: " .. tostring(response))
end

-- ========================================
-- 8. KẾT QUẢ
-- ========================================

print("\n" .. "=":rep(50))
print("📦 KẾT QUẢ")

if _G.DECODED and #_G.DECODED > 100 then
    print("✅ ĐÃ LẤY ĐƯỢC CODE!")
    print("  Độ dài: " .. #_G.DECODED .. " bytes")
    print("  Preview: " .. string.sub(_G.DECODED, 1, 200) .. "...")
    print("\n📌 Code trong _G.DECODED")
    
    if hasWritefile then
        pcall(function()
            writefile("decoded_FINAL.lua", _G.DECODED)
            print("💾 Đã lưu: decoded_FINAL.lua")
        end)
    end
else
    print("❌ CHƯA LẤY ĐƯỢC CODE!")
    print("📌 Có thể script V8 không dùng loadstring ở cấp global")
    print("📌 Hoặc nó đã tự giải mã và chạy mà không qua loadstring")
end
print("=":rep(50))

-- ========================================
-- 9. HÀM TIỆN ÍCH
-- ========================================
_G.showCode = function()
    if _G.DECODED then
        print(_G.DECODED)
    else
        print("❌ Không có code")
    end
end

_G.saveCode = function()
    if _G.DECODED and hasWritefile then
        writefile("decoded_manual.lua", _G.DECODED)
        print("💾 Saved: decoded_manual.lua")
    end
end

print("\n📌 Hàm tiện ích:")
print("  _G.showCode()  → Xem code")
print("  _G.saveCode()  → Lưu code ra file")
