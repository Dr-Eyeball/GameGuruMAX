-- LUA Script - precede every function and global member with lowercase name of script + '_main'
-- Object Monitor v14 by Necrym59
-- DESCRIPTION: A behavior that allows a named object's health to be monitored and trigger event(s), Lose/Win Game, Change Level or Destroy a named entity upon reaching zero health.
-- DESCRIPTION: Attach to an object set AlwaysActive=ON, and attach any logic links to this object and/or use ActivateIfUsed field.
-- DESCRIPTION: [OBJECT_NAME$=""] to monitor
-- DESCRIPTION: [@DESTROYED_ACTION=1(1=Event Triggers, 2=Lose Game, 3=Win Game, 4=Go To Level, 5=Add to User Global, 6=Destroy Named Entity)]
-- DESCRIPTION: [ENTITY_NAME$=""] to destroy
-- DESCRIPTION: [@DISPLAY_HEALTH=2(1=Yes, 2=No)] to display health on monitored object
-- DESCRIPTION: [@MONITOR_ACTIVE=1(1=Yes, 2=No)] if No then use a zone or switch to activate this monitor.
-- DESCRIPTION: [ACTION_DELAY=2(0,100)] seconds delay before activating destroyed_action.
-- DESCRIPTION: [@@USER_GLOBAL$=""(0=globallist)] user global to apply value (eg: MyGlobal).
-- DESCRIPTION: [USER_GLOBAL_VALUE=100(1,100)] value to apply.
-- DESCRIPTION: [@GoToLevelMode=1(1=Use Storyboard Logic,2=Go to Specific Level)] controls whether the next level in the Storyboard, or another level is loaded.
-- DESCRIPTION: [ResetStates!=0] when entering the new level

local lower = string.lower

local object_monitor 	= {}
local object_name		= {}
local destroyed_action	= {}
local entity_name		= {}
local display_health	= {}
local monitor_active	= {}
local action_delay		= {}
local user_global 		= {}
local user_global_value	= {}
local resetstates		= {}

local pEntn				= {}
local dEntn				= {}
local checks			= {}
local status			= {}
local wait				= {}
local actiondelay		= {}
local checktime			= {}
local currentvalue		= {}

function object_monitor_properties(e, object_name, destroyed_action, entity_name, display_health, monitor_active, action_delay, user_global, user_global_value, resetstates)
	object_monitor[e].object_name = lower(object_name) or ""
	object_monitor[e].destroyed_action = destroyed_action
	object_monitor[e].entity_name = lower(entity_name) or ""
	object_monitor[e].display_health = display_health
	object_monitor[e].monitor_active = monitor_active or 1
	object_monitor[e].action_delay = action_delay or 0	
	object_monitor[e].user_global = user_global
	object_monitor[e].user_global_value = user_global_value
	object_monitor[e].resetstates = resetstates
end

function object_monitor_init(e)
	object_monitor[e] = {}
	object_monitor[e].object_name = ""
	object_monitor[e].destroyed_action = 1
	object_monitor[e].entity_name = ""	
	object_monitor[e].display_health = 2
	object_monitor[e].monitor_active = 1
	object_monitor[e].action_delay = 3		
	object_monitor[e].user_global = ""
	object_monitor[e].user_global_value = 100
	object_monitor[e].resetstates = 0
	
	wait[e] = math.huge
	actiondelay[e] = math.huge
	checktime[e] = 0
	currentvalue[e] = 0
	pEntn[e] = 0
	dEntn[e] = 0
	checks[e] = 0
	status[e] = "init"	
end

