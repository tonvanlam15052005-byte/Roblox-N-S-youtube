-- ==========================================================
-- SCRIPT BẮT CODE LUGRAPH - BẢN KIỂM TRA
-- CHỈ DÙNG HÀM CÓ SẴN, KIỂM TRA TRƯỚC KHI DÙNG
-- ==========================================================

print("=":rep(60))
print("🔧 BẮT CODE LUGRAPH - BẢN KIỂM TRA")
print("=":rep(60))

-- ==========================================================
-- 1. KIỂM TRA TỪNG HÀM TRƯỚC KHI DÙNG
-- ==========================================================
local function safeCall(func, ...)
    if type(func) == "function" then
        return pcall(func, ...)
    end
    return false, "Hàm không tồn tại"
end

-- Kiểm tra các hàm cơ bản
local hasLoadstring = type(loadstring) == "function"
local hasLoad = type(load) == "function"
local hasPrint = type(print) == "function"
local hasPcall = type(pcall) == "function"
local hasXpcall = type(xpcall) == "function"
local hasGetfenv = type(getfenv) == "function"
local hasSetfenv = type(setfenv) == "function"
local hasDebug = type(debug) == "table"
local hasDebugGetinfo = hasDebug and type(debug.getinfo) == "function"
local hasDebugGetregistry = hasDebug and type(debug.getregistry) == "function"

print("📌 KẾT QUẢ KIỂM TRA:")
print("  loadstring: " .. tostring(hasLoadstring))
print("  load: " .. tostring(hasLoad))
print("  print: " .. tostring(hasPrint))
print("  pcall: " .. tostring(hasPcall))
print("  xpcall: " .. tostring(hasXpcall))
print("  getfenv: " .. tostring(hasGetfenv))
print("  setfenv: " .. tostring(hasSetfenv))
print("  debug: " .. tostring(hasDebug))
print("  debug.getinfo: " .. tostring(hasDebugGetinfo))
print("  debug.getregistry: " .. tostring(hasDebugGetregistry))

-- ==========================================================
-- 2. LƯU CÁC HÀM GỐC (CHỈ KHI CÓ)
-- ==========================================================
local oldLoadstring = hasLoadstring and loadstring or nil
local oldLoad = hasLoad and load or nil
local oldPrint = hasPrint and print or nil
local oldPcall = hasPcall and pcall or nil
local oldXpcall = hasXpcall and xpcall or nil
local oldGetfenv = hasGetfenv and getfenv or nil
local oldSetfenv = hasSetfenv and setfenv or nil

-- ==========================================================
-- 3. BIẾN LƯU CODE
-- ==========================================================
local CodeStorage = {}
local CodeIndex = 0

-- Hàm in ra console (dùng print nếu có, hoặc tự tạo)
local function safePrint(...)
    if hasPrint then
        return print(...)
    end
    -- Fallback nếu print bị nil
    return nil
end

