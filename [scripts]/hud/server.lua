local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
ALIEN = {}
Tunnel.bindInterface("hud", ALIEN)
