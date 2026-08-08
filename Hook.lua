-- ==========================================================
-- HOOK LOADSTRING TỐI ƯU CHO DELTA EXECUTOR
-- Tự động phát hiện và sử dụng writefile, makefolder
-- ==========================================================

local function setupHook()
    -- Lưu hàm loadstring gốc
    local oldLoadstring = loadstring
    local hookCount = 0
    
    -- Ghi đè loadstring
    loadstring = function(code, chunkname)
        hookCount = hookCount + 1
        local timestamp = os.time()
        
        -- In thông tin
        print("=":rep(60))
        print("🔍 BẮT LOADSTRING #" .. hookCount)
        print("  Thời gian: " .. os.date("%H:%M:%S", timestamp))
        print("  Chunkname: " .. tostring(chunkname))
        print("  Độ dài: " .. #code .. " ký tự")
        print("=":rep(60))
        
        -- Lưu code vào _G
        _G["DECODED_" .. hookCount] = code
        _G.LAST_DECODED = code
        
        -- ====================================
        -- LƯU CODE RA FILE (Dành cho Delta)
        -- ====================================
        if writefile then
            local folder = "decoded_scripts"
            -- Tạo thư mục nếu chưa có
            if makefolder then
                pcall(function() makefolder(folder) end)
            end
            
            local fileName = folder .. "/decoded_" .. os.date("%Y%m%d_%H%M%S", timestamp) .. "_" .. hookCount .. ".lua"
            
            local success, err = pcall(function()
                writefile(fileName, code)
            end)
            
            if success then
                print("💾 ĐÃ LƯU FILE: " .. fileName)
                print("   📂 Thư mục: workspace của Delta")
            else
                print("⚠️ Lỗi ghi file: " .. tostring(err))
            end
        else
            print("⚠️ writefile không được hỗ trợ")
        end
        
        -- ====================================
        -- COPY VÀO CLIPBOARD (nếu có)
        -- ====================================
        if setclipboard then
            pcall(function()
                setclipboard(code)
                print("📋 Đã copy code vào clipboard!")
            end)
        end
        
        -- ====================================
        -- PREVIEW CODE
        -- ====================================
        local preview = string.sub(code, 1, 300)
        if #code > 300 then
            preview = preview .. "\n... (còn " .. (#code - 300) .. " ký tự)"
        end
        print("📝 PREVIEW:\n" .. preview)
        print("=":rep(60))
        
        -- Gọi loadstring GỐC để chạy code
        return oldLoadstring(code, chunkname)
    end
    
    print("✅ Hook đã sẵn sàng cho Delta Executor!")
    print("📌 Code sẽ được lưu trong thư mục 'decoded_scripts'")
    print("📌 Dùng _G.LAST_DECODED để lấy code mới nhất")
end

-- Chạy hook
setupHook()

-- ==========================================================
-- TẢI VÀ CHẠY SCRIPT YOUTUBE MUSIC PLAYER V8
-- ==========================================================

local url = "https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua"

print("🔄 Đang tải script V8 từ GitHub...")

local success, response = pcall(function()
    return game:HttpGet(url)
end)

if success and response then
    print("✅ Đã tải script V8 (" .. #response .. " ký tự)")
    
    -- Chạy script V8
    -- Hook đã được cài, nên mọi loadstring bên trong sẽ bị bắt
    local chunk, err = loadstring(response)
    if chunk then
        chunk()
        print("✅ Script V8 đã chạy thành công!")
    else
        print("❌ Lỗi khi chạy script: " .. tostring(err))
    end
else
    print("❌ Không thể tải script V8: " .. tostring(response))
end

-- ==========================================================
-- HƯỚNG DẪN LẤY CODE ĐÃ GIẢI MÃ
-- ==========================================================

print("\n" .. "=":rep(60))
print("📌 HƯỚNG DẪN LẤY CODE ĐÃ GIẢI MÃ")
print("=":rep(60))
print("1️⃣ File đã được lưu trong thư mục 'decoded_scripts'")
print("   📂 Tìm trong workspace của Delta Executor")
print("2️⃣ Code cũng đã được copy vào clipboard")
print("3️⃣ Hoặc dùng lệnh: _G.LAST_DECODED")
print("4️⃣ Xem danh sách các code đã bắt:")
print("   _G.showAll = function()")
print("       for k,v in pairs(_G) do")
print("           if string.match(k, 'DECODED_') then")
print("               print(k, ' - ' .. #v .. ' ký tự')")
print("           end")
print("       end")
print("   end")
print("=":rep(60))
