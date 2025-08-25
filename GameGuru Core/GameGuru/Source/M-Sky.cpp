//----------------------------------------------------
//--- GAMEGURU - M-Sky
//----------------------------------------------------
#include "stdafx.h"
#include "gameguru.h"

#ifdef WICKEDENGINE
#include ".\..\..\Guru-WickedMAX\wickedcalls.h"
#ifdef ENABLEIMGUI
#include "..\Imgui\imgui.h"
#ifndef IMGUI_DEFINE_MATH_OPERATORS
#define IMGUI_DEFINE_MATH_OPERATORS
#endif
#include "..\Imgui\imgui_internal.h"
#include "..\Imgui\imgui_impl_win32.h"
#include "..\Imgui\imgui_gg_dx11.h"
#endif
extern wiECS::Entity g_weatherEntityID;
#endif

#ifdef OPTICK_ENABLE
#include "optick.h"
#endif

void sky_init ( void )
{
	// refresh sky list
	g.skymax = 0;
	char pOldDir[MAX_PATH];
	strcpy(pOldDir, GetDir());

	//PE: skybank not really needed if using "none" or simulated
	char checkfolder[MAX_PATH];
	strcpy(checkfolder, pOldDir);
	strcat(checkfolder, "\\skybank");
	if (!PathExist(checkfolder))
	{
		Dim(t.skybank_s, 1);
		t.skybank_s[0] = "None";
		// Default sky settings
		t.sky.currenthour_f = 12.0;
		t.sky.daynightprogress = 0;
		return;
	}

	// get local and remote locations of skybank
	SetDir ("skybank");
	char pLocalSkyDir[MAX_PATH];
	strcpy(pLocalSkyDir, GetDir());
	char pRemoteSkyDir[MAX_PATH];
	strcpy(pRemoteSkyDir, "");
	extern StoryboardStruct Storyboard;
	int iSkyFoldersMax = 1;
	if (strlen(Storyboard.customprojectfolder) > 0)
	{
		strcpy(pRemoteSkyDir, Storyboard.customprojectfolder);
		strcat(pRemoteSkyDir, Storyboard.gamename);
		strcat(pRemoteSkyDir, "\\Files\\skybank\\");
		iSkyFoldersMax = 2;
	}
	for (int iSkyFolders = 0; iSkyFolders < iSkyFoldersMax; iSkyFolders++)
	{
		// Sky directory
		timestampactivity(0, "entering skybank");
		if (iSkyFolders == 0)
		{
			if (PathExist(pLocalSkyDir) == 0) continue;
			SetDir(pLocalSkyDir);
		}
		if (iSkyFolders == 1)
		{
			if (PathExist(pRemoteSkyDir) == 0) continue;
			SetDir(pRemoteSkyDir);
		}

		// Assemble list of all skies
		ChecklistForFiles ();
		timestampactivity(0, "checking skybank files");
		for (t.c = 1; t.c <= ChecklistQuantity(); t.c++)
		{
			if (ChecklistValueA(t.c) == 1)
			{
				t.file_s = ChecklistString(t.c);
				if (cstr(Left(t.file_s.Get(), 1)) != ".")
				{
					// only if contains skyspec.txt
					cstr pSkySpecFile = t.file_s + "\\skyspec.txt";
					if (FileExist(pSkySpecFile.Get()) == 1)
					{
						timestampactivity(0, t.file_s.Get());
						++g.skymax;
						Dim (t.skybank_s, g.skymax);
						if (g.skymax == 1)
						{
							t.skybank_s[0] = "None";
						}
						t.skybank_s[g.skymax] = Lower(t.file_s.Get());
						image_setlegacyimageloading(true);
						cstr cImageName = cstr(t.skybank_s[g.skymax] + "\\preview.bmp");
						LoadImage(cImageName.Get(), SKYBOX_ICONS + g.skymax);
						if (ImageExist(SKYBOX_ICONS + g.skymax) == 0)
						{
							cstr cImageName = cstr(t.skybank_s[g.skymax] + "\\" + Lower(t.file_s.Get())) + cstr("_cube.dds");
							LoadImage(cImageName.Get(), SKYBOX_ICONS + g.skymax);
							if (ImageExist(SKYBOX_ICONS + g.skymax) == 0)
							{
								cstr cImageName = cstr(t.skybank_s[g.skymax] + "\\" + Lower(t.file_s.Get())) + cstr(".png");
								LoadImage(cImageName.Get(), SKYBOX_ICONS + g.skymax);
								if (ImageExist(SKYBOX_ICONS + g.skymax) == 0)
								{
									cImageName = cstr(t.skybank_s[g.skymax] + "\\" + cstr("up.bmp"));
									LoadImage(cImageName.Get(), SKYBOX_ICONS + g.skymax);
								}
							}
						}
						image_setlegacyimageloading(false);
					}
				}
			}
		}
		if (iSkyFolders == 0)
		{
			// Only for stock skies
			// Include one sub-folder in for artist skyboxes
			for (t.s = 1; t.s <= g.skymax; t.s++)
			{
				t.ttry_s = t.skybank_s[t.s] + "\\skyspec.txt";
				if (FileExist(t.ttry_s.Get()) == 0)
				{
					// set entry to remove
					t.removethisone = t.s;
					// into the folder
					SetDir (t.skybank_s[t.s].Get());
					// now populate with any artist skies
					ChecklistForFiles();
					for (t.c = 1; t.c <= ChecklistQuantity(); t.c++)
					{
						if (ChecklistValueA(t.c) == 1)
						{
							t.file_s = ChecklistString(t.c);
							if (cstr(Left(t.file_s.Get(), 1)) != ".")
							{
								++g.skymax;
								Dim (t.skybank_s, g.skymax);
								image_setlegacyimageloading(true);
								cstr cImageName = cstr(t.skybank_s[t.s] + "\\" + Lower(t.file_s.Get()) + "\\" + Lower(t.file_s.Get())) + cstr(".png");
								LoadImage(cImageName.Get(), SKYBOX_ICONS + g.skymax);
								image_setlegacyimageloading(false);

								if (g.skymax == 1)
								{
									t.skybank_s[0] = "None";
								}
								t.skybank_s[g.skymax] = t.skybank_s[t.s] + "\\" + Lower(t.file_s.Get());
							}
						}
					}
					// out of folder
					SetDir ("..");

					// remove this empty folder entry
					for (t.ss = t.removethisone; t.ss <= g.skymax - 1; t.ss++)
					{
						t.skybank_s[t.ss] = t.skybank_s[t.ss + 1];
						char tmp[256];
						strcpy(tmp, t.skybank_s[t.ss + 1].Get());
						int a = 0;
						for (a = strlen(tmp); a > 0; a--)
						{
							if (tmp[a] == '\\')
							{
								a++;
								break;
							}
						}

						//PE: Shift image position.
						image_setlegacyimageloading(true);
						cstr cImageName = cstr(t.skybank_s[t.ss + 1] + "\\" + Lower(&tmp[a])) + cstr(".png");
						LoadImage(cImageName.Get(), SKYBOX_ICONS + t.ss);
						image_setlegacyimageloading(false);
					}
					--g.skymax;
				}
			}
		}
	}

	// Restore Dir
	SetDir ( pOldDir );
	timestampactivity(0, "finished sky bank scan");

	// Default sky settings
	t.sky.currenthour_f=12.0;
	t.sky.daynightprogress=0;
}

