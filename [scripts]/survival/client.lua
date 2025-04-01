local reasonDeath
local pedKiller
local Killer
local enable = true
local cooldown = 0
local morto = false
local deathtimer = cfg.deathtimer
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- THREAD
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
        local time = 180
		local ped = PlayerPedId()
		local vida = GetEntityHealth(ped)
		local x,y,z = table.unpack(GetEntityCoords(ped,true))
        if cfg.dependencys() then
            if IsEntityDead(ped) then
                time = 0
                if GetPedCauseOfDeath(ped) ~= 0 and cooldown == 0 then
                    cooldown = cfg.cooldown
                    reasonDeath = GetPedCauseOfDeath(ped)
                    pedKiller = GetPedSourceOfDeath(ped)

                    if IsEntityAPed(pedKiller) and IsPedAPlayer(pedKiller) then
                        Killer = NetworkGetPlayerIndexFromPed(pedKiller)
                    elseif IsEntityAVehicle(pedKiller) and IsEntityAPed(GetPedInVehicleSeat(pedKiller, -1)) and IsPedAPlayer(GetPedInVehicleSeat(pedKiller, -1)) then
                        Killer = NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(pedKiller, -1))
                    end

                    sendToLog(PlayerId(), reasonDeath, Killer)
                end 

                NetworkResurrectLocalPlayer(x,y,z,true,true, false)
                SetEntityInvincible(ped,true)
                --SetPedDiesInWater(ped, false)
                SetEntityHealth(ped, cfg.minHealth)
            end

            if vida <= cfg.minHealth and not morto then
                morto = true
                SetEntityHealth(ped, cfg.minHealth)
                vRPserver.updateHealth(cfg.minHealth)
                -- print("Atualizou vida para: "..cfg.minHealth)
                TriggerEvent('radio:Outservers')
                TriggerEvent('survival:updateComa', morto)
                TriggerServerEvent("pma-voice:toggleMutePlayer",true)
            end

            if morto then
                if vida <= cfg.minHealth then
                    time = 5
                        cfg.animDeath()

                    if cfg.versionNUI then
                        if enable then
                            openNui()
                        end
                    else
                        cfg.drawtext(deathtimer)
                    end
                end

                if vida > cfg.minHealth then
                    morto = false
                    block = false
                    deathtimer = cfg.deathtimer
                    SetEntityInvincible(ped,false)
                    --SetPedDiesInWater(ped, true)
                    TriggerEvent('survival:updateComa', morto)
                    StopScreenEffect("DeathFailMPIn")
                    vRPserver.updateHealth(GetEntityHealth(ped))
                    TriggerServerEvent("pma-voice:toggleMutePlayer",false)
                    vRP._stopAnim(false)
                    
                    if cfg.versionNUI then
                        closeNui()
                    end
                end

                if deathtimer <= 0 then
                    if cfg.timedown then
                        morrer()
                    end
                end
            end
        end

        Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTION
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sendToLog = function(idMorto, motivoMorto, quemMatou)
    local source = 0
    local ksource = 0
    local motivo = ""

    if idMorto ~= 0 then
        source = GetPlayerServerId(idMorto)
    end

    if quemMatou ~= 0 then
        ksource = GetPlayerServerId(quemMatou)
    end
    
    if cfg.reasons[motivoMorto] then
        motivo = cfg.reasons[motivoMorto]
    else
        motivo= cfg.reasons[0]
    end

    vSERVER.receberMorte(source, motivo, ksource)
end

morrer = function()

    Citizen.Wait(500)
    SetEntityHealth(PlayerPedId(), cfg.maxHealth)
    morto = false
    block = false
    deathtimer = cfg.deathtimer

    StopScreenEffect("DeathFailMPIn")
    if cfg.versionNUI then
        closeNui()
    end

    TriggerEvent('survival:updateComa', morto)
    TriggerServerEvent("pma-voice:toggleMutePlayer",false)
    TriggerEvent("resetBleeding")
	TriggerEvent("resetDiagnostic")
    DoScreenFadeOut(500)

    Citizen.Wait(2000)
    SetEntityInvincible(PlayerPedId(),false)
    SetPedDiesInWater(PlayerPedId(), true)
    ClearPedBloodDamage(PlayerPedId())

    Citizen.Wait(3000)
    SetEntityCoords(PlayerPedId(), cfg.respawn)
    cfg.clearAccount()
    vSERVER.removeBackpack()
    
    Citizen.Wait(4000)
    DoScreenFadeIn(1000)
end

RegisterNetEvent("survival:updateComa")

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NUI
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
openNui = function()
    SetNuiFocus(true,true)
    TransitionToBlurred(1000)
    SendNUIMessage({ setDisplay = true, setDisplayDead = false, deathtimer = deathtimer })
end

closeNui = function()
    SetNuiFocus(false,false)
	TransitionFromBlurred(1000)
    SendNUIMessage({ setDisplay = false, setDisplayDead = false, deathtimer = deathtimer })
end

RegisterNUICallback('ButtonRevive', function()
    if deathtimer <= cfg.deathNUItimer then
        cfg.clearAccount()

        Wait(1000)
        morrer()
    else
        TriggerEvent("Notify","negado","Você não pode desistir de sua vida agora.", 5000)
    end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONTADOR
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local time = 1000
        
        if cooldown > 0 then
            cooldown = cooldown - 1

            if cooldown <= 0 then
                cooldown = 0
            end
        end

        if morto then
            deathtimer = deathtimer - 1

            if deathtimer <= 0 then
                deathtimer = 0
            end
        end

        Citizen.Wait(time)
    end
end)

RegisterNetEvent("survival:updateTime")
AddEventHandler("survival:updateTime", function(time) 
    deathtimer = time
end)

RegisterNetEvent("survival:setHud")
AddEventHandler("survival:setHud", function(boolean) 
    if morto then
        SetNuiFocus(boolean,boolean)
        TransitionFromBlurred(1000)
        SendNUIMessage({ setDisplay = boolean, setDisplayDead = false, deathtimer = deathtimer })
        enable = boolean
    end
end)

function src.getDeathTime()
    return deathtimer
end

RegisterNetEvent("finalizar")
AddEventHandler("finalizar",function(time)
    deathtimer = time
end)