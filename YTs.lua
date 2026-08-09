--[[
    YouTube Player Pro - Mobile Fixed
    Sửa lỗi touch, UI lên khi bấm nút
]]

local player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ===== CONFIG =====
local Request = request or (http and http.request) or (syn and syn.request)
local GetAsset = getcustomasset or getsynasset
local Domain = "https://parvus.fun/"

-- ===== TẠO FOLDER =====
if not isfolder("youtube_media") then makefolder("youtube_media") end
if not isfolder("youtube_media/videos") then makefolder("youtube_media/videos") end
if not isfolder("youtube_media/audios") then makefolder("youtube_media/audios") end

-- ===== LẤY KÍCH THƯỚC MÀN HÌNH =====
local screenSize = player:GetMouse().ViewSizeX and Vector2.new(
    player:GetMouse().ViewSizeX,
    player:GetMouse().ViewSizeY
) or Vector2.new(800, 600)

local isTablet = screenSize.X > 600

-- ===== TẠO GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player.PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ===== STYLE =====
local Colors = {
    BG = Color3.fromRGB(20, 20, 25),
    Surface = Color3.fromRGB(30, 30, 38),
    Surface2 = Color3.fromRGB(40, 40, 50),
    Primary = Color3.fromRGB(255, 0, 0),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(160, 160, 170),
    TextDark = Color3.fromRGB(100, 100, 110),
}

-- ===== NÚT MỞ MENU =====
local FloatBtn = Instance.new("ImageButton")
FloatBtn.Parent = ScreenGui
FloatBtn.Size = UDim2.new(0, 65, 0, 65)
FloatBtn.Position = UDim2.new(0.88, -32, 0.85, 0)
FloatBtn.BackgroundColor3 = Colors.Primary
FloatBtn.BorderSizePixel = 0
FloatBtn.Image = "rbxassetid://6026663719"
FloatBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.ScaleType = Enum.ScaleType.Fit
FloatBtn.ZIndex = 999

local FloatShadow = Instance.new("ImageLabel")
FloatShadow.Parent = FloatBtn
FloatShadow.Size = UDim2.new(1.3, 0, 1.3, 0)
FloatShadow.Position = UDim2.new(-0.15, 0, -0.15, 0)
FloatShadow.BackgroundTransparency = 1
FloatShadow.Image = "rbxassetid://131599993"
FloatShadow.ImageTransparency = 0.7
FloatShadow.ScaleType = Enum.ScaleType.Slice
FloatShadow.SliceCenter = Rect.new(10, 10, 10, 10)
FloatShadow.ZIndex = 0

local FloatCorner = Instance.new("UICorner")
FloatCorner.Parent = FloatBtn
FloatCorner.CornerRadius = UDim.new(1, 0)

local PlayBadge = Instance.new("TextLabel")
PlayBadge.Parent = FloatBtn
PlayBadge.Size = UDim2.new(0.5, 0, 0.5, 0)
PlayBadge.Position = UDim2.new(0.25, 0, 0.25, 0)
PlayBadge.BackgroundTransparency = 1
PlayBadge.Text = "▶"
PlayBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayBadge.TextSize = 20
PlayBadge.Font = Enum.Font.GothamBold
PlayBadge.ZIndex = 10

-- ===== MAIN WINDOW =====
local winWidth = math.min(420, screenSize.X - 20)
local winHeight = math.min(580, screenSize.Y - 40)

local MainWindow = Instance.new("Frame")
MainWindow.Parent = ScreenGui
MainWindow.Size = UDim2.new(0, winWidth, 0, winHeight)
MainWindow.Position = UDim2.new(0.5, -winWidth/2, 0.5, -winHeight/2)
MainWindow.BackgroundColor3 = Colors.BG
MainWindow.BorderSizePixel = 0
MainWindow.Visible = false
MainWindow.ZIndex = 100
MainWindow.ClipsDescendants = true

