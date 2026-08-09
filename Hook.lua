-- ==========================================================
-- SCRIPT BẮT CODE LUGRAPH - BẢN GỌN NHẸ (CHỈ DÙNG PRINT)
-- ==========================================================

print("=":rep(60))
print("🔧 BẮT CODE LUGRAPH - BẢN GỌN NHẸ")
print("=":rep(60))

-- ==========================================================
-- 1. LƯU CÁC HÀM GỐC
-- ==========================================================
local oldLoadstring = loadstring
local oldLoad = load
local oldPrint = print
local oldError = error
local oldPcall = pcall
local oldXpcall = xpcall
local oldGetfenv = getfenv
local oldSetfenv = setfenv

-- ==========================================================
-- 2. BIẾN LƯU CODE (KHÔNG DÙNG FILE)
-- ==========================================================
local CodeStorage = {}
local CodeIndex = 0
local CodeCount = 0

-- ==========================================================
-- 3. HÀM LƯU CODE (CHỈ IN RA CONSOLE)
-- ==========================================================
local function saveCode(code, label)
    if not code or type(code) ~= "string" or #code < 100 then
        return false
    end
    
    -- Kiểm tra có phải code Lua không
    if not (string.find(code, "function") or string.find(code, "return") or string.find(code, "local")) then
        return false
    end
    
    CodeIndex = CodeIndex + 1
    CodeStorage[CodeIndex] = {
        label = label,
        code = code,
        size = #code
    }
    CodeCount = CodeCount + 1
    
    oldPrint("=":rep(50))
    oldPrint("🎯 BẮT CODE #" .. CodeIndex .. " [" .. label .. "]")
    oldPrint("  Size: " .. #code .. " bytes")
    oldPrint("  Preview (200 ký tự đầu):")
    oldPrint("  " .. string.sub(code, 1, 200) .. "...")
    oldPrint("=":rep(50))
    
    return true
end

-- ==========================================================
-- 4. HOOK LOADSTRING (Bắt khi script gọi loadstring)
-- ==========================================================
loadstring = function(code, chunkname)
    if code and type(code) == "string" and #code > 100 then
        saveCode(code, "loadstring")
    end
    return oldLoadstring(code, chunkname)
end
oldPrint("✅ Hook loadstring đã cài!")

-- ==========================================================
-- 5. HOOK LOAD (Bắt khi script gọi load)
-- ==========================================================
if type(load) == "function" then
    load = function(code, chunkname, mode, env)
        if code and type(code) == "string" and #code > 100 then
            saveCode(code, "load")
        end
        return oldLoad(code, chunkname, mode, env)
    end
    oldPrint("✅ Hook load đã cài!")
end

-- ==========================================================
-- 6. HOOK PRINT (Bắt output của VM)
-- ==========================================================
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
oldPrint("✅ Hook print đã cài!")

-- ==========================================================
-- 7. HOOK ERROR (Bắt lỗi, có thể chứa code)
-- ==========================================================
error = function(msg, level)
    if type(msg) == "string" and #msg > 100 then
        saveCode(msg, "error")
    end
    return oldError(msg, level)
end
oldPrint("✅ Hook error đã cài!")

-- ==========================================================
-- 8. HOOK XPCALL (Bắt lỗi từ xpcall)
-- ==========================================================
xpcall = function(f, errHandler)
    return oldXpcall(f, function(err)
        if type(err) == "string" and #err > 100 then
            saveCode(err, "xpcall_error")
        end
        return errHandler and errHandler(err) or err
    end)
end
oldPrint("✅ Hook xpcall đã cài!")

-- ==========================================================
-- 9. HOOK GETFENV (Bắt môi trường của VM)
-- ==========================================================
getfenv = function(level)
    local env = oldGetfenv(level or 1)
    if env and type(env) == "table" then
        for k, v in pairs(env) do
            if type(v) == "string" and #v > 200 then
                if string.find(v, "function") or string.find(v, "return") then
                    saveCode(v, "getfenv_" .. tostring(k))
                end
            end
        end
    end
    return env
end
oldPrint("✅ Hook getfenv đã cài!")

-- ==========================================================
-- 10. HOOK SETFENV (Bắt khi VM tạo môi trường mới)
-- ==========================================================
setfenv = function(level, env)
    if env and type(env) == "table" then
        for k, v in pairs(env) do
            if type(v) == "string" and #v > 200 then
                if string.find(v, "function") or string.find(v, "return") then
                    saveCode(v, "setfenv_" .. tostring(k))
                end
            end
        end
    end
    return oldSetfenv(level, env)
end
oldPrint("✅ Hook setfenv đã cài!")

-- ==========================================================
-- 11. QUÉT DEBUG.GETINFO (Nếu có)
-- ==========================================================
if debug and debug.getinfo then
    oldPrint("🔍 Quét debug.getinfo...")
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
                saveCode(source, "debug_" .. level)
                count = count + 1
            end
        end
        
        level = level + 1
        if level > 20 then break end
    end
    
    oldPrint("✅ Đã quét debug, tìm thấy " .. count .. " code")
end

-- ==========================================================
-- 12. QUÉT STACK (Bắt code từ stack)
-- ==========================================================
oldPrint("🔍 Quét stack...")
local level = 0
local count = 0

while true do
    local ok, info = pcall(function()
        return debug and debug.getinfo and debug.getinfo(level, "S")
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

oldPrint("✅ Đã quét stack, tìm thấy " .. count .. " code")

-- ==========================================================
-- 13. SCAN REGISTRY (Nếu có)
-- ==========================================================
if debug and debug.getregistry then
    oldPrint("🔍 Quét debug.getregistry...")
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
    
    oldPrint("✅ Đã quét registry, tìm thấy " .. count .. " code")
end

-- ==========================================================
-- 14. CHẠY SCRIPT V8 THỦ CÔNG
-- ==========================================================
oldPrint("\n" .. "=":rep(60))
oldPrint("🔄 ĐANG CHỜ BẠN PASTE CODE V8")
oldPrint("=":rep(60))
oldPrint("📋 HƯỚNG DẪN:")
oldPrint("  1. Copy code V8 từ GitHub")
oldPrint("  2. Paste vào chỗ có dấu [[ ]] bên dưới")
oldPrint("  3. Chạy lại script")
oldPrint("=":rep(60))

-- ==========================================================
-- PASTE CODE V8 VÀO ĐÂY
-- ==========================================================
local v8Code = [[
-- PASTE TOÀN BỘ CODE V8 VÀO ĐÂY
-- (Từ: https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua)
]]

-- ==========================================================
-- 15. CHẠY SCRIPT
-- ==========================================================
oldPrint("🔄 Đang chạy script V8...")

local chunk, err = oldLoadstring(v8Code)
if chunk then
    local ok, err2 = oldXpcall(chunk, function(errMsg)
        if type(errMsg) == "string" and #errMsg > 100 then
            saveCode(errMsg, "runtime_error")
        end
        oldPrint("❌ Lỗi runtime: " .. tostring(errMsg))
        return errMsg
    end)
    
    if ok then
        oldPrint("✅ Script đã chạy thành công!")
    else
        oldPrint("❌ Script gặp lỗi: " .. tostring(err2))
    end
else
    oldPrint("❌ Lỗi loadstring: " .. tostring(err))
end

-- ==========================================================
-- 16. KẾT QUẢ
-- ==========================================================
oldPrint("\n" .. "=":rep(60))
oldPrint("📦 KẾT QUẢ")

if CodeIndex > 0 then
    oldPrint("✅ Đã bắt được " .. CodeIndex .. " code!")
    for i = 1, CodeIndex do
        local data = CodeStorage[i]
        oldPrint(string.format("  #%d: [%s] %d bytes", i, data.label, data.size))
    end
    
    -- In chi tiết code cuối cùng
    local lastData = CodeStorage[CodeIndex]
    if lastData then
        oldPrint("\n📄 CODE CUỐI CÙNG [" .. lastData.label .. "]")
        oldPrint("=":rep(50))
        oldPrint(lastData.code)
        oldPrint("=":rep(50))
    end
else
    oldPrint("❌ KHÔNG BẮT ĐƯỢC CODE NÀO!")
    oldPrint("📌 Nguyên nhân có thể:")
    oldPrint("  1. Script không dùng loadstring/load/print")
    oldPrint("  2. Luraph đã che giấu code quá kỹ")
    oldPrint("  3. Cần chạy trong môi trường khác")
end
oldPrint("=":rep(60))
