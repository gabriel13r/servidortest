-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("skinshop",cRP)
vCLIENT = Tunnel.getInterface("skinshop")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKOPEN
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.checkOpen()
	local source = source
	local user_id = vRP.getUserId(source)
	local vida = vRPclient.getHealth(source)
		if not vRPclient.isHandcuffed(source) then
			if user_id then
				if vida <= 101 then TriggerClientEvent('Notify', source, 'importante', 'Você não pode fazer isso em coma.') return end
				return true
			end
			return false
	end
end

function cRP.checkPermission()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.hasPermission(user_id,"booster.permissao") or vRP.hasPermission(user_id,"investidor.permissao") or vRP.hasPermission(user_id,"investidorplus.permissao") or vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"fto.permissao") then
			return true
		end
	else
		return false
	end
	TriggerClientEvent('Notify', source, 'importante', 'Você não tem permissão')
end