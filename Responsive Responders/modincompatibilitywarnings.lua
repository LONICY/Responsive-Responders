Hooks:Add("MenuManagerOnOpenMenu", "RR_MenuManagerOnOpenMenu", function(menu_manager, nodes)
	if BLT.Mods:GetModByName("Payday 2 Hyper Heisting Shin Shootout") or BLT.Mods:GetModByName("RestorationMod") or BLT.Mods:GetModByName("Crackdown") then
		QuickMenu:new("Overhaul Found", "You are using an overhaul (Crackdown, Hyper Heisting or Restoration Mod) Which already have Responsive Responders included. Using Responsive Responders with them can cause crashes and other issues. It is strongly recommended to remove Responsive Responders", {
			[1] = {
				text = "OK",
				is_cancel_button = true
			}
		}):show()
	end
end)