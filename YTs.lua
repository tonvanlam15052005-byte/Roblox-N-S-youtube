-- ==========================================================
-- AUDIOPLAYER - BẢN DÙNG GAME:HTTPGET
-- KHÔNG DÙNG request, syn.request, http.request
-- ==========================================================

local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- ==========================================================
-- KIỂM TRA HÀM HỖ TRỢ
-- ==========================================================
local hasHttpGet = type(game.HttpGet) == "function" or type(game:HttpGet) == "function"
local hasWritefile = type(writefile) == "function"
local hasMakefolder = type(makefolder) == "function"
local hasGetcustomasset = type(getcustomasset) == "function" or type(getsynasset) == "function"

print("📌 Kiểm tra hỗ trợ:")
print("  game:HttpGet: " .. tostring(hasHttpGet))
print("  writefile: " .. tostring(hasWritefile))
print("  makefolder: " .. tostring(hasMakefolder))
print("  getcustomasset: " .. tostring(hasGetcustomasset))

if not hasHttpGet then
    print("❌ game:HttpGet không được hỗ trợ!")
    return
end

-- ==========================================================
-- HÀM GỌI HTTP (DÙNG GAME:HTTPGET)
-- ==========================================================
local function httpGet(url)
    -- Thử các cách khác nhau để gọi
    if type(game.HttpGet) == "function" then
        return game:HttpGet(url)
    elseif type(game:HttpGet) == "function" then
        return game:HttpGet(url)
    else
        error("Không có hàm HttpGet")
    end
end

-- ==========================================================
-- HÀM LẤY CUSTOM ASSET
-- ==========================================================
local function getAsset(path)
    if type(getcustomasset) == "function" then
        return getcustomasset(path)
    elseif type(getsynasset) == "function" then
        return getsynasset(path)
    else
        return path
    end
end

-- ==========================================================
-- TẠO UI (NẾU CHƯA CÓ ASSET, TỰ TẠO)
-- ==========================================================
print("🔧 Đang tạo UI...")

-- Tạo ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AudioPlayer"
ScreenGui.Parent = Player.PlayerGui or CoreGui

-- Tạo Panel Button (trên thanh công cụ)
local PanelButton = Instance.new("ImageButton")
PanelButton.Size = UDim2.new(0, 30, 0, 30)
PanelButton.Position = UDim2.new(0, 10, 0, 5)
PanelButton.BackgroundTransparency = 1
PanelButton.Image = "rbxassetid://6026663699"
PanelButton.Parent = CoreGui:FindFirstChild("ThemeProvider") and CoreGui.ThemeProvider.TopBarFrame.LeftFrame or ScreenGui

-- Tạo cửa sổ chính
local Window = Instance.new("Frame")
Window.Size = UDim2.new(0, 350, 0, 250)
Window.Position = UDim2.new(0.5, -175, 0.5, -125)
Window.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Window.BorderSizePixel = 0
Window.BackgroundTransparency = 0.1
Window.Visible = false
Window.Parent = ScreenGui

-- Tiêu đề (dùng để kéo thả)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Window

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎵 Audio Player"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Nút đóng
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function()
    Window.Visible = false
end)

-- Ô nhập Video ID
local VidInput = Instance.new("TextBox")
VidInput.Size = UDim2.new(0.65, -10, 0, 30)
VidInput.Position = UDim2.new(0, 10, 0, 40)
VidInput.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
VidInput.TextColor3 = Color3.fromRGB(255, 255, 255)
VidInput.TextSize = 14
VidInput.Font = Enum.Font.GothamMedium
VidInput.PlaceholderText = "Nhập Video ID YouTube..."
VidInput.ClearTextOnFocus = false
VidInput.Parent = Window

-- Nút tải
local LoadBtn = Instance.new("TextButton")
LoadBtn.Size = UDim2.new(0.25, -10, 0, 30)
LoadBtn.Position = UDim2.new(0.7, 5, 0, 40)
LoadBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
LoadBtn.Text = "Tải"
LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadBtn.TextSize = 14
LoadBtn.Font = Enum.Font.GothamBold
LoadBtn.Parent = Window

-- Thanh tiến trình
local Playback = Instance.new("Frame")
Playback.Size = UDim2.new(1, -20, 0, 30)
Playback.Position = UDim2.new(0, 10, 0, 80)
Playback.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Playback.BorderSizePixel = 0
Playback.Parent = Window

local PlaybackFill = Instance.new("Frame")
PlaybackFill.Size = UDim2.new(0, 0, 1, 0)
PlaybackFill.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
PlaybackFill.BorderSizePixel = 0
PlaybackFill.Parent = Playback

