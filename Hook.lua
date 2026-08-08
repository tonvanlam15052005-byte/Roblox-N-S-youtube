-- ========================================
-- HOOK LOADSTRING - BẢN SỬA LỖI
-- ========================================

local function setupHook()
    -- Lưu loadstring GỐC
    local originalLoadstring = loadstring
    
    -- Ghi đè
    loadstring = function(code, chunkname)
        print("========== BẮT ĐƯỢC CODE ==========")
        print("📏 Độ dài: " .. #code .. " ký tự")
        
        -- Lưu code
        _G.DECODED_CODE = code
        _G.DECODED_CHUNKNAME = chunkname
        
        -- Copy clipboard
        if setclipboard then
            pcall(setclipboard, code)
            print("📋 Đã copy vào clipboard!")
        end
        
        -- Ghi file
        if writefile then
            pcall(function()
                if makefolder then pcall(makefolder, "decoded") end
                writefile("decoded/decoded_" .. os.time() .. ".lua", code)
                print("💾 Đã lưu file!")
            end)
        end
        
        -- 🔥 QUAN TRỌNG: GỌI LOADSTRING GỐC
        return originalLoadstring(code, chunkname)
    end
    
    print("✅ Hook đã sẵn sàng!")
end

-- Chạy hook
setupHook()

-- ========================================
-- SAU ĐÓ LOAD SCRIPT V8
-- ========================================
-- Lưu ý: Dùng pcall để bắt lỗi
local success, err = pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua'))()
end)

if not success then
    print("❌ Lỗi: " .. tostring(err))
end
