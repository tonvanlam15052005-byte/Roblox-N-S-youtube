-- ==========================================================
-- PHƯƠNG PHÁP MỚI: Dùng debug.getupvalue để lấy code
-- Không hook loadstring → KHÔNG stack overflow
-- ==========================================================

print("=":rep(50))
print("🔧 DÙNG DEBUG ĐỂ LẤY CODE")
print("=":rep(50))

-- ========================================
-- 1. Hàm lưu code (an toàn, không gây stack)
-- ========================================
local function saveCode(code, label)
    if not code or type(code) ~= "string" or #code < 100 then
        return -- Bỏ qua code quá ngắn (có thể không phải code chính)
    end
    
    _G.DECODED = code
    _G.LAST_CODE = code
    
    print("🎯 LƯU CODE (" .. label .. "): " .. #code .. " bytes")
    print("  Preview: " .. string.sub(code, 1, 100) .. "...")
    
    if setclipboard then
        pcall(setclipboard, code)
        print("  📋 Copied to clipboard")
    end
    
    if writefile then
        pcall(function()
            if makefolder then pcall(makefolder, "decoded") end
            local name = "decoded/decoded_" .. label .. "_" .. os.time() .. ".lua"
            writefile(name, code)
            print("  💾 Saved: " .. name)
        end)
    end
end

-- ========================================
-- 2. Hook debug.getinfo để bắt khi script load
-- ========================================
if debug and debug.getinfo then
    local oldGetinfo = debug.getinfo
    
    debug.getinfo = function(func, what)
        local info = oldGetinfo(func, what)
        
        -- Kiểm tra nếu là function mới được tạo từ code
        if info and info.source then
            local src = info.source
            -- Nếu source bắt đầu bằng "=" hoặc "@" và dài, có thể là code được load
            if src and #src > 100 and (string.sub(src, 1, 1) == "=" or string.sub(src, 1, 1) == "@") then
                -- Lấy code từ source
                local code = string.sub(src, 2) -- Bỏ ký tự đầu
                if #code > 100 then
                    saveCode(code, "debug")
                end
            end
        end
        
        return info
    end
    
    print("✅ Hook debug.getinfo đã cài!")
else
    print("❌ debug.getinfo không khả dụng")
end

-- ========================================
-- 3. Hook debug.getupvalue (bắt code từ closures)
-- ========================================
if debug and debug.getupvalue then
    local oldGetupvalue = debug.getupvalue
    
    debug.getupvalue = function(func, index)
        local name, value = oldGetupvalue(func, index)
        
        -- Nếu value là string dài, có thể là code
        if name and value and type(value) == "string" and #value > 500 then
            -- Kiểm tra xem có phải code Lua không
            if string.find(value, "function") or string.find(value, "loadstring") or string.find(value, "return") then
                saveCode(value, "upvalue")
            end
        end
        
        return name, value
    end
    
    print("✅ Hook debug.getupvalue đã cài!")
end

-- ========================================
-- 4. Ghi đè print để bắt output (có thể chứa code)
-- ========================================
local oldPrint = print
print = function(...)
    local args = {...}
    for _, arg in ipairs(args) do
        if type(arg) == "string" and #arg > 500 then
            -- Có thể đây là code được in ra
            if string.find(arg, "function") or string.find(arg, "loadstring") then
                saveCode(arg, "print")
            end
        end
    end
    return oldPrint(...)
end

print("✅ Hook print đã cài!")

-- ========================================
-- 5. Hook error để bắt stack trace (có thể chứa code)
-- ========================================
local oldError = error
error = function(msg, level)
    if type(msg) == "string" and #msg > 500 then
        saveCode(msg, "error")
    end
    return oldError(msg, level)
end

print("✅ Hook error đã cài!")

print("=":rep(50))
print("✅ TẤT CẢ HOOK ĐÃ SẴN SÀNG!")
print("=":rep(50))

-- ========================================
-- 6. CHẠY SCRIPT V8
-- ========================================

local v8Url = "https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua"

print("🔄 Đang tải script V8...")

local success, response = pcall(function()
    return game:HttpGet(v8Url)
end)

if success and response then
    print("✅ Tải thành công (" .. #response .. " bytes)")
    
    -- CHẠY TRONG XPCALL ĐỂ BẮT LỖI
    print("🔄 Đang chạy script V8...")
    local ok, err = xpcall(function()
        local chunk = loadstring(response)
        if chunk then
            chunk()
        else
            error("Lỗi loadstring")
        end
    end, function(errMsg)
        print("❌ LỖI: " .. tostring(errMsg))
        -- Lưu lỗi (có thể chứa code)
        if type(errMsg) == "string" and #errMsg > 100 then
            saveCode(errMsg, "error")
        end
    end)
    
    if ok then
        print("✅ Script V8 đã chạy xong!")
    else
        print("❌ Script V8 gặp lỗi!")
    end
else
    print("❌ Không thể tải script: " .. tostring(response))
end

-- ========================================
-- 7. KẾT QUẢ
-- ========================================

print("\n" .. "=":rep(50))
print("📦 KẾT QUẢ")

if _G.DECODED and #_G.DECODED > 100 then
    print("✅ ĐÃ LẤY ĐƯỢC CODE!")
    print("  Độ dài: " .. #_G.DECODED .. " bytes")
    print("  Preview: " .. string.sub(_G.DECODED, 1, 200) .. "...")
    print("\n📌 Code trong _G.DECODED")
    
    -- Lưu file cuối cùng
    if writefile then
        pcall(function()
            writefile("decoded_FINAL.lua", _G.DECODED)
            print("💾 Đã lưu: decoded_FINAL.lua")
        end)
    end
else
    print("❌ CHƯA LẤY ĐƯỢC CODE!")
    print("📌 Có thể script V8 không chạy hoặc không giải mã thành công")
end
print("=":rep(50))

-- ========================================
-- 8. HÀM TIỆN ÍCH
-- ========================================
_G.showCode = function()
    if _G.DECODED then
        print(_G.DECODED)
    else
        print("❌ Không có code")
    end
end

_G.saveCode = function()
    if _G.DECODED and writefile then
        writefile("decoded_manual.lua", _G.DECODED)
        print("💾 Saved: decoded_manual.lua")
    end
end

print("\n📌 Hàm tiện ích:")
print("  _G.showCode()  → Xem code")
print("  _G.saveCode()  → Lưu code ra file")
