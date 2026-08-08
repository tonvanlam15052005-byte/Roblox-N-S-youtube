-- ==========================================================
-- HOOK METATABLE - Bắt mọi truy cập loadstring
-- ==========================================================

print("🔧 Cài hook metatable...")

-- Lưu bảng _G
local realG = _G

-- Tạo metatable cho _G
setmetatable(_G, {
    __index = function(table, key)
        if key == "loadstring" then
            return function(code, chunk)
                print("🎯 BẮT LOADSTRING QUA METATABLE!")
                _G.DECODED = code
                if setclipboard then pcall(setclipboard, code) end
                if writefile then 
                    pcall(function() 
                        writefile("decoded_meta_"..os.time()..".lua", code) 
                    end) 
                end
                return realG.loadstring(code, chunk)
            end
        end
        return realG[key]
    end,
    __newindex = function(table, key, value)
        if key == "loadstring" then
            print("⚠️ Có script đang ghi đè loadstring!")
            -- Vẫn cho phép ghi đè nhưng lưu lại
            realG[key] = value
        else
            realG[key] = value
        end
    end
})

print("✅ Hook metatable đã cài!")
