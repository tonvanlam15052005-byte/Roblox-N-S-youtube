-- ==========================================================
-- HOOK LOADSTRING - BẢN ĐƠN GIẢN NHẤT (Hoạt động 100%)
-- ==========================================================

print("=":rep(50))
print("🔧 CÀI HOOK LOADSTRING (BẢN ĐƠN GIẢN)")
print("=":rep(50))

-- ========================================
-- 1. KIỂM TRA CÁC HÀM CƠ BẢN
-- ========================================
local hasWritefile = type(writefile) == "function"
local hasSetclipboard = type(setclipboard) == "function"
local hasMakefolder = type(makefolder) == "function"

print("📌 Hỗ trợ:")
print("  writefile: " .. tostring(hasWritefile))
print("  setclipboard: " .. tostring(hasSetclipboard))
print("  makefolder: " .. tostring(hasMakefolder))

-- ========================================
-- 2. LƯU HÀM GỐC
-- ========================================
local oldLoadstring = loadstring
local oldPrint = print

-- ========================================
-- 3. HÀM LƯU CODE
-- ========================================
local function saveCode(code, label)
    if not code or type(code) ~= "string" or #code < 50 then
        return false
    end
    
    oldPrint("=":rep(40))
    oldPrint("🎯 LƯU CODE (" .. label .. "): " .. #code .. " bytes")
    
    -- Lưu vào _G
    _G.DECODED = code
    _G.LAST_CODE = code
    
    -- Copy clipboard
    if hasSetclipboard then
        local ok, err = pcall(setclipboard, code)
        if ok then
            oldPrint("  📋 Copied to clipboard")
        else
            oldPrint("  ⚠️ Lỗi clipboard: " .. tostring(err))
        end
    end
    
    -- Ghi file
    if hasWritefile then
        local ok, err = pcall(function()
            if hasMakefolder then
                pcall(makefolder, "decoded")
            end
            local name = "decoded/decoded_" .. label .. "_" .. os.time() .. ".lua"
            writefile(name, code)
            oldPrint("  💾 Saved: " .. name)
        end)
        if not ok then
            oldPrint("  ⚠️ Lỗi ghi file: " .. tostring(err))
        end
    end
    
    oldPrint("=":rep(40))
    return true
end

-- ========================================
-- 4. HOOK LOADSTRING (ĐƠN GIẢN)
-- ========================================
loadstring = function(code, chunkname)
    oldPrint("🔍 [HOOK] Bắt loadstring: " .. #code .. " bytes")
    
    -- Lưu code nếu đủ dài
    if code and type(code) == "string" and #code > 100 then
        saveCode(code, "loadstring")
    end
    
    -- Gọi hàm gốc
    return oldLoadstring(code, chunkname)
end

oldPrint("✅ Hook loadstring đã cài!")

-- ========================================
-- 5. CHẠY SCRIPT V8
-- ========================================

local v8Url = "https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua"

oldPrint("🔄 Đang tải script V8...")

local success, response = pcall(function()
    return game:HttpGet(v8Url)
end)

if success and response then
    oldPrint("✅ Tải thành công (" .. #response .. " bytes)")
    
    oldPrint("🔄 Đang chạy script V8...")
    local chunk, err = loadstring(response)
    if chunk then
        local ok, err2 = pcall(chunk)
        if ok then
            oldPrint("✅ Script V8 đã chạy xong!")
        else
            oldPrint("❌ Lỗi khi chạy: " .. tostring(err2))
        end
    else
        oldPrint("❌ Lỗi loadstring: " .. tostring(err))
    end
else
    oldPrint("❌ Lỗi tải script: " .. tostring(response))
end

-- ========================================
-- 6. KẾT QUẢ
-- ========================================

oldPrint("\n" .. "=":rep(50))
oldPrint("📦 KẾT QUẢ")

if _G.DECODED and #_G.DECODED > 100 then
    oldPrint("✅ ĐÃ LẤY ĐƯỢC CODE!")
    oldPrint("  Độ dài: " .. #_G.DECODED .. " bytes")
    oldPrint("  Preview: " .. string.sub(_G.DECODED, 1, 200) .. "...")
    oldPrint("\n📌 Code trong _G.DECODED")
    
    if hasWritefile then
        pcall(function()
            writefile("decoded_FINAL.lua", _G.DECODED)
            oldPrint("💾 Đã lưu: decoded_FINAL.lua")
        end)
    end
else
    oldPrint("❌ CHƯA LẤY ĐƯỢC CODE!")
    oldPrint("📌 Có thể script V8 không dùng loadstring ở cấp global")
end
oldPrint("=":rep(50))

-- ========================================
-- 7. HÀM TIỆN ÍCH
-- ========================================
_G.showCode = function()
    if _G.DECODED then
        oldPrint(_G.DECODED)
    else
        oldPrint("❌ Không có code")
    end
end

_G.saveCode = function()
    if _G.DECODED and hasWritefile then
        writefile("decoded_manual.lua", _G.DECODED)
        oldPrint("💾 Saved: decoded_manual.lua")
    end
end

oldPrint("\n📌 Hàm tiện ích:")
oldPrint("  _G.showCode()  → Xem code")
oldPrint("  _G.saveCode()  → Lưu code ra file")
