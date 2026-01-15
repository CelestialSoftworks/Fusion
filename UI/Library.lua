local a = "Alpha 0.1"
local b = 5
local c = "AuraIS"
local Configurations = c .. "/Configurations/"
local Assets = c .. "/Assets/"

local Configuration = {
	Toggles = {},
	Dropdowns = {},
	Sliders = {},
	Keybinds = {},
}

local GetService = game.GetService
local UserInputService = GetService(game, "UserInputService")
local TweenService = GetService(game, "TweenService")
local HttpService = GetService(game, "HttpService")
local RunService = GetService(game, "RunService")
local Players = GetService(game, "Players")
local CoreGui = cloneref(GetService(game, "CoreGui"))
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local IsMobile = table.find({
	Enum.Platform.IOS,
	Enum.Platform.Android,
}, UserInputService:GetPlatform())

if not isfolder(c) then
	makefolder(c)
end
if not isfolder(Configurations) then
	makefolder(Configurations)
end
if not isfolder(Assets) then
	makefolder(Assets)
end

local FilePath = Configurations .. "UI.json"
if not isfile(FilePath) then
	writefile(FilePath, HttpService:JSONEncode(Configuration))
else
	local Content = readfile(FilePath)
	local Success, Decoded = pcall(HttpService.JSONDecode, HttpService, Content)
	if Success then
		Configuration = Decoded
	end
end

local function SaveConfiguration()
	writefile(FilePath, HttpService:JSONEncode(Configuration))
end

if not isfile(Assets .. "click.ogg") then
	local Success, Content = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/SentinelSoftworks/ROE/refs/heads/main/UI/Assets/click.ogg")
	if Success and Content then
		writefile(Assets .. "click.ogg", Content)
	end
end

local ClickSound = Instance.new("Sound")
ClickSound.SoundId = getcustomasset(Assets .. "click.ogg")
ClickSound.Volume = 0.5
ClickSound.Parent = workspace

local function PlayClick()
	if isfile(Assets .. "click.ogg") then
		ClickSound:Play()
	end
end

local e = {
	Theme = {
		Dark = {
			TextColor = Color3.fromRGB(240, 240, 240),
			MainColor = Color3.fromRGB(16, 16, 16),
			SecondaryColor = Color3.fromRGB(22, 22, 22),
			NotificationActionsBackground = Color3.fromRGB(230, 230, 230),
			ImageColor = Color3.fromRGB(255, 255, 255),
			TabBackground = Color3.fromRGB(80, 80, 80),
			TabStroke = Color3.fromRGB(85, 85, 85),
			TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
			TabTextColor = Color3.fromRGB(240, 240, 240),
			SelectedTabTextColor = Color3.fromRGB(50, 50, 50),
			SliderColor = Color3.fromRGB(170, 0, 255),
			ToggleEnabled = Color3.fromRGB(170, 0, 255),
			ToggleDisabled = Color3.fromRGB(139, 139, 139),
			CardButton = Color3.fromRGB(230, 230, 230),
			TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint)
		}
	}
}

local f = tostring(math.random(1, 100)) .. tostring(math.random(1, 50)) .. tostring(math.random(1, 100))

function e:DragFunc(g, h)
	h = h or g
	local i = false
	local j, k, l
	g.InputBegan:Connect(function(m)
		if m.UserInputType == Enum.UserInputType.MouseButton1 or m.UserInputType == Enum.UserInputType.Touch then
			i = true
			k = m.Position
			l = h.Position
			m.Changed:Connect(function()
				if m.UserInputState == Enum.UserInputState.End then
					i = false
				end
			end)
		end
	end)
	g.InputChanged:Connect(function(m)
		if m.UserInputType == Enum.UserInputType.MouseMovement or m.UserInputType == Enum.UserInputType.Touch then
			j = m
		end
	end)
	UserInputService.InputChanged:Connect(function(m)
		if m == j and i then
			local n = m.Position - k
			h.Position = UDim2.new(l.X.Scale, l.X.Offset + n.X, l.Y.Scale, l.Y.Offset + n.Y)
		end
	end)
end

local w = game:GetObjects("rbxassetid://115427779398440")[1]
w.Name = f
w.Main.Visible = false
w.DisplayOrder = 100

if not isfile(Assets .. "0001.png") then
    local Success, Content = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/SentinelSoftworks/ROE/refs/heads/main/UI/Assets/ad.mp4")
    if Success and Content then writefile(Assets .. "0001.png", Content) end
end

w.Main.Advertisement.Image.Image = getcustomasset(Assets .. "0001.png")

if gethui then
	w.Parent = gethui()
else
	w.Parent = CoreGui
end

function e:ToggleUI()
	w.Main.Visible = not w.Main.Visible
end

