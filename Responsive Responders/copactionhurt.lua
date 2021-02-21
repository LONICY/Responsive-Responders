local init_orig = CopActionHurt.init
function CopActionHurt:init(action_desc, common_data, ...)
	init_orig(self, action_desc, common_data, ...)

	local tweak_table = self._unit:base()._tweak_table
	local action_type = action_desc.hurt_type

	if not self._unit:base().nick_name then
		if action_desc.variant == "fire" then
			if tweak_table ~= "tank" and tweak_table ~= "tank_hw" and tweak_table ~= "shield" then
				if action_desc.hurt_type == "fire_hurt" and tweak_table ~= "spooc" then
					self._unit:sound():say("burnhurt")
				elseif action_desc.hurt_type == "death" then
					self._unit:sound():say("burndeath")
				end
			end	
		elseif action_type == "death" then
			self._unit:sound():say("x02a_any_3p", true)								
		elseif action_type == "counter_tased" or action_type == "taser_tased" then
			if self._unit:base():has_tag("taser") then
				self._unit:sound():say("tasered", true)		
			else
				self._unit:sound():say("x01a_any_3p", true) --so that other tased enemies actually react in pain to being tased
			end
		elseif action_type == "hurt_sick" then
			local common_cop = self._unit:base():has_tag("law") and not self._unit:base():has_tag("special")
	  
			if common_cop or self._unit:base():has_tag("shield") then
				self._unit:sound():say("ch3", true) --make cops scream in pain when affected ECM feedback
			elseif self._unit:base():has_tag("medic")then
				self._unit:sound():say("burndeath", true) --same for the medic with a similar sound, since they lack one
			elseif self._unit:base():has_tag("taser") then
				self._unit:sound():say("tasered", true) --same as his tased lines felt they fit best		
			end
		else
			self._unit:sound():say("x01a_any_3p", true)
		end
	end
	
	return true
end