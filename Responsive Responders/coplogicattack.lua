local math_random = math.random

Hooks:PostHook(CopLogicAttack, "_upd_enemy_detection", "RR_upd_enemy_detection", function(data)

	local my_data = data.internal_data
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)

	if new_attention and new_reaction then
		if AIAttentionObject.REACT_COMBAT <= new_reaction and new_attention.nav_tracker and not my_data.walking_to_optimal_pos then
			if data.tactics and data.tactics.flank then
				if data.char_tweak.chatter and data.char_tweak.chatter.look_for_angle then		
					managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "look_for_angle" )
				end
			elseif data.tactics and data.tactics.ranged_fire then 
				if data.char_tweak.chatter and data.char_tweak.chatter.look_for_angle then		
					managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "inpos" )
				end
			end
		end
	end
end)

Hooks:PostHook(CopLogicAttack, "queue_update", "RR_queue_update", function(data, my_data)
	local hostage_count = managers.groupai:state():get_hostage_count_for_chatter() --check current hostage count
	local chosen_panic_chatter = "controlpanic" --set default generic assault break chatter
	
	if hostage_count > 0 then --make sure the hostage count is actually above zero before replacing any of the lines
		if hostage_count > 3 then  -- hostage count needs to be above 3
			if math_random() < 0.4 then --40% chance for regular panic if hostages are present
				chosen_panic_chatter = "controlpanic"
			else
				chosen_panic_chatter = "hostagepanic2" --more panicky "GET THOSE HOSTAGES OUT RIGHT NOW!!!" line for when theres too many hostages on the map
			end
		else
			if math_random() < 0.4 then
				chosen_panic_chatter = "controlpanic"
			else
				chosen_panic_chatter = "hostagepanic1" --less panicky "Delay the assault until those hostages are out." line
			end
		end
			
		if managers.groupai:state():chk_has_civilian_hostages() then
			--log("they got sausages!")
			if math_random() < 0.5 then
				chosen_panic_chatter = chosen_panic_chatter
			else
				chosen_panic_chatter = "civilianpanic"
			end
		end
			
	elseif managers.groupai:state():chk_had_hostages() then
		if math_random() < 0.4 then
			chosen_panic_chatter = "controlpanic"
		else
			chosen_panic_chatter = "hostagepanic3" -- no more hostages!!! full force!!!
		end
	end
	
	local chosen_sabotage_chatter = "sabotagegeneric" --set default sabotage chatter for variety's sake
	local skirmish_map = managers.skirmish:is_skirmish()--these shouldnt play on holdout
	local ignore_radio_rules = nil
	
	if level == "branchbank" then --bank heist
		chosen_sabotage_chatter = "sabotagedrill"
	elseif level == "nmh" or level == "man" or level == "framing_frame_3" or level == "rat" or level == "election_day_1" then --various heists where turning off the power is a frequent occurence
		chosen_sabotage_chatter = "sabotagepower"
	elseif level == "chill_combat" or level == "watchdogs_1" or level == "watchdogs_1_night" or level == "watchdogs_2" or level == "watchdogs_2_day" or level == "cane" then
		chosen_sabotage_chatter = "sabotagebags"
		ignore_radio_rules = true
	else
		chosen_sabotage_chatter = "sabotagegeneric" --if none of these levels are the current one, use a generic "Break their gear!" line
	end

	local clear_t_chk = not data.attention_obj or not data.attention_obj.verified_t or data.attention_obj.verified_t - data.t > math_random(2.5, 5)		
	local cant_say_clear = not data.attention_obj or AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and clear_t_chk
		
	if not cant_say_clear then
		if data.unit:movement():cool() and data.char_tweak.chatter and data.char_tweak.chatter.clear_whisper then
			managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear_whisper" )
		elseif not data.unit:movement():cool() then
			if not data.unit:base():has_tag("special") and not managers.groupai:state():chk_assault_active_atm() then
				if data.char_tweak.chatter and data.char_tweak.chatter.controlpanic then
					local clearchk = math.random(0, 90)
					local say_clear = 30
					if clearchk > 60 then
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear" )
					elseif clearchk > 30 then
						if not skirmish_map and my_data.radio_voice or not skirmish_map and ignore_radio_rules then
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
						else
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_panic_chatter )
						end
					else
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_panic_chatter )
					end
				elseif data.char_tweak.chatter and data.char_tweak.chatter.clear then
					managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear" )
				end
			else
				if data.unit:base():has_tag("tank") or data.unit:base():has_tag("taser") then
					managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "approachingspecial" )
				elseif data.unit:base()._tweak_table == "shield" then
					local shield_knock_cooldown = math.random(6, 12)
					if not my_data.shield_knock_cooldown or my_data.shield_knock_cooldown < data.t then
						my_data.shield_knock_cooldown = data.t + shield_knock_cooldown

						data.unit:sound():play("shield_identification", nil, true)
					end
				elseif data.unit:base()._tweak_table == "akuma" then
					managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "lotusapproach" )
				end
			end
		end
	end
	
	--mid-assault panic for cops based on alerts instead of opening fire, since its supposed to be generic action lines instead of for opening fire and such
	--I'm adding some randomness to these since the delays in groupaitweakdata went a bit overboard but also arent able to really discern things proper
				
	if data.char_tweak and data.char_tweak.chatter and data.char_tweak.chatter.enemyidlepanic and not data.is_converted then
		if not data.unit:base():has_tag("special") and data.unit:base():has_tag("law") then
			if managers.groupai:state():chk_assault_active_atm() then
				if managers.groupai:state():_check_assault_panic_chatter() then
					if data.attention_obj and data.attention_obj.verified and data.attention_obj.dis <= 500 or data.is_suppressed and data.attention_obj and data.attention_obj.verified then
						local roll = math.random(1, 100)
						local chance_suppanic = 50
						
						if roll <= chance_suppanic then
							local nroll = math.random(1, 100)
							local chance_help = 50
							if roll <= chance_suppanic then
								managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed1" )
							else
								managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed2" )
							end
						else
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
						end
					else
						if math.random() < 0.2 then
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
						else
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
						end
					end
				else
					local clearchk = math.random(0, 90)
						
					if clearchk > 60 then
						if not skirmish_map and my_data.radio_voice or not skirmish_map and ignore_radio_rules then
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
						end
					elseif chosen_panic_chatter == "civilianpanic" then
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_panic_chatter )
					end
				end
			end
		elseif not data.unit:base():has_tag("special") and data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.verified_t or not data.unit:base():has_tag("special") and data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.alert_t then
		
			if data.attention_obj.verified and data.attention_obj.dis <= 500 or data.is_suppressed and data.attention_obj.verified then
				local roll = math.random(1, 100)
				local chance_suppanic = 50
						
				if roll <= chance_suppanic then
					local nroll = math.random(1, 100)
					local chance_help = 50
					if roll <= chance_suppanic then
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed1" )
					else
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed2" )
					end
				else
					managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
				end
			else
				managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
			end
			
		end	
	end
