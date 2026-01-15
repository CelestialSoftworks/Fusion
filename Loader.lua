repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.GameId ~= 0

if ROE and ROE.IsLoaded then
    warn("ROE is already running!")
    return
end

repeat task.wait() until game:GetService("Players").LocalPlayer

getgenv().ROE = {
    Source = "https://raw.githubusercontent.com/SentinelSoftworks/ROE/main/",
    Games = {
        ["Universal"] = { Name = "Universal", Script = "Games/Universal.lua" },
        ["5041144419"] = { Name = "SCP: Roleplay", Script = "Games/SCP_RP.lua" },
        ["5897938254"] = { Name = "Site 006 Roleplay", Script = "Games/Site_006.lua" }
    },
    IsLoaded = false
}

local function GetFile(File)
    return game:HttpGet(ROE.Source .. File)
end

local function DownloadFiles()
    if not isfolder("ROE") then
        makefolder("ROE")
    end
    
    local success, treeData = pcall(function()
        local response = game:HttpGet("https://api.github.com/repos/SentinelSoftworks/ROE/git/trees/main?recursive=1")
        return game:GetService("HttpService"):JSONDecode(response)
    end)
    
    if not success or not treeData or not treeData.tree then
        warn("Failed to fetch repository tree")
        return loadstring(game:HttpGet(ROE.Source .. "UI/Library.lua"))()
    end
    
    for _, item in pairs(treeData.tree) do
        if item.type == "blob" then
            local path = item.path
            local fullPath = "ROE/" .. path
            
            if not isfile(fullPath) then
                local folder = string.match(fullPath, "(.+)/[^/]+$")
                if folder and not isfolder(folder) then
                    makefolder(folder)
                end
                
                local success2, content = pcall(function()
                    return game:HttpGet(ROE.Source .. path)
                end)
                
                if success2 and content then
                    writefile(fullPath, content)
                else
                    warn("Failed to download: " .. path)
                end
            end
        end
    end
    
    if not isfile("ROE/UI/Library.lua") then
        warn("UI Library not found, downloading directly")
        local success3, content = pcall(function()
            return game:HttpGet(ROE.Source .. "UI/Library.lua")
        end)
        if success3 and content then
            if not isfolder("ROE/UI") then
                makefolder("ROE/UI")
            end
            writefile("ROE/UI/Library.lua", content)
        end
    end
    
    return loadstring(readfile("ROE/UI/Library.lua"))()
end

local function GetAsset(assetName)
    local assetPath = "ROE/Assets/" .. assetName .. ".png"
    if isfile(assetPath) then
        return getcustomasset(assetPath)
    end
    return "rbxassetid://12974454446"
end

local function GetVersion()
    local lv, rv = nil, nil
    
    if isfile("ROE/version.json") then
        local success, content = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("ROE/version.json"))
        end)
        if success then lv = content end
    end
    
    local content = GetFile("version.json")
    if content then
        local success, data = pcall(game:GetService("HttpService").JSONDecode, game:GetService("HttpService"), content)
        if success then rv = data end
    end
    
    return lv, rv
end

local function GetUIP()
    local success, ip = pcall(game.HttpGet, game, "https://api.ipify.org")
    return success and ip or "N/A"
end

local function ValidateKey(key)
    if not key or key == "" then
        return false, "Key cannot be empty"
    end
    
    local userIp = GetUIP()
    
    local success, response = pcall(function()
        return game:HttpGet(string.format("https://work.ink/_api/v2/token/isValid/%s?forbiddenOnFail=1", key))
    end)
    
    if not success then
        return false, "Connection failed"
    end
    
    local success2, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(response)
    end)
    
    if not success2 then
        return false, "Server error"
    end
    
    if data.valid then
        if data.info and data.info.byIp then
            if data.info.byIp == userIp then
                return true, data.info
            else
                return false, "IP mismatch"
            end
        end
        return true, data.info or {}
    else
        return false, "Invalid key"
    end
end

local function CheckKey()
    if not isfile("ROE/SK") then return false, nil end
    
    local SK = readfile("ROE/SK")
    if SK == "" then return false, nil end
    
    return ValidateKey(SK)
end

