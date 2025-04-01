local menu_state = {}

local apontar = false
local cancelando = false
local menu_celular = false
local apontando = false
local object = nil


--[ COOLDOWN ]---------------------------------------------------------------------------------------------------------------------------

local cooldown = {}
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		for k, v in pairs(cooldown) do
			if v > 0 then
				cooldown[k] = v - 1
			else
				cooldown[k] = nil
			end
		end
	end
end)

function tvRP.openMenuData(menudata)
	SendNUIMessage({ act = "open_menu", menudata = menudata })
end

function tvRP.closeMenu()
	SendNUIMessage({ act = "close_menu" })
end

function tvRP.getMenuState()
	return menu_state
end

function tvRP.getAgachar()
	return agachar
end

function tvRP.getCancelando()
	return cancelando
end

RegisterNetEvent('cancelando')
AddEventHandler('cancelando', function(status)
	cancelando = status
end)

Citizen.CreateThread(function()
	while true do
		local idle = 1000
		if cancelando then
			idle = 1
			BlockWeaponWheelThisFrame()
			DisableControlAction(0, 29, true)
			DisableControlAction(0, 38, true)
			DisableControlAction(0, 47, true)
			DisableControlAction(0, 56, true)
			DisableControlAction(0, 57, true)
			DisableControlAction(0, 73, true)
			DisableControlAction(0, 137, true)
			DisableControlAction(0, 166, true)
			DisableControlAction(0, 167, true)
			DisableControlAction(0, 169, true)
			DisableControlAction(0, 170, true)
			DisableControlAction(0, 182, true)
			DisableControlAction(0, 187, true)
			DisableControlAction(0, 188, true)
			DisableControlAction(0, 189, true)
			DisableControlAction(0, 190, true)
			DisableControlAction(0, 243, true)
			DisableControlAction(0, 245, true)
			DisableControlAction(0, 257, true)
			DisableControlAction(0, 288, true)
			DisableControlAction(0, 289, true)
			DisableControlAction(0, 311, true)
			DisableControlAction(0, 344, true)
		end

		if menu_celular then
			idle = 1
			BlockWeaponWheelThisFrame()
			DisableControlAction(0, 16, true)
			DisableControlAction(0, 17, true)
			DisableControlAction(0, 24, true)
			DisableControlAction(0, 25, true)
			DisableControlAction(0, 29, true)
			DisableControlAction(0, 56, true)
			DisableControlAction(0, 57, true)
			DisableControlAction(0, 73, true)
			DisableControlAction(0, 166, true)
			DisableControlAction(0, 167, true)
			DisableControlAction(0, 170, true)
			DisableControlAction(0, 182, true)
			DisableControlAction(0, 187, true)
			DisableControlAction(0, 188, true)
			DisableControlAction(0, 189, true)
			DisableControlAction(0, 190, true)
			DisableControlAction(0, 243, true)
			DisableControlAction(0, 245, true)
			DisableControlAction(0, 257, true)
			DisableControlAction(0, 288, true)
			DisableControlAction(0, 289, true)
			DisableControlAction(0, 344, true)
		end

		--[[ 		if menu_state.opened then
			idle = 1
			DisableControlAction(0, 75)
		end ]]
		Citizen.Wait(idle)
	end
end)

function tvRP.prompt(title, default_text)
	SendNUIMessage({ act = "prompt", title = title, text = tostring(default_text) })
	SetNuiFocus(true)
end

function tvRP.request(id, text, time)
	SendNUIMessage({ act = "request", id = id, text = tostring(text), time = time })
end

RegisterNUICallback("menu", function(data, cb)
	if data.act == "close" then
		vRPserver._closeMenu(data.id)
	elseif data.act == "valid" then
		vRPserver._validMenuChoice(data.id, data.choice, data.mod)
	end
end)

RegisterNUICallback("menu_state", function(data, cb)
	menu_state = data
end)

RegisterNUICallback("prompt", function(data, cb)
	if data.act == "close" then
		SetNuiFocus(false)
		vRPserver._promptResult(data.result)
	end
end)

RegisterNUICallback("request", function(data, cb)
	if data.act == "response" then
		vRPserver._requestResult(data.id, data.ok)
	end
end)

RegisterNUICallback("init", function(data, cb)
	SendNUIMessage({ act = "cfg", cfg = {} })
	TriggerEvent("vRP:NUIready")
end)

function tvRP.setDiv(name, css, content)
	SendNUIMessage({ act = "set_div", name = name, css = css, content = content })
end

