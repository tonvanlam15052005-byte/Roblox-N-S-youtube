-- ============================================
-- YOUTUBE PLAYER - DELTA EXECUTOR
-- BẢN HOẠT ĐỘNG (Dùng API mới)
-- ============================================

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- ============================================
-- CẤU HÌNH (API ĐANG HOẠT ĐỘNG)
-- ============================================
local CONFIG = {
    -- Dùng API của api.vevioz.com (miễn phí, đang hoạt động)
    SEARCH_API = "https://api.vevioz.com/api/search?query=",
    AUDIO_API = "https://api.vevioz.com/api/button/mp3/https://www.youtube.com/watch?v=",
}

-- ============================================
-- HÀM GỬI REQUEST (Hỗ trợ cả 2 cách)
-- ============================================
local function request(url)
    local success, result = pcall(function()
        -- Ưu tiên syn.request nếu có
        if syn and syn.request then
            local response = syn.request({
                Url = url,
                Method = "GET",
                Headers = {
                    ["User-Agent"] = "Mozilla/5.0"
                }
            })
            return response.Body
        else
            -- Fallback: game:HttpGet
            return game:HttpGet(url)
        end
    end)
    
    if success then
        return result
    else
        warn("⚠️ Lỗi request: " .. tostring(result))
        return nil
    end
end

-- ============================================
-- YOUTUBE API
-- ============================================
local YouTubeAPI = {}

-- Tìm kiếm video
function YouTubeAPI:search(query)
    if not query or query == "" then
        return nil, "Vui lòng nhập từ khóa"
    end
    
    local url = CONFIG.SEARCH_API .. HttpService:UrlEncode(query)
    print("🔍 Đang tìm: " .. query)
    
    local response = request(url)
    if not response then
        return nil, "Không thể kết nối đến API"
    end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    
    if not success then
        return nil, "Dữ liệu trả về không hợp lệ"
    end
    
    if data and data.results and #data.results > 0 then
        return data.results
    else
        return nil, "Không tìm thấy kết quả"
    end
end

-- Lấy link audio
function YouTubeAPI:getAudio(videoId)
    if not videoId then return nil end
    
    local url = CONFIG.AUDIO_API .. videoId
    print("🎵 Đang lấy audio cho: " .. videoId)
    
    local response = request(url)
    if not response then
        return nil
    end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    
    if not success then
        return nil
    end
    
    -- Kiểm tra cấu trúc response của vevioz
    if data and data.download_url then
        return data.download_url
    elseif data and data.audio and data.audio.url then
        return data.audio.url
    elseif data and data.url then
        return data.url
    else
        return nil
    end
end

-- Trích xuất video ID từ link YouTube
function YouTubeAPI:extractVideoId(input)
    if not input then return nil end
    
    local patterns = {
        "v=([^&]+)",
        "youtu%.be/([^?]+)",
        "embed/([^?]+)",
        "shorts/([^?]+)"
    }
    
    for _, pattern in ipairs(patterns) do
        local id = string.match(input, pattern)
        if id and #id == 11 then
            return id
        end
    end
    
    -- Nếu input chỉ là ID (11 ký tự)
    if #input == 11 and not string.find(input, "/") then
        return input
    end
    
    return nil
end

-- ============================================
-- TRÌNH PHÁT NHẠC
-- ============================================
local PlayerManager = {}
local sound = nil
local currentTrack = nil
local isPlaying = false
local queue = {}
local currentVolume = 0.5

function PlayerManager:init()
    if sound then return end
    
    sound = Instance.new("Sound")
    sound.Volume = currentVolume
    sound.Parent = Player.PlayerGui or game.CoreGui
    
    sound.Stopped:Connect(function()
        isPlaying = false
        if #queue > 0 then
            PlayerManager:playNext()
        end
    end)
    
    print("✅ Player đã sẵn sàng")
end

function PlayerManager:play(audioUrl, track)
    if not sound then self:init() end
    
    if sound.IsPlaying then
        sound:Stop()
    end
    
    sound.SoundId = audioUrl
    currentTrack = track
    isPlaying = true
    
    sound:Play()
    
    print("▶️ Đang phát: " .. (track.title or "Unknown"))
    
    -- Cập nhật UI nếu có
    if UI and UI.updateNowPlaying then
        UI.updateNowPlaying("▶️ " .. (track.title or "Đang phát"))
    end
