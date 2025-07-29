-- LUA Script - precede every function and global member with lowercase name of script + '_main'
-- PARTICLE_TOGGLER v1 by Necrym59
-- DESCRIPTION: When this entity is triggered it will activate and toggle a named particle on or off
-- DESCRIPTION: Attach to an object and logic link from a switch or zone to activate.
-- DESCRIPTION: [PARTICLE_NAME$=""] particle name

local lower = string.lower
local particle_toggler		= {}
local particle_name			= {}
local particle_no			= {}
local status				= {}
	
function particle_toggler_properties(e, particle_name)
	particle_toggler[e].particle_name = string.lower(particle_name)
end
 
function particle_toggler_init(e)
	particle_toggler[e] = {}
	particle_toggler[e].particle_name = ""
	particle_toggler[e].particle_no = 0
	
	status[e] = "init"
end
 
function particle_toggler_main(e)	
	
	if status[e] == "init" then
		if particle_toggler[e].particle_name ~= "" then
			for p = 1, g_EntityElementMax do
				if p ~= nil and g_Entity[p] ~= nil then
					if string.lower(GetEntityName(p)) == particle_toggler[e].particle_name then
						particle_toggler[e].particle_no = p
					end
				end
			end
		end
		Hide(particle_toggler[e].particle_no)
		status[e] = "Off"
	end
	
	if g_Entity[e]['activated'] == 1 and status[e] == "Off" then	
		SetActivated(particle_toggler[e].particle_no,1)
		Show(particle_toggler[e].particle_no)
		status[e] = "On"
		SetActivated(e,0)
	end
	if g_Entity[e]['activated'] == 1 and status[e] == "On" then
		Hide(particle_toggler[e].particle_no)
		status[e] = "Off"
		SetActivated(e,0)
	end
end