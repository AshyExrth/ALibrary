local Library = {}

Library.Themes = {

	DefaultDark = {

		MainBackground = Color3.fromRGB(56, 56, 56),
		SecondaryBackground = Color3.fromRGB(62, 62, 62),
		MainText = Color3.fromRGB(255, 255, 255),
		ItemBackground = Color3.fromRGB(72, 72, 72),
		ItemContent = Color3.fromRGB(255, 255, 255),
		SectionNameBackground = Color3.fromRGB(99, 99, 99),
		SelectedListItem = Color3.fromRGB(255, 255, 255),
		UnselectedListItem = Color3.fromRGB(150, 150, 150),
		InputBackground = Color3.fromRGB(45, 45, 45),
		InputText = Color3.fromRGB(255, 255, 255),
		InputBorder = Color3.fromRGB(61, 61, 61),
		FontFace = Enum.Font.Jura

	},
	DefaultLight = {

		MainBackground = Color3.fromRGB(235, 231, 231),
		SecondaryBackground = Color3.fromRGB(198, 198, 198),
		MainText = Color3.fromRGB(38, 38, 38),
		ItemBackground = Color3.fromRGB(171, 171, 171),
		ItemContent = Color3.fromRGB(255, 255, 255),
		SectionNameBackground = Color3.fromRGB(220, 220, 220),
		SelectedListItem = Color3.fromRGB(0, 0, 0),
		UnselectedListItem = Color3.fromRGB(108, 108, 108),
		InputBackground = Color3.fromRGB(171, 171, 171),
		InputText = Color3.fromRGB(42, 42, 42),
		InputBorder = Color3.fromRGB(212, 212, 212),
		FontFace = Enum.Font.Jura

	},
	Cream = {

		MainBackground = Color3.fromRGB(255, 234, 180),
		SecondaryBackground = Color3.fromRGB(190, 176, 144),
		MainText = Color3.fromRGB(97, 91, 68),
		ItemBackground = Color3.fromRGB(198, 182, 134),
		ItemContent = Color3.fromRGB(84, 75, 53),
		SectionNameBackground = Color3.fromRGB(255, 196, 148),
		SelectedListItem = Color3.fromRGB(61, 53, 40),
		UnselectedListItem = Color3.fromRGB(116, 104, 88),
		InputBackground = Color3.fromRGB(72, 63, 40),
		InputText = Color3.fromRGB(255, 228, 194),
		InputBorder = Color3.fromRGB(79, 60, 49),
		FontFace = Enum.Font.FredokaOne

	}

}

local TypeValues = {
	Button = "Text",
	Toggle = "Value",
	Input = "Content",
	TextLabel = "Text",
	ImageLabel = "Text"
}

local CreateObjects = {}

local function GetKey(Table : {any}, Index : number)
	local Iterations = 0

	for Key, Value in pairs(Table) do
		Iterations += 1

		if Iterations == Index then
			return Key
		end
	end
end

local function ObjectHasProperty(Object : Instance, PropertyName : string)
	return pcall(function()
		return Object[PropertyName]
	end)
end

