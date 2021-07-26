local math_random = math.random
local radio_prefix = {
	['l1d_'] = true,
	['l2d_'] = true,
	['l3d_'] = true,
	['l4d_'] = true,
	['l5d_'] = true
}

local killdapowa = {
	['e_so_pull_lever'] = true,
	['e_so_pull_lever_var2'] = true
}

Hooks:PostHook(CopLogicTravel, "queue_update", "RR_queue_update", function(data, my_data)
	local objective = data.objective
	local hostage_count = managers.groupai:state():get_hostage_count_for_chatter() --check current hostage count
	local chosen_panic_chatter = "controlpanic" --set default generic assault break chatter
	local radio_voice = radio_prefix[data.unit:sound():chk_voice_prefix()]
	
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

	local level = Global.level_data and Global.level_data.level_id	
	local chosen_sabotage_chatter = "sabotagegeneric" --set default sabotage chatter for variety's sake
	local skirmish_map = managers.skirmish:is_skirmish()--these shouldnt play on holdout
	local ignore_radio_rules = nil

	if objective then
		if objective.action and killdapowa[objective.action.variant] then
			chosen_sabotage_chatter = "sabotagepower"
		elseif objective.bagjob or objective.grp_objective and objective.grp_objective.bagjob then
			chosen_sabotage_chatter = "sabotagebags"
			ignore_radio_rules = true
		elseif objective.hostagejob or objective.grp_objective and objective.grp_objective.hostagejob then
			chosen_sabotage_chatter = "sabotagehostages"
			ignore_radio_rules = true
		elseif objective.drilljob then
			chosen_sabotage_chatter = "sabotagedrill"
		end
	end
	
	if data.tactics and math_random() < 0.25 then
		ignore_radio_rules = true 
		ignore_skirmish_rules = true
		if data.tactics.flank then
			chosen_sabotage_chatter = "look_for_angle"
		elseif data.tactics.charge then
			if math_random() < 0.5 then
				chosen_sabotage_chatter = "go_go"
			else
				chosen_sabotage_chatter = "push"
			end
		end
	end
		
	local clear_t_chk = not data.attention_obj or not data.attention_obj.verified_t or data.attention_obj.verified_t - data.t > math_random(2.5, 5)		
	local cant_say_clear = not data.attention_obj or AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and clear_t_chk
		
	if not data.unit:base():has_tag("special") and not cant_say_clear and not data.is_converted then
		if data.unit:movement():cool() and data.char_tweak.chatter and data.char_tweak.chatter.clear_whisper then  
			local roll = math.rand(1, 100)
			local whistle_chance = 50
			if roll <= whistle_chance then
				managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear_whisper_2" )
				--log("whistle")
			else
				managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear_whisper" )
				--log("reporting")
			end
		elseif not data.unit:movement():cool() then
			if not managers.groupai:state():chk_assault_active_atm() then
				if data.char_tweak.chatter and data.char_tweak.chatter.controlpanic then
					local clearchk = math_random(0, 90)
					local say_clear = 30
					if clearchk > 60 then
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear" )
					elseif clearchk > 30 then
						if not skirmish_map and radio_voice or not skirmish_map and ignore_radio_rules then
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
			end
		end
	end
	
	if (data.unit:base():has_tag("tank") or data.unit:base():has_tag("taser")) and not cant_say_clear then
		managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "approachingspecial" )
	end
		
	--mid-assault panic for cops based on alerts instead of opening fire, since its supposed to be generic action lines instead of for opening fire and such
	--I'm adding some randomness to these since the delays in groupaitweakdata went a bit overboard but also arent able to really discern things proper
				
	if data.char_tweak and data.char_tweak.chatter and data.char_tweak.chatter.enemyidlepanic and not data.is_converted then
		if not data.unit:base():has_tag("special") and data.unit:base():has_tag("law") then
			if managers.groupai:state():chk_assault_active_atm() then
				if managers.groupai:state():_check_assault_panic_chatter() then
					if data.attention_obj and data.attention_obj.verified and data.attention_obj.dis <= 500 or data.is_suppressed and data.attention_obj and data.attention_obj.verified then
						local roll = math_random(1, 100)
						local chance_suppanic = 50
						
						if roll <= chance_suppanic then
							local nroll = math_random(1, 100)
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
						if math_random() < 0.2 then
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
						else
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
						end
					end
				else
					local clearchk = math_random(0, 90)
						
					if clearchk > 60 then
						if not skirmish_map and radio_voice or not skirmish_map and ignore_radio_rules then
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
						end
					elseif chosen_panic_chatter == "civilianpanic" then
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_panic_chatter )
					end
				end
			end
		elseif not data.unit:base():has_tag("special") and data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.verified_t or not data.unit:base():has_tag("special") and data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.alert_t then
		
			if data.attention_obj.verified and data.attention_obj.dis <= 500 or data.is_suppressed and data.attention_obj.verified then
				local roll = math_random(1, 100)
				local chance_suppanic = 50
						
				if roll <= chance_suppanic then
					local nroll = math_random(1, 100)
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