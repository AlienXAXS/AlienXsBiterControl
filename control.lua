
local function isModEnabled()
	return settings.global["cbc-enabled"].value
end

local function onInit()
	global.settings = {}
	global.settings.preGameSpeed = 0
	
	-- Save our current evolution factor, in case we are running on an existing save
	global.settings.evolution_factor_by_time = game.forces["enemy"].evolution_factor_by_time
	global.settings.evolution_factor_by_pollution = game.forces["enemy"].evolution_factor_by_pollution
	global.settings.evolution_factor_by_killing_spawners = game.forces["enemy"].evolution_factor_by_killing_spawners
	
	log("CBC: Mod Init Complete")
end

local function onLoad()
	-- While not needed really, it ensures the global table settings exists.
	if not global.settings then global.settings = {} end
	
	log("CBC: Mod Load Complete")
end

local function runMod(expectedPlayerCount)
	if ( not isModEnabled() ) then return end
	
	local playerCount = #game.connected_players
	if ( playerCount == expectedPlayerCount and global.settings.preGameSpeed == 0 ) then
		-- We're at 1 players (or none), so this will be the last player, let's configure the biters now.
		
		log("#####################################################################")
		log("CBC: There are no players in the server, setting AI & Biter states!")
		
		local bitersDisabled = settings.global["cbc-biters-disable"].value
		local bitersForcedDisable = settings.global["cbc-biters-force-disable"].value
		local pausedGameSpeed = settings.global["cbc-game-speed"].value
		
		if ( bitersDisabled ) then
			log("CBC: Disabling Biter AI")
			global.settings.bitersDisabled = bitersDisabled
			
			-- Disable the vanilla AI
			game.forces.enemy.ai_controllable = false
		end
		
		if ( bitersForcedDisable ) then
			log("CBC: Disabling Biter AI (FORCED)")
			global.settings.bitersForcedDisable = bitersForcedDisable
			
			for _,surface in pairs(game.surfaces) do
				for _,ent in ipairs(surface.find_entities_filtered({force="enemy"})) do
					ent.active = false
				end
			end
		end
		
		log("CBC: Setting game speed to " .. pausedGameSpeed .. " from " .. game.speed)
		global.settings.preGameSpeed = game.speed
		game.speed = pausedGameSpeed
		
		if ( game.forces["enemy"] ) then
			-- Save our evolution settings
			global.settings.evolution_factor_by_time = game.forces["enemy"].evolution_factor_by_time
			global.settings.evolution_factor_by_pollution = game.forces["enemy"].evolution_factor_by_pollution
			global.settings.evolution_factor_by_killing_spawners = game.forces["enemy"].evolution_factor_by_killing_spawners
			
			log("CBC: Evolution settings saved for restore later")
			log("CBC: time: " .. global.settings.evolution_factor_by_time .. " | pollution: " .. global.settings.evolution_factor_by_pollution .. " | killing_spawners: " .. global.settings.evolution_factor_by_killing_spawners)
		end
		
		log("#####################################################################")
	end
end

local function onPlayerJoinedGame(pid)
	if ( not isModEnabled() ) then return end
	
	log("#####################################################################")
	log("CBC: Player has joined the game, enabling biters again")
	if ( global.settings.bitersDisabled ) then
		-- Reenable the biter AI
		global.settings.bitersDisabled = not bitersDisabled
		game.forces.enemy.ai_controllable = true
	end
	
	if ( global.settings.bitersForcedDisable ) then
		global.settings.bitersForcedDisable = not bitersForcedDisable
		
		for _,surface in pairs(game.surfaces) do
			for _,ent in ipairs(surface.find_entities_filtered({force="enemy"})) do
				ent.active = true
			end
		end
	end
	
	if ( global.settings.preGameSpeed > 0 ) then
		game.speed = global.settings.preGameSpeed
		global.settings.preGameSpeed = 0
	end
		
	if ( game.forces["enemy"] ) then
		-- Restore our evolution settings from memory
		log("CBC: Evolution settings pre-patch")
		log("CBC: time: " .. game.forces["enemy"].evolution_factor_by_time .. " | pollution: " .. game.forces["enemy"].evolution_factor_by_pollution .. " | killing_spawners: " .. game.forces["enemy"].evolution_factor_by_killing_spawners)
		
		
		-- Just check here if this mod is being loaded onto a new save, if it is do not apply evo, but instead capture it
		if ( global.settings.evolution_factor_by_time == nil or global.settings.evolution_factor_by_pollution == nil or global.settings.evolution_factor_by_killing_spawners == nil ) then
			log("CBC: Detected that this save has not seen CBC before, grabbing snapshot of evolution state")
			global.settings.evolution_factor_by_time = game.forces["enemy"].evolution_factor_by_time
			global.settings.evolution_factor_by_pollution = game.forces["enemy"].evolution_factor_by_pollution
			global.settings.evolution_factor_by_killing_spawners = game.forces["enemy"].evolution_factor_by_killing_spawners
		end
		
		game.forces["enemy"].evolution_factor_by_time = global.settings.evolution_factor_by_time
		game.forces["enemy"].evolution_factor_by_pollution = global.settings.evolution_factor_by_pollution
		game.forces["enemy"].evolution_factor_by_killing_spawners = global.settings.evolution_factor_by_killing_spawners
		
		
		log("CBC: Restoring Evolution")
		log("CBC: time: " .. game.forces["enemy"].evolution_factor_by_time .. " | pollution: " .. game.forces["enemy"].evolution_factor_by_pollution .. " | killing_spawners: " .. game.forces["enemy"].evolution_factor_by_killing_spawners)
	end
	
	log("CBC: Biters have been reset back to their previous state")
	log("#####################################################################")
end

local function onPrePlayerLeftGame(pid)
	runMod(1)
end

local function onNthTick()
	runMod(0)
end


script.on_init(onInit)
script.on_load(onLoad)
script.on_nth_tick(30, onNthTick)
script.on_event(defines.events.on_pre_player_left_game, onPrePlayerLeftGame)
script.on_event(defines.events.on_player_joined_game, onPlayerJoinedGame)