function Library.new(GuiName : string, Theme : {any}, Parent : Instance?)
	local Mouse = game.Players.LocalPlayer:GetMouse()
	local Mouse1Down = false

	Mouse.Button1Down:Connect(function()
		Mouse1Down = true
	end)
	Mouse.Button1Up:Connect(function()
		Mouse1Down = false
	end)

	Parent = Parent or game.CoreGui
	local Gui = {}

	Gui.ScreenGui = Instance.new("ScreenGui")
	Gui.UI = CreateObjects.CreateMainGui(GuiName)

	Gui.ScreenGui.Name = GuiName
	Gui.ScreenGui.Parent = Parent
	Gui.UI.Parent = Gui.ScreenGui
	Gui.Name = GuiName

	Gui.Pages = {}
	Gui.TakenItemIds = {}

	Gui.CurrentPage = nil
	Gui.Theme = Theme

	local NotificationsUi = Parent:FindFirstChild("AL_Notifs") or Instance.new("ScreenGui")
	NotificationsUi.Name = "AL_Notifs"
	NotificationsUi.Parent = Parent

	if not NotificationsUi:FindFirstChild("Notifications") then
		CreateObjects.CreateNotificationHolder().Parent = NotificationsUi
	end
	
	Gui.UI.ExitButton.Activated:Connect(function()
		Gui.ScreenGui:Destroy()
	end)
	
	Gui.HandleDrag = function(Object : GuiObject, Target : GuiObject?)
		Target = Target or Object
		
		local InUI = false
		Object.MouseEnter:Connect(function()
			InUI = true
		end)
		Object.MouseLeave:Connect(function()
			InUI = false
		end)

		Mouse.Button1Down:Connect(function()
			Mouse1Down = true
			if InUI and Object:GetAttribute("Draggable") then
				local LastMousePosition = Vector2.new(Mouse.X, Mouse.Y)
				local LastGuiPosition = Object.Position
				
				while Mouse1Down and Object:GetAttribute("Draggable") do
					Target.Position += UDim2.new(0, (Mouse.X - LastMousePosition.X), 0, (Mouse.Y - LastMousePosition.Y))
					LastGuiPosition = Target.Position
					LastMousePosition = Vector2.new(Mouse.X, Mouse.Y)
					
					game:GetService("RunService").RenderStepped:Wait()
				end
			end
		end)
	end

	Gui.Notify = function(Title : string, Description : string, Duration : number?)
		Duration = Duration or #Title / 2

		local Notification = CreateObjects.CreateNotification()
		Notification.GuiName.Text = "From: " .. GuiName
		Notification.Title.Text = Title
		Notification.Description.Text = Description

		Notification.Parent = NotificationsUi

		Gui.ApplyTheme(Gui.Theme, Notification)

		task.spawn(function()
			Notification.GroupTransparency = 1
			game:GetService("TweenService"):Create(Notification, TweenInfo.new(0.5), {GroupTransparency = 0}):Play()
			task.wait(Duration)
			game:GetService("TweenService"):Create(Notification, TweenInfo.new(0.5), {GroupTransparency = 1}):Play()
			task.wait(0.5)
			Notification:Destroy()
		end)
	end

	Gui.CreatePage = function(PageName : string)
		local Page = {}
		Gui.Pages[PageName] = Page

		Page.Name = PageName
		Page.Button = CreateObjects.CreatePage(PageName)
		Page.Button.Parent = Gui.UI.PageSelection.PageScroller

		Page.Button.Text = PageName
		Page.Button.Visible = true

		Page.Sections = {}

		Page.Button.Activated:Connect(function()
			Gui.SelectPage(Page)
		end)

		Page.CreateSection = function(SectionName : string)
			local Section = {}
			Page.Sections[SectionName] = Section


			Section.Name = SectionName
			Section.Items = {}

			Section.CreateItem = function(ItemId : string)
				if table.find(Gui.TakenItemIds, ItemId) then
					Gui.Notify("Error", "Item id is not unique!", 3)
					return nil
				end
				
				local Item = {}
				Section.Items[ItemId] = Item
				table.insert(Gui.TakenItemIds, ItemId)

				Item.Id = ItemId

				Item.SetType = function(Type : string, Data : {any})
					Item.Type = Type

					Item.Data = Data
				end

				return Item
			end

			Section.RemoveItem = function(ItemId : string)
				table.remove(Gui.TakenItemIds, table.find(Gui.TakenItemIds, ItemId))
				Section.Items[ItemId] = nil
			end

			return Section
		end

		Page.RemoveSection = function(SectionName : string)
			Page.Sections[SectionName] = nil
		end

		Page.LoadSection = function(SectionName : string)
			local Section = Page.Sections[SectionName]

			local NewSectionUi = CreateObjects.CreateSection(SectionName)
			NewSectionUi.Parent = Gui.UI.MainPage.PageContents

			for ItemId, Item in pairs(Section.Items) do
				local NewItem = CreateObjects.CreateItem(((Item.Type == "TextLabel" or Item.Type == "ImageLabel") and "Label") or Item.Type)

				if Item.Type == "Button" then
					NewItem.Text = Item.Data.Text
					NewItem.TextButton.Activated:Connect(Item.Data.OnClick)
				elseif Item.Type == "Toggle" then
					NewItem.Text = Item.Data.Text

					local function SetImage()
						NewItem.ToggleImage.Image = Item.Data.Value and "http://www.roblox.com/asset/?id=6031068426" or "http://www.roblox.com/asset/?id=6031068433"
					end
					SetImage()

					NewItem.TextButton.Activated:Connect(function()
						Item.Data.Value = not Item.Data.Value

						SetImage()

						Item.Data.OnToggle(Item.Data.Value)
					end)
				elseif Item.Type == "TextLabel" then
					NewItem.Text = Item.Data.Text
				elseif Item.Type == "ImageLabel" then
					NewItem.TextTransparency = 1
					NewItem.Image.Image = Item.Data.Image
					NewItem.Image.ScaleType = Item.Data.FitType or Enum.ScaleType.Stretch
				elseif Item.Type == "Input" then
					local TextBox: TextBox = NewItem.TextBox
					NewItem.Text = Item.Data.Text

					TextBox.Text = Item.Data.Content
					if Item.Data.OnFocus then
						TextBox.Focused:Connect(Item.Data.OnFocus)
					end
					TextBox.FocusLost:Connect(function(EnterPressed)
						Item.Data.Content = TextBox.Text
						if EnterPressed then
							if Item.Data.OnSubmit then
								Item.Data.OnSubmit(TextBox.Text)
							end
						else

						end
					end)
				end

				NewItem.Parent = NewSectionUi

				NewItem.TextScaled = false
				NewItem.TextSize = NewItem.AbsoluteSize.Y / 2
			end
		end

		Gui.UI.PageSelection.Visible = true

		return Page
	end
	
	Gui.GetItemValue = function(ItemId : string)
		for _, Page in pairs(Gui.Pages) do
			for _, Section in pairs(Page.Sections) do
				for _, Item in pairs(Section.Items) do
					if Item.Id == ItemId then
						return Item.Data[TypeValues[Item.Type]]
					end
				end
			end
		end
		
		return nil
	end
	
	Gui.RemovePage = function(PageName : string)
		Gui.Pages[PageName].Button:Destroy()
		Gui.Pages[PageName] = nil

		if Gui.CurrentPage == PageName then
			Gui.SelectPage(1)
		end
	end

	Gui.LoadCurrentPage = function()
		if not Gui.CurrentPage then return end

		local PageContents: ScrollingFrame = Gui.UI.MainPage.PageContents

		for _, Item in pairs(PageContents:GetChildren()) do
			if Item:IsA("Frame") then
				Item:Destroy()
			end
		end

		local Page = Gui.Pages[Gui.CurrentPage]

		for SectionName, Section in pairs(Page.Sections) do
			Page.LoadSection(SectionName)
		end
	end

	Gui.SelectPage = function(Page : {}|number)
		if typeof(Page) == "table" then
			Page = Page
		elseif typeof(Page) == "number" then
			Page = Gui.Pages[GetKey(Gui.Pages, Page)]
		end

		for _, Button: Instance? in pairs(Gui.UI.PageSelection.PageScroller:GetChildren()) do
			if Button:IsA("TextButton") and Button ~= Page.Button then
				Button:SetAttribute("Selected", false)
				game:GetService("TweenService"):Create(Button, TweenInfo.new(0.25), {TextColor3 = Theme.UnselectedListItem}):Play()
			end
		end

		Page.Button:SetAttribute("Selected", true)
		game:GetService("TweenService"):Create(Page.Button, TweenInfo.new(0.25), {TextColor3 = Theme.SelectedListItem}):Play()

		Gui.CurrentPage = Page.Name
		Gui.LoadCurrentPage()
	end

	Gui.ApplyTheme = function(Theme : {[string]: Color3}, Object : Instance)
		Object = Object or Gui.ScreenGui
		for _, Descendant: Instance? in pairs({Object, table.unpack(Object:GetDescendants())}) do
			local BackgroundColor = Descendant:GetAttribute("ThemeBackgroundColor")
			local ContentColor = Descendant:GetAttribute("ThemeContentColor")
			local Color = Descendant:GetAttribute("ThemeColor")

			if ObjectHasProperty(Descendant, "Font") then
				Descendant.Font = Theme.FontFace
			end

			if BackgroundColor then
				if ObjectHasProperty(Descendant, "BackgroundColor3") then
					Descendant.BackgroundColor3 = Theme[BackgroundColor]
				end
			end
			if ContentColor then
				if ObjectHasProperty(Descendant, "TextColor3") then
					Descendant.TextColor3 = Theme[ContentColor]
				end
				if ObjectHasProperty(Descendant, "ImageColor3") then
					Descendant.ImageColor3 = Theme[ContentColor]
				end
				if ObjectHasProperty(Descendant, "Color") then
					Descendant.Color = Theme[ContentColor]
				end
			end
			if Color then
				if ObjectHasProperty(Descendant, "BackgroundColor3") then
					Descendant.BackgroundColor3 = Theme[Color]
				end
				if ObjectHasProperty(Descendant, "TextColor3") then
					Descendant.TextColor3 = Theme[Color]
				end
				if ObjectHasProperty(Descendant, "ImageColor3") then
					Descendant.ImageColor3 = Theme[Color]
				end
				if ObjectHasProperty(Descendant, "Color") then
					Descendant.Color = Theme[Color]
				end
			end
		end
	end

	Gui.ScreenGui.DescendantAdded:Connect(function()
		Gui.ApplyTheme(Gui.Theme)
	end)
	Gui.LoadCurrentPage()
	
	for _, Descendant in pairs(Gui.ScreenGui:GetDescendants()) do
		if Descendant:GetAttribute("Draggable") then
			local Target = Descendant:GetAttribute("DragTarget")
			if Target then
				if Target == "Main" then
					Gui.HandleDrag(Descendant, Gui.UI)
				end
			else
				Gui.HandleDrag(Descendant)
			end
		end
	end

	return Gui
