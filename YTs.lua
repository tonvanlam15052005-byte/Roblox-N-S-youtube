-- ==========================================================
-- AUDIOPLAYER - BẢN TỐI GIẢN
-- CHỈ DÙNG HÀM CHẮC CHẮN CÓ
-- ==========================================================

print("=":rep(50))
print("🎵 AUDIOPLAYER - BẢN TỐI GIẢN")
print("=":rep(50))

-- ==========================================================
-- 1. KIỂM TRA TỪNG BƯỚC
-- ==========================================================

-- Kiểm tra game
if not game then
    print("❌ game không tồn tại!")
    return
end
print("✅ game OK")

-- Kiểm tra Players
local Players = game:GetService("Players")
if not Players then
    print("❌ Players không tồn tại!")
    return
end
print("✅ Players OK")

-- Kiểm tra LocalPlayer
local Player = Players.LocalPlayer
if not Player then
    print("❌ LocalPlayer không tồn tại! Chờ 1 giây...")
    wait(1)
    Player = Players.LocalPlayer
    if not Player then
        print("❌ Vẫn không có LocalPlayer!")
        return
    end
end
print("✅ LocalPlayer: " .. Player.Name)

-- Kiểm tra HttpService
local HttpService = game:GetService("HttpService")
if not HttpService then
    print("❌ HttpService không tồn tại!")
    return
end
print("✅ HttpService OK")

-- Kiểm tra CoreGui
local CoreGui = game:GetService("CoreGui")
if not CoreGui then
    print("❌ CoreGui không tồn tại!")
    return
end
print("✅ CoreGui OK")

-- ==========================================================
-- 2. TẠO UI ĐƠN GIẢN
-- ==========================================================

print("🔧 Đang tạo UI...")

-- Tạo ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AudioPlayer"
ScreenGui.Parent = Player.PlayerGui or CoreGui
print("✅ ScreenGui created")

-- Tạo Frame chính
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.05
Frame.Parent = ScreenGui
print("✅ Frame created")

-- Tiêu đề
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Title.Text = "🎵 Audio Player"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

-- Ô nhập
local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(0.7, -5, 0, 30)
InputBox.Position = UDim2.new(0, 5, 0, 40)
InputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.TextSize = 14
InputBox.Font = Enum.Font.GothamMedium
InputBox.PlaceholderText = "Video ID..."
InputBox.Parent = Frame

-- Nút tải
local LoadBtn = Instance.new("TextButton")
LoadBtn.Size = UDim2.new(0.25, -5, 0, 30)
LoadBtn.Position = UDim2.new(0.75, 0, 0, 40)
LoadBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
LoadBtn.Text = "▶️ Tải"
LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadBtn.TextSize = 14
LoadBtn.Font = Enum.Font.GothamBold
LoadBtn.Parent = Frame

-- Trạng thái
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -10, 0, 25)
Status.Position = UDim2.new(0, 5, 0, 80)
Status.BackgroundTransparency = 1
Status.Text = "Nhập Video ID để tải"
Status.TextColor3 = Color3.fromRGB(150, 150, 150)
Status.TextSize = 12
Status.Font = Enum.Font.GothamMedium
Status.Parent = Frame

-- Nút điều khiển
local PlayBtn = Instance.new("TextButton")
PlayBtn.Size = UDim2.new(0, 60, 0, 35)
PlayBtn.Position = UDim2.new(0.5, -90, 0, 115)
PlayBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
PlayBtn.Text = "▶️"
PlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayBtn.TextSize = 20
PlayBtn.Font = Enum.Font.GothamBold
PlayBtn.Parent = Frame

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0, 60, 0, 35)
StopBtn.Position = UDim2.new(0.5, -25, 0, 115)
StopBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
StopBtn.Text = "⏹️"
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.TextSize = 20
StopBtn.Font = Enum.Font.GothamBold
StopBtn.Parent = Frame

-- Nút đóng
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Frame

-- ==========================================================
-- 3. SOUND OBJECT
-- ==========================================================
local Sound = Instance.new("Sound")
Sound.Volume = 0.5
Sound.Parent = Frame
print("✅ Sound created")

-- ==========================================================
-- 4. BIẾN
-- ==========================================================
local isPlaying = false
local currentId = ""

-- ==========================================================
-- 5. HÀM TẢI AUDIO
-- ==========================================================
local function loadAudio(videoId)
    if not videoId or videoId == "" then
        Status.Text = "⚠️ Vui lòng nhập Video ID"
        return
    end
    
    Status.Text = "⏳ Đang tải: " .. videoId
    print("🎯 Đang tải video: " .. videoId)
    
    -- Dùng API vevioz
    local url = "https://api.vevioz.com/api/button/mp3/https://www.youtube.com/watch?v=" .. videoId
    
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        Status.Text = "❌ Lỗi kết nối: " .. tostring(response)
        print("❌ Lỗi: " .. tostring(response))
        return
    end
    
    local data = HttpService:JSONDecode(response)
    
    if data and data.download_url then
        currentId = videoId
        Sound.SoundId = data.download_url
        Sound:Play()
        isPlaying = true
        PlayBtn.Text = "⏸️"
        Status.Text = "▶️ Đang phát: " .. videoId
        print("✅ Đang phát: " .. videoId)
    else
        Status.Text = "❌ Không tìm thấy audio"
        print("❌ Không tìm thấy audio cho: " .. videoId)
    end
end

-- ==========================================================
-- 6. SỰ KIỆN
-- ==========================================================

-- Tải
LoadBtn.MouseButton1Click:Connect(function()
    loadAudio(InputBox.Text)
end)

-- Enter
InputBox.FocusLost:Connect(function(enter)
    if enter then
        loadAudio(InputBox.Text)
    end
end)

-- Play/Pause
PlayBtn.MouseButton1Click:Connect(function()
    if isPlaying then
        Sound:Pause()
        isPlaying = false
        PlayBtn.Text = "▶️"
        Status.Text = "⏸️ Tạm dừng"
    else
        Sound:Resume()
        isPlaying = true
        PlayBtn.Text = "⏸️"
        Status.Text = "▶️ Đang phát: " .. currentId
    end
end)

-- Stop
StopBtn.MouseButton1Click:Connect(function()
    Sound:Stop()
    isPlaying = false
    PlayBtn.Text = "▶️"
    Status.Text = "⏹️ Đã dừng"
end)

-- Close
CloseBtn.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

-- Khi sound kết thúc
Sound.Stopped:Connect(function()
    isPlaying = false
    PlayBtn.Text = "▶️"
    Status.Text = "⏹️ Đã dừng"
end)

-- ==========================================================
-- 7. PHÍM TẮT
-- ==========================================================
local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.Space then
        if isPlaying then
            Sound:Pause()
            isPlaying = false
            PlayBtn.Text = "▶️"
            Status.Text = "⏸️ Tạm dừng"
        else
            Sound:Resume()
            isPlaying = true
            PlayBtn.Text = "⏸️"
            Status.Text = "▶️ Đang phát: " .. currentId
        end
    end
end)

-- ==========================================================
-- 8. THÔNG BÁO
-- ==========================================================
print("=":rep(50))
print("✅ AUDIOPLAYER ĐÃ SẴN SÀNG!")
print("=":rep(50))
print("📌 HƯỚNG DẪN:")
print("  1. Lấy Video ID từ YouTube")
print("     Ví dụ: https://youtu.be/ABC123 → ID là ABC123")
print("  2. Paste vào ô → Enter")
print("  3. Thưởng thức!")
print("=":rep(50))
print("⌨️ Phím Space: Play/Pause")
print("=":rep(50))