void sky_skyspec_init(bool bResetVisuals)
{
	//PE: Wicked is so different we need this for wicked only.
	visualstype* visuals = &t.visuals;

	// Get lighting data from skyspec
	if (g.skyindex > 0)
	{
		// Load sky spec for light position and color
		t.terrain.skyshader_s = "";
		t.terrain.skyscrollshader_s = "";
		t.terrain.sunskyscrollspeedx_f = 0.0;
		t.terrain.sunskyscrollspeedz_f = 0.0;
		if (g.skyindex >= t.skybank_s.size())
		{
			if (t.skybank_s.size() == 0)
			{
				Dim(t.skybank_s, 1);
				t.skybank_s[0] = "None";
			}
			g.skyindex = 0;
			return;
		}
		t.skyname_s = t.skybank_s[g.skyindex];
		timestampactivity(0, cstr(cstr("Loading skyspec.txt:") + t.skyname_s).Get());

		cstr skypath = cstr(cstr("skybank\\") + t.skyname_s + "\\skyspec.txt");
		if (!DB_FileExist(skypath.Get()))
		{
			//PE: Just ignore if skybox is not there. and set to none.
			g.skyindex = 0;
			return;
		}
		OpenToRead(1, skypath.Get());
		Dim(t.value_f, 3); t.valuei = 0;
		do
		{
			t.line_s = ReadString(1);
			t.line_s = Lower(t.line_s.Get());

			// common values
			t.try_s = "suncolor";
			if (cstr(Left(t.line_s.Get(), Len(t.try_s.Get()))) == t.try_s)
			{
				terrain_parsed_getvalues();
				if (bResetVisuals)
				{
					t.terrain.suncolorr_f = t.value_f[0];
					t.terrain.suncolorg_f = t.value_f[1];
					t.terrain.suncolorb_f = t.value_f[2];
					visuals->SunRed_f = t.value_f[0];
					visuals->SunGreen_f = t.value_f[1];
					visuals->SunBlue_f = t.value_f[2];
				}
			}
			t.try_s = "sunstrength";
			if (cstr(Left(t.line_s.Get(), Len(t.try_s.Get()))) == t.try_s)
			{
				terrain_parsed_getvalues();
				if (bResetVisuals)
				{
					t.terrain.sunstrength_f = t.value_f[0];
					visuals->SunIntensity_f = t.value_f[0];
				}
			}

			t.try_s = "exposure";
			if (cstr(Left(t.line_s.Get(), Len(t.try_s.Get()))) == t.try_s)
			{
				terrain_parsed_getvalues();
				if (bResetVisuals)
				{
					visuals->fExposure = t.value_f[0];
				}
			}

			t.try_s = "ambientcolor";
			if (cstr(Left(t.line_s.Get(), Len(t.try_s.Get()))) == t.try_s)
			{
				terrain_parsed_getvalues();
				if (bResetVisuals)
				{
					visuals->AmbienceRed_f = t.value_f[0];
					visuals->AmbienceGreen_f = t.value_f[1];
					visuals->AmbienceBlue_f = t.value_f[2];
				}
			}

			// wicked specific sky settings
			t.try_s = "sunrotationx";
			if (cstr(Left(t.line_s.Get(), Len(t.try_s.Get()))) == t.try_s)
			{
				terrain_parsed_getvalues();
				if (bResetVisuals)
				{
					t.terrain.sunrotationx_f = t.value_f[0];
					visuals->SunAngleX = t.value_f[0];
				}
			}
			t.try_s = "sunrotationy";
			if (cstr(Left(t.line_s.Get(), Len(t.try_s.Get()))) == t.try_s)
			{
				terrain_parsed_getvalues();
				if (bResetVisuals)
				{
					t.terrain.sunrotationy_f = t.value_f[0];
					visuals->SunAngleY = t.value_f[0];
				}
			}
			t.try_s = "sunrotationz";
			if (cstr(Left(t.line_s.Get(), Len(t.try_s.Get()))) == t.try_s)
			{
				terrain_parsed_getvalues();
				if (bResetVisuals)
				{
					t.terrain.sunrotationz_f = t.value_f[0];
					visuals->SunAngleZ = t.value_f[0];
				}
			}

		} while (!(t.line_s == ""));
		CloseFile(1);

		// when using a skybank, ensure it is copied over to remote project if not there
		cstr sFolderToCopy = cstr(cstr("skybank\\") + t.skyname_s);
		extern void mapfile_ensurethisfolderexistsinremoteproject(LPSTR);
		mapfile_ensurethisfolderexistsinremoteproject(sFolderToCopy.Get());
	}

	if (t.game.runasmultiplayer == 1) mp_refresh();

	// Initialise main and secondary sky
	SetMipmapNum(1);
	timestampactivity(0, cstr(cstr("Initialise sky textures")).Get());
	for (t.tskyi = 0; t.tskyi <= t.terrainskyspecinitmode; t.tskyi++)
	{
		// sky object
		if (t.tskyi == 0) { t.skyobj = t.terrain.objectstartindex + 4; t.skyname_s = t.skybank_s[g.skyindex]; }
		if (t.tskyi == 1) { t.skyobj = t.terrain.objectstartindex + 8; t.skyname_s = "night"; }

		if (t.game.runasmultiplayer == 1) mp_refresh();

		// skyname only
		t.skynameonly_s = t.skyname_s;
		for (t.n = Len(t.skyname_s.Get()); t.n >= 1; t.n += -1)
		{
			if (cstr(Mid(t.skyname_s.Get(), t.n)) == "\\" || cstr(Mid(t.skyname_s.Get(), t.n)) == "/")
			{
				t.skynameonly_s = Right(t.skyname_s.Get(), Len(t.skyname_s.Get()) - t.n);
				break;
			}
		}

		// sky is stored as a cube map DDS
		cstr pFileToLoad = cstr(cstr("skybank\\") + t.skyname_s + "\\" + t.skynameonly_s + "_cube.dds");
		timestampactivity(0, cstr(cstr("Load sky cube:") + pFileToLoad).Get());
		wiScene::WeatherComponent* weather = wiScene::GetScene().weathers.GetComponent(g_weatherEntityID);
		if (t.skyname_s != "None")
		{
			// if cube does not exist, need to make one
			if (!FileExist(pFileToLoad.Get()))
			{
				// Load in the six sides for the sky
				LPSTR pUp = NULL, pDown = NULL, pLeft = NULL, pRight = NULL, pBack = NULL, pFront = NULL;
				cstr pOldDir = GetDir();
				SetDir(cstr(cstr("skybank\\") + t.skyname_s + "\\").Get());
				int iFoundImages = 0;
				ChecklistForFiles();
				for (int c = 1; c <= ChecklistQuantity(); c++)
				{
					LPSTR pFile = ChecklistString(c);
					if (pFile && strcmp(pFile, ".") != NULL & strcmp(pFile, "..") != NULL)
					{
						if (strnicmp(pFile + strlen(pFile) - 4, ".dds", 4) == NULL
							|| strnicmp(pFile + strlen(pFile) - 4, ".bmp", 4) == NULL
							|| strnicmp(pFile + strlen(pFile) - 4, ".png", 4) == NULL
							|| strnicmp(pFile + strlen(pFile) - 4, ".jpg", 4) == NULL)
						{
							//PE: Ignore case (sunset_06).
							if (pestrcasestr(pFile, "up") || pestrcasestr(pFile, "top") || strnicmp(pFile + strlen(pFile) - 5, "U", 1) == NULL) { pUp = pFile; iFoundImages++; }
							if (pestrcasestr(pFile, "down") || pestrcasestr(pFile, "bottom") || strnicmp(pFile + strlen(pFile) - 5, "D", 1) == NULL) { pDown = pFile; iFoundImages++; }
							if (pestrcasestr(pFile, "left") != NULL || strnicmp(pFile + strlen(pFile) - 5, "L", 1) == NULL) { pLeft = pFile; iFoundImages++; }
							if (pestrcasestr(pFile, "right") != NULL || strnicmp(pFile + strlen(pFile) - 5, "R", 1) == NULL) { pRight = pFile; iFoundImages++; }
							if (pestrcasestr(pFile, "back") != NULL || strnicmp(pFile + strlen(pFile) - 5, "B", 1) == NULL) { pBack = pFile; iFoundImages++; }
							if (pestrcasestr(pFile, "front") != NULL || strnicmp(pFile + strlen(pFile) - 5, "F", 1) == NULL) { pFront = pFile; iFoundImages++; }
						}
					}
				}

				// Save final sky cube file - combine all sky side images into a single cube map creation using DirectXTex
				cstr pCubeToSave = t.skynameonly_s + "_cube.dds";

				//All Megapack 1, and others have them reversed. for now:
				if (iFoundImages == 6)
				{
					// new skies require front and back flipped
					ImageCreateCubeMapFile(pCubeToSave.Get(), pUp, pDown, pLeft, pRight, pFront, pBack);
				}

				// finally restore folder
				SetDir(pOldDir.Get());
			}

			// wicked has its own cube map to render the static sky backdrop!
			if (weather->skyMap != nullptr && weather->skyMapName.length() > 0)
			{
				//PE: Make sure to free any old resources.
				WickedCall_DeleteImage(weather->skyMapName);
			}
			weather->skyMapName = pFileToLoad.Get();
			weather->skyMap = WickedCall_LoadImage(weather->skyMapName);
			weather->cloudiness = 0.0f; //PE: This has changed in the new repo, same shader is now used and cloudiness turn it off, so must now be zero.
			weather->cloudSpeed = 0.0f; //To stop moving lightshaft.

			// set the sun parameters
			extern void Wicked_Update_Visuals(void *voidvisual);
			Wicked_Update_Visuals((void*)visuals);
		}
		else
		{
			//Delete if we alreadey have one loaded.
			timestampactivity(0, "delete any old sky");
			if (weather->skyMap != nullptr && weather->skyMapName.length() > 0)
			{
				//PE: Make sure to free any old resources.
				WickedCall_DeleteImage(weather->skyMapName);
			}
			weather->skyMap = nullptr;
			weather->skyMapName = "";
			weather->cloudSpeed = t.visuals.SkyCloudSpeed;
			weather->cloudiness = t.visuals.SkyCloudiness;
		}
		// and ensure env probes updated
		timestampactivity(0, "update probes for the sky");
		WickedCall_UpdateProbes();
	}

	// For MAIN sky, get full name and name only strings (again)
	t.skyname_s = t.skybank_s[g.skyindex];
	t.skynameonly_s = t.skyname_s;
	timestampactivity(0, t.skyname_s.Get());
	for (t.n = Len(t.skyname_s.Get()); t.n >= 1; t.n += -1)
	{
		if (cstr(Mid(t.skyname_s.Get(), t.n)) == "\\" || cstr(Mid(t.skyname_s.Get(), t.n)) == "/")
		{
			t.skynameonly_s = Right(t.skyname_s.Get(), Len(t.skyname_s.Get()) - t.n);
			break;
		}
	}
	SetMipmapNum(-1);

	// when change sky, due to sun direction, must update shader constants too
	t.visuals.refreshshaders = 1;

	// when skybox changes, refresh env probes
	extern bool g_bLightProbeScaleChanged;
	g_bLightProbeScaleChanged = true;
}

