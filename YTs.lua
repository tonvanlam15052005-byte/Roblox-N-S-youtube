--[[
    YouTube Pro Player V2.0
    Tích hợp: Video + Audio Player
    Tính năng: Search, Playlist, Queue, Controls, Effects
]]

local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
-- BỎ DÒNG ClipboardService

-- ===== CONFIG =====
local Request = request or (http and http.request) or (syn and syn.request)
local GetAsset = getcustomasset or getsynasset
local Domain = "https://parvus.fun/" -- Có thể thay bằng API khác

-- ===== TẠO FOLDER =====
if not isfolder("youtube_media") then makefolder("youtube_media") end
if not isfolder("youtube_media/videos") then makefolder("youtube_media/videos") end
if not isfolder("youtube_media/audios") then makefolder("youtube_media/audios") end

-- ===== LOAD ASSETS =====
local AssetFolder = InsertService:LoadLocalAsset("rbxassetid://7563729664") -- Video assets
local AudioAssets = InsertService:LoadLocalAsset("rbxassetid://11312132580") -- Audio assets

-- ===== CREATE MAIN UI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YouTubeProPlayer"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

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

local function MakeDraggable(Dragger, Object)
    local dragging, dragStart, startPos
    Dragger.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = Input.Position
            startPos = Object.Position
        end
    end)
    Dragger.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(Input)
        if dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Input.Position - dragStart
            Object.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ===== SEARCH FUNCTION =====
local searchCache = {}
local function SearchYouTube(query)
    if searchCache[query] then return searchCache[query] end
    
    local response = Request({
        Method = "GET",
        Url = Domain .. "yt/search?q=" .. HttpService:UrlEncode(query) .. "&limit=20"
    })
    
    if response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        searchCache[query] = data
        return data
    end
    return nil
end

-- ===== VIDEO/AUDIO FUNCTIONS =====
local function RequestVideo(VideoId, type)
    type = type or "video" -- "video" or "audio"
    local response = Request({
        Method = "POST",
        Url = Domain .. "yt/" .. type .. "?videoId=" .. VideoId,
    })
    if response.StatusCode == 404 then return false end
    return response.Body
end

-- ===== CREATE MAIN WINDOW =====
local MainWindow = CreateUI("Frame", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 800, 0, 600),
    Position = UDim2.new(0.5, -400, 0.5, -300),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})

-- Shadow
CreateUI("ImageLabel", {
    Parent = MainWindow,
    Size = UDim2.new(1, 20, 1, 20),
    Position = UDim2.new(0, -10, 0, -10),
    BackgroundTransparency = 1,
    Image = "rbxassetid://131599993",
    ImageTransparency = 0.8,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(10, 10, 10, 10),
})

-- ===== TITLE BAR =====
local TitleBar = CreateUI("Frame", {
    Parent = MainWindow,
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
})

CreateUI("TextLabel", {
    Parent = TitleBar,
    Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "🎬 YouTube Pro Player",
    TextColor3 = Theme.Text,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
})

-- Close Button
local CloseBtn = CreateUI("TextButton", {
    Parent = TitleBar,
    Size = UDim2.new(0, 40, 1, 0),
    Position = UDim2.new(1, -40, 0, 0),
    BackgroundTransparency = 1,
    Text = "✕",
    TextColor3 = Theme.TextDim,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
})
CloseBtn.MouseButton1Click:Connect(function()
    Tween(MainWindow, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}, 0.3)
    task.wait(0.3)
    MainWindow.Visible = false
end)

MakeDraggable(TitleBar, MainWindow)

-- ===== SEARCH BAR =====
local SearchBar = CreateUI("Frame", {
    Parent = MainWindow,
    Size = UDim2.new(1, 0, 0, 60),
    Position = UDim2.new(0, 0, 0, 40),
    BackgroundColor3 = Theme.Surface2,
    BorderSizePixel = 0,
})

local SearchInput = CreateUI("TextBox", {
    Parent = SearchBar,
    Size = UDim2.new(0.7, -20, 0, 40),
    Position = UDim2.new(0, 15, 0, 10),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    PlaceholderText = "🔍 Tìm kiếm video YouTube...",
    PlaceholderColor3 = Theme.TextDim,
    TextColor3 = Theme.Text,
    TextSize = 14,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
})