end)

Hooks:PostHook(CopLogicAttack, "aim_allow_fire", "RR_aim_allow_fire", function(shoot, aim, data, my_data)
	local focus_enemy = data.attention_obj

	if shoot and not data.unit:in_slot(16) and not data.is_converted and data.char_tweak and data.char_tweak.chatter and data.char_tweak.chatter.aggressive then
		if not data.unit:base():has_tag("special") and data.unit:base():has_tag("law") and not data.unit:base()._tweak_table == "gensec" and not data.unit:base()._tweak_table == "security" then
			if focus_enemy.verified and focus_enemy.verified_dis <= 500 then
				if managers.groupai:state():chk_assault_active_atm() then
					local roll = math.random(1, 100)
				
					if roll < 33 then
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressivecontrolsurprised1")
					elseif roll < 66 and roll > 33 then
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressivecontrolsurprised2")
					else
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "open_fire")
					end
				else
					local roll = math.random(1, 100)
				
					if roll <= chance_heeeeelpp then
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressivecontrolsurprised1")
					else --hopefully some variety here now
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressivecontrolsurprised2")
					end	
				end
			else
				if managers.groupai:state():chk_assault_active_atm() then
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "open_fire")
				else
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressivecontrol")
				end
			end
		elseif data.unit:base():has_tag("special") then
			if not data.unit:base():has_tag("tank") and data.unit:base():has_tag("medic") then
				managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressive")
			elseif data.unit:base():has_tag("shield") then
				local shield_knock_cooldown = math.random(3, 6)
				if not my_data.shield_knock_cooldown or my_data.shield_knock_cooldown < data.t then
					local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)	
					my_data.shield_knock_cooldown = data.t + shield_knock_cooldown
					
					if diff_index < 8 then
						data.unit:sound():play("shield_identification", nil, true)
					else
						data.unit:sound():play("hos_shield_indication_sound_terminator_style", nil, true)
					end
				end
			else
				managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "contact")
			end
		else
			managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "contact")
		end
	end
end)

Hooks:PostHook(CopLogicAttack, "_upd_aim", "RR_upd_aim", function(data)
	local focus_enemy = data.attention_obj

	if focus_enemy and focus_enemy.is_person and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and not data.unit:in_slot(16) and not data.is_converted then
		if focus_enemy.is_local_player then
			local time_since_verify = data.attention_obj.verified_t and data.t - data.attention_obj.verified_t
			local e_movement_state = focus_enemy.unit:movement():current_state()
			
			if e_movement_state:_is_reloading() and time_since_verify and time_since_verify < 2 then
				if not data.unit:in_slot(16) and data.char_tweak.chatter.reload then
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "reload")
				end
			end
		else
			local e_anim_data = focus_enemy.unit:anim_data()
			local time_since_verify = data.attention_obj.verified_t and data.t - data.attention_obj.verified_t

			if e_anim_data.reload and time_since_verify and time_since_verify < 2 then
				if not data.unit:in_slot(16) and data.char_tweak.chatter.reload then
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "reload")
				end			
			end
		end
	end
