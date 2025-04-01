local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
src = {}
Tunnel.bindInterface("chat", src)

vCLIENT = Tunnel.getInterface("chat")

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
function SendWebhookMessage(webhook, message)
	if webhook ~= nil and webhook ~= "" then
		PerformHttpRequest(webhook, function(err, text, headers)
			end, 'POST', json.encode({ content = message }),
			{ ['Content-Type'] = 'application/json' })
	end
end

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
RegisterServerEvent('chat:init')
RegisterServerEvent('chat:addTemplate')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:addSuggestion')
RegisterServerEvent('chat:removeSuggestion')
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('chat:clear')
RegisterServerEvent('__cfx_internal:commandFallback')

AddEventHandler('_chat:messageEntered', function(author, color, message)
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if not message or not author or not identity then
		return
	end
	if not WasEventCanceled() then
		TriggerClientEvent('chatMessageProximity', -1, source, identity.name, identity.firstname, message)
	end
end)

AddEventHandler('__cfx_internal:commandFallback', function(command)
	local name = GetPlayerName(source)
	if not command or not name then
		return
	end
	if not WasEventCanceled() then
		TriggerEvent('chatMessage', source, name, '/' .. command)
	end
	CancelEvent()
end)

-- command suggestions for clients
local function refreshCommands(player)
	if GetRegisteredCommands then
		local registeredCommands = GetRegisteredCommands()
		local suggestions = {}
		for _, command in ipairs(registeredCommands) do
			if IsPlayerAceAllowed(player, ('command.%s'):format(command.name)) then
				table.insert(suggestions, {
					name = '/' .. command.name,
					help = ''
				})
			end
		end
		TriggerClientEvent('chat:addSuggestions', player, suggestions)
	end
end

AddEventHandler('chat:init', function()
	refreshCommands(source)
end)

AddEventHandler('onServerResourceStart', function(resName)
	Wait(500)
	for _, player in ipairs(GetPlayers()) do
		refreshCommands(player)
	end
end)

RegisterCommand('limparchat', function(source)
	local user_id = vRP.getUserId(source);
	if user_id ~= nil then
		if vRP.hasPermission(user_id, "magisk.permissao") then
			TriggerClientEvent("chat:clear", -1);
		else
			TriggerClientEvent("chat:clear", source);
		end
	end
end)



RegisterCommand('panucio', function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id, "suporte.permissao") or vRP.hasPermission(user_id, "policia.permissao") or
			vRP.hasPermission(user_id, "comando.permissao") or vRP.hasPermission(user_id, "news.permissao") then
		local identity = vRP.getUserIdentity(user_id)

		local title = vRP.prompt(source, "Titulo:", "")
		if title == "" then
			return
		end

		local mensagem = vRP.prompt(source, "Mensagem:", "")
		if mensagem == "" then
			return
		end

		local time = vRP.prompt(source, "Tempo em segundos:", "")
		if time == "" and parseInt(time) == 0 then
			return
		end

		TriggerClientEvent('Anuncio', -1, title, mensagem, (time * 1000), identity.name .. " " .. identity.firstname)
	end
end)

------------------------------------------------------------------------------------------------------------------------------
--[ANUNCIO ADEMIRO CHAT]-----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("cupula", function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)

	if user_id then
		if vRP.hasPermission(user_id, "moderador.permissao") then
			local message = vRP.prompt(source, "Mensagem:", "")
			if message == "" then
				return
			end

			local time = vRP.prompt(source, "Minutos:", "")
			if time == "" then
				return
			end

			if tonumber(time) > 2 or tonumber(time) < 1 then
				TriggerClientEvent("Notify", source, "negado", "O tempo deve ser entre <b>1</b> e <b>2 minutos</b>.",
					5000)
				return
			end

			-- local name = vRP.prompt(source,"Nome:","Administrador")
			-- if name == "" then
			--     return
			-- end

			TriggerClientEvent("Notify", -1, "aviso", message .. "<br><br><b>Mensagem enviada por: </b>Cúpula",
				time * 24 * 60 * 60)
			SendWebhookMessage(config.AdminAnnounce,
				"```prolog\n[ADMINISTRADOR ANUNCIO]\n[QUEM ENVIOU]: [" ..
				user_id ..
				"] " ..
				identity.name ..
				" " ..
				identity.firstname .. "\n[Mensagem]: " .. message .. os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
		end
	end
end)