-- Thời gian
local TimeText = Instance.new("TextLabel")
TimeText.Size = UDim2.new(1, -20, 0, 20)
TimeText.Position = UDim2.new(0, 10, 0, 115)
TimeText.BackgroundTransparency = 1
TimeText.Text = "00:00 / 00:00"
TimeText.TextColor3 = Color3.fromRGB(200, 200, 200)
TimeText.TextSize = 12
TimeText.Font = Enum.Font.GothamMedium
TimeText.Parent = Window

-- Nút điều khiển
local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.new(1, -20, 0, 40)
ControlFrame.Position = UDim2.new(0, 10, 0, 140)
ControlFrame.BackgroundTransparency = 1
ControlFrame.Parent = Window

-- Play/Pause
local PlayBtn = Instance.new("TextButton")
PlayBtn.Size = UDim2.new(0, 50, 0, 35)
PlayBtn.Position = UDim2.new(0.5, -75, 0, 0)
PlayBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
PlayBtn.Text = "▶️"
PlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayBtn.TextSize = 20
PlayBtn.Font = Enum.Font.GothamBold
PlayBtn.Parent = ControlFrame

-- Stop
local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0, 50, 0, 35)
StopBtn.Position = UDim2.new(0.5, -20, 0, 0)
StopBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
StopBtn.Text = "⏹️"
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.TextSize = 20
StopBtn.Font = Enum.Font.GothamBold
StopBtn.Parent = ControlFrame

-- Repeat
local RepeatBtn = Instance.new("TextButton")
RepeatBtn.Size = UDim2.new(0, 50, 0, 35)
RepeatBtn.Position = UDim2.new(0.5, 35, 0, 0)
RepeatBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
RepeatBtn.Text = "🔁"
RepeatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RepeatBtn.TextSize = 20
RepeatBtn.Font = Enum.Font.GothamBold
RepeatBtn.Parent = ControlFrame

-- Volume slider
local VolFrame = Instance.new("Frame")
VolFrame.Size = UDim2.new(0, 100, 0, 20)
VolFrame.Position = UDim2.new(1, -110, 1, -25)
VolFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
VolFrame.BorderSizePixel = 0
VolFrame.Parent = Window

local VolFill = Instance.new("Frame")
VolFill.Size = UDim2.new(0.5, 0, 1, 0)
VolFill.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
VolFill.BorderSizePixel = 0
VolFill.Parent = VolFrame

local VolLabel = Instance.new("TextLabel")
VolLabel.Size = UDim2.new(0, 30, 1, 0)
VolLabel.Position = UDim2.new(1, 2, 0, 0)
VolLabel.BackgroundTransparency = 1
VolLabel.Text = "50%"
VolLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
VolLabel.TextSize = 10
VolLabel.Font = Enum.Font.GothamMedium
VolLabel.Parent = VolFrame

-- ==========================================================
-- SOUND OBJECT
-- ==========================================================
local Sound = Instance.new("Sound")
Sound.Volume = 0.5
Sound.Parent = Window

-- ==========================================================
-- BIẾN ĐIỀU KHIỂN
-- ==========================================================
local isPlaying = false
local isLooped = false
local isDragging = false
local isDraggingVol = false
local currentVideoId = ""

-- ==========================================================
-- HÀM CẬP NHẬT
-- ==========================================================
local function updateTime()
    local pos = Sound.TimePosition
    local len = Sound.TimeLength
    if len == 0 then return end
    
    local function format(t)
        return string.format("%02i:%02i", t / 60 % 60, t % 60)
    end
    
    TimeText.Text = format(pos) .. " / " .. format(len)
    PlaybackFill.Size = UDim2.new(pos / len, 0, 1, 0)
end

