--[[
    YouTube Player Pro - Fix Loading
    Hiển thị lỗi rõ ràng, có fallback
]]

local player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ===== CONFIG =====
local Request = request or (http and http.request) or (syn and syn.request)
local GetAsset = getcustomasset or getsynasset
local Domain = "https://parvus.fun/"

-- ===== TẠO FOLDER =====
if not isfolder("youtube_media") then makefolder("youtube_media") end
if not isfolder("youtube_media/videos") then makefolder("youtube_media/videos") end
if not isfolder("youtube_media/audios") then makefolder("youtube_media/audios") end

-- ===== TẠO GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player.PlayerGui
ScreenGui.ResetOnSpawn = false

-- ===== STYLE =====
local Colors = {
    BG = Color3.fromRGB(18, 18, 22),
    Surface = Color3.fromRGB(28, 28, 35),
    Surface2 = Color3.fromRGB(38, 38, 48),
    Primary = Color3.fromRGB(255, 0, 0),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(155, 155, 165),
}

-- ===== NÚT MỞ MENU =====
local FloatBtn = Instance.new("TextButton")
FloatBtn.Parent = ScreenGui
FloatBtn.Size = UDim2.new(0, 65, 0, 65)
FloatBtn.Position = UDim2.new(0.85, -32, 0.82, 0)
FloatBtn.BackgroundColor3 = Colors.Primary
FloatBtn.BorderSizePixel = 0
FloatBtn.Text = "▶"
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.TextSize = 28
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.ZIndex = 999

-- ===== MAIN WINDOW =====
local winWidth = 380
local winHeight = 550

local MainWindow = Instance.new("Frame")
MainWindow.Parent = ScreenGui
MainWindow.Size = UDim2.new(0, winWidth, 0, winHeight)
MainWindow.Position = UDim2.new(0.5, -winWidth/2, 0.5, -winHeight/2)
MainWindow.BackgroundColor3 = Colors.BG
MainWindow.BorderSizePixel = 0
MainWindow.Visible = false
MainWindow.ZIndex = 100
MainWindow.ClipsDescendants = true

-- ===== TITLE BAR =====
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainWindow
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Colors.Surface
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 150

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.Size = UDim2.new(0.6, 0, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🎬 YouTube Player"
TitleText.TextColor3 = Colors.Text
TitleText.TextSize = 15
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = 160

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 45, 1, 0)
CloseBtn.Position = UDim2.new(1, -45, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Colors.TextDim
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 160
CloseBtn.MouseButton1Click:Connect(function()
    MainWindow.Visible = false
    FloatBtn.Text = "▶"
end)

-- ===== DRAG =====
local isDragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = MainWindow.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MainWindow.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
    end
end)

-- ===== SEARCH BAR =====
local SearchFrame = Instance.new("Frame")
SearchFrame.Parent = MainWindow
SearchFrame.Size = UDim2.new(1, 0, 0, 90)
SearchFrame.Position = UDim2.new(0, 0, 0, 40)
SearchFrame.BackgroundColor3 = Colors.Surface2
SearchFrame.BorderSizePixel = 0
SearchFrame.ZIndex = 140

-- Input tìm kiếm
local SearchBox = Instance.new("TextBox")
SearchBox.Parent = SearchFrame
SearchBox.Size = UDim2.new(0.6, -10, 0, 35)
SearchBox.Position = UDim2.new(0, 10, 0, 8)
SearchBox.BackgroundColor3 = Colors.BG
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "🔍 Tìm video..."
SearchBox.PlaceholderColor3 = Colors.TextDim
SearchBox.TextColor3 = Colors.Text
SearchBox.TextSize = 14
SearchBox.Font = Enum.Font.Gotham
SearchBox.ClearTextOnFocus = false
SearchBox.ZIndex = 150

local SearchBtn = Instance.new("TextButton")
SearchBtn.Parent = SearchFrame
SearchBtn.Size = UDim2.new(0, 70, 0, 35)
SearchBtn.Position = UDim2.new(0.63, 5, 0, 8)
SearchBtn.BackgroundColor3 = Colors.Primary
SearchBtn.BorderSizePixel = 0
SearchBtn.Text = "Tìm"
SearchBtn.TextColor3 = Colors.Text
SearchBtn.TextSize = 14
SearchBtn.Font = Enum.Font.GothamBold
SearchBtn.ZIndex = 150

