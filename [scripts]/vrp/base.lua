-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEL
-----------------------------------------------------------------------------------------------------------------------------------------
local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
local config = module("cfg/others")

-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
vRP = {}
exports("getvRP", function() return vRP end)
tvRP = {}
Tunnel.bindInterface("vRP", tvRP)
vRPclient = Tunnel.getInterface("vRP")
vRP.users = {}
vRP.rusers = {}
vRP.user_tables = {}
vRP.user_tmp_tables = {}
vRP.user_sources = {}
Proxy.addInterface("vRP", vRP)

local db_drivers = {}
local db_driver
local cached_prepares = {}
local cached_queries = {}
local prepared_queries = {}
local db_initialized = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
function SendWebhookMessage(webhook, message)
	if webhook ~= nil and webhook ~= "" then
		PerformHttpRequest(webhook, function(err, text, headers)
			end, 'POST', json.encode({ content = message }),
			{ ['Content-Type'] = 'application/json' })
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- BASE.LUA
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.registerDBDriver(name, on_init, on_prepare, on_query)
	if not db_drivers[name] then
		db_drivers[name] = { on_init, on_prepare, on_query }
		db_driver = db_drivers[name]
		db_initialized = true

		for _, prepare in pairs(cached_prepares) do
			on_prepare(table.unpack(prepare, 1, table.maxn(prepare)))
		end

		for _, query in pairs(cached_queries) do
			query[2](on_query(table.unpack(query[1], 1, table.maxn(query[1]))))
		end

		cached_prepares = nil
		cached_queries = nil
	end
end

function vRP.format(n)
	local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)', '%1.'):reverse()) .. right
end

function vRP.prepare(name, query)
	prepared_queries[name] = true

	if db_initialized then
		db_driver[2](name, query)
	else
		table.insert(cached_prepares, { name, query })
	end
end

function vRP.query(name, params, mode)
	if not mode then mode = "query" end

	if db_initialized then
		return db_driver[3](name, params or {}, mode)
	else
		local r = async()
		table.insert(cached_queries, { { name, params or {}, mode }, r })
		return r:wait()
	end
end

function vRP.execute(name, params)
	return vRP.query(name, params, "execute")
end

vRP.prepare("vRP/create_user",
	"INSERT INTO vrp_users(whitelisted, banned) VALUES(false, false); SELECT LAST_INSERT_ID() AS id")
vRP.prepare("vRP/add_identifier", "INSERT INTO vrp_user_ids(identifier, user_id) VALUES(@identifier, @user_id)")
vRP.prepare("vRP/add_benefitsChars", "INSERT INTO vrp_benefits(steam, user_id) VALUES(@identifier, @user_id)")
vRP.prepare("vRP/userid_byidentifier", "SELECT user_id,identifier FROM vrp_user_ids WHERE identifier = @identifier")
vRP.prepare("vRP/get_usersBenefits", "SELECT * FROM vrp_benefits WHERE steam = @steam")
vRP.prepare("vRP/get_usersBenefitsId", "SELECT * FROM vrp_benefits WHERE user_id = @user_id")
vRP.prepare("vRP/identifier_byuserid", "SELECT * FROM vrp_user_ids WHERE user_id = @user_id")
vRP.prepare("vRP/set_userdata", "REPLACE INTO vrp_user_data(user_id, dkey, dvalue) VALUES(@user_id, @key, @value)")
vRP.prepare("vRP/get_userdata", "SELECT dvalue FROM vrp_user_data WHERE user_id = @user_id AND dkey = @key")
vRP.prepare("vRP/set_srvdata", "REPLACE INTO vrp_srv_data(dkey, dvalue) VALUES(@key, @value)")
vRP.prepare("vRP/get_srvdata", "SELECT dvalue FROM vrp_srv_data WHERE dkey = @key")


-- vRP.prepare("vRP/get_banned", "SELECT banned, expire_banned FROM vrp_users WHERE id = @user_id")
-- vRP.prepare("vRP/set_banned", "UPDATE vrp_users SET banned = @banned, WHERE id = @user_id")
-- vRP.prepare("vRP/set_bannedGlobal", "UPDATE vrp_benefits SET global_ban = @banned WHERE user_id = @user_id")

vRP.prepare("vRP/get_banned", "SELECT banned FROM vrp_users WHERE id = @user_id")
vRP.prepare("vRP/set_banned", "UPDATE vrp_users SET banned = @banned WHERE id = @user_id")

