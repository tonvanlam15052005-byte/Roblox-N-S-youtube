-- ==========================================================
-- SCRIPT HOOK ĐẦU TIÊN (Chạy ngay sau khi inject)
-- ==========================================================

-- Đảm bảo các hàm cơ bản tồn tại
if type(loadstring) ~= "function" then
    -- Thử khôi phục từ _G
    if type(_G.loadstring) == "function" then
        loadstring = _G.loadstring
    end
end

-- Hook loadstring ngay lập tức
local oldLoadstring = loadstring
loadstring = function(code, chunk)
    -- In ra dấu hiệu hook đang hoạt động
    print("🔍 HOOK: " .. #code .. " bytes")
    
    -- Lưu code
    _G.CODE = code
    
    -- Gọi hàm gốc
    return oldLoadstring(code, chunk)
end

print("✅ Hook đã cài!")

-- Sau đó chạy script V8
-- (Cần chắc chắn rằng script V8 KHÔNG được chạy trước hook này)
