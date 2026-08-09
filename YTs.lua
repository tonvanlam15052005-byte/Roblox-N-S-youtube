-- GỘP VIDEO + AUDIO PLAYER + TÌM KIẾM

local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Load assets từ code gốc
local VideoAsset = InsertService:LoadLocalAsset("rbxassetid://7563729664")
local AudioAsset = InsertService:LoadLocalAsset("rbxassetid://11312132580")

local Request = request or (http and http.request) or (syn and syn.request)
local GetAsset = getcustomasset or getsynasset
local Domain = "https://parvus.fun/"

-- Tạo folder
if not isfolder("videos") then makefolder("videos") end
if not isfolder("audios") then makefolder("audios") end

-- Lấy panel trên TopBar (giữ nguyên cách của bạn)
local RobloxPanel = CoreGui.ThemeProvider.TopBarFrame.LeftFrame

-- Tạo nút Video (từ code cũ)
local VideoButton = VideoAsset.VideoButton:Clone()
VideoButton.Name = HttpService:GenerateGUID(false)
VideoButton.Parent = RobloxPanel

-- Tạo nút Audio (từ code cũ)
local AudioButton = AudioAsset.AudioPlayer:Clone()
AudioButton.Name = HttpService:GenerateGUID(false)
AudioButton.Parent = RobloxPanel

-- Lấy screen video và audio
local VideoScreen = VideoAsset.Videoplayer:Clone()
VideoScreen.Name = HttpService:GenerateGUID(false)
VideoScreen.Parent = CoreGui

local AudioScreen = AudioAsset.Screen:Clone()
AudioScreen.Name = HttpService:GenerateGUID(false)
AudioScreen.Parent = CoreGui

-- Ẩn audio screen ban đầu
AudioScreen.Visible = false

-- Lấy các thành phần
local VideoWindow = VideoScreen.Window
local AudioWindow = AudioScreen.Window

local VideoControl = VideoWindow.ControlPanel
local AudioControl = AudioWindow.ControlPanel

-- ===== THÊM TÌM KIẾM VÀO VIDEO =====
-- Tạo search frame trong video window
local SearchFrame = Instance.new("Frame")
SearchFrame.Parent = VideoWindow
SearchFrame.Size = UDim2.new(1, 0, 0, 50)
SearchFrame.Position = UDim2.new(0, 0, 0, 40)
SearchFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
SearchFrame.BackgroundTransparency = 0.5
SearchFrame.BorderSizePixel = 0

local SearchBox = Instance.new("TextBox")
SearchBox.Parent = SearchFrame
SearchBox.Size = UDim2.new(0.6, -10, 0, 32)
SearchBox.Position = UDim2.new(0, 10, 0, 9)
SearchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "🔍 Tìm video..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 155)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.TextSize = 13
SearchBox.Font = Enum.Font.Gotham
SearchBox.ClearTextOnFocus = false

local SearchBtn = Instance.new("TextButton")
SearchBtn.Parent = SearchFrame
SearchBtn.Size = UDim2.new(0, 65, 0, 32)
SearchBtn.Position = UDim2.new(0.63, 5, 0, 9)
SearchBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
SearchBtn.BorderSizePixel = 0
SearchBtn.Text = "Tìm"
SearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBtn.TextSize = 13
SearchBtn.Font = Enum.Font.GothamBold

-- Link input
local LinkBox = Instance.new("TextBox")
LinkBox.Parent = SearchFrame
LinkBox.Size = UDim2.new(0.6, -10, 0, 28)
LinkBox.Position = UDim2.new(0, 10, 0, 46)
LinkBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
LinkBox.BorderSizePixel = 0
LinkBox.PlaceholderText = "🔗 Dán link hoặc Video ID"
LinkBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 155)
LinkBox.TextColor3 = Color3.fromRGB(255, 255, 255)
LinkBox.TextSize = 12
LinkBox.Font = Enum.Font.Gotham
LinkBox.ClearTextOnFocus = false

local LoadBtn = Instance.new("TextButton")
LoadBtn.Parent = SearchFrame
LoadBtn.Size = UDim2.new(0, 65, 0, 28)
LoadBtn.Position = UDim2.new(0.63, 5, 0, 46)
LoadBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
LoadBtn.BorderSizePixel = 0
LoadBtn.Text = "Phát"
LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadBtn.TextSize = 13
LoadBtn.Font = Enum.Font.GothamBold

-- Dịch chuyển video player xuống
VideoWindow.Video.Position = UDim2.new(0, 0, 0, 90)

-- ==== FUNCTIONS ====
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
    local response = Request({Method = "GET", Url = url})
    if response and response.StatusCode == 200 then
        return HttpService:JSONDecode(response.Body)
    end
    return nil
end

local function RequestVideo(videoId)
    local response = Request({Method = "POST", Url = Domain .. "yt/video?videoId=" .. videoId})
    if response and response.StatusCode == 404 then return false end
    return response and response.Body or false
end

