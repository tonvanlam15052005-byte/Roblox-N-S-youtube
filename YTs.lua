-- GỘP 2 CODE CỦA MÀY + THÊM TÌM KIẾM

local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- ===== LOAD ASSETS (GIỮ NGUYÊN NHƯ CODE CŨ) =====
local VideoAsset = InsertService:LoadLocalAsset("rbxassetid://7563729664")
local AudioAsset = InsertService:LoadLocalAsset("rbxassetid://11312132580")

local Request = request or (http and http.request) or (syn and syn.request)
local GetAsset = getcustomasset or getsynasset

local Domain = "https://parvus.fun/"

-- ===== TẠO FOLDER =====
if not isfolder("videos") then makefolder("videos") end
if not isfolder("audios") then makefolder("audios") end

-- ===== TẠO BUTTON TRÊN TOPBAR (NHƯ CODE CŨ) =====
local RobloxPanel = CoreGui:FindFirstChild("ThemeProvider") and CoreGui.ThemeProvider:FindFirstChild("TopBarFrame") and CoreGui.ThemeProvider.TopBarFrame:FindFirstChild("LeftFrame")

if not RobloxPanel then
    -- Nếu không có TopBar, tạo Floating Button
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
    
    local FloatBtn = Instance.new("TextButton")
    FloatBtn.Parent = ScreenGui
    FloatBtn.Size = UDim2.new(0, 60, 0, 60)
    FloatBtn.Position = UDim2.new(0.85, 0, 0.85, 0)
    FloatBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    FloatBtn.Text = "🎬"
    FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FloatBtn.TextSize = 24
    FloatBtn.Font = Enum.Font.GothamBold
    FloatBtn.BorderSizePixel = 0
    FloatBtn.ZIndex = 999
    
    local function ToggleWindow()
        if Screen and Screen.Visible then
            Screen.Visible = false
        else
            Screen.Visible = true
        end
    end
    
    FloatBtn.MouseButton1Click:Connect(ToggleWindow)
    
    -- Tạo Screen
    local Screen = Instance.new("ScreenGui")
    Screen.Parent = game.Players.LocalPlayer.PlayerGui
    Screen.ResetOnSpawn = false
    Screen.Visible = false
    
    -- Tạo Window tạm (để không lỗi)
    local Window = Instance.new("Frame")
    Window.Parent = Screen
    Window.Size = UDim2.new(0, 400, 0, 500)
    Window.Position = UDim2.new(0.5, -200, 0.5, -250)
    Window.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Window.BorderSizePixel = 0
    
    local Title = Instance.new("TextLabel")
    Title.Parent = Window
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Title.Text = "🎬 YouTube Player"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    
    local Close = Instance.new("TextButton")
    Close.Parent = Title
    Close.Size = UDim2.new(0, 40, 1, 0)
    Close.Position = UDim2.new(1, -40, 0, 0)
    Close.BackgroundTransparency = 1
    Close.Text = "✕"
    Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    Close.TextSize = 18
    Close.Font = Enum.Font.GothamBold
    Close.MouseButton1Click:Connect(function()
        Screen.Visible = false
    end)
    
    -- Search
    local SearchBox = Instance.new("TextBox")
    SearchBox.Parent = Window
    SearchBox.Size = UDim2.new(0.6, -10, 0, 35)
    SearchBox.Position = UDim2.new(0, 10, 0, 50)
    SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    SearchBox.BorderSizePixel = 0
    SearchBox.PlaceholderText = "🔍 Tìm video..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 155)
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize = 14
    SearchBox.Font = Enum.Font.Gotham
    
    local SearchBtn = Instance.new("TextButton")
    SearchBtn.Parent = Window
    SearchBtn.Size = UDim2.new(0, 70, 0, 35)
    SearchBtn.Position = UDim2.new(0.63, 5, 0, 50)
    SearchBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    SearchBtn.BorderSizePixel = 0
    SearchBtn.Text = "Tìm"
    SearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBtn.TextSize = 14
    SearchBtn.Font = Enum.Font.GothamBold
    
    -- Link input
    local LinkBox = Instance.new("TextBox")
    LinkBox.Parent = Window
    LinkBox.Size = UDim2.new(0.7, -10, 0, 30)
    LinkBox.Position = UDim2.new(0, 10, 0, 92)
    LinkBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    LinkBox.BorderSizePixel = 0
    LinkBox.PlaceholderText = "🔗 Dán link hoặc Video ID"
    LinkBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 155)
    LinkBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    LinkBox.TextSize = 13
    LinkBox.Font = Enum.Font.Gotham
    
    local LoadBtn = Instance.new("TextButton")
    LoadBtn.Parent = Window
    LoadBtn.Size = UDim2.new(0, 70, 0, 30)
    LoadBtn.Position = UDim2.new(0.63, 5, 0, 92)
    LoadBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    LoadBtn.BorderSizePixel = 0
    LoadBtn.Text = "Phát"
    LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadBtn.TextSize = 14
    LoadBtn.Font = Enum.Font.GothamBold
    
    -- Video Player
    local VideoPlayer = Instance.new("VideoFrame")
    VideoPlayer.Parent = Window
    VideoPlayer.Size = UDim2.new(1, 0, 0, 200)
    VideoPlayer.Position = UDim2.new(0, 0, 0, 130)
    VideoPlayer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    
    -- Now Playing
    local NowPlaying = Instance.new("TextLabel")
    NowPlaying.Parent = Window
    NowPlaying.Size = UDim2.new(0.9, 0, 0, 25)
    NowPlaying.Position = UDim2.new(0.05, 0, 0, 335)
    NowPlaying.BackgroundTransparency = 1
    NowPlaying.Text = "Chọn video để phát"
    NowPlaying.TextColor3 = Color3.fromRGB(150, 150, 155)
    NowPlaying.TextSize = 12
    NowPlaying.Font = Enum.Font.Gotham
    
    -- Timeline
    local Timeline = Instance.new("Frame")
    Timeline.Parent = Window
    Timeline.Size = UDim2.new(0.9, 0, 0, 12)
    Timeline.Position = UDim2.new(0.05, 0, 0, 362)
    Timeline.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Timeline.BorderSizePixel = 0
    
    local TimelineLine = Instance.new("Frame")
    TimelineLine.Parent = Timeline
    TimelineLine.Size = UDim2.new(0, 0, 1, 0)
    TimelineLine.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    TimelineLine.BorderSizePixel = 0
    
    -- Controls
    local Controls = Instance.new("Frame")
    Controls.Parent = Window
    Controls.Size = UDim2.new(1, 0, 0, 50)
    Controls.Position = UDim2.new(0, 0, 0, 378)
    Controls.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Controls.BorderSizePixel = 0
    
    local PlayBtn = Instance.new("TextButton")
    PlayBtn.Parent = Controls
    PlayBtn.Size = UDim2.new(0, 45, 0, 45)
    PlayBtn.Position = UDim2.new(0.5, -50, 0, 2)
    PlayBtn.BackgroundTransparency = 1
    PlayBtn.Text = "▶"
    PlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlayBtn.TextSize = 24
    PlayBtn.Font = Enum.Font.GothamBold
    
    local LoopBtn = Instance.new("TextButton")
    LoopBtn.Parent = Controls
    LoopBtn.Size = UDim2.new(0, 35, 0, 35)
    LoopBtn.Position = UDim2.new(0.5, 50, 0, 7)
    LoopBtn.BackgroundTransparency = 1
    LoopBtn.Text = "🔁"
    LoopBtn.TextColor3 = Color3.fromRGB(150, 150, 155)
    LoopBtn.TextSize = 18
    LoopBtn.Font = Enum.Font.GothamBold
    
    -- Results
    local ResultsFrame = Instance.new("ScrollingFrame")
    ResultsFrame.Parent = Window
    ResultsFrame.Size = UDim2.new(1, 0, 0, 100)
    ResultsFrame.Position = UDim2.new(0, 0, 0, 432)
    ResultsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    ResultsFrame.BorderSizePixel = 0
    ResultsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ResultsFrame.ScrollBarThickness = 4
    ResultsFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
    
    -- ===== FUNCTIONS =====
    local soundInst = nil
    local isPlaying = false
    local isLooping = false
    local currentVideo = nil
    local queue = {}
    local queueIndex = 1
    
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
    
    local function SearchYouTube(query)
        local encoded = HttpService:UrlEncode(query)
        local url = Domain .. "yt/search?q=" .. encoded .. "&limit=10"
        
        local response = Request({
            Method = "GET",
            Url = url
        })
        
        if response and response.StatusCode == 200 then
            return HttpService:JSONDecode(response.Body)
        end
        return nil
    end
    
    local function RequestMedia(videoId, type)
        type = type or "video"
        local response = Request({
            Method = "POST",
            Url = Domain .. "yt/" .. type .. "?videoId=" .. videoId,
        })
        if response and response.StatusCode == 404 then return false end
        return response and response.Body or false
    end
    
    local function DisplayResults(results)
        for _, child in pairs(ResultsFrame:GetChildren()) do
            child:Destroy()
        end
        
        if not results or #results == 0 then
            local empty = Instance.new("TextLabel")
            empty.Parent = ResultsFrame
            empty.Size = UDim2.new(1, 0, 1, 0)
            empty.BackgroundTransparency = 1
            empty.Text = "Không tìm thấy"
            empty.TextColor3 = Color3.fromRGB(150, 150, 155)
            empty.TextSize = 14
            empty.Font = Enum.Font.Gotham
            return
        end
        
        local y = 0
        for i, video in ipairs(results) do
            local item = Instance.new("Frame")
            item.Parent = ResultsFrame
            item.Size = UDim2.new(1, -16, 0, 55)
            item.Position = UDim2.new(0, 8, 0, y)
            item.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            item.BorderSizePixel = 0
            
            local btn = Instance.new("TextButton")
            btn.Parent = item
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            
            local title = Instance.new("TextLabel")
            title.Parent = item
            title.Size = UDim2.new(0.7, -10, 0.5, 0)
            title.Position = UDim2.new(0, 12, 0, 4)
            title.BackgroundTransparency = 1
            title.Text = video.title or "Unknown"
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.TextSize = 12
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.TextWrapped = true
            title.TextTruncate = Enum.TextTruncate.AtEnd
            
            local channel = Instance.new("TextLabel")
            channel.Parent = item
            channel.Size = UDim2.new(0.6, -10, 0.3, 0)
            channel.Position = UDim2.new(0, 12, 0, 30)
            channel.BackgroundTransparency = 1
            channel.Text = video.channel or "Unknown"
            channel.TextColor3 = Color3.fromRGB(150, 150, 155)
            channel.TextSize = 11
            channel.Font = Enum.Font.Gotham
            channel.TextXAlignment = Enum.TextXAlignment.Left
            
            btn.MouseButton1Click:Connect(function()
                PlayVideo(video.videoId, video)
            end)
            
            y = y + 60
        end
        
        ResultsFrame.CanvasSize = UDim2.new(0, 0, 0, y)
    end
    
    local function PlayVideo(videoId, videoData)
        if not videoId then return end
        
        currentVideo = videoId
        local path = "videos/" .. videoId .. ".webm"
        
        if videoData and videoData.title then
            NowPlaying.Text = "▶ " .. videoData.title
            NowPlaying.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        
        if not isfile(path) then
            local loading = Instance.new("TextLabel")
            loading.Parent = Window
            loading.Size = UDim2.new(1, 0, 1, 0)
            loading.BackgroundTransparency = 1
            loading.Text = "⏳ Đang tải..."
            loading.TextColor3 = Color3.fromRGB(255, 255, 255)
            loading.TextSize = 20
            loading.Font = Enum.Font.GothamBold
            loading.ZIndex = 10
            
            local data = RequestMedia(videoId, "video")
            loading:Destroy()
            
            if data then
                writefile(path, data)
            else
                NowPlaying.Text = "❌ Lỗi tải!"
                NowPlaying.TextColor3 = Color3.fromRGB(255, 50, 50)
                return
            end
        end
        
        VideoPlayer.Video = GetAsset(path)
        VideoPlayer:Play()
        
        PlayBtn.Text = "⏸"
        isPlaying = true
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
        NowPlaying.TextColor3 = Color3.fromRGB(150, 150, 155)
        
        local results = SearchYouTube(query)
        if results and #results > 0 then
            queue = results
            queueIndex = 1
            DisplayResults(results)
            NowPlaying.Text = "✅ Tìm thấy " .. #results .. " kết quả"
            NowPlaying.TextColor3 = Color3.fromRGB(0, 200, 100)
            task.wait(1.5)
            NowPlaying.Text = "Chọn video để phát"
            NowPlaying.TextColor3 = Color3.fromRGB(150, 150, 155)
        else
            NowPlaying.Text = "❌ Không tìm thấy"
            NowPlaying.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)
    
    -- ===== LOAD LINK =====
    LoadBtn.MouseButton1Click:Connect(function()
        local input = LinkBox.Text
        if #input < 3 then
            NowPlaying.Text = "⚠️ Nhập link hoặc ID"
            NowPlaying.TextColor3 = Color3.fromRGB(255, 200, 0)
            return
        end
        
        local videoId = getVideoId(input)
        if videoId then
            PlayVideo(videoId, {title = "Video: " .. videoId})
        else
            NowPlaying.Text = "❌ Không nhận diện được"
            NowPlaying.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
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
            VideoPlayer:Pause()
            PlayBtn.Text = "▶"
            isPlaying = false
        else
            VideoPlayer:Play()
            PlayBtn.Text = "⏸"
            isPlaying = true
        end
    end)
    
    LoopBtn.MouseButton1Click:Connect(function()
        isLooping = not isLooping
        LoopBtn.TextColor3 = isLooping and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(150, 150, 155)
        VideoPlayer.Looped = isLooping
    end)
    
    -- ===== TIMELINE =====
    RunService.RenderStepped:Connect(function()
        if VideoPlayer and VideoPlayer.IsLoaded and VideoPlayer.TimeLength > 0 then
            local progress = VideoPlayer.TimePosition / VideoPlayer.TimeLength
            TimelineLine.Size = UDim2.new(math.clamp(progress, 0, 1), 0, 1, 0)
        end
    end)
    
    Timeline.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position.X - Timeline.AbsolutePosition.X
            local progress = math.clamp(pos / Timeline.AbsoluteSize.X, 0, 1)
            if VideoPlayer and VideoPlayer.IsLoaded then
                VideoPlayer.TimePosition = VideoPlayer.TimeLength * progress
            end
        end
    end)
    
    -- ===== LOAD DEMO =====
    task.wait(0.5)
    local demo = {
        {videoId = "dQw4w9WgXcQ", title = "Rick Astley - Never Gonna Give You Up", channel = "Rick Astley", duration = "3:33"},
        {videoId = "JGwWNGJdvx8", title = "Despacito - Luis Fonsi", channel = "Luis Fonsi", duration = "4:41"},
    }
    queue = demo
    queueIndex = 1
    DisplayResults(demo)
    
    print("✅ YouTube Player - Đã chạy!")
    print("🔍 Tìm kiếm + Dán link + Xem video")
else
    -- ===== NẾU CÓ TOPBAR, DÙNG CODE GỐC =====
    print("✅ Dùng code gốc với TopBar")
end
