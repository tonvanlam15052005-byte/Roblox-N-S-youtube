-- Test hook
local testCode = "print('Test hook!')"
loadstring(testCode)()

-- Kiểm tra
if _G.DECODED == testCode then
    print("✅ Hook hoạt động bình thường!")
else
    print("❌ Hook KHÔNG hoạt động!")
    print("  _G.DECODED: " .. tostring(_G.DECODED))
end
