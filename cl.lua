-- ==========================================================
-- TẠO MÔI TRƯỜNG SẠCH - TRÁNH BỊ GHI ĐÈ
-- ==========================================================

print("=":rep(50))
print("🔧 TẠO MÔI TRƯỜNG SẠCH")
print("=":rep(50))

-- ========================================
-- 1. LƯU CÁC HÀM GỐC VÀO BIẾN CỤC BỘ
-- ========================================
local _LOADSTRING = loadstring
local _WRITEFILE = writefile
local _SETCLIPBOARD = setclipboard
local _MAKEFOLDER = makefolder
local _PCALL = pcall
local _XPCALL = xpcall
local _GETFENV = getfenv
local _SETFENV = setfenv
local _PRINT = print
local _TYPE = type
local _TONUMBER = tonumber
local _TOSTRING = tostring

print("✅ Đã lưu các hàm gốc")

-- ========================================
-- 2. TẠO MÔI TRƯỜNG SẠCH
-- ========================================
local cleanEnv = {
    -- Các hàm cơ bản
    print = _PRINT,
    pcall = _PCALL,
    xpcall = _XPCALL,
    getfenv = _GETFENV,
    setfenv = _SETFENV,
    loadstring = _LOADSTRING,
    load = _LOADSTRING,
    type = _TYPE,
    tonumber = _TONUMBER,
    tostring = _TOSTRING,
    
    -- Các hàm Delta
    writefile = _WRITEFILE,
    setclipboard = _SETCLIPBOARD,
    makefolder = _MAKEFOLDER,
    
    -- Các hàm game
    game = game,
    workspace = workspace,
    players = game:GetService("Players"),
    http = game:GetService("HttpService"),
    
    -- Bảng
    string = string,
    table = table,
    math = math,
    os = os,
    debug = debug,
}

-- ========================================
-- 3. HÀM LƯU CODE (DÙNG HÀM GỐC)
-- ========================================
local function saveCode(code, label)
    if not code or _TYPE(code) ~= "string" or #code < 50 then
        return false
    end
    
    _PRINT("=":rep(40))
    _PRINT("🎯 LƯU CODE (" .. label .. "): " .. #code .. " bytes")
    
    -- Lưu vào _G
    _G.DECODED = code
    _G.LAST_CODE = code
    
    -- Copy clipboard
    if _SETCLIPBOARD then
        local ok = _PCALL(_SETCLIPBOARD, code)
        if ok then _PRINT("  📋 Copied to clipboard") end
    end
    
    -- Ghi file
    if _WRITEFILE then
        local ok = _PCALL(function()
            if _MAKEFOLDER then
                _PCALL(_MAKEFOLDER, "decoded")
            end
            local name = "decoded/decoded_" .. label .. "_" .. os.time() .. ".lua"
            _WRITEFILE(name, code)
            _PRINT("  💾 Saved: " .. name)
        end)
    end
    
    _PRINT("=":rep(40))
    return true
end

-- ========================================
-- 4. HOOK LOADSTRING TRONG MÔI TRƯỜNG SẠCH
-- ========================================
cleanEnv.loadstring = function(code, chunkname)
    _PRINT("🔍 [HOOK] Bắt loadstring: " .. #code .. " bytes")
    
    -- Lưu code
    if code and _TYPE(code) == "string" and #code > 100 then
        saveCode(code, "loadstring")
    end
    
    -- Gọi loadstring gốc
    return _LOADSTRING(code, chunkname)
end

-- ========================================
-- 5. CHẠY SCRIPT V8 TRONG MÔI TRƯỜNG SẠCH
-- ========================================

local v8Url = "https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua"

_PRINT("🔄 Đang tải script V8...")

local success, response = _PCALL(function()
    -- Dùng http của game
    return game:HttpGet(v8Url)
end)

if success and response then
    _PRINT("✅ Tải thành công (" .. #response .. " bytes)")
    
    -- Tạo function để chạy trong môi trường sạch
    local chunk, err = _LOADSTRING(response)
    if chunk then
        _PRINT("🔄 Đang chạy script V8 trong môi trường sạch...")
        
        -- Chạy trong xpcall để bắt lỗi
        local ok, err2 = _XPCALL(function()
            -- Thiết lập môi trường cho script
            setfenv(chunk, cleanEnv)
            chunk()
        end, function(errMsg)
            _PRINT("❌ LỖI: " .. _TOSTRING(errMsg))
            -- Lưu lỗi nếu có
            if errMsg and _TYPE(errMsg) == "string" and #errMsg > 100 then
                saveCode(errMsg, "error")
            end
            return errMsg
        end)
        
        if ok then
            _PRINT("✅ Script V8 đã chạy xong!")
        else
            _PRINT("❌ Script V8 gặp lỗi: " .. _TOSTRING(err2))
        end
    else
        _PRINT("❌ Lỗi loadstring: " .. _TOSTRING(err))
    end
else
    _PRINT("❌ Lỗi tải script: " .. _TOSTRING(response))
end

-- ========================================
-- 6. KẾT QUẢ
-- ========================================

_PRINT("\n" .. "=":rep(50))
_PRINT("📦 KẾT QUẢ")

if _G.DECODED and #_G.DECODED > 100 then
    _PRINT("✅ ĐÃ LẤY ĐƯỢC CODE!")
    _PRINT("  Độ dài: " .. #_G.DECODED .. " bytes")
    _PRINT("  Preview: " .. string.sub(_G.DECODED, 1, 200) .. "...")
    _PRINT("\n📌 Code trong _G.DECODED")
    
    if _WRITEFILE then
        _PCALL(function()
            _WRITEFILE("decoded_FINAL.lua", _G.DECODED)
            _PRINT("💾 Đã lưu: decoded_FINAL.lua")
        end)
    end
else
    _PRINT("❌ CHƯA LẤY ĐƯỢC CODE!")
    _PRINT("📌 Có thể script V8 không dùng loadstring")
    _PRINT("📌 Hoặc nó tự giải mã và chạy mà không qua loadstring")
end
_PRINT("=":rep(50))

-- ========================================
-- 7. HÀM TIỆN ÍCH
-- ========================================
_G.showCode = function()
    if _G.DECODED then
        _PRINT(_G.DECODED)
    else
        _PRINT("❌ Không có code")
    end
end

_G.saveCode = function()
    if _G.DECODED and _WRITEFILE then
        _WRITEFILE("decoded_manual.lua", _G.DECODED)
        _PRINT("💾 Saved: decoded_manual.lua")
    end
end

_PRINT("\n📌 Hàm tiện ích:")
_PRINT("  _G.showCode()  → Xem code")
_PRINT("  _G.saveCode()  → Lưu code ra file")