vRP.prepare("vRP/get_whitelisted", "SELECT whitelisted FROM vrp_users WHERE id = @user_id")
vRP.prepare("vRP/set_whitelisted", "UPDATE vrp_users SET whitelisted = @whitelisted WHERE id = @user_id")
vRP.prepare("vRP/update_ip", "UPDATE vrp_users SET ip = @ip WHERE id = @uid")
vRP.prepare("vRP/update_login", "UPDATE vrp_users SET last_login = @ll WHERE id = @uid")
vRP.prepare("vRP/get_users_estasempulso", "SELECT * FROM vrp_sempulso WHERE idCidadao = @idCidadao and semPulso = 1")
vRP.prepare("vRP/delete_users_sempulso", "DELETE FROM vrp_sempulso WHERE idCidadao = @idCidadao")
vRP.prepare("vRP/set_users_sempulso", "INSERT INTO vrp_sempulso (idCidadao,semPulso) VALUES (@idCidadao, @semPulso)")

-----------------------------------------------------------------------------------------------------------------------------------------
---PULSO--------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.get_estasempulso(nuser_id)
	local rows = vRP.query("vRP/get_users_estasempulso", { idCidadao = nuser_id })
	if #rows > 0 then
		return rows
	else
		return ""
	end
end

function vRP.del_sempulso(user_id)
	vRP.execute("vRP/delete_users_sempulso", { idCidadao = user_id })
end

function vRP.setsempulso(idCidadao)
	vRP.execute("vRP/set_users_sempulso", { idCidadao = idCidadao, semPulso = 1 })
end

-----------------------------------------------------------------------------------------------------------------------------------------
-------VRPEX NORMAL----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.isBanned(user_id, cbr)
	local rows = vRP.query("vRP/get_banned", { user_id = user_id })
	if #rows > 0 then
		return rows[1].banned
	else
		return false
	end
end

function vRP.setBanned(user_id, banned)
	vRP.execute("vRP/set_banned", { user_id = user_id, banned = banned })
end

function vRP.getUserIdByIdentifier(ids)
	local rows = vRP.query("vRP/userid_byidentifier", { identifier = ids })
	if #rows > 0 then
		return rows[1].user_id
	else
		return -1
	end
end

function vRP.getUserIdByIdentifiers(ids)
	if ids and #ids then
		for i = 1, #ids do
			if (string.find(ids[i], "ip:") == nil) then
				local rows = vRP.query("vRP/userid_byidentifier", { identifier = ids[i] })
				if #rows > 0 then
					return rows[1].user_id
				end
			end
		end

		local rows, affected = vRP.query("vRP/create_user", {})

		if #rows then
			local user_id = rows[1].id
			for l, w in pairs(ids) do
				if (string.find(w, "ip:") == nil) then
					vRP.execute("vRP/add_identifier", { user_id = user_id, identifier = w })
				end
			end
			return user_id
		end
	end
end

function vRP.getSteam(source)
	local identifiers = GetPlayerIdentifiers(source)
	for k, v in ipairs(identifiers) do
		if string.sub(v, 1, 5) == 'steam' then
			return v
		end
	end
end

function vRP.getPlayerEndpoint(player)
	return GetPlayerEP(player) or "0.0.0.0"
end

function vRP.isWhitelisted(user_id, cbr)
	local rows = vRP.query("vRP/get_whitelisted", { user_id = user_id })
	if #rows > 0 then
		return rows[1].whitelisted
	else
		return false
	end
end

function vRP.setWhitelisted(user_id, whitelisted)
	vRP.execute("vRP/set_whitelisted", { user_id = user_id, whitelisted = whitelisted })
end

function vRP.setUData(user_id, key, value)
	vRP.execute("vRP/set_userdata", { user_id = user_id, key = key, value = value })
end

function vRP.getUData(user_id, key, cbr)
	local rows = vRP.query("vRP/get_userdata", { user_id = user_id, key = key })
	if #rows > 0 then
		return rows[1].dvalue
	else
		return ""
	end
end

function vRP.setSData(key, value)
	vRP.execute("vRP/set_srvdata", { key = key, value = value })
end

function vRP.getSData(key, cbr)
	local rows = vRP.query("vRP/get_srvdata", { key = key })
	if #rows > 0 then
		return rows[1].dvalue
	else
		return ""
	end