-- Input dán link/ID
local LinkBox = Instance.new("TextBox")
LinkBox.Parent = SearchFrame
LinkBox.Size = UDim2.new(0.7, -10, 0, 32)
LinkBox.Position = UDim2.new(0, 10, 0, 48)
LinkBox.BackgroundColor3 = Colors.BG
LinkBox.BorderSizePixel = 0
LinkBox.PlaceholderText = "🔗 Dán link hoặc Video ID..."
LinkBox.PlaceholderColor3 = Colors.TextDim
LinkBox.TextColor3 = Colors.Text
LinkBox.TextSize = 13
LinkBox.Font = Enum.Font.Gotham
LinkBox.ClearTextOnFocus = false
LinkBox.ZIndex = 150

local LoadBtn = Instance.new("TextButton")
LoadBtn.Parent = SearchFrame
LoadBtn.Size = UDim2.new(0, 70, 0, 32)
LoadBtn.Position = UDim2.new(0.63, 5, 0, 48)
LoadBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
LoadBtn.BorderSizePixel = 0
LoadBtn.Text = "Phát"
LoadBtn.TextColor3 = Colors.Text
LoadBtn.TextSize = 14
LoadBtn.Font = Enum.Font.GothamBold
LoadBtn.ZIndex = 150

-- ===== MODE =====
local ModeFrame = Instance.new("Frame")
ModeFrame.Parent = SearchFrame
ModeFrame.Size = UDim2.new(0, 85, 0, 30)
ModeFrame.Position = UDim2.new(0.78, 0, 0, 10)
ModeFrame.BackgroundColor3 = Colors.BG
ModeFrame.BorderSizePixel = 0
ModeFrame.ZIndex = 150

local ModeVid = Instance.new("TextButton")
ModeVid.Parent = ModeFrame
ModeVid.Size = UDim2.new(0.5, 0, 1, 0)
ModeVid.BackgroundColor3 = Colors.Primary
ModeVid.BorderSizePixel = 0
ModeVid.Text = "🎥"
ModeVid.TextColor3 = Colors.Text
ModeVid.TextSize = 14
ModeVid.Font = Enum.Font.GothamBold
ModeVid.ZIndex = 160

local ModeAud = Instance.new("TextButton")
ModeAud.Parent = ModeFrame
ModeAud.Size = UDim2.new(0.5, 0, 1, 0)
ModeAud.Position = UDim2.new(0.5, 0, 0, 0)
ModeAud.BackgroundTransparency = 1
ModeAud.BorderSizePixel = 0
ModeAud.Text = "🎵"
ModeAud.TextColor3 = Colors.TextDim
ModeAud.TextSize = 14
ModeAud.Font = Enum.Font.GothamBold
ModeAud.ZIndex = 160

local currentMode = "video"

-- ===== VIDEO PLAYER =====
local PlayerFrame = Instance.new("Frame")
PlayerFrame.Parent = MainWindow
PlayerFrame.Size = UDim2.new(1, 0, 0, 180)
PlayerFrame.Position = UDim2.new(0, 0, 0, 130)
PlayerFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PlayerFrame.BorderSizePixel = 0
PlayerFrame.ZIndex = 120

local VideoPlayer = Instance.new("VideoFrame")
VideoPlayer.Parent = PlayerFrame
VideoPlayer.Size = UDim2.new(1, 0, 1, 0)
VideoPlayer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
VideoPlayer.ZIndex = 130

local AudioFrame = Instance.new("Frame")
AudioFrame.Parent = PlayerFrame
AudioFrame.Size = UDim2.new(1, 0, 1, 0)
AudioFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
AudioFrame.Visible = false
AudioFrame.ZIndex = 130

