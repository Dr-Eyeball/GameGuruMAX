-- LUA Script - precede every function and global member with lowercase name of script + '_main'
-- Variable Light v4
-- DESCRIPTION: A light for use with a variable switch. Attach to a light.
-- DESCRIPTION: Enter the name of the [@@VARIABLE_SWITCH_USER_GLOBAL$=""(0=globallist)]  User Global used to monitor (eg; Variable_Switch1)

-- N.B.: This behavior script depends on the global variable 'g_vswitchvalue'.

module_lightcontrol = require "scriptbank\\markers\\module_lightcontrol"
local rad = math.rad

local varlight 						= {}
local variable_switch_user_global	= {}

local status 						= {}
local current_level					= {}
local currentvalue					= {}
local lightNum = 0

function variable_light_properties(e,variable_switch_user_global)	
	module_lightcontrol.init(e,1)
	varlight[e].variable_switch_user_global = variable_switch_user_global
end

function variable_light_init(e)
	varlight[e] = {}
	varlight[e].variable_switch_user_global = ""
	
	lightNum = GetEntityLightNumber(e)
	SetActivated(e,1)
	currentvalue[e] = 0
	status[e] = "init"
end
	
function variable_light_main(e)	

	if status[e] == "init" then
		status[e] = "endinit"
	end
	
	-- FIXME: Undefined global `g_vswitchvalue`. Undocumented. Valid?
	current_level[e] = g_vswitchvalue
	
	if g_Entity[e]['activated'] == 1 then		
		lightNum = GetEntityLightNumber(e)
		if varlight[e].variable_switch_user_global ~= "" then
			-- FIXME: The logic here does not look correct. Same value used for: currentvalue[] & current_level[].
			if _G["g_UserGlobal['"..varlight[e].variable_switch_user_global.."']"] ~= nil then 
				-- FIXME: 'currentvalue[]' is never used.
				currentvalue[e] = _G["g_UserGlobal['"..varlight[e].variable_switch_user_global.."']"] 
			end
			current_level[e] = _G["g_UserGlobal['"..varlight[e].variable_switch_user_global.."']"]
		end
		SetLightRange(lightNum,current_level[e])
	end
end