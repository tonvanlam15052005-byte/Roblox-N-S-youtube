-- Script kiểm tra HttpService
local httpService = game:GetService("HttpService")
local success, result = pcall(function()
    return httpService:GetAsync("https://httpbin.org/ip")
end)

if success then
    print("✅ HttpService ĐÃ BẬT! IP của bạn là: " .. result)
else
    print("❌ HttpService ĐANG TẮT. Lỗi: " .. tostring(result))
    print("👉 Đây là nguyên nhân script không tải được.")
end
