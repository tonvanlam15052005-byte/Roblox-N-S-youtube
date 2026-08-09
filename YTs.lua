--[[
    YouTube Pro Player V2.3 - Mobile Fixed
    Dành cho Delta Executor trên điện thoại
    Fix lỗi nil và touch
]]

local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- ===== CONFIG =====
local Request = request or (http and http.request) or (syn and syn.request)
local GetAsset = getcustomasset or getsynasset
local Domain = "https://parvus.fun/"

-- ===== TẠO FOLDER =====
if not isfolder("youtube_media") then makefolder("youtube_media") end
if not isfolder("youtube_media/videos") then makefolder("youtube_media/videos") end
if not isfolder("youtube_media/audios") then makefolder("youtube_media/audios") end

-- ===== TẠO SCREENGUI =====
local player = Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YouTubeProPlayer"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

-- ===== TẠO NÚT MỞ MENU (Floating Button) =====
local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "OpenMenuButton"
FloatingButton.Parent = ScreenGui
FloatingButton.Size = UDim2.new(0, 65, 0, 65)
FloatingButton.Position = UDim2.new(0.85, -35, 0.88, 0)
FloatingButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FloatingButton.BorderSizePixel = 0
FloatingButton.Text = "▶"
FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingButton.TextSize = 30
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.ZIndex = 999

-- Shadow
local ButtonShadow = Instance.new("ImageLabel")
ButtonShadow.Parent = FloatingButton
ButtonShadow.Size = UDim2.new(1.2, 0, 1.2, 0)
ButtonShadow.Position = UDim2.new(-0.1, 0, -0.1, 0)
ButtonShadow.BackgroundTransparency = 1
ButtonShadow.Image = "rbxassetid://131599993"
ButtonShadow.ImageTransparency = 0.7
ButtonShadow.ScaleType = Enum.ScaleType.Slice
ButtonShadow.SliceCenter = Rect.new(10, 10, 10, 10)
ButtonShadow.ZIndex = 0

-- Circle clip
local Clip = Instance.new("UICorner")
Clip.Parent = FloatingButton
Clip.CornerRadius = UDim.new(1, 0)

-- ===== STYLES =====
local Theme = {
    Background = Color3.fromRGB(18, 18, 18),
    Surface = Color3.fromRGB(30, 30, 30),
    Surface2 = Color3.fromRGB(40, 40, 40),
    Primary = Color3.fromRGB(255, 0, 0),
    PrimaryDark = Color3.fromRGB(200, 0, 0),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(0, 150, 255),
}

-- ===== HELPER FUNCTIONS =====
local function CreateUI(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k == "Parent" then continue end
        obj[k] = v
    end
    return obj
end

local function Tween(obj, props, duration, style)
    duration = duration or 0.3
    style = style or Enum.EasingStyle.Quad
    local tween = TweenService:Create(obj, TweenInfo.new(duration, style), props)
    tween:Play()
    return tween
end

-- ===== SEARCH FUNCTION =====
local searchCache = {}
local function SearchYouTube(query)
    if searchCache[query] then return searchCache[query] end
    
    local response = Request({
        Method = "GET",
        Url = Domain .. "yt/search?q=" .. HttpService:UrlEncode(query) .. "&limit=15"
    })
    
    if response and response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        searchCache[query] = data
        return data
    end
    return nil
end

-- ===== VIDEO/AUDIO FUNCTIONS =====
local function RequestVideo(VideoId, type)
    type = type or "video"
    local response = Request({
        Method = "POST",
        Url = Domain .. "yt/" .. type .. "?videoId=" .. VideoId,
    })
    if response and response.StatusCode == 404 then return false end
    return response and response.Body or false
end

-- ===== TẠO MAIN WINDOW =====
local MainWindow = CreateUI("Frame", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 0, 0, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = false,
    BackgroundTransparency = 1,
    ZIndex = 100,
})

-- Corner cho window
local WindowCorner = Instance.new("UICorner")
WindowCorner.Parent = MainWindow
WindowCorner.CornerRadius = UDim.new(0, 12)

-- ===== SHOW/HIDE WINDOW =====
local function ShowWindow()
    MainWindow.Visible = true
    MainWindow.Size = UDim2.new(0, 0, 0, 0)
    MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainWindow.BackgroundTransparency = 1
    
    local screenSize = Instance.new("ScreenGui").AbsoluteSize
    local width = math.min(380, screenSize.X - 20)
    local height = math.min(600, screenSize.Y - 80)
    
    Tween(MainWindow, {
        Size = UDim2.new(0, width, 0, height),
        Position = UDim2.new(0.5, -width/2, 0.5, -height/2),
        BackgroundTransparency = 0
    }, 0.4)
