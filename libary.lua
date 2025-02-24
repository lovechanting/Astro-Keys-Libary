getgenv().AstroKeys = {}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Drawing = Drawing
local AstroKeys = getgenv().AstroKeys

AstroKeys.Config = {
    DefaultProvider = "GITHUB",
    APIKeys = {
        PrivateGitHub = "",
        CustomAPI = ""
    },
    Providers = {
        GITHUB = "https://raw.githubusercontent.com/YourRepo/keys/main/keys.txt",
        PASTEBIN = "https://pastebin.com/raw/YourPasteID",
        LINKVERTISE = "https://linkvertise.com/api/getKey?apiKey=YourAPIKey",
        PRIVATE_GITHUB = "https://raw.githubusercontent.com/YourPrivateRepo/keys/main/keys.txt"
    },
    RankColors = {
        Owner = Color3.fromRGB(0, 0, 139),
        Guest = Color3.fromRGB(169, 169, 169)
    },
    CommandPrefix = ","
}

local function fetchKeys(url, headers)
    if not url or url == "" then return nil end
    local success, response = pcall(function()
        if headers then
            return HttpService:GetAsync(url, true, headers)
        else
            return game:HttpGet(url)
        end
    end)
    return success and response or nil
end

local function parseKeyFormat(keyData)
    local keys = {}
    for line in keyData:gmatch("[^\n]+") do
        local key, rank = line:match("(.-) %[([^%]]+)%]")
        if key and rank then
            keys[key] = rank
        else
            keys[line] = "Guest"
        end
    end
    return keys
end

function AstroKeys.ValidateKey(inputKey, provider)
    provider = provider or AstroKeys.Config.DefaultProvider
    if not AstroKeys.Config.Providers[provider] then return false end
    local keyList = fetchKeys(AstroKeys.Config.Providers[provider])
    if keyList then
        local parsedKeys = parseKeyFormat(keyList)
        return parsedKeys[inputKey] and parsedKeys[inputKey] or false
    end
    return false
end

function AstroKeys.SetCustomProvider(name, url)
    if type(name) == "string" and type(url) == "string" then
        AstroKeys.Config.Providers[name] = url
    end
end

function AstroKeys.AuthenticatePrivateRepo()
    local token = AstroKeys.Config.APIKeys.PrivateGitHub
    if token == "" then return nil end
    local headers = {
        ["Authorization"] = "token " .. token
    }
    return fetchKeys(AstroKeys.Config.Providers["PRIVATE_GITHUB"], headers)
end

function AstroKeys.RequestKeyFromAPI(apiURL)
    local apiKey = AstroKeys.Config.APIKeys.CustomAPI
    if apiKey == "" then return nil end
    local headers = {
        ["Authorization"] = "Bearer " .. apiKey
    }
    return fetchKeys(apiURL, headers)
end

function AstroKeys.DisplayRank(player, rank)
    if not Drawing or not player.Character or not player.Character:FindFirstChild("Head") then return end
    local head = player.Character.Head
    local rankText = Drawing.new("Text")
    rankText.Text = rank
    rankText.Color = AstroKeys.Config.RankColors[rank] or Color3.fromRGB(255, 255, 255)
    rankText.Size = 18
    rankText.Outline = true
    rankText.Visible = true
    rankText.Position = Vector2.new(head.Position.X, head.Position.Y - 20)
    task.spawn(function()
        while task.wait() do
            if not player.Character or not player.Character:FindFirstChild("Head") then
                rankText:Remove()
                break
            end
            rankText.Position = Vector2.new(head.Position.X, head.Position.Y - 20)
        end
    end)
end

function AstroKeys.AssignRank(player, inputKey)
    local rank = AstroKeys.ValidateKey(inputKey)
    if rank then
        AstroKeys.DisplayRank(player, rank)
        if rank == "Owner" then
            AstroKeys.EnableChatCommands(player)
        end
    end
end

function AstroKeys.EnableChatCommands(player)
    player.Chatted:Connect(function(msg)
        local prefix = AstroKeys.Config.CommandPrefix
        if msg:sub(1, #prefix) == prefix then
            local command, targetName = msg:match(prefix .. "(%w+)%s*(.*)")
            local target = Players:FindFirstChild(targetName)
            if command == "bring" and target and target.Character and player.Character then
                target.Character:SetPrimaryPartCFrame(player.Character:GetPrimaryPartCFrame())
            elseif command == "kill" and target and target.Character then
                target.Character:BreakJoints()
            elseif command == "float" and target and target.Character then
                target.Character.HumanoidRootPart.Anchored = true
            elseif command == "freeze" and target and target.Character then
                for _, part in ipairs(target.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Anchored = true
                    end
                end
            elseif command == "spin" and target and target.Character then
                task.spawn(function()
                    while true do
                        task.wait()
                        if target.Character then
                            target.Character:SetPrimaryPartCFrame(target.Character:GetPrimaryPartCFrame() * CFrame.Angles(0, math.rad(10), 0))
                        else
                            break
                        end
                    end
                end)
            elseif command == "aspaz" and target and target.Character then
                task.spawn(function()
                    while true do
                        task.wait(0.05)
                        if target.Character then
                            local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid then
                                humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                            end
                            target.Character:SetPrimaryPartCFrame(target.Character:GetPrimaryPartCFrame() * CFrame.Angles(math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360))))
                        else
                            break
                        end
                    end
                end)
            elseif command == "gl" and target then
                VirtualInputManager:SendKeyEvent(true, "Escape", false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(true, "L", false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(true, "Return", false, game)
            end
        end
    end)
end

return AstroKeys