local AudioIcon = Instance.new("TextLabel")
AudioIcon.Parent = AudioFrame
AudioIcon.Size = UDim2.new(1, 0, 0.6, 0)
AudioIcon.Position = UDim2.new(0, 0, 0.2, 0)
AudioIcon.BackgroundTransparency = 1
AudioIcon.Text = "🎵"
AudioIcon.TextColor3 = Colors.Primary
AudioIcon.TextSize = 55
AudioIcon.Font = Enum.Font.GothamBold
AudioIcon.ZIndex = 140

local AudioStatus = Instance.new("TextLabel")
AudioStatus.Parent = AudioFrame
AudioStatus.Size = UDim2.new(0.8, 0, 0, 25)
AudioStatus.Position = UDim2.new(0.1, 0, 0.75, 0)
AudioStatus.BackgroundTransparency = 1
AudioStatus.Text = "Đang phát Audio..."
AudioStatus.TextColor3 = Colors.TextDim
AudioStatus.TextSize = 13
AudioStatus.Font = Enum.Font.Gotham
AudioStatus.ZIndex = 140

-- ===== NOW PLAYING =====
local NowPlaying = Instance.new("TextLabel")
NowPlaying.Parent = MainWindow
NowPlaying.Size = UDim2.new(0.9, 0, 0, 25)
NowPlaying.Position = UDim2.new(0.05, 0, 0, 315)
NowPlaying.BackgroundTransparency = 1
NowPlaying.Text = "👆 Chọn video hoặc dán link"
NowPlaying.TextColor3 = Colors.TextDim
NowPlaying.TextSize = 12
NowPlaying.Font = Enum.Font.Gotham
NowPlaying.TextTruncate = Enum.TextTruncate.AtEnd
NowPlaying.ZIndex = 150

-- ===== TIMELINE =====
local Timeline = Instance.new("Frame")
Timeline.Parent = MainWindow
Timeline.Size = UDim2.new(0.9, 0, 0, 14)
Timeline.Position = UDim2.new(0.05, 0, 0, 342)
Timeline.BackgroundColor3 = Colors.Surface2
Timeline.BorderSizePixel = 0
Timeline.ZIndex = 150

local TimelineLine = Instance.new("Frame")
TimelineLine.Parent = Timeline
TimelineLine.Size = UDim2.new(0, 0, 1, 0)
TimelineLine.BackgroundColor3 = Colors.Primary
TimelineLine.BorderSizePixel = 0
TimelineLine.ZIndex = 160

-- ===== CONTROLS =====
local Controls = Instance.new("Frame")
Controls.Parent = MainWindow
Controls.Size = UDim2.new(1, 0, 0, 55)
Controls.Position = UDim2.new(0, 0, 0, 360)
Controls.BackgroundColor3 = Colors.Surface
Controls.BorderSizePixel = 0
Controls.ZIndex = 140

local function MakeBtn(parent, pos, text, size)
    size = size or 40
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(0, size, 0, size)
    btn.Position = pos
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = Colors.Text
    btn.TextSize = 22
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 150
    return btn
end

local PlayBtn = MakeBtn(Controls, UDim2.new(0.5, -50, 0, 3), "▶", 48)
local PrevBtn = MakeBtn(Controls, UDim2.new(0.5, -100, 0, 3), "⏮", 38)
local NextBtn = MakeBtn(Controls, UDim2.new(0.5, 0, 0, 3), "⏭", 38)
local LoopBtn = MakeBtn(Controls, UDim2.new(0.5, 50, 0, 3), "🔁", 38)

-- Volume
local VolFrame = Instance.new("Frame")
VolFrame.Parent = Controls
VolFrame.Size = UDim2.new(0, 70, 0, 14)
VolFrame.Position = UDim2.new(0.85, 0, 0.5, -7)
VolFrame.BackgroundColor3 = Colors.Surface2
VolFrame.BorderSizePixel = 0
VolFrame.ZIndex = 150

local VolLine = Instance.new("Frame")
VolLine.Parent = VolFrame
VolLine.Size = UDim2.new(0.5, 0, 1, 0)
VolLine.BackgroundColor3 = Colors.Primary
VolLine.BorderSizePixel = 0
VolLine.ZIndex = 160

