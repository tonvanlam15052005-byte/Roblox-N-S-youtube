-- ==========================================================
-- HOOK LOADSTRING - DÙNG GETFENV (KHÔNG DÙNG _G)
-- ==========================================================

print("=":rep(50))
print("🔧 CÀI HOOK LOADSTRING (DÙNG GETFENV)")
print("=":rep(50))

-- ========================================
-- 1. LẤY MÔI TRƯỜNG HIỆN TẠI
-- ========================================
local env = getfenv()
local oldPrint = print
local oldLoadstring = loadstring

-- ========================================
-- 2. KIỂM TRA HÀM HỖ TRỢ
-- ========================================
local hasWritefile = type(writefile) == "function"
local hasSetclipboard = type(setclipboard) == "function"
local hasMakefolder = type(makefolder) == "function"

oldPrint("📌 Hỗ trợ:")
oldPrint("  writefile: " .. tostring(hasWritefile))
oldPrint("  setclipboard: " .. tostring(hasSetclipboard))
oldPrint("  makefolder: " .. tostring(hasMakefolder))

-- ========================================
-- 3. HÀM LƯU CODE (DÙNG BIẾN CỤC BỘ TRONG ENV)
-- ========================================
local function saveCode(code, label)
    if not code or type(code) ~= "string" or #code < 50 then
        return false
    end
    
    oldPrint("=":rep(40))
    oldPrint("🎯 LƯU CODE (" .. label .. "): " .. #code .. " bytes")
    
    -- Lưu vào environment thay vì _G
    env.DECODED = code
    env.LAST_CODE = code
    
    -- Copy clipboard
    if hasSetclipboard then
        pcall(setclipboard, code)
        oldPrint("  📋 Copied to clipboard")
    end
    
    -- Ghi file
    if hasWritefile then
        pcall(function()
            if hasMakefolder then
                pcall(makefolder, "decoded")
            end
            local name = "decoded/decoded_" .. label .. "_" .. os.time() .. ".lua"
            writefile(name, code)
            oldPrint("  💾 Saved: " .. name)
        end)
    end
    
    oldPrint("=":rep(40))
    return true
end

-- ========================================
-- 4. HOOK LOADSTRING
-- ========================================
loadstring = function(code, chunkname)
    oldPrint("🔍 [HOOK] Bắt loadstring: " .. #code .. " bytes")
    
    if code and type(code) == "string" and #code > 100 then
        saveCode(code, "loadstring")
    end
    
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

local decoded = env.DECODED or env.LAST_CODE

if decoded and #decoded > 100 then
    oldPrint("✅ ĐÃ LẤY ĐƯỢC CODE!")
    oldPrint("  Độ dài: " .. #decoded .. " bytes")
    oldPrint("  Preview: " .. string.sub(decoded, 1, 200) .. "...")
    oldPrint("\n📌 Code trong: getfenv().DECODED")
    
    if hasWritefile then
        pcall(function()
            writefile("decoded_FINAL.lua", decoded)
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
env.showCode = function()
    local code = env.DECODED or env.LAST_CODE
    if code then
        oldPrint(code)
    else
        oldPrint("❌ Không có code")
    end
end

env.saveCode = function()
    local code = env.DECODED or env.LAST_CODE
    if code and hasWritefile then
        writefile("decoded_manual.lua", code)
        oldPrint("💾 Saved: decoded_manual.lua")
    end
end

oldPrint("\n📌 Hàm tiện ích:")
oldPrint("  getfenv().showCode()  → Xem code")
oldPrint("  getfenv().saveCode()  → Lưu code ra file")