-- ==========================================================
-- 4. HÀM LƯU CODE (CHỈ IN RA CONSOLE)
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
    
    safePrint("=":rep(50))
    safePrint("🎯 BẮT CODE #" .. CodeIndex .. " [" .. label .. "]")
    safePrint("  Size: " .. #code .. " bytes")
    safePrint("  Preview (200 ký tự đầu):")
    safePrint("  " .. string.sub(code, 1, 200) .. "...")
    safePrint("=":rep(50))
    
    return true
end

-- ==========================================================
-- 5. HOOK LOADSTRING (NẾU CÓ)
-- ==========================================================
if hasLoadstring then
    loadstring = function(code, chunkname)
        if code and type(code) == "string" and #code > 100 then
            saveCode(code, "loadstring")
        end
        return oldLoadstring(code, chunkname)
    end
    safePrint("✅ Hook loadstring đã cài!")
else
    safePrint("❌ loadstring không có, bỏ qua hook")
end

-- ==========================================================
-- 6. HOOK LOAD (NẾU CÓ)
-- ==========================================================
if hasLoad then
    load = function(code, chunkname, mode, env)
        if code and type(code) == "string" and #code > 100 then
            saveCode(code, "load")
        end
        return oldLoad(code, chunkname, mode, env)
    end
    safePrint("✅ Hook load đã cài!")
else
    safePrint("❌ load không có, bỏ qua hook")
end

-- ==========================================================
-- 7. HOOK PRINT (NẾU CÓ)
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
    safePrint("✅ Hook print đã cài!")
else
    safePrint("❌ print không có, bỏ qua hook")
end

-- ==========================================================
-- 8. HOOK XPCALL (NẾU CÓ)
-- ==========================================================
if hasXpcall then
    xpcall = function(f, errHandler)
        return oldXpcall(f, function(err)
            if type(err) == "string" and #err > 100 then
                saveCode(err, "xpcall_error")
            end
            return errHandler and errHandler(err) or err
        end)
    end
    safePrint("✅ Hook xpcall đã cài!")
else
    safePrint("❌ xpcall không có, bỏ qua hook")
end

-- ==========================================================
-- 9. HOOK GETFENV (NẾU CÓ)
-- ==========================================================
if hasGetfenv then
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
    safePrint("✅ Hook getfenv đã cài!")
else
    safePrint("❌ getfenv không có, bỏ qua hook")
end

-- ==========================================================
-- 10. HOOK SETFENV (NẾU CÓ)
-- ==========================================================
if hasSetfenv then
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
    safePrint("✅ Hook setfenv đã cài!")
else
    safePrint("❌ setfenv không có, bỏ qua hook")
end

-- ==========================================================
-- 11. QUÉT DEBUG.GETINFO (NẾU CÓ)
-- ==========================================================
if hasDebugGetinfo then
    safePrint("🔍 Quét debug.getinfo...")
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
    
    safePrint("✅ Đã quét debug, tìm thấy " .. count .. " code")
else
    safePrint("❌ debug.getinfo không có, bỏ qua quét")
end

-- ==========================================================
-- 12. QUÉT DEBUG.GETREGISTRY (NẾU CÓ)
-- ==========================================================
if hasDebugGetregistry then
    safePrint("🔍 Quét debug.getregistry...")
    local registry = debug.getregistry()
    local count = 0
    
    for k, v in pairs(registry) do
        if type(v) == "string" and #v > 200 then
            if string.find(v, "function") or string.find(v, "return") then
                saveCode(v, "registry_" .. tostring(k))
                count = count + 1
            end
        elseif type(v) == "function" then
            local ok, info = pcall(function()
                return debug.getinfo(v, "S")
            end)
            if ok and info and info.source and #info.source > 100 then
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
    
    safePrint("✅ Đã quét registry, tìm thấy " .. count .. " code")
else
    safePrint("❌ debug.getregistry không có, bỏ qua quét")
end

-- ==========================================================
-- 13. QUÉT STACK (CHỈ KHI CÓ DEBUG)
-- ==========================================================
if hasDebugGetinfo then
    safePrint("🔍 Quét stack...")
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
    
    safePrint("✅ Đã quét stack, tìm thấy " .. count .. " code")
end

-- ==========================================================
-- 14. CHẠY SCRIPT V8 THỦ CÔNG
-- ==========================================================
safePrint("\n" .. "=":rep(60))
safePrint("🔄 ĐANG CHỜ BẠN PASTE CODE V8")
safePrint("=":rep(60))
safePrint("📋 HƯỚNG DẪN:")
safePrint("  1. Copy code V8 từ GitHub")
safePrint("  2. Paste vào chỗ có dấu [[ ]] bên dưới")
safePrint("  3. Chạy lại script")
safePrint("=":rep(60))

-- ==========================================================
-- PASTE CODE V8 VÀO ĐÂY
-- ==========================================================
local v8Code = [[
-- PASTE TOÀN BỘ CODE V8 VÀO ĐÂY
-- (Từ: https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua)
]]

-- ==========================================================
-- 15. CHẠY SCRIPT V8
-- ==========================================================
if v8Code and #v8Code > 100 then
    safePrint("🔄 Đang chạy script V8 (" .. #v8Code .. " bytes)...")
    
    -- Kiểm tra xem có loadstring không
    if not hasLoadstring then
        safePrint("❌ loadstring không có, không thể chạy script!")
        return
    end
    
    local chunk, err = loadstring(v8Code)
    if chunk then
        -- Chạy với xpcall nếu có, hoặc pcall nếu không
        local ok, err2
        if hasXpcall then
            ok, err2 = xpcall(chunk, function(errMsg)
                if type(errMsg) == "string" and #errMsg > 100 then
                    saveCode(errMsg, "runtime_error")
                end
                safePrint("❌ Lỗi runtime: " .. tostring(errMsg))
                return errMsg
            end)
        elseif hasPcall then
            ok, err2 = pcall(chunk)
        else
            safePrint("❌ Không có pcall hoặc xpcall, chạy trực tiếp...")
            chunk()
            ok = true
        end
        
        if ok then
            safePrint("✅ Script đã chạy thành công!")
        else
            safePrint("❌ Script gặp lỗi: " .. tostring(err2))
        end
    else
        safePrint("❌ Lỗi loadstring: " .. tostring(err))
    end
else
    safePrint("❌ Chưa paste code V8!")
end

-- ==========================================================
-- 16. KẾT QUẢ
-- ==========================================================
safePrint("\n" .. "=":rep(60))
safePrint("📦 KẾT QUẢ")

if CodeIndex > 0 then
    safePrint("✅ Đã bắt được " .. CodeIndex .. " code!")
    for i = 1, CodeIndex do
        local data = CodeStorage[i]
        safePrint(string.format("  #%d: [%s] %d bytes", i, data.label, data.size))
    end
    
    -- In chi tiết code cuối cùng
    local lastData = CodeStorage[CodeIndex]
    if lastData then
        safePrint("\n📄 CODE CUỐI CÙNG [" .. lastData.label .. "]")
        safePrint("=":rep(50))
        safePrint(lastData.code)
        safePrint("=":rep(50))
    end
else
    safePrint("❌ KHÔNG BẮT ĐƯỢC CODE NÀO!")
    safePrint("📌 Nguyên nhân có thể:")
    safePrint("  1. Script không dùng loadstring/load/print")
    safePrint("  2. Luraph đã che giấu code quá kỹ")
    safePrint("  3. Cần chạy trong môi trường khác")
end
safePrint("=":rep(60))
