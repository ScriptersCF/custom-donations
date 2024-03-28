-- Services
local Player = game:GetService("Players").LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")
local Event = game:GetService("ReplicatedStorage"):WaitForChild("Event") -- Remote event

-- References
local Discord = script.Parent.Parent.Discord
local Donate = script.Parent.Donate
local Input = script.Parent.Input
local ThankYou = script.Parent.Parent.ThankYou
local Main = script.Parent.Parent.Main

-- Settings 
local PromptFinished, Purchased, PreviousPurchase = false, false, false
local DonationAmount, MaxDonationAmount = 0, 1e6
local SuccessColor, FailColor = Color3.fromRGB(0, 255, 0), Color3.fromRGB(255, 0, 0)

-- Tables -- 
local Cost = {500000, 100000, 50000, 20000, 10000, 6000, 5000, 2000, 1000, 500, 200, 100, 50, 20, 10, 5, 2, 1}
local Ids = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
local Products = {
	[500000] = 90753051,
	[100000] = 90753035,
	[50000] = 90753020,
	[20000] = 90752996,
	[10000] = 90752352,
	[6000] = 90752333,
	[5000] = 90752308,
	[2000] = 90751479,
	[1000] = 90751372,
	[500] = 90751344,
	[200] = 90751322,
	[100] = 90751297,
	[50] = 90751219,
	[20] = 90751193,
	[10] = 90751163,
	[5] = 90751122,
	[2] = 90751102,
	[1] = 90750843
}

-- Donate stuff --
Input:GetPropertyChangedSignal("Text"):Connect(function()
	local IsNumber = tonumber(Input.Text) ~= nil
	
	if #Input.Text > 7 then
		Input.Text = Input.Text:sub(1, 7)
	elseif IsNumber and #Input.Text <= 7 and tonumber(Input.Text) > 0 and tonumber(Input.Text) <= MaxDonationAmount and math.floor(Input.Text) == tonumber(Input.Text) then
		Input.BorderColor3 = SuccessColor
		Donate.Visible = true
		DonationAmount = tonumber(Input.Text)
		Ids = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	else
		Input.BorderColor3 = FailColor
		Donate.Visible = false
	end
end)

Donate.MouseButton1Click:Connect(function()
	if not tonumber(Input.Text) or tonumber(Input.Text) > MaxDonationAmount then return end
	Donate.Visible = false
	for index, value in pairs(Cost) do
		while DonationAmount >= tonumber(value) do
			Ids[index] = Ids[index] + 1
			DonationAmount = DonationAmount - tonumber(value)
		end
	end
	for index, value in pairs(Ids) do
		for t = 1, value do
			MarketplaceService:PromptProductPurchase(Player, tonumber(Products[Cost[index]]))
			repeat wait() until PromptFinished
			if Purchased then
				PromptFinished = false
			elseif not Purchased and not PreviousPurchase then PromptFinished = false return end
		end
	end
	Event:FireServer()
end)

MarketplaceService.PromptProductPurchaseFinished:Connect(function(Player, Id, IsPurchased)
	Input.Text = ""
	if IsPurchased then
		Purchased, PromptFinished, PreviousPurchase = true, true, true
	elseif PreviousPurchase and not IsPurchased then
		Purchased, PromptFinished, PreviousPurchase = false, true, false
		Event:FireServer()
	else
		Purchased, PromptFinished, PreviousPurchase = false, true, false
	end
end)

-- Discord stuff --
Discord.Username:GetPropertyChangedSignal("Text"):Connect(function()
	local User = Discord.Username.Text
	if #User > 32 then
		Discord.Username.Text = User:sub(1, 32)
	elseif #User > 2 and #User <= 32 then 
		Discord.Submit.Visible = true--Discord.Discriminator.BorderColor3 == SuccessColor
		Discord.Username.BorderColor3 = SuccessColor
	else
		Discord.Submit.Visible = false
		Discord.Username.BorderColor3 = FailColor
	end
end)

Discord.Discriminator:GetPropertyChangedSignal("Text"):Connect(function()
	local Discrim = Discord.Discriminator.Text
	if #Discrim > 4 then
		Discord.Discriminator.Text = Discrim:sub(1, 4)
	elseif #Discrim == 4 and tonumber(Discrim) then
		Discord.Submit.Visible = Discord.Username.BorderColor3 == SuccessColor
		Discord.Discriminator.BorderColor3 = SuccessColor
	else 
		Discord.Submit.Visible = false
		Discord.Discriminator.BorderColor3 = FailColor
	end
end)

Discord.Submit.MouseButton1Click:Connect(function()
	Event:FireServer(Discord.Username.Text:lower(), "0")
	--Discord.Visible, Donate.Visible = false, true
	Discord.Visible = false
	ThankYou.Visible = true
end)

Event.OnClientEvent:Connect(function()
	Discord.Visible = true
	Main.Visible = false
	Donate.Visible = false
end)
