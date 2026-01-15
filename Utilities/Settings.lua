local Settings = {}
Settings.__index = Settings

function Settings.new(Library, GetAsset, ROE)
    local self = setmetatable({}, Settings)
    
    self.Library = Library
    self.GetAsset = GetAsset or function(assetName)
        return "rbxassetid://12974454446"
    end
    self.ROE = ROE or {}
    
    self.Toggles = {}
    self.Keybinds = {}
    self.Sliders = {}
    
    self.Config = {
        AutoUpdates = true
    }
    
    return self
end

function Settings:Initialize()
    if not self.Library then
        warn("ROE Settings: Library not found")
        return false
    end
    
    self:CreateTab()
    self:LoadConfig()
    self:StartServices()
    
    return true
end

function Settings:CreateTab()
    self.Tab = self.Library:CreateTab("Settings", self.GetAsset("settings"))
    
    self:CreateUISection()
    self:CreateUpdateSection()
    self:CreateConfigSection()
    self:CreateAboutSection()
end

function Settings:CreateUISection()
    local section = self.Tab:CreateSection("UI Settings", "Normal")
    
    self.Keybinds.ToggleUI = section:CreateKeybind({
        Name = "Toggle UI",
        Keybind = "RightControl",
        Type = "Press",
        Flag = "UIToggleKey",
        Callback = function(state)
            if state and self.Library then
                self.Library.Visible = not self.Library.Visible
                self:SaveConfig()
            end
        end
    })
end

function Settings:CreateUpdateSection()
    local section = self.Tab:CreateSection("Updates", "Foldable")
    
    self.Toggles.AutoUpdates = section:CreateToggle("Normal", {
        Name = "Auto Check Updates",
        CurrentValue = self.Config.AutoUpdates,
        Flag = "AutoUpdates",
        Callback = function(value)
            self.Config.AutoUpdates = value
            self:SaveConfig()
            if value then
                self:Notify("Auto Updates", "Updates will be checked automatically", 3)
            end
        end,
    })
    
    section:CreateButton({
        Name = "Check for Updates Now",
        Callback = function()
            self:CheckForUpdates()
        end
    })
end

function Settings:CreateConfigSection()
    local section = self.Tab:CreateSection("Configuration", "Foldable")
    
    section:CreateButton({
        Name = "Save Configuration",
        Callback = function()
            self:SaveConfig()
            self:Notify("Configuration Saved", "Settings saved to disk", 3)
        end
    })
    
    section:CreateButton({
        Name = "Load Configuration",
        Callback = function()
            if self:LoadConfig() then
                self:Notify("Configuration Loaded", "Settings loaded from disk", 3)
            else
                self:Notify("No Config Found", "No saved configuration found", 3)
            end
        end
    })
    
    section:CreateButton({
        Name = "Reset to Default",
        Callback = function()
            self:ResetToDefault()
            self:Notify("Reset Complete", "All settings reset to default", 3)
        end
    })
end

function Settings:CreateAboutSection()
    local section = self.Tab:CreateSection("About", "Foldable")
    
    local version = self:GetVersion() or "Unknown"
    
    section:CreateCard({
        Title = "ROE Hub",
        Description = "ROE is a premium Roblox script hub delivering optimized, undetected, and high-quality scripts.",
        SecondaryTitle = "Version v" .. version,
        Image = self.GetAsset("roe"),
        Buttons = {
            Discord = {
                Name = "Join Discord",
                Callback = function()
                    self:CopyToClipboard("https://discord.gg/tester", "Discord invite copied to clipboard.")
                end
            },
            GitHub = {
                Name = "Visit GitHub",
                Callback = function()
                    self:CopyToClipboard("https://github.com/SentinelSoftworks/ROE", "GitHub link copied to clipboard")
                end
            }
        }
    })
end

function Settings:Notify(title, content, duration)
    if self.Library and self.Library.Notify then
        self.Library:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3,
            Image = self.GetAsset("clipboard")
        })
    end
end

function Settings:CopyToClipboard(text, message)
    setclipboard(text)
    self:Notify("Link Copied", message, 5)
end

function Settings:GetVersion()
    if isfile("ROE/version.json") then
        local success, content = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("ROE/version.json"))
        end)
        if success and content and content.ROE then
            return content.ROE.version
        end
    end
    return nil
end

function Settings:CheckForUpdates()
    local lv, rv = self:GetVersionInfo()
    
    if rv then
        if not lv or lv.ROE.version ~= rv.ROE.version then
            self.Library:Notify({
                Title = "Update Available",
                Content = "Version " .. rv.ROE.version .. " is available!",
                Duration = 8,
                Image = self.GetAsset("clipboard"),
                Actions = {
                    Update = {
                        Name = "Update",
                        Callback = function()
                            self:Notify("Updating", "Downloading latest version...", 3)
                        end
                    }
                }
            })
        else
            self:Notify("Up to Date", "You have the latest version", 3)
        end
    else
        self:Notify("Update Check Failed", "Could not check for updates", 3)
    end
end

function Settings:GetVersionInfo()
    local lv, rv = nil, nil
    
    if isfile("ROE/version.json") then
        local success, content = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("ROE/version.json"))
        end)
        if success then lv = content end
    end
    
    local content = game:HttpGet("https://raw.githubusercontent.com/SentinelSoftworks/ROE/main/version.json")
    if content then
        local success, data = pcall(game:GetService("HttpService").JSONDecode, game:GetService("HttpService"), content)
        if success then rv = data end
    end
    
    return lv, rv
end

function Settings:SaveConfig()
    local config = {
        Updates = {
            AutoCheck = self.Config.AutoUpdates
        }
    }
    
    if isfolder("ROE") then
        local success, err = pcall(function()
            writefile("ROE/config.json", game:GetService("HttpService"):JSONEncode(config))
        end)
        
        if not success then
            warn("ROE Settings: Failed to save config -", err)
        end
    end
end

function Settings:LoadConfig()
    if isfile("ROE/config.json") then
        local success, config = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("ROE/config.json"))
        end)
        
        if success and config then
            if config.Updates then
                self.Config.AutoUpdates = config.Updates.AutoCheck or true
                if self.Toggles.AutoUpdates then
                    self.Toggles.AutoUpdates:Set(self.Config.AutoUpdates)
                end
            end
            
            return true
        end
    end
    return false
end

function Settings:ResetToDefault()
    self.Config.AutoUpdates = true
    
    if self.Toggles.AutoUpdates then
        self.Toggles.AutoUpdates:Set(true)
    end
    
    if self.Keybinds.ToggleUI then
        self.Keybinds.ToggleUI:Set("RightControl")
    end
    
    self:SaveConfig()
end

function Settings:StartServices()
    task.spawn(function()
        while true do
            task.wait(3600)
            
            if self.Config.AutoUpdates then
                local lv, rv = self:GetVersionInfo()
                
                if rv and (not lv or lv.ROE.version ~= rv.ROE.version) then
                    self.Library:Notify({
                        Title = "Update Available",
                        Content = "Version " .. rv.ROE.version .. " is available!",
                        Duration = 8,
                        Image = self.GetAsset("clipboard"),
                        Actions = {
                            Update = {
                                Name = "Update",
                                Callback = function()
                                    self:Notify("Updating", "Downloading latest version...", 3)
                                end
                            }
                        }
                    })
                end
            end
        end
    end)
end

function Settings:Destroy()
    if self.Tab then
    end
    
    self.Library = nil
    self.GetAsset = nil
    self.ROE = nil
    self.Toggles = {}
    self.Keybinds = {}
    self.Sliders = {}
    self.Config = {}
end

return Settings