RegisterCommand('advogado', function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id, "advogado.permissao") or vRP.hasPermission(user_id, "policia.permissao") or
			vRP.hasPermission(user_id, "comando.permissao") or vRP.hasPermission(user_id, "news.permissao") then
		local identity = vRP.getUserIdentity(user_id)

		local title = vRP.prompt(source, "Titulo:", "")
		if title == "" then
			return
		end

		local mensagem = vRP.prompt(source, "Mensagem:", "")
		if mensagem == "" then
			return
		end

		local time = vRP.prompt(source, "Tempo em segundos:", "")
		if time == "" and parseInt(time) == 0 then
			return
		end

		TriggerClientEvent('Anuncio', -1, title, mensagem, (time * 1000), identity.name .. " " .. identity.firstname)
	end
end)

RegisterCommand('beanmachine', function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id, "beanmachine.permissao") or vRP.hasPermission(user_id, "beanmachine.permissao") or
			vRP.hasPermission(user_id, "beanmachine.permissao") or vRP.hasPermission(user_id, "beanmachine.permissao") then
		local identity = vRP.getUserIdentity(user_id)

		local title = vRP.prompt(source, "Titulo:", "")
		if title == "" then
			return
		end

		local mensagem = vRP.prompt(source, "Mensagem:", "")
		if mensagem == "" then
			return
		end

		local time = vRP.prompt(source, "Tempo em segundos:", "")
		if time == "" and parseInt(time) == 0 then
			return
		end

		TriggerClientEvent('Anuncio', -1, title, mensagem, (time * 1000), identity.name .. " " .. identity.firstname)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT ADMIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('aa', function(source, args, rawCommand)
	if not exports["chat"]:statusChatServer(source) then return end
	if args[1] then
		local user_id = vRP.getUserId(source)
		local title = vRP.getUserGroupByType(user_id, "staff")
		local identity = vRP.getUserIdentity(user_id)
		local permission = "suporte.permissao"

		if vRP.hasPermission(user_id, permission) then
			local admin = vRP.getUsersByPermission(permission)
			for l, w in pairs(admin) do
				local player = vRP.getUserSource(parseInt(w))
				if player then
					async(function()
						TriggerClientEvent('chatMessage', player,
							"" .. os.date("[%H:%M:%S]") .. " [" .. title .. "] " ..
							identity.name .. " " .. identity.firstname .. " #" .. user_id .. ": ", { 255, 0, 255 },
							rawCommand:sub(3))
						SendWebhookMessage(config.AdminChat,
							"```prolog\n[ADMIN CHAT INTERNO]\n[Nome]: [" ..
							user_id ..
							"] " ..
							identity.name ..
							" " ..
							identity.firstname .. "\n[Mensagem]: " .. rawCommand:sub(3) ..
							os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
					end)
				end
			end
		end
	end
end)

RegisterCommand('cc', function(source, args, rawCommand)
	if not exports["chat"]:statusChatServer(source) then return end
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		local permission = "magisk.permissao"
		local title = vRP.getUserGroupByType(user_id, "staff")
		if vRP.hasPermission(user_id, permission) then
			local soldado = vRP.getUsersByPermission(permission)
			for l, w in pairs(soldado) do
				local player = vRP.getUserSource(parseInt(w))
				if player then
					async(function()
						TriggerClientEvent('chatMessage', player,
							"[" .. title .. "] " .. identity.name .. " " .. identity.firstname .. " #" .. user_id .. ": ",
							{ 100, 149, 237 },
							rawCommand:sub(3))
					end)
				end
			end
		end
	end
end)
------------------------------------------------------------------------------------------------------------------------------
--[ CHAT VIP ]-----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('v', function(source, args, rawCommand)
	if not exports["chat"]:statusChatServer(source) then return end
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		local permission = "chatvip.permissao"
		local title = vRP.getUserGroupByType(user_id, "vip")
		if vRP.hasPermission(user_id, permission) then
			local vip = vRP.getUsersByPermission(permission)
			for l, w in pairs(vip) do
				local player = vRP.getUserSource(parseInt(w))
				if player then
					async(function()
						TriggerClientEvent('chatMessage', player,
							"[" .. title .. "] " .. identity.name .. " " .. identity.firstname .. " #" .. user_id .. ": ",
							{ 100, 149, 237 },
							rawCommand:sub(3))
						SendWebhookMessage(config.ChatVip,
							"```prolog\n[Chat Vip]\n[Nome]: [" ..
							user_id ..
							"] " ..
							identity.name ..
							" " .. identity.firstname ..
							"\n[Mensagem]: " .. rawCommand:sub(4) .. os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
					end)
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ CHAT GLOBAL VILLE RACING ]--------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('vc', function(source, args, rawCommand)
	if not exports["chat"]:statusChatServer(source) then return end
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		if vRP.hasPermission(user_id, "villeracing.permissao") then
			if user_id then
				TriggerClientEvent('chatMessage', -1,
					"[VILLERACING] " .. identity.name .. " " .. identity.firstname .. ":",
					{ 135, 206, 250 }, rawCommand:sub(4))
				SendWebhookMessage(config.MecanicoChat,
					"```prolog\n[VILLE GLOBAL]\n[Nome]: [" ..
					user_id ..
					"] " ..
					identity.name ..
					" " .. identity.firstname ..
					"\n[Mensagem]: " .. rawCommand:sub(4) .. os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ CHAT INTERNO VILLE RACING ] -------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('vi', function(source, args, rawCommand)
	if not exports["chat"]:statusChatServer(source) then return end
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		local permission = "villeracing.permissao"
		if vRP.hasPermission(user_id, permission) then
			local colaboradordmla = vRP.getUsersByPermission(permission)
			for l, w in pairs(colaboradordmla) do
				local player = vRP.getUserSource(parseInt(w))
				if player then
					async(function()
						TriggerClientEvent('chatMessage', player,
							"[VILLERACING INTERNO] " ..
							identity.name .. " " .. identity.firstname .. " [" .. user_id .. "]: ",
							{ 135, 206, 250 }
							, rawCommand:sub(3))
						SendWebhookMessage(config.MecInterno,
							"```prolog\n[VILLERACING INTERNO]\n[Nome]: [" ..
							user_id ..
							"] " ..
							identity.name ..
							" " ..
							identity.firstname .. "\n[Mensagem]: " .. rawCommand:sub(3) ..
							os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
					end)
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ CHAT INTERNO VILLE PERFORMANCE] -------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterCommand('vp', function(source, args, rawCommand)
	if not exports["chat"]:statusChatServer(source) then return end
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		local permission = "villeperformance.permissao"
		if vRP.hasPermission(user_id, permission) then
			local colaboradordmla = vRP.getUsersByPermission(permission)
			for l, w in pairs(colaboradordmla) do
				local player = vRP.getUserSource(parseInt(w))
				if player then
					async(function()
						TriggerClientEvent('chatMessage', player,
							"[V.PERFORMANCE INTERNO] " ..
							identity.name .. " " .. identity.firstname .. " [" .. user_id .. "]: ",
							{ 135, 206, 250 }
							, rawCommand:sub(3))
						SendWebhookMessage(config.MecInterno,
							"```prolog\n[VILLEPERFORMANCE INTERNO]\n[Nome]: [" ..
							user_id ..
							"] " ..
							identity.name ..
							" " ..
							identity.firstname .. "\n[Mensagem]: " .. rawCommand:sub(3) ..
							os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
					end)
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ CHAT GLOBAL VILLE PERFOMANCE ]--------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('vpg', function(source, args, rawCommand)
	if not exports["chat"]:statusChatServer(source) then return end
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		if vRP.hasPermission(user_id, "villeperformance.permissao") then
			if user_id then
				TriggerClientEvent('chatMessage', -1,
					"[VILLEPERFORMANCE] " .. identity.name .. " " .. identity.firstname .. ":",
					{ 135, 206, 250 }, rawCommand:sub(4))
				SendWebhookMessage(config.MecanicoChat,
					"```prolog\n[VILLE GLOBAL]\n[Nome]: [" ..
					user_id ..
					"] " ..
					identity.name ..
					" " .. identity.firstname ..
					"\n[Mensagem]: " .. rawCommand:sub(4) .. os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ COMANDO ADMINSITRATIVO ] -------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('pm', function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	local nplayer = vRP.getUserSource(parseInt(args[1]))

	if not exports["chat"]:statusChatServer(source) then return end

	if vRP.hasPermission(user_id, "suporte.permissao") then
		if args[1] == nil then
			TriggerClientEvent("Notify", source, "negado",
				"Necessário passar o ID após o comando, exemplo: <b>/radm 1</b>",
				2500)
			return
		elseif nplayer == nil then
			TriggerClientEvent("Notify", source, "negado", "O jogador não está online!")
			return
		end

		local mensagem = vRP.prompt(source, "Digite a mensagem:", "")
		if mensagem == "" then
			return
		end

		TriggerClientEvent("Notify", source, "sucesso", "Mensagem enviada com sucesso!")
		TriggerClientEvent('chatMessage', nplayer, "MENSAGEM DA ADMINISTRAÇÃO:", { 255, 0, 60 }, mensagem)
		SendWebhookMessage(config.PrivateMSG,
			"```prolog\n[MENSAGEM PRIVADA ADMIN]\n[QUEM ENVIOU]: [" ..
			user_id ..
			"]\n[QUEM RECEBEU]: [" ..
			nplayer .. "] \n[MENSAGEM]: " .. mensagem .. " " .. os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
	end
end)

RegisterCommand('cadm2', function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	local nplayer = vRP.getUserSource(parseInt(args[1]))
	if not exports["chat"]:statusChatServer(source) then return end
	if vRP.hasPermission(user_id, "magisk.permissao") then
		if args[1] == nil then
			TriggerClientEvent("Notify", source, "negado",
				"Necessário passar o ID após o comando, exemplo: <b>/cadm1 1</b>",
				2500)
			return
		elseif nplayer == nil then
			TriggerClientEvent("Notify", source, "negado", "O jogador não está online!")
			return
		end

		local mensagem = vRP.prompt(source, "Digite a mensagem:", "")
		if mensagem == "" then
			return
		end

		TriggerClientEvent('smartphone:createSMS', nplayer, 'CÚPULA', mensagem) -- Server
	end
end)

RegisterCommand('cadm3', function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	local nplayer = vRP.getUserSource(parseInt(args[1]))
	if not exports["chat"]:statusChatServer(source) then return end
	if vRP.hasPermission(user_id, "magisk.permissao") then
		if args[1] == nil then
			TriggerClientEvent("Notify", source, "negado",
				"Necessário passar o ID após o comando, exemplo: <b>/cadm2 1</b>",
				2500)
			return
		elseif nplayer == nil then
			TriggerClientEvent("Notify", source, "negado", "O jogador não está online!")
			return
		end

		local mensagem = vRP.prompt(source, "Digite a mensagem:", "")
		if mensagem == "" then
			return
		end

		local imagem = vRP.prompt(source, "Coloque o link da imagem:", "")
		if imagem == "" then
			return
		end
		TriggerClientEvent('smartphone:createSMS', nplayer, 'CÚPULA', mensagem, imagem) -- Server
	end
end)

RegisterCommand('cadm4', function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	local nplayer = vRP.getUserSource(parseInt(args[1]))
	local ply = GetEntityCoords(GetPlayerPed(source))

	if not exports["chat"]:statusChatServer(source) then return end
	if vRP.hasPermission(user_id, "magisk.permissao") then
		if args[1] == nil then
			TriggerClientEvent("Notify", source, "negado",
				"Necessário passar o ID após o comando, exemplo: <b>/cadm3 1</b>",
				2500)
			return
		elseif nplayer == nil then
			TriggerClientEvent("Notify", source, "negado", "O jogador não está online!")
			return
		end

		local mensagem = vRP.prompt(source, "Digite a mensagem:", "")

		if mensagem == "" then
			return
		end

		TriggerClientEvent('smartphone:createSMS', nplayer, 'CÚPULA', mensagem, { ply.x, ply.y, ply.z }) -- Server
	end
end)
------------------------------------------------------------------------------------------------------------------------------
--[ANUNCIO ADEMIRO CHAT]-----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("adm", function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)

	if user_id then
		if vRP.hasPermission(user_id, "moderador.permissao") or vRP.hasPermission(user_id, "administrador.permissao") then
			local message = vRP.prompt(source, "Mensagem:", "")
			if message == "" then
				return
			end

			local time = vRP.prompt(source, "Minutos:", "")
			if time == "" then
				return
			end

			if tonumber(time) > 2 or tonumber(time) < 1 then
				TriggerClientEvent("Notify", source, "negado", "O tempo deve ser entre <b>1</b> e <b>2 minutos</b>.",
					5000)
				return
			end

			-- local name = vRP.prompt(source,"Nome:","Administrador")
			-- if name == "" then
			--     return
			-- end

			TriggerClientEvent("Notify", -1, "Prefeitura", message .. "<br><br><b>Mensagem enviada por: </b>Prefeitura",
				time * 24 * 60 * 60)
			SendWebhookMessage(config.AdminAnnounce,
				"```prolog\n[ADMINISTRADOR ANUNCIO]\n[QUEM ENVIOU]: [" ..
				user_id ..
				"] " ..
				identity.name ..
				" " ..
				identity.firstname .. "\n[Mensagem]: " .. message .. os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
		end
	end
end)

RegisterCommand("festa", function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)

	if user_id then
		if vRP.hasPermission(user_id, "moderador.permissao") then
			local message = vRP.prompt(source, "Mensagem:", "")
			if message == "" then
				return
			end

			local time = vRP.prompt(source, "Minutos:", "")
			if time == "" then
				return
			end

			if tonumber(time) > 2 or tonumber(time) < 1 then
				TriggerClientEvent("Notify", source, "negado", "O tempo deve ser entre <b>1</b> e <b>2 minutos</b>.",
					5000)
				return
			end

			-- local name = vRP.prompt(source,"Nome:","Administrador")
			-- if name == "" then
			--     return
			-- end

			TriggerClientEvent("Notify", -1, "Festinha", message .. "<br><br><b>Mensagem enviada por: </b>Prefeitura",
				time * 24 * 60 * 60)
			SendWebhookMessage(config.AdminAnnounce,
				"```prolog\n[ADMINISTRADOR ANUNCIO]\n[QUEM ENVIOU]: [" ..
				user_id ..
				"] " ..
				identity.name ..
				" " ..
				identity.firstname .. "\n[Mensagem]: " .. message .. os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
		end
	end
end)
------------------------------------------------------------------------------------------------------------------------------
--[ ANUNCIO POLICIA/HP GLOBAL]-----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("pol", function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if user_id then
		if vRP.hasPermission(user_id, "policia.permissao") then
			local message = vRP.prompt(source, "Mensagem:", "")
			if message == "" then
				return
			end
			TriggerClientEvent("Notify", -1, "1° BPM INFORMA:",
				message .. "<br><br><b>Mensagem enviada por: </b>" .. identity.name .. " " .. identity.firstname .. " ",
				30000)

			SendWebhookMessage(config.PoliceAnnounce,
				"```prolog\n[POLICIA ANUNCIO]\n[QUEM ENVIOU]: [" ..
				user_id ..
				"] " ..
				identity.name ..
				" " ..
				identity.firstname .. "\n[Mensagem]: " .. message .. os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
		end
	end
end)

RegisterCommand("pol2", function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if user_id then
		if vRP.hasPermission(user_id, "policiaadm.permissao") then
			local message = vRP.prompt(source, "Mensagem:", "")
			if message == "" then
				return
			end
			TriggerClientEvent("Notify", -1, "2° BPM INFORMA:",
				message .. "<br><br><b>Mensagem enviada por: </b>" .. identity.name .. " " .. identity.firstname .. " ",
				30000)

			SendWebhookMessage(config.PoliceAnnounce,
				"```prolog\n[POLICIA ANUNCIO]\n[QUEM ENVIOU]: [" ..
				user_id ..
				"] " ..
				identity.name ..
				" " ..
				identity.firstname .. "\n[Mensagem]: " .. message .. os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
		end
	end
end)

RegisterCommand("casino", function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if user_id then
		if vRP.hasPermission(user_id, "cassino.permissao") then
			local message = vRP.prompt(source, "Mensagem:", "")
			if message == "" then
				return
			end
			TriggerClientEvent("Notify", -1, "CASSINO:",
				message .. "<br><br><b>Mensagem enviada por: </b>" .. identity.name .. " " .. identity.firstname .. " ",
				30000)

			SendWebhookMessage(config.PoliceAnnounce,
				"```prolog\n[POLICIA ANUNCIO]\n[QUEM ENVIOU]: [" ..
				user_id ..
				"] " ..
				identity.name ..
				" " ..
				identity.firstname .. "\n[Mensagem]: " .. message .. os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
		end
	end
end)

RegisterCommand("adv", function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if user_id then
		if vRP.hasPermission(user_id, "advogado.permissao") then
			local message = vRP.prompt(source, "Mensagem:", "")
			if message == "" then
				return
			end
			TriggerClientEvent("Notify", -1, "ADVOGADO",
				message .. "<br><br><b>Mensagem enviada por: </b>" .. identity.name .. " " .. identity.firstname .. " ",
				30000)

			SendWebhookMessage(config.PoliceAnnounce,
				"```prolog\n[POLICIA ANUNCIO]\n[QUEM ENVIOU]: [" ..
				user_id ..
				"] " ..
				identity.name ..
				" " ..
				identity.firstname .. "\n[Mensagem]: " .. message .. os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
		end
	end
end)

RegisterCommand("hp", function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if user_id then
		if vRP.hasPermission(user_id, "paramedico.permissao") then
			local message = vRP.prompt(source, "Mensagem:", "")
			if message == "" then
				return
			end
			TriggerClientEvent("Notify", -1, "Hospital",
				message .. "<br><br><b>Mensagem enviada por: </b>" .. identity.name .. " " .. identity.firstname .. " ",
				30000)
			SendWebhookMessage(config.AnuncioHP,
				"```prolog\n[HP ANUNCIO]\n[QUEM ENVIOU]: [" ..
				user_id ..
				"] " ..
				identity.name ..
				" " ..
				identity.firstname .. "\n[Mensagem]: " .. message .. os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HP CHAT INTERNO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('ch', function(source, args, rawCommand)
	if not exports["chat"]:statusChatServer(source) then return end
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		local permission = "paramedico.permissao"
		if vRP.hasPermission(user_id, permission) then
			local paramedico = vRP.getUsersByPermission(permission)
			for l, w in pairs(paramedico) do
				local player = vRP.getUserSource(parseInt(w))
				if player then
					async(function()
						TriggerClientEvent('chatMessage', player,
							"[HP INTERNO] " .. identity.name .. " " .. identity.firstname .. " [" .. user_id .. "]: ",
							{ 255, 175, 175 },
							rawCommand:sub(3))
						SendWebhookMessage(config.InternoHP,
							"```prolog\n[HP INTERNO]\n[Nome]: [" ..
							user_id ..
							"] " ..
							identity.name ..
							" " ..
							identity.firstname .. "\n[Mensagem]: " .. rawCommand:sub(3) ..
							os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
					end)
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- 112 HP GLOBAL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('112', function(source, args, rawCommand)
	if not exports["chat"]:statusChatServer(source) then return end
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		if vRP.hasPermission(user_id, "paramedico.permissao") or vRP.hasPermission(user_id, "magisk.permissao") then
			if user_id then
				TriggerClientEvent('chatMessage', -1,
					"Paramédico | " .. identity.name .. " " .. identity.firstname .. " :",
					{ 255, 70, 135 }, rawCommand:sub(4))
				SendWebhookMessage(config.GlobalHP,
					"```prolog\n[HP GLOBAL]\n[Nome]: [" ..
					user_id ..
					"] " ..
					identity.name ..
					" " .. identity.firstname ..
					"\n[Mensagem]: " .. rawCommand:sub(4) .. os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PD POLÍCIA INTERNO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('pd', function(source, args, rawCommand)
	if not exports["chat"]:statusChatServer(source) then return end
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		local permission = "pd.permissao"
		local title = vRP.getUserGroupByType(user_id, "job")
		local vida = vRPclient.getHealth(source)
		if vida > 102 then
			if vRP.hasPermission(user_id, permission) then
				local soldado = vRP.getUsersByPermission(permission)
				for l, w in pairs(soldado) do
					local player = vRP.getUserSource(parseInt(w))
					if player then
						async(function()
							TriggerClientEvent('chatMessage', player,
								" [" ..
								title .. "] " .. identity.name .. " " .. identity.firstname .. " [#" .. user_id .. "]: ",
								{ 64, 179, 255 }
								, rawCommand:sub(3))
							SendWebhookMessage(config.PoliceInterno,
								"```prolog\n[POLICE INTERNO]\n[Nome]: [" ..
								user_id ..
								"] " ..
								identity.name ..
								" " ..
								identity.firstname .. "\n[Mensagem]: " .. rawCommand:sub(3) ..
								os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
						end)
					end
				end
			end
		else
			TriggerClientEvent("Notify", source, "negado", "Você não pode enviar mensagem nesse chat nocauteado!", 5000)
		end
	end
end)

RegisterCommand('gc', function(source, args, rawCommand)
	if not exports["chat"]:statusChatServer(source) then return end
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		local permission = "oficial.permissao"
		local title = vRP.getUserGroupByType(user_id, "job")
		if vRP.hasPermission(user_id, permission) then
			local soldado = vRP.getUsersByPermission(permission)
			for l, w in pairs(soldado) do
				local player = vRP.getUserSource(parseInt(w))
				if player then
					async(function()
						TriggerClientEvent('chatMessage', player,
							" [" ..
							title .. "] " .. identity.name .. " " .. identity.firstname .. " [#" .. user_id .. "]: ",
							{ 60, 179, 113 }
							, rawCommand:sub(3))
						SendWebhookMessage(config.PoliceInterno,
							"```prolog\n[POLICE INTERNO]\n[Nome]: [" ..
							user_id ..
							"] " ..
							identity.name ..
							" " ..
							identity.firstname .. "\n[Mensagem]: " .. rawCommand:sub(3) ..
							os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
					end)
				end
			end
		end
	end
end)

RegisterCommand('d', function(source, args, rawCommand)
	if not exports["chat"]:statusChatServer(source) then return end
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		local permission = "twopolice.permissao"
		local title = vRP.getUserGroupByType(user_id, "job")
		if vRP.hasPermission(user_id, permission) then
			local soldado = vRP.getUsersByPermission(permission)
			for l, w in pairs(soldado) do
				local player = vRP.getUserSource(parseInt(w))
				if player then
					async(function()
						TriggerClientEvent('chatMessage', player,
							"[" ..
							title .. "] " .. identity.name .. " " .. identity.firstname .. " [#" .. user_id .. "]: ",
							{ 0, 255, 127 }
							, rawCommand:sub(3))
						SendWebhookMessage(config.PoliceInterno,
							"```prolog\n[POLICE INTERNO]\n[Nome]: [" ..
							user_id ..
							"] " ..
							identity.name ..
							" " ..
							identity.firstname .. "\n[Mensagem]: " .. rawCommand:sub(3) ..
							os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
					end)
				end
			end
		end
	end
end)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[ 911 POLICIA GLOBAL ]----------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('911', function(source, args, rawCommand)
	if not exports["chat"]:statusChatServer(source) then return end
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		if vRP.hasPermission(user_id, "policia.permissao") then
			if user_id then
				TriggerClientEvent('chatMessage', -1, "BPM-OV | " .. identity.name .. " " .. identity.firstname .. ":",
					{ 255, 255, 0 }
					, rawCommand:sub(4))
				SendWebhookMessage(config.PoliceGlobal,
					"```prolog\n[POLICE GLOBAL]\n[Nome]: [" ..
					user_id ..
					"] " ..
					identity.name ..
					" " .. identity.firstname ..
					"\n[Mensagem]: " .. rawCommand:sub(4) .. os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
			end
		end
	end
end)

RegisterCommand('913', function(source, args, rawCommand)
	if not exports["chat"]:statusChatServer(source) then return end
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		if vRP.hasPermission(user_id, "oficial.permissao") then
			if user_id then
				TriggerClientEvent('chatMessage', -1, "2° BPM-OV | " .. identity.name .. " " .. identity.firstname .. ":",
					{ 255, 255, 0 }
					, rawCommand:sub(4))
				SendWebhookMessage(config.PoliceGlobal,
					"```prolog\n[POLICE GLOBAL]\n[Nome]: [" ..
					user_id ..
					"] " ..
					identity.name ..
					" " .. identity.firstname ..
					"\n[Mensagem]: " .. rawCommand:sub(4) .. os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
			end
		end
	end
end)

RegisterCommand('912', function(source, args, rawCommand)
	if not exports["chat"]:statusChatServer(source) then return end
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		if vRP.hasPermission(user_id, "oficial.permissao") or vRP.hasPermission(user_id, "magisk.permissao") then
			if user_id then
				TriggerClientEvent('chatMessage', -1, "2° BPM-OV | " ..
					identity.name .. " " .. identity.firstname .. ":",
					{ 60, 179, 113 }
					, rawCommand:sub(4))
				SendWebhookMessage(config.PoliceGlobal,
					"```prolog\n[POLICE GLOBAL]\n[Nome]: [" ..
					user_id ..
					"] " ..
					identity.name ..
					" " .. identity.firstname ..
					"\n[Mensagem]: " .. rawCommand:sub(4) .. os.date("  \n[Data]: %d/%m/%Y [Hora]: %H:%M:%S ```"))
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STATUSCHAT
-----------------------------------------------------------------------------------------------------------------------------------------
function statusChatServer(source)
	return vCLIENT.statusChat(source)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPORTS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("statusChatServer", statusChatServer)
