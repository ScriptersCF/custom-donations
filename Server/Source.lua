-- this code is derived the 2017 donation centre and was specifically designed for one-player servers.
-- you will need to make modifications for this to be supported in your own work.
-- i recommend only using this for general reference, and not attempting to copy it over directly

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")

local PaidEvent = ReplicatedStorage:WaitForChild("Event")

local URL = "https://discordapp.com/api/webhooks/xxxxxxxxxxxxxxxxxx/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
local COOLDOWN_SECONDS = 30

local UnsavedSpendings = 0
local LastWebhookCall = 0

-- check user isn't spamming webhook requests
local function CanAccessWebhook()
	local CurrentTime = tick()
	
	if CurrentTime - LastWebhookCall > COOLDOWN_SECONDS then
		LastWebhookCall = CurrentTime
		return true
	end
	
	return false
end

-- update the total spent in datastore & return new value
local function GetTotalSpent(Player, Amount)
	local Data = DataStoreService:GetDataStore("PLR" .. Player.UserId)
	local NewTotal = 0
	
	-- update the total spent by the player
	Data:UpdateAsync("TotalSpent", function(OldTotal)
		-- if they haven't spent anything before, set to default
		if not OldTotal then
			OldTotal = 0
		end
		
		-- set the variable in the GetAmount scope for reference later
		NewTotal = OldTotal + UnsavedSpendings
		return NewTotal
	end)
	
	-- reset the unsaved spendings amount and return our new total
	UnsavedSpendings = 0
	return NewTotal
end


-- fired when a user has finished paying for their dev products
PaidEvent.OnServerEvent:Connect(function(Player, Username)
	local Username = Username and tostring(Username)
	
	-- check username is valid
	if Username and #Username > 0 and #Username <= 32 then
		
		-- if webhook was sent recently, refuse the request
		if not CanAccessWebhook() then
			return false
		end
		
		-- get the relevant spendings
		local JustSpent = tonumber(UnsavedSpendings)
		local Success, TotalSpent = pcall(GetTotalSpent, Player)
		
		-- prepare info that needs to be sent
		local Data = {
			username = "Donation",
			content = HttpService:JSONEncode({
				roblox = Player.Name,
				user = Username,
				spent = JustSpent,
				total = Success and TotalSpent,
				hasSaved = Success
			})
		}
		
		-- sent this info via discord webhook
		HttpService:PostAsync(URL, HttpService:JSONEncode(Data))
		
	-- if no username was provided, get client to ask for discord name
	elseif not Username then
		PaidEvent:FireAllClients()
	end
end)

-- when a receipt is received, add to total amount that needs storing
MarketplaceService.ProcessReceipt = function(ReceiptInfo)
	UnsavedSpendings += ReceiptInfo.CurrencySpent
	return Enum.ProductPurchaseDecision.PurchaseGranted		
end
