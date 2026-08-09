-- ==========================================================
-- AUDIOPLAYER NÂNG CAO
-- Tích hợp: Tìm kiếm, Queue, Phím tắt, Lịch sử, Volume
-- Dựa trên script của AlexR32
-- ==========================================================

local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local AssetFolder = InsertService:LoadLocalAsset("rbxassetid://11312132580")
local Request = request or (http and http.request) or (syn and syn.request)
local GetAsset = getcustomasset or getsynasset

local RobloxPanel = CoreGui.ThemeProvider.TopBarFrame.LeftFrame
local PanelButton = AssetFolder.AudioPlayer:Clone()
local Screen = AssetFolder.Screen:Clone()

PanelButton.Name = HttpService:GenerateGUID(false)
PanelButton.Parent = RobloxPanel

Screen.Name = HttpService:GenerateGUID(false)
Screen.Parent = CoreGui

local Window = Screen.Window
local Audio = Window.Sound
local Title = Window.Title
local Playback = Window.Playback
local ControlPanel = Window.ControlPanel

-- ==========================================================
-- BIẾN TOÀN CỤC
-- ==========================================================
local VSActive, PSActive = false, false
local Domain = "https://parvus.fun/"
local Playing = false
local Queue = {}
local QueueIndex = 1
local History = {}
local HistoryFile = "audios/history.json"

-- Tạo thư mục
if not isfolder("audios") then
    makefolder("audios")
end

-- ==========================================================
-- HÀM TIỆN ÍCH
-- ==========================================================

-- Kéo thả cửa sổ
local function MakeDraggable(Dragger, Object, Callback)
    local StartPosition, StartDrag = nil, nil
    Dragger.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            StartPosition = UserInputService:GetMouseLocation()
            StartDrag = Object.AbsolutePosition
        end
    end)
    UserInputService.InputChanged:Connect(function(Input)
        if StartDrag and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Mouse = UserInputService:GetMouseLocation()
            local Delta = Mouse - StartPosition
            StartPosition = Mouse
            Object.Position = Object.Position + UDim2.new(0, Delta.X, 0, Delta.Y)
        end
    end)
    Dragger.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            StartPosition, StartDrag = nil, nil
            if Callback then Callback(Object.Position) end
        end
    end)
end

-- Lưu lịch sử
local function SaveHistory()
    if isfile(HistoryFile) then
        writefile(HistoryFile, HttpService:JSONEncode(History))
    end
end

-- Tải lịch sử
local function LoadHistory()
    if isfile(HistoryFile) then
        local data = readfile(HistoryFile)
        History = HttpService:JSONDecode(data) or {}
    end
end

-- Thêm vào lịch sử
local function AddToHistory(videoId, title)
    local timestamp = os.time()
    table.insert(History, 1, {id = videoId, title = title or "Unknown", time = timestamp})
    if #History > 50 then
        table.remove(History)
    end
    SaveHistory()
end

-- ==========================================================
-- HÀM XỬ LÝ AUDIO
-- ==========================================================

-- Gọi API để lấy audio
local function RequestVideo(VideoId)
    local Response = Request({
        Method = "POST",
        Url = Domain .. "yt/audio?videoId=" .. VideoId
    })
    if Response.StatusCode == 404 then
        return false
    end
    return Response.Body
end

-- Tìm kiếm YouTube
local function SearchYouTube(query)
    local url = "https://youtube-api-v3.vercel.app/api/search?q=" .. HttpService:UrlEncode(query)
    local response = Request({Method = "GET", Url = url})
    if response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        return data.results or {}
    end
    return {}
end

-- Cập nhật thời gian
local function UpdateTime()
    local TimePosition = Audio.TimePosition
    Playback.Time.Text = string.format(
        "%02i:%02i",
        TimePosition / 60 % 60,
        TimePosition % 60
    )
end

-- Cập nhật tổng thời gian
local function UpdateLength()
    local TimeLength = Audio.TimeLength
    Playback.Length.Text = string.format(
        "%02i:%02i",
        TimeLength / 60 % 60,
        TimeLength % 60
    )
end

-- Cập nhật thanh tiến trình
local function UpdatePlayback()
    if Audio.TimeLength > 0 then
        Playback.Line.Size = UDim2.new(Audio.TimePosition / Audio.TimeLength, 0, 1, 0)
    end
end

-- Cập nhật âm lượng
local function UpdateVS(Input)
    local XScale = math.clamp(
        (Input.Position.X - ControlPanel.VolSlider.AbsolutePosition.X) / ControlPanel.VolSlider.AbsoluteSize.X,
        0, 1
    )
    local SliderPrecise = math.round(math.clamp(XScale * 200, 0, 200))
    ControlPanel.VolSlider.Title.Text = tostring(SliderPrecise) .. "%"
    ControlPanel.VolSlider.Line.Size = UDim2.new((SliderPrecise) / 200, 0, 1, 0)
    Audio.Volume = SliderPrecise / 100
end

