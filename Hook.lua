-- ==========================================================
-- SCRIPT TEST ĐƠN GIẢN NHẤT
-- ==========================================================

print("=== TEST ===")

-- 1. Kiểm tra loadstring
local testCode = "print('Hello')"
local fn = loadstring(testCode)
if fn then
    pcall(fn)
    print("✅ loadstring hoạt động")
else
    print("❌ loadstring không hoạt động")
end

-- 2. Kiểm tra writefile
if writefile then
    pcall(function()
        writefile("test.txt", "Hello from Delta!")
        print("✅ writefile hoạt động")
    end)
else
    print("❌ writefile không có")
end

-- 3. Kiểm tra setclipboard
if setclipboard then
    pcall(function()
        setclipboard("Hello")
        print("✅ setclipboard hoạt động")
    end)
else
    print("❌ setclipboard không có")
end

print("=== KẾT THÚC ===")