local VolBtn = Instance.new("TextButton")
VolBtn.Parent = Controls
VolBtn.Size = UDim2.new(0, 25, 0, 25)
VolBtn.Position = UDim2.new(0.8, 0, 0.5, -12)
VolBtn.BackgroundTransparency = 1
VolBtn.Text = "🔊"
VolBtn.TextColor3 = Colors.Text
VolBtn.TextSize = 14
VolBtn.Font = Enum.Font.GothamBold
VolBtn.ZIndex = 150

local currentVolume = 0.5

VolFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position.X - VolFrame.AbsolutePosition.X
        local vol = math.clamp(pos / VolFrame.AbsoluteSize.X, 0, 1)
        currentVolume = vol
        VolLine.Size = UDim2.new(vol, 0, 1, 0)
        if currentMode == "video" and VideoPlayer.Visible then
            VideoPlayer.Volume = vol
        elseif soundInst then
            soundInst.Volume = vol
        end
    end
end)

-- ===== RESULTS =====
local ResultsFrame = Instance.new("ScrollingFrame")
ResultsFrame.Parent = MainWindow
ResultsFrame.Size = UDim2.new(1, 0, 0, 110)
ResultsFrame.Position = UDim2.new(0, 0, 0, 420)
ResultsFrame.BackgroundColor3 = Colors.Surface2
ResultsFrame.BorderSizePixel = 0
ResultsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ResultsFrame.ScrollBarThickness = 4
ResultsFrame.ScrollBarImageColor3 = Colors.Primary
ResultsFrame.ZIndex = 130

-- ===== FUNCTIONS =====
local soundInst = nil
local isPlaying = false
local isLooping = false
local currentVideo = nil
local queue = {}
local queueIndex = 1

-- Lấy Video ID
local function getVideoId(input)
    input = string.lower(input)
    local id = string.match(input, "v=([%w_-]+)")
    if id then return id end
    id = string.match(input, "youtu%.be/([%w_-]+)")
    if id then return id end
    if string.match(input, "^[%w_-]+$") and #input == 11 then
        return input
    end
    return nil
end