end

function vRP.getUserDataTable(user_id)
	return vRP.user_tables[user_id]
end

function vRP.getUserTmpTable(user_id)
	return vRP.user_tmp_tables[user_id]
end

function vRP.getUserId(source)
	if source ~= nil then
		local ids = GetPlayerIdentifiers(source)
		if ids ~= nil and #ids > 0 then
			return vRP.users[ids[1]]
		end
	end
	return nil
end

function vRP.getUsers()
	local users = {}
	for k, v in pairs(vRP.user_sources) do
		users[k] = v
	end
	return users
end

function vRP.getUserSource(user_id)
	return vRP.user_sources[user_id]
end

function vRP.kick(source, reason)
	DropPlayer(source, reason)
end

function vRP.dropPlayer(source)
	local source = source
	local user_id = vRP.getUserId(source)
	vRPclient._removePlayer(-1, source)
	if user_id then
		if user_id and source then
			local identity = vRP.getUserIdentity(user_id)
			if vRP.hasGroup(user_id, "ComandoOn") then
				vRP.addUserGroup(user_id, "ComandoOff")
				SendWebhookMessage(base.recordPolice,
					"```prolog\n[POLICIAL]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "CoronelOn") then
				vRP.addUserGroup(user_id, "CoronelOff")
				SendWebhookMessage(base.recordPolice,
					"```prolog\n[POLICIAL]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "TenenteCoronelOn") then
				vRP.addUserGroup(user_id, "TenenteCoronelOff")
				SendWebhookMessage(base.recordPolice,
					"```prolog\n[POLICIAL]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "MajorOn") then
				vRP.addUserGroup(user_id, "MajorOff")
				SendWebhookMessage(base.recordPolice,
					"```prolog\n[POLICIAL]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "CapitãoOn") then
				vRP.addUserGroup(user_id, "CapitãoOff")
				SendWebhookMessage(base.recordPolice,
					"```prolog\n[POLICIAL]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "TenenteOn") then
				vRP.addUserGroup(user_id, "TenenteOff")
				SendWebhookMessage(base.recordPolice,
					"```prolog\n[POLICIAL]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "SubTenenteOn") then
				vRP.addUserGroup(user_id, "SubTenenteOff")
				SendWebhookMessage(base.recordPolice,
					"```prolog\n[POLICIAL]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "1SargentoOn") then
				vRP.addUserGroup(user_id, "1SargentoOff")
				SendWebhookMessage(base.recordPolice,
					"```prolog\n[POLICIAL]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "2SargentoOn") then
				vRP.addUserGroup(user_id, "2SargentoOff")
				SendWebhookMessage(base.recordPolice,
					"```prolog\n[POLICIAL]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "3SargentoOn") then
				vRP.addUserGroup(user_id, "3SargentoOff")
				SendWebhookMessage(base.recordPolice,
					"```prolog\n[POLICIAL]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "CaboOn") then
				vRP.addUserGroup(user_id, "CaboOff")
				SendWebhookMessage(base.recordPolice,
					"```prolog\n[POLICIAL]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "SoldadoOn") then
				vRP.addUserGroup(user_id, "SoldadoOff")
				SendWebhookMessage(base.recordPolice,
					"```prolog\n[POLICIAL]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "RecrutaOn") then
				vRP.addUserGroup(user_id, "RecrutaOff")
				SendWebhookMessage(base.recordPolice,
					"```prolog\n[POLICIAL]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")

				--[[ POLICIA CIVIL]]
			elseif vRP.hasGroup(user_id, "DelegadoOn") then
				vRP.addUserGroup(user_id, "DelegadoOff")
				SendWebhookMessage(base.recordPolice,
					"```prolog\n[POLICIAL]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "PeritoOn") then
				vRP.addUserGroup(user_id, "PeritoOff")
				SendWebhookMessage(base.recordPolice,
					"```prolog\n[POLICIAL]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "InvestigadorOn") then
				vRP.addUserGroup(user_id, "InvestigadorOff")
				SendWebhookMessage(base.recordPolice,
					"```prolog\n[POLICIAL]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")

				--[[ HOSPITAL ]]
			elseif vRP.hasGroup(user_id, "DiretorOn") then
				vRP.addUserGroup(user_id, "DiretorOff")
				SendWebhookMessage(base.recordMedical,
					"```prolog\n[PARAMEDICO]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "VDiretorOn") then
				vRP.addUserGroup(user_id, "VDiretorOff")
				SendWebhookMessage(base.recordMedical,
					"```prolog\n[PARAMEDICO]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "SupervisorOn") then
				vRP.addUserGroup(user_id, "SupervisorOff")
				SendWebhookMessage(base.recordMedical,
					"```prolog\n[PARAMEDICO]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "SupervisorEnfOn") then
				vRP.addUserGroup(user_id, "SupervisorEnfOff")
				SendWebhookMessage(base.recordMedical,
					"```prolog\n[PARAMEDICO]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "SupervisorEnfOn") then
				vRP.addUserGroup(user_id, "SupervisorEnfOff")
				SendWebhookMessage(base.recordMedical,
					"```prolog\n[PARAMEDICO]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "MedicoOn") then
				vRP.addUserGroup(user_id, "MedicoOff")
				SendWebhookMessage(base.recordMedical,
					"```prolog\n[PARAMEDICO]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "EnfermeiroOn") then
				vRP.addUserGroup(user_id, "EnfermeiroOff")
				SendWebhookMessage(base.recordMedical,
					"```prolog\n[PARAMEDICO]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "TEnfermeiroOn") then
				vRP.addUserGroup(user_id, "TEnfermeiroOff")
				SendWebhookMessage(base.recordMedical,
					"```prolog\n[PARAMEDICO]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "ParamedicoOn") then
				vRP.addUserGroup(user_id, "ParamedicoOff")
				SendWebhookMessage(base.recordMedical,
					"```prolog\n[PARAMEDICO]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "SocorristaOn") then
				vRP.addUserGroup(user_id, "SocorristaOff")
				SendWebhookMessage(base.recordMedical,
					"```prolog\n[PARAMEDICO]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "SocorristaOn") then
				vRP.addUserGroup(user_id, "SocorristaOff")
				SendWebhookMessage(base.recordMedical,
					"```prolog\n[PARAMEDICO]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")

				--[[ VILLE RACING ]]
			elseif vRP.hasGroup(user_id, "VilleChefeOn") then
				vRP.addUserGroup(user_id, "VilleChefeOff")
				SendWebhookMessage(base.mecanico,
					"```prolog\n[MECANICO]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "VilleGerenteOn") then
				vRP.addUserGroup(user_id, "VilleGerenteOff")
				SendWebhookMessage(base.mecanico,
					"```prolog\n[MECANICO]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			elseif vRP.hasGroup(user_id, "VilleMembroOn") then
				vRP.addUserGroup(user_id, "VilleMembroOff")
				SendWebhookMessage(base.mecanico,
					"```prolog\n[MECANICO]: " ..
					user_id ..
					" " ..
					identity.name ..
					" " ..
					identity.firstname ..
					" \n[===========SAIU DE SERVICO (QUITOU EM SERVICO)==========] " ..
					os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. " \r```")
			end
			vRP.setUData(user_id, "vRP:datatable", json.encode(vRP.getUserDataTable(user_id)))
			vRP.users[vRP.rusers[user_id]] = nil
			vRP.rusers[user_id] = nil
			vRP.user_tables[user_id] = nil
			vRP.user_tmp_tables[user_id] = nil
			vRP.user_sources[user_id] = nil
		end
	end
end

function task_save_datatables()
	SetTimeout(60000, task_save_datatables)
	TriggerEvent("vRP:save")
	for k, v in pairs(vRP.user_tables) do
		vRP.setUData(k, "vRP:datatable", json.encode(v))
	end
end

async(function()
	task_save_datatables()
end)



AddEventHandler("queue:playerConnecting", function(source, ids, name, setKickReason, deferrals)
	deferrals.defer()
	local source = source
	local ids = ids


	if ids ~= nil and #ids > 0 then
		deferrals.update("Carregando identidades.")
		local user_id = vRP.getUserIdByIdentifiers(ids)
		if user_id then
			deferrals.update("Carregando banimentos.")
			if not vRP.isBanned(user_id) then
				deferrals.update("Carregando whitelist.")
				if vRP.isWhitelisted(user_id) then
					vRP.execute("vRP/update_login", { ll = os.date("%H:%M:%S %d/%m/%Y"), uid = user_id })
					vRP.execute("vRP/update_ip", { ip = vRP.getPlayerEndpoint(source), uid = user_id })
					if vRP.rusers[user_id] == nil then
						deferrals.update("Carregando banco de dados.")
						--ExecuteCourotineBan(user_id, source)
						deferrals.done()
					else
						local tmpdata = vRP.getUserTmpTable(user_id)
						tmpdata.spawns = 0
						TriggerEvent("vRP:playerRejoin", user_id, source, name)
						deferrals.done()
					end
				else
					deferrals.done("Você não possui allowlist na cidade! [ Adquira seu visto em: discord.gg/ostivillerp ][ ID: " ..
						user_id .. " ]")
					TriggerEvent("queue:playerConnectingRemoveQueues", ids)
				end
			else
				deferrals.done("Sua conta foi banida! [ Mais informações em: discord.gg/ostivillerp ] ")
				TriggerEvent("queue:playerConnectingRemoveQueues", ids)
			end
		else
			deferrals.done("Ocorreu um problema de identificação.")
			TriggerEvent("queue:playerConnectingRemoveQueues", ids)
		end
	else
		deferrals.done("Ocorreu um problema de identidade.")
		TriggerEvent("queue:playerConnectingRemoveQueues", ids)
	end
end)

AddEventHandler("playerDropped", function(reason)
	local source = source
	vRP.dropPlayer(source)
end)

RegisterServerEvent("vRPcli:playerSpawned")
AddEventHandler("vRPcli:playerSpawned", function()
	TriggerClientEvent("chars:setupChar", source)
end)

RegisterServerEvent("baseModule:idLoaded")
AddEventHandler("baseModule:idLoaded", function(source, user_id)
	if user_id then
		local steam = vRP.getSteam(source)
		local sdata = vRP.getUData(user_id, "vRP:datatable")
		local consultChars = vRP.query('vRP/get_usersBenefits', { steam = steam })

		vRP.users[steam] = user_id
		vRP.rusers[user_id] = steam
		vRP.user_tables[user_id] = {}
		vRP.user_tmp_tables[user_id] = {}
		vRP.user_sources[user_id] = source

		local data = json.decode(sdata)
		if type(data) == "table" then vRP.user_tables[user_id] = data end

		local tmp = vRP.getUserTmpTable(user_id)
		tmp.spawns = 0

		tmp.spawns = tmp.spawns + 1
		local first_spawn = (tmp.spawns == 1)

		TriggerEvent("vRP:playerJoin", user_id, source, steam)

		if first_spawn then
			for k, v in pairs(vRP.user_sources) do
				vRPclient._addPlayer(source, v)
			end
			vRPclient._addPlayer(-1, source)
			Tunnel.setDestDelay(source, 0)
			if #consultChars == 0 then
				vRP.execute('vRP/add_benefitsChars', { user_id = user_id, identifier = steam })
			end
		end
		TriggerEvent("vRP:playerSpawn", user_id, source, first_spawn)
		TriggerEvent('character-creator:spawn', user_id, source, first_spawn)
		--exports["nation_tattoos"].getOverlays()
	end
end)

function vRP.getDayHours(seconds)
	local days = math.floor(seconds / 86400)
	seconds = seconds - days * 86400
	local hours = math.floor(seconds / 3600)

	if days > 0 then
		return string.format("<b>%d Dias</b> e <b>%d Horas</b>", days, hours)
	else
		return string.format("<b>%d Horas</b>", hours)
	end
end

function vRP.getMinSecs(seconds)
	local days = math.floor(seconds / 86400)
	seconds = seconds - days * 86400
	local hours = math.floor(seconds / 3600)
	seconds = seconds - hours * 3600
	local minutes = math.floor(seconds / 60)
	seconds = seconds - minutes * 60

	if minutes > 0 then
		return string.format("<b>%d Minutos</b> e <b>%d Segundos</b>", minutes, seconds)
	else
		return string.format("<b>%d Segundos</b>", seconds)
	end
end

--FIX GARMAS + QUIT
vRP.remove_weapon_table = function(user_id, index)
	if vRP.user_tables[user_id].weapons then
		for k, v in pairs(vRP.user_tables[user_id].weapons) do
			vRP.user_tables[user_id].weapons[index] = nil
		end
		vRP.setUData(user_id, "vRP:datatable", json.encode(vRP.getUserDataTable(user_id)))
	end
end