local WinCorner = Instance.new("UICorner")
WinCorner.Parent = MainWindow
WinCorner.CornerRadius = UDim.new(0, 16)

local WinShadow = Instance.new("ImageLabel")
WinShadow.Parent = MainWindow
WinShadow.Size = UDim2.new(1.1, 0, 1.1, 0)
WinShadow.Position = UDim2.new(-0.05, 0, -0.05, 0)
WinShadow.BackgroundTransparency = 1
WinShadow.Image = "rbxassetid://131599993"
WinShadow.ImageTransparency = 0.8
WinShadow.ScaleType = Enum.ScaleType.Slice
WinShadow.SliceCenter = Rect.new(10, 10, 10, 10)
WinShadow.ZIndex = -1

-- ===== DRAG SYSTEM =====
local isDragging = false
local dragStart = nil
local startPos = nil

local function SetupDrag(object)
    object.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = MainWindow.Position
        end
    end)
    
    object.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
end

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        local newX = startPos.X.Offset + delta.X
        local newY = startPos.Y.Offset + delta.Y
        local maxX = screenSize.X - winWidth
        local maxY = screenSize.Y - winHeight
        newX = math.clamp(newX, 0, maxX)
        newY = math.clamp(newY, 0, maxY)
        MainWindow.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- ===== TITLE BAR =====
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainWindow
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Colors.Surface
TitleBar.BorderSizePixel = 0
SetupDrag(TitleBar)

