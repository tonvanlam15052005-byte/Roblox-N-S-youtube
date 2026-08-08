-- ==========================================================
-- HOOK LOADSTRING - BẢN AN TOÀN (KHÔNG GÂY STACK OVERFLOW)
-- ==========================================================

print("🔧 Cài hook an toàn...")

-- Lưu loadstring gốc
local originalLoadstring = loadstring

-- Tạo biến đếm để tránh đệ quy
local hookDepth = 0
local maxDepth = 5

-- Hook mới
loadstring = function(code, chunkname)
    -- Kiểm tra độ sâu đệ quy
    hookDepth = hookDepth + 1
    if hookDepth > maxDepth then
        hookDepth = hookDepth - 1
        -- Gọi trực tiếp không hook để tránh stack overflow
        return originalLoadstring(code, chunkname)
    end
    
    -- Chỉ bắt code khi độ sâu = 1 (không bị lồng nhau)
    if hookDepth == 1 then
        print("=":rep(50))
        print("🎯 BẮT LOADSTRING (depth: " .. hookDepth .. ")")
        print("  Size: " .. #code .. " bytes")
        
        -- Lưu code
        _G.DECODED = code
        
        -- Copy clipboard (an toàn)
        if setclipboard then
            pcall(setclipboard, code)
        end
        
        -- Ghi file (an toàn)
        if writefile then
            pcall(function()
                local name = "decoded_" .. os.time() .. ".lua"
                writefile(name, code)
                print("💾 Saved: " .. name)
            end)
        end
        
        -- Preview
        print("  Preview: " .. string.sub(code, 1, 100) .. "...")
        print("=":rep(50))
    end
    
    -- Gọi loadstring gốc
    local result = originalLoadstring(code, chunkname)
    
    -- Giảm depth
    hookDepth = hookDepth - 1
    
    return result
end

print("✅ Hook an toàn đã sẵn sàng!")
print("📌 Chỉ bắt code ở depth=1 để tránh stack overflow")

-- ==========================================================
-- CHẠY SCRIPT V8
-- ==========================================================

local v8Url = "https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua"

print("🔄 Đang tải script V8...")

local success, response = pcall(function()
    return game:HttpGet(v8Url)
end)

if success and response then
    print("✅ Tải thành công (" .. #response .. " bytes)")
    
    print("🔄 Đang chạy script V8...")
    local chunk, err = loadstring(response)
    if chunk then
        -- Chạy script trong pcall để bắt lỗi
        local ok, err2 = pcall(chunk)
        if ok then
            print("✅ Script V8 đã chạy xong!")
        else
            print("❌ Lỗi khi chạy: " .. tostring(err2))
        end
    else
        print("❌ Lỗi loadstring: " .. tostring(err))
    end
else
    print("❌ Lỗi tải script: " .. tostring(response))
end

-- ==========================================================
-- KẾT QUẢ
-- ==========================================================

print("\n" .. "=":rep(50))
print("📦 KẾT QUẢ")

if _G.DECODED then
    print("✅ ĐÃ BẮT ĐƯỢC CODE!")
    print("  Độ dài: " .. #_G.DECODED .. " bytes")
    print("  Preview: " .. string.sub(_G.DECODED, 1, 200) .. "...")
    print("\n📌 Code trong _G.DECODED")
else
    print("❌ KHÔNG BẮT ĐƯỢC CODE!")
    print("📌 Có thể script V8 không dùng loadstring ở depth=1")
end
print("=":rep(50))