end

CreateObjects.CreateNotificationHolder = function()
	-- << Base Object Parent (eg. game.StarterGui, game.Workspace, ...) >> --
	local BaseParent = nil


	-- ['Notifications'] --
	local Object0 = Instance.new('Frame')
	-- <Properties (Parent at bottom of script)> --
	Object0.Name = [[Notifications]]
	Object0.BackgroundColor3 = Color3.new(1, 1, 1)
	Object0.BackgroundTransparency = 1
	Object0.Size = UDim2.new(0.99512732, 0, 0.990732133, 0)


	-- ['Notifications/UIListLayout'] --
	local Object1 = Instance.new('UIListLayout')
	-- <Properties> --
	Object1.Padding = UDim.new(0.00499999989, 0)
	Object1.Parent = Object0
	Object1.HorizontalAlignment = Enum.HorizontalAlignment.Right
	Object1.SortOrder = Enum.SortOrder.LayoutOrder
	Object1.VerticalAlignment = Enum.VerticalAlignment.Bottom


	-- << Sets Base Object's Parent >> --
	Object0.Parent = BaseParent

	return Object0
end

CreateObjects.CreateNotification = function()
	-- << Base Object Parent (eg. game.StarterGui, game.Workspace, ...) >> --
	local BaseParent = nil


	-- ['Notification'] --
	local Object0 = Instance.new('CanvasGroup')
	-- <Properties (Parent at bottom of script)> --
	Object0.Name = [[Notification]]
	Object0.AnchorPoint = Vector2.new(1, 1)
	Object0.AutomaticSize = Enum.AutomaticSize.Y
	Object0.BackgroundColor3 = Color3.new(0.219608, 0.219608, 0.219608)
	Object0.Position = UDim2.new(0.995326757, 0, 0.990732193, 0)
	Object0.Size = UDim2.new(0.157812506, 0, 0.0926784053, 0)
	-- <Attributes> --
	Object0:SetAttribute([[ThemeBackgroundColor]], [[SecondaryBackground]])


	-- ['Notification/UICorner'] --
	local Object1 = Instance.new('UICorner')
	-- <Properties> --
	Object1.Parent = Object0
	Object1.CornerRadius = UDim.new(0.150000006, 0)


	-- ['Notification/GuiName'] --
	local Object2 = Instance.new('TextLabel')
	-- <Properties> --
	Object2.Name = [[GuiName]]
	Object2.Parent = Object0
	Object2.BackgroundColor3 = Color3.new(1, 1, 1)
	Object2.BackgroundTransparency = 1
	Object2.Position = UDim2.new(0.0317394882, 0, 0, 0)
	Object2.Size = UDim2.new(0.966996729, 0, 0.189999998, 0)
	Object2.Text = [[Source UI]]
	Object2.TextColor3 = Color3.new(1, 1, 1)
	Object2.TextScaled = true
	Object2.TextSize = 14
	Object2.TextWrapped = true
	Object2.TextXAlignment = Enum.TextXAlignment.Left
	-- <Attributes> --
	Object2:SetAttribute([[ThemeContentColor]], [[MainText]])


	-- ['Notification/Title'] --
	local Object3 = Instance.new('TextLabel')
	-- <Properties> --
	Object3.Name = [[Title]]
	Object3.Parent = Object0
	Object3.BackgroundColor3 = Color3.new(1, 1, 1)
	Object3.BackgroundTransparency = 1
	Object3.Position = UDim2.new(0.0317394882, 0, 0.189999998, 0)
	Object3.Size = UDim2.new(0.966996729, 0, 0.289999992, 0)
	Object3.Text = [[Title]]
	Object3.TextColor3 = Color3.new(1, 1, 1)
	Object3.TextScaled = true
	Object3.TextSize = 14
	Object3.TextWrapped = true
	Object3.TextXAlignment = Enum.TextXAlignment.Left
	-- <Attributes> --
	Object3:SetAttribute([[ThemeContentColor]], [[MainText]])


	-- ['Notification/Description'] --
	local Object4 = Instance.new('TextLabel')
	-- <Properties> --
	Object4.Name = [[Description]]
	Object4.Parent = Object0
	Object4.AutomaticSize = Enum.AutomaticSize.Y
	Object4.BackgroundColor3 = Color3.new(1, 1, 1)
	Object4.BackgroundTransparency = 1
	Object4.Position = UDim2.new(0.0317394882, 0, 0.479999989, 0)
	Object4.Size = UDim2.new(0.966996729, 0, 0.519999981, 0)
	Object4.Text = [[Description]]
	Object4.TextColor3 = Color3.new(1, 1, 1)
	Object4.TextSize = 25
	Object4.TextWrapped = true
	Object4.TextXAlignment = Enum.TextXAlignment.Left
	Object4.TextYAlignment = Enum.TextYAlignment.Top
	-- <Attributes> --
	Object4:SetAttribute([[ThemeContentColor]], [[MainText]])


	-- << Sets Base Object's Parent >> --
	Object0.Parent = BaseParent

	return Object0