-- ==========================================================
-- HÀM TẢI AUDIO
-- ==========================================================
local function loadAudio(videoId)
    if not videoId or videoId == "" then return end
    
    VidInput.PlaceholderText = "Đang tải..."
    VidInput.Text = ""
    
    -- Kiểm tra file đã có chưa
    local filePath = "audios/" .. videoId .. ".mp3"
    
    if hasWritefile and not isfile(filePath) then
        -- Tải từ API
        local url = "https://api.vevioz.com/api/button/mp3/https://www.youtube.com/watch?v=" .. videoId
        
        local success, response = pcall(function()
            return httpGet(url)
        end)
        
        if success and response then
            local data = HttpService:JSONDecode(response)
            if data and data.download_url then
                -- Tải file MP3
                local audioSuccess, audioData = pcall(function()
                    return httpGet(data.download_url)
                end)
                
                if audioSuccess and audioData then
                    if hasMakefolder then
                        pcall(makefolder, "audios")
                    end
                    if hasWritefile then
                        writefile(filePath, audioData)
                        print("💾 Đã lưu: " .. filePath)
                    end
                end
            end
        end
    end
    
    -- Phát audio
    local soundId
    if hasWritefile and isfile(filePath) and hasGetcustomasset then
        soundId = getAsset(filePath)
    else
        -- Fallback: dùng link trực tiếp (có thể không hoạt động)
        soundId = "https://api.vevioz.com/api/button/mp3/https://www.youtube.com/watch?v=" .. videoId
    end
    
    Sound.SoundId = soundId
    currentVideoId = videoId
    VidInput.PlaceholderText = "Video ID"
    
    -- Phát
    Sound:Play()
    isPlaying = true
    PlayBtn.Text = "⏸️"
end

-- ==========================================================
-- SỰ KIỆN
-- ==========================================================

-- Nút tải
LoadBtn.MouseButton1Click:Connect(function()
    loadAudio(VidInput.Text)
end)

-- Enter
VidInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        loadAudio(VidInput.Text)
    end
end)

-- Play/Pause
PlayBtn.MouseButton1Click:Connect(function()
    if isPlaying then
        Sound:Pause()
        isPlaying = false
        PlayBtn.Text = "▶️"
    else
        Sound:Resume()
        isPlaying = true
        PlayBtn.Text = "⏸️"
    end
end)

-- Stop
StopBtn.MouseButton1Click:Connect(function()
    Sound:Stop()
    isPlaying = false
    PlayBtn.Text = "▶️"
    PlaybackFill.Size = UDim2.new(0, 0, 1, 0)
    TimeText.Text = "00:00 / 00:00"
end)

-- Repeat
RepeatBtn.MouseButton1Click:Connect(function()
    isLooped = not isLooped
    Sound.Looped = isLooped
    RepeatBtn.Text = isLooped and "🔁" or "🔁"
    RepeatBtn.BackgroundColor3 = isLooped and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(60, 60, 70)
end)

-- Update time
Sound.Stopped:Connect(function()
    isPlaying = false
    PlayBtn.Text = "▶️"
end)

-- ==========================================================
-- VOLUME SLIDER
-- ==========================================================
VolFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingVol = true
        local mouse = Player:GetMouse()
        local pos = VolFrame.AbsolutePosition.X
        local size = VolFrame.AbsoluteSize.X
        local percent = math.clamp((mouse.X - pos) / size, 0, 1)
        Sound.Volume = percent
        VolFill.Size = UDim2.new(percent, 0, 1, 0)
        VolLabel.Text = math.floor(percent * 100) .. "%"
    end
end)

Player:GetMouse().Move:Connect(function()
    if isDraggingVol then
        local mouse = Player:GetMouse()
        local pos = VolFrame.AbsolutePosition.X
        local size = VolFrame.AbsoluteSize.X
        local percent = math.clamp((mouse.X - pos) / size, 0, 1)
        Sound.Volume = percent
        VolFill.Size = UDim2.new(percent, 0, 1, 0)
        VolLabel.Text = math.floor(percent * 100) .. "%"
    end
end)

VolFrame.InputEnded:Connect(function()
    isDraggingVol = false
end)

-- ==========================================================
-- PANEL BUTTON
-- ==========================================================
PanelButton.MouseButton1Click:Connect(function()
    Window.Visible = not Window.Visible
end)

-- ==========================================================
-- KÉO THẢ WINDOW
-- ==========================================================
local dragStart, dragPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        dragPos = Window.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Window.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = nil
        dragPos = nil
    end
end)

-- ==========================================================
-- UPDATE LOOP
-- ==========================================================
RunService.RenderStepped:Connect(function()
    if Sound.IsPlaying then
        updateTime()
    end
end)

-- ==========================================================
-- THÔNG BÁO
-- ==========================================================
print("=":rep(50))
print("🎵 AUDIOPLAYER ĐÃ SẴN SÀNG!")
print("=":rep(50))
print("📌 HƯỚNG DẪN:")
print("  1. Tìm Video ID từ YouTube")
print("  2. Paste vào ô → Enter")
print("  3. Thưởng thức nhạc!")
print("=":rep(50))
print("⌨️ PHÍM TẮT:")
print("  Space → Play/Pause")
print("=":rep(50))
