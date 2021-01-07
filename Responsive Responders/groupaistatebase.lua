function GroupAIStateBase:_check_assault_panic_chatter()
	if self._t and self._last_killed_cop_t and self._t - self._last_killed_cop_t < math.random(0.15, 1.2) then
		return true
	end
	
	return
end

local old_init = GroupAIStateBase._process_recurring_grp_SO
function GroupAIStateBase:_process_recurring_grp_SO(...)
	if old_init(self, ...) then
		managers.hud:post_event("cloaker_spawn")
		return true
	end
end