function tvRP.setDivContent(name, content)
	SendNUIMessage({ act = "set_div_content", name = name, content = content })
end

function tvRP.removeDiv(name)
	SendNUIMessage({ act = "remove_div", name = name })
end

function tvRP.loadAnimSet(dict)
	RequestAnimSet(dict)
	while not HasAnimSetLoaded(dict) do
		Citizen.Wait(10)
	end
	SetPedMovementClipset(PlayerPedId(), dict, 0.25)
end

function tvRP.CarregarAnim(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(10)
	end
end

function tvRP.CarregarObjeto(dict, anim, prop, flag, hand, pos1, pos2, pos3, pos4, pos5, pos6)
	local ped = PlayerPedId()

	RequestModel(GetHashKey(prop))
	while not HasModelLoaded(GetHashKey(prop)) do
		Citizen.Wait(10)
	end

	if pos1 then
		local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, -5.0)
		object = CreateObject(GetHashKey(prop), coords.x, coords.y, coords.z, true, true, true)
		SetEntityCollision(object, false, false)
		AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, hand), pos1, pos2, pos3, pos4, pos5, pos6, true, true,
			false,
			true, 1, true)
	else
		tvRP.CarregarAnim(dict)
		TaskPlayAnim(ped, dict, anim, 3 - .0, 3.0, -1, flag, 0, 0, 0, 0)
		local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, -5.0)
		object = CreateObject(GetHashKey(prop), coords.x, coords.y, coords.z, true, true, true)
		SetEntityCollision(object, false, false)
		AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, hand), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false,
			false
			, 2, true)
	end
	--Citizen.InvokeNative(0xAD738C3085FE7E11, object, true, true)
	SetEntityAsMissionEntity(object, true, true)
end

--[[ function tvRP.DeletarObjeto()
	tvRP.stopAnim(true)
	TriggerEvent("binoculos")
	if DoesEntityExist(object) then
		TriggerServerEvent("trydeleteobj", ObjToNet(object))
		object = nil
	end
end ]]
function tvRP.DeletarObjeto()
	tvRP.stopAnim(true)

	TriggerEvent("binoculos")
	TriggerEvent("camera")

	if DoesEntityExist(object) then
		TriggerServerEvent("trydeleteobj", ObjToNet(object))
		object = nil
	end
end

RegisterNetEvent("status:celular")
AddEventHandler("status:celular", function(status)
	menu_celular = status
end)


RegisterCommand("mgk:ostiville:menuUp", function(source)
	SendNUIMessage({ act = "event", event = "UP" })
	if menu_state.opened then
		tvRP.playSound("NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET")
	end
end)
RegisterKeyMapping("mgk:ostiville:menuUp", "[Menu] Cima", "keyboard", "UP")


RegisterCommand("mgk:ostiville:menuDown", function(source)
	SendNUIMessage({ act = "event", event = "DOWN" })
	if menu_state.opened then
		tvRP.playSound("NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET")
	end
end)
RegisterKeyMapping("mgk:ostiville:menuDown", "[Menu] Baixo", "keyboard", "DOWN")


RegisterCommand("mgk:ostiville:menuLeft", function(source)
	SendNUIMessage({ act = "event", event = "LEFT" })
	if menu_state.opened then
		tvRP.playSound("NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET")
	end
end)
RegisterKeyMapping("mgk:ostiville:menuLeft", "[Menu] Esquerda", "keyboard", "LEFT")


RegisterCommand("mgk:ostiville:menuRight", function(source)
	SendNUIMessage({ act = "event", event = "RIGHT" })
	if menu_state.opened then
		tvRP.playSound("NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET")
	end
end)
RegisterKeyMapping("mgk:ostiville:menuRight", "[Menu] Direita", "keyboard", "RIGHT")


RegisterCommand("mgk:ostiville:menuSelecionar", function(source)
	SendNUIMessage({ act = "event", event = "SELECT" })
	if menu_state.opened then
		tvRP.playSound("SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET")
	end
end)
RegisterKeyMapping("mgk:ostiville:menuSelecionar", "[Menu] Selecionar", "keyboard", "RETURN")


RegisterCommand("mgk:ostiville:menuCancel", function(source)
	SendNUIMessage({ act = "event", event = "CANCEL" })
end)
RegisterKeyMapping("mgk:ostiville:menuCancel", "[Menu] Voltar/Cancelar", "keyboard", "BACK")


RegisterCommand("mgk:ostiville:confirmAccept", function(source)
	SendNUIMessage({ act = "event", event = "Y" })
end)
RegisterKeyMapping("mgk:ostiville:confirmAccept", "[Menu] Aceitar confirmação", "keyboard", "Y")


