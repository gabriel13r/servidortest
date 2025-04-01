local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

vSERVER = Tunnel.getInterface("chat")
src = {}
Tunnel.bindInterface("chat", src)

local chatInputActive = false
local chatInputActivating = false
local chatHidden = true
local chatLoaded = false
local chatOpen = false

RegisterNetEvent('chatMessage')
RegisterNetEvent('chat:addTemplate')
RegisterNetEvent('chat:addMessage')
RegisterNetEvent('chat:addSuggestion')
RegisterNetEvent('chat:addSuggestions')
RegisterNetEvent('chat:clear')
RegisterNetEvent('__cfx_internal:serverPrint')
RegisterNetEvent('_chat:messageEntered')

RegisterNetEvent('chatMessageProximity')
AddEventHandler('chatMessageProximity', function(id, name, firstname, message)
	local myId = PlayerId()
	local pid_cl = GetPlayerServerId(PlayerId())
	local pid = GetPlayerFromServerId(id)
	if pid == -1 then
		return -- PLAYER NOT CLOSE
	end
	if pid == myId then
		TriggerEvent('chatMessage', "" .. name .. " " .. firstname .. ": ", { 39, 122, 185 }, message)
	elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(pid)), GetEntityCoords(PlayerPedId(), true)) < 10.999 then
		TriggerEvent('chatMessage', "" .. name .. " " .. firstname .. " ", { 39, 122, 185 }, message)
	end
end)

AddEventHandler('chatMessage', function(author, color, text)
	local args = { text }
	if author ~= "" then
		table.insert(args, 1, author)
	end
	SendNUIMessage({ type = 'ON_MESSAGE', message = { color = color, multiline = true, args = args } })
end)

AddEventHandler('__cfx_internal:serverPrint', function(msg)
	SendNUIMessage({ type = 'ON_MESSAGE', message = { templateId = 'print', multiline = true, args = { msg } } })
	chatOpen = false
end)

AddEventHandler('chat:addMessage', function(message)
	SendNUIMessage({ type = 'ON_MESSAGE', message = message })
end)

--AddEventHandler('chat:addSuggestion', function(name, help, params)
--SendNUIMessage({ type = 'ON_SUGGESTION_ADD', suggestion = { name = name, help = help, params = params or nil } })
--end)

AddEventHandler('chat:addSuggestion', function(name, help, params)
	SendNUIMessage({
		type = 'ON_SUGGESTION_ADD',
		suggestion = {
			name = name,
			help = help,
			params = params or nil
		}
	})
end)

AddEventHandler('chat:addSuggestions', function(suggestions)
	SendNUIMessage({ type = 'ON_SUGGESTION_ADD', suggestion = suggestion })
end)

AddEventHandler('chat:removeSuggestion', function(name)
	SendNUIMessage({ type = 'ON_SUGGESTION_REMOVE', name = name })
end)

AddEventHandler('chat:addTemplate', function(id, html)
	SendNUIMessage({ type = 'ON_TEMPLATE_ADD', template = { id = id, html = html } })
end)

AddEventHandler('chat:clear', function(name)
	SendNUIMessage({ type = 'ON_CLEAR' })
end)

RegisterNUICallback('fecharChat', function(data, cb)
	chatInputActive = false
	SetNuiFocus(false)
	chatOpen = false
end)

RegisterNUICallback('chatResult', function(data, cb)
	chatInputActive = false
	SetNuiFocus(false)


	if not data.canceled then
		local id = PlayerId()
		local r, g, b = 0, 0x99, 255

		if data.message:sub(1, 1) == '/' then
			ExecuteCommand(data.message:sub(2))
		else
			TriggerServerEvent('_chat:messageEntered', GetPlayerName(id), { r, g, b }, data.message)
		end
	end

	cb('ok')
end)

local function refreshCommands()
	if GetRegisteredCommands then
		local registeredCommands = GetRegisteredCommands()

		local suggestions = {}

		for _, command in ipairs(registeredCommands) do
			if IsAceAllowed(('command.%s'):format(command.name)) then
				table.insert(suggestions, {
					name = '/' .. command.name,
					help = ''
				})
			end
		end

		TriggerEvent('chat:addSuggestions', suggestions)
	end
end

