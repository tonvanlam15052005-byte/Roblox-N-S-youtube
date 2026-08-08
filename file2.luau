-- ========================================
-- YOUTUBE PLAYER SIMPLE - Delta Executor
-- Hỗ trợ: Tìm kiếm + Dán link
-- ========================================

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- ========================================
-- CẤU HÌNH
-- ========================================
local CONFIG = {
    -- Sử dụng API miễn phí của cộng đồng
    SEARCH_API = "https://youtube-api-v3.vercel.app/api/search?q=",
    AUDIO_API = "https://youtube-api-v3.vercel.app/api/audio?id=",
}

-- ========================================
-- HÀM HỖ TRỢ
-- ========================================
local function request(url)
    -- Ưu tiên syn.request nếu có
    if syn and syn.request then
        local response = syn.request({Url = url, Method = "GET"})
        return response.Body
    else
        -- Fallback: game:HttpGet()
        return game:HttpGet(url)
    end
end

-- ========================================
-- YOUTUBE API (Sử dụng dịch vụ có sẵn)
-- ========================================
local YouTubeAPI = {}

-- Tìm kiếm video
function YouTubeAPI:search(query)
    local url = CONFIG.SEARCH_API .. HttpService:UrlEncode(query)
    local success, response = pcall(request, url)
    if not success then return nil, "Lỗi kết nối" end
    
    local data = HttpService:JSONDecode(response)
    if not data or not data.results then return nil, "Không có kết quả" end
    
    return data.results
end

-- Lấy link audio từ video ID
function YouTubeAPI:getAudio(videoId)
    local url = CONFIG.AUDIO_API .. videoId
    local success, response = pcall(request, url)
    if not success then return nil end
    
    local data = HttpService:JSONDecode(response)
    if data and data.audio then
        return data.audio
    end
    return nil
end

-- Lấy thông tin video từ link
function YouTubeAPI:extractVideoId(url)
    -- Hỗ trợ các định dạng link YouTube
    local patterns = {
        "v=([^&]+)",
        "youtu%.be/([^?]+)",
        "embed/([^?]+)"
    }
    
    for _, pattern in ipairs(patterns) do
        local id = string.match(url, pattern)
        if id then return id end
    end
    return nil
end

-- ========================================
-- PLAYER MANAGER
-- ========================================
local PlayerManager = {}
local sound = nil
local currentTrack = nil
local isPlaying = false
local queue = {}

function PlayerManager:init()
    sound = Instance.new("Sound")
    sound.Volume = 0.5
    sound.Parent = Player.PlayerGui or game.CoreGui
    
    sound.Stopped:Connect(function()
        isPlaying = false
        if #queue > 0 then
            PlayerManager:playNext()
        end
    end)
end

function PlayerManager:play(audioUrl, track)
    if not sound then self:init() end
    if sound.IsPlaying then sound:Stop() end
    
    sound.SoundId = audioUrl
    currentTrack = track
    isPlaying = true
    sound:Play()
    
    print("🎵 Đang phát: " .. track.title)
end

function PlayerManager:pause()
    if isPlaying and sound then
        sound:Pause()
        isPlaying = false
        return true
    end
    return false
end

function PlayerManager:resume()
    if not isPlaying and sound then
        sound:Resume()
        isPlaying = true
        return true
    end
    return false
end

function PlayerManager:stop()
    if sound then
        sound:Stop()
        isPlaying = false
        currentTrack = nil
        return true
    end
    return false
end

