-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module('vrp', 'lib/Tunnel')
local Proxy = module('vrp', 'lib/Proxy')
vRP = Proxy.getInterface('vRP')
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cnVRP = {}
Tunnel.bindInterface('skinshop', cnVRP)
vSERVER = Tunnel.getInterface('skinshop')
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local cam = -1
local skinData = {}
local previousSkinData = {}
local customCamLocation = nil
local creatingCharacter = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- SKINDATA
-----------------------------------------------------------------------------------------------------------------------------------------
local skinData = {
	["pants"] = { item = 0, texture = 0 },
	["arms"] = { item = 0, texture = 0 },
	["tshirt"] = { item = 1, texture = 0 },
	["torso"] = { item = 0, texture = 0 },
	["vest"] = { item = 0, texture = 0 },
	["backpack"] = { item = 0, texture = 0 },
	["shoes"] = { item = 1, texture = 0 },
	["mask"] = { item = 0, texture = 0 },
	["hat"] = { item = -1, texture = 0 },
	["glass"] = { item = 0, texture = 0 },
	["ear"] = { item = -1, texture = 0 },
	["watch"] = { item = -1, texture = 0 },
	["bracelet"] = { item = -1, texture = 0 },
	["accessory"] = { item = 0, texture = 0 },
	["decals"] = { item = 0, texture = 0 }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SKINDATA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vrp_skinshop:apply")
AddEventHandler("vrp_skinshop:apply", function(status)
	if status["pants"] ~= nil then
		skinData = status
	end

	resetClothing(skinData)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENCLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vrp_skinshop:OpenClothes", function()
	if not creatingCharacter then
		customCamLocation = nil
		openMenu({
			{ menu = 'character',   label = 'Roupas',     selected = true },
			{ menu = 'accessoires', label = 'Utilidades', selected = false }
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCATESHOPS
-----------------------------------------------------------------------------------------------------------------------------------------
local locateShops = {
	{ 70.87,    -1399.59, 29.38 },
	{ 73.09,    -1399.38, 29.38 },
	{ 75.32,    -1399.56, 29.38 },
	{ -709.40,  -153.66,  37.41 },
	{ -163.20,  -302.03,  39.73 },
	{ 425.58,   -806.23,  29.49 },
	{ -822.34,  -1073.49, 11.32 },
	{ -1193.81, -768.49,  17.31 },
	{ -1450.85, -238.15,  49.81 },
	{ 4.90,     6512.47,  31.87 },
	{ 1693.95,  4822.67,  42.06 },
	{ 126.05,   -223.10,  54.55 },
	{ 614.26,   2761.91,  42.08 },
	{ 1196.74,  2710.21,  38.22 },
	{ -3170.18, 1044.54,  20.86 },
	{ -1115.76, -1647.8,  -0.98 }, -- Bloods
	{ 1286.33,  -1707.81, 49.93 }, -- Crips
	{ 943.55,   -210.19,  69.35 }, -- Russkaya
	{ -566.76,  240.63,   74.9 }, -- Yardie
	{ 2194.45,  85.12,    228.9 }, -- Ballas
	{ 1389.84,  -171.48,  161.53 }, -- Grove
	{ 1794.06,  445.9,    172.55 }, -- Vagos
	{ 472.06,   -1728.18, 28.82 }, -- Aztecas
	{ -1664.05, 181.29,   61.76 },
	{ 1189.63,  -140.67,  72.72 }
}
Citizen.CreateThread(function()
	local innerTable = {}
	for k, v in pairs(locateShops) do
		table.insert(innerTable, { v[1], v[2], v[3], 2.5, "E", "Loja De Roupas", "Pressione para abrir a" })
	end

	TriggerEvent("hoverfy:insertTable", innerTable)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('loja', function(source, args, rawCmd)
	SetNuiFocus(false, false)

	local ped = PlayerPedId()
	if not IsPedInAnyVehicle(ped) and not creatingCharacter then
		if vSERVER.checkOpen() and vSERVER.checkPermission() then
			customCamLocation = nil
			openMenu({
				{ menu = 'character',   label = 'Roupas',     selected = true },
				{ menu = 'accessoires', label = 'Utilidades', selected = false }
			})
		end
	end
end)

Citizen.CreateThread(function()
	SetNuiFocus(false, false)

	while true do
		local idle = 500
		local ped = PlayerPedId()
		if not IsPedInAnyVehicle(ped) and not creatingCharacter then
			local coords = GetEntityCoords(ped)

			for k, v in pairs(locateShops) do
				local distance = #(coords - vector3(v[1], v[2], v[3]))
				if distance <= 1.5 then
					idle = 4
					--DrawMarker(27,v[1],v[2],v[3]-0.97,0,0,0,0,0,0,1.0,1.0,0.5,255,255,255,130,0,0,0,0)

					if IsControlJustPressed(0, 38) and vSERVER.checkOpen() then
						customCamLocation = nil

						openMenu({
							{ menu = 'character',   label = 'Roupas',     selected = true },
							{ menu = 'accessoires', label = 'Utilidades', selected = false }
						})
					end
				end
			end
		end

		Citizen.Wait(idle)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DRAWTEXT3D
-----------------------------------------------------------------------------------------------------------------------------------------
--[[ function DrawText3D(x,y,z,text)
	local onScreen,_x,_y = World3dToScreen2d(x,y,z)
	SetTextFont(4)
	SetTextScale(0.35,0.35)
	SetTextColour(255,255,255,100)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text)) / 400
	DrawRect(_x,_y+0.0125,0.01+factor,0.03,0,0,0,100)
end ]]
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESETOUTFIT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("resetOutfit", function()
	resetClothing(json.decode(previousSkinData))
	skinData = json.decode(previousSkinData)
	previousSkinData = {}
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROTATERIGHT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("rotateRight", function()
	local ped = PlayerPedId()
	local heading = GetEntityHeading(ped)
	SetEntityHeading(ped, heading + 30)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROTATELEFT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("rotateLeft", function()
	local ped = PlayerPedId()
	local heading = GetEntityHeading(ped)
	SetEntityHeading(ped, heading - 30)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOTHINGCATEGORYS
-----------------------------------------------------------------------------------------------------------------------------------------
local clothingCategorys = {
	["arms"] = { type = "variation", id = 3 },
	["tshirt"] = { type = "variation", id = 8 },
	["torso"] = { type = "variation", id = 11 },
	["pants"] = { type = "variation", id = 4 },
	["vest"] = { type = "variation", id = 9 },
	["backpack"] = { type = "variation", id = 5 },
	["shoes"] = { type = "variation", id = 6 },
	["mask"] = { type = "mask", id = 1 },
	["hat"] = { type = "prop", id = 0 },
	["glass"] = { type = "prop", id = 1 },
	["ear"] = { type = "prop", id = 2 },
	["watch"] = { type = "prop", id = 6 },
	["bracelet"] = { type = "prop", id = 7 },
	["accessory"] = { type = "variation", id = 7 },
	["decals"] = { type = "variation", id = 10 }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETMAXVALUES
-----------------------------------------------------------------------------------------------------------------------------------------
function GetMaxValues()
	maxModelValues = {
		["arms"] = { type = "character", item = 0, texture = 0, id = 3 },
		["tshirt"] = { type = "character", item = 0, texture = 0, id = 8 },
		["torso"] = { type = "character", item = 0, texture = 0, id = 11 },
		["pants"] = { type = "character", item = 0, texture = 0, id = 4 },
		["shoes"] = { type = "character", item = 0, texture = 0, id = 6 },
		["vest"] = { type = "character", item = 0, texture = 0, id = 9 },
		["backpack"] = { type = "character", item = 0, texture = 0, id = 5 },
		["accessory"] = { type = "character", item = 0, texture = 0, id = 7 },
		["decals"] = { type = "character", item = 0, texture = 0, id = 10 },
		["mask"] = { type = "accessoires", item = 0, texture = 0, id = 1 },
		["hat"] = { type = "accessoires", item = 0, texture = 0, id = "p0" },
		["glass"] = { type = "accessoires", item = 0, texture = 0, id = "p1" },
		["ear"] = { type = "accessoires", item = 0, texture = 0, id = "p2" },
		["watch"] = { type = "accessoires", item = 0, texture = 0, id = "p6" },
		["bracelet"] = { type = "accessoires", item = 0, texture = 0, id = "p7" }
	}

	local ped = PlayerPedId()
	for k, v in pairs(clothingCategorys) do
		if v["type"] == "variation" then
			maxModelValues[k]["item"] = GetNumberOfPedDrawableVariations(ped, v["id"]) - 1
			maxModelValues[k]["texture"] = GetNumberOfPedTextureVariations(ped, v["id"],
				GetPedDrawableVariation(ped, v["id"])) - 1

			if maxModelValues[k]["texture"] <= 0 then
				maxModelValues[k]["texture"] = 0
			end
		end

		if v["type"] == "mask" then
			maxModelValues[k]["item"] = GetNumberOfPedDrawableVariations(ped, v["id"]) - 1
			maxModelValues[k]["texture"] = GetNumberOfPedTextureVariations(ped, v["id"],
				GetPedDrawableVariation(ped, v["id"])) - 1

			if maxModelValues[k]["texture"] <= 0 then
				maxModelValues[k]["texture"] = 0
			end
		end

		if v["type"] == "prop" then
			maxModelValues[k]["item"] = GetNumberOfPedPropDrawableVariations(ped, v["id"]) - 1
			maxModelValues[k]["texture"] = GetNumberOfPedPropTextureVariations(ped, v["id"], GetPedPropIndex(ped, v
				["id"])) - 1

			if maxModelValues[k]["texture"] <= 0 then
				maxModelValues[k]["texture"] = 0
			end
		end
	end

	SendNUIMessage({ action = "updateMax", maxValues = maxModelValues })
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENMENU
-----------------------------------------------------------------------------------------------------------------------------------------
--[[ function openMenu(allowedMenus)
	creatingCharacter = true
	previousSkinData = json.encode(skinData)

	GetMaxValues()

	SendNUIMessage({ action = 'open', menus = allowedMenus, currentClothing = skinData })

	SetNuiFocus(true,true)
	SetCursorLocation(0.9,0.25)

	enableCam()
end
 ]]

function openMenu(allowedMenus)
	local currentGender = ""
	creatingCharacter = true
	previousSkinData = json.encode(skinData)

	GetMaxValues()

	if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
		currentGender = "male"
	elseif GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
		currentGender = "female"
	end

	SendNUIMessage({ action = "open", menus = allowedMenus, currentClothing = skinData, currentGender = currentGender })

	SetNuiFocus(true, true)
	SetCursorLocation(0.9, 0.25)

	enableCam()
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ENABLECAM
-----------------------------------------------------------------------------------------------------------------------------------------
function enableCam()
	local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 2.0, 0)
	RenderScriptCams(false, false, 0, 1, 0)
	DestroyCam(cam, false)

	if not DoesCamExist(cam) then
		cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
		SetCamActive(cam, true)
		RenderScriptCams(true, false, 0, true, true)
		SetCamCoord(cam, coords["x"], coords["y"], coords["z"] + 0.5)
		SetCamRot(cam, 0.0, 0.0, GetEntityHeading(PlayerPedId()) + 180)
	end

	if customCamLocation ~= nil then
		SetCamCoord(cam, customCamLocation["x"], customCamLocation["y"], customCamLocation["z"])
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ROTATECAM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("rotateCam", function(data)
	local ped = PlayerPedId()
	local rotType = data["type"]
	local coords = GetOffsetFromEntityInWorldCoords(ped, 0, 2.0, 0)

	if rotType == "left" then
		SetEntityHeading(ped, GetEntityHeading(ped) - 10)
		SetCamCoord(cam, coords["x"], coords["y"], coords["z"] + 0.5)
		SetCamRot(cam, 0.0, 0.0, GetEntityHeading(ped) + 180)
	else
		SetEntityHeading(ped, GetEntityHeading(ped) + 10)
		SetCamCoord(cam, coords["x"], coords["y"], coords["z"] + 0.5)
		SetCamRot(cam, 0.0, 0.0, GetEntityHeading(ped) + 180)
	end
end)
------------------------------------------------------------------------------------------------------------------------------------------
-- SETUPCAM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("setupCam", function(data)
	local value = data["value"]

	if value == 1 then
		local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 0.75, 0)
		SetCamCoord(cam, coords["x"], coords["y"], coords["z"] + 0.6)
	elseif value == 2 then
		local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 1.0, 0)
		SetCamCoord(cam, coords["x"], coords["y"], coords["z"] + 0.2)
	elseif value == 3 then
		local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 1.0, 0)
		SetCamCoord(cam, coords["x"], coords["y"], coords["z"] - 0.5)
	else
		local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 2.0, 0)
		SetCamCoord(cam, coords["x"], coords["y"], coords["z"] + 0.5)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISABLECAM
-----------------------------------------------------------------------------------------------------------------------------------------
--[[ function closeMenu()
	SendNUIMessage({ action = "close" })
	RenderScriptCams(false,true,250,1,0)
	DestroyCam(cam,false)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSEMENU
-----------------------------------------------------------------------------------------------------------------------------------------
function closeMenu()
	SendNUIMessage({ action = 'close' })
	disableCam()
end ]]

function closeMenu()
	SendNUIMessage({ action = "close" })
	RenderScriptCams(false, true, 250, 1, 0)
	DestroyCam(cam, false)
end

RegisterNUICallback("close", function()
	RenderScriptCams(false, true, 250, 1, 0)
	creatingCharacter = false
	SetNuiFocus(false, false)
	DestroyCam(cam, false)
	vRP.DeletarObjeto()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESETCLOTHING
-----------------------------------------------------------------------------------------------------------------------------------------
function resetClothing(data)
	local ped = PlayerPedId()

	if data["backpack"] == nil then
		data["backpack"] = {}
		data["backpack"]["item"] = 0
		data["backpack"]["texture"] = 0
	end

	SetPedComponentVariation(ped, 4, data["pants"]["item"], data["pants"]["texture"], 1)
	SetPedComponentVariation(ped, 3, data["arms"]["item"], data["arms"]["texture"], 1)
	SetPedComponentVariation(ped, 5, data["backpack"]["item"], data["backpack"]["texture"], 1)
	SetPedComponentVariation(ped, 8, data["tshirt"]["item"], data["tshirt"]["texture"], 1)
	SetPedComponentVariation(ped, 9, data["vest"]["item"], data["vest"]["texture"], 1)
	SetPedComponentVariation(ped, 11, data["torso"]["item"], data["torso"]["texture"], 1)
	SetPedComponentVariation(ped, 6, data["shoes"]["item"], data["shoes"]["texture"], 1)
	SetPedComponentVariation(ped, 1, data["mask"]["item"], data["mask"]["texture"], 1)
	SetPedComponentVariation(ped, 10, data["decals"]["item"], data["decals"]["texture"], 1)
	SetPedComponentVariation(ped, 7, data["accessory"]["item"], data["accessory"]["texture"], 1)

	if data["hat"]["item"] ~= -1 and data["hat"]["item"] ~= 0 then
		SetPedPropIndex(ped, 0, data["hat"]["item"], data["hat"]["texture"], 1)
	else
		ClearPedProp(ped, 0)
	end

	if data["glass"]["item"] ~= -1 and data["glass"]["item"] ~= 0 then
		SetPedPropIndex(ped, 1, data["glass"]["item"], data["glass"]["texture"], 1)
	else
		ClearPedProp(ped, 1)
	end

	if data["ear"]["item"] ~= -1 and data["ear"]["item"] ~= 0 then
		SetPedPropIndex(ped, 2, data["ear"]["item"], data["ear"]["texture"], 1)
	else
		ClearPedProp(ped, 2)
	end

	if data["watch"]["item"] ~= -1 and data["watch"]["item"] ~= 0 then
		SetPedPropIndex(ped, 6, data["watch"]["item"], data["watch"]["texture"], 1)
	else
		ClearPedProp(ped, 6)
	end

	if data["bracelet"]["item"] ~= -1 and data["bracelet"]["item"] ~= 0 then
		SetPedPropIndex(ped, 7, data["bracelet"]["item"], data["bracelet"]["texture"], 1)
	else
		ClearPedProp(ped, 7)
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
--[[ RegisterNUICallback('close',function()
	disableCam()
	SetNuiFocus(false,false)
	creatingCharacter = false
end) ]]
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATESKIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("updateSkin", function(data, cb)
	ChangeVariation(data)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATESKINONINPUT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("updateSkinOnInput", function(data)
	ChangeVariation(data)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHANGEVARIATION
-----------------------------------------------------------------------------------------------------------------------------------------
function ChangeVariation(data)
	local ped = PlayerPedId()
	local types = data["type"]
	local item = data["articleNumber"]
	local category = data["clothingType"]

	if category == "pants" then
		if types == "item" then
			SetPedComponentVariation(ped, 4, item, 0, 1)
			skinData["pants"]["item"] = item
		elseif types == "texture" then
			SetPedComponentVariation(ped, 4, GetPedDrawableVariation(ped, 4), item, 1)
			skinData["pants"]["texture"] = item
		end
	elseif category == "arms" then
		if types == "item" then
			SetPedComponentVariation(ped, 3, item, 0, 1)
			skinData["arms"]["item"] = item
		elseif types == "texture" then
			SetPedComponentVariation(ped, 3, GetPedDrawableVariation(ped, 3), item, 1)
			skinData["arms"]["texture"] = item
		end
	elseif category == "tshirt" then
		if types == "item" then
			SetPedComponentVariation(ped, 8, item, 0, 1)
			skinData["tshirt"]["item"] = item
		elseif types == "texture" then
			SetPedComponentVariation(ped, 8, GetPedDrawableVariation(ped, 8), item, 1)
			skinData["tshirt"]["texture"] = item
		end
	elseif category == "vest" then
		if types == "item" then
			SetPedComponentVariation(ped, 9, item, 0, 1)
			skinData["vest"]["item"] = item
		elseif types == "texture" then
			SetPedComponentVariation(ped, 9, skinData["vest"]["item"], item, 1)
			skinData["vest"]["texture"] = item
		end
	elseif category == "backpack" then
		if types == "item" then
			SetPedComponentVariation(ped, 5, item, 0, 1)
			skinData["backpack"]["item"] = item
		elseif types == "texture" then
			SetPedComponentVariation(ped, 5, skinData["backpack"]["item"], item, 1)
			skinData["backpack"]["texture"] = item
		end
	elseif category == "decals" then
		if types == "item" then
			SetPedComponentVariation(ped, 10, item, 0, 1)
			skinData["decals"]["item"] = item
		elseif types == "texture" then
			SetPedComponentVariation(ped, 10, skinData["decals"]["item"], item, 1)
			skinData["decals"]["texture"] = item
		end
	elseif category == "accessory" then
		if types == "item" then
			SetPedComponentVariation(ped, 7, item, 0, 1)
			skinData["accessory"]["item"] = item
		elseif types == "texture" then
			SetPedComponentVariation(ped, 7, skinData["accessory"]["item"], item, 1)
			skinData["accessory"]["texture"] = item
		end
	elseif category == "torso" then
		if types == "item" then
			SetPedComponentVariation(ped, 11, item, 0, 1)
			skinData["torso"]["item"] = item
		elseif types == "texture" then
			SetPedComponentVariation(ped, 11, GetPedDrawableVariation(ped, 11), item, 1)
			skinData["torso"]["texture"] = item
		end
	elseif category == "shoes" then
		if types == "item" then
			SetPedComponentVariation(ped, 6, item, 0, 1)
			skinData["shoes"]["item"] = item
		elseif types == "texture" then
			SetPedComponentVariation(ped, 6, GetPedDrawableVariation(ped, 6), item, 1)
			skinData["shoes"]["texture"] = item
		end
	elseif category == "mask" then
		if types == "item" then
			SetPedComponentVariation(ped, 1, item, 0, 1)
			skinData["mask"]["item"] = item
		elseif types == "texture" then
			SetPedComponentVariation(ped, 1, GetPedDrawableVariation(ped, 1), item, 1)
			skinData["mask"]["texture"] = item
		end
	elseif category == "hat" then
		if types == "item" then
			if item ~= -1 then
				SetPedPropIndex(ped, 0, item, skinData["hat"]["texture"], 1)
			else
				ClearPedProp(ped, 0)
			end

			skinData["hat"]["item"] = item
		elseif types == "texture" then
			SetPedPropIndex(ped, 0, skinData["hat"]["item"], item, 1)
			skinData["hat"]["texture"] = item
		end
	elseif category == "glass" then
		if types == "item" then
			if item ~= -1 then
				SetPedPropIndex(ped, 1, item, skinData["glass"]["texture"], 1)
				skinData["glass"]["item"] = item
			else
				ClearPedProp(ped, 1)
			end
		elseif types == "texture" then
			SetPedPropIndex(ped, 1, skinData["glass"]["item"], item, 1)
			skinData["glass"]["texture"] = item
		end
	elseif category == "ear" then
		if types == "item" then
			if item ~= -1 then
				SetPedPropIndex(ped, 2, item, skinData["ear"]["texture"], 1)
			else
				ClearPedProp(ped, 2)
			end

			skinData["ear"]["item"] = item
		elseif types == "texture" then
			SetPedPropIndex(ped, 2, skinData["ear"]["item"], item, 1)
			skinData["ear"]["texture"] = item
		end
	elseif category == "watch" then
		if types == "item" then
			if item ~= -1 then
				SetPedPropIndex(ped, 6, item, skinData["watch"]["texture"], 1)
			else
				ClearPedProp(ped, 6)
			end

			skinData["watch"]["item"] = item
		elseif types == "texture" then
			SetPedPropIndex(ped, 6, skinData["watch"]["item"], item, 1)
			skinData["watch"]["texture"] = item
		end
	elseif category == "bracelet" then
		if types == "item" then
			if item ~= -1 then
				SetPedPropIndex(ped, 7, item, skinData["bracelet"]["texture"], 1)
			else
				ClearPedProp(ped, 7)
			end

			skinData["bracelet"]["item"] = item
		elseif types == "texture" then
			SetPedPropIndex(ped, 7, skinData["bracelet"]["item"], item, 1)
			skinData["bracelet"]["texture"] = item
		end
	end

	GetMaxValues()
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVECLOTHING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback('saveClothing', function(data)
	SaveSkin()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVESKIN
-----------------------------------------------------------------------------------------------------------------------------------------
function SaveSkin()
	vSERVER.updateClothes(json.encode(skinData), true)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- GETCUSTOMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.getCustomization()
	return skinData
end
