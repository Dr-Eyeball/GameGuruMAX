-- LUA Script - precede every function and global member with lowercase name of script + '_main'
-- Hack v8 by Necrym59
-- DESCRIPTION: Will this will enable player to hack and activate a Logic Linked or ActivateIfUsed Entity?
-- DESCRIPTION: [USE_RANGE=80(1,100)]
-- DESCRIPTION: [USE_TEXT$="E to Hack"]
-- DESCRIPTION: [HACK_TIME=8(1,30)]
-- DESCRIPTION: [HACK_TEXT$="Working..."]
-- DESCRIPTION: [SUCCESS_TEXT$="Success.."]
-- DESCRIPTION: [FAILURE_TEXT$="Failed.."]
-- DESCRIPTION: [FAILURE_COUNT=3(1,20)]
-- DESCRIPTION: [@FAILURE_ALARM=1(1=Off, 2=On)]
-- DESCRIPTION: [ALARM_RESET=5(1,60)] Seconds
-- DESCRIPTION: [NOISE_RANGE=500(0,5000)]
-- DESCRIPTION: [@HACK_TRIGGER=1(1=Off, 2=On)]
-- DESCRIPTION: [HACKBAR_IMAGEFILE$="imagebank\\misc\\testimages\\search-bar.png"]
-- DESCRIPTION: [@@USER_GLOBAL_AFFECTED$=""(0=globallist)] User Global eg: "MyGlobal"
-- DESCRIPTION: [AFFECT_VALUE=1(1,100)] Value to add to User Global upon successful hack.
-- DESCRIPTION: [NO_FAILURES!=0] If set on will allow success only
-- DESCRIPTION: [@PROMPT_DISPLAY=1(1=Local,2=Screen)]
-- DESCRIPTION: [@ITEM_HIGHLIGHT=0(0=None,1=Shape,2=Outline,3=Icon)]
-- DESCRIPTION: [HIGHLIGHT_ICON_IMAGEFILE$="imagebank\\icons\\hand.png"]
-- DESCRIPTION: <Sound0> Hacking sound
-- DESCRIPTION: <Sound1> Success sound
-- DESCRIPTION: <Sound2> Failure sound
-- DESCRIPTION: <Sound3> Alarm sound

local module_misclib = require "scriptbank\\module_misclib"
local U = require "scriptbank\\utillib"
g_tEnt = {}

local hack 					= {}
local use_range 			= {}
local use_text 				= {}
local hack_time 			= {}
local hack_text 			= {}
local success_text 			= {}
local failure_text 			= {}
local failure_count			= {}
local failure_alarm			= {}
local alarm_reset			= {}
local noise_range			= {}
local hack_trigger			= {}
local hackbar_image			= {}
local user_global_affected 	= {}
local affect_value			= {}
local no_failures			= {}
local prompt_display		= {}
local item_highlight		= {}
local highlight_icon		= {}

local hackbar		= {}
local currentvalue	= {}
local htime 		= {}
local status 		= {}
local hl_icon		= {}
local hl_imgwidth	= {}
local hl_imgheight	= {}
local tEnt			= {}
local hackresult	= {}
local failcount		= {}
local alarm			= {}
local wait			= {}
local doonce		= {}
local playonce		= {}

function hack_properties(e, use_range, use_text, hack_time, hack_text, success_text, failure_text, failure_count, failure_alarm, alarm_reset, noise_range, hack_trigger, hackbar_image, user_global_affected, affect_value, no_failures, prompt_display, item_highlight, highlight_icon_imagefile)
	hack[e].use_range = use_range
	hack[e].use_text = use_text
	hack[e].hack_time = hack_time
	hack[e].hack_text = hack_text
	hack[e].success_text = success_text
	hack[e].failure_text = failure_text
	hack[e].failure_count = failure_count
	hack[e].failure_alarm = failure_alarm
	hack[e].alarm_reset = alarm_reset
	hack[e].noise_range = noise_range
	hack[e].hack_trigger = hack_trigger
	hack[e].hackbar_image = hackbar_image
	hack[e].user_global_affected = user_global_affected
	hack[e].affect_value = affect_value
	hack[e].no_failures = no_failures or 0
	hack[e].prompt_display = prompt_display
	hack[e].item_highlight = item_highlight
	hack[e].highlight_icon = highlight_icon_imagefile
end

function hack_init(e)
	hack[e] = {}
	hack[e].use_range = 80
	hack[e].use_text = "E to Hack"
	hack[e].hack_time = 8
	hack[e].hack_text = ""
	hack[e].success_text = ""
	hack[e].failure_text = ""
	hack[e].failure_count = 3
	hack[e].failure_alarm = 1
	hack[e].alarm_reset = 5
	hack[e].noise_range = 500
	hack[e].hack_trigger = 1
	hack[e].hackbar_image = "imagebank\\misc\\testimages\\search-bar.png"
	hack[e].user_global_affected = ""
	hack[e].affect_value = 1
	hack[e].no_failures = 0
	hack[e].prompt_display = 1
	hack[e].item_highlight = 0
	hack[e].highlight_icon = "imagebank\\icons\\hand.png"

	status[e] = "init"
	tEnt[e] = 0
	g_tEnt = 0	
	currentvalue[e] = 0
	wait[e] = math.huge
	alarm[e] = math.huge
	hackresult[e] = 0
	failcount[e] = 0
	doonce[e] = 0
	playonce[e] = 0
	hl_icon[e] = 0
	hl_imgwidth[e] = 0
	hl_imgheight[e] = 0	
end