end

CreateObjects.CreateMainGui = function(GuiTitle : string)
	-- << Base Object Parent (eg. game.StarterGui, game.Workspace, ...) >> --
	local BaseParent = nil


	-- ['Main'] --
	local Object0 = Instance.new('CanvasGroup')
	-- <Properties (Parent at bottom of script)> --
	Object0.Name = [[Main]]
	Object0.BackgroundColor3 = Color3.new(0.219608, 0.219608, 0.219608)
	Object0.Position = UDim2.new(0.319270819, 0, 0.281742364, 0)
	Object0.Size = UDim2.new(0.360937506, 0, 0.436515301, 0)
	-- <Attributes> --
	Object0:SetAttribute([[ThemeBackgroundColor]], [[MainBackground]])


	-- ['Main/UICorner'] --
	local Object1 = Instance.new('UICorner')
	-- <Properties> --
	Object1.Parent = Object0
	Object1.CornerRadius = UDim.new(0.0250000004, 0)


	-- ['Main/Title'] --
	local Object2 = Instance.new('TextLabel')
	-- <Properties> --
	Object2.Name = [[Title]]
	Object2.Parent = Object0
	Object2.BackgroundColor3 = Color3.new(1, 1, 1)
	Object2.BackgroundTransparency = 1
	Object2.Position = UDim2.new(0.0089825606, 0, 0, 0)
	Object2.Size = UDim2.new(0.754689753, 0, 0.082802549, 0)
	Object2.ZIndex = 2
	Object2.Text = GuiTitle
	Object2.TextColor3 = Color3.new(1, 1, 1)
	Object2.TextScaled = true
	Object2.TextSize = 14
	Object2.TextWrapped = true
	Object2.TextXAlignment = Enum.TextXAlignment.Left
	-- <Attributes> --
	Object2:SetAttribute([[ThemeContentColor]], [[MainText]])
	Object2:SetAttribute([[Draggable]], true)
	Object2:SetAttribute([[DragTarget]], [[Main]])


	-- ['Main/UIGradient'] --
	local Object3 = Instance.new('UIGradient')
	-- <Properties> --
	Object3.Parent = Object0
	Object3.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(0.898039, 0.898039, 0.898039)),
		ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
	})
	Object3.Rotation = 90


	-- ['Main/PageSelection'] --
	local Object4 = Instance.new('Frame')
	-- <Properties> --
	Object4.Name = [[PageSelection]]
	Object4.Parent = Object0
	Object4.BackgroundColor3 = Color3.new(0.243137, 0.243137, 0.243137)
	Object4.BorderSizePixel = 0
	Object4.Size = UDim2.new(0.240981236, 0, 1, 0)
	Object4.Visible = nil
	-- <Attributes> --
	Object4:SetAttribute([[ThemeBackgroundColor]], [[SecondaryBackground]])


	-- ['Main/PageSelection/PageScroller'] --
	local Object5 = Instance.new('ScrollingFrame')
	-- <Properties> --
	Object5.Name = [[PageScroller]]
	Object5.Parent = Object4
	Object5.Active = true
	Object5.BackgroundColor3 = Color3.new(1, 1, 1)
	Object5.BackgroundTransparency = 1
	Object5.Position = UDim2.new(0, 0, 0.10533113, 0)
	Object5.Size = UDim2.new(1, 0, 0.893842876, 0)
	Object5.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Object5.CanvasSize = UDim2.new(0, 0, 0, 0)
	Object5.ScrollBarImageColor3 = Color3.new(0, 0, 0)
	Object5.ScrollBarImageTransparency = 1
	Object5.ScrollBarThickness = 0


	-- ['Main/PageSelection/PageScroller/UIListLayout'] --
	local Object6 = Instance.new('UIListLayout')
	-- <Properties> --
	Object6.Parent = Object5
	Object6.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Object6.SortOrder = Enum.SortOrder.LayoutOrder


	-- ['Main/PageSelection/Divider'] --
	local Object7 = Instance.new('Frame')
	-- <Properties> --
	Object7.Name = [[Divider]]
	Object7.Parent = Object4
	Object7.BackgroundColor3 = Color3.new(0.219608, 0.219608, 0.219608)
	Object7.BorderSizePixel = 0
	Object7.Position = UDim2.new(0, 0, 0.0891719759, 0)
	Object7.Size = UDim2.new(1, 0, 0.0148619954, 0)
	-- <Attributes> --
	Object7:SetAttribute([[ThemeBackgroundColor]], [[MainBackground]])


	-- ['Main/MainPage'] --
	local Object8 = Instance.new('Frame')
	-- <Properties> --
	Object8.Name = [[MainPage]]
	Object8.Parent = Object0
	Object8.BackgroundColor3 = Color3.new(1, 1, 1)
	Object8.BackgroundTransparency = 1
	Object8.Position = UDim2.new(0.240981236, 0, 0.0891719759, 0)
	Object8.Size = UDim2.new(0.75757575, 0, 0.910828054, 0)


	-- ['Main/MainPage/PageContents'] --
	local Object9 = Instance.new('ScrollingFrame')
	-- <Properties> --
	Object9.Name = [[PageContents]]
	Object9.Parent = Object8
	Object9.Active = true
	Object9.BackgroundColor3 = Color3.new(1, 1, 1)
	Object9.BackgroundTransparency = 1
	Object9.Position = UDim2.new(0.0146362307, 0, 0.0163170155, 0)
	Object9.Size = UDim2.new(0.973072708, 0, 0.98368299, 0)
	Object9.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Object9.CanvasSize = UDim2.new(0, 0, 0, 0)
	Object9.ScrollBarImageColor3 = Color3.new(0, 0, 0)
	Object9.ScrollBarImageTransparency = 1
	Object9.ScrollBarThickness = 0


	-- ['Main/MainPage/PageContents/UIListLayout'] --
	local Object10 = Instance.new('UIListLayout')
	-- <Properties> --
	Object10.Padding = UDim.new(0.0500000007, 0)
	Object10.Parent = Object9
	Object10.SortOrder = Enum.SortOrder.LayoutOrder


	-- ['Main/ExitButton'] --
	local Object11 = Instance.new('TextButton')
	-- <Properties> --
	Object11.Text = [[X]]
	Object11.TextColor3 = Color3.new(1, 1, 1)
	Object11.TextScaled = true
	Object11.TextSize = 14
	Object11.TextWrapped = true
	Object11.Name = [[ExitButton]]
	Object11.Parent = Object0
	Object11.BackgroundColor3 = Color3.new(1, 1, 1)
	Object11.BackgroundTransparency = 1
	Object11.Position = UDim2.new(0.94162643, 0, 0.0127388528, 0)
	Object11.Size = UDim2.new(0.0476190485, 0, 0.0700636953, 0)
	-- <Attributes> --
	Object11:SetAttribute([[ThemeContentColor]], [[MainText]])


	-- ['Main/ExitButton/UICorner'] --
	local Object12 = Instance.new('UICorner')
	-- <Properties> --
	Object12.Parent = Object11
	Object12.CornerRadius = UDim.new(0.300000012, 0)


	-- ['Main/ExitButton/UIStroke'] --
	local Object13 = Instance.new('UIStroke')
	-- <Properties> --
	Object13.Parent = Object11
	Object13.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Object13.Color = Color3.new(1, 1, 1)
	Object13.Thickness = 2


	-- << Sets Base Object's Parent >> --
	Object0.Parent = BaseParent

	return Object0
