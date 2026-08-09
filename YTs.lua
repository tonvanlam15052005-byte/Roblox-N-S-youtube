-- ==========================================================
-- THÊM CHỨC NĂNG TÌM KIẾM YOUTUBE
-- ==========================================================

-- Thêm vào script (sau phần RequestVideo)

local function SearchYouTube(query)
    local url = "https://youtube-api-v3.vercel.app/api/search?q=" .. HttpService:UrlEncode(query)
    local response = Request({Method = "GET", Url = url})
    if response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        return data.results or {}
    end
    return {}
end

-- Thêm nút tìm kiếm vào UI
local SearchBtn = ControlPanel:FindFirstChild("SearchBtn") or Instance.new("TextButton")
SearchBtn.Size = UDim2.new(0, 30, 0, 30)
SearchBtn.Position = UDim2.new(0.7, 5, 0, 10)
SearchBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
SearchBtn.Text = "🔍"
SearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBtn.Parent = ControlPanel

-- Xử lý tìm kiếm
SearchBtn.MouseButton1Click:Connect(function()
    local query = ControlPanel.VIDInput.Text
    if query == "" then return end
    
    local results = SearchYouTube(query)
    if #results > 0 then
        -- Lấy video đầu tiên
        local videoId = results[1].id
        ControlPanel.VIDInput.Text = videoId
        LoadAudio(true) -- Tự động tải
    end
end)
