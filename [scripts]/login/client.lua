local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

local menuactive = false
function ToggleActionMenu()
	menuactive = not menuactive
	if menuactive then
		SetNuiFocus(true,true)
		SendNUIMessage({ showmenu = true })
	else
		SetNuiFocus(false)
		SendNUIMessage({ hidemenu = true })
	end
end

RegisterNUICallback("ButtonClick",function(data,cb)
	if data == "rodoviaria" then
		vRP.teleport(-1604.54, -1048.51, 13.05)
	elseif data == "aeroporto" then
		vRP.teleport(237.62, -823.51, 30.11)
	end
	ToggleActionMenu()
	TriggerEvent("ToogleBackCharacter")
	TriggerEvent("status:hud",false)
end)


RegisterNetEvent('vrp:ToogleLoginMenu')
AddEventHandler('vrp:ToogleLoginMenu',function()
	ToggleActionMenu()
end)