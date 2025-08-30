-- Sit v11 by Necrym59
-- DESCRIPTION: The attached object will allow the player to sit down
-- DESCRIPTION: [USE_PROMPT$="Press E to sit/stand"]
-- DESCRIPTION: [USE_RANGE=90(1,300)]
-- DESCRIPTION: [@USE_STYLE=2(1=Ranged, 2=Accurate)]
-- DESCRIPTION: [#SEATED_X_POSITION=0(-100,100)]
-- DESCRIPTION: [#SEATED_Y_POSITION=40(-100,100)]
-- DESCRIPTION: [#SEATED_Z_POSITION=0(-100,100)]
-- DESCRIPTION: [#STAND_ADJUSTMENT=50(0,200)]
-- DESCRIPTION: [#SEATING_SPEED=5.0(0.0,50.0)]
-- DESCRIPTION: [HORIZONTAL_VIEW_LIMIT=90(1,180)] the horizontal view limit while seated
-- DESCRIPTION: [VERTICAL_VIEW_LIMIT=50(1,90)] the vertical view limit while seated
-- DESCRIPTION: [@TRIGGER_EXT_LINKS=0(0=None,1=When Sitting Down,2=When Standing Up)]
-- DESCRIPTION: [#SEATED_ANGLE_ADJUST=0(-180,180)]
-- DESCRIPTION: [@PROMPT_DISPLAY=1(1=Local,2=Screen)]
-- DESCRIPTION: [@ITEM_HIGHLIGHT=0(0=None,1=Shape,2=Outline,3=Icon)]
-- DESCRIPTION: [HIGHLIGHT_ICON_IMAGEFILE$="imagebank\\icons\\hand.png"]
-- DESCRIPTION: <Sound0> when sitting down.

local module_misclib = require "scriptbank\\module_misclib"
local U = require "scriptbank\\utillib"
g_tEnt = {}

local sit 					= {}
local use_prompt 			= {}
local use_range 			= {}
local seated_x_position		= {}
local seated_y_position		= {}
local seated_z_position		= {}
local stand_adjustment		= {}
local seating_speed			= {}
local horizontal_view_limit	= {}
local vertical_view_limit	= {}
local trigger_ext_links		= {}
local seated_angle_adjust 	= {}
local prompt_display		= {}
local item_highlight		= {}
local highlight_icon		= {}

local seat_posx	 			= {}
local seat_posy	 			= {}
local seat_posz	 			= {}
local seat_angx	 			= {}
local seat_angy	 			= {}
local seat_angz	 			= {}
local sittime 				= {}
local sitmove				= {}
local status				= {}
local hl_icon				= {}
local hl_imgwidth			= {}
local hl_imgheight			= {}
local keypause				= {}
local sitstate				= {}
local wait					= {}
local last_gun				= {}
local selectobj				= {}
local tEnt					= {}
local done					= {}
local freezeangy			= {}

function sit_properties(e, use_prompt, use_range, use_style, seated_x_position, seated_y_position, seated_z_position, stand_adjustment, seating_speed, horizontal_view_limit, vertical_view_limit, trigger_ext_links, seated_angle_adjust, prompt_display, item_highlight, highlight_icon_imagefile)
	sit[e].use_prompt = use_prompt
	sit[e].use_range = use_range
	sit[e].use_style = use_style	
	sit[e].seated_x_position = seated_x_position	
	sit[e].seated_y_position = seated_y_position
	sit[e].seated_z_position = seated_z_position	
	sit[e].stand_adjustment = stand_adjustment
	sit[e].seating_speed = seating_speed
	sit[e].horizontal_view_limit = horizontal_view_limit
	sit[e].vertical_view_limit = vertical_view_limit
	sit[e].trigger_ext_links = trigger_ext_links
	sit[e].seated_angle_adjust = seated_angle_adjust	
	sit[e].prompt_display = prompt_display
	sit[e].item_highlight =	item_highlight
	sit[e].highlight_icon = highlight_icon_imagefile	
end

function sit_init(e)
	sit[e] = {}
	sit[e].use_prompt = "Press E to sit/stand"
	sit[e].use_range = 90
	sit[e].use_style = 2	
	sit[e].seated_x_position = 0
	sit[e].seated_y_position = 20
	sit[e].seated_z_position = 10
	sit[e].stand_adjustment = 50
	sit[e].seating_speed = 0.2
	sit[e].horizontal_view_limit = 90
	sit[e].vertical_view_limit = 50
	sit[e].trigger_ext_links = 0
	sit[e].seated_angle_adjust = 0
	sit[e].prompt_display = 1
	sit[e].item_highlight =	0
	sit[e].highlight_icon = "imagebank\\icons\\hand.png"

	seat_posx[e] = 0
	seat_posy[e] = 0
	seat_posz[e] = 0
	seat_angx[e] = 0
	seat_angy[e] = 0
	seat_angz[e] = 0	
	sittime[e] = 0
	sitmove[e] = 0
	last_gun[e] = 0
	keypause[e] = 0
	sitstate[e] = 0	
	freezeangy[e] = 0
	tEnt[e] = 0
	g_tEnt = 0
	done[e] = 0
	selectobj[e] = 0	
	status[e] = "init"
	hl_icon[e] = 0
	hl_imgwidth[e] = 0
	hl_imgheight[e] = 0	
end

function sit_main(e)
	
	if status[e] == "init" then
		if sit[e].item_highlight == 3 and sit[e].highlight_icon ~= "" then
			hl_icon[e] = CreateSprite(LoadImage(sit[e].highlight_icon))
			hl_imgwidth[e] = GetImageWidth(LoadImage(sit[e].highlight_icon))
			hl_imgheight[e] = GetImageHeight(LoadImage(sit[e].highlight_icon))
			SetSpriteSize(hl_icon[e],-1,-1)
			SetSpriteDepth(hl_icon[e],100)
			SetSpriteOffset(hl_icon[e],hl_imgwidth[e]/2.0, hl_imgheight[e]/2.0)
			SetSpritePosition(hl_icon[e],500,500)
		end
		seat_posx[e],seat_posy[e],seat_posz[e],seat_angx[e],seat_angy[e],seat_angz[e] = GetEntityPosAng(e)
		keypause[e] = g_Time + 1000
		sitmove[e] = sit[e].stand_adjustment
		status[e] = "wait"
	end
	
	if status[e] == "wait" then
		if sit[e].use_style == 1 then
			local PlayerDist = GetPlayerDistance(e)
			if PlayerDist < sit[e].use_range then
				selectobj[e]= U.ObjectPlayerLookingAt(sit[e].use_range)
				if g_Entity[e]['obj'] == selectobj[e] then
					if sit[e].prompt_display == 1 then TextCenterOnX(50,54,1,sit[e].use_prompt) end
					if sit[e].prompt_display == 2 then Prompt(sit[e].use_prompt) end
					local r,g,b = GetEntityEmissiveColor(e)
					if r==0 and g==0 and b==0 then SetEntityEmissiveColor(e,0,80,0) end
					if sit[e].item_highlight == 1 then SetEntityEmissiveStrength(e,500) end -- shape option
					if sit[e].item_highlight == 2 then SetEntityOutline(e,1) end -- outline option
					if g_Time > keypause[e] and sitstate[e] == 0 then
						if g_KeyPressE == 1 then
							last_gun[e] = g_PlayerGunName
							SetPlayerWeapons(0)
							PlaySound(e,0)
							status[e] = "sit"
							SetEntityEmissiveStrength(e,0)
							keypause[e] = g_Time + 1000
							sitstate[e] = 1
						end
					end
				else
					SetEntityEmissiveStrength(e,0)
				end
			end
		end
	
		if sit[e].use_style == 2 then
			local PlayerDist = GetPlayerDistance(e)
			if PlayerDist < sit[e].use_range then
				--pinpoint select object--
				module_misclib.pinpoint(e,sit[e].use_range,sit[e].item_highlight,hl_icon[e])
				tEnt[e] = g_tEnt
				--end pinpoint select object--
				if PlayerDist < sit[e].use_range and tEnt[e] == e then
					if sit[e].prompt_display == 1 then TextCenterOnX(50,54,1,sit[e].use_prompt) end
					if sit[e].prompt_display == 2 then Prompt(sit[e].use_prompt) end
					if g_Time > keypause[e] and sitstate[e] == 0 then
						if g_KeyPressE == 1 then
							last_gun[e] = g_PlayerGunName
							SetPlayerWeapons(0)
							PlaySound(e,0)
							status[e] = "sit"
							SetEntityEmissiveStrength(tEnt[e],0)
							keypause[e] = g_Time + 1000
							sitstate[e] = 1
						end
					end	
				end
			end
		end
	end

	if status[e] == "sit" then		
		CollisionOff(e)
		if GetCameraPositionY(0) > seat_posy[e]+sit[e].seated_y_position and sitstate[e] == 1 then
			SetCameraPosition(0,seat_posx[e]+sit[e].seated_x_position,GetCameraPositionY(0)-sittime[e],seat_posz[e]+sit[e].seated_z_position)
			SetCameraAngle(0,GetCameraAngleX(0),GetCameraAngleY(0)-180,GetCameraAngleZ(0))			
			if GetCameraPositionY(0) <= seat_posy[e]+sit[e].seated_y_position then
				SetCameraAngle(0,GetCameraAngleX(0),GetCameraAngleY(0)-180,GetCameraAngleZ(0))
				SetCameraPosition(0,seat_posx[e]+sit[e].seated_x_position,seat_posy[e]+sit[e].seated_y_position,seat_posz[e]+sit[e].seated_z_position)	
				sittime[e] = seat_posy[e]+sit[e].seated_y_position
				sitstate[e] = 2
				freezeangy[e] = g_Entity[e]['angley'] + sit[e].seated_angle_adjust
				SetGamePlayerControlFinalCameraAngley(freezeangy[e])
			end
			sittime[e] = sittime[e] + sit[e].seating_speed/60
		end
		if sitstate[e] == 2 then
			SetCameraPosition(0,seat_posx[e]+sit[e].seated_x_position,seat_posy[e]+sit[e].seated_y_position,seat_posz[e]+sit[e].seated_z_position)			
			SetCameraAngle(0,GetCameraAngleX(0),GetCameraAngleY(0)-180,GetCameraAngleZ(0))
			SetFreezeAngle(GetCameraAngleX(0),GetCameraAngleY(0),GetCameraAngleZ(0))
			SetFreezePosition(GetCameraPositionX(0),sittime[e],GetCameraPositionZ(0))			
			TransportToFreezePositionOnly()	
			--Set Lateral View Limit
			if GetGamePlayerControlFinalCameraAngley()>sit[e].horizontal_view_limit+freezeangy[e] then SetGamePlayerControlFinalCameraAngley(sit[e].horizontal_view_limit+freezeangy[e]) end
			if GetGamePlayerControlFinalCameraAngley()<-sit[e].horizontal_view_limit+freezeangy[e]then SetGamePlayerControlFinalCameraAngley(-sit[e].horizontal_view_limit+freezeangy[e]) end
			--Set Vertical View Limit
			if (GetGamePlayerStateCamAngleX()<-sit[e].vertical_view_limit) then SetGamePlayerStateCamAngleX(-sit[e].vertical_view_limit) end
			if (GetGamePlayerStateCamAngleX()>sit[e].vertical_view_limit) then SetGamePlayerStateCamAngleX(sit[e].vertical_view_limit) end
			if sit[e].trigger_ext_links == 1 and done[e] == 0 then 
				ActivateIfUsed(e)
				PerformLogicConnections(e)
				done[e] = 1
			end	
			if sit[e].trigger_ext_links == 2 and done[e] == 0 then 
				ActivateIfUsed(e)
				PerformLogicConnections(e)
				status[e] = "stand"
				keypause[e] = g_Time + 1000
				sitstate[e] = 0
			end
		end	
		
		if g_Time > keypause[e] and sitstate[e] == 2 then
			if g_KeyPressE == 1 then
				status[e] = "stand"
				keypause[e] = g_Time + 1000
				sitstate[e] = 0
			end
		end
	end
	if status[e] == "stand" then
		local ox,oy,oz = U.Rotate3D(0,0,-sitmove[e],math.rad(g_PlayerAngX),math.rad(g_PlayerAngY),math.rad(g_PlayerAngZ))
		local forwardposx,forwardposy,forwardposz = g_PlayerPosX+ox, g_PlayerPosY+oy, g_PlayerPosZ+oz
		local surfacehy = GetSurfaceHeight(forwardposx,forwardposy,forwardposz)
		SetFreezeAngle(g_PlayerAngX,g_PlayerAngY,g_PlayerAngZ)
		SetFreezePosition(forwardposx,surfacehy+35,forwardposz)
		TransportToFreezePositionOnly()	
		ChangePlayerWeapon(last_gun[e])
		SetPlayerWeapons(1)
		CollisionOn(e)
		sittime[e] = 0
		done[e] = 0
		status[e] = "wait"
	end
end