-- Cập nhật vị trí phát
local function UpdatePS(Input)
    local Position = math.clamp(
        (Input.Position.X - Playback.AbsolutePosition.X) / Playback.AbsoluteSize.X,
        0, 1
    )
    Audio.TimePosition = math.clamp(Audio.TimeLength * Position, 0, Audio.TimeLength)
    UpdateTime()
    UpdatePlayback()
end

-- Điều khiển phát
local function AudioMode(Mode)
    if Mode == "Play" then
        Audio.TimePosition = 0
        Audio:Play()
        ControlPanel.Play.Image = "rbxassetid://6026663719"
        PanelButton.Icon.Image = "rbxassetid://6026663719"
    elseif Mode == "Resume" then
        Audio:Resume()
        ControlPanel.Play.Image = "rbxassetid://6026663719"
        PanelButton.Icon.Image = "rbxassetid://6026663719"
    elseif Mode == "Stop" then
        Audio:Stop()
        ControlPanel.Play.Image = "rbxassetid://6026663699"
        PanelButton.Icon.Image = "rbxassetid://6026663699"
    elseif Mode == "Pause" then
        Audio:Pause()
        ControlPanel.Play.Image = "rbxassetid://6026663699"
        PanelButton.Icon.Image = "rbxassetid://6026663699"
    elseif Mode == "LoopOn" then
        Audio.Looped = true
        ControlPanel.Repeat.Image = "rbxassetid://6026666994"
    elseif Mode == "LoopOff" then
        Audio.Looped = false
        ControlPanel.Repeat.Image = "rbxassetid://6026666998"
    end
end

-- Tải audio
local function LoadAudio(Enter)
    if Enter then
        local VideoId = ControlPanel.VIDInput.Text
        local VideoTitle = ControlPanel.VIDInput.PlaceholderText
        
        if VideoId == "" then return end
        
        ControlPanel.VIDInput.PlaceholderText = "Loading..."
        ControlPanel.VIDInput.Text = ""
        
        -- Kiểm tra file đã có chưa
        if not isfile("audios/" .. VideoId .. ".mp3") then
            local Video = RequestVideo(VideoId)
            if Video then
                writefile("audios/" .. VideoId .. ".mp3", Video)
                Audio.SoundId = GetAsset("audios/" .. VideoId .. ".mp3")
                Title.Text = "🎵 " .. VideoTitle
                ControlPanel.VIDInput.PlaceholderText = "Video ID"
                AudioMode("Play")
                Playing = Audio.Playing
                AddToHistory(VideoId, VideoTitle)
            else
                ControlPanel.VIDInput.PlaceholderText = "Failed!"
                Window.Title.Text = "Audio Player"
                AudioMode("Stop")
                Playing = Audio.Playing
            end
        else
            ControlPanel.VIDInput.PlaceholderText = "Video ID"
            Audio.SoundId = GetAsset("audios/" .. VideoId .. ".mp3")
            Title.Text = "🎵 " .. VideoTitle
            AudioMode("Play")
            Playing = Audio.Playing
            AddToHistory(VideoId, VideoTitle)
        end
    end
end

-- Phát bài tiếp theo trong queue
local function PlayNext()
    if #Queue > 0 then
        local nextVideo = table.remove(Queue, 1)
        ControlPanel.VIDInput.Text = nextVideo
        LoadAudio(true)
    end
end

-- ==========================================================
-- UI SỰ KIỆN
-- ==========================================================

-- Volume slider
ControlPanel.VolSlider.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        UpdateVS(Input)
        VSActive = true
    end
end)

ControlPanel.VolSlider.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        VSActive = false
    end
end)

-- Playback slider
Playback.Slider.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        AudioMode("Pause")
        UpdatePS(Input)
        PSActive = true
    end
end)

Playback.Slider.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Playing then AudioMode("Resume") end
        PSActive = false
    end
end)

-- Mouse movement
UserInputService.InputChanged:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseMovement then
        if VSActive then UpdateVS(Input) end
        if PSActive then UpdatePS(Input) end
    end
end)

-- ==========================================================
-- UI BUTTONS
-- ==========================================================

-- Tìm kiếm và tải
ControlPanel.VIDInput.FocusLost:Connect(LoadAudio)

-- Play/Pause
ControlPanel.Play.MouseButton1Click:Connect(function()
    AudioMode(not Audio.Playing and "Resume" or "Pause")
    Playing = Audio.Playing
end)

-- Repeat
ControlPanel.Repeat.MouseButton1Click:Connect(function()
    AudioMode(Audio.Looped and "LoopOff" or "LoopOn")
end)

-- ==========================================================
-- THÊM NÚT TÌM KIẾM
-- ==========================================================
local SearchBtn = Instance.new("TextButton")
SearchBtn.Size = UDim2.new(0, 30, 0, 30)
SearchBtn.Position = UDim2.new(0.7, 5, 0, 10)
SearchBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
SearchBtn.Text = "🔍"
SearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBtn.Font = Enum.Font.GothamBold
SearchBtn.TextSize = 16
SearchBtn.Parent = ControlPanel

