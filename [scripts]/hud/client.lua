local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
ALIENserver = Tunnel.getInterface('hud')
ALIEN = {}
Tunnel.bindInterface('hud', ALIEN)

ALIEN.ready = true

local hour = 0
local minute = 0
local month = ""
local dayOfMonth = 0

-----------------------------------------------------------------------------------------------------------------------------------------
-- SEATBELT
-----------------------------------------------------------------------------------------------------------------------------------------
local beltLock = 0
local beltSpeed = 0
local beltVelocity = 0

local hunger = 100
local thirst = 100
local hudoff = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- STATUSHUNGER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("statusHunger")
AddEventHandler("statusHunger",function(number)
	hunger = parseInt(number)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FOME
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("statusThirst")
AddEventHandler("statusThirst",function(number)
	thirst = parseInt(number)
end)

RegisterNetEvent("vrp_hud:update")
AddEventHandler("vrp_hud:update", function(rHunger, rThirst)
  hunger, thirst = rHunger, rThirst
end)

inCar = false
Citizen.CreateThread(function()
while true do
	local hyper = 1000
	local ped = PlayerPedId()
	inCar = IsPedInAnyVehicle(ped, false)

	if inCar then 
		vehicle = GetVehiclePedIsIn(ped, false)
		local vida = math.ceil((100 * ((GetEntityHealth(ped) - 100) / (GetEntityMaxHealth(ped) - 100))))
		local armour = GetPedArmour(ped)
		local stamina = 100 - GetPlayerSprintStaminaRemaining(PlayerId())

		SendNUIMessage({
			action = "inCar",
			health = vida,
			armour = armour,
			stamina = stamina,
			hunger = parseInt(hunger),
			thirst = parseInt(thirst),
			hudoff = hudoff,
		})	
	end
	Citizen.Wait(hyper)	
end
end)

local streetLast = 0
local flexDirection = "Norte"
Citizen.CreateThread(function()
	while true do
		local hyper = 1000
		local ped = PlayerPedId()
		local x,y,z = table.unpack(GetEntityCoords(ped,false))
		local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))
		local coords = GetEntityCoords(ped)
		local heading = GetEntityHeading(ped)
		local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords["x"],coords["y"],coords["z"]))
		if heading >= 315 or heading < 45 then
			flexDirection = "Norte"
		elseif heading >= 45 and heading < 135 then
			flexDirection = "Oeste"
		elseif heading >= 135 and heading < 225 then
			flexDirection = "Sul"
		elseif heading >= 225 and heading < 315 then
			flexDirection = "Leste"
		end
		hours = GetClockHours()
		minutes = GetClockMinutes()
	
		if hours <= 9 then
			hours = "0"..hours
		end
	
		if minutes <= 9 then
			minutes = "0"..minutes
		end
		local horario = hours..":"..minutes

		SendNUIMessage({
			action = "horarios",
			time = horario,
			direction = flexDirection,
			street = streetName,
		})	

		Citizen.Wait(hyper)	
	end
end)

Citizen.CreateThread(function()
	while true do
		local hyper = 1000
		if inCar then 
			hyper = 0
			local speed = math.ceil(GetEntitySpeed(vehicle) * 3.605936)
			if IsVehicleDriveable(vehicle, 0) then
				local marcha = GetVehicleCurrentGear(vehicle)
				local fuel = GetVehicleFuelLevel(vehicle)
				local engine = GetVehicleEngineHealth(vehicle)

				carGear = GetVehicleCurrentGear(vehicle)
				rpm = GetVehicleCurrentRpm(vehicle)
				rpm = math.ceil(rpm * 10000, 2)
				vehicleNailRpm = 280 - math.ceil( math.ceil((rpm-2000) * 140) / 10000)

				local farol = "off"
				local _,lights,highlights = GetVehicleLightsState(vehicle)
				if lights == 1 and highlights == 0 then 
					farol = "normal"
				elseif (lights == 1 and highlights == 1) or (lights == 0 and highlights == 1) then 
					farol = "alto"
				end
			
				local vehicleGear = GetVehicleCurrentGear(vehicle)
			
				if speed > 0 and vehicleGear == 0 then
					vehicleGear = 7
				end

				local alien = GetVehicleClass(vehicle)
				if beltLock == 1 or alien == 19 or alien == 8 or alien == 13 or alien == 15 or alien == 18 then
					DisplayRadar(true)
				else
					DisplayRadar(false)
				end

				

				SendNUIMessage({
					only = "updateSpeed",
					speed = speed,
					marcha = carGear,
					gear = vehicleGear,
					fuel = parseInt(fuel),
					engine = math.ceil((engine / 1000) * 100),
					rpmnail = vehicleNailRpm,
					rpm = rpm/100,
					cinto = CintoSeguranca,
					hudoff = hudoff,
					seatbelt = beltLock,
					farol = farol,
				})
			end		
		end
		Citizen.Wait(hyper)	
	end
end)

