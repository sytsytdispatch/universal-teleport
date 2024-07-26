 local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.3, 0, 0.6, 0)
frame.Position = UDim2.new(0.35, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.Parent = screenGui

local topBar = Instance.new("TextLabel")
topBar.Size = UDim2.new(1, 0, 0, 60)  -- Height doubled
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
topBar.Text = "Universal Teleportation"
topBar.TextScaled = true
topBar.Font = Enum.Font.LuckiestGuy
topBar.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundTransparency = 1
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 0, 0)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.LuckiestGuy
closeButton.Parent = topBar

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, 0, 1, -60)  -- Adjusted for new top bar height
scrollingFrame.Position = UDim2.new(0, 0, 0, 60)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 10
scrollingFrame.Parent = frame

local function createPlayerButton(player)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 50)
    button.Text = player.Name
    button.TextScaled = true
    button.Parent = scrollingFrame

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 50, 0, 50)
    avatar.Position = UDim2.new(0, 0, 0, 0)
    avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
    avatar.Parent = button

    button.MouseButton1Click:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame)
        end
    end)

    return button
end

local function updatePlayerList()
    local existingPlayers = {}
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then
            existingPlayers[child.Text] = child
        end
    end

    local yOffset = 0
    for _, player in ipairs(Players:GetPlayers()) do
        local button = existingPlayers[player.Name]
        if not button then
            button = createPlayerButton(player)
        end
        button.Position = UDim2.new(0, 10, 0, yOffset)
        yOffset = yOffset + 60
    end

    for name, button in pairs(existingPlayers) do
        if not Players:FindFirstChild(name) then
            button:Destroy()
        end
    end

    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

game:GetService("RunService").Stepped:Connect(function()
    updatePlayerList()
end)

local dragging
local dragInput
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

topBar.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
    game.StarterGui:SetCore("SendNotification", {
        Title = "Universal Teleportation",
        Text = "Press L to bring back the GUI",
        Duration = 5
    })
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.L then
        if not screenGui.Enabled then
            screenGui.Enabled = true
        end
    end
end)

while true do
    updatePlayerList()
    wait(1)
end