end

CreateObjects.CreateSection = function(SectionName : string)
	-- << Base Object Parent (eg. game.StarterGui, game.Workspace, ...) >> --
	local BaseParent = nil


	-- ['Section'] --
	local Object0 = Instance.new('Frame')
	-- <Properties (Parent at bottom of script)> --
	Object0.Name = [[Section]]
	Object0.AutomaticSize = Enum.AutomaticSize.Y
	Object0.BackgroundColor3 = Color3.new(1, 1, 1)
	Object0.BackgroundTransparency = 1
	Object0.Size = UDim2.new(1, 0, 0, 0)
	Object0.Visible = true


	-- ['Section/UIListLayout'] --
	local Object1 = Instance.new('UIListLayout')
	-- <Properties> --
	Object1.Padding = UDim.new(0, 5)
	Object1.Parent = Object0
	Object1.SortOrder = Enum.SortOrder.LayoutOrder


	-- << Sets Base Object's Parent >> --
	Object0.Parent = BaseParent

	local function deserialize()
		-- << Base Object Parent (eg. game.StarterGui, game.Workspace, ...) >> --
		local BaseParent = Object0


		-- ['SectionName'] --
		local Object0 = Instance.new('TextLabel')
		-- <Properties (Parent at bottom of script)> --
		Object0.Name = [[SectionName]]
		Object0.BackgroundColor3 = Color3.new(0.388235, 0.388235, 0.388235)
		Object0.Size = UDim2.new(1, 0, 0.100000001, 0)
		Object0.SizeConstraint = Enum.SizeConstraint.RelativeXX
		Object0.Visible = nil
		Object0.Text = SectionName
		Object0.TextColor3 = Color3.new(1, 1, 1)
		Object0.TextScaled = true
		Object0.TextSize = 14
		Object0.TextWrapped = true
		Object0.LayoutOrder = -1
		Object0.Visible = true
		-- <Attributes> --
		Object0:SetAttribute([[ThemeBackgroundColor]], [[SectionNameBackground]])


		-- ['SectionName/UICorner'] --
		local Object1 = Instance.new('UICorner')
		-- <Properties> --
		Object1.Parent = Object0
		Object1.CornerRadius = UDim.new(0.200000003, 0)


		-- ['SectionName/UIGradient'] --
		local Object2 = Instance.new('UIGradient')
		-- <Properties> --
		Object2.Parent = Object0
		Object2.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(0.847059, 0.847059, 0.847059)),
		})
		Object2.Rotation = 90


		-- << Sets Base Object's Parent >> --
		Object0.Parent = BaseParent

		return Object0
	end

	deserialize()

	return Object0