-- Search YouTube với error handling
local function SearchYouTube(query)
    local encoded = HttpService:UrlEncode(query)
    local url = Domain .. "yt/search?q=" .. encoded .. "&limit=10"
    
    print("🔍 Đang gọi API:", url)
    
    local success, response = pcall(function()
        return Request({
            Method = "GET",
            Url = url,
            Timeout = 5
        })
    end)
    
    if not success then
        print("❌ Lỗi kết nối:", response)
        return nil
    end
    
    if not response then
        print("❌ Không có response")
        return nil
    end
    
    print("📡 Status:", response.StatusCode)
    
    if response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        print("✅ Tìm thấy:", #data, "kết quả")
        return data
    else
        print("❌ Status code:", response.StatusCode)
        return nil
    end
end

-- Tải video/audio
local function RequestMedia(videoId, type)
    type = type or "video"
    local url = Domain .. "yt/" .. type .. "?videoId=" .. videoId
    
    print("📥 Đang tải:", videoId, "type:", type)
    
    local success, response = pcall(function()
        return Request({
            Method = "POST",
            Url = url,
            Timeout = 30
        })
    end)
    
    if not success then
        print("❌ Lỗi tải:", response)
        return false
    end
    
    if not response then
        print("❌ Không có response")
        return false
    end
    
    if response.StatusCode == 404 then 
        print("❌ Video không tồn tại")
        return false 
    end
    
    if response.StatusCode == 200 then
        print("✅ Tải thành công, size:", #response.Body)
        return response.Body
    end
    
    print("❌ Status code:", response.StatusCode)
    return false
end

-- Hiển thị kết quả
local function DisplayResults(results)
    for _, child in pairs(ResultsFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    if not results or #results == 0 then
        local empty = Instance.new("TextLabel")
        empty.Parent = ResultsFrame
        empty.Size = UDim2.new(1, 0, 1, 0)
        empty.BackgroundTransparency = 1
        empty.Text = "Không tìm thấy kết quả"
        empty.TextColor3 = Colors.TextDim
        empty.TextSize = 14
        empty.Font = Enum.Font.Gotham
        empty.ZIndex = 140
        return
    end
    
    local y = 0
    for i, video in ipairs(results) do
        local item = Instance.new("Frame")
        item.Parent = ResultsFrame
        item.Size = UDim2.new(1, -16, 0, 55)
        item.Position = UDim2.new(0, 8, 0, y)
        item.BackgroundColor3 = Colors.Surface
        item.BorderSizePixel = 0
        item.ZIndex = 135
        
        local btn = Instance.new("TextButton")
        btn.Parent = item
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 140
        
        local title = Instance.new("TextLabel")
        title.Parent = item
        title.Size = UDim2.new(0.7, -10, 0.5, 0)
        title.Position = UDim2.new(0, 12, 0, 4)
        title.BackgroundTransparency = 1
        title.Text = video.title or "Unknown"
        title.TextColor3 = Colors.Text
        title.TextSize = 13
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextWrapped = true
        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.ZIndex = 145
        
        local channel = Instance.new("TextLabel")
        channel.Parent = item
        channel.Size = UDim2.new(0.6, -10, 0.3, 0)
        channel.Position = UDim2.new(0, 12, 0, 30)
        channel.BackgroundTransparency = 1
        channel.Text = video.channel or "Unknown"
        channel.TextColor3 = Colors.TextDim
        channel.TextSize = 11
        channel.Font = Enum.Font.Gotham
        channel.TextXAlignment = Enum.TextXAlignment.Left
        channel.ZIndex = 145
        
        local duration = Instance.new("TextLabel")
        duration.Parent = item
        duration.Size = UDim2.new(0.2, 0, 0.3, 0)
        duration.Position = UDim2.new(0.78, 0, 0.5, 0)
        duration.BackgroundTransparency = 1
        duration.Text = video.duration or "--:--"
        duration.TextColor3 = Colors.TextDim
        duration.TextSize = 11
        duration.Font = Enum.Font.Gotham
        duration.TextXAlignment = Enum.TextXAlignment.Right
        duration.ZIndex = 145
        
        btn.MouseButton1Click:Connect(function()
            PlayVideo(video.videoId, video)
        end)
        
        y = y + 60
    end
    
    ResultsFrame.CanvasSize = UDim2.new(0, 0, 0, y)
end

-- Phát video
local function PlayVideo(videoId, videoData)
    if not videoId then return end
    
    currentVideo = videoId
    local mediaType = currentMode
    local ext = mediaType == "video" and "webm" or "mp3"
    local path = "youtube_media/" .. mediaType .. "s/" .. videoId .. "." .. ext
    
    if videoData and videoData.title then
        NowPlaying.Text = "▶ " .. videoData.title
        NowPlaying.TextColor3 = Colors.Text
    else
        NowPlaying.Text = "▶ Đang tải: " .. videoId
        NowPlaying.TextColor3 = Colors.Text
    end
    
    if not isfile(path) then
        local loading = Instance.new("TextLabel")
        loading.Parent = PlayerFrame
        loading.Size = UDim2.new(1, 0, 1, 0)
        loading.BackgroundTransparency = 1
        loading.Text = "⏳ Đang tải..."
        loading.TextColor3 = Colors.Text
        loading.TextSize = 20
        loading.Font = Enum.Font.GothamBold
        loading.ZIndex = 200
        
        local data = RequestMedia(videoId, mediaType)
        loading:Destroy()
        
        if data then
            writefile(path, data)
            print("💾 Đã lưu:", path)
        else
            NowPlaying.Text = "❌ Lỗi tải video!"
            NowPlaying.TextColor3 = Color3.fromRGB(255, 50, 50)
            return
        end
    end
    
    if mediaType == "video" then
        VideoPlayer.Visible = true
        AudioFrame.Visible = false
        VideoPlayer.Video = GetAsset(path)
        VideoPlayer.Volume = currentVolume
        VideoPlayer:Play()
    else
        VideoPlayer.Visible = false
        AudioFrame.Visible = true
        if soundInst then soundInst:Destroy() end
        soundInst = Instance.new("Sound")
        soundInst.SoundId = GetAsset(path)
        soundInst.Volume = currentVolume
        soundInst.Parent = AudioFrame
        soundInst:Play()
    end
    
    PlayBtn.Text = "⏸"
    isPlaying = true
    FloatBtn.Text = "⏸"
end

-- ===== SEARCH =====
SearchBtn.MouseButton1Click:Connect(function()
    local query = SearchBox.Text
    if #query < 2 then
        NowPlaying.Text = "⚠️ Nhập ít nhất 2 ký tự"
        NowPlaying.TextColor3 = Color3.fromRGB(255, 200, 0)
        return
    end
    
    NowPlaying.Text = "⏳ Đang tìm: " .. query
    NowPlaying.TextColor3 = Colors.TextDim
    
    local results = SearchYouTube(query)
    
    if results and #results > 0 then
        queue = results
        queueIndex = 1
        DisplayResults(results)
        NowPlaying.Text = "✅ Tìm thấy " .. #results .. " kết quả"
        NowPlaying.TextColor3 = Color3.fromRGB(0, 200, 100)
        task.wait(2)
        NowPlaying.Text = "Chọn video để phát"
        NowPlaying.TextColor3 = Colors.TextDim
    else
        NowPlaying.Text = "❌ Không tìm thấy hoặc API lỗi. Kiểm tra console!"
        NowPlaying.TextColor3 = Color3.fromRGB(255, 50, 50)
        
        -- Load demo nếu API lỗi
        local demo = {
            {videoId = "dQw4w9WgXcQ", title = "Rick Astley - Never Gonna Give You Up (Demo)", channel = "Rick Astley", duration = "3:33"},
            {videoId = "JGwWNGJdvx8", title = "Despacito - Luis Fonsi (Demo)", channel = "Luis Fonsi", duration = "4:41"},
            {videoId = "fJ9rUzIMcZQ", title = "Queen - Bohemian Rhapsody (Demo)", channel = "Queen Official", duration = "5:55"},
        }
        queue = demo
        queueIndex = 1
        DisplayResults(demo)
        print("📢 Đã load demo vì API không hoạt động")
    end
end)

SearchBox.FocusLost:Connect(function(enter)
    if enter then SearchBtn.MouseButton1Click:Fire() end
end)

-- ===== LOAD LINK =====
LoadBtn.MouseButton1Click:Connect(function()
    local input = LinkBox.Text
    if #input < 3 then
        NowPlaying.Text = "⚠️ Nhập link hoặc Video ID"
        NowPlaying.TextColor3 = Color3.fromRGB(255, 200, 0)
        return
    end
    
    local videoId = getVideoId(input)
    if videoId then
        NowPlaying.Text = "▶ Đang phát: " .. videoId
        NowPlaying.TextColor3 = Colors.Text
        PlayVideo(videoId, {title = "Video ID: " .. videoId})
    else
        NowPlaying.Text = "❌ Không nhận diện được link"
        NowPlaying.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

LinkBox.FocusLost:Connect(function(enter)
    if enter then LoadBtn.MouseButton1Click:Fire() end
end)

-- ===== MODE =====
ModeVid.MouseButton1Click:Connect(function()
    currentMode = "video"
    ModeVid.BackgroundColor3 = Colors.Primary
    ModeVid.TextColor3 = Colors.Text
    ModeAud.BackgroundTransparency = 1
    ModeAud.TextColor3 = Colors.TextDim
    VideoPlayer.Visible = true
    AudioFrame.Visible = false
end)

ModeAud.MouseButton1Click:Connect(function()
    currentMode = "audio"
    ModeAud.BackgroundColor3 = Colors.Primary
    ModeAud.TextColor3 = Colors.Text
    ModeVid.BackgroundTransparency = 1
    ModeVid.TextColor3 = Colors.TextDim
    VideoPlayer.Visible = false
    AudioFrame.Visible = true
end)

-- ===== CONTROLS =====
PlayBtn.MouseButton1Click:Connect(function()
    if currentVideo == nil then
        if #queue > 0 then
            PlayVideo(queue[1].videoId, queue[1])
        end
        return
    end
    
    if isPlaying then
        if currentMode == "video" then
            VideoPlayer:Pause()
        else
            if soundInst then soundInst:Pause() end
        end
        PlayBtn.Text = "▶"
        isPlaying = false
        FloatBtn.Text = "▶"
    else
        if currentMode == "video" then
            VideoPlayer:Play()
        else
            if soundInst then soundInst:Resume() end
        end
        PlayBtn.Text = "⏸"
        isPlaying = true
        FloatBtn.Text = "⏸"
    end
end)

LoopBtn.MouseButton1Click:Connect(function()
    isLooping = not isLooping
    LoopBtn.TextColor3 = isLooping and Colors.Primary or Colors.Text
    if currentMode == "video" then
        VideoPlayer.Looped = isLooping
    else
        if soundInst then soundInst.Looped = isLooping end
    end
end)

PrevBtn.MouseButton1Click:Connect(function()
    if #queue > 0 then
        queueIndex = math.max(1, queueIndex - 1)
        PlayVideo(queue[queueIndex].videoId, queue[queueIndex])
    end
end)

NextBtn.MouseButton1Click:Connect(function()
    if #queue > 0 then
        queueIndex = math.min(#queue, queueIndex + 1)
        PlayVideo(queue[queueIndex].videoId, queue[queueIndex])
    end
end)

-- ===== TIMELINE =====
RunService.RenderStepped:Connect(function()
    if currentMode == "video" and VideoPlayer.Visible and VideoPlayer.IsLoaded then
        if VideoPlayer.TimeLength > 0 then
            local progress = VideoPlayer.TimePosition / VideoPlayer.TimeLength
            TimelineLine.Size = UDim2.new(math.clamp(progress, 0, 1), 0, 1, 0)
        end
    elseif currentMode == "audio" and soundInst and soundInst.IsLoaded then
        if soundInst.TimeLength > 0 then
            local progress = soundInst.TimePosition / soundInst.TimeLength
            TimelineLine.Size = UDim2.new(math.clamp(progress, 0, 1), 0, 1, 0)
        end
    end
end)

Timeline.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position.X - Timeline.AbsolutePosition.X
        local progress = math.clamp(pos / Timeline.AbsoluteSize.X, 0, 1)
        if currentMode == "video" and VideoPlayer.Visible and VideoPlayer.IsLoaded then
            VideoPlayer.TimePosition = VideoPlayer.TimeLength * progress
        elseif currentMode == "audio" and soundInst and soundInst.IsLoaded then
            soundInst.TimePosition = soundInst.TimeLength * progress
        end
    end
end)

-- ===== FLOATING BUTTON =====
local menuOpen = false

FloatBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    MainWindow.Visible = menuOpen
    if not menuOpen then FloatBtn.Text = "▶" end
end)

-- ===== KÉO FLOATING =====
local floatDrag = false
local floatStart = nil
local floatPos = nil

FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        floatDrag = true
        floatStart = input.Position
        floatPos = FloatBtn.Position
    end
end)

FloatBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        floatDrag = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if floatDrag and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - floatStart
        local newX = math.clamp(floatPos.X.Offset + delta.X, 0, 800 - 70)
        local newY = math.clamp(floatPos.Y.Offset + delta.Y, 0, 600 - 70)
        FloatBtn.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- ===== DEMO =====
task.wait(0.5)
local demo = {
    {videoId = "dQw4w9WgXcQ", title = "Rick Astley - Never Gonna Give You Up", channel = "Rick Astley", duration = "3:33"},
    {videoId = "JGwWNGJdvx8", title = "Despacito - Luis Fonsi ft. Daddy Yankee", channel = "Luis Fonsi", duration = "4:41"},
    {videoId = "fJ9rUzIMcZQ", title = "Queen - Bohemian Rhapsody", channel = "Queen Official", duration = "5:55"},
}
queue = demo
queueIndex = 1
DisplayResults(demo)

print("✅ YouTube Player Pro - Fix Loading!")
print("📌 Nếu API lỗi, script vẫn hiển thị demo")
print("📌 Xem console để biết lỗi chi tiết")
