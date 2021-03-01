Hooks:PostHook(CopLogicBase, "_set_attention_obj", "RR_set_attention_obj", function(data, new_att_obj, new_reaction)
	if new_att_obj and AIAttentionObject.REACT_SHOOT <= new_reaction and new_att_obj.verified and contact_chatter_time_ok and (data.unit:anim_data().idle or data.unit:anim_data().move) and new_att_obj.is_person and data.char_tweak.chatter.contact then	
		if data.unit:base()._tweak_table == "gensec" then
			data.unit:sound():say("a01", true)			
		elseif data.unit:base()._tweak_table == "security" then
			data.unit:sound():say("a01", true)								
		else
			data.unit:sound():say("c01", true)
		end
	end
end)