local TitleCorner = Instance.new("UICorner")
TitleCorner.Parent = TitleBar
TitleCorner.CornerRadius = UDim.new(0, 16)

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.Size = UDim2.new(0.6, 0, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🎬 YouTube Player"
TitleText.TextColor3 = Colors.Text
TitleText.TextSize = 17
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 50, 1, 0)
CloseBtn.Position = UDim2.new(1, -50, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Colors.TextDim
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold

-- Dùng MouseButton1Click cho Close
CloseBtn.MouseButton1Click:Connect(function()
    MainWindow.Visible = false
    PlayBadge.Text = "▶"
end)

-- ===== SEARCH BAR =====
local SearchFrame = Instance.new("Frame")
SearchFrame.Parent = MainWindow
SearchFrame.Size = UDim2.new(1, 0, 0, 55)
SearchFrame.Position = UDim2.new(0, 0, 0, 50)
SearchFrame.BackgroundColor3 = Colors.Surface2
SearchFrame.BorderSizePixel = 0

local SearchBox = Instance.new("TextBox")
SearchBox.Parent = SearchFrame
SearchBox.Size = UDim2.new(0.6, -15, 0, 38)
SearchBox.Position = UDim2.new(0, 12, 0, 8)
SearchBox.BackgroundColor3 = Colors.BG
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "🔍 Tìm video..."
SearchBox.PlaceholderColor3 = Colors.TextDim
SearchBox.TextColor3 = Colors.Text
SearchBox.TextSize = 15
SearchBox.Font = Enum.Font.Gotham
SearchBox.ClearTextOnFocus = false

local SearchCorner = Instance.new("UICorner")
SearchCorner.Parent = SearchBox
SearchCorner.CornerRadius = UDim.new(0, 8)

local SearchBtn = Instance.new("TextButton")
SearchBtn.Parent = SearchFrame
SearchBtn.Size = UDim2.new(0, 70, 0, 38)
SearchBtn.Position = UDim2.new(0.67, 0, 0, 8)
SearchBtn.BackgroundColor3 = Colors.Primary
SearchBtn.BorderSizePixel = 0
SearchBtn.Text = "Tìm"
SearchBtn.TextColor3 = Colors.Text
SearchBtn.TextSize = 15
SearchBtn.Font = Enum.Font.GothamBold

local SearchCorner2 = Instance.new("UICorner")
SearchCorner2.Parent = SearchBtn
SearchCorner2.CornerRadius = UDim.new(0, 8)

-- ===== MODE SWITCH =====
local ModeFrame = Instance.new("Frame")
ModeFrame.Parent = SearchFrame
ModeFrame.Size = UDim2.new(0, 90, 0, 32)
ModeFrame.Position = UDim2.new(0.8, 0, 0, 11)
ModeFrame.BackgroundColor3 = Colors.BG
ModeFrame.BorderSizePixel = 0

local ModeCorner = Instance.new("UICorner")
ModeCorner.Parent = ModeFrame
ModeCorner.CornerRadius = UDim.new(0, 6)

local ModeVid = Instance.new("TextButton")
ModeVid.Parent = ModeFrame
ModeVid.Size = UDim2.new(0.5, 0, 1, 0)
ModeVid.BackgroundColor3 = Colors.Primary
ModeVid.BorderSizePixel = 0
ModeVid.Text = "🎥"
ModeVid.TextColor3 = Colors.Text
ModeVid.TextSize = 14
ModeVid.Font = Enum.Font.GothamBold

local ModeVidCorner = Instance.new("UICorner")
ModeVidCorner.Parent = ModeVid
ModeVidCorner.CornerRadius = UDim.new(0, 6)

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

local currentMode = "video"

-- ===== PLAYER =====
local playerHeight = isTablet and 250 or 200
local PlayerFrame = Instance.new("Frame")
PlayerFrame.Parent = MainWindow
PlayerFrame.Size = UDim2.new(1, 0, 0, playerHeight)
PlayerFrame.Position = UDim2.new(0, 0, 0, 105)
PlayerFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PlayerFrame.BorderSizePixel = 0
PlayerFrame.ClipsDescendants = true

local VideoPlayer = Instance.new("VideoFrame")
VideoPlayer.Parent = PlayerFrame
VideoPlayer.Size = UDim2.new(1, 0, 1, 0)
VideoPlayer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

local AudioFrame = Instance.new("Frame")
AudioFrame.Parent = PlayerFrame
AudioFrame.Size = UDim2.new(1, 0, 1, 0)
AudioFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
AudioFrame.Visible = false

local AudioIcon = Instance.new("TextLabel")
AudioIcon.Parent = AudioFrame
AudioIcon.Size = UDim2.new(1, 0, 0.6, 0)
AudioIcon.Position = UDim2.new(0, 0, 0.2, 0)
AudioIcon.BackgroundTransparency = 1
AudioIcon.Text = "🎵"
AudioIcon.TextColor3 = Colors.Primary
AudioIcon.TextSize = 70
AudioIcon.Font = Enum.Font.GothamBold

local AudioStatus = Instance.new("TextLabel")
AudioStatus.Parent = AudioFrame
AudioStatus.Size = UDim2.new(0.8, 0, 0, 25)
AudioStatus.Position = UDim2.new(0.1, 0, 0.75, 0)
AudioStatus.BackgroundTransparency = 1
AudioStatus.Text = "Đang phát Audio..."
AudioStatus.TextColor3 = Colors.TextDim
AudioStatus.TextSize = 13
AudioStatus.Font = Enum.Font.Gotham

-- ===== NOW PLAYING =====
local NowPlaying = Instance.new("TextLabel")
NowPlaying.Parent = MainWindow
NowPlaying.Size = UDim2.new(0.9, 0, 0, 28)
NowPlaying.Position = UDim2.new(0.05, 0, 0, 105 + playerHeight + 5)
NowPlaying.BackgroundTransparency = 1
NowPlaying.Text = "👆 Chọn video để phát"
NowPlaying.TextColor3 = Colors.TextDim
NowPlaying.TextSize = 12
NowPlaying.Font = Enum.Font.Gotham
NowPlaying.TextTruncate = Enum.TextTruncate.AtEnd

-- ===== TIMELINE =====
local Timeline = Instance.new("Frame")
Timeline.Parent = MainWindow
Timeline.Size = UDim2.new(0.9, 0, 0, 18)
Timeline.Position = UDim2.new(0.05, 0, 0, 105 + playerHeight + 33)
Timeline.BackgroundColor3 = Colors.Surface2
Timeline.BorderSizePixel = 0

local TimelineCorner = Instance.new("UICorner")
TimelineCorner.Parent = Timeline
TimelineCorner.CornerRadius = UDim.new(0, 4)

local TimelineLine = Instance.new("Frame")
TimelineLine.Parent = Timeline
TimelineLine.Size = UDim2.new(0, 0, 1, 0)
TimelineLine.BackgroundColor3 = Colors.Primary
TimelineLine.BorderSizePixel = 0

local TimelineCorner2 = Instance.new("UICorner")
TimelineCorner2.Parent = TimelineLine
TimelineCorner2.CornerRadius = UDim.new(0, 4)

-- ===== CONTROLS =====
local Controls = Instance.new("Frame")
Controls.Parent = MainWindow
Controls.Size = UDim2.new(1, 0, 0, 55)
Controls.Position = UDim2.new(0, 0, 0, 105 + playerHeight + 55)
Controls.BackgroundColor3 = Colors.Surface
Controls.BorderSizePixel = 0

local function MakeBtn(parent, pos, text, size)
    size = size or 40
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(0, size, 0, size)
    btn.Position = pos
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = Colors.Text
    btn.TextSize = isTablet and 26 or 22
    btn.Font = Enum.Font.GothamBold
    return btn
end

local PlayBtn = MakeBtn(Controls, UDim2.new(0.5, -55, 0, 5), "▶", 50)
local PrevBtn = MakeBtn(Controls, UDim2.new(0.5, -110, 0, 5), "⏮", 38)
local NextBtn = MakeBtn(Controls, UDim2.new(0.5, 0, 0, 5), "⏭", 38)
local LoopBtn = MakeBtn(Controls, UDim2.new(0.5, 55, 0, 5), "🔁", 38)

-- ===== RESULTS =====
local resultsHeight = winHeight - (105 + playerHeight + 55 + 55 + 28)
local ResultsFrame = Instance.new("ScrollingFrame")
ResultsFrame.Parent = MainWindow
ResultsFrame.Size = UDim2.new(1, 0, 0, resultsHeight)
ResultsFrame.Position = UDim2.new(0, 0, 0, 105 + playerHeight + 55 + 55)
ResultsFrame.BackgroundColor3 = Colors.Surface2
ResultsFrame.BorderSizePixel = 0
ResultsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ResultsFrame.ScrollBarThickness = 4
ResultsFrame.ScrollBarImageColor3 = Colors.Primary

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
local function RequestVideoFile(videoId, type)
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
        empty.Text = "Không tìm thấy kết quả"
        empty.TextColor3 = Colors.TextDim
        empty.TextSize = 15
        empty.Font = Enum.Font.Gotham
        return
    end
    
    local y = 0
    for i, video in ipairs(results) do
        local item = Instance.new("Frame")
        item.Parent = ResultsFrame
        item.Size = UDim2.new(1, -16, 0, 60)
        item.Position = UDim2.new(0, 8, 0, y)
        item.BackgroundColor3 = Colors.Surface
        item.BorderSizePixel = 0
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.Parent = item
        itemCorner.CornerRadius = UDim.new(0, 8)
        
        local btn = Instance.new("TextButton")
        btn.Parent = item
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        
        local title = Instance.new("TextLabel")
        title.Parent = item
        title.Size = UDim2.new(0.7, -10, 0.5, 0)
        title.Position = UDim2.new(0, 12, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = video.title or "Unknown"
        title.TextColor3 = Colors.Text
        title.TextSize = 13
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextWrapped = true
        title.TextTruncate = Enum.TextTruncate.AtEnd
        
        local channel = Instance.new("TextLabel")
        channel.Parent = item
        channel.Size = UDim2.new(0.6, -10, 0.3, 0)
        channel.Position = UDim2.new(0, 12, 0, 32)
        channel.BackgroundTransparency = 1
        channel.Text = video.channel or "Unknown"
        channel.TextColor3 = Colors.TextDim
        channel.TextSize = 11
        channel.Font = Enum.Font.Gotham
        channel.TextXAlignment = Enum.TextXAlignment.Left
        
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
        
        -- Dùng MouseButton1Click (hoạt động trên cả touch)
        btn.MouseButton1Click:Connect(function()
            PlayVideo(video.videoId, video)
        end)
        
        -- Hover effect
        item.MouseEnter:Connect(function()
            item.BackgroundColor3 = Colors.Surface2
        end)
        item.MouseLeave:Connect(function()
            item.BackgroundColor3 = Colors.Surface
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
        NowPlaying.TextColor3 = Colors.Text
    end
    
    if not isfile(path) then
        local loading = Instance.new("TextLabel")
        loading.Parent = PlayerFrame
        loading.Size = UDim2.new(1, 0, 1, 0)
        loading.BackgroundTransparency = 1
        loading.Text = "⏳ Đang tải..."
        loading.TextColor3 = Colors.Text
        loading.TextSize = 22
        loading.Font = Enum.Font.GothamBold
        loading.ZIndex = 10
        
        local data = RequestVideoFile(videoId, mediaType)
        loading:Destroy()
        
        if data then
            writefile(path, data)
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
    PlayBadge.Text = "⏸"
end

-- ===== SEARCH =====
SearchBtn.MouseButton1Click:Connect(function()
    local query = SearchBox.Text
    if #query < 2 then
        NowPlaying.Text = "⚠️ Nhập ít nhất 2 ký tự"
        NowPlaying.TextColor3 = Color3.fromRGB(255, 200, 0)
        return
    end
    
    NowPlaying.Text = "🔍 Đang tìm: " .. query
    NowPlaying.TextColor3 = Colors.TextDim
    
    local results = SearchYouTube(query)
    if results then
        DisplayResults(results)
        NowPlaying.Text = "✅ Tìm thấy " .. #results .. " kết quả"
        NowPlaying.TextColor3 = Color3.fromRGB(0, 200, 100)
        task.wait(1.5)
        NowPlaying.Text = "Chọn video để phát"
        NowPlaying.TextColor3 = Colors.TextDim
    else
        NowPlaying.Text = "❌ Không tìm thấy"
        NowPlaying.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

SearchBox.FocusLost:Connect(function(enter)
    if enter then
        SearchBtn.MouseButton1Click:Fire()
    end
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
        PlayBadge.Text = "▶"
    else
        if currentMode == "video" then
            VideoPlayer:Play()
        else
            if soundInst then soundInst:Resume() end
        end
        PlayBtn.Text = "⏸"
        isPlaying = true
        PlayBadge.Text = "⏸"
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

-- ===== FLOATING BUTTON (DÙNG MouseButton1Click) =====
local menuOpen = false

FloatBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    MainWindow.Visible = menuOpen
    if not menuOpen then
        PlayBadge.Text = "▶"
    end
end)

-- ===== KÉO FLOATING BUTTON =====
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
        local newX = math.clamp(floatPos.X.Offset + delta.X, 0, screenSize.X - 70)
        local newY = math.clamp(floatPos.Y.Offset + delta.Y, 0, screenSize.Y - 70)
        FloatBtn.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- ===== LOAD DEMO =====
task.wait(0.5)
DisplayResults({
    {videoId = "dQw4w9WgXcQ", title = "Rick Astley - Never Gonna Give You Up", channel = "Rick Astley", duration = "3:33"},
    {videoId = "JGwWNGJdvx8", title = "Despacito - Luis Fonsi ft. Daddy Yankee", channel = "Luis Fonsi", duration = "4:41"},
    {videoId = "fJ9rUzIMcZQ", title = "Queen - Bohemian Rhapsody", channel = "Queen Official", duration = "5:55"},
})

print("✅ YouTube Player Pro - Mobile Fixed!")
print("📱 Chạm vào nút đỏ để mở menu")
