Hooks:PostHook(CharacterTweakData, "init", "RR_Set_Enemy_Chatter", function(self)
	-- Speech prefix shit
	local job = Global.level_data and Global.level_data.level_id
	if job == "nightclub" or job == "short2_stage1" or job == "jolly" or job == "spa" then
		self.gangster.speech_prefix_p1 = "rt"
		self.gangster.speech_prefix_p2 = nil
		self.gangster.speech_prefix_count = 2
	elseif job == "alex_2" then
		self.gangster.speech_prefix_p1 = "ict"
		self.gangster.speech_prefix_p2 = nil
		self.gangster.speech_prefix_count = 2
	elseif job == "welcome_to_the_jungle_1" then
		self.gangster.speech_prefix_p1 = "bik"
		self.gangster.speech_prefix_p2 = nil
		self.gangster.speech_prefix_count = 2
	else
		self.gangster.speech_prefix_p1 = "lt"
		self.gangster.speech_prefix_p2 = nil
		self.gangster.speech_prefix_count = 2
	end
	
	-- No, they weren't supposed to sound like cops
	self.mobster.speech_prefix_p1 = "rt"
	self.mobster.speech_prefix_p2 = nil
	self.mobster.speech_prefix_count = 2
	self.biker.speech_prefix_p1 = "bik"
	self.biker.speech_prefix_p2 = nil
	self.biker.speech_prefix_count = 2
	
	if self.tweak_data and self.tweak_data.levels then
		local faction = self.tweak_data.levels:get_ai_group_type()			
		if faction == "america" then
			-- Removed some radio filtered voices due to the player equipment lines
			-- I am not interested in adding an option for the radio voices so don't bug me about it
			-- These are required for the sabotaging power, drill and generic lines to play
			self.heavy_swat.speech_prefix_p2 = "d"
			self.fbi_heavy_swat.speech_prefix_p2 = "d"
			self.shield.speech_prefix_p2 = "d" 
			self.shield.speech_prefix_count = 5 -- Shields can have l5d, which is a very distinctive voiceset that goes unused in vanilla
		end
	end

	self.shield.tags = {
		"law",
		"shield",
	}

	-- Give special enemies lines declaring they have spawned
	self.tank.spawn_sound_event = self.tank.speech_prefix_p1 .. "_entrance" --BULLDOZER, COMING THROUGH!!!
	self.tank_medic.spawn_sound_event = self.tank.speech_prefix_p1 .. "_entrance_elite" --ELITE BULLDOZER, COMING THROUGH!!!
	self.tank_mini.spawn_sound_event = self.tank.speech_prefix_p1 .. "_entrance_elite" --ELITE BULLDOZER, COMING THROUGH!!!
	self.shield.spawn_sound_event = "shield_identification" -- knock knock, it's a cocking shield
	self.taser.spawn_sound_event = self.taser.speech_prefix_p1 .. "_entrance" -- Taser, Taser!
	self.sniper.spawn_sound_event = "mga_deploy_snipers"
	-- TODO: Give Zeal tasers _entrance_elite

	-- Give enemies their chatter setups
	local swat = {
		entry = true,
		aggressive = true,
		enemyidlepanic = true,
		controlpanic = true,
		retreat = true,
		contact = true,
		clear = true,
		clear_whisper = true,
		go_go = true,
		push = true,
		reload = true,
		look_for_angle = true,
		ecm = true,
		saw = true,
		trip_mines = true,
		sentry = true,
		ready = true,
		smoke = true,
		flash_grenade = true,
		follow_me = true,
		deathguard = true,
		open_fire = true,
		suppress = true,
		dodge = true,
		cuffed = true,
		incomming_tank = true,
		incomming_spooc = true,
		incomming_shield = true,
		incomming_taser = true
	}
	local gangster = {
		aggressive = true,
		retreat = true,
		contact = true,
		go_go = true,
		suppress = true,
		enemyidlepanic = true
	}
	local cop = {
		aggressive = true,
		contact = true,
		enemyidlepanic = true,
		controlpanic = true,
		clear = true,
		clear_whisper = true,
		clear_whisper_2 = true,
		ecm = true,
		saw = true,
		trip_mines = true,
		sentry = true,
		suppress = true,
		dodge = true,
		cuffed = true,
		incomming_tank = true,
		incomming_spooc = true,
		incomming_shield = true,
		incomming_taser = true
	}
	local security = {
		aggressive = true,
		contact = true,
		clear_whisper = true,
		clear_whisper_2 = true,
		ecm = true,
		saw = true,
		trip_mines = true,
		sentry = true,
		suppress = true,
		dodge = true,
		cuffed = true
	}

	self.tank.chatter = {
		contact = true,
		aggressive = true,
		retreat = true,
		approachingspecial = true
	}
	self.spooc.chatter = {
		cloakercontact = true,
		go_go = true, --only used for russian cloaker
		cloakeravoidance = true --only used for russian cloaker
	}
	self.shield.chatter = {
		entry = true,
		aggressive = true,
		enemyidlepanic = true,
		controlpanic = true,
		retreat = true,
		contact = true,
		clear = true,
		clear_whisper = true,
		go_go = true,
		push = true,
		reload = true,
		look_for_angle = true,
		ecm = true,
		saw = true,
		trip_mines = true,
		sentry = true,
		ready = true,
		follow_me = true,
		deathguard = true,
		open_fire = true,
		suppress = true,
		cuffed = true,
		incomming_tank = true,
		incomming_spooc = true,
		incomming_shield = true,
		incomming_taser = true
	}
	self.medic.chatter = {
		aggressive = true,
		contact = true
	}
	self.taser.chatter = {
		contact = true,
		aggressive = true,
		retreat = true,
		approachingspecial = true
	}
	self.swat.chatter = swat
	self.fbi.chatter = swat
	self.heavy_swat.chatter = swat
	self.fbi_swat.chatter = swat
	self.fbi_heavy_swat.chatter = swat
	self.city_swat.chatter = swat
	self.gangster.chatter = gangster
	self.mobster.chatter = gangster
	self.biker.chatter = gangster
	self.biker_escape.chatter = gangster
	self.bolivian.chatter = gangster
	self.bolivian_indoors.chatter = gangster
	self.cop.chatter = cop
	self.gensec.chatter = security
	self.security.chatter = security
	self.security_undominatable.chatter = security
	self.security_mex.chatter = security
	self.security_mex_no_pager.chatter = security
end)