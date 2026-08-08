-- ==========================================================
-- HOOK KHÔNG CAN THIỆP - Chỉ lưu code, không ảnh hưởng
-- ==========================================================

print("🔧 Cài hook không can thiệp...")

local originalLoadstring = loadstring
local hookActive = true

loadstring = function(code, chunkname)
    -- Chỉ bắt khi hook đang hoạt động
    if hookActive and code and type(code) == "string" then
        -- Lưu code
        _G.DECODED = code
        
        -- Ghi file
        if writefile then
            pcall(function()
                writefile("decoded_" .. os.time() .. ".lua", code)
            end)
        end
        
        -- Tắt hook tạm thời để tránh đệ quy
        hookActive = false
        
        -- In thông tin
        print("🎯 BẮT LOADSTRING: " .. #code .. " bytes")
    end
    
    -- Gọi loadstring gốc
    local result = originalLoadstring(code, chunkname)
    
    -- Bật lại hook
    hookActive = true
    
    return result
end

print("✅ Hook không can thiệp đã sẵn sàng!")