-- ==== SEARCH =====
SearchBtn.MouseButton1Click:Connect(function()
    local query = SearchBox.Text
    if #query < 2 then
        VideoWindow.Title.Text = "⚠️ Nhập ít nhất 2 ký tự"
        return
    end
    
    VideoWindow.Title.Text = "🔍 Đang tìm: " .. query
    local results = SearchYouTube(query)
    
    if results and #results > 0 then
        -- Hiển thị kết quả đầu tiên lên title
        VideoWindow.Title.Text = "✅ " .. results[1].title
        -- Tự động phát video đầu tiên
        local videoId = results[1].videoId
        local path = "videos/" .. videoId .. ".webm"
        
        if not isfile(path) then
            VideoWindow.Title.Text = "⏳ Đang tải..."
            local data = RequestVideo(videoId)
            if data then
                writefile(path, data)
            else
                VideoWindow.Title.Text = "❌ Lỗi tải!"
                return
            end
        end
        
        VideoWindow.Video.Video = GetAsset(path)
        VideoWindow.Title.Text = "▶ " .. results[1].title
        VideoWindow.Video:Play()
        VideoControl.Play.ImageRectOffset = Vector2.new(804, 124)
    else
        VideoWindow.Title.Text = "❌ Không tìm thấy"
    end
end)

-- ==== LOAD LINK =====
LoadBtn.MouseButton1Click:Connect(function()
    local input = LinkBox.Text
    if #input < 3 then
        VideoWindow.Title.Text = "⚠️ Nhập link hoặc ID"
        return
    end
    
    local videoId = getVideoId(input)
    if not videoId then
        VideoWindow.Title.Text = "❌ Không nhận diện được"
        return
    end
    
    local path = "videos/" .. videoId .. ".webm"
    if not isfile(path) then
        VideoWindow.Title.Text = "⏳ Đang tải..."
        local data = RequestVideo(videoId)
        if data then
            writefile(path, data)
        else
            VideoWindow.Title.Text = "❌ Lỗi tải!"
            return
        end
    end
    
    VideoWindow.Video.Video = GetAsset(path)
    VideoWindow.Title.Text = "▶ " .. videoId
    VideoWindow.Video:Play()
    VideoControl.Play.ImageRectOffset = Vector2.new(804, 124)
end)

-- Enter để search
SearchBox.FocusLost:Connect(function(enter)
    if enter then SearchBtn.MouseButton1Click:Fire() end
end)

LinkBox.FocusLost:Connect(function(enter)
    if enter then LoadBtn.MouseButton1Click:Fire() end
end)

-- ===== TOGGLE VIDEO/AUDIO =====
VideoButton.Icon.MouseButton1Click:Connect(function()
    VideoScreen.Visible = not VideoScreen.Visible
    if VideoScreen.Visible then
        AudioScreen.Visible = false
    end
end)

AudioButton.Icon.MouseButton1Click:Connect(function()
    AudioScreen.Visible = not AudioScreen.Visible
    if AudioScreen.Visible then
        VideoScreen.Visible = false
    end
end)

-- ===== GIỮ NGUYÊN CÁC CHỨC NĂNG CŨ =====
-- Video controls (giữ nguyên từ code cũ)
VideoControl.Play.MouseButton1Click:Connect(function()
    local playing = VideoWindow.Video.IsPlaying
    if playing then
        VideoWindow.Video:Pause()
        VideoControl.Play.ImageRectOffset = Vector2.new(764, 244)
    else
        VideoWindow.Video:Play()
        VideoControl.Play.ImageRectOffset = Vector2.new(804, 124)
    end
end)

VideoWindow.Video.Loaded:Connect(function()
    local len = VideoWindow.Video.TimeLength
    VideoWindow.Playback.Length.Text = string.format("%02i:%02i:%02i", len/60^2, len/60%60, len%60)
end)

VideoWindow.Video.Ended:Connect(function()
    VideoControl.Play.ImageRectOffset = Vector2.new(764, 244)
    VideoWindow.Video.TimePosition = 0
end)

-- Audio controls (giữ nguyên từ code cũ)
AudioControl.Play.MouseButton1Click:Connect(function()
    local audio = AudioWindow.Sound
    if audio.IsPlaying then
        audio:Pause()
        AudioControl.Play.Image = "rbxassetid://6026663699"
    else
        audio:Resume()
        AudioControl.Play.Image = "rbxassetid://6026663719"
    end
end)

AudioControl.Repeat.MouseButton1Click:Connect(function()
    local audio = AudioWindow.Sound
    audio.Looped = not audio.Looped
    AudioControl.Repeat.Image = audio.Looped and "rbxassetid://6026666994" or "rbxassetid://6026666998"
end)

AudioWindow.Sound.Loaded:Connect(function()
    local len = AudioWindow.Sound.TimeLength
    AudioWindow.Playback.Length.Text = string.format("%02i:%02i:%02i", len/60^2, len/60%60, len%60)
end)

-- Timeline update
RunService.RenderStepped:Connect(function()
    -- Video timeline
    if VideoWindow.Video.IsLoaded and VideoWindow.Video.TimeLength > 0 then
        local progress = VideoWindow.Video.TimePosition / VideoWindow.Video.TimeLength
        VideoWindow.Playback.Line.Size = UDim2.new(progress, 0, 1, 0)
        local pos = VideoWindow.Video.TimePosition
        VideoWindow.Playback.Time.Text = string.format("%02i:%02i:%02i", pos/60^2, pos/60%60, pos%60)
    end
    
    -- Audio timeline
    if AudioWindow.Sound.IsLoaded and AudioWindow.Sound.TimeLength > 0 then
        local progress = AudioWindow.Sound.TimePosition / AudioWindow.Sound.TimeLength
        AudioWindow.Playback.Line.Size = UDim2.new(progress, 0, 1, 0)
        local pos = AudioWindow.Sound.TimePosition
        AudioWindow.Playback.Time.Text = string.format("%02i:%02i:%02i", pos/60^2, pos/60%60, pos%60)
    end
end)

print("✅ YouTube Player đã sẵn sàng!")
print("📌 2 nút trên thanh công cụ: Video và Audio")
print("📌 Có tìm kiếm và dán link")