Citizen.CreateThread(function()
	while true do
		local hyper = 1000
		if not inCar then 
			local ped = PlayerPedId()
			DisplayRadar(false)

			local vida = math.ceil((100 * ((GetEntityHealth(ped) - 100) / (GetEntityMaxHealth(ped) - 100))))
			local armour = GetPedArmour(ped)
			local stamina = 100 - GetPlayerSprintStaminaRemaining(PlayerId())

			SendNUIMessage({
				action = "update",
				health = vida,
				armour = armour,
				stamina = stamina,
				street = street,
				hudoff = hudoff,
				hunger = parseInt(hunger),
				thirst = parseInt(thirst),
			})			

		end
		Citizen.Wait(hyper)	
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FOWARDPED
-----------------------------------------------------------------------------------------------------------------------------------------
function fowardPed(ped)
	local heading = GetEntityHeading(ped) + 90.0
	if heading < 0.0 then
		heading = 360.0 + heading
	end

	heading = heading * 0.0174533

	return { x = math.cos(heading) * 2.0, y = math.sin(heading) * 2.0 }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADBELT
-----------------------------------------------------------------------------------------------------------------------------------------
local CintoSeguranca2 = true
Citizen.CreateThread(function()
	while true do
		local timeDistance = 999
		if true then
			local ped = PlayerPedId()
			if IsPedInAnyVehicle(ped) then
				if not IsPedOnAnyBike(ped) and not IsPedInAnyPlane(ped) then
					if CintoSeguranca2 == true then
						DisableControlAction(0,75)
						DisableControlAction(1,75)
						DisableControlAction(0,23)
						DisableControlAction(1,23)
					end
					timeDistance = 1

					local vehicle = GetVehiclePedIsUsing(ped)
					local speed = GetEntitySpeed(vehicle) * 3.6
					if speed ~= beltSpeed then
						local plate = GetVehicleNumberPlateText(vehicle)

						if ((beltSpeed - speed) >= 50 and beltLock == 0) or ((beltSpeed - speed) >= 75 and beltLock == 1 and plate == nil and GetPedInVehicleSeat(vehicle,-1) == ped) then
							local fowardVeh = fowardPed(ped)
							local coords = GetEntityCoords(ped)
							SetEntityCoords(ped,coords["x"] + fowardVeh["x"],coords["y"] + fowardVeh["y"],coords["z"] + 1,1,0,0,0)
							SetEntityVelocity(ped,beltVelocity["x"],beltVelocity["y"],beltVelocity["z"])
							ApplyDamageToPed(ped,50,false)

							Citizen.Wait(1)

							SetPedToRagdoll(ped,5000,5000,0,0,0,0)
						end

						beltVelocity = GetEntityVelocity(vehicle)
						beltSpeed = speed
					end
				end
			else
				if beltSpeed ~= 0 then
					beltSpeed = 0
				end

				if beltLock == 1 then
					beltLock = 0
				end
			end
		end

		Citizen.Wait(timeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SEATBELT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("seatbelt",function(source,args)
	local ped = PlayerPedId()
	if IsPedInAnyVehicle(ped) then
		if not IsPedOnAnyBike(ped) then
			if beltLock == 1 then
				TriggerEvent("vrp_sound:source","unbelt",0.5)
				beltLock = 0
				CintoSeguranca2 = false
			else
				TriggerEvent("vrp_sound:source","belt",0.5)
				beltLock = 1
				CintoSeguranca2 = true

			end
		end
	end
end)

RegisterCommand('+indicatorlights',function(source,args)
	local ped = PlayerPedId()
	local isIn = IsPedInAnyVehicle(ped,false)
	if isIn then
	local vehicle = GetVehiclePedIsIn(ped, false)
	local lights = GetVehicleIndicatorLights(vehicle)
			if args[1] == 'up' then
				lightState = 'up'
				SetVehicleIndicatorLights(vehicle,0,true)
				SetVehicleIndicatorLights(vehicle,1,true)
			elseif args[1] == 'left' then
				lightState = 'left'
				SetVehicleIndicatorLights(vehicle,1,true)
				SetVehicleIndicatorLights(vehicle,0,false)
			elseif args[1] == 'right' then
				lightState = 'right'
				SetVehicleIndicatorLights(vehicle,0,true)
				SetVehicleIndicatorLights(vehicle,1,false)
			elseif args[1] == 'off' and lights >= 0 then
				lightState = 'off'
				SetVehicleIndicatorLights(vehicle,0,false)
				SetVehicleIndicatorLights(vehicle,1,false)
			end
	end
end)

RegisterKeyMapping("+indicatorlights up","Ambas setas.","keyboard","UP")
RegisterKeyMapping("+indicatorlights left","Seta para esquerda.","keyboard","LEFT")
RegisterKeyMapping("+indicatorlights right","Seta para direita.","keyboard","RIGHT")
RegisterKeyMapping("+indicatorlights off","Desligar setas.","keyboard","BACK")

-----------------------------------------------------------------------------------------------------------------------------------------
-- KEYMAPPING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("seatbelt","Colocar/Retirar o cinto.","keyboard","g")

RegisterCommand("hud",function(source,args)
	hudoff = not hudoff
end)

-- RegisterCommand('seat', function(source, args, rawCmd)
-- 	local ped = PlayerPedId()
-- 	if IsPedInAnyVehicle(ped, false) then	
-- 		local carrinhu = GetVehiclePedIsIn(ped, false)
-- 		if not seatbeltIsOn then
-- 			if args[1] then
-- 				local acento = parseInt(args[1])
				
-- 				if acento == 1 then
-- 					if IsVehicleSeatFree(carrinhu, -1) then 
-- 						if GetPedInVehicleSeat(carrinhu, 0) == ped then
-- 							SetPedIntoVehicle(ped, carrinhu, -1)
-- 						else
-- 							TriggerEvent('Notify', 'negado','Você só pode passar para o P1 a partir do P2.')
-- 						end
-- 					else
-- 						TriggerEvent('Notify','negado','O acento deve estar livre.')
-- 					end
-- 				elseif acento == 2 then
-- 					if IsVehicleSeatFree(carrinhu, 0) then 
-- 						if GetPedInVehicleSeat(carrinhu, -1) == ped then
-- 							SetPedIntoVehicle(ped, carrinhu, 0)
-- 						else
-- 							TriggerEvent('Notify', 'negado','Você só pode passar para o P2 a partir do P1.')
-- 						end
-- 					else
-- 						TriggerEvent('Notify', 'negado','O acento deve estar livre.')
-- 					end
-- 				elseif acento == 3 then
-- 					if IsVehicleSeatFree(carrinhu, 1) then 
-- 						if GetPedInVehicleSeat(carrinhu, 2) == ped then
-- 							SetPedIntoVehicle(ped, carrinhu, 1)
-- 						else
-- 							TriggerEvent('Notify', 'negado','Você só pode passar para o P3 a partir do P4.')
-- 						end
-- 					else
-- 						TriggerEvent('Notify', 'negado','O acento deve estar livre.')
-- 					end
-- 				elseif acento == 4 then
-- 					if IsVehicleSeatFree(carrinhu, 2) then 
-- 						if GetPedInVehicleSeat(carrinhu, 1) == ped then
-- 							SetPedIntoVehicle(ped, carrinhu, 2)
-- 						else
-- 							TriggerEvent('Notify', 'negado','Você só pode passar para o P4 a partir do P3.')
-- 						end
-- 					else
-- 						TriggerEvent('Notify', 'negado','O acento deve estar livre.')
-- 					end
-- 				end
-- 			else
-- 				TriggerEvent('Notify', 'negado','Especifique o acento que quer ir!')
-- 			end
-- 		else
-- 			TriggerEvent('Notify', 'negado','Você não pode utilizar esse comando com o cinto de segurança!')
-- 		end
-- 	end
-- end)
	
RegisterCommand("cr",function(source,args)
	local veh = GetVehiclePedIsIn(PlayerPedId(),false)
	local maxspeed = GetVehicleMaxSpeed(GetEntityModel(veh))
	local vehspeed = GetEntitySpeed(veh)*3.605936
	if GetPedInVehicleSeat(veh,-1) == PlayerPedId() and math.ceil(vehspeed) >= 0 and GetEntityModel(veh) ~= -2076478498 and not IsEntityInAir(veh) then
		if args[1] == nil then
			SetEntityMaxSpeed(veh,maxspeed)
			TriggerEvent("Notify","sucesso","Limitador de Velocidade desligado com sucesso.")
		else
			SetEntityMaxSpeed(veh,0.45*args[1]-0.45)
			TriggerEvent("Notify","sucesso","Velocidade máxima travada em <b>"..args[1].." KM/H</b>.")
		end
	end
end)

RegisterNetEvent("vrp_hud:VoiceTalking")
AddEventHandler("vrp_hud:VoiceTalking", function(boolean)
    SendNUIMessage({action = "talking", boolean = boolean})
end)

RegisterNetEvent("hud:channel")
AddEventHandler("hud:channel", function(text)
    SendNUIMessage({action = "channel", radio = text})
end)

AddEventHandler("pma-voice:setTalkingMode", function(number)
    SendNUIMessage({action = "proximity", voice = number})
end)
 
local StatusCarro = true
Citizen.CreateThread(function()
    while true do
		local hyper = 1000
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
			hyper = 1000
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local lockStatus = GetVehicleDoorLockStatus(vehicle)
            if (lockStatus == 1) then
				StatusCarro = true
                SendNUIMessage({
					lock = "fecharcarro", 
					status = StatusCarro,
				})
            elseif lockstatus ~= 1 then
				StatusCarro = false
                SendNUIMessage({
					lock = "fecharcarro", 
					status = StatusCarro,
				})
            end
        end
		Citizen.Wait(hyper)	
    end
end)


Citizen.CreateThread(function()
	while true do
		local ped = PlayerPedId()
		if GetEntityHealth(ped) > 101 then
			if hunger >= 6 and hunger <= 15 then
				ApplyDamageToPed(ped,1,false)
				TriggerEvent("Notify","aviso","Você está sentindo muita fome.",5000)
			elseif hunger <= 5 then
				ApplyDamageToPed(ped,2,false)
                TriggerEvent("Notify","aviso","Você está sentindo muita fome.",5000)
			end

			if thirst >= 6 and thirst <= 15 then
				ApplyDamageToPed(ped,1,false)
				TriggerEvent("Notify","aviso","Você está sentindo muita sede.",5000)
			elseif thirst <= 5 then
				ApplyDamageToPed(ped,2,false)
				TriggerEvent("Notify","aviso","Você está sentindo muita sede.",5000)
			end
		end
		Citizen.Wait(15000)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- SETWAY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("setWay",function(data)
    SetNewWaypoint(data.x+0.0001,data.y+0.0001)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADCIRCLE
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	DisplayRadar(false)

	RequestStreamedTextureDict("circlemap",false)
	while not HasStreamedTextureDictLoaded("circlemap") do
		Citizen.Wait(100)
	end

	AddReplaceTexture("platform:/textures/graphics","radarmasksm","circlemap","radarmasksm")

	SetMinimapClipType(1)
	SetMinimapComponentPosition("minimap","L","B",0.009,-0.0125,0.16,0.28)
	SetMinimapComponentPosition("minimap_mask","L","B",0.155,0.12,0.080,0.15)
	SetMinimapComponentPosition("minimap_blur","L","B",0.0095,0.015,0.229,0.311)

	SetBigmapActive(true,false)

	Citizen.Wait(5000)

	SetBigmapActive(false,false)
end)