SearchBtn.MouseButton1Click:Connect(function()
    local query = ControlPanel.VIDInput.Text
    if query == "" then return end
    
    local results = SearchYouTube(query)
    if #results > 0 then
        local video = results[1]
        ControlPanel.VIDInput.Text = video.id
        ControlPanel.VIDInput.PlaceholderText = video.title or "Unknown"
        LoadAudio(true)
    else
        ControlPanel.VIDInput.PlaceholderText = "No results!"
    end
end)

-- ==========================================================
-- THÊM NÚT QUEUE (HIỂN THỊ SỐ LƯỢNG)
-- ==========================================================
local QueueBtn = Instance.new("TextButton")
QueueBtn.Size = UDim2.new(0, 40, 0, 30)
QueueBtn.Position = UDim2.new(0.78, 5, 0, 10)
QueueBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
QueueBtn.Text = "📋 0"
QueueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
QueueBtn.Font = Enum.Font.GothamBold
QueueBtn.TextSize = 14
QueueBtn.Parent = ControlPanel

-- Thêm vào queue bằng phím tắt (Ctrl+Enter)
ControlPanel.VIDInput.Binding:Connect(function()
    -- Chức năng này sẽ được xử lý qua phím tắt
end)

-- ==========================================================
-- THÊM NÚT LỊCH SỬ
-- ==========================================================
local HistoryBtn = Instance.new("TextButton")
HistoryBtn.Size = UDim2.new(0, 30, 0, 30)
HistoryBtn.Position = UDim2.new(0.85, 5, 0, 10)
HistoryBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
HistoryBtn.Text = "📜"
HistoryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HistoryBtn.Font = Enum.Font.GothamBold
HistoryBtn.TextSize = 16
HistoryBtn.Parent = ControlPanel

HistoryBtn.MouseButton1Click:Connect(function()
    if #History > 0 then
        local last = History[1]
        ControlPanel.VIDInput.Text = last.id
        ControlPanel.VIDInput.PlaceholderText = last.title or "History"
        LoadAudio(true)
    else
        ControlPanel.VIDInput.PlaceholderText = "No history!"
    end
end)

-- ==========================================================
-- PHÍM TẮT
-- ==========================================================
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    
    -- Space: Play/Pause
    if Input.KeyCode == Enum.KeyCode.Space then
        AudioMode(not Audio.Playing and "Resume" or "Pause")
        Playing = Audio.Playing
    end
    
    -- R: Repeat
    if Input.KeyCode == Enum.KeyCode.R then
        AudioMode(Audio.Looped and "LoopOff" or "LoopOn")
    end
    
    -- M: Mute
    if Input.KeyCode == Enum.KeyCode.M then
        Audio.Volume = Audio.Volume > 0 and 0 or 0.5
        ControlPanel.VolSlider.Title.Text = tostring(Audio.Volume * 100) .. "%"
        ControlPanel.VolSlider.Line.Size = UDim2.new(Audio.Volume, 0, 1, 0)
    end
    
    -- Ctrl+Enter: Add to Queue
    if Input.KeyCode == Enum.KeyCode.Return and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local videoId = ControlPanel.VIDInput.Text
        if videoId ~= "" then
            table.insert(Queue, videoId)
            QueueBtn.Text = "📋 " .. #Queue
            ControlPanel.VIDInput.PlaceholderText = "Added to queue!"
        end
    end
end)

-- ==========================================================
-- UPDATE VÒNG LẶP
-- ==========================================================
RunService.RenderStepped:Connect(function()
    if Audio.Playing then
        UpdateTime()
        UpdatePlayback()
    end
end)

-- ==========================================================
-- SỰ KIỆN KHÁC
-- ==========================================================

-- Tự động phát tiếp
Audio.Stopped:Connect(function()
    if Audio.Looped then return end
    if #Queue > 0 then
        PlayNext()
        QueueBtn.Text = "📋 " .. #Queue
    end
end)

-- Cập nhật tổng thời gian khi tải xong
Audio.Loaded:Connect(UpdateLength)

-- Mở/Đóng panel
PanelButton.Icon.MouseButton1Click:Connect(function()
    Window.Visible = not Window.Visible
end)

-- Kéo thả
MakeDraggable(Title, Window)

-- ==========================================================
-- TẢI LỊCH SỬ
-- ==========================================================
LoadHistory()

-- ==========================================================
-- THÔNG BÁO
-- ==========================================================
print("=":rep(50))
print("🎵 AUDIOPLAYER NÂNG CAO ĐÃ SẴN SÀNG!")
print("=":rep(50))
print("📌 HƯỚNG DẪN:")
print("  - Nhập Video ID YouTube → Enter để tải")
print("  - Click 🔍 để tìm kiếm tự động")
print("  - Click 📋 để xem queue")
print("  - Click 📜 để phát bài cuối cùng")
print("=":rep(50))
print("⌨️ PHÍM TẮT:")
print("  Space → Play/Pause")
print("  R → Repeat")
print("  M → Mute")
print("  Ctrl+Enter → Thêm vào Queue")
print("=":rep(50))
