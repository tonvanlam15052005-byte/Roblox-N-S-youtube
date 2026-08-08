-- ========================================
-- HOOK LOADSTRING - BẮT CODE ĐÃ GIẢI MÃ
-- Chạy TRƯỚC khi load script bị làm rối
-- ========================================

local function setupHook()
    -- Lưu hàm loadstring gốc
    local originalLoadstring = loadstring
    
    -- Ghi đè loadstring
    loadstring = function(code, chunkname)
        print("========== BẮT ĐƯỢC CODE ĐÃ GIẢI MÃ ==========")
        print("📌 Chunkname: " .. tostring(chunkname))
        print("📏 Độ dài code: " .. tostring(#code) .. " ký tự")
        print("================================================")
        
        -- In ra 500 ký tự đầu để xem thử
        print("📝 500 ký tự đầu tiên:")
        print(string.sub(code, 1, 500))
        print("... (còn " .. tostring(#code - 500) .. " ký tự)")
        print("================================================")
        
        -- Lưu toàn bộ code vào biến toàn cục để dùng sau
        _G.DECODED_CODE = code
        _G.DECODED_CHUNKNAME = chunkname
        
        -- Copy vào clipboard (nếu executor hỗ trợ)
        if setclipboard then
            setclipboard(code)
            print("📋 Đã copy TOÀN BỘ code vào clipboard!")
        end
        
        -- Ghi ra file (nếu executor hỗ trợ)
        if writefile then
            local filename = "decoded_" .. os.time() .. ".lua"
            writefile(filename, code)
            print("💾 Đã lưu code vào file: " .. filename)
        end
        
        -- Chạy code gốc
        return originalLoadstring(code, chunkname)
    end
    
    print("✅ Hook loadstring đã được cài đặt!")
    print("🔄 Bây giờ hãy load script bị làm rối")
end

-- Chạy hook
setupHook()

-- ========================================
-- SAU ĐÓ LOAD SCRIPT V8
-- ========================================
-- loadstring(game:HttpGet('https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua'))()