function object_monitor_main(e)

	if status[e] == "init" then
		checktime[e] = g_Time + 500		
		if object_monitor[e].monitor_active == 1 then SetEntityActivated(e,1) end
		if object_monitor[e].monitor_active == 2 then SetEntityActivated(e,0) end		

		if pEntn[e] == 0 then
			for n = 1, g_EntityElementMax do
				if n ~= nil and g_Entity[n] ~= nil then
					if lower(GetEntityName(n)) == object_monitor[e].object_name then 
						pEntn[e] = n						
						break
					end
				end
			end
		end
		if dEntn[e] == 0 then
			for m = 1, g_EntityElementMax do
				if m ~= nil and g_Entity[m] ~= nil then
					if lower(GetEntityName(m)) == object_monitor[e].entity_name then 
						dEntn[e] = m
						break
					end
				end
			end
		end
		status[e] = "monitor"
	end			

	if g_Entity[e]['activated'] == 1 then

		if status[e] == "monitor" and g_Time > checktime[e] then
			if g_Entity[pEntn[e]].health <= 0 and object_monitor[e].destroyed_action == 1 then
				wait[e] = g_Time + (object_monitor[e].action_delay*1000)				
				if object_monitor[e].user_global > "" then
					_G["g_UserGlobal['"..object_monitor[e].user_global.."']"] = object_monitor[e].user_global_value
				end
				status[e] = "alarm"
			end
			if g_Entity[pEntn[e]].health <= 0 and object_monitor[e].destroyed_action == 2 then
				wait[e] = g_Time + (object_monitor[e].action_delay*1000)
				status[e] = "winorlose"
			end
			if g_Entity[pEntn[e]].health <= 0 and object_monitor[e].destroyed_action == 3 then			
				wait[e] = g_Time + (object_monitor[e].action_delay*1000)
				if object_monitor[e].user_global > "" then
					_G["g_UserGlobal['"..object_monitor[e].user_global.."']"] = object_monitor[e].user_global_value
				end
				status[e] = "winorlose"
			end
			if g_Entity[pEntn[e]].health <= 0 and object_monitor[e].destroyed_action == 4 then			
				wait[e] = g_Time + (object_monitor[e].action_delay*1000)
				if object_monitor[e].user_global > "" then
					_G["g_UserGlobal['"..object_monitor[e].user_global.."']"] = object_monitor[e].user_global_value
				end
				status[e] = "winorlose"
			end
			if g_Entity[pEntn[e]].health <= 0 and object_monitor[e].destroyed_action == 5 then			
				if _G["g_UserGlobal['"..object_monitor[e].user_global.."']"] ~= nil then
					currentvalue[e] = _G["g_UserGlobal['"..object_monitor[e].user_global.."']"]
					_G["g_UserGlobal['"..object_monitor[e].user_global.."']"] = currentvalue[e] + object_monitor[e].user_global_value
				end
				status[e] = "end"
				SwitchScript(e,"no_behavior_selected.lua")
			end
			if g_Entity[pEntn[e]].health <= 0 and object_monitor[e].destroyed_action == 6 then			
				wait[e] = g_Time + (object_monitor[e].action_delay*1000)
				if object_monitor[e].user_global > "" then
					_G["g_UserGlobal['"..object_monitor[e].user_global.."']"] = object_monitor[e].user_global_value
				end
				status[e] = "destroy"
			end			
			if object_monitor[e].display_health == 1 then
				PromptLocal(pEntn[e],"Health: " ..g_Entity[pEntn[e]].health)
			end
			checktime[e] = g_Time + 500
		end

		if status[e] == "alarm" then			
			if g_Time < wait[e] then MakeAISound(g_PlayerPosX,g_PlayerPosY,g_PlayerPosZ,3000,1,-1) end
			if g_Time > wait[e] then
				ActivateIfUsed(e)
				PerformLogicConnections(e)
				status[e] = "end"
				SwitchScript(e,"no_behavior_selected.lua")				
			end
		end
		
		if status[e] == "winorlose" then
			if g_Time > wait[e] then
				if object_monitor[e].destroyed_action == 2 then LoseGame() end
				if object_monitor[e].destroyed_action == 3 then WinGame() end
				if object_monitor[e].destroyed_action == 4 then
					JumpToLevelIfUsedEx(e,object_monitor[e].resetstates)
				end
				status[e] = "end"
			end
		end
		
		if status[e] == "destroy" then			
			if g_Time > wait[e] then
				Destroy(dEntn[e])
				status[e] = "end"
				SwitchScript(e,"no_behavior_selected.lua")				
			end
		end
	end
end