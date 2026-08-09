-- ==========================================================
-- SCRIPT HOOK THUẦN TÚY - BẮT CODE LUGRAPH
-- KHÔNG CHẠY V8, BẠN TỰ CHẠY SAU
-- ==========================================================

print("=":rep(60))
print("🔧 HOOK THUẦN TÚY - BẮT CODE LUGRAPH")
print("=":rep(60))

-- ==========================================================
-- 1. KIỂM TRA HÀM CÓ SẴN (KHÔNG GÂY LỖI)
-- ==========================================================
local function hasFunction(name)
    local ok, result = pcall(function()
        return _G[name] ~= nil
    end)
    return ok and result
end

local hasLoadstring = hasFunction("loadstring")
local hasPrint = hasFunction("print")
local hasPcall = hasFunction("pcall")

print("📌 Hỗ trợ:")
print("  loadstring: " .. tostring(hasLoadstring))
print("  print: " .. tostring(hasPrint))
print("  pcall: " .. tostring(hasPcall))

if not hasLoadstring then
    print("❌ loadstring không tồn tại! Không thể hook.")
    return
end

-- ==========================================================
-- 2. LƯU HÀM GỐC (AN TOÀN)
-- ==========================================================
local oldLoadstring = loadstring
local oldPrint = print

-- ==========================================================
-- 3. BIẾN LƯU CODE
-- ==========================================================
local HookData = {
    count = 0,
    codes = {}
}

-- ==========================================================
-- 4. HÀM LƯU CODE (CHỈ DÙNG PRINT)
-- ==========================================================
local function saveCode(code, label)
    if not code or type(code) ~= "string" then
        return false
    end
    
    if #code < 100 then
        return false
    end
    
    -- Chỉ bắt code có dấu hiệu Lua
    if not (string.find(code, "function") or string.find(code, "return") or string.find(code, "local")) then
        return false
    end
    
    HookData.count = HookData.count + 1
    HookData.codes[HookData.count] = {
        label = label,
        code = code,
        size = #code
    }
    
    print("=":rep(50))
    print("🎯 BẮT CODE #" .. HookData.count .. " [" .. label .. "]")
    print("  Size: " .. #code .. " bytes")
    print("  Preview: " .. string.sub(code, 1, 100) .. "...")
    print("=":rep(50))
    
    return true
end

-- ==========================================================
-- 5. HOOK LOADSTRING (CÁCH 1)
-- ==========================================================
loadstring = function(code, chunkname)
    if code and type(code) == "string" and #code > 50 then
        saveCode(code, "loadstring")
    end
    return oldLoadstring(code, chunkname)
end
print("✅ Hook loadstring đã cài!")

-- ==========================================================
-- 6. HOOK PRINT (CÁCH 2 - BẮT OUTPUT)
-- ==========================================================
if hasPrint then
    print = function(...)
        local args = {...}
        for _, arg in ipairs(args) do
            if type(arg) == "string" and #arg > 200 then
                if string.find(arg, "function") or string.find(arg, "return") then
                    saveCode(arg, "print")
                end
            end
        end
        return oldPrint(...)
    end
    print("✅ Hook print đã cài!")
end

-- ==========================================================
-- 7. HOOK XPCALL (CÁCH 3 - BẮT LỖI)
-- ==========================================================
if hasPcall then
    local oldXpcall = xpcall
    xpcall = function(f, errHandler)
        return oldXpcall(f, function(err)
            if type(err) == "string" and #err > 100 then
                saveCode(err, "xpcall_error")
            end
            return errHandler and errHandler(err) or err
        end)
    end
    print("✅ Hook xpcall đã cài!")
end

-- ==========================================================
-- 8. HOOK ERROR (CÁCH 4)
-- ==========================================================
local oldError = error
error = function(msg, level)
    if type(msg) == "string" and #msg > 100 then
        saveCode(msg, "error")
    end
    return oldError(msg, level)
end
print("✅ Hook error đã cài!")

-- ==========================================================
-- 9. QUÉT STACK (CÁCH 5)
-- ==========================================================
print("🔍 Quét stack hiện tại...")
local level = 0
local count = 0

while true do
    local ok, info = pcall(function()
        return debug.getinfo(level, "S")
    end)
    if not ok or not info then break end
    
    if info.source and #info.source > 100 then
        local source = info.source
        if string.sub(source, 1, 1) == "=" then
            source = string.sub(source, 2)
        end
        if #source > 100 and (string.find(source, "function") or string.find(source, "return")) then
            saveCode(source, "stack_" .. level)
            count = count + 1
        end
    end
    
    level = level + 1
    if level > 20 then break end
end
print("✅ Đã quét stack, tìm thấy " .. count .. " code")

-- ==========================================================
-- 10. QUÉT DEBUG (CÁCH 6)
-- ==========================================================
if debug and debug.getregistry then
    print("🔍 Quét debug.getregistry...")
    local registry = debug.getregistry()
    local count = 0
    
    for k, v in pairs(registry) do
        if type(v) == "string" and #v > 200 then
            if string.find(v, "function") or string.find(v, "return") then
                saveCode(v, "registry_" .. tostring(k))
                count = count + 1
            end
        elseif type(v) == "function" then
            local info = debug.getinfo(v, "S")
            if info and info.source and #info.source > 100 then
                local source = info.source
                if string.sub(source, 1, 1) == "=" then
                    source = string.sub(source, 2)
                end
                if #source > 100 then
                    saveCode(source, "func_" .. tostring(k))
                    count = count + 1
                end
            end
        end
    end
    
    print("✅ Đã quét registry, tìm thấy " .. count .. " code")
end

-- ==========================================================
-- 11. THÔNG BÁO HOÀN TẤT
-- ==========================================================
print("=":rep(60))
print("✅ HOOK ĐÃ SẴN SÀNG!")
print("=":rep(60))
print("📌 HƯỚNG DẪN:")
print("  1. Hook đã được cài đặt")
print("  2. Bây giờ bạn tự chạy script V8")
print("  3. Mọi loadstring/print sẽ bị bắt")
print("  4. Kết quả sẽ hiển thị trong console")
print("=":rep(60))
print("📌 LỆNH XEM CODE:")
print("  _G.showCodes()  → Xem danh sách")
print("  _G.showCode(n)  → Xem code #n")
print("  _G.lastCode     → Code mới nhất")
print("=":rep(60))

-- ==========================================================
-- 12. HÀM TIỆN ÍCH (DÙNG SAU KHI CHẠY V8)
-- ==========================================================
_G.showCodes = function()
    if HookData.count == 0 then
        print("❌ Chưa có code nào")
        return
    end
    
    print("=":rep(50))
    print("📋 DANH SÁCH CODE (" .. HookData.count .. " code)")
    print("=":rep(50))
    for i, data in ipairs(HookData.codes) do
        print(string.format("  #%d: [%s] %d bytes", i, data.label, data.size))
    end
    print("=":rep(50))
    print("📌 Dùng: _G.showCode(n) để xem chi tiết")
end

_G.showCode = function(index)
    local data = HookData.codes[index]
    if not data then
        print("❌ Không tìm thấy code #" .. tostring(index))
        return
    end
    
    print("=":rep(50))
    print("📄 CODE #" .. index .. " [" .. data.label .. "] (" .. data.size .. " bytes)")
    print("=":rep(50))
    print(data.code)
    print("=":rep(50))
end

_G.lastCode = function()
    local data = HookData.codes[HookData.count]
    if not data then
        print("❌ Chưa có code nào")
        return
    end
    return data.code
end

_G.HookData = HookData

print("✅ Hàm tiện ích đã sẵn sàng!")
print("=":rep(60))
