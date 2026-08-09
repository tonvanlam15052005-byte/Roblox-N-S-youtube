--[[
    YouTube Player - Mobile
    Đơn giản, không lỗi
]]

local player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- ===== REQUEST =====
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

-- ===== NÚT MỞ MENU =====
local FloatBtn = Instance.new("TextButton")
FloatBtn.Parent = ScreenGui
FloatBtn.Size = UDim2.new(0, 60, 0, 60)
FloatBtn.Position = UDim2.new(0.85, -30, 0.85, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FloatBtn.Text = "▶"
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.TextSize = 28
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.BorderSizePixel = 0

local Corner = Instance.new("UICorner")
Corner.Parent = FloatBtn
Corner.CornerRadius = UDim.new(1, 0)

-- ===== TẠO WINDOW =====
local MainWindow = Instance.new("Frame")
MainWindow.Parent = ScreenGui
MainWindow.Size = UDim2.new(0, 350, 0, 500)
MainWindow.Position = UDim2.new(0.5, -175, 0.5, -250)
MainWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainWindow.BorderSizePixel = 0
MainWindow.Visible = false

local WindowCorner = Instance.new("UICorner")
WindowCorner.Parent = MainWindow
WindowCorner.CornerRadius = UDim.new(0, 10)

-- ===== TITLE =====
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainWindow
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.BorderSizePixel = 0

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.Size = UDim2.new(0.7, 0, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🎬 YouTube Player"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 14
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.MouseButton1Click:Connect(function()
    MainWindow.Visible = false
end)

-- ===== SEARCH =====
local SearchFrame = Instance.new("Frame")
SearchFrame.Parent = MainWindow
SearchFrame.Size = UDim2.new(1, 0, 0, 50)
SearchFrame.Position = UDim2.new(0, 0, 0, 40)
SearchFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SearchFrame.BorderSizePixel = 0

local SearchBox = Instance.new("TextBox")
SearchBox.Parent = SearchFrame
SearchBox.Size = UDim2.new(0.6, -10, 0, 35)
SearchBox.Position = UDim2.new(0, 10, 0, 7)
SearchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "🔍 Tìm video..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.TextSize = 14
SearchBox.Font = Enum.Font.Gotham
SearchBox.ClearTextOnFocus = false

local SearchBtn = Instance.new("TextButton")
SearchBtn.Parent = SearchFrame
SearchBtn.Size = UDim2.new(0, 70, 0, 35)
SearchBtn.Position = UDim2.new(0.68, 0, 0, 7)
SearchBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
SearchBtn.BorderSizePixel = 0
SearchBtn.Text = "Tìm"
SearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBtn.TextSize = 14
SearchBtn.Font = Enum.Font.GothamBold

-- ===== MODE =====
local ModeFrame = Instance.new("Frame")
ModeFrame.Parent = SearchFrame
ModeFrame.Size = UDim2.new(0, 100, 0, 30)
ModeFrame.Position = UDim2.new(0.82, 0, 0, 10)
ModeFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ModeFrame.BorderSizePixel = 0

local ModeVid = Instance.new("TextButton")
ModeVid.Parent = ModeFrame
ModeVid.Size = UDim2.new(0.5, 0, 1, 0)
ModeVid.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ModeVid.BorderSizePixel = 0
ModeVid.Text = "🎥"
ModeVid.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeVid.TextSize = 14
ModeVid.Font = Enum.Font.GothamBold

local ModeAud = Instance.new("TextButton")
ModeAud.Parent = ModeFrame
ModeAud.Size = UDim2.new(0.5, 0, 1, 0)
ModeAud.Position = UDim2.new(0.5, 0, 0, 0)
ModeAud.BackgroundTransparency = 1
ModeAud.BorderSizePixel = 0
ModeAud.Text = "🎵"
ModeAud.TextColor3 = Color3.fromRGB(150, 150, 150)
ModeAud.TextSize = 14
ModeAud.Font = Enum.Font.GothamBold

local currentMode = "video"

-- ===== VIDEO PLAYER =====
local PlayerFrame = Instance.new("Frame")
PlayerFrame.Parent = MainWindow
PlayerFrame.Size = UDim2.new(1, 0, 0, 200)
PlayerFrame.Position = UDim2.new(0, 0, 0, 90)
PlayerFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PlayerFrame.BorderSizePixel = 0

local VideoPlayer = Instance.new("VideoFrame")
VideoPlayer.Parent = PlayerFrame
VideoPlayer.Size = UDim2.new(1, 0, 1, 0)
VideoPlayer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

local AudioFrame = Instance.new("Frame")
AudioFrame.Parent = PlayerFrame
AudioFrame.Size = UDim2.new(1, 0, 1, 0)
AudioFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
AudioFrame.Visible = false

local AudioText = Instance.new("TextLabel")
AudioText.Parent = AudioFrame
AudioText.Size = UDim2.new(1, 0, 1, 0)
AudioText.BackgroundTransparency = 1
AudioText.Text = "🎵"
AudioText.TextColor3 = Color3.fromRGB(255, 0, 0)
AudioText.TextSize = 60
AudioText.Font = Enum.Font.GothamBold

-- ===== NOW PLAYING =====
local NowPlaying = Instance.new("TextLabel")
NowPlaying.Parent = MainWindow
NowPlaying.Size = UDim2.new(0.9, 0, 0, 25)
NowPlaying.Position = UDim2.new(0.05, 0, 0, 295)
NowPlaying.BackgroundTransparency = 1
NowPlaying.Text = "Chọn video để phát"
NowPlaying.TextColor3 = Color3.fromRGB(150, 150, 150)
NowPlaying.TextSize = 12
NowPlaying.Font = Enum.Font.Gotham
NowPlaying.TextTruncate = Enum.TextTruncate.AtEnd

-- ===== TIMELINE =====
local Timeline = Instance.new("Frame")
Timeline.Parent = MainWindow
Timeline.Size = UDim2.new(0.9, 0, 0, 15)
Timeline.Position = UDim2.new(0.05, 0, 0, 320)
Timeline.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Timeline.BorderSizePixel = 0

local TimelineLine = Instance.new("Frame")
TimelineLine.Parent = Timeline
TimelineLine.Size = UDim2.new(0, 0, 1, 0)
TimelineLine.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TimelineLine.BorderSizePixel = 0

-- ===== CONTROLS =====
local Controls = Instance.new("Frame")
Controls.Parent = MainWindow
Controls.Size = UDim2.new(1, 0, 0, 50)
Controls.Position = UDim2.new(0, 0, 0, 340)
Controls.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Controls.BorderSizePixel = 0

local function MakeBtn(parent, pos, text, size)
    size = size or 40
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(0, size, 0, size)
    btn.Position = pos
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 22
    btn.Font = Enum.Font.GothamBold
    return btn
end

local PlayBtn = MakeBtn(Controls, UDim2.new(0.5, -50, 0, 5), "▶", 50)
local PrevBtn = MakeBtn(Controls, UDim2.new(0.5, -100, 0, 5), "⏮", 35)
local NextBtn = MakeBtn(Controls, UDim2.new(0.5, 0, 0, 5), "⏭", 35)
local LoopBtn = MakeBtn(Controls, UDim2.new(0.5, 50, 0, 5), "🔁", 35)

-- ===== RESULTS =====
local ResultsFrame = Instance.new("ScrollingFrame")
ResultsFrame.Parent = MainWindow
ResultsFrame.Size = UDim2.new(1, 0, 0, 100)
ResultsFrame.Position = UDim2.new(0, 0, 0, 395)
ResultsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ResultsFrame.BorderSizePixel = 0
ResultsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ResultsFrame.ScrollBarThickness = 4
ResultsFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)

-- ===== SEARCH FUNCTION =====
local function SearchYouTube(query)
    local response = Request({
        Method = "GET",
        Url = Domain .. "yt/search?q=" .. HttpService:UrlEncode(query) .. "&limit=10"
    })
    if response and response.StatusCode == 200 then
        return HttpService:JSONDecode(response.Body)
    end
    return nil
end

-- ===== REQUEST VIDEO =====
local function RequestVideo(videoId, type)
    type = type or "video"
    local response = Request({
        Method = "POST",
        Url = Domain .. "yt/" .. type .. "?videoId=" .. videoId,
    })
    if response and response.StatusCode == 404 then return false end
    return response and response.Body or false
end

-- ===== DISPLAY RESULTS =====
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
        empty.Text = "Không tìm thấy"
        empty.TextColor3 = Color3.fromRGB(150, 150, 150)
        empty.TextSize = 14
        empty.Font = Enum.Font.Gotham
        return
    end
    
    local y = 0
    for i, video in ipairs(results) do
        local item = Instance.new("Frame")
        item.Parent = ResultsFrame
        item.Size = UDim2.new(1, -20, 0, 60)
        item.Position = UDim2.new(0, 10, 0, y)
        item.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        item.BorderSizePixel = 0
        
        local btn = Instance.new("TextButton")
        btn.Parent = item
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        
        local title = Instance.new("TextLabel")
        title.Parent = item
        title.Size = UDim2.new(0.7, -10, 0.5, 0)
        title.Position = UDim2.new(0, 10, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = video.title or "Unknown"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 12
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextWrapped = true
        
        local channel = Instance.new("TextLabel")
        channel.Parent = item
        channel.Size = UDim2.new(0.7, -10, 0.3, 0)
        channel.Position = UDim2.new(0, 10, 0, 32)
        channel.BackgroundTransparency = 1
        channel.Text = video.channel or "Unknown"
        channel.TextColor3 = Color3.fromRGB(150, 150, 150)
        channel.TextSize = 11
        channel.Font = Enum.Font.Gotham
        channel.TextXAlignment = Enum.TextXAlignment.Left
        
        local duration = Instance.new("TextLabel")
        duration.Parent = item
        duration.Size = UDim2.new(0.2, 0, 0.3, 0)
        duration.Position = UDim2.new(0.78, 0, 0.5, 0)
        duration.BackgroundTransparency = 1
        duration.Text = video.duration or "--:--"
        duration.TextColor3 = Color3.fromRGB(150, 150, 150)
        duration.TextSize = 11
        duration.Font = Enum.Font.Gotham
        duration.TextXAlignment = Enum.TextXAlignment.Right
        
        btn.MouseButton1Click:Connect(function()
            PlayVideo(video.videoId, video)
        end)
        
        y = y + 65
    end
    
    ResultsFrame.CanvasSize = UDim2.new(0, 0, 0, y)
end

-- ===== PLAY VIDEO =====
local soundInst = nil
local isPlaying = false
local isLooping = false
local currentVideo = nil

local function PlayVideo(videoId, videoData)
    if not videoId then return end
    
    currentVideo = videoId
    local mediaType = currentMode
    local ext = mediaType == "video" and "webm" or "mp3"
    local path = "youtube_media/" .. mediaType .. "s/" .. videoId .. "." .. ext
    
    if videoData and videoData.title then
        NowPlaying.Text = "▶ " .. videoData.title
        NowPlaying.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    if not isfile(path) then
        local loading = Instance.new("TextLabel")
        loading.Parent = PlayerFrame
        loading.Size = UDim2.new(1, 0, 1, 0)
        loading.BackgroundTransparency = 1
        loading.Text = "⏳ Đang tải..."
        loading.TextColor3 = Color3.fromRGB(255, 255, 255)
        loading.TextSize = 20
        loading.Font = Enum.Font.GothamBold
        loading.ZIndex = 10
        
        local data = RequestVideo(videoId, mediaType)
        loading:Destroy()
        
        if data then
            writefile(path, data)
        else
            NowPlaying.Text = "❌ Lỗi tải!"
            NowPlaying.TextColor3 = Color3.fromRGB(255, 50, 50)
            return
        end
    end
    
    if mediaType == "video" then
        VideoPlayer.Visible = true
        AudioFrame.Visible = false
        VideoPlayer.Video = GetAsset(path)
        VideoPlayer:Play()
    else
        VideoPlayer.Visible = false
        AudioFrame.Visible = true
        if soundInst then soundInst:Destroy() end
        soundInst = Instance.new("Sound")
        soundInst.SoundId = GetAsset(path)
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
    if #query < 2 then return end
    
    NowPlaying.Text = "🔍 Đang tìm: " .. query
    NowPlaying.TextColor3 = Color3.fromRGB(150, 150, 150)
    
    local results = SearchYouTube(query)
    if results then
        DisplayResults(results)
        NowPlaying.Text = "✅ Tìm thấy " .. #results .. " kết quả"
        NowPlaying.TextColor3 = Color3.fromRGB(0, 150, 255)
        task.wait(1.5)
        NowPlaying.Text = "Chọn video để phát"
        NowPlaying.TextColor3 = Color3.fromRGB(150, 150, 150)
    else
        NowPlaying.Text = "❌ Không tìm thấy"
        NowPlaying.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

-- ===== MODE =====
ModeVid.MouseButton1Click:Connect(function()
    currentMode = "video"
    ModeVid.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    ModeVid.TextColor3 = Color3.fromRGB(255, 255, 255)
    ModeAud.BackgroundTransparency = 1
    ModeAud.TextColor3 = Color3.fromRGB(150, 150, 150)
    VideoPlayer.Visible = true
    AudioFrame.Visible = false
end)

ModeAud.MouseButton1Click:Connect(function()
    currentMode = "audio"
    ModeAud.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    ModeAud.TextColor3 = Color3.fromRGB(255, 255, 255)
    ModeVid.BackgroundTransparency = 1
    ModeVid.TextColor3 = Color3.fromRGB(150, 150, 150)
    VideoPlayer.Visible = false
    AudioFrame.Visible = true
end)

-- ===== CONTROLS =====
PlayBtn.MouseButton1Click:Connect(function()
    if currentVideo == nil then
        PlayVideo("dQw4w9WgXcQ", {
            title = "Rick Astley - Never Gonna Give You Up",
            channel = "Rick Astley",
            duration = "3:33"
        })
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
    LoopBtn.TextColor3 = isLooping and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
    if currentMode == "video" then
        VideoPlayer.Looped = isLooping
    else
        if soundInst then soundInst.Looped = isLooping end
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
end)

-- ===== DEMO =====
task.wait(0.5)
DisplayResults({
    {videoId = "dQw4w9WgXcQ", title = "Rick Astley - Never Gonna Give You Up", channel = "Rick Astley", duration = "3:33"},
    {videoId = "JGwWNGJdvx8", title = "Despacito - Luis Fonsi ft. Daddy Yankee", channel = "Luis Fonsi", duration = "4:41"},
    {videoId = "fJ9rUzIMcZQ", title = "Queen - Bohemian Rhapsody", channel = "Queen Official", duration = "5:55"},
})

print("✅ YouTube Player đã sẵn sàng!")
print("📱 Chạm nút đỏ để mở menu")
