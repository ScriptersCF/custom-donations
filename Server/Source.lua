local paid = game.ReplicatedStorage:WaitForChild("paid")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local URL = "https://discordapp.com/api/webhooks/xxxxxxxxxxxxxx/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
local Spent = 0

game:GetService("MarketplaceService").ProcessReceipt = function(ReceiptInfo)
	if ReceiptInfo.CurrencySpent then
		Spent = Spent + ReceiptInfo.CurrencySpent
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted		
end

local function GetAmount(Player, Amount)
	local Data = DataStoreService:GetDataStore("PLR" .. Player.UserId)
	local Total = Amount
	Data:UpdateAsync("TotalSpent", function(Old)
		if not Old then
			Old = 0
		end
		Total = Total + Old
		Old = Old + Amount
		return Old
	end)
	Spent = 0
	return Total
end

paid.OnServerEvent:Connect(function(Player, Username, Discriminator)
	--if Spent >= 100 then
		if Username then
			Player:LoadCharacter()
			if #Username > 0 and #Username <= 32 and #Discriminator == 4 and tonumber(Discriminator) then
				local User = Username .. "#" .. Discriminator
				local TotalSpent = GetAmount(Player, Spent)
				local Data = {
					username = "Donation",
					content = HttpService:JSONEncode({user = User, amount = TotalSpent}) .. "\n**" .. User .. " has now donated a total of " .. TotalSpent .. "R$!**"
				}
				HttpService:PostAsync(URL, HttpService:JSONEncode(Data))
			end
		else
			paid:FireAllClients()
		end
	--end
end)