RegisterCommand("mgk:ostiville:confirmRefuse", function(source)
	SendNUIMessage({ act = "event", event = "U" })
end)
RegisterKeyMapping("mgk:ostiville:confirmRefuse", "[Menu] Negar confirmação", "keyboard", "U")

-- Animações

RegisterCommand("mgk:ostiville:animacaoCruzarBraco", function(source)
	local ped = PlayerPedId()
	if not IsPedInAnyVehicle(ped) and GetEntityHealth(ped) > 101 and not menu_state.opened and not menu_celular and
			not IsPauseMenuActive() then
		if IsEntityPlayingAnim(ped, "anim@amb@nightclub@peds@", "rcmme_amanda1_stand_loop_cop", 3) then
			tvRP.DeletarObjeto()
		else
			tvRP.playAnim(true, { { "anim@amb@nightclub@peds@", "rcmme_amanda1_stand_loop_cop" } }, true)
		end
	end
end)
RegisterKeyMapping("mgk:ostiville:animacaoCruzarBraco", "[Animação] Cruzar Braços", "keyboard", "F1")


RegisterCommand("mgk:ostiville:animacaoAguardar", function(source)
	local ped = PlayerPedId()
	if not IsPedInAnyVehicle(ped) and GetEntityHealth(ped) > 101 and not menu_state.opened and not menu_celular and
			not IsPauseMenuActive() then
		if IsEntityPlayingAnim(ped, "anim@amb@casino@valet_scenario@pose_d@", "base_a_m_y_vinewood_01", 3) then
			tvRP.DeletarObjeto()
		else
			tvRP.playAnim(true, { { "anim@amb@casino@valet_scenario@pose_d@", "base_a_m_y_vinewood_01" } }, true)
		end
	end
end)
RegisterKeyMapping("mgk:ostiville:animacaoAguardar", "[Animação] Aguardar", "keyboard", "F2")


RegisterCommand("mgk:ostiville:animacaoDedoMeio", function(source)
	local ped = PlayerPedId()
	if not IsPedInAnyVehicle(ped) and GetEntityHealth(ped) > 101 and not menu_state.opened and not menu_celular and
			not IsPauseMenuActive() then
		if IsEntityPlayingAnim(ped, "anim@mp_player_intupperfinger", "idle_a_fp", 3) then
			tvRP.DeletarObjeto()
		else
			tvRP.playAnim(true, { { "anim@mp_player_intupperfinger", "idle_a_fp" } }, true)
		end
	end
end)
RegisterKeyMapping("mgk:ostiville:animacaoDedoMeio", "[Animação] Dedo do Meio", "keyboard", "F3")

local Tunnel = module("vrp", "lib/Tunnel")
vPLAYER = Tunnel.getInterface("player")
RegisterCommand("mgk:ostiville:cancelAnimations", function(source)
	local ped = PlayerPedId()
	if not vPLAYER.getAnimated() then
		if not cooldown["cancel"] then
			cooldown["cancel"] = 6
			if GetEntityHealth(ped) > 101 then
				if not menu_state.opened then
					tvRP.DeletarObjeto()
					ClearPedTasks(ped)
				end
			end
		end
	end
end)
RegisterKeyMapping("mgk:ostiville:cancelAnimations", "[Animação] Cancelar animações", "keyboard", "F6")

RegisterCommand("mgk:ostiville:animacaoHandsInHead", function(source)
	local ped = PlayerPedId()
	if GetEntityHealth(ped) > 101 and not menu_state.opened and not menu_celular and not IsPauseMenuActive() then
		if not cooldown["handsHead"] then
			cooldown["handsHead"] = 2
			SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
			if IsEntityPlayingAnim(ped, "random@arrests@busted", "idle_a", 3) then
				tvRP.DeletarObjeto()
			else
				tvRP.DeletarObjeto()
				tvRP.playAnim(true, { { "random@arrests@busted", "idle_a" } }, true)
			end
		end
	end
end)
RegisterKeyMapping("mgk:ostiville:animacaoHandsInHead", "[Animação] Mãos na cabeça", "keyboard", "F10")


RegisterCommand("mgk:ostiville:animacaoJoia2", function(source)
	local ped = PlayerPedId()
	if not IsPedInAnyVehicle(ped) and not tvRP.isHandcuffed() and GetEntityHealth(ped) > 101 and not menu_state.opened and
			not menu_celular and not IsPauseMenuActive() then
		tvRP.playAnim(true, { { "anim@mp_player_intincarthumbs_upbodhi@ps@", "enter" } }, false)
	end
end)
RegisterKeyMapping("mgk:ostiville:animacaoJoia2", "[Animação] Jóia 2", "keyboard", "DELETE")


