# ALibrary

A roblox GUI library made by me for fun in like 6 hours maybe??

# Documentation

# Importing the module
You can import the module using
```lua
local ALibrary = loadstring("https://raw.githubusercontent.com/AshyExrth/ALibrary/main/Main.lua")()
```

# Creating your Gui
To create the gui all you have to do is use this code
```lua
local Gui = ALibrary.new(Gui_Name, Theme (default ALibrary.Themes.DefaultDark), Parent (default game.CoreGui))
```

# Themes
There are 3 default themes with near infinite possiblities with custom themes, the defaults are
```
DefaultDark
DefaultLight
and Cream
```

A custom theme can be created by using this chart
```
MainBackground: Color3,
SecondaryBackground: Color3,
InputBackground: Color3,
ItemBackground: Color3,
SectionNameBackground: Color3,

MainText: Color3,
InputText: Color3,

ItemContent: Color3,

SelectedListItem: Color3,
UnselectedListItem: Color3,

InputBorder: Color3,

FontFace: Font
```

# Creating pages
Creating pages is easy aswell!
Use this code to create pages
```lua
local Page = Gui.CreatePage(Page_Name)
```

# Sections
Inside pages you can have sections!
Sections hold items that interact with the scripts
To create a section use
```lua
local Section = Page.CreateSection(Section_Name)
```
Inside sections you have
# Items
Items are objects like buttons, labels, inputs, etc.. To create items use
```lua
local Item = Section.CreateItem(Item_Id)
```
To make the item useful, examine these example scripts
```lua
local Toggle = Item.SetType("Toggle", { -- Toggle Button, On/Off
	Text = "ToggleButton",
	Value = false,
	OnToggle = function(Value)
		print("My value is", Value)
	end,
})
local Input = Item.SetType("Input", { -- Input Box
	Text = "Input",
	Content = "Input Content",
	OnFocus = function()
		print("Input focused!")
	end,
	OnSubmit = function(Text)
		print("Submitted", Text .. "!")
	end,
})
local Button = Item.SetType("Button", { -- Clickable Button
	Text = "Button",
	OnClick = function()
		print("Click!")
	end,
})
local TextLabel = Item.SetType("TextLabel", { -- Text Label
	Text = "Label"
})
local ImageLabel = Item.SetType("ImageLabel", { -- Image Label
	Image = "ImageId",
	FitType = Enum.ScaleType.Fit
})
```

You can get the value of a specific item using
```lua
Gui.GetItemValue(ItemId)
```

# Notifications

You can send notifications using
```lua
Gui.Notify(Title, Description, Duration (default 5)
```

# Finished??

Sorry if its short, its a pretty basic library. Thanks for reading and hopefully using.
