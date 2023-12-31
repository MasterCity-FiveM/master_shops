ESX             = nil
local ZoneItems = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_shop:requestDBItems', function(source, cb, zone)
	ESX.RunCustomFunction("anti_ddos", source, 'esx_shop:requestDBItems', {zone = zone})
	if ZoneItems[zone] ~= nil then
		cb(ZoneItems[zone])
	else
		MySQL.Async.fetchAll(
			'SELECT shops.item as sname, shops.price as price, shops.forsell as forsell, shops.item_type as item_type, items.label as itemname, items.limit as maxamount, items.label_fa as label_fa FROM shops LEFT JOIN items ON items.name = shops.item WHERE shops.name = @zone',
			{
				['@zone'] = zone
			},
			function(result)
				local shopItems  = {}
				for i=1, #result, 1 do
				
					if shopItems[i] == nil then
						shopItems[i] = {}
					end
					shopItems[i].name  = result[i].sname
					shopItems[i].price = result[i].price
					shopItems[i].label = result[i].itemname
					shopItems[i].maxamount = result[i].maxamount
					shopItems[i].item_type = result[i].item_type
					shopItems[i].forsell = result[i].forsell
					
					if result[i].label_fa then
						shopItems[i].label_fa = result[i].label_fa
					else
						shopItems[i].label_fa = result[i].itemname
					end
				end
				
				if ZoneItems[zone] == nil then
					ZoneItems[zone] = {}
				end
				
				ZoneItems[zone] = shopItems
				cb(shopItems)
			end
		)
	end
end)

function GetItemCount(source, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    local items = xPlayer.getInventoryItem(item)

    if items == nil then
        return 0
    else
        return items.count
    end
end

RegisterServerEvent('esx_shops:buyItem')
AddEventHandler('esx_shops:buyItem', function(itemName, amount, zone)
	--ESX.RunCustomFunction("anti_ddos", source, 'esx_shops:buyItem', {itemName = itemName, amount = amount, zone = zone})
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	amount = ESX.Math.Round(amount)

	-- is the player trying to exploit?
	if amount < 0 then
		-- print('esx_shops: ' .. xPlayer.identifier .. ' attempted to exploit the shop!')
		return
	end

	-- get price
	local price = 0
	local item_type = 'item'
	local itemLabel = ''
	local maxamount = 1
	local forsell = 1
	local found = false
	for i=1, #ZoneItems[zone], 1 do
		if ZoneItems[zone][i].name == itemName then
			price = ZoneItems[zone][i].price
			itemLabel = ZoneItems[zone][i].label
			maxamount = ZoneItems[zone][i].maxamount
			item_type =  ZoneItems[zone][i].item_type
			forsell =  ZoneItems[zone][i].forsell
			found = true
			break
		end
	end
	
	if found == false then
		return
	end
	
	if forsell == 1 then
		local AmountInBag = GetItemCount(_source, itemName)
		local AmountInBagAfterBuy = AmountInBag + amount
		
		if AmountInBag == nil then
			AmountInBag = 0
		end
		
		if AmountInBag >= maxamount then
			TriggerClientEvent("pNotify:SendNotification", _source, { text = "شما حداکثر تعداد قابل حمل این محصول را دارید.", type = "error", timeout = 5000, layout = "bottomCenter"})
			return
		elseif AmountInBagAfterBuy > maxamount then
			TriggerClientEvent("pNotify:SendNotification", _source, { text = "مقدار وارد شده بیش از حد مجاز قابل حمل محصول می باشد.", type = "error", timeout = 5000, layout = "bottomCenter"})
			return
		end
		
		price = price * amount
		
		if xPlayer.getMoney() >= price then
			-- can the player carry the said amount of x item?
			if xPlayer.canCarryItem(itemName, amount) then
				xPlayer.removeMoney(price)
				if item_type == 'weapon' then
					xPlayer.addWeapon(itemName:upper(), amount)
				else
					xPlayer.addInventoryItem(itemName, amount)
				end

				TriggerClientEvent("pNotify:SendNotification", _source, { text = "از خرید شما متشکریم، باز هم به ما سر بزنید.", type = "success", timeout = 5000, layout = "bottomCenter"})
			else
				TriggerClientEvent("pNotify:SendNotification", _source, { text = "جیب شما برای نگهداری این محصولات جا ندارد.", type = "error", timeout = 5000, layout = "bottomCenter"})			
			end
		else
			TriggerClientEvent("pNotify:SendNotification", _source, { text = "پول شما برای خرید کافی نیست.", type = "error", timeout = 5000, layout = "bottomCenter"})
		end
	elseif GetItemCount(_source, itemName) > 0 then
		xPlayer.removeInventoryItem(itemName, 1)
		xPlayer.addMoney(price)
		TriggerClientEvent("pNotify:SendNotification", _source, { text = "معامله خوبی بود.", type = "success", timeout = 5000, layout = "bottomCenter"})
	end
end)