RegisterCommand("mgk:ostiville:animacaoAssobiar", function(source)
	local ped = PlayerPedId()
	if not IsPedInAnyVehicle(ped) and not tvRP.isHandcuffed() and GetEntityHealth(ped) > 101 and not menu_state.opened and
			not menu_celular and not IsPauseMenuActive() then
		tvRP.playAnim(true, { { "rcmnigel1c", "hailing_whistle_waive_a" } }, false)
	end
end)
RegisterKeyMapping("mgk:ostiville:animacaoAssobiar", "[Animação] Assobiar", "keyboard", "DOWN")


RegisterCommand("mgk:ostiville:animacaoJoia", function(source)
	local ped = PlayerPedId()
	if not IsPedInAnyVehicle(ped) and not tvRP.isHandcuffed() and GetEntityHealth(ped) > 101 and not menu_state.opened and
			not menu_celular and not IsPauseMenuActive() then
		tvRP.playAnim(true, { { "anim@mp_player_intselfiethumbs_up", "idle_a" } }, false)
	end
end)
RegisterKeyMapping("mgk:ostiville:animacaoJoia", "[Animação] Jóia", "keyboard", "LEFT")


RegisterCommand("mgk:ostiville:animacaoFacePalm", function(source)
	local ped = PlayerPedId()
	if not IsPedInAnyVehicle(ped) and not tvRP.isHandcuffed() and GetEntityHealth(ped) > 101 and not menu_state.opened and
			not menu_celular and not IsPauseMenuActive() then
		tvRP.playAnim(true, { { "anim@mp_player_intupperface_palm", "idle_a" } }, false)
	end
end)
RegisterKeyMapping("mgk:ostiville:animacaoFacePalm", "[Animação] FacePalm", "keyboard", "RIGHT")


RegisterCommand("mgk:ostiville:animacaoSaudacao", function(source)
	local ped = PlayerPedId()
	if not IsPedInAnyVehicle(ped) and not tvRP.isHandcuffed() and GetEntityHealth(ped) > 101 and not menu_state.opened and
			not menu_celular and not IsPauseMenuActive() then
		tvRP.playAnim(true, { { "anim@mp_player_intcelebrationmale@salute", "salute" } }, false)
	end
end)
RegisterKeyMapping("mgk:ostiville:animacaoSaudacao", "[Animação] Saudação", "keyboard", "UP")


RegisterCommand("mgk:ostiville:animacaoHands", function(source)
	local ped = PlayerPedId()
	if not IsPedInAnyVehicle(ped) and not tvRP.isHandcuffed() and GetEntityHealth(ped) > 101 and not menu_celular and
			not IsPauseMenuActive() then
		if not cooldown["hands"] then
			cooldown["hands"] = 2
			SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
			if IsEntityPlayingAnim(ped, "random@mugging3", "handsup_standing_base", 3) then
				tvRP.DeletarObjeto()
			else
				tvRP.playAnim(true, { { "random@mugging3", "handsup_standing_base" } }, true)
			end
		end
	end
end)
RegisterKeyMapping("mgk:ostiville:animacaoHands", "[Animação] Levantar Mãos", "keyboard", "X")

RegisterCommand("mgk:ostiville:toggleEngine", function(source)
	local ped = PlayerPedId()
	if IsPedInAnyVehicle(ped) and not IsPauseMenuActive() then
		local vehicle = GetVehiclePedIsIn(ped, false)
		if GetPedInVehicleSeat(vehicle, -1) == ped then
			tvRP.DeletarObjeto()
			-- local running = Citizen.InvokeNative(0xAE31E7DF9B5B132E, vehicle)
			local running = GetIsVehicleEngineRunning(vehicle)
			SetVehicleEngineOn(vehicle, not running, true, true)
			if running then
				SetVehicleUndriveable(vehicle, true)
			else
				SetVehicleUndriveable(vehicle, false)
			end
		end
	end
end)
RegisterKeyMapping("mgk:ostiville:toggleEngine", "[Veículo] Ligar/desligar motor", "keyboard", "Z")