end

local function HideWindow()
    Tween(MainWindow, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1
    }, 0.3)
    task.wait(0.3)
    MainWindow.Visible = false
end

-- ===== TITLE BAR =====
local TitleBar = CreateUI("Frame", {
    Parent = MainWindow,
    Size = UDim2.new(1, 0, 0, 45),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
})

local TitleCorner = Instance.new("UICorner")
TitleCorner.Parent = TitleBar
TitleCorner.CornerRadius = UDim.new(0, 12)

CreateUI("TextLabel", {
    Parent = TitleBar,
    Size = UDim2.new(0.6, 0, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "🎬 YouTube Player",
    TextColor3 = Theme.Text,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local CloseBtn = CreateUI("TextButton", {
    Parent = TitleBar,
    Size = UDim2.new(0, 50, 1, 0),
    Position = UDim2.new(1, -50, 0, 0),
    BackgroundTransparency = 1,
    Text = "✕",
    TextColor3 = Theme.TextDim,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
})
CloseBtn.MouseButton1Click:Connect(HideWindow)
CloseBtn.TouchTap:Connect(HideWindow)

-- ===== SEARCH BAR =====
local SearchBar = CreateUI("Frame", {
    Parent = MainWindow,
    Size = UDim2.new(1, 0, 0, 65),
    Position = UDim2.new(0, 0, 0, 45),
    BackgroundColor3 = Theme.Surface2,
    BorderSizePixel = 0,
})

local SearchInput = CreateUI("TextBox", {
    Parent = SearchBar,
    Size = UDim2.new(0.6, -15, 0, 42),
    Position = UDim2.new(0, 10, 0, 11),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    PlaceholderText = "🔍 Tìm video...",
    PlaceholderColor3 = Theme.TextDim,
    TextColor3 = Theme.Text,
    TextSize = 15,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
})

local SearchBtn = CreateUI("TextButton", {
    Parent = SearchBar,
    Size = UDim2.new(0, 80, 0, 42),
    Position = UDim2.new(0.65, 5, 0, 11),
    BackgroundColor3 = Theme.Primary,
    BorderSizePixel = 0,
    Text = "Tìm",
    TextColor3 = Theme.Text,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
})
SearchBtn.MouseButton1Click:Connect(function() end)

-- ===== MODE SWITCH =====
local ModeFrame = CreateUI("Frame", {
    Parent = SearchBar,
    Size = UDim2.new(0, 110, 0, 32),
    Position = UDim2.new(0.8, 0, 0, 16),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
})

local ModeVideo = CreateUI("TextButton", {
    Parent = ModeFrame,
    Size = UDim2.new(0.5, 0, 1, 0),
    BackgroundColor3 = Theme.Primary,
    BorderSizePixel = 0,
    Text = "🎥",
    TextColor3 = Theme.Text,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
})

local ModeAudio = CreateUI("TextButton", {
    Parent = ModeFrame,
    Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0.5, 0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Text = "🎵",
    TextColor3 = Theme.TextDim,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
})

local currentMode = "video"

-- ===== PLAYER AREA =====
local PlayerArea = CreateUI("Frame", {
    Parent = MainWindow,
    Size = UDim2.new(1, 0, 0, 220),
    Position = UDim2.new(0, 0, 0, 110),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
})

local VideoPlayer = CreateUI("VideoFrame", {
    Parent = PlayerArea,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    Visible = true,
})

local AudioPlayer = CreateUI("Frame", {
    Parent = PlayerArea,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(20, 20, 30),
    Visible = false,
})

CreateUI("TextLabel", {
    Parent = AudioPlayer,
    Size = UDim2.new(1, 0, 0.5, 0),
    Position = UDim2.new(0, 0, 0.2, 0),
    BackgroundTransparency = 1,
    Text = "🎵",
    TextColor3 = Theme.Primary,
    TextSize = 50,
    Font = Enum.Font.GothamBold,
})

CreateUI("TextLabel", {
    Parent = AudioPlayer,
    Size = UDim2.new(0.8, 0, 0, 25),
    Position = UDim2.new(0.1, 0, 0.7, 0),
    BackgroundTransparency = 1,
    Text = "Đang phát Audio...",
    TextColor3 = Theme.TextDim,
    TextSize = 13,
    Font = Enum.Font.Gotham,
})

-- ===== NOW PLAYING =====
local NowPlaying = CreateUI("TextLabel", {
    Parent = MainWindow,
    Size = UDim2.new(0.9, 0, 0, 28),
    Position = UDim2.new(0.05, 0, 0, 335),
    BackgroundTransparency = 1,
    Text = "👆 Chọn video để phát",
    TextColor3 = Theme.TextDim,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextTruncate = Enum.TextTruncate.AtEnd,
})

-- ===== TIMELINE =====
local Timeline = CreateUI("Frame", {
    Parent = MainWindow,
    Size = UDim2.new(0.9, 0, 0, 20),
    Position = UDim2.new(0.05, 0, 0, 362),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
})

local TimelineLine = CreateUI("Frame", {
    Parent = Timeline,
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Theme.Primary,
    BorderSizePixel = 0,
})

-- ===== CONTROLS =====
local Controls = CreateUI("Frame", {
    Parent = MainWindow,
    Size = UDim2.new(1, 0, 0, 55),
    Position = UDim2.new(0, 0, 0, 385),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
})

local function CreateControlButton(parent, pos, text, size)
    size = size or 50
    local btn = CreateUI("TextButton", {
        Parent = parent,
        Size = UDim2.new(0, size, 0, size),
        Position = pos,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 26,
        Font = Enum.Font.GothamBold,
    })
    return btn
end

local PlayBtn = CreateControlButton(Controls, UDim2.new(0.5, -65, 0, 2), "▶", 50)
local PrevBtn = CreateControlButton(Controls, UDim2.new(0.5, -120, 0, 2), "⏮", 40)
local NextBtn = CreateControlButton(Controls, UDim2.new(0.5, -10, 0, 2), "⏭", 40)
local LoopBtn = CreateControlButton(Controls, UDim2.new(0.5, 45, 0, 2), "🔁", 40)

-- ===== RESULTS AREA =====
local ResultsArea = CreateUI("ScrollingFrame", {
    Parent = MainWindow,
    Size = UDim2.new(1, 0, 0, 110),
    Position = UDim2.new(0, 0, 0, 440),
    BackgroundColor3 = Theme.Surface2,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 6,
    ScrollBarImageColor3 = Theme.Primary,
    Visible = true,
})

-- ===== DISPLAY RESULTS =====
local function DisplayResults(results)
    for _, child in pairs(ResultsArea:GetChildren()) do
        if child:IsA("ImageButton") or child:IsA("TextLabel") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if not results or #results == 0 then
        local empty = CreateUI("TextLabel", {
            Parent = ResultsArea,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "Không tìm thấy video",
            TextColor3 = Theme.TextDim,
            TextSize = 15,
            Font = Enum.Font.Gotham,
        })
        return
    end
    
    local y = 0
    for i, video in ipairs(results) do
        local item = CreateUI("Frame", {
            Parent = ResultsArea,
            Size = UDim2.new(1, -20, 0, 70),
            Position = UDim2.new(0, 10, 0, y),
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel = 0,
        })
        
        local btn = CreateUI("TextButton", {
            Parent = item,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
        })
        
        CreateUI("TextLabel", {
            Parent = item,
            Size = UDim2.new(0.7, -20, 0.5, 0),
            Position = UDim2.new(0, 10, 0, 5),
            BackgroundTransparency = 1,
            Text = video.title or "Unknown",
            TextColor3 = Theme.Text,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
        })
        
        CreateUI("TextLabel", {
            Parent = item,
            Size = UDim2.new(0.7, -20, 0.3, 0),
            Position = UDim2.new(0, 10, 0, 38),
            BackgroundTransparency = 1,
            Text = video.channel or "Unknown",
            TextColor3 = Theme.TextDim,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        CreateUI("TextLabel", {
            Parent = item,
            Size = UDim2.new(0.2, 0, 0.3, 0),
            Position = UDim2.new(0.78, 0, 0.6, 0),
            BackgroundTransparency = 1,
            Text = video.duration or "--:--",
            TextColor3 = Theme.TextDim,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Right,
        })
        
        btn.MouseButton1Click:Connect(function()
            PlayVideo(video.videoId, video)
        end)
        btn.TouchTap:Connect(function()
            PlayVideo(video.videoId, video)
        end)
        
        y = y + 75
    end
    
    ResultsArea.CanvasSize = UDim2.new(0, 0, 0, y)
end

-- ===== PLAY FUNCTION =====
local soundInstance = nil
local isPlaying = false
local isLooping = false
local currentVideoId = nil

local function PlayVideo(videoId, videoData)
    if not videoId then return end
    
    currentVideoId = videoId
    local mediaType = currentMode
    local fileExt = mediaType == "video" and "webm" or "mp3"
    local filePath = "youtube_media/" .. mediaType .. "s/" .. videoId .. "." .. fileExt
    
    if videoData and videoData.title then
        NowPlaying.Text = "▶ " .. videoData.title
        NowPlaying.TextColor3 = Theme.Text
    else
        NowPlaying.Text = "▶ Đang tải..."
    end
    
    if not isfile(filePath) then
        local loading = CreateUI("TextLabel", {
            Parent = PlayerArea,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "⏳ Đang tải...",
            TextColor3 = Theme.Text,
            TextSize = 24,
            Font = Enum.Font.GothamBold,
            ZIndex = 10,
        })
        
        local data = RequestVideo(videoId, mediaType)
        loading:Destroy()
        
        if data then
            writefile(filePath, data)
        else
            NowPlaying.Text = "❌ Lỗi tải video!"
            NowPlaying.TextColor3 = Color3.fromRGB(255, 50, 50)
            return
        end
    end
    
    if mediaType == "video" then
        VideoPlayer.Visible = true
        AudioPlayer.Visible = false
        VideoPlayer.Video = GetAsset(filePath)
        VideoPlayer:Play()
        PlayBtn.Text = "⏸"
        isPlaying = true
        FloatingButton.Text = "⏸"
    else
        VideoPlayer.Visible = false
        AudioPlayer.Visible = true
        if soundInstance then soundInstance:Destroy() end
        soundInstance = Instance.new("Sound")
        soundInstance.SoundId = GetAsset(filePath)
        soundInstance.Parent = AudioPlayer
        soundInstance:Play()
        PlayBtn.Text = "⏸"
        isPlaying = true
        FloatingButton.Text = "⏸"
    end
end

-- ===== SEARCH BUTTON =====
SearchBtn.MouseButton1Click:Connect(function()
    local query = SearchInput.Text
    if #query < 2 then 
        NowPlaying.Text = "⚠️ Nhập ít nhất 2 ký tự"
        NowPlaying.TextColor3 = Color3.fromRGB(255, 200, 0)
        return 
    end
    
    NowPlaying.Text = "🔍 Đang tìm: " .. query
    NowPlaying.TextColor3 = Theme.TextDim
    
    local results = SearchYouTube(query)
    if results then
        DisplayResults(results)
        NowPlaying.Text = "✅ Tìm thấy " .. #results .. " kết quả"
        NowPlaying.TextColor3 = Theme.Accent
        task.wait(1.5)
        NowPlaying.Text = "Chọn video để phát"
        NowPlaying.TextColor3 = Theme.TextDim
    else
        NowPlaying.Text = "❌ Không tìm thấy kết quả"
        NowPlaying.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

SearchBtn.TouchTap:Connect(function()
    SearchBtn.MouseButton1Click:Fire()
end)

SearchInput.FocusLost:Connect(function(enter)
    if enter then
        SearchBtn.MouseButton1Click:Fire()
    end
end)

-- ===== MODE SWITCH =====
ModeVideo.MouseButton1Click:Connect(function()
    currentMode = "video"
    ModeVideo.BackgroundColor3 = Theme.Primary
    ModeVideo.TextColor3 = Theme.Text
    ModeAudio.BackgroundTransparency = 1
    ModeAudio.TextColor3 = Theme.TextDim
    VideoPlayer.Visible = true
    AudioPlayer.Visible = false
end)
ModeVideo.TouchTap:Connect(function()
    ModeVideo.MouseButton1Click:Fire()
end)

ModeAudio.MouseButton1Click:Connect(function()
    currentMode = "audio"
    ModeAudio.BackgroundColor3 = Theme.Primary
    ModeAudio.TextColor3 = Theme.Text
    ModeVideo.BackgroundTransparency = 1
    ModeVideo.TextColor3 = Theme.TextDim
    VideoPlayer.Visible = false
    AudioPlayer.Visible = true
end)
ModeAudio.TouchTap:Connect(function()
    ModeAudio.MouseButton1Click:Fire()
end)

-- ===== PLAYBACK CONTROLS =====
PlayBtn.MouseButton1Click:Connect(function()
    if currentVideoId == nil then
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
            if soundInstance then soundInstance:Pause() end
        end
        PlayBtn.Text = "▶"
        isPlaying = false
        FloatingButton.Text = "▶"
    else
        if currentMode == "video" then
            VideoPlayer:Play()
        else
            if soundInstance then soundInstance:Resume() end
        end
        PlayBtn.Text = "⏸"
        isPlaying = true
        FloatingButton.Text = "⏸"
    end
end)
PlayBtn.TouchTap:Connect(function()
    PlayBtn.MouseButton1Click:Fire()
end)

LoopBtn.MouseButton1Click:Connect(function()
    isLooping = not isLooping
    LoopBtn.TextColor3 = isLooping and Theme.Primary or Theme.Text
    if currentMode == "video" then
        VideoPlayer.Looped = isLooping
    else
        if soundInstance then soundInstance.Looped = isLooping end
    end
end)
LoopBtn.TouchTap:Connect(function()
    LoopBtn.MouseButton1Click:Fire()
end)

PrevBtn.MouseButton1Click:Connect(function()
    NowPlaying.Text = "⏮ Quay lại video trước"
    NowPlaying.TextColor3 = Theme.TextDim
end)
PrevBtn.TouchTap:Connect(function()
    PrevBtn.MouseButton1Click:Fire()
end)

NextBtn.MouseButton1Click:Connect(function()
    NowPlaying.Text = "⏭ Video tiếp theo"
    NowPlaying.TextColor3 = Theme.TextDim
end)
NextBtn.TouchTap:Connect(function()
    NextBtn.MouseButton1Click:Fire()
end)

-- ===== TIMELINE UPDATE =====
RunService.RenderStepped:Connect(function()
    if currentMode == "video" and VideoPlayer.Visible and VideoPlayer.IsLoaded then
        if VideoPlayer.TimeLength > 0 then
            local progress = VideoPlayer.TimePosition / VideoPlayer.TimeLength
            TimelineLine.Size = UDim2.new(math.clamp(progress, 0, 1), 0, 1, 0)
        end
    elseif currentMode == "audio" and soundInstance and soundInstance.IsLoaded then
        if soundInstance.TimeLength > 0 then
            local progress = soundInstance.TimePosition / soundInstance.TimeLength
            TimelineLine.Size = UDim2.new(math.clamp(progress, 0, 1), 0, 1, 0)
        end
    end
end)

-- ===== TIMELINE TOUCH =====
Timeline.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position.X - Timeline.AbsolutePosition.X
        local progress = math.clamp(pos / Timeline.AbsoluteSize.X, 0, 1)
        
        if currentMode == "video" and VideoPlayer.Visible and VideoPlayer.IsLoaded then
            VideoPlayer.TimePosition = VideoPlayer.TimeLength * progress
        elseif currentMode == "audio" and soundInstance and soundInstance.IsLoaded then
            soundInstance.TimePosition = soundInstance.TimeLength * progress
        end
    end
end)

-- ===== FLOATING BUTTON TOGGLE =====
local menuOpen = false
FloatingButton.MouseButton1Click:Connect(function()
    if menuOpen then
        HideWindow()
        menuOpen = false
    else
        ShowWindow()
        menuOpen = true
    end
end)

FloatingButton.TouchTap:Connect(function()
    if menuOpen then
        HideWindow()
        menuOpen = false
    else
        ShowWindow()
        menuOpen = true
    end
end)

-- ===== DRAG FLOATING BUTTON =====
local isDragging = false
local dragStartPos = nil
local startButtonPos = nil

FloatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStartPos = input.Position
        startButtonPos = FloatingButton.Position
    end
end)

FloatingButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStartPos
        local newX = startButtonPos.X.Offset + delta.X
        local newY = startButtonPos.Y.Offset + delta.Y
        FloatingButton.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- ===== LOAD DEMO RESULTS =====
task.wait(0.5)
local demoResults = {
    {
        videoId = "dQw4w9WgXcQ",
        title = "Rick Astley - Never Gonna Give You Up",
        channel = "Rick Astley",
        duration = "3:33",
    },
    {
        videoId = "JGwWNGJdvx8",
        title = "Despacito - Luis Fonsi ft. Daddy Yankee",
        channel = "Luis Fonsi",
        duration = "4:41",
    },
    {
        videoId = "fJ9rUzIMcZQ",
        title = "Queen - Bohemian Rhapsody",
        channel = "Queen Official",
        duration = "5:55",
    }
}
DisplayResults(demoResults)

print("🎬 YouTube Pro Player V2.3 - Mobile Fixed!")
print("📱 Hướng dẫn:")
print("  1. 👆 Chạm nút đỏ ▶ để mở menu")
print("  2. 🔍 Nhập từ khóa → Chạm Tìm")
print("  3. 👆 Chạm kết quả để phát")
print("  4. 🔴 Kéo thả nút đỏ để di chuyển")
