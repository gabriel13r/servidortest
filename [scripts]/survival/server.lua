function src.receberMorte(source, motivo, ksource)
    if source == 0 or source == nil then
    return
end
    
local user_id = vRP.getUserId(source)
    if user_id then
        local discord_UserID = GetPlayerIdentifiers(source)
        local coords = GetEntityCoords(GetPlayerPed(source))
        local kuser_id = "Ninguem"
        local discord_kUserID
        if ksource ~= 0 or ksource == nil then
            local id = vRP.getUserId(ksource)
            if id then
                kuser_id = "ID: "..id
                discord_kUserID = GetPlayerIdentifiers(ksource)
            end
        end
        local discordID = ""
        if discord_UserID ~= nil then
            for k,v in pairs(discord_UserID) do
                if string.find(v,"discord:") then
                    discordID = "<@"..string.gsub(v, "discord:","")..">\n"
                end
            end
        end

        local discordkID = ""
        if discord_kUserID ~= nil then
            for k,v in pairs(discord_kUserID) do
                if string.find(v,"discord:") then
                    discordkID = "<@"..string.gsub(v, "discord:","")..">\n"
                end
            end
        end
        if user_id == nil or kuser_id == nil then
            return
        end

        vRP.sendLog('survival',"[ID]: "..user_id.."  "..discordID.."\n[Causa da Morte]: "..motivo.."\n[Assasino]: "..kuser_id.." "..discordkID.."\n[Coordenadas]: "..tD(coords[1])..","..tD(coords[2])..","..tD(coords[3]).."\n[Horario]: "..os.date("[%d/%m/%Y as %H:%M]"), true)
    end
end

function sendToDiscord(weebhook, message)
    PerformHttpRequest(weebhook, function(err, text, headers) end, 'POST', json.encode({embeds = message}), { ['Content-Type'] = 'application/json' })
end

function tD(n)
    n = math.ceil(n * 100) / 100
    return n
end

function src.removeBackpack()
    local source = source
    local user_id = vRP.getUserId(source)
    local valor = 0
    if vRP.getBackpack(user_id) == 6 or vRP.getBackpack(user_id) == 5 or vRP.getBackpack(user_id) == 0 then
        valor = 5
    elseif vRP.getBackpack(user_id) == 30 then
        valor = 5
    elseif vRP.getBackpack(user_id) == 60 then
        valor = 5
    elseif vRP.getBackpack(user_id) == 90 then
        valor = 5
    end
    vRP.setBackpack(user_id, valor)
end