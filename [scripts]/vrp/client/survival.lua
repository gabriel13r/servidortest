-----------------------------------------------------------------------------------------------------------------------------------------
--[ ARENA ]--------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
local in_arena = false

RegisterNetEvent("mirtin_survival:updateArena")
AddEventHandler("mirtin_survival:updateArena", function(boolean)
	in_arena = boolean
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ VARYHEALTH ]--------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.varyHealth(variation)
	local ped = PlayerPedId()
	local n = math.floor(GetEntityHealth(ped) + variation)
	SetEntityHealth(ped, n)
end

-----------------------------------------------------------------------------------------------------------------------------------------
--[ GETHEALTH ]--------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.getHealth()
	return GetEntityHealth(PlayerPedId())
end

-----------------------------------------------------------------------------------------------------------------------------------------
--[ SETHEALTH ]--------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.setHealth(health)
	SetEntityHealth(PlayerPedId(), parseInt(health))
	SendNUIMessage({ death = false })
	TriggerServerEvent('pma-voice:muteUpdate', false) --TESTE PMA
	TriggerScreenblurFadeOut(3000)
end

-----------------------------------------------------------------------------------------------------------------------------------------
--[ SETFRIENDLYFIRE ]--------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.setFriendlyFire(flag)
	NetworkSetFriendlyFireOption(flag)
	SetCanAttackFriendly(PlayerPedId(), flag, flag)
end

-----------------------------------------------------------------------------------------------------------------------------------------
--[ NOCAUTEVAR ]-------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
local nocauteado = false
local deathtimer = 600
-----------------------------------------------------------------------------------------------------------------------------------------
--[ NOCAUTEADO ]-------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local sleep = 1000
		local ped = PlayerPedId()
		if GetEntityHealth(ped) <= 101 and deathtimer >= 0 and not in_arena then
			sleep = 5
			if not nocauteado then
				local x, y, z = table.unpack(GetEntityCoords(ped))
				NetworkResurrectLocalPlayer(x, y, z, true, true, false)
				SendNUIMessage({ death = true })             --remover (gui bxd)
				TriggerServerEvent('pma-voice:muteUpdate', true) --TESTE PMA
				deathtimer = 600
				nocauteado = true
				vRPserver._updateHealth(101)
				SetEntityHealth(ped, 101)
				SetEntityInvincible(ped, true)
				SetPedArmour(ped, 0)
				if IsPedInAnyVehicle(ped) then
					TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped), 4160)
				end
				TriggerEvent("radio:outServers")
				TriggerServerEvent('guardararmas')
				TriggerScreenblurFadeIn(3000)
			else
				if deathtimer > 0 then
					SendNUIMessage({
						deathtext = "desacordado <br> <small>aguarde <color>" .. deathtimer .. " segundos</color></small>" })
				else
					SendNUIMessage({
						deathtext =
						"<color2>Você foi morto</color2> <br> <small>Pressione <color>E</color> para voltar ao aeroporto</small>"
					})
				end
				--SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
				--SetFollowPedCamViewMode(4)
				SetEntityHealth(ped, 101)
				BlockWeaponWheelThisFrame()
				DisableControlAction(0, 21, true)
				DisableControlAction(0, 22, true)
				DisableControlAction(0, 23, true)
				DisableControlAction(0, 24, true)
				DisableControlAction(0, 25, true)
				DisableControlAction(0, 29, true)
				DisableControlAction(0, 32, true)
				DisableControlAction(0, 33, true)
				DisableControlAction(0, 34, true)
				DisableControlAction(0, 35, true)
				DisableControlAction(0, 37, true)
				DisableControlAction(0, 47, true)
				DisableControlAction(0, 56, true)
				DisableControlAction(0, 58, true)
				DisableControlAction(0, 73, true)
				DisableControlAction(0, 75, true)
				DisableControlAction(0, 137, true)
				DisableControlAction(0, 140, true)
				DisableControlAction(0, 141, true)
				DisableControlAction(0, 142, true)
				DisableControlAction(0, 143, true)
				DisableControlAction(0, 166, true)
				DisableControlAction(0, 167, true)
				DisableControlAction(0, 168, true)
				DisableControlAction(0, 169, true)
				DisableControlAction(0, 170, true)
				DisableControlAction(0, 177, true)
				DisableControlAction(0, 182, true)
				DisableControlAction(0, 187, true)
				DisableControlAction(0, 188, true)
				DisableControlAction(0, 189, true)
				DisableControlAction(0, 190, true)
				DisableControlAction(0, 243, true)
				DisableControlAction(0, 249, true)
				DisableControlAction(0, 257, true)
				DisableControlAction(0, 263, true)
				DisableControlAction(0, 264, true)
				DisableControlAction(0, 268, true)
				DisableControlAction(0, 269, true)
				DisableControlAction(0, 270, true)
				DisableControlAction(0, 271, true)
				DisableControlAction(0, 288, true)
				DisableControlAction(0, 289, true)
				DisableControlAction(0, 311, true)
				DisableControlAction(0, 344, true)
				if not IsEntityPlayingAnim(ped, "dead", "dead_a", 3) and not IsPedInAnyVehicle(ped) then
					tvRP.playAnim(false, { { "dead", "dead_a" } }, true)
				end
			end
		end
		Citizen.Wait(sleep)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUTTONTIMER
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local sleep = 1000
		local ped = PlayerPedId()
		if GetEntityHealth(ped) <= 101 and deathtimer <= 0 then
			sleep = 1
			if IsControlJustPressed(0, 38) then
				vRPserver._removeFinalizado()
				TriggerServerEvent('mgk:Spawn:fome')
				TriggerEvent("resetBleeding")
				TriggerEvent("resetDiagnostic")
				TriggerEvent("resetWarfarina")
				SendNUIMessage({ death = false })             --remover NUI
				TriggerServerEvent('pma-voice:muteUpdate', false) --TESTE PMA
				--SetFollowPedCamViewMode(1)
				deathtimer = 600
				nocauteado = false
				TriggerScreenblurFadeOut(3000)
				ClearPedBloodDamage(ped)
				SetEntityInvincible(ped, false)
				DoScreenFadeOut(1000)
				SetEntityHealth(ped, 400)
				SetPedArmour(ped, 0)
				Citizen.Wait(1000)
				-- SetEntityCoords(ped,-461.19+0.0001,-335.01+0.0001,34.51+0.0001,1,0,0,1)
				SetEntityCoordsNoOffset(ped, 1116.74, -1562.48, 34.98, false, false, false, true)
				FreezeEntityPosition(ped, true)
				TriggerServerEvent("clearInventoryAfterDie")
				SetTimeout(5000, function()
					FreezeEntityPosition(ped, false)
					Citizen.Wait(1000)
					DoScreenFadeIn(1000)
				end)
			end
		end
		Wait(sleep)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ HEALTHRECHARGE ]---------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		SetPlayerHealthRechargeMultiplier(PlayerId(), 0)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ DEATHTIMER ]-------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if nocauteado and deathtimer > 0 then
			deathtimer = deathtimer - 1
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ DRAWTXT ]----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-- function drawTxt(text,font,x,y,scale,r,g,b,a)
-- 	SetTextFont(font)
-- 	SetTextScale(scale,scale)
-- 	SetTextColour(r,g,b,a)
-- 	SetTextOutline()
-- 	SetTextCentre(1)
-- 	SetTextEntry("STRING")
-- 	AddTextComponentString(text)
-- 	DrawText(x,y)
-- end
-----------------------------------------------------------------------------------------------------------------------------------------
--[ ISINCOMA ]---------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.isInComa()
	return nocauteado