local SearchBtn = CreateUI("TextButton", {
    Parent = SearchBar,
    Size = UDim2.new(0, 100, 0, 40),
    Position = UDim2.new(0.7, 10, 0, 10),
    BackgroundColor3 = Theme.Primary,
    BorderSizePixel = 0,
    Text = "Tìm kiếm",
    TextColor3 = Theme.Text,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
})

-- ===== MODE SWITCH =====
local ModeSwitch = CreateUI("Frame", {
    Parent = SearchBar,
    Size = UDim2.new(0, 120, 0, 30),
    Position = UDim2.new(0.7, 120, 0, 15),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
})

local ModeVideo = CreateUI("TextButton", {
    Parent = ModeSwitch,
    Size = UDim2.new(0.5, 0, 1, 0),
    BackgroundColor3 = Theme.Primary,
    BorderSizePixel = 0,
    Text = "🎥 Video",
    TextColor3 = Theme.Text,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
})

local ModeAudio = CreateUI("TextButton", {
    Parent = ModeSwitch,
    Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0.5, 0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Text = "🎵 Audio",
    TextColor3 = Theme.TextDim,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
})

local currentMode = "video" -- "video" or "audio"

-- ===== VIDEO/AUDIO PLAYER AREA =====
local PlayerArea = CreateUI("Frame", {
    Parent = MainWindow,
    Size = UDim2.new(1, 0, 0, 350),
    Position = UDim2.new(0, 0, 0, 100),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
})

-- Video Player (ẩn khi ở chế độ audio)
local VideoPlayer = CreateUI("VideoFrame", {
    Parent = PlayerArea,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    Visible = true,
})

-- Audio Player (hiện khi ở chế độ audio)
local AudioPlayer = CreateUI("Frame", {
    Parent = PlayerArea,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(20, 20, 30),
    Visible = false,
})

-- Audio Visualizer
CreateUI("ImageLabel", {
    Parent = AudioPlayer,
    Size = UDim2.new(0.3, 0, 0.8, 0),
    Position = UDim2.new(0.35, 0, 0.1, 0),
    BackgroundTransparency = 1,
    Image = "rbxassetid://6026666994",
    ImageColor3 = Theme.Primary,
})

CreateUI("TextLabel", {
    Parent = AudioPlayer,
    Size = UDim2.new(0.6, 0, 0, 30),
    Position = UDim2.new(0.2, 0, 0.9, 0),
    BackgroundTransparency = 1,
    Text = "🎵 Đang phát Audio...",
    TextColor3 = Theme.TextDim,
    TextSize = 14,
    Font = Enum.Font.Gotham,
    TextScaled = true,
})

-- ===== CONTROLS =====
local Controls = CreateUI("Frame", {
    Parent = MainWindow,
    Size = UDim2.new(1, 0, 0, 50),
    Position = UDim2.new(0, 0, 0, 450),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
})

-- Timeline
local Timeline = CreateUI("Frame", {
    Parent = MainWindow,
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 440),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
})

local TimelineLine = CreateUI("Frame", {
    Parent = Timeline,
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Theme.Primary,
    BorderSizePixel = 0,
})

local TimelineHover = CreateUI("Frame", {
    Parent = Timeline,
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    Visible = false,
})

-- Control Buttons
local function CreateControlButton(parent, pos, text, image)
    local btn = CreateUI("TextButton", {
        Parent = parent,
        Size = UDim2.new(0, 40, 0, 40),
        Position = pos,
        BackgroundTransparency = 1,
        Text = text or "",
        TextColor3 = Theme.Text,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
    })
    if image then
        btn.Image = image
        btn.ImageColor3 = Theme.Text
        btn.BackgroundTransparency = 1
    end
    return btn
end

local PlayBtn = CreateControlButton(Controls, UDim2.new(0.5, -60, 0, 5), "▶")
local PrevBtn = CreateControlButton(Controls, UDim2.new(0.5, -110, 0, 5), "⏮")
local NextBtn = CreateControlButton(Controls, UDim2.new(0.5, -10, 0, 5), "⏭")
local LoopBtn = CreateControlButton(Controls, UDim2.new(0.5, 40, 0, 5), "🔁")
local VolBtn = CreateControlButton(Controls, UDim2.new(0.9, -40, 0, 5), "🔊")