local function refreshThemes()
	local themes = {}

	for resIdx = 0, GetNumResources() - 1 do
		local resource = GetResourceByFindIndex(resIdx)

		if GetResourceState(resource) == 'started' then
			local numThemes = GetNumResourceMetadata(resource, 'chat_theme')

			if numThemes > 0 then
				local themeName = GetResourceMetadata(resource, 'chat_theme')
				local themeData = json.decode(GetResourceMetadata(resource, 'chat_theme_extra') or 'null')

				if themeName and themeData then
					themeData.baseUrl = 'nui://' .. resource .. '/'
					themes[themeName] = themeData
				end
			end
		end
	end
	SendNUIMessage({ type = 'ON_UPDATE_THEMES', themes = themes })
end

AddEventHandler('onClientResourceStart', function(resName)
	Wait(500)

	refreshCommands()
	refreshThemes()
end)

AddEventHandler('onClientResourceStop', function(resName)
	Wait(500)

	refreshCommands()
	refreshThemes()
end)

RegisterNUICallback('loaded', function(data, cb)
	TriggerServerEvent('chat:init');

	refreshCommands()
	refreshThemes()

	chatLoaded = true

	cb('ok')
end)
RegisterCommand("openChat", function(source, args)
	SetTextChatEnabled(false)
	SetNuiFocus(false)

	if not chatInputActive then
		chatInputActive = true
		chatInputActivating = true
		chatOpen = true
		SendNUIMessage({ type = 'ON_OPEN' })
	end

	if chatInputActivating then
		SetNuiFocus(true)
		chatInputActivating = false
	end

	if chatLoaded then
		local shouldBeHidden = false

		if IsScreenFadedOut() or IsPauseMenuActive() then
			shouldBeHidden = true
		end

		if (shouldBeHidden and not chatHidden) or (not shouldBeHidden and chatHidden) then
			chatHidden = shouldBeHidden
			SendNUIMessage({ type = 'ON_SCREEN_STATE_CHANGE', shouldHide = shouldBeHidden })
		end
	end
end)
RegisterKeyMapping("openChat", "Abrir chat", "keyboard", "t")

function src.statusChat()
	return chatOpen
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- STATUSCHAT
-----------------------------------------------------------------------------------------------------------------------------------------
function statusChat()
	return chatOpen
end