void sky_hide ( void )
{
	if ( ObjectExist(t.terrain.objectstartindex+4) == 1 ) 
	{
		t.tskyobj1v=GetVisible(t.terrain.objectstartindex+4);
		HideObject ( t.terrain.objectstartindex+4 );
	}
	if ( ObjectExist(t.terrain.objectstartindex+8) == 1 ) 
	{
		t.tskyobj2v=GetVisible(t.terrain.objectstartindex+8);
		HideObject ( t.terrain.objectstartindex+8 );
	}
	if ( ObjectExist(t.terrain.objectstartindex+9) == 1 ) 
	{
		t.tskyobj3v=GetVisible(t.terrain.objectstartindex+9);
		HideObject ( t.terrain.objectstartindex+9 );
	}
}

void sky_show ( void )
{
	if ( ObjectExist(t.terrain.objectstartindex+4) == 1 && t.tskyobj1v == 1 ) ShowObject ( t.terrain.objectstartindex+4 );
	if ( ObjectExist(t.terrain.objectstartindex+8) == 1 && t.tskyobj2v == 1 ) ShowObject ( t.terrain.objectstartindex+8 );
	if ( ObjectExist(t.terrain.objectstartindex+9) == 1 && t.tskyobj3v == 1 ) ShowObject ( t.terrain.objectstartindex+9 );
}

