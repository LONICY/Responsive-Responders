Hooks:PostHook(CharacterTweakData, "init", "RR_Set_Enemy_Chatter", function(self, tweak_data)
	-- Speech prefix shit
	local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings and Global.game_settings.difficulty or "normal")
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
	
	if tweak_data and tweak_data.levels then
		local faction = tweak_data.levels:get_ai_group_type()			
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

	-- overkill please fix
	self.gensec.speech_prefix_p1 = self._unit_prefixes.cop
	self.cop.speech_prefix_p1 = self._unit_prefixes.cop -- no idea why this fucker is tied to swat
	self.cop_scared.speech_prefix_p1 = self._unit_prefixes.cop -- no idea why this fucker is tied to swat
	self.fbi.speech_prefix_p1 = self._unit_prefixes.cop -- no idea why this fucker is tied to swat
	self.sniper.speech_prefix_p1 = self._unit_prefixes.cop -- unfiltered voice
	self.shield.speech_prefix_p1 = self._unit_prefixes.heavy_swat

	-- Give special enemies lines declaring they have spawned
	self.tank.spawn_sound_event = self.tank.speech_prefix_p1 .. "_entrance" -- BULLDOZER, COMING THROUGH!!!
	self.tank_medic.spawn_sound_event = self.tank_medic.speech_prefix_p1 .. "_entrance_elite" -- ELITE BULLDOZER, COMING THROUGH!!!
	self.tank_mini.spawn_sound_event = self.tank_mini.speech_prefix_p1 .. "_entrance_elite" -- ELITE BULLDOZER, COMING THROUGH!!!
	self.shield.spawn_sound_event = "shield_identification" -- knock knock, it's a cocking shield
	if difficulty_index >= 8 then
		self.taser.spawn_sound_event = self.taser.speech_prefix_p1 .. "_elite" -- Elite taser, coming through!
	else
		self.taser.spawn_sound_event = self.taser.speech_prefix_p1 .. "_entrance" -- Taser, Taser!
	end
	self.sniper.spawn_sound_event = "mga_deploy_snipers"

	-- Give enemies their chatter setups
	local chatter_setups = {
		heavy_swat = {
			entry = true,
			aggressive = true,
			retreat = true,
			contact = true,
			clear = true,
			go_go = true,
			push = true,
			reload = true,
			look_for_angle = true,
			inpos = true,
			saw = true,
			trip_mine = true,
			sentry = true,
			ready = true,
			smoke = true,
			flash_grenade = true,
			open_fire = true,
			sabotagepower = true,
			sabotagedrill = true,
			sabotagegeneric = true,
			sabotagegear = true,
			sabotagebags = true,
			sabotagehostages = true
		},
		swat = {
			entry = true,
			aggressive = true,
			retreat = true,
			contact = true,
			clear = true,
			go_go = true,
			push = true,
			reload = true,
			look_for_angle = true,
			inpos = true,
			saw = true,
			ammo_bag = true,
			doctor_bag = true,
			first_aid_kit = true,
			trip_mine = true,
			sentry = true,
			ready = true,
			smoke = true,
			flash_grenade = true,
			open_fire = true,
			sabotagebags = true,
			sabotagehostages = true
		},
		gangster = {
			aggressive = true,
			contact = true,
			go_go = true
		},
		cop = {
			aggressive = true,
			contact = true,
			clear = true,
			clear_whisper = true,
			saw = true,
			ammo_bag = true,
			doctor_bag = true,
			first_aid_kit = true,
			trip_mine = true,
			sentry = true
		},
		security = {
			aggressive = true,
			contact = true,
			clear_whisper = true
		}
	}

	self.tank.chatter = {
		contact = true,
		aggressive = true,
		approachingspecial = true
	}
	self.tank_medic.chatter = self.tank.chatter
	self.tank_mini.chatter = self.tank.chatter
	self.spooc.chatter = {
		cloakercontact = true,
		go_go = true, --only used for russian cloaker
		cloakeravoidance = true --only used for russian cloaker
	}
	self.shield.chatter = {
		entry = true,
		aggressive = true,
		contact = true,
		clear = true,
		go_go = true,
		push = true,
		reload = true,
		inpos = true,
		look_for_angle = true,
		saw = true,
		trip_mine = true,
		sentry = true,
		ready = true,
		follow_me = true,
		open_fire = true
	}
	self.medic.chatter = {
		aggressive = true,
		contact = true
	}
	self.taser.chatter = {
		contact = true,
		aggressive = true,
		approachingspecial = true
	}
	self.swat.chatter = chatter_setups.swat
	self.fbi.chatter = chatter_setups.swat
	self.heavy_swat.chatter = chatter_setups.heavy_swat
	self.fbi_swat.chatter = chatter_setups.swat
	self.fbi_heavy_swat.chatter = chatter_setups.heavy_swat
	self.city_swat.chatter = chatter_setups.swat
	self.gangster.chatter = chatter_setups.gangster
	self.mobster.chatter = chatter_setups.gangster
	self.biker.chatter = chatter_setups.gangster
	self.biker_escape.chatter = chatter_setups.gangster
	self.bolivian.chatter = chatter_setups.gangster
	self.bolivian_indoors.chatter = chatter_setups.gangster
	self.cop.chatter = chatter_setups.cop
	self.gensec.chatter = chatter_setups.security
	self.security.chatter = chatter_setups.security
	self.security_undominatable.chatter = chatter_setups.security
	self.security_mex.chatter = chatter_setups.security
	self.security_mex_no_pager.chatter = chatter_setups.security
end)