end

-----------------------------------------------------------------------------------------------------------------------------------------
--[ FINALIZAR ]---------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.killComa()
	if nocauteado then
		deathtimer = 150
	end
end

RegisterNetEvent('vrp:setObito')
AddEventHandler('vrp:setObito', function()
	deathtimer = 0
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ FOME E SEDE ]---------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.sedeFome()
	vRPserver.varyHunger(-100)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10000) -- 6000
		if IsPlayerPlaying(PlayerId()) then
			local ped = PlayerPedId()
			local vthirst = 0.3
			local vhunger = 0.3

			if IsPedOnFoot(ped) and not tvRP.isNoclip() then
				--	local factor = math.min(tvRP.getSpeed(), 10)

				vthirst = vthirst + 0.1 -- *factor 0.3
				vhunger = vhunger + 0.1 -- *factor 0.3
			end

			if IsPedInMeleeCombat(ped) then
				vthirst = vthirst + 1
				vhunger = vhunger + 1
			end

			if IsPedHurt(ped) or IsPedInjured(ped) then
				vthirst = vthirst + 1
				vhunger = vhunger + 1
			end

			if vthirst > 0 then
				vRPserver.varyThirst(vthirst / 12.0)
			end

			if vhunger > 0 then
				vRPserver.varyHunger(vhunger / 12.0)
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ NETWORKRESSURECTION ]----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.killGod()
	nocauteado = false
	local ped = PlayerPedId()
	local x, y, z = table.unpack(GetEntityCoords(ped))
	NetworkResurrectLocalPlayer(x, y, z, true, true, false)
	ClearPedBloodDamage(ped)
	SetEntityInvincible(ped, false)
	SendNUIMessage({ death = false })                --remover NUI
	TriggerServerEvent('pma-voice:muteUpdate', false) --TESTE PMA
	TriggerScreenblurFadeOut(3000)
	SetEntityHealth(ped, 110)
	ClearPedTasks(ped)
	ClearPedSecondaryTask(ped)
	--SetFollowPedCamViewMode(1)
end

-----------------------------------------------------------------------------------------------------------------------------------------
--[ NETWORKPRISON ]----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.PrisionGod()
	local ped = PlayerPedId()
	if GetEntityHealth(ped) <= 101 then
		nocauteado = false
		ClearPedBloodDamage(ped)
		SetEntityInvincible(ped, false)
		SetEntityHealth(ped, 110)
		ClearPedTasks(ped)
		ClearPedSecondaryTask(ped)
	end
end