void sky_free ( void )
{
	// free sky objects
	if ( ObjectExist(t.terrain.objectstartindex+4) == 1 ) DeleteObject ( t.terrain.objectstartindex+4 );
	if ( ObjectExist(t.terrain.objectstartindex+8) == 1 ) DeleteObject ( t.terrain.objectstartindex+8 );
	if ( ObjectExist(t.terrain.objectstartindex+9) == 1 ) DeleteObject ( t.terrain.objectstartindex+9 );
}

void sky_loop ( void )
{
#ifdef OPTICK_ENABLE
	OPTICK_EVENT();
#endif
	// day
	t.sky.alpha1_f=1.0;
	t.sky.alpha2_f=0;

	// Update skybox position
	if ( t.hardwareinfoglobals.nosky == 0 ) 
	{
		if ( ObjectExist(t.terrain.objectstartindex+4) == 1 ) 
		{
			if ( t.sky.alpha1_f>0 ) 
			{
				PositionObject ( t.terrain.objectstartindex+4,CameraPositionX(t.terrain.gameplaycamera),CameraPositionY(t.terrain.gameplaycamera),CameraPositionZ(t.terrain.gameplaycamera) );
				SetAlphaMappingOn ( t.terrain.objectstartindex+4,100.0*t.sky.alpha1_f );
				ShowObject ( t.terrain.objectstartindex+4 );
			}
			else
			{
				HideObject ( t.terrain.objectstartindex+4 );
			}
		}
		if ( ObjectExist(t.terrain.objectstartindex+8) == 1 ) 
		{
			if ( t.sky.alpha2_f>0 ) 
			{
				PositionObject ( t.terrain.objectstartindex+8,CameraPositionX(t.terrain.gameplaycamera),CameraPositionY(t.terrain.gameplaycamera),CameraPositionZ(t.terrain.gameplaycamera) );
				SetAlphaMappingOn ( t.terrain.objectstartindex+8,100.0*t.sky.alpha2_f );
				ShowObject ( t.terrain.objectstartindex+8 );
			}
			else
			{
				HideObject ( t.terrain.objectstartindex+8 );
			}
		}
		if ( ObjectExist(t.terrain.objectstartindex+9) == 1 ) 
		{
			PositionObject ( t.terrain.objectstartindex+9,CameraPositionX(t.terrain.gameplaycamera),CameraPositionY(t.terrain.gameplaycamera)+7000,CameraPositionZ(t.terrain.gameplaycamera) );
			if ( GetEffectExist(t.terrain.effectstartindex+9) == 1 ) 
			{
				t.terrain.sunskyscrollx_f=t.terrain.sunskyscrollx_f+(t.terrain.sunskyscrollspeedx_f*g.timeelapsed_f);
				t.terrain.sunskyscrollz_f=t.terrain.sunskyscrollz_f+(t.terrain.sunskyscrollspeedz_f*g.timeelapsed_f);
				SetVector4 ( g.terrainvectorindex,t.terrain.sunskyscrollx_f,t.terrain.sunskyscrollz_f,0,0 );
				SetEffectConstantVEx ( t.terrain.effectstartindex+9,t.effectparam.skyscroll.SkyScrollValues,g.terrainvectorindex );
			}
		}
	}

	// update sky fog
	#ifdef WICKEDENGINE
	// wicked has its own fog
	#else
	if ( GetEffectExist(t.terrain.effectstartindex+4) ) 
	{
		SetVector4 ( g.terrainvectorindex,t.visuals.FogNearest_f,t.visuals.FogDistance_f,0,0 );
		SetEffectConstantVEx ( t.terrain.effectstartindex+4,t.effectparam.sky.HudFogDist,g.terrainvectorindex );
		SetVector4 ( g.terrainvectorindex,t.visuals.FogR_f/255.0,t.visuals.FogG_f/255.0,t.visuals.FogB_f/255.0,t.visuals.FogA_f/255.0 );
		SetEffectConstantVEx ( t.terrain.effectstartindex+4,t.effectparam.sky.HudFogColor,g.terrainvectorindex );
	}
	if ( GetEffectExist(t.terrain.effectstartindex+9) == 1 ) 
	{
		SetVector4 ( g.terrainvectorindex,t.visuals.FogNearest_f,t.visuals.FogDistance_f,0,0 );
		SetEffectConstantVEx ( t.terrain.effectstartindex+9,t.effectparam.skyscroll.HudFogDist,g.terrainvectorindex );
		SetVector4 ( g.terrainvectorindex,t.visuals.FogR_f/255.0,t.visuals.FogG_f/255.0,t.visuals.FogB_f/255.0,t.visuals.FogA_f/255.0 );
		SetEffectConstantVEx ( t.terrain.effectstartindex+9,t.effectparam.skyscroll.HudFogColor,g.terrainvectorindex );
	}
	#endif
}