function e:Notify(x, y)
	task.spawn(function()
		local z = y.Duration or b
		local A = w.Notifications[x]:Clone()
		A.Parent = w.Notifications
		A.Name = y.Title or "Unknown Title"
		A.Visible = true
		A.Actions.ButtonTemplate.Visible = false
		if y.Actions then
			for B, C in next, y.Actions do
				local D = A.Actions.ButtonTemplate:Clone()
				D.Name = C.Name
				D.Visible = true
				D.Parent = A.Actions
				D.Text = C.Name
				D.Size = UDim2.new(0, D.TextBounds.X + 27, 1, 0)
				D.MouseButton1Click:Connect(function()
					PlayClick()
					local E, F = pcall(C.Callback)
				end)
			end
		end
		A.Title.Text = y.Title or "Unknown"
		A.Description.Text = y.Content or "Unknown"
		if y.Image then
			A.Icon.Image = y.Image
		end
		while z >= 0 do
			A.Duration.Text = z
			task.wait(1)
			z = z - 1
		end
		A:Destroy()
	end)
end

function e:CreateLibrary(G, H)
	local I = {
		Name = typeof(G) == "table" and G.Name or (typeof(G) == "string" and G or "Undefined"),
		Icon = typeof(G) == "table" and G.Icon or H or "rbxassetid://11432865001"
	}
	
	w.Main.Visible = true
	local J = w.Main.SideBar
	local K = J.Buttons
	local L = w.Main.TabContainer
	
	J.NameText.Text = I.Name
	J.Icon.Image = I.Icon
	
	e:DragFunc(J, w.Main)
	
	if w:FindFirstChild("OpenButton") then
		w.OpenButton.Icon.Image = I.Icon
		w.OpenButton.Visible = IsMobile
		
		e:DragFunc(w.OpenButton)
		w.OpenButton.MouseButton1Click:Connect(function()
			e:ToggleUI()
		end)
	end
	
	K.Parent.Minimize.MouseButton1Click:Connect(function()
		PlayClick()
		if K.Parent.Minimize.Rotation == 0 then
			TweenService:Create(K.Parent.Minimize, e.Theme.Dark.TweenInfo, {Rotation = 180}):Play()
			TweenService:Create(K.Parent, e.Theme.Dark.TweenInfo, {Size = UDim2.new(0, 147, 1, 0)}):Play()
			TweenService:Create(L, e.Theme.Dark.TweenInfo, {Size = UDim2.new(0, 349, 0, 326)}):Play()
			TweenService:Create(L, e.Theme.Dark.TweenInfo, {Position = UDim2.new(0.305, 0, 0.021, 0)}):Play()
		else
			TweenService:Create(K.Parent.Minimize, e.Theme.Dark.TweenInfo, {Rotation = 0}):Play()
			TweenService:Create(K.Parent, e.Theme.Dark.TweenInfo, {Size = UDim2.new(0, 55, 1, 0)}):Play()
			TweenService:Create(L, e.Theme.Dark.TweenInfo, {Size = UDim2.new(0, 439, 0, 326)}):Play()
			TweenService:Create(L, e.Theme.Dark.TweenInfo, {Position = UDim2.new(0.13, 0, 0.021, 0)}):Play()
		end
	end)
	
	local M = {}
	
	function M:Notify(y, N, O, P)
		task.spawn(function()
			w.Main.Notifications.Visible = true
			local z = typeof(y) == "table" and y.Duration or O or b
			local A = w.Main.Notifications.Template:Clone()
			A.Parent = w.Main.Notifications
			A.Duration.Text = z
			A.Visible = true
			
			for Q, R in next, A.Actions:GetChildren() do
				if R.Name ~= "ButtonTemplate" and not R:IsA("UIListLayout") then
					R:Destroy()
				end
			end
			
			A.Actions.ButtonTemplate.Visible = false
			
			if typeof(y) == "table" and y.Actions or P then
				for B, C in next, (typeof(y) == "table" and y.Actions or P) do
					local D = A.Actions.ButtonTemplate:Clone()
					D.Name = C.Name
					D.Visible = true
					D.Parent = A.Actions
					D.Text = C.Name
					D.Size = UDim2.new(0, D.TextBounds.X + 27, 1, 0)
					D.MouseButton1Click:Connect(function()
						PlayClick()
						local E, F = pcall(C.Callback)
					end)
				end
			end
			
			A.Title.Text = typeof(y) == "table" and y.Title or y or "Unknown"
			A.Description.Text = typeof(y) == "table" and y.Content or N or "Unknown"
			
			while z >= 0 do
				A.Duration.Text = z
				task.wait(1)
				z = z - 1
			end
			
			A:Destroy()
			w.Main.Notifications.Visible = false
		end)
	end
	
	local FirstTabCreated = false
	local FirstTab = nil
	
	function M:SwitchTab(tabName)
		if tabName then
			for B, tab in next, L:GetChildren() do
				if tab.Name == tabName and tab:IsA("Frame") then
					L.UIPageLayout:JumpTo(tab)
					break
				end
			end
		else
			if FirstTab then
				for B, tab in next, L:GetChildren() do
					if tab.Name == FirstTab and tab:IsA("Frame") then
						L.UIPageLayout:JumpTo(tab)
						break
					end
				end
			end
		end
	end
	
	function M:CreateTab(S, H)
		if not S then return end
		
		local T = K.Template:Clone()
		T.ImageLabel.Image = typeof(S) == "table" and S.Icon or H or "rbxassetid://11432859220"
		T.TextLabel.Text = typeof(S) == "table" and S.Title or S or "Unknown"
		T.Visible = true
		T.Parent = K
		
		local U = L.Template:Clone()
		U.Parent = L
		U.Name = typeof(S) == "table" and S.Title or S or "Unknown"
		U.Visible = true
		U.LayoutOrder = #L:GetChildren()
		
		for B, V in next, U:GetChildren() do
			if V.ClassName == "Frame" then
				V:Destroy()
			end
		end
		
		if not FirstTabCreated then
			FirstTabCreated = true
			FirstTab = U.Name
			L.UIPageLayout:JumpTo(U)
		end
		
		T.MouseButton1Click:Connect(function()
			if L.UIPageLayout.CurrentPage ~= U then
				L.UIPageLayout:JumpTo(U)
			end
		end)
		
		local X = {}
		
		function X:CreateSection(Y, Z)
			local _ = {}
			local a0
			
			if Z == "Normal" then
				a0 = L.Template.SectionTitle:Clone()
				a0.Name = Y
				a0.Title.Text = Y
				a0.Visible = true
				a0.Parent = U
			elseif Z == "Foldable" then
				a0 = L.Template.FoldableSectionTitle:Clone()
				a0.Name = Y
				a0.Title.Text = Y
				a0.Visible = true
				a0.Parent = U
			end
			
			a0.Title.TextTransparency = 1
			TweenService:Create(a0.Title, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
			
			function _:SetName(a1)
				a0.Title.Text = a1
			end
			
			local function a2()
				local a3 = a0.UIListLayout.AbsoluteContentSize
				a0.Size = UDim2.new(1, 0, 0, a3.Y)
			end
			
			if Z == "Foldable" then
				local a4 = true
				a0.Title.TextButton.MouseButton1Click:Connect(function()
					if a4 then
						a4 = false
						for B, R in next, a0:GetChildren() do
							if R.Name ~= "UIListLayout" and R.Name ~= "UIPadding" and not R:IsA("TextLabel") then
								R.Visible = false
							end
						end
					else
						a4 = true
						for B, R in next, a0:GetChildren() do
							if R.Name ~= "UIListLayout" and R.Name ~= "UIPadding" and not R:IsA("TextLabel") then
								R.Visible = true
							end
						end
					end
					a2()
				end)
			end
			
			function _:Remove()
				if a0 then
					a0:Destroy()
					a0 = nil
				end
			end
			
			function _:CreateButton(a5)
				local a6 = {Func = a5.Callback}
				local a7 = L.Template.Button:Clone()
				a7.Name = a5.Name or "Undefined"
				a7.Title.Text = a5.Name or "Undefined"
				a7.Visible = true
				a7.Parent = a0
				a2()
				
				a7.Interact.MouseButton1Click:Connect(function()
					PlayClick()
					local a8, a9 = pcall(a6.Func)
					if not a8 then
						local aa = a7.Size
						TweenService:Create(a7, e.Theme.Dark.TweenInfo, {Size = UDim2.new(0.992, -10, 0, 35)}):Play()
						TweenService:Create(a7, e.Theme.Dark.TweenInfo, {BackgroundColor3 = Color3.fromRGB(103, 0, 0)}):Play()
						a7.Title.Text = "Error occurred"
						print("[AuraIS]: An error occurred: " .. tostring(a9))
						task.wait(0.5)
						a7.Title.Text = a5.Name
						TweenService:Create(a7, e.Theme.Dark.TweenInfo, {Size = aa}):Play()
						TweenService:Create(a7, e.Theme.Dark.TweenInfo, {BackgroundColor3 = e.Theme.Dark.SecondaryColor}):Play()
					else
						local aa = a7.Size
						TweenService:Create(a7, e.Theme.Dark.TweenInfo, {Size = UDim2.new(0.992, -10, 0, 35)}):Play()
						task.wait(0.2)
						TweenService:Create(a7, e.Theme.Dark.TweenInfo, {Size = aa}):Play()
					end
				end)
				
				function a6:SetCallback(ab)
					a6.Func = ab
				end
				
				function a6:Remove()
					if a7 then
						a7:Destroy()
						a7 = nil
						a2()
					end
				end
				
				function a6:SetName(ac)
					a7.Title.Text = ac
					a7.Name = ac
				end
				
				return a6
			end
			
			function _:CreateDivider()
				local div = L.Template.Divider:Clone()
				div.Visible = true
				div.Parent = a0
				a2()
				return div
			end
			
			function _:CreateToggle(ad, ae)
				local af = {}
				local Flag = ae.Flag
				local CurrentValue = Flag and Configuration.Toggles[Flag] or ae.CurrentValue
				
				if Flag and Configuration.Toggles[Flag] == nil then
					Configuration.Toggles[Flag] = CurrentValue
					SaveConfiguration()
				end
				
				local ag
				if ad == "Radio" then
					ag = L.Template.Toggle_Radio:Clone()
				else
					ag = L.Template.Toggle:Clone()
				end
				
				local ah = ag.Interact
				local ai = ag.Switch
				local aj = ai.Indicator
				
				ag.Name = ae.Name
				ag.Title.Text = ae.Name
				ag.Visible = true
				ag.Parent = a0
				
				local function UpdateToggle(value)
					if Flag then
						Configuration.Toggles[Flag] = value
						SaveConfiguration()
					end
					
					if ad == "Radio" then
						aj.BackgroundTransparency = value and 0 or 1
					else
						TweenService:Create(aj, e.Theme.Dark.TweenInfo, {
							BackgroundColor3 = value and e.Theme.Dark.ToggleEnabled or e.Theme.Dark.ToggleDisabled,
							Position = value and UDim2.new(0.537, 0, 0.5, 0) or UDim2.new(0.07, 0, 0.5, 0)
						}):Play()
					end
					
					local success, err = pcall(function()
						ae.Callback(value)
					end)
					
					if not success then
						TweenService:Create(ag, e.Theme.Dark.TweenInfo, {BackgroundColor3 = Color3.fromRGB(103, 0, 0)}):Play()
						ag.Title.Text = "Error occurred"
						print("[AuraIS]: An error occurred: " .. tostring(err))
						task.wait(0.5)
						ag.Title.Text = ae.Name
						TweenService:Create(ag, e.Theme.Dark.TweenInfo, {BackgroundColor3 = e.Theme.Dark.SecondaryColor}):Play()
					end
					
					ae.CurrentValue = value
				end
				
				if ad == "Radio" then
					aj.BackgroundTransparency = 1
					aj.BackgroundColor3 = e.Theme.Dark.ToggleEnabled
					if CurrentValue then
						UpdateToggle(CurrentValue)
					end
					
					ag.Interact.MouseButton1Click:Connect(function()
						PlayClick()
						UpdateToggle(not ae.CurrentValue)
					end)
					
					ae.SetToggle = UpdateToggle
				else
					if CurrentValue then
						UpdateToggle(CurrentValue)
					end
					
					ag.Interact.MouseButton1Click:Connect(function()
						PlayClick()
						UpdateToggle(not ae.CurrentValue)
					end)
					
					ag.MouseEnter:Connect(function()
						TweenService:Create(ag, e.Theme.Dark.TweenInfo, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
						TweenService:Create(ag, e.Theme.Dark.TweenInfo, {Size = UDim2.new(1.011, -10, 0, 40)}):Play()
					end)
					
					ag.MouseLeave:Connect(function()
						TweenService:Create(ag, e.Theme.Dark.TweenInfo, {BackgroundColor3 = e.Theme.Dark.SecondaryColor}):Play()
						TweenService:Create(ag, e.Theme.Dark.TweenInfo, {Size = UDim2.new(1, -10, 0, 40)}):Play()
					end)
					
					ae.SetToggle = UpdateToggle
				end
				
				a2()
				return ae
			end
			
			function _:CreateKeybind(Data)
				local Keybind = L.Template.Keybind:Clone()
				local Flag = Data.Flag
				local KeybindSelected = Flag and Configuration.Keybinds[Flag] or Data.Keybind or "..."
				
				if Flag and not Configuration.Keybinds[Flag] then
					Configuration.Keybinds[Flag] = KeybindSelected
					SaveConfiguration()
				end
				
				Keybind.Name = Data.Name
				Keybind.Title.Text = Data.Name
				Keybind.KeybindFrame.KeybindBox.Text = KeybindSelected
				Keybind.Visible = true
				Keybind.Parent = a0
				
				local AdditionalData = {
					Deciding = false,
					Enabled = false,
				}
				
				Keybind.KeybindFrame.KeybindBox.MouseButton1Click:Connect(function()
					PlayClick()
					AdditionalData.Deciding = true
					Keybind.KeybindFrame.KeybindBox.Text = "..."
					
					local connection
					connection = UserInputService.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.Keyboard then
							AdditionalData.Deciding = false
							KeybindSelected = input.KeyCode.Name
							Keybind.KeybindFrame.KeybindBox.Text = KeybindSelected
							
							if Flag then
								Configuration.Keybinds[Flag] = KeybindSelected
								SaveConfiguration()
							end
							
							connection:Disconnect()
						end
					end)
				end)
				
				if Data.Type == "Press" then
					UserInputService.InputBegan:Connect(function(input)
						if KeybindSelected == "..." then return end
						if input.KeyCode == Enum.KeyCode[KeybindSelected] then
							AdditionalData.Enabled = not AdditionalData.Enabled
							task.spawn(function()
								Data.Callback(AdditionalData.Enabled)
							end)
						end
					end)
				elseif Data.Type == "Hold" then
					UserInputService.InputBegan:Connect(function(input)
						if KeybindSelected == "..." then return end
						if input.KeyCode == Enum.KeyCode[KeybindSelected] then
							AdditionalData.Enabled = true
						end
					end)
					
					UserInputService.InputEnded:Connect(function(input)
						if KeybindSelected == "..." then return end
						if input.KeyCode == Enum.KeyCode[KeybindSelected] then
							AdditionalData.Enabled = false
						end
					end)
					
					RunService.RenderStepped:Connect(function()
						if AdditionalData.Enabled then
							task.spawn(function()
								Data.Callback(true)
							end)
						end
					end)
				end
				
				a2()
				
				local KeybindObj = {}
				function KeybindObj:Set(key)
					KeybindSelected = key
					Keybind.KeybindFrame.KeybindBox.Text = key
					if Flag then
						Configuration.Keybinds[Flag] = key
						SaveConfiguration()
					end
				end
				
				return KeybindObj
			end
			
			function _:CreateColorPicker(ak)
				local al = L.Template.ColorPicker:Clone()
				local am = al.Switch
				local an = al["RGB"]
				local ao = al.Color
				local ap = ao.SliderPoint
				local aq = al.Darkness
				local ar = aq.SliderPoint
				al.Name = ak.Name
				al.Title.Text = ak.Name
				al.Visible = true
				al.Parent = a0
				local as = {1, 1, 1}
				local at = false
				local au = false
				local av
				local aw = ak.Callback
				a2()
				local function ax(ay)
					return math.acos(math.cos(ay * math.pi)) / math.pi
				end
				counter = 0
				local function az()
					return Player:GetMouse()
				end
				local function aA()
					if at then
						local aB = math.clamp(Mouse.X - ao.AbsolutePosition.X, 0, ao.AbsoluteSize.X)
						local aC = math.clamp(Mouse.Y - ao.AbsolutePosition.Y, 0, ao.AbsoluteSize.Y)
						local aD = math.floor(ao.AbsoluteSize.X)
						local aE = math.floor(ao.AbsoluteSize.Y)
						if aB < 0 then aB = 0 end
						if aB > aD then aB = aD end
						if aC < 0 then aC = 0 end
						if aC > aE then aC = aE end
						aB = aB / aD
						aC = aC / aE
						local aF = ap.AbsoluteSize.X / 2
						local aG = ap.AbsoluteSize.Y / 2
						ap.Position = UDim2.new(math.min(aB, 1 - aF / aD), 0, math.min(aC, 1 - aG / aE), 0)
						as = {1 - aB, 1 - aC, as[3]}
						local aH = Color3.fromHSV(as[1], as[2], as[3])
						aw(aH)
					end
					if au then
						local aI = az()
						local aC = aI.Y - aq.AbsolutePosition.Y
						local aE = math.floor(ao.AbsoluteSize.Y) - 1
						if aC < 0 then aC = 0 end
						if aC > aE then aC = aE end
						aC = aC / aE
						local aG = ar.AbsoluteSize.Y / 2
						ar.Position = UDim2.new(0.5, 0, math.min(aC, 1 - aG / aE), 0)
						ar.ImageColor3 = Color3.fromHSV(0, 0, aC)
						as = {as[1], as[2], 1 - aC}
						local aH = Color3.fromHSV(as[1], as[2], as[3])
						aw(aH)
					end
				end
				local function aJ(aK)
					local aF = ap.AbsoluteSize.X / 2
					local aG = ap.AbsoluteSize.Y / 2
					as = {aK[1], aK[2], aK[3]}
					ap.Position = UDim2.new(as[1], -aF, as[2] - 1, -aG)
					ar.Position = UDim2.new(0.5, 0, as[3] - 1, -aG)
					local aH = Color3.fromHSV(as[1], as[2], as[3])
				end
				local function aL(aK)
					local aD = math.floor(ao.AbsoluteSize.X)
					local aE = math.floor(ao.AbsoluteSize.Y)
					local aF = ap.AbsoluteSize.X / 2
					local aG = ap.AbsoluteSize.Y / 2
					as = {aK[1], aK[2], as[3]}
					ap.Position = UDim2.new(math.min(as[1], 1 - aF / aE), 0, math.min(as[2] - 1, 1 - aG / aE))
					local aH = Color3.fromHSV(as[1], as[2], as[3])
					aw(aH)
				end
				local function aM()
					if rainbow then
						TweenService:Create(am.Indicator, e.Theme.Dark.TweenInfo, {BackgroundTransparency = 1}):Play()
						rainbow = false
						av:Disconnect()
					else
						TweenService:Create(am.Indicator, e.Theme.Dark.TweenInfo, {BackgroundTransparency = 0}):Play()
						rainbow = true
						av = RunService.RenderStepped:Connect(function()
							aL({ax(counter), 1, 1})
							counter = counter + 0.01
						end)
					end
				end
				am:FindFirstChildWhichIsA("TextButton").MouseButton1Click:Connect(function()
					PlayClick()
					aM()
				end)
				Mouse.Move:Connect(aA)
				ao.MouseButton1Down:Connect(function()
					PlayClick()
					at = true
				end)
				aq.MouseButton1Down:Connect(function()
					PlayClick()
					au = true
				end)
				UserInputService.InputEnded:Connect(function(m)
					if m.UserInputType == Enum.UserInputType.MouseButton1 or m.UserInputType == Enum.UserInputType.Touch then
						if au then au = false end
						if at then at = false end
					end
				end)
				return ak
			end
			
			function _:CreateSlider(aN)
				local aO = false
				local aP = L.Template.Slider:Clone()
				local Flag = aN.Flag
				local CurrentValue = Flag and Configuration.Sliders[Flag] or aN.CurrentValue
				
				if Flag and not Configuration.Sliders[Flag] then
					Configuration.Sliders[Flag] = CurrentValue
					SaveConfiguration()
				end
				
				aP.Name = aN.Name
				aP.Title.Text = aN.Name
				aP.Title.TextScaled = false
				aP.Visible = true
				aP.Parent = a0
				a2()
				aP.Main.Progress.Size = UDim2.new(0, aP.Main.AbsoluteSize.X * (CurrentValue + aN.Value[1]) / (aN.Value[2] - aN.Value[1]) > 5 and aP.Main.AbsoluteSize.X * CurrentValue / (aN.Value[2] - aN.Value[1]) or 5, 1, 0)
				aP.Main.Progress.BackgroundColor3 = e.Theme.Dark.SliderColor
				
				if not aN.Suffix then
					aP.Main.Information.Text = tostring(CurrentValue)
				else
					aP.Main.Information.Text = tostring(CurrentValue) .. " " .. aN.Suffix
				end
				
				aP.Main.Interact.InputBegan:Connect(function(aQ)
					if aQ.UserInputType == Enum.UserInputType.MouseButton1 or aQ.UserInputType == Enum.UserInputType.Touch then
						PlayClick()
						aO = true
					end
				end)
				
				aP.Main.Interact.InputEnded:Connect(function(aQ)
					if aQ.UserInputType == Enum.UserInputType.MouseButton1 or aQ.UserInputType == Enum.UserInputType.Touch then
						aO = false
					end
				end)
				
				aP.Main.Interact.MouseButton1Down:Connect(function(ay)
					local aR = aP.Main.Progress.AbsolutePosition.X + aP.Main.Progress.AbsoluteSize.X
					local aS = aR
					local aT = ay
					local aU
					aU = RunService.Stepped:Connect(function()
						if aO then
							aT = UserInputService:GetMouseLocation().X
							aR = aT
							if aT < aP.Main.AbsolutePosition.X then
								aT = aP.Main.AbsolutePosition.X
							elseif aT > aP.Main.AbsolutePosition.X + aP.Main.AbsoluteSize.X then
								aT = aP.Main.AbsolutePosition.X + aP.Main.AbsoluteSize.X
							end
							if aR < aP.Main.AbsolutePosition.X + 5 then
								aR = aP.Main.AbsolutePosition.X + 5
							elseif aR > aP.Main.AbsolutePosition.X + aP.Main.AbsoluteSize.X then
								aR = aP.Main.AbsolutePosition.X + aP.Main.AbsoluteSize.X
							end
							if aR <= aT and aT - aS < 0 then
								aS = aT
							elseif aR >= aT and aT - aS > 0 then
								aS = aT
							end
							aP.Main.Progress.Size = UDim2.new(0, aR - aP.Main.AbsolutePosition.X, 1, 0)
							local aV = aN.Value[1] + (aT - aP.Main.AbsolutePosition.X) / aP.Main.AbsoluteSize.X * (aN.Value[2] - aN.Value[1])
							aV = math.floor(aV / aN.Increment + 0.5) * aN.Increment * 10000000 / 10000000
							if not aN.Suffix then
								aP.Main.Information.Text = tostring(aV)
							else
								aP.Main.Information.Text = tostring(aV) .. " " .. aN.Suffix
							end
							if CurrentValue ~= aV then
								if Flag then
									Configuration.Sliders[Flag] = aV
									SaveConfiguration()
							 end
								local E, F = pcall(function()
									aN.Callback(aV)
								end)
								CurrentValue = aV
							end
						else
							aP.Main.Progress.Size = UDim2.new(0, aT - aP.Main.AbsolutePosition.X > 5 and aT - aP.Main.AbsolutePosition.X or 5, 1, 0)
							aU:Disconnect()
						end
					end)
				end)
				
				function aN:Set(aW)
					aP.Main.Progress.Size = UDim2.new(0, aP.Main.AbsoluteSize.X * (aW + aN.Value[1]) / (aN.Value[2] - aN.Value[1]) > 5 and aP.Main.AbsoluteSize.X * aW / (aN.Value[2] - aN.Value[1]) or 5, 1, 0)
					aP.Main.Information.Text = tostring(aW) .. " " .. aN.Suffix
					local E, F = pcall(function()
						aN.Callback(aW)
					end)
					CurrentValue = aW
					if Flag then
						Configuration.Sliders[Flag] = CurrentValue
						SaveConfiguration()
					end
				end
				
				return aN
			end
			
			function _:CreateDropdown(aX)
				local aY = L.Template.Dropdown:Clone()
				local Flag = aX.Flag
				local CurrentOption = Flag and Configuration.Dropdowns[Flag] or aX.CurrentOption
				
				if Flag and not Configuration.Dropdowns[Flag] then
					Configuration.Dropdowns[Flag] = CurrentOption
					SaveConfiguration()
				end
				
				if string.find(aX.Name, "closed") then
					aY.Name = "Dropdown"
				else
					aY.Name = aX.Name
				end
				aY.Title.Text = aX.Name
				aY.Visible = true
				aY.Parent = a0
				aY.Size = UDim2.new(1, -10, 0, 45)
				aY.List.Visible = false
				
				if typeof(CurrentOption) == "string" then
					CurrentOption = {CurrentOption}
				end
				if not aX.MultipleOptions then
					CurrentOption = {CurrentOption[1]}
				end
				
				if aX.MultipleOptions then
					if #CurrentOption == 1 then
						aY.Selected.Text = CurrentOption[1]
					elseif #CurrentOption == 0 then
						aY.Selected.Text = "None"
					else
						aY.Selected.Text = #CurrentOption .. " item" .. (#CurrentOption > 1 and "s" or "")
					end
				else
					aY.Selected.Text = CurrentOption[1]
				end
				
				aY.BackgroundTransparency = 1
				aY.UIStroke.Transparency = 1
				aY.Title.TextTransparency = 1
				aY.Size = UDim2.new(1, -10, 0, 45)
				a2()
				
				TweenService:Create(aY, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
				TweenService:Create(aY.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
				TweenService:Create(aY.Title, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
				
				for B, aZ in next, aY.List:GetChildren() do
					if aZ.ClassName == "Frame" and aZ.Name ~= "Placeholder" then
						aZ:Destroy()
					end
				end
				
				aY.Interact.MouseButton1Click:Connect(function()
					PlayClick()
					if Debounce then return end
					
					if aY.List.Visible then
						Debounce = true
						TweenService:Create(aY, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(1, -10, 0, 45)}):Play()
						
						for B, b2 in next, aY.List:GetChildren() do
							if b2.ClassName == "Frame" and b2.Name ~= "Placeholder" then
								TweenService:Create(b2, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
								TweenService:Create(b2.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
								TweenService:Create(b2.Title, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
							end
						end
						
						TweenService:Create(aY.Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Rotation = 180}):Play()
						task.wait(0.35)
						aY.List.Visible = false
						Debounce = false
					else
						aY.List.Visible = true
						TweenService:Create(aY, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(1, -10, 0, 180)}):Play()
						TweenService:Create(aY.Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Rotation = 0}):Play()
						
						for B, b2 in next, aY.List:GetChildren() do
							if b2.ClassName == "Frame" and b2.Name ~= "Placeholder" then
								TweenService:Create(b2, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
								TweenService:Create(b2.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
								TweenService:Create(b2.Title, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
							end
						end
					end
				end)
				
				for B, b3 in next, aX.Options do
					local b4 = L.Template.Dropdown.List.Template:Clone()
					b4.Name = b3
					b4.Title.Text = b3
					b4.Parent = aY.List
					b4.Visible = true
					
					if table.find(CurrentOption, b3) then
						b4.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
					end
					
					b4.MouseEnter:Connect(function()
						TweenService:Create(b4, e.Theme.Dark.TweenInfo, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
						TweenService:Create(b4, e.Theme.Dark.TweenInfo, {Size = UDim2.new(0.921, 0, 0, 38)}):Play()
					end)
					
					b4.MouseLeave:Connect(function()
						TweenService:Create(b4, e.Theme.Dark.TweenInfo, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
						TweenService:Create(b4, e.Theme.Dark.TweenInfo, {Size = UDim2.new(0.921, 0, 0, 38)}):Play()
					end)
					
					b4.Interact.MouseButton1Click:Connect(function()
						PlayClick()
						if not aX.MultipleOptions and table.find(CurrentOption, b3) then
							return
						end
						
						if table.find(CurrentOption, b3) then
							table.remove(CurrentOption, table.find(CurrentOption, b3))
						else
							if not aX.MultipleOptions then
								table.clear(CurrentOption)
							end
							table.insert(CurrentOption, b3)
						end
						
						if aX.MultipleOptions then
							if #CurrentOption == 1 then
								aY.Selected.Text = CurrentOption[1]
							elseif #CurrentOption == 0 then
								aY.Selected.Text = "None"
							else
								aY.Selected.Text = #CurrentOption .. " item" .. (#CurrentOption > 1 and "s" or "")
							end
						else
							aY.Selected.Text = CurrentOption[1]
						end
						
						if Flag then
							Configuration.Dropdowns[Flag] = aX.MultipleOptions == false and CurrentOption[1] or CurrentOption
							SaveConfiguration()
						end
						
						local E, F = pcall(function()
							aX.Callback(aX.MultipleOptions == false and CurrentOption[1] or CurrentOption)
						end)
						
						for B, b6 in next, aY.List:GetChildren() do
							if b6.ClassName == "Frame" and b6.Name ~= "Placeholder" then
								if table.find(CurrentOption, b6.Name) then
									b6.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
								else
									b6.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
								end
							end
						end
					end)
				end
				
				function aX:Set(b7)
					CurrentOption = b7
					if typeof(CurrentOption) == "string" then
						CurrentOption = {CurrentOption}
					end
					if not aX.MultipleOptions then
						CurrentOption = {CurrentOption[1]}
					end
					
					if aX.MultipleOptions then
						if #CurrentOption == 1 then
							aY.Selected.Text = CurrentOption[1]
						elseif #CurrentOption == 0 then
							aY.Selected.Text = "None"
						else
							aY.Selected.Text = #CurrentOption .. " item" .. (#CurrentOption > 1 and "s" or "")
						end
					else
						aY.Selected.Text = CurrentOption[1]
					end
					
					if Flag then
						Configuration.Dropdowns[Flag] = aX.MultipleOptions == false and CurrentOption[1] or CurrentOption
						SaveConfiguration()
					end
					
					local E, F = pcall(function()
						aX.Callback(b7)
					end)
				end
				
				return aX
			end
			
			function _:CreateTextbox(b8)
				local aQ = L.Template.Input:Clone()
				local CurrentValue = ""
				
				aQ.Name = b8.Name
				aQ.Title.Text = b8.Name
				aQ.Visible = true
				aQ.Parent = a0
				
				aQ.InputFrame.InputBox.Text = CurrentValue
				aQ.InputFrame.InputBox.PlaceholderText = b8.PlaceholderText
				aQ.InputFrame.Size = UDim2.new(0, aQ.InputFrame.InputBox.TextBounds.X + 24, 0, 30)
				
				a2()
				
				aQ.InputFrame.InputBox.FocusLost:Connect(function()
					local text = aQ.InputFrame.InputBox.Text
					if b8.RemoveTextAfterFocusLost then
						aQ.InputFrame.InputBox.Text = ""
					end
					
					local E, F = pcall(function()
						b8.Callback(text)
					end)
					
					aQ.InputFrame.Size = UDim2.new(0, aQ.InputFrame.InputBox.TextBounds.X + 24, 0, 30)
				end)
				
				aQ.InputFrame.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
					TweenService:Create(aQ.InputFrame, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Size = UDim2.new(0, aQ.InputFrame.InputBox.TextBounds.X + 24, 0, 30)
					}):Play()
				end)
				
				local b8Obj = {}
				function b8Obj:Set(b9)
					aQ.InputFrame.InputBox.Text = b9
				end
				return b8Obj
			end
			
			function _:CreateParagraph(ba)
				local bb = L.Template.Paragraph:Clone()
				bb.Name = ba.Title
				bb.Title.Text = ba.Title
				bb.Content.Text = ba.Description
				bb.Content.RichText = true
				bb.Visible = true
				bb.Parent = a0
				a2()
			end
			
			function _:CreateLabel(bc)
				local bb = L.Template.Label:Clone()
				bb.Name = bc.Description
				bb.Title.Text = bc.Description
				bb.Visible = true
				bb.Parent = a0
				a2()
			end
			
			function _:CreateCard(bd)
				local be = L.Template.Card:Clone()
				be.Name = bd.Title
				be.Title.Text = bd.Title
				be.Description.Text = bd.Description
				be.State.Text = bd.SecondaryTitle or ""
				be.PreviewImage.Image = bd.Image or "rbxassetid://14167800463"
				be.Parent = a0
				a2()
				be.Button1.Visible = false
				be.Button2.Visible = false
				if bd.Buttons then
					if bd.Buttons.Button1 then
						local a7 = be.Button1
						a7.Visible = true
						a7.Name = bd.Buttons.Button1.Name
						a7.Text = bd.Buttons.Button1.Name
						a7.MouseButton1Click:Connect(function()
							PlayClick()
							local E, F = pcall(bd.Buttons.Button1.Callback)
						end)
					end
					if bd.Buttons.Button2 then
						local a7 = be.Button2
						a7.Visible = true
						a7.Name = bd.Buttons.Button2.Name
						a7.Text = bd.Buttons.Button2.Name
						a7.MouseButton1Click:Connect(function()
							PlayClick()
							local E, F = pcall(bd.Buttons.Button2.Callback)
						end)
					end
				end
			end
			
			return _
		end
		
		return X
	end
	
	return M
end

return e
