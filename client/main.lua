local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX                           = nil
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function OpenShopMenu(zone)
	if Config.Zones[zone].Items[1] ~= nil then
		OpenFinalShopMenu(zone)
	else
		ESX.TriggerServerCallback('esx_shop:requestDBItems', function(ShopItems)
			Config.Zones[zone].Items = ShopItems
			OpenFinalShopMenu(zone)
		end, zone)
	end
end


function OpenFinalShopMenu(zone) -- If you don't want the ESX_SuperMarket feature comment out this function
	PlayerData = ESX.GetPlayerData()
	
	SendNUIMessage({
		message		= "show",
		clear = true
	})
	
	local elements = {}
	for i=1, #Config.Zones[zone].Items, 1 do
		local item = Config.Zones[zone].Items[i]

		SendNUIMessage({
			message		= "add",
			name		= item.name,
			label      	= item.label,
			label_fa  	= item.label_fa,
			price      	= item.price,
			maxcount  	= item.maxamount,
			loc		= zone
		})

	end
	
	ESX.SetTimeout(200, function()
		SetNuiFocus(true, true)
	end)
end

function OpenFinalShopMenuDef(zone)
	local elements = {}
	
	for i=1, #Config.Zones[zone].Items, 1 do

		local item = Config.Zones[zone].Items[i]

		table.insert(elements, {
			label     = item.label .. ' - <span style="color:green;">$' .. item.price .. ' </span>',
			realLabel = item.label,
			value     = item.name,
			price     = item.price
		})

	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'shop',
		{
			title  = _U('shop'),
			align = 'center',
			elements = elements
		},
		function(data, menu)
			TriggerServerEvent('esx_shop:buyItem', data.current.value, 1, data.current.price)
		end,
		function(data, menu)
			menu.close()
			CurrentAction     = 'shop_menu'
			CurrentActionMsg  = _U('press_menu')
			CurrentActionData = {zone = zone}
		end
	)
end

AddEventHandler('esx_shops:hasEnteredMarker', function(zone)
	CurrentAction     = 'shop_menu'
	CurrentActionMsg  = _U('press_menu')
	CurrentActionData = {zone = zone}
	
	exports.pNotify:SendNotification({text = CurrentActionMsg, type = "info", timeout = 3000})
end)

AddEventHandler('esx_shops:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

-- Create Blips
Citizen.CreateThread(function()
	for i=1, #Config.Map, 1 do
		
		local blip = AddBlipForCoord(Config.Map[i].x, Config.Map[i].y, Config.Map[i].z)
		SetBlipSprite (blip, Config.Map[i].id)
		SetBlipScale  (blip, 1.2)
		SetBlipDisplay(blip, 4)
		SetBlipColour (blip, Config.Map[i].color)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(Config.Map[i].name)
		EndTextCommandSetBlipName(blip)
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false
		local currentZone = nil
		local letSleep = true
		
		for k,v in pairs(Config.Zones) do
			for i = 1, #v.Pos, 1 do
				local distance = GetDistanceBetweenCoords(coords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, true)
				if distance < Config.DrawDistance then	
					DrawMarker(Config.Type, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Size.x, Config.Size.y, Config.Size.z, Config.Color.r, Config.Color.g, Config.Color.b, 100, false, true, 2, false, false, false, false)
					letSleep = false
				end
				
				if(distance < Config.Size.x) then
					isInMarker  = true
					ShopItems   = v.Items
					currentZone = k
					LastZone    = k
				end
			end
		end
		
		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('esx_shops:hasEnteredMarker', currentZone)
		end
		
		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_shops:hasExitedMarker', LastZone)
		end
		
		if letSleep then
			Citizen.Wait(2000)
		end
	end
end)

RegisterNetEvent('master_keymap:e')
AddEventHandler('master_keymap:e', function() 
	if CurrentAction ~= nil then
		OpenShopMenu(CurrentActionData.zone)
		CurrentAction = nil
	end
end)

RegisterNetEvent('master_keymap:q')
AddEventHandler('master_keymap:q', function() 
	if CurrentAction ~= nil then
		ESX.SetTimeout(200, function()
			closeGui()
		end)
	end
end)

function closeGui()
  SetNuiFocus(false, false)
  SendNUIMessage({message = "hide"})
end

RegisterNUICallback('quit', function(data, cb)
  closeGui()
  cb('ok')
end)

RegisterNUICallback('purchase', function(data, cb)
	TriggerServerEvent('esx_shops:buyItem', data.item, data.count, data.loc)
	cb('ok')
end)
