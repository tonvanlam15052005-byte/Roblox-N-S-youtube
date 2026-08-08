-- ==========================================================
-- HOOK LOADSTRING ALL-IN-ONE
-- Tự động xử lý MỌI trường hợp: có writefile, có setclipboard, hay chỉ có _G
-- ==========================================================

local function setupUniversalHook()
    local originalLoadstring = loadstring
    local hookId = 0
    local savedCodes = {}
    
    -- ========================================
    -- KIỂM TRA HỖ TRỢ
    -- ========================================
    local hasWritefile = type(writefile) == "function"
    local hasMakefolder = type(makefolder) == "function"
    local hasSetclipboard = type(setclipboard) == "function"
    local hasReadfile = type(readfile) == "function"
    local hasListfiles = type(listfiles) == "function"
    
    -- In thông tin môi trường
    print("=":rep(50))
    print("🔧 KIỂM TRA HỖ TRỢ:")
    print("  writefile:     " .. tostring(hasWritefile))
    print("  makefolder:    " .. tostring(hasMakefolder))
    print("  setclipboard:  " .. tostring(hasSetclipboard))
    print("  readfile:      " .. tostring(hasReadfile))
    print("  listfiles:     " .. tostring(hasListfiles))
    print("=":rep(50))
    
    -- ========================================
    -- HÀM LƯU FILE (TỰ ĐỘNG CHỌN CÁCH)
    -- ========================================
    local function saveCode(code, chunkname)
        hookId = hookId + 1
        local timestamp = os.time()
        local dateStr = os.date("%Y%m%d_%H%M%S", timestamp)
        
        -- Lưu vào bộ nhớ
        local data = {
            id = hookId,
            time = timestamp,
            date = dateStr,
            chunkname = chunkname or "unknown",
            code = code,
            length = #code,
            preview = string.sub(code, 1, 500)
        }
        savedCodes[hookId] = data
        _G["DECODED_" .. hookId] = code
        _G.LAST_DECODED = code
        _G.ALL_DECODED = savedCodes
        
        -- In thông tin
        print("=":rep(60))
        print("🔍 BẮT ĐƯỢC CODE #" .. hookId)
        print("  Thời gian: " .. os.date("%H:%M:%S", timestamp))
        print("  Chunkname: " .. tostring(chunkname))
        print("  Độ dài: " .. #code .. " ký tự")
        print("=":rep(60))
        
        -- ====================================
        -- CÁCH 1: LƯU RA FILE (nếu hỗ trợ)
        -- ====================================
        local savedToFile = false
        local savedToClipboard = false
        
        if hasWritefile then
            local folderName = "decoded_scripts"
            local fileName = folderName .. "/decoded_" .. dateStr .. "_" .. hookId .. ".lua"
            
            -- Tạo thư mục nếu chưa có và hỗ trợ
            if hasMakefolder then
                pcall(function() makefolder(folderName) end)
            end
            
            -- Ghi file
            local success, err = pcall(function()
                writefile(fileName, code)
            end)
            
            if success then
                print("💾 ĐÃ LƯU FILE: " .. fileName)
                savedToFile = true
                
                -- Kiểm tra file đã lưu thành công chưa
                if hasReadfile then
                    local check = pcall(function()
                        local content = readfile(fileName)
                        if content and #content == #code then
                            print("✅ File lưu thành công (" .. #content .. " ký tự)")
                        end
                    end)
                end
            else
                print("⚠️ Lỗi ghi file: " .. tostring(err))
            end
        end
        
        -- ====================================
        -- CÁCH 2: COPY VÀO CLIPBOARD (nếu hỗ trợ)
        -- ====================================
        if hasSetclipboard then
            local success, err = pcall(function()
                setclipboard(code)
            end)
            if success then
                print("📋 ĐÃ COPY VÀO CLIPBOARD!")
                savedToClipboard = true
            else
                print("⚠️ Lỗi copy clipboard: " .. tostring(err))
            end
        end
        
        -- ====================================
        -- CÁCH 3: LƯU VÀO _G (LUÔN LUÔN CÓ)
        -- ====================================
        print("📦 ĐÃ LƯU VÀO _G:")
        print("  _G.DECODED_" .. hookId .. " (code #" .. hookId .. ")")
        print("  _G.LAST_DECODED (code mới nhất)")
        print("  _G.ALL_DECODED (danh sách tất cả)")
        
        -- ====================================
        -- TÓM TẮT
        -- ====================================
        print("-" :rep(50))
        print("📝 PREVIEW (300 ký tự đầu):")
        print(string.sub(code, 1, 300) .. ( #code > 300 and "\n... (còn " .. (#code - 300) .. " ký tự)" or ""))
        print("=":rep(60))
        
        -- Lưu kết quả vào _G để kiểm tra sau
        _G._SAVE_RESULT = {
            id = hookId,
            savedToFile = savedToFile,
            savedToClipboard = savedToClipboard,
            fileName = savedToFile and (folderName .. "/decoded_" .. dateStr .. "_" .. hookId .. ".lua") or nil,
            codeLength = #code
        }
        
        -- Chạy code gốc
        return originalLoadstring(code, chunkname)
    end
    
    -- ========================================
    -- GHI ĐÈ LOADSTRING
    -- ========================================
    loadstring = saveCode
    
    -- ========================================
    -- HÀM TIỆN ÍCH ĐỂ XEM CODE ĐÃ LƯU
    -- ========================================
    _G.showDecoded = function(id)
        if id then
            local data = savedCodes[id]
            if data then
                print("=":rep(60))
                print("📄 CODE #" .. id)
                print("  Thời gian: " .. data.date)
                print("  Chunkname: " .. data.chunkname)
                print("  Độ dài: " .. data.length .. " ký tự")
                print("-" :rep(60))
                print(data.code)
                print("=":rep(60))
            else
                print("❌ Không tìm thấy code #" .. id)
            end
        else
            print("=":rep(60))
            print("📋 DANH SÁCH CODE ĐÃ BẮT (" .. #savedCodes .. " code)")
            print("-" :rep(60))
            for _, data in ipairs(savedCodes) do
                print(string.format("  #%d - %s - %s - %d ký tự", 
                    data.id, 
                    data.date, 
                    data.chunkname, 
                    data.length))
            end
            print("=":rep(60))
            print("📌 Dùng: _G.showDecoded(id) để xem chi tiết")
            print("📌 Dùng: _G.LAST_DECODED để lấy code mới nhất")
        end
    end
    
    -- ========================================
    -- HÀM LƯU CODE VÀO FILE (THỦ CÔNG)
    -- ========================================
    _G.saveDecodedToFile = function(id, fileName)
        local code = id and savedCodes[id] and savedCodes[id].code or _G.LAST_DECODED
        if not code then
            print("❌ Không tìm thấy code để lưu")
            return
        end
        
        if not hasWritefile then
            print("❌ Không hỗ trợ writefile, không thể lưu file")
            return
        end
        
        fileName = fileName or "decoded_manual_" .. os.time() .. ".lua"
        
        local success, err = pcall(function()
            writefile(fileName, code)
        end)
        
        if success then
            print("💾 Đã lưu code vào: " .. fileName)
        else
            print("❌ Lỗi lưu file: " .. tostring(err))
        end
    end
    
    -- ========================================
    -- HOOK THÊM: LOAD VÀ LOADFILE
    -- ========================================
    local originalLoad = load
    load = function(code, chunkname, mode, env)
        print("📦 Bắt được load: " .. tostring(chunkname))
        local result = saveCode(code, chunkname)
        return result
    end
    
    -- ========================================
    -- THÔNG BÁO HOÀN TẤT
    -- ========================================
    print("=":rep(50))
    print("✅ HOOK ALL-IN-ONE ĐÃ SẴN SÀNG!")
    print("=":rep(50))
    print("📌 HƯỚNG DẪN:")
    print("  1. Chạy script bị làm rối (loadstring hoặc load)")
    print("  2. Code sẽ được tự động lưu")
    print("  3. Kiểm tra code đã lưu:")
    print("     - _G.showDecoded()         → Xem danh sách")
    print("     - _G.showDecoded(id)       → Xem code cụ thể")
    print("     - _G.LAST_DECODED          → Code mới nhất")
    print("     - _G.ALL_DECODED           → Tất cả code")
    print("  4. Nếu có hỗ trợ writefile:")
    print("     - File lưu trong: decoded_scripts/")
    print("     - _G.saveDecodedToFile()   → Lưu code ra file")
    print("=":rep(50))
end

-- ========================================
-- CHẠY HOOK
-- ========================================
setupUniversalHook()

-- ========================================
-- SAU ĐÓ LOAD SCRIPT CẦN GIẢI MÃ
-- ========================================
-- Ví dụ:
-- loadstring(game:HttpGet('https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua'))()