function PlayerManager:addToQueue(track)
    table.insert(queue, track)
    print("📋 Đã thêm vào queue: " .. track.title .. " (#" .. #queue .. ")")
end

function PlayerManager:playNext()
    if #queue > 0 then
        local nextTrack = table.remove(queue, 1)
        local audioUrl = YouTubeAPI:getAudio(nextTrack.id)
        if audioUrl then
            self:play(audioUrl, nextTrack)
            return true
        end
    end
    return false
end

function PlayerManager:getState()
    return {
        isPlaying = isPlaying,
        currentTrack = currentTrack,
        queue = queue
    }
end

-- ========================================
-- UI (Giao diện đơn giản)
-- ========================================
local UI = {}
local mainFrame = nil

function UI:create()
    -- Xóa UI cũ
    if mainFrame then mainFrame:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YTMusicPlayer"
    screenGui.Parent = Player.PlayerGui or game.CoreGui
    
    -- Frame chính
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    title.Text = "🎵 YouTube Player"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = mainFrame
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
    
    -- Search/Input Frame
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -10, 0, 40)
    inputFrame.Position = UDim2.new(0, 5, 0, 45)
    inputFrame.BackgroundTransparency = 1
    inputFrame.Parent = mainFrame
    
    -- Input box (có thể nhập link hoặc tên bài hát)
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0.7, -5, 1, 0)
    searchBox.Position = UDim2.new(0, 0, 0, 0)
    searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.TextSize = 15
    searchBox.Font = Enum.Font.GothamMedium
    searchBox.PlaceholderText = "🔍 Nhập tên bài hát hoặc dán link YouTube..."
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = inputFrame
    
    -- Search Button
    local searchBtn = Instance.new("TextButton")
    searchBtn.Size = UDim2.new(0.28, -5, 1, 0)
    searchBtn.Position = UDim2.new(0.72, 5, 0, 0)
    searchBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    searchBtn.Text = "🔍 Tìm / Phát"
    searchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBtn.TextSize = 15
    searchBtn.Font = Enum.Font.GothamBold
    searchBtn.Parent = inputFrame
    
    -- Result List
    local resultList = Instance.new("ScrollingFrame")
    resultList.Size = UDim2.new(1, -10, 0, 220)
    resultList.Position = UDim2.new(0, 5, 0, 90)
    resultList.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    resultList.BorderSizePixel = 0
    resultList.CanvasSize = UDim2.new(0, 0, 0, 0)
    resultList.ScrollBarThickness = 6
    resultList.Parent = mainFrame
    
    -- Now Playing
    local nowPlaying = Instance.new("TextLabel")
    nowPlaying.Size = UDim2.new(1, -10, 0, 30)
    nowPlaying.Position = UDim2.new(0, 5, 0, 315)
    nowPlaying.BackgroundTransparency = 1
    nowPlaying.Text = "⏸️ Chưa có bài hát"
    nowPlaying.TextColor3 = Color3.fromRGB(200, 200, 200)
    nowPlaying.TextSize = 14
    nowPlaying.Font = Enum.Font.GothamMedium
    nowPlaying.Parent = mainFrame
    
    -- Control Buttons
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(1, -10, 0, 40)
    controlsFrame.Position = UDim2.new(0, 5, 0, 350)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = mainFrame
    
    local function createBtn(text, posX, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 60, 0, 35)
        btn.Position = UDim2.new(0, posX, 0, 0)
        btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 70)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 18
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = controlsFrame
        return btn
    end
    
    local playBtn = createBtn("▶️", 0)
    local pauseBtn = createBtn("⏸️", 65, Color3.fromRGB(200, 150, 0))
    local stopBtn = createBtn("⏹️", 130, Color3.fromRGB(200, 50, 50))
    local nextBtn = createBtn("⏭️", 195)
    
    -- Queue info
    local queueLabel = Instance.new("TextLabel")
    queueLabel.Size = UDim2.new(0, 100, 0, 35)
    queueLabel.Position = UDim2.new(1, -110, 0, 0)
    queueLabel.BackgroundTransparency = 1
    queueLabel.Text = "📋 Queue: 0"
    queueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    queueLabel.TextSize = 14
    queueLabel.Font = Enum.Font.GothamMedium
    queueLabel.TextXAlignment = Enum.TextXAlignment.Right
    queueLabel.Parent = controlsFrame
    
    -- ========================================
    -- UI EVENTS
    -- ========================================
    
    local function doSearch()
        local input = searchBox.Text
        if input == "" then return end
        
        -- Clear old results
        for _, child in ipairs(resultList:GetChildren()) do
            child:Destroy()
        end
        
        -- Loading
        local loading = Instance.new("TextLabel")
        loading.Size = UDim2.new(1, 0, 0, 40)
        loading.BackgroundTransparency = 1
        loading.Text = "⏳ Đang tìm kiếm..."
        loading.TextColor3 = Color3.fromRGB(200, 200, 200)
        loading.TextSize = 16
        loading.Font = Enum.Font.GothamMedium
        loading.Parent = resultList
        
        -- Kiểm tra nếu input là link YouTube
        local videoId = YouTubeAPI:extractVideoId(input)
        
        if videoId then
            -- Nếu là link, phát trực tiếp
            loading.Text = "⏳ Đang tải video..."
            
            local audioUrl = YouTubeAPI:getAudio(videoId)
            loading:Destroy()
            
            if audioUrl then
                local track = {id = videoId, title = "Video từ link"}
                PlayerManager:play(audioUrl, track)
                nowPlaying.Text = "▶️ " .. track.title
            else
                nowPlaying.Text = "❌ Không thể tải video này"
            end
            return
        end
        
        -- Tìm kiếm bình thường
        local results, err = YouTubeAPI:search(input)
        loading:Destroy()
        
        if not results then
            local errorLabel = Instance.new("TextLabel")
            errorLabel.Size = UDim2.new(1, 0, 0, 40)
            errorLabel.BackgroundTransparency = 1
            errorLabel.Text = "❌ " .. err
            errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            errorLabel.TextSize = 14
            errorLabel.Font = Enum.Font.GothamMedium
            errorLabel.Parent = resultList
            return
        end
        
        if #results == 0 then
            local emptyLabel = Instance.new("TextLabel")
            emptyLabel.Size = UDim2.new(1, 0, 0, 40)
            emptyLabel.BackgroundTransparency = 1
            emptyLabel.Text = "Không tìm thấy kết quả"
            emptyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            emptyLabel.TextSize = 16
            emptyLabel.Font = Enum.Font.GothamMedium
            emptyLabel.Parent = resultList
            return
        end
        
        -- Display results
        local yPos = 5
        for _, track in ipairs(results) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 40)
            btn.Position = UDim2.new(0, 5, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 14
            btn.Font = Enum.Font.GothamMedium
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BorderSizePixel = 0
            
            local title = track.title
            if #title > 50 then title = string.sub(title, 1, 47) .. "..." end
            btn.Text = string.format("%s - %s", title, track.channel or "Unknown")
            
            btn.Parent = resultList
            
            -- Click để phát
            btn.MouseButton1Click:Connect(function()
                nowPlaying.Text = "⏳ Đang tải: " .. track.title
                
                local audioUrl = YouTubeAPI:getAudio(track.id)
                if audioUrl then
                    PlayerManager:play(audioUrl, track)
                    nowPlaying.Text = "▶️ " .. track.title
                else
                    nowPlaying.Text = "❌ Không thể tải: " .. track.title
                end
            end)
            
            -- Right-click thêm vào queue
            btn.MouseButton2Click:Connect(function()
                PlayerManager:addToQueue(track)
                queueLabel.Text = "📋 Queue: " .. #queue
            end)
            
            yPos = yPos + 45
        end
        
        resultList.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
    end
    
    -- Events
    searchBtn.MouseButton1Click:Connect(doSearch)
    searchBox.FocusLost:Connect(function(enter)
        if enter then doSearch() end
    end)
    
    -- Controls
    playBtn.MouseButton1Click:Connect(function()
        PlayerManager:resume()
        local state = PlayerManager:getState()
        if state.currentTrack then
            nowPlaying.Text = "▶️ " .. state.currentTrack.title
        end
    end)
    
    pauseBtn.MouseButton1Click:Connect(function()
        PlayerManager:pause()
        local state = PlayerManager:getState()
        if state.currentTrack then
            nowPlaying.Text = "⏸️ " .. state.currentTrack.title
        end
    end)
    
    stopBtn.MouseButton1Click:Connect(function()
        PlayerManager:stop()
        nowPlaying.Text = "⏹️ Đã dừng"
    end)
    
    nextBtn.MouseButton1Click:Connect(function()
        if PlayerManager:playNext() then
            local state = PlayerManager:getState()
            if state.currentTrack then
                nowPlaying.Text = "⏭️ " .. state.currentTrack.title
            end
            queueLabel.Text = "📋 Queue: " .. #queue
        end
    end)
    
    -- Keyboard shortcuts
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Space then
            local state = PlayerManager:getState()
            if state.isPlaying then
                PlayerManager:pause()
                nowPlaying.Text = "⏸️ " .. (state.currentTrack and state.currentTrack.title or "")
            else
                PlayerManager:resume()
                nowPlaying.Text = "▶️ " .. (state.currentTrack and state.currentTrack.title or "")
            end
        end
    end)
    
    -- Update queue label periodically
    spawn(function()
        while wait(2) do
            queueLabel.Text = "📋 Queue: " .. #queue
        end
    end)
    
    print("✅ YouTube Player đã sẵn sàng!")
    print("📖 Hướng dẫn:")
    print("   - Tìm kiếm: Nhập tên bài hát -> Enter")
    print("   - Phát link: Dán link YouTube -> Enter")
    print("   - Click để phát | Right-click để thêm vào queue")
    print("   - Phím Space: Pause/Resume")
end

-- ========================================
-- KHỞI CHẠY
-- ========================================
wait(1)
UI:create()
PlayerManager:init()

print("🎵 YouTube Player đã khởi động thành công!")