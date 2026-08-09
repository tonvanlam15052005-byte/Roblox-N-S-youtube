-- ==========================================================
-- SCRIPT BẮT CODE TỪ LUGRAPH VM - TẤT CẢ CÁCH TRONG MỘT
-- ==========================================================

print("=":rep(60))
print("🔧 BẮT CODE LUGRAPH - ALL-IN-ONE")
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

local hasWritefile = type(writefile) == "function"
local hasSetclipboard = type(setclipboard) == "function"
local hasMakefolder = type(makefolder) == "function"
local hasListfiles = type(listfiles) == "function"

print("📌 Hỗ trợ:")
print("  writefile: " .. tostring(hasWritefile))
print("  setclipboard: " .. tostring(hasSetclipboard))
print("  makefolder: " .. tostring(hasMakefolder))

-- ==========================================================
-- 2. HÀM LƯU CODE (TỐI ƯU)
-- ==========================================================
local function saveCode(code, label)
    if not code or type(code) ~= "string" or #code < 50 then
        return false
    end
    
    local timestamp = os.time()
    local filename = "decoded_" .. label .. "_" .. timestamp .. ".lua"
    
    oldPrint("=":rep(50))
    oldPrint("🎯 BẮT CODE [" .. label .. "]")
    oldPrint("  Độ dài: " .. #code .. " bytes")
    oldPrint("  Preview: " .. string.sub(code, 1, 150) .. "...")
    
    -- Lưu vào environment
    local env = getfenv() or _G
    if env then
        env["CODE_" .. label] = code
        env.LAST_CODE = code
        env.ALL_CODES = env.ALL_CODES or {}
        table.insert(env.ALL_CODES, {label = label, code = code, time = timestamp})
    end
    
    -- Copy clipboard
    if hasSetclipboard then
        pcall(function()
            setclipboard(code)
            oldPrint("  📋 Copied to clipboard")
        end)
    end
    
    -- Ghi file
    if hasWritefile then
        pcall(function()
            if hasMakefolder then
                pcall(makefolder, "decoded")
            end
            writefile("decoded/" .. filename, code)
            oldPrint("  💾 Saved: decoded/" .. filename)
            
            -- Lưu thêm file index để dễ tìm
            if hasWritefile then
                local index = env.ALL_CODES or {}
                local summary = ""
                for i, data in ipairs(index) do
                    summary = summary .. string.format("%d. [%s] %d bytes\n", i, data.label, #data.code)
                end
                writefile("decoded/INDEX.txt", summary)
            end
        end)
    end
    
    oldPrint("=":rep(50))
    return true
end

-- ==========================================================
-- 3. HOOK LOADSTRING
-- ==========================================================
loadstring = function(code, chunkname)
    if code and type(code) == "string" and #code > 100 then
        if string.find(code, "function") or string.find(code, "return") or string.find(code, "local") then
            saveCode(code, "loadstring")
        end
    end
    return oldLoadstring(code, chunkname)
end

-- ==========================================================
-- 4. HOOK LOAD
-- ==========================================================
if type(load) == "function" then
    load = function(code, chunkname, mode, env)
        if code and type(code) == "string" and #code > 100 then
            saveCode(code, "load")
        end
        return oldLoad(code, chunkname, mode, env)
    end
end

-- ==========================================================
-- 5. HOOK PRINT (BẮT OUTPUT CỦA VM)
-- ==========================================================
print = function(...)
    local args = {...}
    for _, arg in ipairs(args) do
        if type(arg) == "string" and #arg > 200 then
            if string.find(arg, "function") or string.find(arg, "return") or string.find(arg, "local") then
                saveCode(arg, "print")
            end
        end
    end
    return oldPrint(...)
end

-- ==========================================================
-- 6. HOOK ERROR
-- ==========================================================
error = function(msg, level)
    if type(msg) == "string" and #msg > 100 then
        saveCode(msg, "error")
    end
    return oldError(msg, level)
end

-- ==========================================================
-- 7. HOOK XPCALL ĐỂ BẮT LỖI VÀ CODE
-- ==========================================================
xpcall = function(f, errHandler)
    return oldXpcall(f, function(err)
        if type(err) == "string" and #err > 100 then
            saveCode(err, "xpcall_error")
        end
        return errHandler and errHandler(err) or err
    end)
end

-- ==========================================================
-- 8. HOOK GETFENV (BẮT MÔI TRƯỜNG CỦA VM)
-- ==========================================================
getfenv = function(level)
    local env = oldGetfenv(level or 1)
    if env and type(env) == "table" then
        -- Kiểm tra xem có code trong environment không
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

-- ==========================================================
-- 9. SCAN DEBUG.REGISTRY
-- ==========================================================
local function scanRegistry()
    if debug and debug.getregistry then
        oldPrint("🔍 Scanning debug.getregistry...")
        local registry = debug.getregistry()
        local count = 0
        
        for k, v in pairs(registry) do
            if type(v) == "string" and #v > 200 then
                if string.find(v, "function") or string.find(v, "return") or string.find(v, "local") then
                    saveCode(v, "registry_" .. tostring(k))
                    count = count + 1
                end
            elseif type(v) == "function" then
                -- Lấy source của function
                local info = debug.getinfo(v, "S")
                if info and info.source and #info.source > 100 then
                    local source = info.source
                    if string.sub(source, 1, 1) == "=" then
                        source = string.sub(source, 2)
                    end
                    if #source > 100 then
                        saveCode(source, "function_" .. tostring(k))
                        count = count + 1
                    end
                end
            end
        end
        
        oldPrint("✅ Đã quét registry, tìm thấy " .. count .. " code")
    end
end

-- ==========================================================
-- 10. SCAN GETFENV + STACK
-- ==========================================================
local function scanStack()
    oldPrint("🔍 Scanning stack...")
    local level = 0
    local count = 0
    
    while true do
        local info = debug and debug.getinfo and debug.getinfo(level, "S")
        if not info then break end
        
        if info.source and #info.source > 100 then
            local source = info.source
            if string.sub(source, 1, 1) == "=" then
                source = string.sub(source, 2)
            end
            if #source > 100 then
                saveCode(source, "stack_" .. level)
                count = count + 1
            end
        end
        
        level = level + 1
        if level > 50 then break end -- Giới hạn để tránh vô hạn
    end
    
    oldPrint("✅ Đã quét stack, tìm thấy " .. count .. " code")
end

-- ==========================================================
-- 11. HOOK SETFENV (BẮT KHI VM TẠO MÔI TRƯỜNG MỚI)
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

-- ==========================================================
-- 12. TẠO BIẾN TOÀN CỤC ĐỂ LƯU CODE
-- ==========================================================
local env = getfenv() or _G
env.CODES = {}
env.LAST_CODE = nil

-- ==========================================================
-- 13. CHẠY SCRIPT V8
-- ==========================================================
oldPrint("\n🔄 Đang chạy script YouTube Music Player V8...")

local v8Url = "https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua"

-- Tải script
local success, response = oldPcall(function()
    return game:HttpGet(v8Url)
end)

if not success then
    oldPrint("❌ Lỗi tải script: " .. tostring(response))
    oldPrint("📌 Thử tải bằng tay...")
    
    -- Nếu không tải được, yêu cầu paste thủ công
    oldPrint("\n📋 Vui lòng paste code V8 vào đây:")
    oldPrint("local v8Code = [[")
    oldPrint("-- PASTE CODE V8 VÀO ĐÂY")
    oldPrint("]]")
    oldPrint("Sau đó chạy lại script.")
    return
end

oldPrint("✅ Tải thành công (" .. #response .. " bytes)")

-- Chạy script trong xpcall để bắt lỗi
local chunk, err = oldLoadstring(response)
if not chunk then
    oldPrint("❌ Lỗi loadstring: " .. tostring(err))
    return
end

oldPrint("🔄 Đang thực thi script...")
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

-- ==========================================================
-- 14. QUÉT LẠI SAU KHI CHẠY
-- ==========================================================
oldPrint("\n🔍 Quét lại sau khi chạy...")
scanRegistry()
scanStack()

-- ==========================================================
-- 15. KẾT QUẢ
-- ==========================================================
oldPrint("\n" .. "=":rep(60))
oldPrint("📦 KẾT QUẢ")

local env2 = getfenv() or _G
local codes = env2.ALL_CODES or {}

if #codes > 0 then
    oldPrint("✅ Đã bắt được " .. #codes .. " code!")
    for i, data in ipairs(codes) do
        oldPrint(string.format("  %d. [%s] %d bytes", i, data.label, #data.code))
    end
    oldPrint("\n📌 Code mới nhất: " .. #(env2.LAST_CODE or "") .. " bytes")
else
    oldPrint("❌ KHÔNG BẮT ĐƯỢC CODE NÀO!")
    oldPrint("📌 Lý do có thể:")
    oldPrint("  1. Script không sử dụng loadstring")
    oldPrint("  2. VM đã che giấu code quá kỹ")
    oldPrint("  3. Cần chạy script trong môi trường đặc biệt")
end

-- Liệt kê file đã lưu
if hasWritefile and hasListfiles then
    oldPrint("\n📁 File đã lưu trong thư mục 'decoded/':")
    pcall(function()
        local files = listfiles("decoded/") or {}
        for _, file in ipairs(files) do
            oldPrint("  - " .. file)
        end
    end)
end

oldPrint("=":rep(60))

-- ==========================================================
-- 16. HÀM TIỆN ÍCH
-- ==========================================================
local env3 = getfenv() or _G

env3.showCodes = function()
    local allCodes = env3.ALL_CODES or {}
    if #allCodes == 0 then
        oldPrint("❌ Chưa có code nào")
        return
    end
    
    oldPrint("\n📋 DANH SÁCH CODE:")
    for i, data in ipairs(allCodes) do
        oldPrint(string.format("  %d. [%s] %d bytes", i, data.label, #data.code))
    end
    oldPrint("\n📌 Dùng: showCode(index) để xem chi tiết")
end

env3.showCode = function(index)
    local allCodes = env3.ALL_CODES or {}
    local data = allCodes[index]
    if not data then
        oldPrint("❌ Không tìm thấy code #" .. tostring(index))
        return
    end
    oldPrint("\n📄 CODE [" .. data.label .. "] (" .. #data.code .. " bytes):")
    oldPrint(data.code)
end

env3.saveAll = function()
    local allCodes = env3.ALL_CODES or {}
    if #allCodes == 0 then
        oldPrint("❌ Chưa có code nào để lưu")
        return
    end
    
    if not hasWritefile then
        oldPrint("❌ Không hỗ trợ writefile")
        return
    end
    
    pcall(function()
        if hasMakefolder then pcall(makefolder, "decoded") end
        for i, data in ipairs(allCodes) do
            local filename = string.format("decoded/code_%02d_%s.lua", i, data.label)
            writefile(filename, data.code)
            oldPrint("💾 Saved: " .. filename)
        end
        oldPrint("✅ Đã lưu tất cả code!")
    end)
end

oldPrint("\n📌 HÀM TIỆN ÍCH:")
oldPrint("  showCodes()     → Xem danh sách code")
oldPrint("  showCode(index) → Xem code chi tiết")
oldPrint("  saveAll()       → Lưu tất cả code ra file")
oldPrint("  LAST_CODE       → Code mới nhất")
