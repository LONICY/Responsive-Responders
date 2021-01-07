Hooks:Add("MenuManagerOnOpenMenu", "RR_MenuManagerOnOpenMenu", function(menu_manager, nodes)
	local overhaul_found = false
	local hyperheisting = BLT.Mods:GetModByName("Payday 2 Hyper Heisting Shin Shootout")
	local restoration = BLT.Mods:GetModByName("RestorationMod")
	local crackdown = BLT.Mods:GetModByName("Crackdown")

	if hyperheisting and hyperheisting:IsEnabled() or restoration and restoration:IsEnabled() or crackdown and crackdown:IsEnabled() then
		overhaul_found = true
	end

	if overhaul_found then
		QuickMenu:new("Overhaul Found", "You are using an overhaul (Crackdown, Hyper Heisting or Restoration Mod) Which already have Responsive Responders included. Using Responsive Responders with them can cause crashes and other issues. It is strongly recommended to remove Responsive Responders", {
			[1] = {
				text = "OK",
				is_cancel_button = true
			}
		}):show()
	end
end)