end

function PlayerManager:pause()
    if isPlaying and sound then
        sound:Pause()
        isPlaying = false
        if UI and UI.updateNowPlaying then
            UI.updateNowPlaying("⏸️ " .. (currentTrack and currentTrack.title or "Tạm dừng"))
        end
        return true
    end
    return false
end

function PlayerManager:resume()
    if not isPlaying and sound then
        sound:Resume()
        isPlaying = true
        if UI and UI.updateNowPlaying then
            UI.updateNowPlaying("▶️ " .. (currentTrack and currentTrack.title or "Đang phát"))
        end
        return true
    end
    return false
end

function PlayerManager:stop()
    if sound then
        sound:Stop()
        isPlaying = false
        currentTrack = nil
        if UI and UI.updateNowPlaying then
            UI.updateNowPlaying("⏹️ Đã dừng")
        end
        return true
    end
    return false
end

function PlayerManager:setVolume(vol)
    currentVolume = math.clamp(vol, 0, 1)
    if sound then
        sound.Volume = currentVolume
    end
    return currentVolume
end

function PlayerManager:addToQueue(track)
    table.insert(queue, track)
    print("📋 Đã thêm: " .. track.title .. " (#" .. #queue .. ")")
    if UI and UI.updateQueue then
        UI.updateQueue(#queue)
    end
end

function PlayerManager:playNext()
    if #queue > 0 then
        local nextTrack = table.remove(queue, 1)
        local audioUrl = YouTubeAPI:getAudio(nextTrack.id)
        
        if audioUrl then
            self:play(audioUrl, nextTrack)
            if UI and UI.updateQueue then
                UI.updateQueue(#queue)
            end
            return true
        else
            print("❌ Không tải được: " .. nextTrack.title)
            return self:playNext() -- Thử bài tiếp
        end
    end
    return false
end

function PlayerManager:clearQueue()
    queue = {}
    if UI and UI.updateQueue then
        UI.updateQueue(0)
    end
    print("🗑️ Đã xóa hàng chờ")
end

function PlayerManager:getState()
    return {
        isPlaying = isPlaying,
        currentTrack = currentTrack,
        queue = queue,
        volume = currentVolume
    }
end

-- ============================================
-- GIAO DIỆN NGƯỜI DÙNG
-- ============================================
local UI = {}
local mainFrame = nil
local resultList = nil
local nowPlaying = nil
local queueLabel = nil
local searchBox = nil

function UI:create()
    -- Xóa UI cũ
    if mainFrame then 
        mainFrame:Destroy() 
        mainFrame = nil
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YTMusicPlayer"
    screenGui.Parent = Player.PlayerGui or game.CoreGui
    
    -- Frame chính
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 480, 0, 480)
    mainFrame.Position = UDim2.new(0.5, -240, 0.5, -240)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Cho phép kéo thả
    mainFrame.Draggable = true
    mainFrame.Active = true
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎵 YouTube Player"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -38, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
    
    -- Search area
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(1, -20, 0, 45)
    searchFrame.Position = UDim2.new(0, 10, 0, 50)
    searchFrame.BackgroundTransparency = 1
    searchFrame.Parent = mainFrame
    
    searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0.7, -5, 1, 0)
    searchBox.Position = UDim2.new(0, 0, 0, 0)
    searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.TextSize = 15
    searchBox.Font = Enum.Font.GothamMedium
    searchBox.PlaceholderText = "🔍 Nhập tên bài hát hoặc link YT..."
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = searchFrame
    
    local searchBtn = Instance.new("TextButton")
    searchBtn.Size = UDim2.new(0.28, -5, 1, 0)
    searchBtn.Position = UDim2.new(0.72, 5, 0, 0)
    searchBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    searchBtn.Text = "🔍 Tìm"
    searchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBtn.TextSize = 16
    searchBtn.Font = Enum.Font.GothamBold
    searchBtn.BorderSizePixel = 0
    searchBtn.Parent = searchFrame
    
    -- Result list
    resultList = Instance.new("ScrollingFrame")
    resultList.Size = UDim2.new(1, -20, 0, 240)
    resultList.Position = UDim2.new(0, 10, 0, 105)
    resultList.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    resultList.BorderSizePixel = 0
    resultList.CanvasSize = UDim2.new(0, 0, 0, 0)
    resultList.ScrollBarThickness = 8
    resultList.Parent = mainFrame
    
    -- Now playing
    nowPlaying = Instance.new("TextLabel")
    nowPlaying.Size = UDim2.new(1, -20, 0, 35)
    nowPlaying.Position = UDim2.new(0, 10, 0, 350)
    nowPlaying.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    nowPlaying.Text = "⏸️ Chưa có bài hát"
    nowPlaying.TextColor3 = Color3.fromRGB(200, 200, 200)
    nowPlaying.TextSize = 15
    nowPlaying.Font = Enum.Font.GothamMedium
    nowPlaying.Parent = mainFrame
    
    -- Controls
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(1, -20, 0, 45)
    controlsFrame.Position = UDim2.new(0, 10, 0, 390)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = mainFrame
    
    local function createBtn(text, posX, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 65, 0, 40)
        btn.Position = UDim2.new(0, posX, 0, 0)
        btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 80)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 20
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = controlsFrame
        return btn
    end
    
    local playBtn = createBtn("▶️", 0)
    local pauseBtn = createBtn("⏸️", 70, Color3.fromRGB(200, 150, 0))
    local stopBtn = createBtn("⏹️", 140, Color3.fromRGB(200, 50, 50))
    local nextBtn = createBtn("⏭️", 210)
    local clearBtn = createBtn("🗑️", 280, Color3.fromRGB(150, 50, 50))
    
    -- Queue label
    queueLabel = Instance.new("TextLabel")
    queueLabel.Size = UDim2.new(0, 100, 0, 40)
    queueLabel.Position = UDim2.new(1, -110, 0, 0)
    queueLabel.BackgroundTransparency = 1
    queueLabel.Text = "📋 0"
    queueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    queueLabel.TextSize = 16
    queueLabel.Font = Enum.Font.GothamMedium
    queueLabel.TextXAlignment = Enum.TextXAlignment.Right
    queueLabel.Parent = controlsFrame
    
    -- Volume slider
    local volFrame = Instance.new("Frame")
    volFrame.Size = UDim2.new(0, 120, 0, 25)
    volFrame.Position = UDim2.new(0, 5, 1, -30)
    volFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    volFrame.BorderSizePixel = 0
    volFrame.Parent = mainFrame
    
    local volBar = Instance.new("Frame")
    volBar.Size = UDim2.new(1, 0, 1, 0)
    volBar.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    volBar.BorderSizePixel = 0
    volBar.Parent = volFrame
    
    local volFill = Instance.new("Frame")
    volFill.Size = UDim2.new(0.5, 0, 1, 0)
    volFill.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    volFill.BorderSizePixel = 0
    volFill.Parent = volBar
    
    local volLabel = Instance.new("TextLabel")
    volLabel.Size = UDim2.new(0, 25, 1, 0)
    volLabel.Position = UDim2.new(1, 2, 0, 0)
    volLabel.BackgroundTransparency = 1
    volLabel.Text = "🔊"
    volLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    volLabel.TextSize = 16
    volLabel.Font = Enum.Font.GothamMedium
    volLabel.Parent = volFrame
    
    -- ============================================
    -- UI SỰ KIỆN
    -- ============================================
    
    -- Search
    local function doSearch()
        local input = searchBox.Text
        if input == "" then return end
        
        -- Xóa kết quả cũ
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
        resultList.CanvasSize = UDim2.new(0, 0, 0, 50)
        
        -- Kiểm tra link YouTube
        local videoId = YouTubeAPI:extractVideoId(input)
        
        if videoId then
            loading.Text = "⏳ Đang tải video..."
            
            local audioUrl = YouTubeAPI:getAudio(videoId)
            loading:Destroy()
            
            if audioUrl then
                local track = {id = videoId, title = "📹 Video từ link"}
                PlayerManager:play(audioUrl, track)
            else
                nowPlaying.Text = "❌ Không thể tải video này"
            end
            return
        end
        
        -- Tìm kiếm
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
            resultList.CanvasSize = UDim2.new(0, 0, 0, 50)
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
            resultList.CanvasSize = UDim2.new(0, 0, 0, 50)
            return
        end
        
        -- Hiển thị kết quả
        local yPos = 5
        for _, track in ipairs(results) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 42)
            btn.Position = UDim2.new(0, 5, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 14
            btn.Font = Enum.Font.GothamMedium
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BorderSizePixel = 0
            
            local title = track.title or "Không tiêu đề"
            if #title > 55 then title = string.sub(title, 1, 52) .. "..." end
            local channel = track.channel or "Unknown"
            btn.Text = title .. " - " .. channel
            
            btn.Parent = resultList
            
            -- Click trái -> phát
            btn.MouseButton1Click:Connect(function()
                nowPlaying.Text = "⏳ Đang tải: " .. track.title
                
                local audioUrl = YouTubeAPI:getAudio(track.id)
                if audioUrl then
                    PlayerManager:play(audioUrl, track)
                else
                    nowPlaying.Text = "❌ Không thể tải: " .. track.title
                end
            end)
            
            -- Click phải -> thêm queue
            btn.MouseButton2Click:Connect(function()
                PlayerManager:addToQueue(track)
            end)
            
            yPos = yPos + 47
        end
        
        resultList.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
    end
    
    -- Gán sự kiện
    searchBtn.MouseButton1Click:Connect(doSearch)
    searchBox.FocusLost:Connect(function(enter)
        if enter then doSearch() end
    end)
    
    -- Control buttons
    playBtn.MouseButton1Click:Connect(function()
        PlayerManager:resume()
    end)
    
    pauseBtn.MouseButton1Click:Connect(function()
        PlayerManager:pause()
    end)
    
    stopBtn.MouseButton1Click:Connect(function()
        PlayerManager:stop()
    end)
    
    nextBtn.MouseButton1Click:Connect(function()
        PlayerManager:playNext()
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        PlayerManager:clearQueue()
    end)
    
    -- Volume slider
    volBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local function updateVol()
                local mouse = Player:GetMouse()
                local posX = volBar.AbsolutePosition.X
                local width = volBar.AbsoluteSize.X
                local percent = math.clamp((mouse.X - posX) / width, 0, 1)
                
                volFill.Size = UDim2.new(percent, 0, 1, 0)
                PlayerManager:setVolume(percent)
            end
            
            updateVol()
            
            local conn
            conn = Player:GetMouse().Move:Connect(updateVol)
            Player:GetMouse().Button1Up:Connect(function()
                conn:Disconnect()
            end)
        end
    end)
    
    -- Keyboard: Space để pause/resume
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        if input.KeyCode == Enum.KeyCode.Space then
            local state = PlayerManager:getState()
            if state.isPlaying then
                PlayerManager:pause()
            else
                PlayerManager:resume()
            end
        end
    end)
    
    -- ============================================
    -- UI UPDATE FUNCTIONS (để gọi từ PlayerManager)
    -- ============================================
    
    function UI.updateNowPlaying(text)
        if nowPlaying then
            nowPlaying.Text = text
        end
    end
    
    function UI.updateQueue(count)
        if queueLabel then
            queueLabel.Text = "📋 " .. count
        end
    end
    
    print("✅ UI đã sẵn sàng")
end

-- ============================================
-- KHỞI ĐỘNG
-- ============================================

print("🎵 Đang khởi động YouTube Player...")
print("📌 Sử dụng API: vevioz.com")

-- Khởi tạo
wait(1)
PlayerManager:init()
UI:create()

print("✅ YouTube Player đã sẵn sàng!")
print("📖 HƯỚNG DẪN:")
print("   - Nhập tên bài hát -> Enter để tìm")
print("   - Dán link YouTube -> Enter để phát")
print("   - Click trái vào bài hát -> Phát")
print("   - Click phải vào bài hát -> Thêm vào hàng chờ")
print("   - Phím Space -> Pause/Resume")