function hack_main(e)

	local PlayerDist = GetPlayerDistance(e)

	if status[e] == "init" then
		if hack[e].hackbar_image ~= "" then
			hackbar[e] = CreateSprite(LoadImage(hack[e].hackbar_image))
			SetSpriteSize(hackbar[e],5,-1)
			SetSpritePosition(hackbar[e],200,200)
		end	
		if hack[e].item_highlight == 3 and hack[e].highlight_icon ~= "" then
			hl_icon[e] = CreateSprite(LoadImage(hack[e].highlight_icon))
			hl_imgwidth[e] = GetImageWidth(LoadImage(hack[e].highlight_icon))
			hl_imgheight[e] = GetImageHeight(LoadImage(hack[e].highlight_icon))
			SetSpriteSize(hl_icon[e],-1,-1)
			SetSpriteDepth(hl_icon[e],100)
			SetSpriteOffset(hl_icon[e],hl_imgwidth[e]/2.0, hl_imgheight[e]/2.0)
			SetSpritePosition(hl_icon[e],500,500)
		end	
		status[e] = "hackinit"
	end
	
	if status[e] == "hackinit" then
		htime[e] = hack[e].hack_time * 5
		doonce[e] = 0
		playonce[e] = 0
		g_hackresult = 0
		status[e] = "hacking"
	end	

	if PlayerDist < hack[e].use_range then
		if status[e] ~= "finish" then
			--pinpoint select object--
			module_misclib.pinpoint(e,hack[e].use_range,hack[e].item_highlight,hl_icon[e])
			tEnt[e] = g_tEnt
			--end pinpoint select object--
		end			
		if PlayerDist < hack[e].use_range and tEnt[e] == e and GetEntityVisibility(e) == 1 then
			if status[e] == "hacking" then  --Hacking
				if hack[e].prompt_display == 1 then PromptLocal(e,hack[e].use_text) end
				if hack[e].prompt_display == 2 then Prompt(hack[e].use_text) end			
				if g_KeyPressE == 1 then
					if hack[e].prompt_display == 1 then PromptLocal(e,"") end
					if hack[e].prompt_display == 2 then Prompt("") end
					if htime[e] > 0 then
						if playonce[e] == 0 then
							LoopSound(e,0)
							playonce[e] = 1
						end
						if hack[e].prompt_display == 1 then PromptLocal(e,hack[e].hack_text) end
						if hack[e].prompt_display == 2 then Prompt(hack[e].hack_text) end
						PasteSpritePosition(hackbar[e],50-(htime[e]/16),95)
						SetSpriteSize(hackbar[e],htime[e]/8,1)
						htime[e] = htime[e]-0.1
						if htime[e] < 0 then htime[e] = 0 end
					end
					if hack[e].noise_range > 0 then MakeAISound(g_PlayerPosX,g_PlayerPosY,g_PlayerPosZ,hack[e].noise_range,1,e) end
					if hack[e].no_failures == 0 then hackresult[e] = math.random(1,2) end
					if hack[e].no_failures == 1 then hackresult[e] = 1 end
					if htime[e] == 0 then
						if hackresult[e] == 1 then -- Success
							SetAnimationName(e,"on")
							PlayAnimation(e)
							wait[e] = g_Time + 1000
							status[e] = "success"
						end
						if hackresult[e] == 2 then -- Failure
							SetAnimationName(e,"off")
							PlayAnimation(e)
							wait[e] = g_Time + 1000
							failcount[e] = failcount[e] + 1
							status[e] = "failure"
						end
					end
				end
				if g_KeyPressE == 0 then StopSound(e,0) end
			end
		end
		-----------------------------------------------------------------------
		if status[e] == "success" then
			if hack[e].prompt_display == 1 then PromptLocal(e,hack[e].success_text) end
			if hack[e].prompt_display == 2 then Prompt(hack[e].success_text) end
			if doonce[e] == 0 then
				StopSound(e,0)
				PlaySound(e,1)
				if hack[e].user_global_affected > "" then
					if _G["g_UserGlobal['"..hack[e].user_global_affected.."']"] ~= nil then currentvalue[e] = _G["g_UserGlobal['"..hack[e].user_global_affected.."']"] end
					_G["g_UserGlobal['"..hack[e].user_global_affected.."']"] = currentvalue[e] + hack[e].affect_value
				end
				doonce[e] = 1
			end			
			if g_Time > wait[e] then status[e] = "hacked" end
		end
		if status[e] == "failure" then
			if hack[e].prompt_display == 1 then PromptLocal(e,hack[e].failure_text) end
			if hack[e].prompt_display == 2 then Prompt(hack[e].failure_text) end		
			if hack[e].failure_alarm == 1 then
				if doonce[e] == 0 then
					StopSound(e,0)
					PlaySound(e,2)
					doonce[e] = 1
				end
				if g_Time > wait[e] then status[e] = "hackinit" end
			end
			if hack[e].failure_alarm == 2 and failcount[e] == hack[e].failure_count then
				if doonce[e] == 0 then
					StopSound(e,0)
					LoopSound(e,3)
					doonce[e] = 1
					alarm[e] = g_Time + (hack[e].alarm_reset*1000)
				end
				MakeAISound(g_Entity[e]['x'],g_Entity[e]['y'],g_Entity[e]['z'],2000,1,e)
			end
		end
		if status[e] == "hacked" then  --Finished
			if hack[e].hack_trigger == 2 then
				ActivateIfUsed(e)
				PerformLogicConnections(e)
				status[e] = "finish"
			end
			SwitchScript(e,"no_behavior_selected.lua")
			SetActivated(e,0)
		end
	end
	if g_Time > alarm[e] and failcount[e] == hack[e].failure_count then -- Alarm reset
		StopSound(e,3)
		failcount[e] = 0
		status[e] = "hackinit"
	end
end