end

CreateObjects.CreateItem = function(ItemType : string)
	if ItemType == "Button" then
		-- << Base Object Parent (eg. game.StarterGui, game.Workspace, ...) >> --
		local BaseParent = nil


		-- ['Button'] --
		local Object0 = Instance.new('TextLabel')
		-- <Properties (Parent at bottom of script)> --
		Object0.Name = [[Button]]
		Object0.BackgroundColor3 = Color3.new(0.282353, 0.282353, 0.282353)
		Object0.Size = UDim2.new(1, 0, 0.100000001, 0)
		Object0.SizeConstraint = Enum.SizeConstraint.RelativeXX
		Object0.Visible = nil
		Object0.Text = [[Button]]
		Object0.TextColor3 = Color3.new(1, 1, 1)
		Object0.TextScaled = true
		Object0.TextSize = 14
		Object0.TextWrapped = true
		Object0.TextXAlignment = Enum.TextXAlignment.Left
		Object0.Visible = true
		-- <Attributes> --
		Object0:SetAttribute([[ThemeContentColor]], [[ItemContent]])
		Object0:SetAttribute([[ThemeBackgroundColor]], [[ItemBackground]])


		-- ['Button/UICorner'] --
		local Object1 = Instance.new('UICorner')
		-- <Properties> --
		Object1.Parent = Object0
		Object1.CornerRadius = UDim.new(0.200000003, 0)


		-- ['Button/UIGradient'] --
		local Object2 = Instance.new('UIGradient')
		-- <Properties> --
		Object2.Parent = Object0
		Object2.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(0.847059, 0.847059, 0.847059)),
		})
		Object2.Rotation = 90


		-- ['Button/ImageLabel'] --
		local Object3 = Instance.new('ImageLabel')
		-- <Properties> --
		Object3.Image = [[http://www.roblox.com/asset/?id=6023565895]]
		Object3.Parent = Object0
		Object3.BackgroundColor3 = Color3.new(1, 1, 1)
		Object3.BackgroundTransparency = 1
		Object3.Position = UDim2.new(0.899615943, 0, 0, 0)
		Object3.Size = UDim2.new(1, 0, 1, 0)
		Object3.SizeConstraint = Enum.SizeConstraint.RelativeYY
		-- <Attributes> --
		Object3:SetAttribute([[ThemeContentColor]], [[ItemContent]])


		-- ['Button/TextButton'] --
		local Object4 = Instance.new('TextButton')
		-- <Properties> --
		Object4.TextColor3 = Color3.new(0, 0, 0)
		Object4.TextSize = 14
		Object4.TextTransparency = 1
		Object4.Parent = Object0
		Object4.BackgroundColor3 = Color3.new(1, 1, 1)
		Object4.BackgroundTransparency = 1
		Object4.Size = UDim2.new(1, 0, 1, 0)


		-- << Sets Base Object's Parent >> --
		Object0.Parent = BaseParent

		return Object0
	elseif ItemType == "Toggle" then
		-- << Base Object Parent (eg. game.StarterGui, game.Workspace, ...) >> --
		local BaseParent = nil


		-- ['ToggleButton'] --
		local Object0 = Instance.new('TextLabel')
		-- <Properties (Parent at bottom of script)> --
		Object0.Name = [[ToggleButton]]
		Object0.BackgroundColor3 = Color3.new(0.282353, 0.282353, 0.282353)
		Object0.Size = UDim2.new(1, 0, 0.100000001, 0)
		Object0.SizeConstraint = Enum.SizeConstraint.RelativeXX
		Object0.Visible = nil
		Object0.Text = [[Toggle]]
		Object0.TextColor3 = Color3.new(1, 1, 1)
		Object0.TextScaled = true
		Object0.TextSize = 14
		Object0.TextWrapped = true
		Object0.TextXAlignment = Enum.TextXAlignment.Left
		Object0.Visible = true
		-- <Attributes> --
		Object0:SetAttribute([[ThemeContentColor]], [[ItemContent]])
		Object0:SetAttribute([[ThemeBackgroundColor]], [[ItemBackground]])


		-- ['ToggleButton/UICorner'] --
		local Object1 = Instance.new('UICorner')
		-- <Properties> --
		Object1.Parent = Object0
		Object1.CornerRadius = UDim.new(0.200000003, 0)


		-- ['ToggleButton/UIGradient'] --
		local Object2 = Instance.new('UIGradient')
		-- <Properties> --
		Object2.Parent = Object0
		Object2.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(0.847059, 0.847059, 0.847059)),
		})
		Object2.Rotation = 90


		-- ['ToggleButton/ToggleImage'] --
		local Object3 = Instance.new('ImageLabel')
		-- <Properties> --
		Object3.Image = [[http://www.roblox.com/asset/?id=6031068433]]
		Object3.Name = [[ToggleImage]]
		Object3.Parent = Object0
		Object3.BackgroundColor3 = Color3.new(1, 1, 1)
		Object3.BackgroundTransparency = 1
		Object3.Position = UDim2.new(0.903530896, 0, 0.0391494259, 0)
		Object3.Size = UDim2.new(0.899999976, 0, 0.899999976, 0)
		Object3.SizeConstraint = Enum.SizeConstraint.RelativeYY
		-- <Attributes> --
		Object3:SetAttribute([[ThemeContentColor]], [[ItemContent]])


		-- ['ToggleButton/TextButton'] --
		local Object4 = Instance.new('TextButton')
		-- <Properties> --
		Object4.TextColor3 = Color3.new(0, 0, 0)
		Object4.TextSize = 14
		Object4.TextTransparency = 1
		Object4.Parent = Object0
		Object4.BackgroundColor3 = Color3.new(1, 1, 1)
		Object4.BackgroundTransparency = 1
		Object4.Size = UDim2.new(1, 0, 1, 0)


		-- << Sets Base Object's Parent >> --
		Object0.Parent = BaseParent

		return Object0
	elseif ItemType == "Input" then
		-- << Base Object Parent (eg. game.StarterGui, game.Workspace, ...) >> --
		local BaseParent = nil


		-- ['InputBox'] --
		local Object0 = Instance.new('TextLabel')
		-- <Properties (Parent at bottom of script)> --
		Object0.Name = [[InputBox]]
		Object0.BackgroundColor3 = Color3.new(0.282353, 0.282353, 0.282353)
		Object0.Size = UDim2.new(1, 0, 0.100000001, 0)
		Object0.SizeConstraint = Enum.SizeConstraint.RelativeXX
		Object0.Text = [[Input]]
		Object0.TextColor3 = Color3.new(1, 1, 1)
		Object0.TextScaled = true
		Object0.TextSize = 14
		Object0.TextWrapped = true
		Object0.TextXAlignment = Enum.TextXAlignment.Left
		-- <Attributes> --
		Object0:SetAttribute([[ThemeContentColor]], [[ItemContent]])
		Object0:SetAttribute([[ThemeBackgroundColor]], [[ItemBackground]])


		-- ['InputBox/UICorner'] --
		local Object1 = Instance.new('UICorner')
		-- <Properties> --
		Object1.Parent = Object0
		Object1.CornerRadius = UDim.new(0.200000003, 0)


		-- ['InputBox/UIGradient'] --
		local Object2 = Instance.new('UIGradient')
		-- <Properties> --
		Object2.Parent = Object0
		Object2.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(0.847059, 0.847059, 0.847059)),
		})
		Object2.Rotation = 90


		-- ['InputBox/TextBox'] --
		local Object3 = Instance.new('TextBox')
		-- <Properties> --
		Object3.Parent = Object0
		Object3.CursorPosition = -1
		Object3.Text = [[]]
		Object3.TextColor3 = Color3.new(1, 1, 1)
		Object3.TextSize = 25
		Object3.TextTruncate = Enum.TextTruncate.AtEnd
		Object3.TextWrapped = true
		Object3.TextXAlignment = Enum.TextXAlignment.Left
		Object3.AnchorPoint = Vector2.new(1, 0.5)
		Object3.AutomaticSize = Enum.AutomaticSize.X
		Object3.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
		Object3.Position = UDim2.new(0.977914751, 0, 0.487047642, 0)
		Object3.Size = UDim2.new(0, 50, 0.708999991, 0)
		-- <Attributes> --
		Object3:SetAttribute([[ThemeBackgroundColor]], [[InputBackground]])


		-- ['InputBox/TextBox/UICorner'] --
		local Object4 = Instance.new('UICorner')
		-- <Properties> --
		Object4.Parent = Object3
		Object4.CornerRadius = UDim.new(0.300000012, 0)


		-- ['InputBox/TextBox/UIStroke'] --
		local Object5 = Instance.new('UIStroke')
		-- <Properties> --
		Object5.Parent = Object3
		Object5.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Object5.Color = Color3.new(0.239216, 0.239216, 0.239216)
		Object5.Thickness = 2
		-- <Attributes> --
		Object5:SetAttribute([[ThemeContentColor]], [[InputBorder]])


		-- << Sets Base Object's Parent >> --
		Object0.Parent = BaseParent

		return Object0
	elseif ItemType == "Label" then
		-- << Base Object Parent (eg. game.StarterGui, game.Workspace, ...) >> --
		local BaseParent = nil


		-- ['Label'] --
		local Object0 = Instance.new('TextLabel')
		-- <Properties (Parent at bottom of script)> --
		Object0.Name = [[Label]]
		Object0.BackgroundColor3 = Color3.new(0.329412, 0.329412, 0.329412)
		Object0.BackgroundTransparency = 1
		Object0.Size = UDim2.new(1, 0, 0.100000001, 0)
		Object0.SizeConstraint = Enum.SizeConstraint.RelativeXX
		Object0.Visible = nil
		Object0.TextColor3 = Color3.new(1, 1, 1)
		Object0.TextScaled = true
		Object0.TextSize = 14
		Object0.TextWrapped = true
		Object0.Visible = true
		-- <Attributes> --
		Object0:SetAttribute([[ThemeContentColor]], [[ItemContent]])


		-- ['Label/Image'] --
		local Object1 = Instance.new('ImageLabel')
		-- <Properties> --
		Object1.Name = [[Image]]
		Object1.Parent = Object0
		Object1.BackgroundColor3 = Color3.new(1, 1, 1)
		Object1.BackgroundTransparency = 1
		Object1.Size = UDim2.new(1, 0, 1, 0)
		-- <Attributes> --
		Object1:SetAttribute([[ThemeContentColor]], [[ItemContent]])


		-- << Sets Base Object's Parent >> --
		Object0.Parent = BaseParent

		return Object0
	end

	return nil
end

CreateObjects.CreatePage = function(PageName : string)
	-- << Base Object Parent (eg. game.StarterGui, game.Workspace, ...) >> --
	local BaseParent = nil


	-- ['PageButton'] --
	local Object0 = Instance.new('TextButton')
	-- <Properties (Parent at bottom of script)> --
	Object0.Text = [[PageButton]]
	Object0.TextColor3 = Color3.new(0.686275, 0.686275, 0.686275)
	Object0.TextScaled = true
	Object0.TextSize = 14
	Object0.TextWrapped = true
	Object0.Name = [[PageButton]]
	Object0.BackgroundColor3 = Color3.new(1, 1, 1)
	Object0.BackgroundTransparency = 1
	Object0.Size = UDim2.new(1, 0, 0.200000003, 0)
	Object0.SizeConstraint = Enum.SizeConstraint.RelativeXX
	Object0.Visible = nil
	-- <Attributes> --
	Object0:SetAttribute([[Selected]], false)


	-- << Sets Base Object's Parent >> --
	Object0.Parent = BaseParent

	return Object0
end


return Library
