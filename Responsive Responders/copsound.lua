function CopSound:init(unit)
	self._unit = unit
	self._speak_expire_t = 0

	self:set_voice_prefix(nil)

	if self._unit:base():char_tweak().spawn_sound_event then
		self._unit:sound():play(self._unit:base():char_tweak().spawn_sound_event, nil, nil)
	end

	--Mostly just here in the event we have a unit to have both an 'entrance' line *and* a global spawn in noise
	if self._unit:base():char_tweak().spawn_sound_event_2 then
		self._unit:sound():play(self._unit:base():char_tweak().spawn_sound_event_2, nil, nil)
	end

	unit:base():post_init()
end

function CopSound:chk_voice_prefix()
	return self._prefix
end

function CopSound:say(sound_name, sync, skip_prefix, important, callback)
	if self._last_speech then
		self._last_speech:stop()
	end

	local full_sound = nil
	if self._prefix == "l5d_" then
		if sound_name == "c01" or sound_name == "att" then
			sound_name = "g90"
		elseif sound_name == "rrl" then
			sound_name = "pus"
		elseif sound_name == "t01" then
			sound_name = "prm"
		elseif sound_name == "h01" then
			sound_name = "h10"
		end
	elseif self._prefix == "l1n_" or self._prefix == "l2n_" or self._prefix == "l3n_" then
		if sound_name == "x02a_any_3p" then
			sound_name = "x01a_any_3p"
		elseif sound_name == "x01a_any_3p" then
			sound_name = "x02a_any_3p"
		end
	elseif self._prefix == "l4n_" then
		if sound_name == "x02a_any_3p" then
			sound_name = "x01a_any_3p"
		elseif sound_name == "x01a_any_3p" then
			sound_name = "l1n_x02a_any_3p"
		end
	end

	if self._prefix == "l1d_" or self._prefix == "l2d_" or self._prefix == "l3d_" or self._prefix == "l4d_" or self._prefix == "l5d_" then
		if sound_name == "a05" or sound_name == "a06" then
			sound_name = "clr"
		end
	end

	local faction = tweak_data.levels:get_ai_group_type()
	if self._unit:base():has_tag("special") then
		if sound_name == "x02a_any_3p" then
			if self._unit:base():has_tag("spooc") then
				if faction == "russia" then
					full_sound = "rclk_x02a_any_3p"
				else
					full_sound = "clk_x02a_any_3p"
				end
			elseif self._unit:base():has_tag("taser") then
				if faction == "russia" then
					full_sound = "rtsr_x02a_any_3p"
				else
					full_sound = "tsr_x02a_any_3p"
				end
			elseif self._unit:base():has_tag("tank") then
				full_sound = "bdz_x02a_any_3p"
			elseif self._unit:base():has_tag("medic") then
				full_sound = "mdc_x02a_any_3p"
			end
		elseif sound_name == "x01a_any_3p" then
			if self._unit:base():has_tag("spooc") then
				if faction == "russia" then
					full_sound = "rclk_x01a_any_3p" --weird he has hurt noises but the regular cloaker doesnt
				else
					full_sound = full_sound
				end
			elseif self._unit:base():has_tag("taser") then
				if faction == "russia" then
					full_sound = "rtsr_x01a_any_3p"
				else
					full_sound = "tsr_x01a_any_3p"
				end
			elseif self._unit:base():has_tag("tank") then
				full_sound = "bdz_x01a_any_3p"
			elseif self._unit:base():has_tag("medic") then
				full_sound = "mdc_x01a_any_3p"
			end
		end
	end

	if self._prefix == "l2d_" then
		if sound_name == "x02a_any_3p" then
			full_sound = "l1d_x02a_any_3p"
		end
	elseif self._prefix == "l3d_" then
		if sound_name == "burnhurt" then
			full_sound = "l1d_burnhurt"
		end
		if sound_name == "burndeath" then
			full_sound = "l1d_burndeath"
		end
	elseif self._prefix == "z1n_" or self._prefix == "z2n_" or self._prefix == "z3n_" or self._prefix == "z4n_" then
		if sound_name == "x02a_any_3p" then
			full_sound = "l2n_x01a_any_3p"
		end

		if sound_name == "x01a_any_3p" then
			full_sound = "l2n_x02a_any_3p"
		end

		if sound_name ~= "x01a_any_3p" and sound_name ~= "x02a_any_3p" then
			sound_name = "g90"
		end
	elseif self._prefix == "f1n_" then
		if sound_name == "x02a_any_3p" then
			full_sound = "f1n_x01a_any_3p_01"
		end
	elseif self._prefix == "r1n_" or self._prefix == "r2n_" or self._prefix == "r3n_" or self._prefix == "r4n_" then
		if sound_name == "x02a_any_3p" then
			full_sound = "l2n_x01a_any_3p"
		elseif sound_name == "x01a_any_3p" then
			full_sound = "l2n_x02a_any_3p"
		end
	end

	if not full_sound then
		if skip_prefix then
			full_sound = sound_name
		else
			full_sound = self._prefix .. sound_name
		end
	end

	local event_id = nil

	if type(full_sound) == "number" then
		event_id = full_sound
		full_sound = nil
	end

	if sync then
		event_id = event_id or SoundDevice:string_to_id(full_sound)

		self._unit:network():send("say", event_id)
	end

	self._last_speech = self:_play(full_sound or event_id)

	if not self._last_speech then
		return
	end

	self._speak_expire_t = TimerManager:game():time() + 2
end