RegisterCommand("mgk:ostiville:animacaoDedo", function(source)
	local ped = PlayerPedId()
	if GetEntityHealth(ped) > 101 and not menu_celular and not IsPauseMenuActive() then
		tvRP.CarregarAnim("anim@mp_point")
		if not apontar then
			SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
			SetPedConfigFlag(ped, 36, 1)
			Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
			apontar = true
		else
			Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
			if not IsPedInjured(ped) then
				ClearPedSecondaryTask(ped)
			end
			if not IsPedInAnyVehicle(ped) then
				SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
			end
			SetPedConfigFlag(ped, 36, 0)
			ClearPedSecondaryTask(ped)
			apontar = false
		end
	end
end)
RegisterKeyMapping("mgk:ostiville:animacaoDedo", "[Animação] Apontar dedo", "keyboard", "B")

local anims = {
	{ dict = "random@mugging3",                      "handsup_standing_base",          anim = "handsup_standing_base" },
	{ dict = "random@arrests@busted",                anim = "idle_a" },
	{ dict = "anim@heists@heist_corona@single_team", anim = "single_team_loop_boss" },
	{ dict = "mini@strip_club@idles@bouncer@base",   anim = "base" },
	{ dict = "anim@mp_player_intupperfinger",        anim = "idle_a_fp" },
	{ dict = "random@arrests",                       anim = "generic_radio_enter" },
	{ dict = "mp_player_int_upperpeace_sign",        anim = "mp_player_int_peace_sign" }
}

Citizen.CreateThread(function()
	while true do
		local sleep = 1000
		for _, block in pairs(anims) do
			if IsEntityPlayingAnim(PlayerPedId(), block.dict, block.anim, 3) or object then
				sleep = 1
				BlockWeaponWheelThisFrame()
				DisableControlAction(0, 16, true)
				DisableControlAction(0, 17, true)
				DisableControlAction(0, 24, true)
				DisableControlAction(0, 25, true)
				DisableControlAction(0, 137, true)
				DisableControlAction(0, 245, true)
				DisableControlAction(0, 257, true)
			end
		end
		Citizen.Wait(sleep)
	end
end)

Citizen.CreateThread(function()
	while true do
		local sleep = 1000
		local ped = PlayerPedId()
		if IsControlJustPressed(0, 29) then
			if GetEntityHealth(ped) > 101 and not menu_celular and not cancelando then
				tvRP.CarregarAnim("anim@mp_point")
				if not apontar then
					SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
					SetPedConfigFlag(ped, 36, 1)
					Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
					apontar = true
				else
					Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
					if not IsPedInjured(ped) then
						ClearPedSecondaryTask(ped)
					end
					if not IsPedInAnyVehicle(ped) then
						SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
					end
					SetPedConfigFlag(ped, 36, 0)
					ClearPedSecondaryTask(ped)
					apontar = false
				end
			end
		end
		Wait(sleep)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÃO DO APONTAR
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local idle = 1000
		local ped = PlayerPedId()

		if apontar then
			idle = 1
			local camPitch = GetGameplayCamRelativePitch()
			if camPitch < -70.0 then
				camPitch = -70.0
			elseif camPitch > 42.0 then
				camPitch = 42.0
			end
			camPitch = (camPitch + 70.0) / 112.0

			local camHeading = GetGameplayCamRelativeHeading()
			local cosCamHeading = Cos(camHeading)
			local sinCamHeading = Sin(camHeading)
			if camHeading < -180.0 then
				camHeading = -180.0
			elseif camHeading > 180.0 then
				camHeading = 180.0
			end
			camHeading = (camHeading + 180.0) / 360.0

			local blocked = 0
			local nn = 0
			local coords = GetOffsetFromEntityInWorldCoords(ped,
				(cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3
				)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
			local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2,
				0.4, 95,
				ped, 7);
			nn, blocked, coords, coords = GetRaycastResult(ray)

			Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
			Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)
			Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isBlocked", blocked)
			Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isFirstPerson",
				Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)
		end
		Citizen.Wait(idle)
	end
end)

--[ SYNCCLEAN ]--------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("syncclean")
AddEventHandler("syncclean", function(index)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToVeh(index)
		if DoesEntityExist(v) then
			if IsEntityAVehicle(v) then
				SetVehicleDirtLevel(v, 0.0)
				SetVehicleUndriveable(v, false)
				tvRP.DeletarObjeto()
			end
		end
	end
end)

--[ SYNCDELETEPED ]----------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("syncdeleteped")
AddEventHandler("syncdeleteped", function(index)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToPed(index)
		if DoesEntityExist(v) then
			Citizen.InvokeNative(0xAD738C3085FE7E11, v, true, true)
			SetPedAsNoLongerNeeded(Citizen.PointerValueIntInitialized(v))
			DeletePed(v)
		end
	end
end)
