-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Notify")
AddEventHandler("Notify",function(css,mensagem,timer)

	if not timer or timer == "" then
		timer = 5000
	end
	SendNUIMessage({ css = css, mensagem = mensagem, timer = timer })
end)

RegisterCommand("testenotify55",function(source,args)
	TriggerEvent('Notify', 'aviso',"Osti Ville - Episódio 1 <b>MELHOR SERVER</b>",10000)

end)
