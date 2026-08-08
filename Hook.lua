-- ==========================================================
-- HOOK NHIỀU HÀM (load, loadstring, loadfile)
-- ==========================================================

print("🔧 Cài hook đa năng...")

-- Hook loadstring
local oldLoadstring = loadstring
loadstring = function(code, chunk)
    _G.DECODED = code
    if setclipboard then pcall(setclipboard, code) end
    if writefile then pcall(function() writefile("decoded_"..os.time()..".lua", code) end) end
    return oldLoadstring(code, chunk)
end

-- Hook load
local oldLoad = load
load = function(code, chunk, mode, env)
    _G.DECODED = code
    if setclipboard then pcall(setclipboard, code) end
    if writefile then pcall(function() writefile("decoded_load_"..os.time()..".lua", code) end) end
    return oldLoad(code, chunk, mode, env)
end

-- Hook loadfile (nếu có)
if loadfile then
    local oldLoadfile = loadfile
    loadfile = function(name, mode, env)
        print("📁 loadfile: " .. name)
        return oldLoadfile(name, mode, env)
    end
end

print("✅ Hook đa năng đã sẵn sàng!")