local function UpdateNotification(UI, rv)
    local window = UI:CreateLibrary("ROE", GetAsset("roe"))
    local updated = false
    
    window:Notify({
        Title = "Update Available",
        Content = "A new update is available. Do you wish to update?",
        Duration = 10,
        Actions = {
            Update = {
                Name = "Update",
                Callback = function()
                    window:Notify({
                        Title = "Updating",
                        Content = "Downloading latest files...",
                        Duration = 3,
                    })
                    
                    local success = pcall(DownloadFiles)
                    
                    if success then
                        window:Notify({
                            Title = "Update Complete",
                            Content = "Updated to v" .. rv.ROE.version,
                            Duration = 5,
                            Image = GetAsset("clipboard"),
                            Actions = {
                                Changelog = {
                                    Name = "Changelog",
                                    Callback = function()
                                        window:Notify({
                                            Title = "v" .. rv.ROE.version .. " Changelog",
                                            Content = rv.ROE.changelog,
                                            Duration = 8,
                                            Image = GetAsset("clipboard")
                                        })
                                    end
                                }
                            }
                        })
                        updated = true
                    else
                        window:Notify({
                            Title = "Update Failed",
                            Content = "Failed to download update",
                            Duration = 5,
                        })
                    end
                    
                    task.wait(1)
                    window:Destroy()
                end
            },
            Skip = {
                Name = "Skip",
                Callback = function()
                    task.wait(0.5)
                    window:Destroy()
                end
            }
        }
    })
    
    repeat task.wait() until not window
    return updated
end

local function LoadScript()
    local gameId = tostring(game.GameId)
    local gameData = ROE.Games[gameId] or ROE.Games.Universal
    
    local success, err = pcall(function()
        local scriptPath = gameData.Script
        local fullPath = "ROE/" .. scriptPath
        
        if not isfile(fullPath) then
            local content = GetFile(scriptPath)
            if content then
                local folder = string.match(fullPath, "(.+)/[^/]+$")
                if folder and not isfolder(folder) then
                    makefolder(folder)
                end
                writefile(fullPath, content)
            else
                return false
            end
        end
        
        return loadstring(readfile(fullPath))()
    end)
    
    if success then
        ROE.IsLoaded = true
        return true
    else
        warn("Failed to load script: " .. tostring(err))
        return false
    end
end

local keyValid, keyInfo = CheckKey()

if not keyValid then
    local UI = DownloadFiles()
    if not UI then
        warn("Failed to load UI library")
        return
    end
    
    local window = UI:CreateLibrary("ROE", GetAsset("roe"))
    local keyTab = window:CreateTab("Key", GetAsset("key"))
    local keySection = keyTab:CreateSection("Key System", "Normal")
    
    keySection:CreateParagraph({
        Title = "Instructions",
        Description = "1. Copy the link below\n2. Get your key from the link\n3. Paste your key below\n4. Click 'Validate Key' to continue"
    })
    
    local currentKey = ""
    local keyValidated = false
    keyInfo = nil
    
    keySection:CreateButton({
        Name = "Copy Link",
        Callback = function()
            setclipboard("https://work.ink/2cMY/24h-key-roe-key-system")
            UI:Notify({Normal,
                Title = "Link Copied",
                Content = "Key link copied",
                Duration = 4,
                Image = GetAsset("clipboard")
            })
        end
    })
    
    keySection:CreateTextbox({
        Name = "Enter Key",
        PlaceholderText = "Paste key here...",
        Callback = function(text)
            currentKey = text
        end
    })
    
    keySection:CreateButton({
        Name = "Validate Key",
        Callback = function()
            local valid, infoOrError = ValidateKey(currentKey)
            
            if valid then
                if not isfolder("ROE") then
                    makefolder("ROE")
                end
                writefile("ROE/SK", currentKey)
                keyValidated = true
                keyInfo = infoOrError
                
                window:Notify({
                    Title = "Success",
                    Content = "Key validated",
                    Duration = 3,
                    Image = GetAsset("roe")
                })
                
                task.wait(2)
                window:Destroy()
            else
                window:Notify({
                    Title = "Failed",
                    Content = infoOrError,
                    Duration = 5,
                    Image = GetAsset("roe")
                })
            end
        end
    })
    
    local startTime = tick()
    repeat 
        task.wait() 
        if tick() - startTime > 120 then
            window:Destroy()
            warn("Key validation timeout")
            return
        end
    until keyValidated or not window
    
    if not keyValidated then return end
end

local lv, rv = GetVersion()

if rv and (not lv or lv.ROE.version ~= rv.ROE.version) then
    local UI = DownloadFiles()
    if UI then
        UpdateNotification(UI, rv)
    end
end

LoadScript()