end)

-- The big stuff, cops will comment on player equipment

CopLogicAttack._cop_comment_cooldown_t = {}

Hooks:PostHook(CopLogicAttack, "update", "RR_update", function(data)
	CopLogicAttack:inform_law_enforcements(data)	
end)

function CopLogicAttack:_game_t()
	return TimerManager:game():time()
end

function CopLogicAttack:start_inform_ene_cooldown(cooldown_t, msg_type)
	local t = self:_game_t()
	self._cop_comment_cooldown_t[msg_type] = self._cop_comment_cooldown_t[msg_type] or {}
	self._cop_comment_cooldown_t[msg_type]._cooldown_t = cooldown_t + t
	self._cooldown_delay_t = t + 5
end

function CopLogicAttack:ene_inform_has_cooldown_met(msg_type)
	local t = TimerManager:game():time()
	
	if not self._cop_comment_cooldown_t[msg_type] then
		return true
	end
	
	if self._cooldown_delay_t and self._cooldown_delay_t > t then
		return false
	end
	
	if self._cop_comment_cooldown_t[msg_type]._cooldown_t < t then
		return true
	end
	
	return false
end


function CopLogicAttack:_has_deployable_type(unit, deployable)
	local peer_id = managers.criminals:character_peer_id_by_unit(unit)
	if not peer_id then
		return false
	end

	local synced_deployable_equipment = managers.player:get_synced_deployable_equipment(peer_id)

	if synced_deployable_equipment then

		if not synced_deployable_equipment.deployable or synced_deployable_equipment.deployable ~= deployable then
			return false
		end

		--[[if synced_deployable_equipment.amount and synced_deployable_equipment.amount <= 0 then
			return false
		end]]--


		return true		
	end

	return false
end

function CopLogicAttack:_next_to_cops(data, amount)
	local close_peers = {}
	local range = 5000
	amount = amount or 4
	for u_key, u_data in pairs(managers.enemy:all_enemies()) do
		if data.key ~= u_key then
			if u_data.unit and alive(u_data.unit) and not u_data.unit:character_damage():dead() then
				local anim_data = u_data.unit:anim_data()
				if not anim_data.surrender and not anim_data.hands_tied and not anim_data.hands_back then
					if mvector3.distance_sq(data.m_pos, u_data.m_pos) < range * range then
						table.insert(close_peers, u_data.unit)
					end
				end
			end
		end
	end
	return #close_peers >= amount
end

function CopLogicAttack:inform_law_enforcements(data, debug_enemy)
	if managers.groupai:state()._special_unit_types[data.unit:base()._tweak_table] then
		return
	end
	if data.unit:in_slot(16) or not data.char_tweak.chatter then
		return
	end

	local sound_name, cooldown_t, msg_type
	local enemy_target = data.attention_obj

	if debug_enemy then
		enemy_target = {
			unit = debug_enemy,
			dis = 0,
			is_deployable = false
		}	
	end

	if enemy_target then
		if enemy_target.is_deployable then
			msg_type = "sentry_detected"
			sound_name = "ch2" -- Every voiceset except l5n (unused)
			cooldown_t = 30
		elseif enemy_target.unit:in_slot(managers.slot:get_mask("all_criminals")) then
			local weapon = enemy_target.unit.inventory and enemy_target.unit:inventory():equipped_unit()
			if weapon and weapon:base():is_category("saw") then
				msg_type = "saw_maniac"
				sound_name = "ch4" -- Every voiceset except l5n (unused)
				cooldown_t = 30
			elseif self:_has_deployable_type(enemy_target.unit, "doctor_bag") then
				msg_type = "doc_bag"
				sound_name = "med" -- Why do only l2n, l3n and l4n have this line :/
				cooldown_t = 30
			elseif self:_has_deployable_type(enemy_target.unit, "first_aid_kit") then
				msg_type = "first_aid_kit"
				sound_name = "med" -- Why do only l2n, l3n and l4n have this line :/
				cooldown_t = 30
			elseif self:_has_deployable_type(enemy_target.unit, "ammo_bag") then
				msg_type = "ammo_bag"
				sound_name = "amm" -- All lxn voicesets 
				cooldown_t = 30
			elseif self:_has_deployable_type(enemy_target.unit, "trip_mine") then
				msg_type = "trip_mine"
				sound_name = "ch1" -- Every voiceset except l5n (unused)
				cooldown_t = 30
			end
		end
	end

	if self:_next_to_cops(data) then
		return
	end

	if not enemy_target or enemy_target.dis > 100000 then
		return
	end
	
	if not msg_type or not self:ene_inform_has_cooldown_met(msg_type) then
		return
	end

	if data.unit then
		data.unit:sound():say(sound_name, true)
		self:start_inform_ene_cooldown(cooldown_t, msg_type)
	end
end