-- Citizen.CreateThread(function()
--  TriggerEvent('chat:addSuggestion', '/112', 'Mandar mensagem para o Hospital.', {{ name="TEXTO"}})
-- 	TriggerEvent('chat:addSuggestion', '/911', 'Mandar mensagem para o Departamento Policial.', {{ name="TEXTO"}})
-- 	TriggerEvent('chat:addSuggestion', '/mec', 'Mandar mensagem para os Mecânicos.', {{ name="TEXTO"}})
-- 	TriggerEvent('chat:addSuggestion', '/taxi', 'Mandar mensagem para os Taxista.', {{ name="TEXTO"}})
-- 	TriggerEvent('chat:addSuggestion', '/law', 'Mandar mensagem para Advogados/Juiz.', {{ name="TEXTO"}})
-- 	TriggerEvent('chat:addSuggestion', '/coc', 'Mandar mensagem para Concessionária.', {{ name="TEXTO"}})
-- 	TriggerEvent('chat:addSuggestion', '/chamar', 'Executar um chamado.', {{ name="NÚMERO",help="ADM."}})
-- 	TriggerEvent('chat:addSuggestion', '/toogle', 'Para Entrar/Sair de serviço.')
-- 	TriggerEvent('chat:addSuggestion', '/toogle2', 'Para Entrar/Sair de serviço em uma ação.')
-- 	TriggerEvent('chat:addSuggestion', '/re', 'Para reanimar o paciente em coma.')
-- 	TriggerEvent('chat:addSuggestion', '/re2', 'Para reanimar o paciente em coma ação.')
--  TriggerEvent('chat:addSuggestion', '/tratamento', 'Para curar o paciente.')
-- 	TriggerEvent('chat:addSuggestion', '/reanimar', 'Para reanimar americano.')
-- 	TriggerEvent('chat:addSuggestion', '/cv', 'Para colocar dentro do veículo.')
-- 	TriggerEvent('chat:addSuggestion', '/rv', 'Para tirar do veículo.')
-- 	TriggerEvent('chat:addSuggestion', '/attachs', 'Para fazer melhorias no armamento.')
-- 	TriggerEvent('chat:addSuggestion', '/id', 'Para ver o passaporte da pessoa.', {{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/revistar', 'Para revistar um civil.')
-- 	TriggerEvent('chat:addSuggestion', '/apreender', 'Apreensão de todos os itens.')
-- 	TriggerEvent('chat:addSuggestion', '/prender', 'Envia um jogador para a prisão.', {{ name="PASSAPORTE"},{ name="TEMPO"}})
-- 	TriggerEvent('chat:addSuggestion', '/enviar', 'Envia dinheiro ao jogador mais próximo.', {{ name="QUANTIA"}})
--  TriggerEvent('chat:addSuggestion', '/defuse', 'Defusar a bomba do veículo.')
--  TriggerEvent('chat:addSuggestion', '/placa', 'Mostra a placa do veículo mais próximo.')
-- 	TriggerEvent('chat:addSuggestion', '/multar', 'Aplicar multa no jogador destinado.')
-- 	TriggerEvent('chat:addSuggestion', '/multas pagar', 'Para pagar suas multas.')
-- 	TriggerEvent('chat:addSuggestion', '/detido', 'Deixa o veículo na detenção.')
-- 	TriggerEvent('chat:addSuggestion', '/rmascara', 'Retirar a mascara da pessoa próxima.')
-- 	TriggerEvent('chat:addSuggestion', '/rchapeu', 'Retirar o chapéu da pessoa próxima.')
-- 	TriggerEvent('chat:addSuggestion', '/rcapuz', 'Retirar o capuz da pessoa próxima.')
-- 	TriggerEvent('chat:addSuggestion', '/cone', 'Coloca um cone a sua frente.')
-- 	TriggerEvent('chat:addSuggestion', '/procurado', 'Saber se você está sendo procurado pela policia.')
-- 	TriggerEvent('chat:addSuggestion', '/seat', 'Para você trocar de assento em um veículo.')
-- 	TriggerEvent('chat:addSuggestion', '/cone d', 'Retira um cone a sua frente.')
--  TriggerEvent('chat:addSuggestion', '/barreira', 'Coloca uma barreira a sua frente.')
--  TriggerEvent('chat:addSuggestion', '/barreira d', 'Retira uma barreira a sua frente.')
-- 	TriggerEvent('chat:addSuggestion', '/spike', 'Coloca um espinho a sua frente.')
-- 	TriggerEvent('chat:addSuggestion', '/spike d', 'Retira um espinho a sua frente.')
-- 	TriggerEvent('chat:addSuggestion', '/reparar', 'Para reparar um veículo.')
-- 	TriggerEvent('chat:addSuggestion', '/motor', 'Para reparar um motor.')
-- 	TriggerEvent('chat:addSuggestion', '/doors 5', 'Para abrir/fechar o porta malas.')
-- 	TriggerEvent('chat:addSuggestion', '/hood', 'Para abrir/fechar o capo.')
-- 	TriggerEvent('chat:addSuggestion', '/doors', 'Para abrir/fechar as portas.')
-- 	TriggerEvent('chat:addSuggestion', '/wins', 'Abrir e fechar os vidros do veículo.')
-- 	TriggerEvent('chat:addSuggestion', '/garmas', 'Para desequipar todas as armas do inventário.')
-- 	TriggerEvent('chat:addSuggestion', '/gcolete', 'Para guarda o colete no inventário.')
-- 	TriggerEvent('chat:addSuggestion', '/gmochila', 'Para desequipar a mochila das costas.')
-- 	TriggerEvent('chat:addSuggestion', '/jcolete', 'Para jogar o colete danificado fora.')
-- 	TriggerEvent('chat:addSuggestion', '/sequestro', 'Coloca a pessoa no porta-malas.')
-- 	TriggerEvent('chat:addSuggestion', '/apagao', 'Você consegue apagar todas as luzes da cidade.')
-- 	TriggerEvent('chat:addSuggestion', '/carregar', 'Carrega um americano.')
-- 	TriggerEvent('chat:addSuggestion', '/sequestro2', 'Coloca o americano no porta-malas.')
-- 	TriggerEvent('chat:addSuggestion', '/cloneplate', 'Clona a placa do veículo utilizado.')
-- 	TriggerEvent('chat:addSuggestion', '/dv', 'Deleta um veículo mais próximo.')
-- 	TriggerEvent('chat:addSuggestion', '/fix', 'Reparar um veículo.')
-- 	TriggerEvent('chat:addSuggestion', '/rename', 'Para alterar nome de um jogador.')
-- 	TriggerEvent('chat:addSuggestion', '/god', 'Reviver um jogador.', {{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/godall', 'Reviver todos os jogador.')
-- 	TriggerEvent('chat:addSuggestion', '/kill', 'Matar um jogador.', {{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/arma', 'Pegar uma arma temporário com base no, [wiki.rage.mp].')
--  TriggerEvent('chat:addSuggestion', '/pon', 'Ver quais IDs estão online.')
-- 	TriggerEvent('chat:addSuggestion', '/tuning', 'Tunar o veículo no máximo.')
-- 	TriggerEvent('chat:addSuggestion', '/unwl', 'Tirar da whitelist.', {{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/wl', 'Adicionar na whitelist.', {{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/kick', 'Kickar um jogador.', {{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/kickall', 'Kickar todos os jogadores.')
-- 	TriggerEvent('chat:addSuggestion', '/status', 'Verificar quantos trabalhadores estão em seu expediente.')
-- 	TriggerEvent('chat:addSuggestion', '/ban', 'Banir um jogador.', {{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/unban', 'Desbanir um jogador.', {{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/nc', 'NoClip, fica invisível e atravessa paredes.')
-- 	TriggerEvent('chat:addSuggestion', '/blips', 'Blips, ver os jogadores no mapa.')
-- 	TriggerEvent('chat:addSuggestion', '/nomes', 'Nomes, ver os nomes dos jogadores na cabeça.')
--  TriggerEvent('chat:addSuggestion', '/tpcds', 'Teleportar para uma cordenada.')
-- 	TriggerEvent('chat:addSuggestion', '/cds', 'Pegar uma cordenada.')
-- 	TriggerEvent('chat:addSuggestion', '/cds2', 'Pegar uma cordenada.')
-- 	TriggerEvent('chat:addSuggestion', '/hud', 'Para você desabilitar as hud.')
-- 	TriggerEvent('chat:addSuggestion', '/setradio on', 'Para ligar o rádio do veículo.')
-- 	TriggerEvent('chat:addSuggestion', '/setradio url', 'Para colocar o link de uma música.')
-- 	TriggerEvent('chat:addSuggestion', '/setradio off', 'Para desligar o rádio do veículo.')
-- 	TriggerEvent('chat:addSuggestion', '/setradio volume', 'Para alterar o volume da música.')
-- 	TriggerEvent('chat:addSuggestion', '/vtuning', 'Ver a porcentagem do veículo.')
-- 	TriggerEvent('chat:addSuggestion', '/group', 'Para colocar o jogador em algum grupo.', {{ name="PASSAPORTE"},{ name="GRUPO"}})
-- 	TriggerEvent('chat:addSuggestion', '/ungroup', 'Para tirar o grupo de algum jogador.', {{ name="PASSAPORTE"},{ name="GRUPO"}})
-- 	TriggerEvent('chat:addSuggestion', '/tptome', 'Puxar um jogador até você.', {{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/tpto', 'Ir até um jogador.', {{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/tpway', 'Teleporte para lugar do mapa marcado.')
-- 	TriggerEvent('chat:addSuggestion', '/car', 'Criar um carro temporário com base no, [wiki.rage.mp].', {{ name="VEÍCULO"}})
-- 	TriggerEvent('chat:addSuggestion', '/delnpcs', 'Deletar NPCs mais próximos.')
-- 	TriggerEvent('chat:addSuggestion', '/adm', 'Colocar anúncio global, [ADM VERMELHO].')
-- 	TriggerEvent('chat:addSuggestion', '/algema', 'Remover algemas de si, [Via Console].')
-- 	TriggerEvent('chat:addSuggestion', '/money', 'Pegar dinheiro temporariamente.', {{ name="QUANTIDADE"}})
--  TriggerEvent('chat:addSuggestion', '/e', 'Executa uma animação, [/e dancar]', {{ name="NOME DA ANIMAÇÃO"}})
-- 	TriggerEvent('chat:addSuggestion', '/e2', 'Executa uma animação no jogador mais próximo.', {{ name="NOME DA ANIMAÇÃO"}})
-- 	TriggerEvent('chat:addSuggestion', '/estoque', 'Adicionar mais veículos no estoque.', {{ name="VEÍCULOS"},{ name="QUANTIDADE"}})
-- 	TriggerEvent('chat:addSuggestion', '/addcar', 'Adicionar um veículo para o jogador.', {{ name="VEÍCULOS"},{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/remcar', 'Remover um veículo para o jogador.', {{ name="VEÍCULOS"},{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/carcolor', 'Alterar temporariamente a cor do veículo, usando tabela, [RGB].')
-- 	TriggerEvent('chat:addSuggestion', '/limpainv', 'Limpar inventário de um jogador.', {{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/fuel', 'Adicionar ou remover combustível do veículo.', {{ name="QUANTIDADE"}})
--  TriggerEvent('chat:addSuggestion', '/limpararea', 'Limpar area mais próxima.')
--  TriggerEvent('chat:addSuggestion', '/skin', 'Trocar personagen do jogador.', {{ name="PASSAPORTE"},{ name="SKIN"}})
-- 	TriggerEvent('chat:addSuggestion', '/colete', 'Dar colete para um jogador.', {{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/hash', 'Pegar hash de um veículo.')
-- 	TriggerEvent('chat:addSuggestion', '/players', 'Para ver todos jogadores online.')
-- 	TriggerEvent('chat:addSuggestion', '/admin', 'Falar no chat como adimistrador.', {{ name="TEXTO"}})
-- 	TriggerEvent('chat:addSuggestion', '/vroupas', 'Ver os IDs das roupas que esta vestido.')
-- 	TriggerEvent('chat:addSuggestion', '/pack', 'Pegar caminho de entrega da carga do caminhoneiro.', {{ name="CARGA"  , help="DIESEL,GAS,CARS,WOODS,SHOW"}})
-- 	TriggerEvent('chat:addSuggestion', '/cr', 'Travar/Destravar velecidade do veículo.', {{ name="VELECIDADE"}})
--  TriggerEvent('chat:addSuggestion', '/me', 'Falar no pensamento.', {{ name="TEXTO"}})
--  TriggerEvent('chat:addSuggestion', '/weaponcolor', 'Trocar as cores das armas.', {{ name="NÚMERO"}})
-- 	TriggerEvent('chat:addSuggestion', '/help', 'Abrir um ticket para staff.')
-- 	TriggerEvent('chat:addSuggestion', '/shield', 'Para pegar escudo da policia.')
-- 	TriggerEvent('chat:addSuggestion', '/paypal', 'Para fazer suas transferência.')
-- 	TriggerEvent('chat:addSuggestion', '/cmec', 'Mandar mensagem na central da mecânica.', {{ name="TEXTO"}})
-- 	TriggerEvent('chat:addSuggestion', '/mr', 'Chat interno entre os mecânicos.', {{ name="TEXTO"}})
-- 	TriggerEvent('chat:addSuggestion', '/aa', 'Chat interno entre os staffs.', {{ name="TEXTO"}})
-- 	TriggerEvent('chat:addSuggestion', '/pd', 'Chat interno entre os policiais.', {{ name="TEXTO"}})
-- 	TriggerEvent('chat:addSuggestion', '/pr', 'Chat interno entre os paramedico.', {{ name="TEXTO"}})
--  TriggerEvent('chat:addSuggestion', '/card', 'Mostrar uma carta para jogadores próximos.')
-- 	TriggerEvent('chat:addSuggestion', '/mascara', 'Trocar máscara com base do [wiki.rage.mp], é necessário ter o item Roupas.')
-- 	TriggerEvent('chat:addSuggestion', '/coletes', 'Trocar colete com base do [wiki.rage.mp], é necessário ter o item Roupas.')
-- 	TriggerEvent('chat:addSuggestion', '/maos', 'Trocar mão com base do [wiki.rage.mp], é necessário ter o item Roupas.')
-- 	TriggerEvent('chat:addSuggestion', '/acessorios', 'Trocar acessórios com base do [wiki.rage.mp], é necessário ter o item Roupas.')
--  TriggerEvent('chat:addSuggestion', '/sapatos', 'Trocar sapatos com base do [wiki.rage.mp], é necessário ter o item Roupas.')
--  TriggerEvent('chat:addSuggestion', '/chapeu', 'Trocar chapéu com base do [wiki.rage.mp], é necessário ter o item Roupas.')
-- 	TriggerEvent('chat:addSuggestion', '/oculos', 'Trocar oculos com base do [wiki.rage.mp], é necessário ter o item Roupas.')
-- 	TriggerEvent('chat:addSuggestion', '/roupas', 'Para colocar uma roupa pre-setada.', {{ name="NOME"}})
-- 	TriggerEvent('chat:addSuggestion', '/verid', 'Ver o ID do jogador mais próximo.')
-- 	TriggerEvent('chat:addSuggestion', '/vehs', 'Para você ver sua lista de veículos.')
-- 	TriggerEvent('chat:addSuggestion', '/vehs', 'Para você vender seu veículo para outra pessoa.', {{ name="NOME DO VEÍCULO"},{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/uservehs', 'Ver todos os veículos que o jogador tem.', {{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/item', 'Mandar mensagem para Concessionária.', {{ name="NOME"},{ name="QUANTIDADE"}})
-- 	TriggerEvent('chat:addSuggestion', '/porte check', 'Para verificar se o jogador tem o porte.', {{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/porte add', 'Para adicionar o porte a um jogador.', {{ name="PASSAPORTE"}})
--  TriggerEvent('chat:addSuggestion', '/porte rem', 'Para remover o porte de um jogador.', {{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/p', 'Mandar a localização entre os policiais.')
-- 	TriggerEvent('chat:addSuggestion', '/extras', 'Abre o menu de alterações no veículo.')
-- 	TriggerEvent('chat:addSuggestion', '/anuncio', 'Fazer um anuncio para os jogadores.')
-- 	TriggerEvent('chat:addSuggestion', '/preset', 'Colocar roupas do serviço.', {{ name="NÚMERO"}})
-- 	TriggerEvent('chat:addSuggestion', '/a', 'Para pegar armas.', {{ name="ARMA"}})
-- 	TriggerEvent('chat:addSuggestion', '/ptr', 'Ver quantos policias online.')
-- 	TriggerEvent('chat:addSuggestion', '/ptr2', 'Ver quantos policias offline.')
-- 	TriggerEvent('chat:addSuggestion', '/ems', 'Ver quantos paramedicos online.')
--  TriggerEvent('chat:addSuggestion', '/mecs', 'Ver quantos mecânicos online.')
-- 	TriggerEvent('chat:addSuggestion', '/taxis', 'Ver quantos taxistas online.')
-- 	TriggerEvent('chat:addSuggestion', '/enter', 'Caso a casa esteja disponível aparece o valor para comprar.')
-- 	TriggerEvent('chat:addSuggestion', '/homes add', 'Adiciona a permissão da residência para o passaporte escolhido.', {{ name="RESIDÊNCIA"},{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/homes check', 'Mostra todas as permissões da residência.', {{ name="RESIDÊNCIA"}})
-- 	TriggerEvent('chat:addSuggestion', '/homes transfer', 'Transfere a residência ao passaporte escolhido.', {{ name="RESIDÊNCIA"},{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/homes rem', 'Remove a permissão da residência do passaporte escolhido.', {{ name="RESIDÊNCIA"},{ name="PASSAPORTE"}})
-- 	TriggerEvent('chat:addSuggestion', '/homes tax', 'Efetua o pagamento da Property Tax da residência.', {{ name="RESIDÊNCIA"}})
-- 	TriggerEvent('chat:addSuggestion', '/homes garage', 'Permite a garagem por 50.000 dólares.', {{ name="RESIDÊNCIA"},{ name="PASSAPORTE"}})
--  TriggerEvent('chat:addSuggestion', '/homes list', 'Mostra no mapa todas as residências disponíveis a venda na cidade.')
--   riggerEvent('chat:addSuggestion', '/outfit', 'Mostra todos os outfits.')
-- 	TriggerEvent('chat:addSuggestion', '/outfit save', 'Para adicionar um outfit ao seu Guarda-Roupas.', {{ name="NOME"}})
-- 	TriggerEvent('chat:addSuggestion', '/outfit rem', 'Para remover um outfit ao seu Guarda-Roupas.', {{ name="NOME"}})
-- 	TriggerEvent('chat:addSuggestion', '/outfit apply', 'Para colocar um outfit do seu Guarda-Roupas.', {{ name="NOME"}})
-- 	TriggerEvent('chat:addSuggestion', '/exit', 'Para sair da casa.')
-- 	TriggerEvent('chat:addSuggestion', '/vault', 'Para acessar o baú da casa.')
-- 	TriggerEvent('chat:addSuggestion', '/homem', 'Andar com um soar de homem.')
-- 	TriggerEvent('chat:addSuggestion', '/mulher', 'Andar com um soar de mulher.')
-- 	TriggerEvent('chat:addSuggestion', '/depressivo', 'Andar com um soar depressivo.')
-- 	TriggerEvent('chat:addSuggestion', '/depressiva', 'Andar com um soar depressiva.')
-- 	TriggerEvent('chat:addSuggestion', '/empresario', 'Andar com um soar empresário.')
-- 	TriggerEvent('chat:addSuggestion', '/determinado', 'Andar com um soar determinado.')
-- 	TriggerEvent('chat:addSuggestion', '/descontraido', 'Andar com um soar descontraído.')
-- 	TriggerEvent('chat:addSuggestion', '/farto', 'Andar com um soar farto.')
-- 	TriggerEvent('chat:addSuggestion', '/estiloso', 'Andar com um soar estiloso.')
-- 	TriggerEvent('chat:addSuggestion', '/ferido', 'Andar com um soar ferido.')
-- 	TriggerEvent('chat:addSuggestion', '/arrogante', 'Andar com um soar arrogante.')
-- 	TriggerEvent('chat:addSuggestion', '/nervoso', 'Andar com um soar nervoso.')
-- 	TriggerEvent('chat:addSuggestion', '/desleixado', 'Andar com um soar desleixado.')
-- 	TriggerEvent('chat:addSuggestion', '/infeliz', 'Andar com um soar infeliz.')
-- 	TriggerEvent('chat:addSuggestion', '/musculoso', 'Andar com um soar musculoso.')
-- 	TriggerEvent('chat:addSuggestion', '/desligado', 'Andar com um soar desligado.')
-- 	TriggerEvent('chat:addSuggestion', '/fadiga', 'Andar com um soar fadiga.')
-- 	TriggerEvent('chat:addSuggestion', '/apressado', 'Andar com um soar apressado.')
-- 	TriggerEvent('chat:addSuggestion', '/descolado', 'Andar com um soar descolado.')
-- 	TriggerEvent('chat:addSuggestion', '/bebado', 'Andar com um soar bebado.')
-- 	TriggerEvent('chat:addSuggestion', '/bebado2', 'Andar com um soar bebado2.')
-- 	TriggerEvent('chat:addSuggestion', '/bebado3', 'Andar com um soar bebado3.')
-- 	TriggerEvent('chat:addSuggestion', '/irritado', 'Andar com um soar irritado.')
-- 	TriggerEvent('chat:addSuggestion', '/intimidado', 'Andar com um soar intimidado.')
-- 	TriggerEvent('chat:addSuggestion', '/poderosa', 'Andar com um soar poderosa.')
-- 	TriggerEvent('chat:addSuggestion', '/chateado', 'Andar com um soar chateado.')
-- 	TriggerEvent('chat:addSuggestion', '/estilosa', 'Andar com um soar estilosa.')
-- 	TriggerEvent('chat:addSuggestion', '/sensual', 'Andar com um soar sensual.')
-- 	TriggerEvent('chat:addSuggestion', '/corridinha', 'Fazer uma corridinha .')
-- 	TriggerEvent('chat:addSuggestion', '/piriguete', 'Andar com um soar piriguete.')
-- 	TriggerEvent('chat:addSuggestion', '/petulante', 'Andar com um soar petulante.')
-- end)
