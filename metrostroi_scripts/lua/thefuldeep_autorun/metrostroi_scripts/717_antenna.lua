if SERVER then resource.AddWorkshop("2236239064") end

if CLIENT then
	MetrostroiWagNumUpdateRecieve = MetrostroiWagNumUpdateRecieve or function(index)
		local ent = Entity(index)
		--таймер, чтобы дождаться обновления сетевых значений (ну а вдруг)
		timer.Simple(0.3,function()
			if IsValid(ent) and ent.UpdateWagNumCallBack then 
				ent:UpdateWagNumCallBack()
				--ent:UpdateTextures()
			end
		end)
	end
end

if SERVER then
	local hooks = hook.GetTable()
	if not hooks.MetrostroiSpawnerUpdate or not hooks.MetrostroiSpawnerUpdate["Call hook on clientside"] then
		hook.Add("MetrostroiSpawnerUpdate","Call hook on clientside",function(ent)
			if not IsValid(ent) then return end
			local idx = ent:EntIndex()
			for _,ply in pairs(player.GetHumans())do
				if IsValid(ply)then ply:SendLua("MetrostroiWagNumUpdateRecieve("..idx..")")end
			end
		end)
	end
end

local function RemoveEnt(wag,prop)
	local ent = wag.ClientEnts and wag.ClientEnts[prop]
	if IsValid(ent) then SafeRemoveEntity(ent)end
end

local function UpdateCpropCallBack(ENT,cprop,modelcallback,precallback,callback)	
	if not ENT.UpdateWagNumCallBack then
		function ENT:UpdateWagNumCallBack()end
	end
	
	if modelcallback then
		local oldmodelcallback = ENT.ClientProps[cprop].modelcallback or function() end
		ENT.ClientProps[cprop].modelcallback = function(wag,...)
			return modelcallback(wag) or oldmodelcallback(wag,...)
		end
		
		local oldstartedcallback = ENT.UpdateWagNumCallBack
		ENT.UpdateWagNumCallBack = function(wag)
			oldstartedcallback(wag)
			RemoveEnt(wag,cprop)
		end
	end
	
	if precallback then
		local oldcallback = ENT.ClientProps[cprop].callback or function() end
		ENT.ClientProps[cprop].callback = function(wag,cent,...)
			precallback(wag,cent)
			oldcallback(wag,cent,...)
		end
		
		local oldstartedcallback = ENT.UpdateWagNumCallBack
		ENT.UpdateWagNumCallBack = function(wag)
			oldstartedcallback(wag)
			RemoveEnt(wag,cprop)
		end
	end
	
	if callback then
		local oldcallback = ENT.ClientProps[cprop].callback or function() end
		ENT.ClientProps[cprop].callback = function(wag,cent,...)
			oldcallback(wag,cent,...)
			callback(wag,cent)
		end
		
		local oldstartedcallback = ENT.UpdateWagNumCallBack
		ENT.UpdateWagNumCallBack = function(wag)
			oldstartedcallback(wag)
			RemoveEnt(wag,cprop)
		end
	end
end


hook.Add("InitPostEntity","Metrostroi 717 antenna",function()
	local NOMER = scripted_ents.GetStored("gmod_subway_81-717_mvm")
	if not NOMER then return else NOMER = NOMER.t end
	local NOMER_CUSTOM = scripted_ents.GetStored("gmod_subway_81-717_mvm_custom").t
	
	table.insert(NOMER_CUSTOM.Spawner,9,{"Antenna","Антенна","Boolean"})
	
	if SERVER then return end
	
	NOMER.ClientProps["antenna"] = {
        model = "models/metrostroi_train/81-717/antenna.mdl",
        pos = Vector(-0.2,0,0.2),
        ang = Angle(0,0,0),
        hide=2
    }
	
	--если UpdateWagNumCallBack не вызвалась из-за того, что состав уже был
	UpdateCpropCallBack(
		NOMER,
		"antenna",
		nil,
		nil,
		function(wag)
			wag:ShowHide("antenna",wag:GetNW2Bool("Antenna"))--скроется, если прогрузится, но должно быть скрыто
		end
	)
	
	local oldupdate = NOMER.UpdateWagNumCallBack
	NOMER.UpdateWagNumCallBack = function(wag)
		oldupdate(wag)
		wag:ShowHide("antenna",wag:GetNW2Bool("Antenna"))
	end
end)

