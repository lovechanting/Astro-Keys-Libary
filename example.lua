local AstroKeys = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourRepo/AstroKeys/main/AstroKeys.lua"))()

getgenv().AstroKeys.Config = {
    DefaultProvider = "GITHUB",
    APIKeys = {
        PrivateGitHub = "githubapikey",
        CustomAPI = "customapikey"
    },
    CommandPrefix = ","
}

local function authkey(key)
    local rank = AstroKeys.ValidateKey(key)
    if rank then
        local player = game:GetService("Players").LocalPlayer
        AstroKeys.AssignRank(player, key)
    end
end

authkey("your_key_here")