local isPlaying = false
local isLooping = false
local currentVideoId = nil
local queue = {}
local currentQueueIndex = 1

-- ===== PLAYLIST / RESULTS =====
local ResultsArea = CreateUI("ScrollingFrame", {
    Parent = MainWindow,
    Size = UDim2.new(1, 0, 0, 100),
    Position = UDim2.new(0, 0, 0, 500),
    BackgroundColor3 = Theme.Surface2,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Theme.Primary,
    Visible = true,
})

-- ===== SEARCH LOGIC =====
local function DisplayResults(results)
    -- Clear old results
    for _, child in pairs(ResultsArea:GetChildren()) do
        if child:IsA("ImageButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    if not results or #results == 0 then
        local empty = CreateUI("TextLabel", {
            Parent = ResultsArea,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "Không tìm thấy video nào",
            TextColor3 = Theme.TextDim,
            TextSize = 16,
            Font = Enum.Font.Gotham,
        })
        return
    end
    
    local y = 0
    for i, video in ipairs(results) do
        local item = CreateUI("ImageButton", {
            Parent = ResultsArea,
            Size = UDim2.new(1, -20, 0, 70),
            Position = UDim2.new(0, 10, 0, y),
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel = 0,
            Image = video.thumbnail or "",
            ScaleType = Enum.ScaleType.Fit,
        })
        
        -- Title
        CreateUI("TextLabel", {
            Parent = item,
            Size = UDim2.new(0.7, -20, 0.5, 0),
            Position = UDim2.new(0.3, 10, 0, 5),
            BackgroundTransparency = 1,
            Text = video.title or "Unknown",
            TextColor3 = Theme.Text,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
        })
        
        -- Channel
        CreateUI("TextLabel", {
            Parent = item,
            Size = UDim2.new(0.7, -20, 0.3, 0),
            Position = UDim2.new(0.3, 10, 0, 35),
            BackgroundTransparency = 1,
            Text = video.channel or "Unknown",
            TextColor3 = Theme.TextDim,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        -- Duration
        CreateUI("TextLabel", {
            Parent = item,
            Size = UDim2.new(0.2, 0, 0.3, 0),
            Position = UDim2.new(0.8, 0, 0.6, 0),
            BackgroundTransparency = 1,
            Text = video.duration or "--:--",
            TextColor3 = Theme.TextDim,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Right,
        })
        
        item.MouseButton1Click:Connect(function()
            PlayVideo(video.videoId, video)
        end)
        
        y = y + 75
    end
    
    ResultsArea.CanvasSize = UDim2.new(0, 0, 0, y)
end

-- ===== PLAY FUNCTION =====
local soundInstance = nil
local function PlayVideo(videoId, videoData)
    if not videoId then return end
    
    currentVideoId = videoId
    local mediaType = currentMode
    
    -- Load media
    local fileExt = mediaType == "video" and "webm" or "mp3"
    local filePath = "youtube_media/" .. mediaType .. "s/" .. videoId .. "." .. fileExt
    
    if not isfile(filePath) then
        -- Show loading
        local status = CreateUI("TextLabel", {
            Parent = PlayerArea,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "⏳ Đang tải...",
            TextColor3 = Theme.Text,
            TextSize = 24,
            Font = Enum.Font.GothamBold,
        })
        
        local data = RequestVideo(videoId, mediaType)
        status:Destroy()
        
        if data then
            writefile(filePath, data)
        else
            -- Show error
            local err = CreateUI("TextLabel", {
                Parent = PlayerArea,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "❌ Lỗi tải video",
                TextColor3 = Color3.fromRGB(255, 50, 50),
                TextSize = 20,
                Font = Enum.Font.GothamBold,
            })
            task.wait(2)
            err:Destroy()
            return
        end
    end
    
    -- Play
    if mediaType == "video" then
        VideoPlayer.Visible = true
        AudioPlayer.Visible = false
        VideoPlayer.Video = GetAsset(filePath)
        VideoPlayer:Play()
        PlayBtn.Text = "⏸"
        isPlaying = true
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
    end
    
    -- Update title
    if videoData then
        -- Xóa title cũ
        for _, child in pairs(MainWindow:GetChildren()) do
            if child:IsA("TextLabel") and child.Name == "NowPlaying" then
                child:Destroy()
            end
        end
        
        local titleLabel = CreateUI("TextLabel", {
            Parent = MainWindow,
            Name = "NowPlaying",
            Size = UDim2.new(0.8, 0, 0, 25),
            Position = UDim2.new(0.1, 0, 0, 425),
            BackgroundTransparency = 1,
            Text = "▶ " .. (videoData.title or ""),
            TextColor3 = Theme.Text,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextTruncate = Enum.TextTruncate.AtEnd,
        })
    end
end

-- ===== SEARCH BUTTON =====
SearchBtn.MouseButton1Click:Connect(function()
    local query = SearchInput.Text
    if #query < 2 then return end
    
    local results = SearchYouTube(query)
    if results then
        DisplayResults(results)
    end
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

ModeAudio.MouseButton1Click:Connect(function()
    currentMode = "audio"
    ModeAudio.BackgroundColor3 = Theme.Primary
    ModeAudio.TextColor3 = Theme.Text
    ModeVideo.BackgroundTransparency = 1
    ModeVideo.TextColor3 = Theme.TextDim
    VideoPlayer.Visible = false
    AudioPlayer.Visible = true
end)

-- ===== PLAYBACK CONTROLS =====
PlayBtn.MouseButton1Click:Connect(function()
    if currentVideoId == nil then
        -- Nếu chưa có video, load demo
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
    else
        if currentMode == "video" then
            VideoPlayer:Play()
        else
            if soundInstance then soundInstance:Resume() end
        end
        PlayBtn.Text = "⏸"
        isPlaying = true
    end
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

-- ===== TIMELINE CLICK =====
Timeline.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local pos = input.Position.X - Timeline.AbsolutePosition.X
        local progress = math.clamp(pos / Timeline.AbsoluteSize.X, 0, 1)
        
        if currentMode == "video" and VideoPlayer.Visible and VideoPlayer.IsLoaded then
            VideoPlayer.TimePosition = VideoPlayer.TimeLength * progress
        elseif currentMode == "audio" and soundInstance and soundInstance.IsLoaded then
            soundInstance.TimePosition = soundInstance.TimeLength * progress
        end
    end
end)

-- ===== VOLUME =====
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        local volume = 0.5
        if currentMode == "video" and VideoPlayer.Visible then
            volume = VideoPlayer.Volume
        elseif currentMode == "audio" and soundInstance then
            volume = soundInstance.Volume
        end
        volume = math.clamp(volume + (input.Position.Z > 0 and 0.05 or -0.05), 0, 1)
        if currentMode == "video" and VideoPlayer.Visible then
            VideoPlayer.Volume = volume
        elseif currentMode == "audio" and soundInstance then
            soundInstance.Volume = volume
        end
    end
end)

-- ===== KEYBOARD SHORTCUTS =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        PlayBtn.MouseButton1Click:Fire()
    end
end)

-- ===== SHOW WINDOW =====
Tween(MainWindow, {BackgroundTransparency = 0, Size = UDim2.new(0, 800, 0, 600)}, 0.5)

-- ===== AUTO SHOW DEMO =====
task.wait(0.5)
local demoResults = {
    {
        videoId = "dQw4w9WgXcQ",
        title = "Rick Astley - Never Gonna Give You Up",
        channel = "Rick Astley",
        duration = "3:33",
        thumbnail = ""
    }
}
DisplayResults(demoResults)

print("🎬 YouTube Pro Player V2.0 đã sẵn sàng!")
print("📌 Tính năng:")
print("  - 🔍 Tìm kiếm video YouTube")
print("  - 🎥 Xem video / 🎵 Nghe audio")
print("  - ⏯️ Điều khiển Play/Pause")
print("  - 🔁 Loop video")
print("  - ⌨️ Phím Space để Play/Pause")
print("  - 🖱️ Scroll để điều chỉnh âm lượng")
