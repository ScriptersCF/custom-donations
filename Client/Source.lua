-- written in mid 2017, needs aesthetic improvements
local sP = script.Parent
local input = sP.input
local don = sP['donate-btn']
local conf = true
local plrn = sP.Parent.Parent.Parent.Parent.Name
local donam = 0;
local ms = game:GetService("MarketplaceService")
local nxt = false
local max=1e6
local HB=game:GetService"RunService".RenderStepped
local paid = game.ReplicatedStorage:WaitForChild("paid")
local total = 0

local Discord = script.Parent.Parent["discord-frm"]

local ns = {500000,100000,50000,20000,10000,6000,5000,2000,1000,500,200,100,50,20,10,5,2,1}
local ns1 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

local ns2 = {
	[500000]=90753051,
	[100000]=90753035,
	[50000]=90753020,
	[20000]=90752996,
	[10000]=90752352,
	[6000]=90752333,
	[5000]=90752308,
	[2000]=90751479,
	[1000]=90751372,
	[500]=90751344,
	[200]=90751322,
	[100]=90751297,
	[50]=90751219,
	[20]=90751193,
	[10]=90751163,
	[5]=90751122,
	[2]=90751102,
	[1]=90750843
}

input.Changed:Connect(function()
	conf = tonumber(input.Text) ~= nil
	if conf and #input.Text < 12 and tonumber(input.Text) > 0 and tonumber(input.Text)<=max and math.floor(input.Text) == tonumber(input.Text) then
		input.BorderColor3 = Color3.fromRGB(0, 255, 0)
		don.Visible = true
		donam = tonumber(input.Text)
		ns1 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	else
		input.BorderColor3 = Color3.fromRGB(255, 0, 0)
		don.Visible = false
	end
end)

don.MouseButton1Click:Connect(function()
	if not tonumber(input.Text) or tonumber(input.Text)>max then return end
	don.Visible = false
	local rep=0
	for i, v in pairs(ns) do
		while donam >= tonumber(v) do
			rep=(rep+1)%(max/100)
			if rep==0 then
				HB:Wait()
			end
			ns1[i] = ns1[i] + 1
			donam = donam - tonumber(v)
		end
	end
	for i, v in pairs(ns1) do
		for j = 1, v do
			ms:PromptProductPurchase(game.Players[plrn], tonumber(ns2[ns[i]]))
			repeat wait() until nxt
			nxt = false
			wait(1)
		end
	end
	paid:FireServer()
end)

ms.PromptProductPurchaseFinished:Connect(function()
	nxt = true
end)

Discord.discrim:GetPropertyChangedSignal("Text"):Connect(function()
	local Numbers = Discord.discrim.Text
	if #Numbers == 4 and tonumber(Numbers) then
		Discord.discrim.BorderColor3 = Color3.fromRGB(0, 255, 0)
		Discord["submit-btn"].Visible = true
	else
		Discord.discrim.BorderColor3 = Color3.fromRGB(255, 0, 0)
		Discord["submit-btn"].Visible = false
	end
end)

Discord["submit-btn"].MouseButton1Click:Connect(function()
	paid:FireServer(Discord.username.Text, Discord.discrim.Text)
end)

paid.OnClientEvent:Connect(function()
	Discord.Visible = true
	script.Parent.Visible = false
end)
