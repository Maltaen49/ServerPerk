class SRHUDKillingFloor extends SRHUDBase;
	
#exec obj load file="KFMapEndTextures.utx"
#exec obj load file="2K4Menus.utx"
//#exec obj load file="TreeNew_A.utx"
#exec TEXTURE IMPORT FILE="Textures\11_FROWN.pcx" NAME="I_Frown" GROUP="Emo" MIPS=0 MASKED=1
#exec TEXTURE IMPORT FILE="Textures\12_INDIFFE.pcx" NAME="I_Indiffe" GROUP="Emo" MIPS=0 MASKED=1
#exec TEXTURE IMPORT FILE="Textures\13_OHWELL.pcx" NAME="I_Ohwell" GROUP="Emo" MIPS=0 MASKED=1
#exec TEXTURE IMPORT FILE="Textures\16_BIGGRIN.pcx" NAME="I_BigGrin" GROUP="Emo" MIPS=0 MASKED=1
#exec TEXTURE IMPORT FILE="Textures\17_TONGUE1.pcx" NAME="I_Tongue" GROUP="Emo" MIPS=0 MASKED=1
#exec TEXTURE IMPORT FILE="Textures\17_TONGUE2.pcx" NAME="I_TongueB" GROUP="Emo" MIPS=0 MASKED=1
#exec TEXTURE IMPORT FILE="Textures\18_REDFACE.pcx" NAME="I_RedFace" GROUP="Emo" MIPS=0 MASKED=1
#exec TEXTURE IMPORT FILE="Textures\19_GREENLI1.pcx" NAME="I_GreenLick" GROUP="Emo" MIPS=0 MASKED=1
#exec TEXTURE IMPORT FILE="Textures\19_GREENLI2.pcx" NAME="I_GreenLickB" GROUP="Emo" MIPS=0 MASKED=1
#exec TEXTURE IMPORT FILE="Textures\Ban.pcx" NAME="I_Ban" GROUP="Emo" MIPS=0 MASKED=1
#exec TEXTURE IMPORT FILE="Textures\COOL.pcx" NAME="I_Cool" GROUP="Emo" MIPS=0 MASKED=1
#exec TEXTURE IMPORT FILE="Textures\HM.pcx" NAME="I_Hmm" GROUP="Emo" MIPS=0 MASKED=1
#exec TEXTURE IMPORT FILE="Textures\MAD.pcx" NAME="I_Mad" GROUP="Emo" MIPS=0 MASKED=1
#exec TEXTURE IMPORT FILE="Textures\SCREAM6.pcx" NAME="I_Scream" GROUP="Emo" MIPS=0 MASKED=1
#exec TEXTURE IMPORT FILE="Textures\SPAM.pcx" NAME="I_Spam" GROUP="Emo" MIPS=0 MASKED=1
#exec OBJ LOAD FILE=GL4_T.utx PACKAGE=Masters
#exec OBJ LOAD FILE=ONYX_T.utx PACKAGE=Masters
//#exec OBJ LOAD FILE=GL8_T.utx PACKAGE=Masters

struct SmileyMessageType
{
	var string SmileyTag;
	var texture SmileyTex;
	var bool bInCAPS;
};
var array<SmileyMessageType> SmileyMsgs;
//var array<SRPlayerReplicationInfo.ClanInfo> pClanInfo[10];
//var array<SRPlayerReplicationInfo.ClanData> pClanList[10];

//var ClanLogoMut ClanLogoM;
var localized string SumDmgTxt;
var() config bool bShowSpeed;
var() config bool bShowTime;
var() config bool bSBTrue;
var() config float SpeedometerX, SpeedometerY; 
var() config byte SpeedometerFont; 

struct SHitInfo
{
	var string Text;
	var float LastHit;
};

struct Damage
{
	var int Damage;
	var float LastHit;
	var bool IsHead;
};

var SHitInfo SHitText[4];
var byte SHitInt;
var float RY[30],RX[30];
var Damage Dam[30];
var int Dint;
var byte secondViewed;
var color DamRegCol, DamHsCol;

var ClientPerkRepLink ClientRep;

var float SumDmgLH,SumDmgDelay;
var int SumDmg;

var float NextBlinkTime,BlinkInterval;
var bool Blink;
// by Dr. Killjoy aka Steklo, так же использован код от Тело aka Dave_Scream

var array<string> DemonessaCongratzMess;
var float CongratzDemonessaMessFreq,CongratzDemonessaMessTime;
var int CDMIndex;

simulated function ShowDamage(int D, float LH, bool isHead)
{
	if (SumDmgLH + SumDmgDelay < LH) // Если после последнего попадания прошло слишком много времени, обнуляем суммарный дамаг
		SumDmg=0;
	SumDmg += D;
	SumDmgLH = LH;
	
	RX[Dint] = ( 0.4+(0.2*frand()) );
	RY[Dint] = ( 0.1+(0.2*frand()) );
	Dam[Dint].damage = D;
	Dam[Dint].LastHit = LH;
	Dam[Dint].IsHead = isHead;

	Dint++;

	if(Dint > 29)
		Dint=0;
}

simulated function HandleSHit(canvas c)
{
	local int i;
	local float XPos,YPos, fadetimeB, fadetimeG, fadetimeR;
	local int RColor,GColor,BColor;

	C.Font = GetConsoleFont(C);
	for( i=0;i<3;i++)
	{
		XPos = 0.7 * c.clipx;

		YPos = ( 0.7 - ((level.timeseconds - SHitText[i].lasthit)/20) ) * c.clipy;
		if( YPos <= 0.3 )
			YPos = 0.3;


		if( i < 2 && 0.7 - ((level.timeseconds - SHitText[i+1].lasthit)/20) <= 0.6 && SHitText[i+1].text != ""||
			i == 2 && 0.7 - ((level.timeseconds - SHitText[0].lasthit)/20) <= 0.6 && SHitText[0].text != "")
			SHitText[i].text="";

		if( 5 < level.timeseconds - SHitText[i].lasthit )
			{
				SHitText[i].lasthit = 0;
				SHitText[i].text = "";

			}
			else if( SHitText[i].text != "" )
			{
				c.Setpos(Xpos,Ypos);
				c.drawtext(SHitText[i].text);

			}
	}

	C.Font = LoadFont(7);
	for(i=0;i<30;i++)
	{
		if( 2 < level.timeseconds - Dam[i].lasthit )
		{
			if (!Dam[i].isHead)
				continue;
			else
				if ((Dam[i].isHead) && ( 5 < level.timeseconds - Dam[i].lasthit ))
					continue;
		}
		c.style = Erenderstyle.sty_translucent;

		//log("DamColor"@DamRegCol.R@DamRegCol.G@DamRegCol.B);
		
		//Regular damage color
        RColor = 255;//DamRegCol.R;
        GColor = 255;//DamRegCol.G;
        BColor = 100;//DamRegCol.B;
		
		//Headshot damage color
		if(Dam[i].IsHead)
		{
			RColor = 255; //DamHsCol.R;
        	GColor = 0; // DamHsCol.G;
        	BColor = 0; // DamHsCol.B;
		}
		if (Dam[i].isHead)
		{
			fadetimeR = ((level.timeseconds - Dam[i].lasthit)*(RColor/5));
			fadetimeG = ((level.timeseconds - Dam[i].lasthit)*(GColor/5));
			fadetimeB = ((level.timeseconds - Dam[i].lasthit)*(BColor/5));
		}
		else
		{
			fadetimeR = ((level.timeseconds - Dam[i].lasthit)*(RColor/2));
			fadetimeG = ((level.timeseconds - Dam[i].lasthit)*(GColor/2));
			fadetimeB = ((level.timeseconds - Dam[i].lasthit)*(BColor/2));
		}
		c.SetPos( RX[i]* c.clipx, RY[i]* c.clipy);


		//color
        	c.drawcolor.r=RColor-fadetimeR;
        	c.drawcolor.g=GColor-fadetimeG;
			c.drawcolor.b=BColor-FadetimeB;

		c.DrawText(Dam[i].damage);
	}
}

simulated function SumDmgShow(canvas c)
{
	local float tXL, tYL,fadetimeR,fadetimeG,fadetimeB,fadeMult,tScaleX, tScaleY;
	local Color tColor, dColor;
	local string S;
	if (SumDmg==0)
		return;
	
	tColor = c.DrawColor;
	tScaleX = c.FontScaleX;
	tScaleY = c.FontScaleY;
	c.FontScaleX*=1.50;
	c.FontScaleY*=1.50;
	if (SumDmgLH+SumDmgDelay > level.timeseconds)
	{
		c.style = Erenderstyle.sty_translucent;
		dColor.r = 255;
		dColor.g = 255;
		dColor.b = 100;
		fadeMult = (-((level.timeseconds-SumDmgLH)/SumDmgDelay))+1;
		c.drawcolor.r=dColor.r*fadeMult;
		c.drawcolor.g=dColor.g*fadeMult;
		c.drawcolor.b=dColor.b*fadeMult;	

		S="Damage:+"$SumDmg;
		c.SetPos(c.ClipX/2-tXL/2-120, 0.3*c.clipY-200); // посередине почти
		//c.SetPos(c.ClipX-tXL-10, 135+tYL+5); //справа в углу
		c.DrawText(S);
	}
	c.FontScaleX = tScaleX;
	c.FontScaleY = tScaleY;
	c.DrawColor = tColor;
}

simulated event PostRender( canvas Canvas )
{
	super.PostRender(canvas);
	//HandleSHit(canvas);
	SumDmgShow(canvas);
	
	if (SRPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).bShowHeadShotSphere == true)
		DrawHeadShotSphere();
	else
		ClearStayingDebugLines();
}
simulated function PostBeginPlay()
{
	local Font MyFont;

	Super(HudBase).PostBeginPlay();
	SetHUDAlpha();

	foreach DynamicActors(class'KFSPLevelInfo', KFLevelRule)
		Break;

	Hint_45_Time = 9999999;

	MyFont = LoadWaitingFont(0);
	MyFont = LoadWaitingFont(1);

	bUseBloom = bool(ConsoleCommand("get ini:Engine.Engine.ViewportManager Bloom"));
	bUseMotionBlur = Class'KFHumanPawn'.Default.bUseBlurEffect;

    // prevent using speedometer as crosshair
    if ( SpeedometerX > 0.4 && SpeedometerX < 0.6
            && SpeedometerY > 0.4 && SpeedometerY < 0.6 ) 
	{
        SpeedometerX = 0.985;
        SpeedometerY = 0.80;
        PlayerOwner.ClientMessage("HUD Cheat Prevention: Speedometer position set to default");
    }
}

function DrawCustomBeacon(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY);

simulated function DrawSpectatingHud(Canvas C)
{
	local rotator CamRot;
	local vector CamPos, ViewDir, ScreenPos;
	local KFPawn KFBuddy;

	DrawModOverlay(C);

	if( bHideHud )
		return;

	PlayerOwner.PostFX_SetActive(0, false);

	// Grab our View Direction
	C.GetCameraLocation(CamPos, CamRot);
	ViewDir = vector(CamRot);

	// Draw the Name, Health, Armor, and Veterancy above other players (using this way to fix portal's beacon errors).
	foreach VisibleCollidingActors(Class'KFPawn',KFBuddy,1000.f,CamPos)
	{
		KFBuddy.bNoTeamBeacon = true;
		if ( KFBuddy.PlayerReplicationInfo!=None && KFBuddy.Health>0 && ((KFBuddy.Location - CamPos) Dot ViewDir)>0.8 )
		{
			ScreenPos = C.WorldToScreen(KFBuddy.Location+vect(0,0,1)*KFBuddy.CollisionHeight);
			if( ScreenPos.X>=0 && ScreenPos.Y>=0 && ScreenPos.X<=C.ClipX && ScreenPos.Y<=C.ClipY )
				DrawPlayerInfo(C, KFBuddy, ScreenPos.X, ScreenPos.Y);
		}
	}

	DrawFadeEffect(C);

	if ( KFPlayerController(PlayerOwner) != None && KFPlayerController(PlayerOwner).ActiveNote != None )
		KFPlayerController(PlayerOwner).ActiveNote = None;

	if( KFGameReplicationInfo(Level.GRI) != none && KFGameReplicationInfo(Level.GRI).EndGameType > 0 )
	{
		if( KFGameReplicationInfo(Level.GRI).EndGameType == 2 )
		{
			DrawEndGameHUD(C, True);
			Return;
		}
		else DrawEndGameHUD(C, False);
	}

	DrawKFHUDTextElements(C);
	DisplayLocalMessages(C);

	if ( bShowScoreBoard && ScoreBoard != None )
		ScoreBoard.DrawScoreboard(C);

	// portrait
	if ( bShowPortrait && Portrait != None )
		DrawPortrait(C);

	// Draw hints
	if ( bDrawHint )
		DrawHint(C);
}

simulated function DrawHud(Canvas C)
{
	local KFGameReplicationInfo CurrentGame;
	local rotator CamRot;
	local vector CamPos, ViewDir, ScreenPos;
	local KFPawn KFBuddy;

	local class<SRVeterancyTypes> VeterancyClass;
	local float coiff;

	CurrentGame = KFGameReplicationInfo(Level.GRI);

	if ( FontsPrecached < 2 )
		PrecacheFonts(C);

	UpdateHud();

	PassStyle = STY_Modulated;
	DrawModOverlay(C);

	if ( bUseBloom )
		PlayerOwner.PostFX_SetActive(0, true);

	if ( bHideHud )
	{
		// Draw fade effects even if the hud is hidden so poeple can't just turn off thier hud
		C.Style = ERenderStyle.STY_Alpha;
		DrawFadeEffect(C);
		return;
	}

	if ( !KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).bViewingMatineeCinematic )
	{
		if ( bShowTargeting )
			DrawTargeting(C);

		// Grab our View Direction
		C.GetCameraLocation(CamPos,CamRot);
		ViewDir = vector(CamRot);
		// Draw the Name, Health, Armor, and Veterancy above other players (using this way to fix portal's beacon errors).
		VeterancyClass=class<SRVeterancyTypes>(KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).ClientVeteranSkill);
		coiff=VeterancyClass.static.GetHUDCoiff(KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo));
		HealthBarCutoffDist = default.HealthBarCutoffDist * coiff;
		foreach VisibleCollidingActors(Class'KFPawn',KFBuddy,0.5 * HealthBarCutoffDist,CamPos)
		//foreach VisibleCollidingActors(Class'KFPawn',KFBuddy,1000.f,CamPos)
		{
			KFBuddy.bNoTeamBeacon = true;
			if ( KFBuddy!=PawnOwner && KFBuddy.PlayerReplicationInfo!=None && KFBuddy.Health>0 && ((KFBuddy.Location - CamPos) Dot ViewDir)>0.8 )
			{
				ScreenPos = C.WorldToScreen(KFBuddy.Location+vect(0,0,1)*KFBuddy.CollisionHeight);
				if( ScreenPos.X>=0 && ScreenPos.Y>=0 && ScreenPos.X<=C.ClipX && ScreenPos.Y<=C.ClipY )
					DrawPlayerInfo(C, KFBuddy, ScreenPos.X, ScreenPos.Y);
			}
		}

		PassStyle = STY_Alpha;
		DrawDamageIndicators(C);
		DrawHudPassA(C);
		DrawHudPassC(C);

		if ( KFPlayerController(PlayerOwner)!= None && KFPlayerController(PlayerOwner).ActiveNote!=None )
		{
			if( PlayerOwner.Pawn == none )
				KFPlayerController(PlayerOwner).ActiveNote = None;
			else KFPlayerController(PlayerOwner).ActiveNote.RenderNote(C);
		}

		PassStyle = STY_None;
		DisplayLocalMessages(C);
		DrawWeaponName(C);
		DrawVehicleName(C);

		PassStyle = STY_Alpha;

		if ( CurrentGame!=None && CurrentGame.EndGameType > 0 )
		{
			DrawEndGameHUD(C, (CurrentGame.EndGameType==2));
			return;
		}

		RenderFlash(C);
		C.Style = PassStyle;
		DrawKFHUDTextElements(C);
	}
	if ( KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).bViewingMatineeCinematic )
	{
		PassStyle = STY_Alpha;
		DrawCinematicHUD(C);
	}
	if ( bShowNotification )
		DrawPopupNotification(C);
//========================================================// Vepr 12
    if( ! bHideHud && PawnOwner != none ) 
	{
        if ( bShowSpeed )
            DrawSpeed(C);
    }
}

simulated function UpdateHud()
{
	local float maxAmmo,currentAmmo;
        local float MaxGren, CurGren;
        local KFHumanPawn KFHPawn;
        local NewSyringe S;
	Super(HUDKillingFloor).UpdateHud();
	maxAmmo=1;
	currentAmmo=1;
	if(PawnOwner.Weapon==None) return;
	PawnOwner.Weapon.GetAmmoCount(maxAmmo,currentAmmo);

        if( PawnOwner == none )
        {
                super.UpdateHud();
                return;
        }

        KFHPawn = KFHumanPawn(PawnOwner);

        CalculateAmmo();

        if ( KFHPawn != none )
        {
                FlashlightDigits.Value = 100 * (float(KFHPawn.TorchBatteryLife) / float(KFHPawn.default.TorchBatteryLife));
        }

        if ( KFWeapon(PawnOwner.Weapon) != none )
        {
                BulletsInClipDigits.Value = KFWeapon(PawnOwner.Weapon).MagAmmoRemaining;

                if ( BulletsInClipDigits.Value < 0 )
                {
                        BulletsInClipDigits.Value = 0;
                }
        }

        ClipsDigits.Value = CurClipsPrimary;
        SecondaryClipsDigits.Value = CurClipsSecondary;

        if ( LAW(PawnOwner.Weapon) != none || Crossbow(PawnOwner.Weapon) != none
			|| M79GrenadeLauncher(PawnOwner.Weapon) != none || EX41GrenadeLauncher(PawnOwner.Weapon) != none || PipeBombExplosive(PawnOwner.Weapon) != none
			|| TacticalMineExplosive(PawnOwner.Weapon) != none || FireBombExplosive(PawnOwner.Weapon) != none || PipeBombExplosiveA(PawnOwner.Weapon) != none )
        {
                ClipsDigits.Value += KFWeapon(PawnOwner.Weapon).MagAmmoRemaining;
        }
		else if (LAWM(PawnOwner.Weapon) != none || RPG(PawnOwner.Weapon) != none
			|| M79FGrenadeLauncher(PawnOwner.Weapon) != none || M79GrenadeLauncherM(PawnOwner.Weapon) != none 
			|| SelfDestruct(PawnOwner.Weapon) != none || CrossbowM(PawnOwner.Weapon) != none )
		{
		//Log("ClipsDigits.Value"@ClipsDigits.Value@KFWeapon(PawnOwner.Weapon).MagAmmoRemaining@BulletsInClipDigits.Value@PawnOwner.Weapon);
			ClipsDigits.Value += KFWeapon(PawnOwner.Weapon).MagAmmoRemaining;
		}
		else if ( HuskGunNew(PawnOwner.Weapon) != none )
		{
			ClipsDigits.Value = HuskGunNew(PawnOwner.Weapon).HuskGunChargeBar();
		}

        if ( PlayerGrenade == none )
        {
                FindPlayerGrenade();
        }

        if ( PlayerGrenade != none )
        {
                PlayerGrenade.GetAmmoCount(MaxGren, CurGren);
                GrenadeDigits.Value = CurGren;
        }
        else
        {
                GrenadeDigits.Value = 0;
        }

        HealthDigits.Value = PawnOwner.Health;
        ArmorDigits.Value = xPawn(PawnOwner).ShieldStrength;
		ZedTimeDigits.Value = SRPlayerReplicationInfo(PawnOwner.Controller.PlayerReplicationInfo).ZedTimeCharge;

        // "Poison" the health meter
        if ( VomitHudTimer > Level.TimeSeconds )
        {
                HealthDigits.Tints[0].R = 196;
                HealthDigits.Tints[0].G = 206;
                HealthDigits.Tints[0].B = 0;

                HealthDigits.Tints[1].R = 196;
                HealthDigits.Tints[1].G = 206;
                HealthDigits.Tints[1].B = 0;
        }
        else if ( PawnOwner.Health < 25 )
        {
                if ( Level.TimeSeconds < SwitchDigitColorTime )
                {
                        HealthDigits.Tints[0].R = 0;
                        HealthDigits.Tints[0].G = 0;
                        HealthDigits.Tints[0].B = 0;

                        HealthDigits.Tints[1].R = 0;
                        HealthDigits.Tints[1].G = 0;
                        HealthDigits.Tints[1].B = 0;
                }
                else
                {
                        HealthDigits.Tints[0].R = 255;
                        HealthDigits.Tints[0].G = 0;
                        HealthDigits.Tints[0].B = 0;

                        HealthDigits.Tints[1].R = 255;
                        HealthDigits.Tints[1].G = 0;
                        HealthDigits.Tints[1].B = 0;

                        if ( Level.TimeSeconds > SwitchDigitColorTime + 0.2 )
                        {
                                SwitchDigitColorTime = Level.TimeSeconds + 0.2;
                        }
                }
        }
		else if ( PawnOwner.Health < 35 )
        {
            HealthDigits.Tints[0].R = 255;
            HealthDigits.Tints[0].G = 0;
            HealthDigits.Tints[0].B = 0;

            HealthDigits.Tints[1].R = 255;
            HealthDigits.Tints[1].G = 0;
            HealthDigits.Tints[1].B = 0;
        }
		else if ( PawnOwner.Health < 70 )
        {
            HealthDigits.Tints[0].R = 255;
            HealthDigits.Tints[0].G = 255;
            HealthDigits.Tints[0].B = 0;

            HealthDigits.Tints[1].R = 255;
            HealthDigits.Tints[1].G = 255;
            HealthDigits.Tints[1].B = 0;
        }
        else
        {
                HealthDigits.Tints[0].R = 0;
                HealthDigits.Tints[0].G = 255;
                HealthDigits.Tints[0].B = 0;

                HealthDigits.Tints[1].R = 0;
                HealthDigits.Tints[1].G = 255;
                HealthDigits.Tints[1].B = 0;
        }



        CashDigits.Value = PawnOwnerPRI.Score;

        WelderDigits.Value = 100 * (CurAmmoPrimary / MaxAmmoPrimary);
        SyringeDigits.Value = WelderDigits.Value;

        if ( SyringeDigits.Value < 50 )
        {
                SyringeDigits.Tints[0].R = 128;
                SyringeDigits.Tints[0].G = 128;
                SyringeDigits.Tints[0].B = 128;

                SyringeDigits.Tints[1] = SyringeDigits.Tints[0];
        }
        else if ( SyringeDigits.Value < 100 )
        {
                SyringeDigits.Tints[0].R = 192;
                SyringeDigits.Tints[0].G = 96;
                SyringeDigits.Tints[0].B = 96;

                SyringeDigits.Tints[1] = SyringeDigits.Tints[0];
        }
        else
        {
                SyringeDigits.Tints[0].R = 255;
                SyringeDigits.Tints[0].G = 64;
                SyringeDigits.Tints[0].B = 64;

                SyringeDigits.Tints[1] = SyringeDigits.Tints[0];
        }
/*
        if ( bDisplayStimulation )
        {
                S = Syringe(PawnOwner.FindInventoryType(class'Syringe'));
                if ( S != none )
                {
                        QuickSyringeDigits.Value = S.ChargeBar() * 100;

                        if ( QuickSyringeDigits.Value < 50 )
                        {
                                QuickSyringeDigits.Tints[0].R = 128;
                                QuickSyringeDigits.Tints[0].G = 128;
                                QuickSyringeDigits.Tints[0].B = 128;

                                QuickSyringeDigits.Tints[1] = QuickSyringeDigits.Tints[0];
                        }
                        else if ( QuickSyringeDigits.Value < 100 )
                        {
                                QuickSyringeDigits.Tints[0].R = 192;
                                QuickSyringeDigits.Tints[0].G = 96;
                                QuickSyringeDigits.Tints[0].B = 96;

                                QuickSyringeDigits.Tints[1] = QuickSyringeDigits.Tints[0];
                        }
                        else
                        {
                                QuickSyringeDigits.Tints[0].R = 255;
                                QuickSyringeDigits.Tints[0].G = 64;
                                QuickSyringeDigits.Tints[0].B = 64;

                                QuickSyringeDigits.Tints[1] = QuickSyringeDigits.Tints[0];
                        }
                }
        }
*/

        // Hints
        if ( PawnOwner.Health <= 50 )
        {
                KFPlayerController(PlayerOwner).CheckForHint(51);
        }

        //Super.UpdateHud();
}

//--------------------------------------------------------------------------------------------------
// For debugging headshots
simulated function DrawHeadShotSphere() // Dave@Psyonix
{
    local KFMonster KFM;
    local coords CO;
    local vector HeadLoc;

    //super.DrawHeadShotSphere();
	ClearStayingDebugLines();
    foreach DynamicActors(class'KFMonster', KFM)
    {
        if( KFM != none )
        {
			CO = KFM.GetBoneCoords(KFM.HeadBone);
			HeadLoc = CO.Origin + (float(KFM.GetPropertyText("ZQHeadHeight")) * KFM.HeadScale * CO.XAxis);
			//HeadLoc = CO.Origin + (KFM.HeadHeight * KFM.HeadScale * CO.XAxis);
			DrawStayingDebugSphere(HeadLoc, KFM.HeadRadius * KFM.HeadScale, 10, 0, 255, 0);
        }
    }
}

//--------------------------------------------------------------------------------------------------
simulated function DrawStayingDebugSphere(vector Base, float Radius, int NumDivisions, byte R, byte G, byte B)
{
	local float AngleDelta;
	local int SideIndex;
	local float	SegmentDist;
	local float TempZ;
	local vector UsedBase;

	AngleDelta = 2.0f * PI / NumDivisions;
	SegmentDist = 2.0 * Radius / NumDivisions;

	// Horizontal circles change in scale
	for( SideIndex = -NumDivisions/2; SideIndex < NumDivisions/2; SideIndex++)
	{
		TempZ = SideIndex*SegmentDist;
		UsedBase = Base;// - vect(0,0,TempZ);
		UsedBase.Z -= TempZ;
        DrawStayingDebugCircle(UsedBase, vect(1,0,0), vect(0,1,0), R,G,B, Sqrt(Radius*Radius - SideIndex*SegmentDist*SideIndex*SegmentDist), NumDivisions);
	}

	// Vertical circles change in angle
	for(SideIndex = 0; SideIndex < NumDivisions; SideIndex++)
	{
		DrawStayingDebugCircle(Base, vect(0,0,1), vect(1,0,0) * Cos(AngleDelta * SideIndex) + vect(0,1,0) * Sin(AngleDelta * SideIndex),  R,G,B, Radius, NumDivisions);
	}
}

//--------------------------------------------------------------------------------------------------
simulated function DrawStayingDebugCircle(vector Base,vector X,vector Y, byte R, byte G, byte B,float Radius,int NumSides)
{
	local float AngleDelta;
	local int SideIndex;
	local vector LastVertex, Vertex;

	AngleDelta = 2.0f * PI / NumSides;
	LastVertex = Base + X * Radius;

	for(SideIndex = 0;SideIndex < NumSides;SideIndex++)
	{
		Vertex = Base + (X * Cos(AngleDelta * (SideIndex + 1)) + Y * Sin(AngleDelta * (SideIndex + 1))) * Radius;

		DrawStayingDebugLine(LastVertex,Vertex,R,G,B);

		LastVertex = Vertex;
	}
}

//--------------------------------------------------------------------------------------------------
function DrawPlayerInfo(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY)
{
	local int k;
	local color tClr;
	local SRPlayerReplicationInfo.ClanData cData;
	local SRPlayerReplicationInfo sPRI,SRPRI;
	
	local float XL, YL, TempX, TempY, TempSize, sXL, sYL, tXL, tYL;
	local string PlayerName, pClanName;
	local float Dist, OffsetX;
	local byte BeaconAlpha,Counter;
	local float OldZ;
	local Material TempMaterial, TempStarMaterial;
	local byte i, TempLevel;
	local string AdminPost,ClanName;
	local float Offset, nameOffsetY, pClanOffsetY, clanOffsetY, AdminOffsetY;
	local string S;

	if ( KFPlayerReplicationInfo(P.PlayerReplicationInfo) == none || KFPRI == none || KFPRI.bViewingMatineeCinematic )
	{
		return;
	}
	
	SPRI = SRPlayerReplicationInfo(P.PlayerReplicationInfo);
	SRPRI = SPRI;

	Dist = vsize(P.Location - PlayerOwner.CalcViewLocation);
	Dist -= HealthBarFullVisDist;
	Dist = FClamp(Dist, 0, HealthBarCutoffDist-HealthBarFullVisDist);
	Dist = Dist / (HealthBarCutoffDist - HealthBarFullVisDist);
	BeaconAlpha = byte((1.f - Dist) * 255.f);

	if ( BeaconAlpha == 0 )
	{
		return;
	}

	OldZ = C.Z;
	Offset = 0.0;
	C.Z = 1.0;
	C.Style = ERenderStyle.STY_Alpha;
	C.SetDrawColor(255/*SRPRI.NR*/, 255/*SRPRI.NG*/, 255/*SRPRI.NB*/, BeaconAlpha);
	C.Font = GetConsoleFont(C);
	PlayerName = Left(P.PlayerReplicationInfo.PlayerName, 16);
	C.StrLen(PlayerName, XL, YL);
	nameOffsetY=YL * 0.3;
	C.SetPos(ScreenLocX - (XL * 0.5), ScreenLocY - (YL * 0.75) + nameOffsetY);
	/*C.StrLen(PlayerName, XL, YL);
	C.SetPos(ScreenLocX - (XL * 0.5), ScreenLocY - (YL * 0.75));*/
	C.DrawTextClipped(PlayerName);
	
	//Draw Clan name
	pClanName = SRPlayerReplicationInfo(P.PlayerReplicationInfo).ClanName;
	if ( pClanName != "" )
	{
		Offset += YL * 0.85;
		C.Font = GetNewConsoleFont(C,2);
		C.SetDrawColor(32, 32, 255, BeaconAlpha);
		C.StrLen(pClanName, XL, YL);
		pClanOffsetY=YL * 0.1;
		C.SetPos(ScreenLocX - (XL * 0.5), ScreenLocY - (YL * 0.75) + Offset + pClanOffsetY);
	
		/*C.StrLen(pClanName, XL, YL);
		C.SetPos(ScreenLocX - (XL * 0.5), ScreenLocY - (YL * 0.75) + Offset);*/
		C.DrawTextClipped(pClanName);
	}
	
	Offset = 0.0;
	
//	Clan Tags

	ClanName = SRPRI.ClanTag;
	
	if ( ClanName != "" )
	{
		Offset += YL * 0.85;
		C.Font = GetNewConsoleFont(C,2);
		C.SetDrawColor(SRPRI.CR, SRPRI.CG, SRPRI.CB, BeaconAlpha);
		/*C.StrLen(ClanName, XL, YL);
		C.SetPos(ScreenLocX - (XL * 0.5), ScreenLocY - (YL * 0.75) + Offset);*/
		C.StrLen(ClanName, XL, YL);
		clanOffsetY=YL * 0.1;
		C.SetPos(ScreenLocX - (XL * 0.5), ScreenLocY - (YL * 0.75) + Offset + clanOffsetY);
		C.DrawTextClipped(ClanName);
	}
	
// Admin Tags

	AdminPost = SRPRI.PostTag;
	
	if ( AdminPost != "" )
	{
		if ( Blink )
		{
			C.SetDrawColor(SRPRI.PR1, SRPRI.PG1, SRPRI.PB1, BeaconAlpha);
		}
		else
		{
			C.SetDrawColor(SRPRI.PR2, SRPRI.PG2, SRPRI.PB2, BeaconAlpha);
		}
		Offset += YL * 0.85;
		C.Font = GetNewConsoleFont(C,2);
		C.StrLen(AdminPost, XL, YL);
		AdminOffsetY=YL * 0.1;
		C.SetPos(ScreenLocX - (XL * 0.5), ScreenLocY - (YL * 0.75) + Offset + AdminOffsetY);
		//C.SetPos(ScreenLocX - (XL * 0.5), ScreenLocY - (YL * 0.75) + Offset);
		C.DrawTextClipped(AdminPost);
	}
	
	C.SetDrawColor(255, 255, 255, BeaconAlpha);

	OffsetX = (36.f * VeterancyMatScaleFactor * 0.6) - (HealthIconSize + 2.0);

	if ( Class<SRVeterancyTypes>(KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkill)!=none )
	{
		TempLevel = Class<SRVeterancyTypes>(KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkill).Static.PreDrawPerk(C,
					KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkillLevel,
					TempMaterial,TempStarMaterial);

		TempSize = 36.f * VeterancyMatScaleFactor;
		TempX = ScreenLocX + ((BarLength + HealthIconSize) * 0.5) - (TempSize * 0.25) - OffsetX;
//		if (KFPlayerReplicationInfo(P.PlayerReplicationInfo).ClientVeteranSkillLevel > 24)
//			TempX+=5;
		TempY = ScreenLocY - YL - (TempSize * 0.75);

		C.SetPos(TempX, TempY);
		C.DrawTile(TempMaterial, TempSize, TempSize, 0, 0, TempMaterial.MaterialUSize(), TempMaterial.MaterialVSize());

		TempX += (TempSize - (VetStarSize * 0.75));
		TempY += (TempSize - (VetStarSize * 1.5));

		for ( i = 0; i < TempLevel; i++ )
		{
			C.SetPos(TempX, TempY-(Counter*VetStarSize*0.7f));
			C.DrawTile(TempStarMaterial, VetStarSize * 0.7, VetStarSize * 0.7, 0, 0, TempStarMaterial.MaterialUSize(), TempStarMaterial.MaterialVSize());

			if( ++Counter==5 )
			{
				Counter = 0;
				TempX+=VetStarSize;
			}
		}
	}
	
	// Clan Icon
	C.Style = ERenderStyle.STY_Alpha;
	C.SetDrawColor(255, 255, 255, BeaconAlpha);

	sPRI = SRPlayerReplicationInfo(P.PlayerReplicationInfo);
	cData = sPRI.myClanData;
	if(	cData.ClanTexture!="" )
	{
		TempMaterial=Texture(DynamicLoadObject(cData.ClanTexture,class'Texture'));
		if (TempMaterial!=none)
		{
			if (Caps(cData.pos)=="LEFT")
			{
				TempX = ScreenLocX - cData.ClanTextureW - 62;
				TempY = ScreenLocY - cData.ClanTextureH/2 - 34;
				C.SetPos(TempX, TempY);
				C.DrawTile(TempMaterial,cData.ClanTextureW,cData.ClanTextureH,0,0,TempMaterial.MaterialUSize(),TempMaterial.MaterialVSize());
			}
			else if (Caps(cData.pos)=="UPSIDE")
			{
				TempX = ScreenLocX + BarLength/2 - 14 - cData.ClanTextureW;
				TempY = ScreenLocY -  41 - cData.ClanTextureH;
				C.SetPos(TempX, TempY);
				C.DrawTile(TempMaterial,cData.ClanTextureW,cData.ClanTextureH,0,0,TempMaterial.MaterialUSize(),TempMaterial.MaterialVSize());
			}			
			else if (Caps(cData.pos)=="NICKR")
			{
				if (cData.bBrackets)
				{
					tClr = C.DrawColor;
					C.SetDrawColor(255, 0, 0, BeaconAlpha);
					TempX=ScreenLocX + (XL * 0.5) + 2;
					TempY=ScreenLocY - (YL * 0.75);
					C.SetPos(TempX, TempY);
					C.DrawText("[");

					C.StrLen("[", tXL, tYL);
					
					C.SetDrawColor(tClr.R, tClr.G, tClr.B, tClr.A);
					
					TempX = TempX+tXL;
					TempY = ScreenLocY - (YL * 0.75) + 12; // nick center
					C.SetPos(TempX, TempY - cData.ClanTextureH/2);
					C.DrawTile(TempMaterial,cData.ClanTextureW,cData.ClanTextureH,1,1,TempMaterial.MaterialUSize()-2,TempMaterial.MaterialVSize()-2);
					
					C.SetDrawColor(255, 0, 0, BeaconAlpha);
					
					C.SetPos(TempX+cData.ClanTextureW+2, ScreenLocY - (YL * 0.75) );
					C.DrawText("]");
					
					C.SetDrawColor(tClr.R, tClr.G, tClr.B, tClr.A);
				}
				else
				{
					TempX = ScreenLocX + (XL*0.5) + 2;
					TempY = ScreenLocY - (YL * 0.75) + 12;
					C.SetPos(TempX, TempY - cData.ClanTextureH/2);
					C.DrawTile(TempMaterial,cData.ClanTextureW,cData.ClanTextureH,0,0,TempMaterial.MaterialUSize(),TempMaterial.MaterialVSize());
				}
			}
			else if (Caps(cData.pos)=="NICKL")
			{
				if (cData.bBrackets)
				{
					tClr = C.DrawColor;
					C.StrLen("]", tXL, tYL);
					C.SetDrawColor(255, 0, 0, BeaconAlpha);
					TempX=ScreenLocX - (XL * 0.5) - 2 - tXL;
					TempY=ScreenLocY - (YL * 0.75);
					C.SetPos(TempX, TempY);
					C.DrawText("]");
			
					C.SetDrawColor(tClr.R, tClr.G, tClr.B, tClr.A);
					
					TempX = TempX-cData.ClanTextureW-2;
					TempY = ScreenLocY - (YL * 0.75) + 12; // nick center
					C.SetPos(TempX, TempY - cData.ClanTextureH/2);
					C.DrawTile(TempMaterial,cData.ClanTextureW,cData.ClanTextureH,1,1,TempMaterial.MaterialUSize()-2,TempMaterial.MaterialVSize()-2);
					
					C.SetDrawColor(255, 0, 0, BeaconAlpha);
					
					C.StrLen("[", tXL, tYL);
					C.SetPos(TempX-tXL-2, ScreenLocY - (YL * 0.75) );
					C.DrawText("[");
					
					C.SetDrawColor(tClr.R, tClr.G, tClr.B, tClr.A);
				}
				else
				{
					//C.StrLen(PlayerName, XL, YL);
					TempX = ScreenLocX - (XL*0.5) - 2 - cData.ClanTextureW;
					TempY = ScreenLocY - (YL * 0.75) + 12;
					C.SetPos(TempX, TempY - cData.ClanTextureH/2);
					C.DrawTile(TempMaterial,cData.ClanTextureW,cData.ClanTextureH,0,0,TempMaterial.MaterialUSize(),TempMaterial.MaterialVSize());
				}
			}
		}
	}
//--------------------------------------------------------------------------------------------------

	// Health
	if ( P.Health > 0 )
		DrawKFBar(C, ScreenLocX - OffsetX, (ScreenLocY - YL) - 0.4 * BarHeight, P.Health / P.HealthMax, BeaconAlpha);

	// Armor
	if ( P.ShieldStrength > 0 )
	{
		DrawKFBar(C, ScreenLocX - OffsetX, (ScreenLocY - YL) - 1.5 * BarHeight, P.ShieldStrength / 100.0, BeaconAlpha, true);
		
		if ( SRPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill == class'SRVetJuggernaut' 
		|| SRPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill == class'SRVetJuggernautHZD'  )
		{
			DrawAmmoBar(C, ScreenLocX - OffsetX, (ScreenLocY - YL) - 2.4 * BarHeight, float(SRPRI.AmmoStatus), BeaconAlpha);
		}
	}
	else
	{
		if ( SRPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill == class'SRVetJuggernaut' 
		|| SRPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill == class'SRVetJuggernautHZD' )
		{
			DrawAmmoBar(C, ScreenLocX - OffsetX, (ScreenLocY - YL) - 1.5 * BarHeight, float(SRPRI.AmmoStatus), BeaconAlpha);
		}
	}
	/*if ( P.ShieldStrength > 0 )
		DrawKFBar(C, ScreenLocX - OffsetX, (ScreenLocY - YL) - 1.5 * BarHeight, P.ShieldStrength / 100.0, BeaconAlpha, true);*/

	C.Z = OldZ;
}

simulated function DrawModOverlay( Canvas C )
{
	local float MaxRBrighten, MaxGBrighten, MaxBBrighten;

	// We want the overlay to start black, and fade in, almost like the player opened their eyes
	// BrightFactor = 1.5;   // Not too bright.  Not too dark.  Livens things up just abit
	// Hook for Optional Vision overlay.  - Alex

	if( PawnOwner==None )
	{
		if( CurrentZone!=None || CurrentVolume!=None ) // Reset everything.
		{
			LastR = 0;
    			LastG = 0;
    			LastB = 0;
			CurrentZone = None;
			LastZone = None;
			CurrentVolume = None;
			LastVolume = None;
			bZoneChanged = false;
			SetTimer(0.f, false);
		}
		VisionOverlay = default.VisionOverlay;

		// Dead Players see Red
		if( !PlayerOwner.IsSpectating() )
		{
			C.SetDrawColor(255, 255, 255, GrainAlpha);
			C.DrawTile(SpectatorOverlay, C.SizeX, C.SizeY, 0, 0, 1024, 1024);
		}
		return;
	}

	C.SetPos(0, 0);

	// if critical, pulsate.  otherwise, dont.
	if ( (PlayerOwner.Pawn==PawnOwner || !PlayerOwner.bBehindView) && Vehicle(PawnOwner)==None && PawnOwner.Health>0 && PawnOwner.Health<(PawnOwner.HealthMax*0.25) )
		VisionOverlay = NearDeathOverlay;
	else VisionOverlay = default.VisionOverlay;

	// Players can choose to turn this feature off completely.
	// conversely, setting bDistanceFog = false in a Zone
	//will cause the code to ignore that zone for a shift in RGB tint
	if ( KFLevelRule != none && !KFLevelRule.bUseVisionOverlay )
		return;

	// here we determine the maximum "brighten" amounts for each value.  CANNOT exceed 255
	MaxRBrighten = Round(LastR* (1.0 - (LastR / 255)) - 2) ;
	MaxGBrighten = Round(LastG* (1.0 - (LastG / 255)) - 2) ;
	MaxBBrighten = Round(LastB* (1.0 - (LastB / 255)) - 2) ;

	C.SetDrawColor(LastR + MaxRBrighten, LastG + MaxGBrighten, LastB + MaxBBrighten, GrainAlpha);
	C.DrawTileScaled(VisionOverlay, C.SizeX, C.SizeY);  //,0,0,1024,1024);

	// Here we change over the Zone.
	// What happens of importance is
	// A.  Set Old Zone to current
	// B.  Set New Zone
	// C.  Set Color info up for use by Tick()

	// if we're in a new zone or volume without distance fog...just , dont touch anything.
	// the physicsvolume check is abit screwy because the player is always in a volume called "DefaultPhyicsVolume"
	// so we've gotta make sure that the return checks take this into consideration.

	// This block of code here just makes sure that if we've already got a tint, and we step into a zone/volume without
	// bDistanceFog, our current tint is not affected.
	// a.  If I'm in a zone and its not bDistanceFog. AND IM NOT IN A PHYSICSVOLUME. Just a zone.
	// b.  If I'm in a Volume
	if ( !PawnOwner.Region.Zone.bDistanceFog &&
		 DefaultPhysicsVolume(PawnOwner.PhysicsVolume)==None && !PawnOwner.PhysicsVolume.bDistanceFog )
		return;

	if ( !bZoneChanged )
	{
		// Grab the most recent zone info from our PRI
		// Only update if it's different
		// EDIT:  AND HAS bDISTANCEFOG true
		if ( CurrentZone!=PawnOwner.Region.Zone || (DefaultPhysicsVolume(PawnOwner.PhysicsVolume) == None &&
			 CurrentVolume != PawnOwner.PhysicsVolume) )
		{
			if ( CurrentZone != none )
				LastZone = CurrentZone;
			else if ( CurrentVolume != none )
				LastVolume = CurrentVolume;

			// This is for all occasions where we're either in a Levelinfo handled zone
			// Or a zoneinfo.
			// If we're in a LevelInfo / ZoneInfo  and NOT touching a Volume.  Set current Zone
			if ( PawnOwner.Region.Zone.bDistanceFog && DefaultPhysicsVolume(PawnOwner.PhysicsVolume)!= none && !PawnOwner.Region.Zone.bNoKFColorCorrection )
			{
				CurrentVolume = none;
				CurrentZone = PawnOwner.Region.Zone;
			}
			else if ( DefaultPhysicsVolume(PawnOwner.PhysicsVolume) == None && PawnOwner.PhysicsVolume.bDistanceFog && !PawnOwner.PhysicsVolume.bNoKFColorCorrection)
			{
				CurrentZone = none;
				CurrentVolume = PawnOwner.PhysicsVolume;
			}

			if ( CurrentVolume != none )
				LastZone = none;
			else if ( CurrentZone != none )
				LastVolume = none;

			if ( LastZone != none )
			{
				if( LastZone.bNewKFColorCorrection )
				{
					LastR = LastZone.KFOverlayColor.R;
    					LastG = LastZone.KFOverlayColor.G;
    					LastB = LastZone.KFOverlayColor.B;
				}
				else
				{
					LastR = LastZone.DistanceFogColor.R;
    					LastG = LastZone.DistanceFogColor.G;
    					LastB = LastZone.DistanceFogColor.B;
				}
			}
			else if ( LastVolume != none )
			{
				if( LastVolume.bNewKFColorCorrection )
				{
					LastR = LastVolume.KFOverlayColor.R;
    					LastG = LastVolume.KFOverlayColor.G;
    					LastB = LastVolume.KFOverlayColor.B;
				}
				else
				{
    					LastR = LastVolume.DistanceFogColor.R;
    					LastG = LastVolume.DistanceFogColor.G;
    					LastB = LastVolume.DistanceFogColor.B;
				}
			}
			else if ( LastZone != none && LastVolume != none )
				return;

			if ( LastZone != CurrentZone || LastVolume != CurrentVolume )
			{
				bZoneChanged = true;
				SetTimer(OverlayFadeSpeed, false);
			}
		}
	}
	if ( !bTicksTurn && bZoneChanged )
	{
		// Pass it off to the tick now
		// valueCheckout signifies that none of the three values have been
		// altered by Tick() yet.

		// BOUNCE IT BACK! :D
		ValueCheckOut = 0;
		bTicksTurn = true;
		SetTimer(OverlayFadeSpeed, false);
	}
}

simulated function DrawEndGameHUD(Canvas C, bool bVictory)
{
	local float Scalar;
	local Shader M;

	C.DrawColor.A = 255;
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	Scalar = FClamp(C.ClipY, 320, 1024);
	C.CurX = C.ClipX / 2 - Scalar / 2;
	C.CurY = C.ClipY / 2 - Scalar / 2;
	C.Style = ERenderStyle.STY_Alpha;

	if ( bVictory )
		M = Shader'KFMapEndTextures.VictoryShader';
	else M = Shader'KFMapEndTextures.DefeatShader';

	C.DrawTile(M, Scalar, Scalar, 0, 0, 1024, 1024);

	if ( bShowScoreBoard && ScoreBoard != None )
		ScoreBoard.DrawScoreboard(C);
}

simulated function DrawHudPassA (Canvas C)
{
	local KFHumanPawn KFHPawn;
	local Material TempMaterial, TempStarMaterial;
	local int i, TempLevel;
	local float TempX, TempY, TempSize;
	local byte Counter;
	local class<SRVeterancyTypes> SV;
	local SRPlayerReplicationInfo SRPRI;

	local string s;

	SRPRI = SRPlayerReplicationInfo(PawnOwner.Controller.PlayerReplicationInfo);
	KFHPawn = KFHumanPawn(PawnOwner);
	
	/*s = (SRPlayerReplicationInfo(KFHPawn.PlayerReplicationInfo)).ClanName;
	C.SetPos(10,10);
	C.DrawTextClipped(s);*/
	
	DrawDoorHealthBars(C);

	if ( !bLightHud )
	{
		DrawSpriteWidget(C, HealthBG);
	}

	DrawSpriteWidget(C, HealthIcon);
	DrawNumericWidget(C, HealthDigits, DigitsSmall);

	if ( !bLightHud )
	{
		DrawSpriteWidget(C, ArmorBG);
	}

	DrawSpriteWidget(C, ArmorIcon);
	DrawNumericWidget(C, ArmorDigits, DigitsSmall);
	
	if ( !bLightHud )
	{
		DrawSpriteWidget(C, ZedTimeBG);
	}

	DrawSpriteWidget(C, ZedTimeIcon);
	DrawNumericWidget(C, ZedTimeDigits, DigitsSmall);
	
	if ( (SRPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill == class'SRVetPhantom' || SRPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill == class'SRVetPhantomHZD')
		|| SRHumanPawn(PawnOwner) != none && SRHumanPawn(PawnOwner).bInvisible )
	{
		if ( class<SRVetPhantom>(SRPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill) != none
			&& class<SRVeterancyTypes>(SRPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill).Static.DecapCountPerWave(PawnOwnerPRI) > 0 )
		{
			if ( !bLightHud )
			{
				DrawSpriteWidget(C, InvisDecapBG);
			}
			
			DrawSpriteWidget(C, InvisDecapIcon);
			InvisDecapDigits.Value = SRPlayerReplicationInfo(PawnOwnerPRI).DecapCount;
			DrawNumericWidget(C, InvisDecapDigits, DigitsSmall);
		}
		
		if ( !bLightHud )
		{
			DrawSpriteWidget(C, InvisBG);
		}
		
		if ( SRHumanPawn(PawnOwner).bInvisible )
		{
			DrawSpriteWidget(C, InvisIcon);
			InvisDigits.Value = SRPlayerReplicationInfo(PawnOwnerPRI).InvisTimeHUD;
		}
		else
		{
			DrawSpriteWidget(C, InvisOffIcon);
			InvisDigits.Value = SRPlayerReplicationInfo(PawnOwnerPRI).InvisCooldown;
		}
		DrawNumericWidget(C, InvisDigits, DigitsSmall);
		
		if ( SRPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill == class'SRVetPhantom' || SRPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill == class'SRVetPhantomHZD' )
		{
			if ( !bLightHud )
			{
				DrawSpriteWidget(C, InvisTimesBG);
			}
			DrawSpriteWidget(C, InvisTimesIcon);
			InvisTimesDigits.Value = Max(0,SRPlayerReplicationInfo(PawnOwnerPRI).InvisCount);
			DrawNumericWidget(C, InvisTimesDigits, DigitsSmall);
		}
		
		if ( SRHumanPawn(PawnOwner) != none && SRHumanPawn(PawnOwner).bInvisible )
		{
			DrawSpottedBar(C,(SRPlayerReplicationInfo(PawnOwnerPRI).InvisAlarmLevelHUD/100.0)/(SRPlayerReplicationInfo(PawnOwnerPRI).InvisAlarmLimitHUD/100.0));
		}
	}

	if ( KFHPawn != none )
	{
		C.SetPos(C.ClipX * WeightBG.PosX, C.ClipY * WeightBG.PosY);

		if ( !bLightHud )
		{
			C.DrawTile(WeightBG.WidgetTexture, WeightBG.WidgetTexture.MaterialUSize() * WeightBG.TextureScale * 1.5 * HudCanvasScale * ResScaleX * HudScale, WeightBG.WidgetTexture.MaterialVSize() * WeightBG.TextureScale * HudCanvasScale * ResScaleY * HudScale, 0, 0, WeightBG.WidgetTexture.MaterialUSize(), WeightBG.WidgetTexture.MaterialVSize());
		}

		DrawSpriteWidget(C, WeightIcon);

		C.Font = LoadSmallFontStatic(5);
		C.FontScaleX = C.ClipX / 1024.0;
		C.FontScaleY = C.FontScaleX;
		C.SetPos(C.ClipX * WeightDigits.PosX, C.ClipY * WeightDigits.PosY);
		C.DrawColor = WeightDigits.Tints[0];
		C.DrawText(int(KFHPawn.CurrentWeight)$"/"$int(KFHPawn.MaxCarryWeight));
		C.FontScaleX = 1;
		C.FontScaleY = 1;
	}

	if ( !bLightHud )
	{
		DrawSpriteWidget(C, GrenadeBG);
	}

	if ( SRPlayerReplicationInfo(PawnOwner.Controller.PlayerReplicationInfo).ClientVeteranSkill == class'SRVetJuggernaut' ||
	SRPlayerReplicationInfo(PawnOwner.Controller.PlayerReplicationInfo).ClientVeteranSkill == class'SRVetJuggernautHZD' )
	{
		DrawSpriteWidget(C, AmmoboxIcon);
	}
	else if ( SRPlayerReplicationInfo(PawnOwner.Controller.PlayerReplicationInfo).ClientVeteranSkill == class'SRVetFieldMedic' 
	|| SRPlayerReplicationInfo(PawnOwner.Controller.PlayerReplicationInfo).ClientVeteranSkill == class'SRVetFieldMedicHZD' )
	{
		DrawSpriteWidget(C, MedkitIcon);
	}
	else
	{
		DrawSpriteWidget(C, GrenadeIcon);
	}
	DrawNumericWidget(C, GrenadeDigits, DigitsSmall);

	if ( PawnOwner != none && PawnOwner.Weapon != none )
	{
		if ( NewSyringe(PawnOwner.Weapon) != none )
		{
			if ( !bLightHud )
			{
				DrawSpriteWidget(C, SyringeBG);
			}

			DrawSpriteWidget(C, SyringeIcon);
			DrawNumericWidget(C, SyringeDigits, DigitsSmall);
		}
		else
		{
			if ( bDisplayQuickSyringe )
			{
				TempSize = Level.TimeSeconds - QuickSyringeStartTime;
				if ( TempSize < QuickSyringeDisplayTime )
				{
					if ( TempSize < QuickSyringeFadeInTime )
					{
						QuickSyringeBG.Tints[0].A = int((TempSize / QuickSyringeFadeInTime) * 255.0);
						QuickSyringeBG.Tints[1].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[0].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[1].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[0].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[1].A = QuickSyringeBG.Tints[0].A;
					}
					else if ( TempSize > QuickSyringeDisplayTime - QuickSyringeFadeOutTime )
					{
						QuickSyringeBG.Tints[0].A = int((1.0 - ((TempSize - (QuickSyringeDisplayTime - QuickSyringeFadeOutTime)) / QuickSyringeFadeOutTime)) * 255.0);
						QuickSyringeBG.Tints[1].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[0].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[1].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[0].A = QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[1].A = QuickSyringeBG.Tints[0].A;
					}
					else
					{
						QuickSyringeBG.Tints[0].A = 255;
						QuickSyringeBG.Tints[1].A = 255;
						QuickSyringeIcon.Tints[0].A = 255;
						QuickSyringeIcon.Tints[1].A = 255;
						QuickSyringeDigits.Tints[0].A = 255;
						QuickSyringeDigits.Tints[1].A = 255;
					}

					if ( !bLightHud )
					{
						DrawSpriteWidget(C, QuickSyringeBG);
					}

					DrawSpriteWidget(C, QuickSyringeIcon);
					DrawNumericWidget(C, QuickSyringeDigits, DigitsSmall);
				}
				else
				{
					bDisplayQuickSyringe = false;
				}
			}

    		if ( MP7MMedicGun(PawnOwner.Weapon) != none )
    		{

                MedicGunDigits.Value = MP7MMedicGun(PawnOwner.Weapon).ChargeBar() * 100;

            	if ( MedicGunDigits.Value < 50 )
            	{
            		MedicGunDigits.Tints[0].R = 128;
            		MedicGunDigits.Tints[0].G = 128;
            		MedicGunDigits.Tints[0].B = 128;

            		MedicGunDigits.Tints[1] = SyringeDigits.Tints[0];
            	}
            	else if ( MedicGunDigits.Value < 100 )
            	{
            		MedicGunDigits.Tints[0].R = 192;
            		MedicGunDigits.Tints[0].G = 96;
            		MedicGunDigits.Tints[0].B = 96;

            		MedicGunDigits.Tints[1] = SyringeDigits.Tints[0];
            	}
            	else
            	{
            		MedicGunDigits.Tints[0].R = 255;
            		MedicGunDigits.Tints[0].G = 64;
            		MedicGunDigits.Tints[0].B = 64;

            		MedicGunDigits.Tints[1] = MedicGunDigits.Tints[0];
            	}

    			if ( !bLightHud )
    			{
    				DrawSpriteWidget(C, MedicGunBG);
    			}

    			DrawSpriteWidget(C, MedicGunIcon);
    			DrawNumericWidget(C, MedicGunDigits, DigitsSmall);
    		}

    		if ( MP7MMedicGunM(PawnOwner.Weapon) != none )
    		{

                MedicGunDigits.Value = MP7MMedicGunM(PawnOwner.Weapon).ChargeBar() * 100;

            	if ( MedicGunDigits.Value < 50 )
            	{
            		MedicGunDigits.Tints[0].R = 128;
            		MedicGunDigits.Tints[0].G = 128;
            		MedicGunDigits.Tints[0].B = 128;

            		MedicGunDigits.Tints[1] = SyringeDigits.Tints[0];
            	}
            	else if ( MedicGunDigits.Value < 100 )
            	{
            		MedicGunDigits.Tints[0].R = 192;
            		MedicGunDigits.Tints[0].G = 96;
            		MedicGunDigits.Tints[0].B = 96;

            		MedicGunDigits.Tints[1] = SyringeDigits.Tints[0];
            	}
            	else
            	{
            		MedicGunDigits.Tints[0].R = 255;
            		MedicGunDigits.Tints[0].G = 64;
            		MedicGunDigits.Tints[0].B = 64;

            		MedicGunDigits.Tints[1] = MedicGunDigits.Tints[0];
            	}

    			if ( !bLightHud )
    			{
    				DrawSpriteWidget(C, MedicGunBG);
    			}

    			DrawSpriteWidget(C, MedicGunIcon);
    			DrawNumericWidget(C, MedicGunDigits, DigitsSmall);
    		}

			if ( WelderExP(PawnOwner.Weapon) != none 
			|| WelderEx(PawnOwner.Weapon) != none 
			|| AxeM(PawnOwner.Weapon) != none 
			|| FireDragon(PawnOwner.Weapon) != none
			|| Ninjato(PawnOwner.Weapon) != none 
			|| KhukuriLLI(PawnOwner.Weapon) != none 
			|| CrossLLI(PawnOwner.Weapon) != none 
			|| AN94KnifeSA(PawnOwner.Weapon) != none 
			|| SKLLI(PawnOwner.Weapon) != none 
			|| KukriFLLI(PawnOwner.Weapon) != none 
			|| FrostSword(PawnOwner.Weapon) != none
			|| NinjatoInf(PawnOwner.Weapon) != none 
			|| GreatswordLLIInf(PawnOwner.Weapon) != none 
			|| Dagger(PawnOwner.Weapon) != none 
			|| TsuguriLLI(PawnOwner.Weapon) != none
			|| CucumberLLI(PawnOwner.Weapon) != none 
			|| AvengerLLIM(PawnOwner.Weapon) != none 
			|| MurasamaDT(PawnOwner.Weapon) != none 
			|| InfernoLLI(PawnOwner.Weapon) != none
			|| EmpireSword(PawnOwner.Weapon) != none
			|| PurifierSword(PawnOwner.Weapon) != none
			|| EbBulava(PawnOwner.Weapon) != none 
			|| Ravager(PawnOwner.Weapon) != none 
			|| PyramidBladeLLI(PawnOwner.Weapon) != none )
			{
				if ( ( (AxeM(PawnOwner.Weapon) != none 
				|| FireDragon(PawnOwner.Weapon) != none 
				|| Ninjato(PawnOwner.Weapon) != none 
				|| AvengerLLIM(PawnOwner.Weapon) != none
				|| AvengerLLIW(PawnOwner.Weapon) != none 
				|| FrostSword(PawnOwner.Weapon) != none 
				|| InfernoLLI(PawnOwner.Weapon) != none  
				|| EmpireSword(PawnOwner.Weapon) != none  
				|| PurifierSword(PawnOwner.Weapon) != none
				|| TsuguriLLI(PawnOwner.Weapon) != none
				|| MurasamaDT(PawnOwner.Weapon) != none 
				|| CucumberLLI(PawnOwner.Weapon) != none 
				|| EbBulava(PawnOwner.Weapon) != none) 
				&& (SRPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill == class'SRVetBerserker' 
				|| SRPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill == class'SRVetBerserkerHZD')) 
				|| KhukuriLLI(PawnOwner.Weapon) != none 
				|| KukriFLLI(PawnOwner.Weapon) != none 
				|| CrossLLI(PawnOwner.Weapon) != none
				|| AN94KnifeSA(PawnOwner.Weapon) != none
				|| SKLLI(PawnOwner.Weapon) != none )
				{
					if ( !bLightHud )
					{
						DrawSpriteWidget(C, WelderBG);
					}
					WelderDigits.Value = FMin( 1.0, ( Level.TimeSeconds - SRPRI.JumpIronTime + 4.5 ) / 4.5 ) * 100;
					DrawSpriteWidget(C, WelderIcon);
					DrawNumericWidget(C, WelderDigits, DigitsSmall);
				}
				else if ( ( NinjatoInf(PawnOwner.Weapon) != none 
				|| Dagger(PawnOwner.Weapon) != none 
				|| GreatswordLLIInf(PawnOwner.Weapon) != none 
				|| Ravager(PawnOwner.Weapon) != none
				|| PyramidBladeLLI(PawnOwner.Weapon) != none ) 
				&& (SRPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill == class'SRVetPhantom' 
				|| SRPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill == class'SRVetPhantomHZD') )
				{
					if ( !bLightHud )
					{
						DrawSpriteWidget(C, WelderBG);
					}
					WelderDigits.Value = FMin( 1.0, ( Level.TimeSeconds - SRMeleeGun(PawnOwner.Weapon).NextIronTime + SRMeleeGun(PawnOwner.Weapon).SpecialAttackCooldown ) / SRMeleeGun(PawnOwner.Weapon).SpecialAttackCooldown ) * 100;
					DrawSpriteWidget(C, WelderIcon);
					DrawNumericWidget(C, WelderDigits, DigitsSmall);
				}
				/*else if ( Ninjato(PawnOwner.Weapon) != none && SRPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill == class'SRVetBerserker' )
				{
					if ( !bLightHud )
					{
						DrawSpriteWidget(C, WelderBG);
					}
					WelderDigits.Value = FMin( 1.0, ( Level.TimeSeconds - Ninjato(PawnOwner.Weapon).NextIronTime + 3.0 ) / 3.0 ) * 100;
					DrawSpriteWidget(C, WelderIcon);
					DrawNumericWidget(C, WelderDigits, DigitsSmall);
				}*/
				else if ( WelderEx(PawnOwner.Weapon) != none 
				|| WelderExP(PawnOwner.Weapon) != none )
				{
					if ( !bLightHud )
					{
						DrawSpriteWidget(C, WelderBG);
					}
					DrawSpriteWidget(C, WelderIcon);
					DrawNumericWidget(C, WelderDigits, DigitsSmall);
				}
			}
			else if ( PawnOwner.Weapon.GetAmmoClass(0) != none )
			{
				if ( !bLightHud )
				{
					DrawSpriteWidget(C, ClipsBG);
				}
                if ( HuskGunNew(PawnOwner.Weapon) != none )       
                {                                              
                    ClipsDigits.PosX = 0.873;
					ClipsDigits.Value = HuskGunNew(PawnOwner.Weapon).HuskGunChargeBar();
					DrawNumericWidget(C, ClipsDigits, DigitsSmall);
					ClipsDigits.PosX = default.ClipsDigits.PosX;
                }
				else
				{
					if ( LAWM(PawnOwner.Weapon) != none || RPG(PawnOwner.Weapon) != none
						|| M79FGrenadeLauncher(PawnOwner.Weapon) != none 
						|| M79FGrenadeLauncher(PawnOwner.Weapon) != none )
					{
						ClipsDigits.Value += 1;
						DrawNumericWidget(C, ClipsDigits, DigitsSmall);
					}
					else
						DrawNumericWidget(C, ClipsDigits, DigitsSmall);
				}
				if ( LAW(PawnOwner.Weapon) != none || LAWM(PawnOwner.Weapon) != none || RPG(PawnOwner.Weapon) != none )
				{
					DrawSpriteWidget(C, LawRocketIcon);
				}
				else if ( Crossbow(PawnOwner.Weapon) != none || CrossbowM(PawnOwner.Weapon) != none )
				{
					DrawSpriteWidget(C, ArrowheadIcon);
				}
				else if ( M79GrenadeLauncher(PawnOwner.Weapon) != none || M79GrenadeLauncherM(PawnOwner.Weapon) != none )
				{
					DrawSpriteWidget(C, M79Icon);
				}
				else if ( FireBombExplosive(PawnOwner.Weapon) != none )
                {
                    DrawSpriteWidget(C, FireBombIcon);
                }
				else if ( PipeBombExplosive(PawnOwner.Weapon) != none ||
				PipeBombExplosiveA(PawnOwner.Weapon) != none ||
				TacticalMineExplosive(PawnOwner.Weapon) != none
						  || SelfDestruct(PawnOwner.Weapon) != none )
				{
                    DrawSpriteWidget(C, PipeBombIcon);
				}
				else if ( HuskGunNew(PawnOwner.Weapon) != none || M79FGrenadeLauncher(PawnOwner.Weapon) != none )   
                {                                               
                    DrawSpriteWidget(C, HuskAmmoIcon);      
                }     
				else
				{
					if ( !bLightHud )
					{
						DrawSpriteWidget(C, BulletsInClipBG);
					}

					DrawNumericWidget(C, BulletsInClipDigits, DigitsSmall);

					if ( Flamethrower(PawnOwner.Weapon) != none 
					|| FlamethrowerM(PawnOwner.Weapon) != none 
					|| TXM8(PawnOwner.Weapon) != none )
					{
						DrawSpriteWidget(C, FlameIcon);
						DrawSpriteWidget(C, FlameTankIcon);
					}
				    else if ( Shotgun(PawnOwner.Weapon) != none || BoomStick(PawnOwner.Weapon) != none || Winchester(PawnOwner.Weapon) != none
					|| ShotgunM(PawnOwner.Weapon) != none || BoomStickM(PawnOwner.Weapon) != none || WinchesterM(PawnOwner.Weapon) != none
					|| toz34Shotgun(PawnOwner.Weapon) != none || Moss12Shotgun(PawnOwner.Weapon) != none || WMediShot(PawnOwner.Weapon) != none
					|| WeldShot(PawnOwner.Weapon) != none || WeldShot(PawnOwner.Weapon) != none || Protecta(PawnOwner.Weapon) != none
					|| Rem870EC(PawnOwner.Weapon) != none
					|| Ashot(PawnOwner.Weapon) != none )
				    {
					    DrawSpriteWidget(C, SingleBulletIcon);
						DrawSpriteWidget(C, BulletsInClipIcon);
				    }
					else
					{
						DrawSpriteWidget(C, ClipsIcon);
						DrawSpriteWidget(C, BulletsInClipIcon);
					}
				}

				if ( KFWeapon(PawnOwner.Weapon) != none && KFWeapon(PawnOwner.Weapon).bTorchEnabled )
				{
					if ( !bLightHud )
					{
						DrawSpriteWidget(C, FlashlightBG);
					}

					DrawNumericWidget(C, FlashlightDigits, DigitsSmall);

					if ( KFWeapon(PawnOwner.Weapon).FlashLight != none && KFWeapon(PawnOwner.Weapon).FlashLight.bHasLight )
					{
						DrawSpriteWidget(C, FlashlightIcon);
					}
					else
					{
						DrawSpriteWidget(C, FlashlightOffIcon);
					}
				}
			}
			// Secondary ammo  ЭТО НУЖНО ДОБАВИТЬ (выделил двойным слэшом)
			if ( KFWeapon(PawnOwner.Weapon) != none && KFWeapon(PawnOwner.Weapon).bHasSecondaryAmmo )
			{
				if ( !bLightHud )
				{
					DrawSpriteWidget(C, SecondaryClipsBG);
				}
				DrawNumericWidget(C, SecondaryClipsDigits, DigitsSmall);
				DrawSpriteWidget(C, SecondaryClipsIcon);
			}
		}
	}

	if( KFPlayerReplicationInfo(PawnOwnerPRI)!=None )
		SV = Class<SRVeterancyTypes>(KFPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill);

	if ( SV!=none )
		SV.Static.SpecialHUDInfo(KFPlayerReplicationInfo(PawnOwnerPRI), C);

	if ( KFSGameReplicationInfo(PlayerOwner.GameReplicationInfo) == none || KFSGameReplicationInfo(PlayerOwner.GameReplicationInfo).bHUDShowCash )
	{
		DrawSpriteWidget(C, CashIcon);
		DrawNumericWidget(C, CashDigits, DigitsBig);
	}

	if ( SV!=None )
	{
//		C.DrawColor.A = 192;
		TempLevel = SV.Static.PreDrawPerk(C,KFPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkillLevel,TempMaterial,TempStarMaterial);

		TempSize = 36 * VeterancyMatScaleFactor * 1.4;
		TempX = C.ClipX * 0.007;
		TempY = C.ClipY * 0.93 - TempSize;
		C.DrawColor = WhiteColor;

		TempLevel = KFPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkillLevel;
		if( ClientRep!=None && (TempLevel+1)<ClientRep.MaximumLevel )
		{
			// Draw progress bar.
			bDisplayingProgress = true;
			if( NextLevelTimer<Level.TimeSeconds )
			{
				NextLevelTimer = Level.TimeSeconds+3.f;
				LevelProgressBar = SV.Static.GetTotalProgress(ClientRep,TempLevel+1);
			}
			C.DrawColor.A = 64;
			C.SetPos(TempX, TempY-TempSize*0.12f);
			C.DrawTileStretched(Texture'thinpipe_b',TempSize*2.f,TempSize*0.1f);
			if( VisualProgressBar>0.f )
			{
				C.DrawColor.A = 150;
				C.SetPos(TempX, TempY-TempSize*0.12f);
				C.DrawTileStretched(Texture'thinpipe_f',TempSize*2.f*VisualProgressBar,TempSize*0.1f);
			}
		}

		C.DrawColor.A = 192;
		TempLevel = SV.Static.PreDrawPerk(C,TempLevel,TempMaterial,TempStarMaterial);

		C.SetPos(TempX, TempY);
		C.DrawTile(TempMaterial, TempSize, TempSize, 0, 0, TempMaterial.MaterialUSize(), TempMaterial.MaterialVSize());

		TempX += (TempSize - VetStarSize);
		TempY += (TempSize - (2.0 * VetStarSize));

		for ( i = 0; i < TempLevel; i++ )
		{
			C.SetPos(TempX, TempY-(Counter*VetStarSize*0.8f));
			C.DrawTile(TempStarMaterial, VetStarSize, VetStarSize, 0, 0, TempStarMaterial.MaterialUSize(), TempStarMaterial.MaterialVSize());

			if( ++Counter==5 )
			{
				Counter = 0;
				TempX+=VetStarSize;
			}
		}
		
		/*C.SetDrawColor(255, 255, 255, 255);
		C.SetPos(TempX, TempY-TempSize*0.12f);
		C.DrawTile(Material'Tree_A.Tree_T.Tree0', TempSize, TempSize, 0, 0, 256, 512);*/
	}

	if ( Level.TimeSeconds - LastVoiceGainTime < 0.333 )
	{
		if ( !bUsingVOIP && PlayerOwner != None && PlayerOwner.ActiveRoom != None &&
			 PlayerOwner.ActiveRoom.GetTitle() == "Team" )
		{
			bUsingVOIP = true;
			PlayerOwner.NotifySpeakingInTeamChannel();
		}

		DisplayVoiceGain(C);
	}
	else
	{
		bUsingVOIP = false;
	}

	if ( bDisplayInventory || bInventoryFadingOut )
	{
		DrawInventory(C);
	}
}

simulated static function DrawSpottedBar( Canvas C, float Val )
{
	local int X,Y,XS,YS;

	C.Style = ERenderStyle.STY_Alpha;
	C.SetDrawColor(255,255,255,200);
	XS = C.ClipX*0.1f;
	X = C.ClipX*0.5f-(XS*0.5);
	Y = C.ClipY*0.05f;
	YS = C.ClipY*0.035f;
	C.SetPos(X,Y);
	C.DrawRect(Texture'KillingFloorHUD.HUD.Hud_Rectangel_W_Stroke',XS,YS);
	if( Val<=0 )
		return;
	C.SetPos(X+2,Y+2);
	C.SetDrawColor(255,255,255,255);
	C.DrawTile(Texture'KillingFloorHUD.HUD.Hud_Rectangel_W_Stroke',float(XS-4)*FMin(Val,1.f),YS-4, 0, 0, 1, 1);
}

simulated final function RenderFlash( canvas Canvas )
{
	if( PlayerOwner==None || PlayerOwner.FlashScale.X==0 || PlayerOwner.FlashFog==vect(0,0,0) )
		Return;
	Canvas.DrawColor.R = Min(Abs(PlayerOwner.FlashFog.X*PlayerOwner.FlashScale.X)*255,255);
	Canvas.DrawColor.G = Min(Abs(PlayerOwner.FlashFog.Y*PlayerOwner.FlashScale.X)*255,255);
	Canvas.DrawColor.B = Min(Abs(PlayerOwner.FlashFog.Z*PlayerOwner.FlashScale.X)*255,255);
	Canvas.DrawColor.A = 255;
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.SetPos(0,0);
	Canvas.DrawTile(Texture'engine.WhiteSquareTexture', Canvas.ClipX, Canvas.ClipY, 0, 0, 1, 1);
	Canvas.DrawColor = Canvas.Default.DrawColor;
}

// Draw Health Bars for damage opened doors.
function DrawDoorHealthBars(Canvas C)
{
	local KFDoorMover DamageDoor;
	local vector CameraLocation, CamDir, TargetLocation, HBScreenPos;
	local rotator CameraRotation;
	local name DoorTag;
	local int i;

	if( PawnOwner==None )
		return;

	if ( (Level.TimeSeconds>LastDoorBarHealthUpdate) || (Welder(PawnOwner.Weapon)!=none && PlayerOwner.bFire==1) )
	{
		DoorCache.Length = 0;

		foreach CollidingActors(class'KFDoorMover', DamageDoor, 300.00, PlayerOwner.CalcViewLocation)
		{
			if ( DamageDoor.WeldStrength<=0 )
				continue;

			DoorCache[DoorCache.Length] = DamageDoor;

			C.GetCameraLocation(CameraLocation, CameraRotation);
			TargetLocation = DamageDoor.WeldIconLocation /*+ vect(0, 0, 1) * Height*/;
			TargetLocation.Z = CameraLocation.Z;
			CamDir	= vector(CameraRotation);

			if ( Normal(TargetLocation - CameraLocation) dot Normal(CamDir) >= 0.1 && DamageDoor.Tag != DoorTag && FastTrace(DamageDoor.WeldIconLocation - ((DoorCache[i].WeldIconLocation - CameraLocation) * 0.25), CameraLocation) )
			{
				HBScreenPos = C.WorldToScreen(TargetLocation);
				DrawDoorBar(C, HBScreenPos.X, HBScreenPos.Y, DamageDoor.WeldStrength / DamageDoor.MaxWeld, 255);
				DoorTag = DamageDoor.Tag;
			}
		}
		LastDoorBarHealthUpdate = Level.TimeSeconds+0.2;
	}
	else
	{
		for ( i = 0; i < DoorCache.Length; i++ )
		{
			if ( DoorCache[i].WeldStrength<=0 )
				continue;
	 		C.GetCameraLocation(CameraLocation, CameraRotation);
			TargetLocation = DoorCache[i].WeldIconLocation /*+ vect(0, 0, 1) * Height*/;
			TargetLocation.Z = CameraLocation.Z;
			CamDir	= vector(CameraRotation);

			if ( Normal(TargetLocation - CameraLocation) dot Normal(CamDir) >= 0.1 && DoorCache[i].Tag != DoorTag && FastTrace(DoorCache[i].WeldIconLocation - ((DoorCache[i].WeldIconLocation - CameraLocation) * 0.25), CameraLocation) )
			{
				HBScreenPos = C.WorldToScreen(TargetLocation);
				DrawDoorBar(C, HBScreenPos.X, HBScreenPos.Y, DoorCache[i].WeldStrength / DoorCache[i].MaxWeld, 255);
				DoorTag = DoorCache[i].Tag;
			}
		}
	}
}

function DrawDoorBar(Canvas C, float XCentre, float YCentre, float BarPercentage, byte BarAlpha)
{
	local float TextWidth, TextHeight;
	local string IntegrityText;

	IntegrityText = int(BarPercentage * 100) $ "%";

	if ( !bLightHud )
	{
		if ( BarPercentage > 0.70 )
			C.SetDrawColor(0, 255, 0, 112);
		else if ( BarPercentage > 0.35 )
			C.SetDrawColor(255, 255, 0, 112);
		else
			C.SetDrawColor(255, 0, 0, 112);
		C.Style = ERenderStyle.STY_Alpha;
		C.SetPos(XCentre - ((DoorWelderBG.USize * 1.18) / 2) , YCentre - ((DoorWelderBG.VSize * 0.9) / 2));
		C.DrawTileScaled(DoorWelderBG, 1.18, 0.9);
	}

	if ( BarPercentage > 0.70 )
		C.SetDrawColor(50, 255, 50, 255);
	else if ( BarPercentage > 0.35 )
		C.SetDrawColor(255, 255, 50, 255);
	else
		C.SetDrawColor(255, 50, 50, 255);

	C.Font = LoadSmallFontStatic(4);
	C.StrLen(IntegrityText, TextWidth, TextHeight);
	if ( BarPercentage > 0.70 )
		C.SetDrawColor(50, 255, 50, 255);
	else if ( BarPercentage > 0.35 )
		C.SetDrawColor(255, 255, 50, 255);
	else
		C.SetDrawColor(255, 50, 50, 255);
	C.SetPos(XCentre + 5 , YCentre - (TextHeight / 2.4));
	C.DrawTextClipped(IntegrityText);

	C.SetPos((XCentre - 5) - 64, YCentre - 24);
	C.Style = ERenderStyle.STY_Alpha;
	C.DrawTile(DoorWelderIcon, 64, 48, 0, 0, 256, 192);
}

simulated function Tick( float Delta )
{
	if ( CongratzDemonessaMessTime < Level.TimeSeconds && SRPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).bCongratzDemonessa )
	{
		CongratzDemonessaMessTime = Level.TimeSeconds + CongratzDemonessaMessFreq;
		CongratzDemonessaMess(PlayerOwner.PlayerReplicationInfo);
	}
	if ( NextBlinkTime < Level.TimeSeconds ) 
	{
		Blink = !Blink;
		NextBlinkTime = Level.TimeSeconds + BlinkInterval;
	}

	if( ClientRep==None )
	{
		ClientRep = Class'ClientPerkRepLink'.Static.FindStats(PlayerOwner);
		if( ClientRep!=None )
			SmileyMsgs = ClientRep.SmileyTags;
	}
	if( ClientRep==None )
		ClientRep = Class'ClientPerkRepLink'.Static.FindStats(PlayerOwner);
	if( ClientRep!=None && ClientRep.bBWZEDTime && OldDilation!=Level.TimeDilation )
	{
		OldDilation = Level.TimeDilation;
		if( OldDilation<0.5f )
		{
			DesiredBW = 1.f;
			bFadeBW = (bUseBloom || bUseMotionBlur);
		}
		else
		{
			DesiredBW = 0.f;
			bFadeBW = (bUseBloom || bUseMotionBlur);
		}
	}
	if( bDisplayingProgress )
	{
		bDisplayingProgress = false;
		if( VisualProgressBar<LevelProgressBar )
			VisualProgressBar = FMin(VisualProgressBar+Delta,LevelProgressBar);
		else if( VisualProgressBar>LevelProgressBar )
			VisualProgressBar = FMax(VisualProgressBar-Delta,LevelProgressBar);
	}
	if( bFadeBW )
	{
		if( CurrentBW>DesiredBW )
			CurrentBW = FMax(CurrentBW-Delta*2.f,DesiredBW);
		else if( CurrentBW<DesiredBW )
			CurrentBW = FMin(CurrentBW+Delta*2.f,DesiredBW);

		if( CurrentBW>0 )
		{
			KFPlayerController(PlayerOwner).postfxon(2);
			KFPlayerController(PlayerOwner).postfxbw(CurrentBW);
		}
		else KFPlayerController(PlayerOwner).postfxoff(2);
		if( CurrentBW==DesiredBW )
			bFadeBW = false;
	}
	Super.Tick(Delta);
}

final function DrawSelectionIcon( Canvas C, bool bSelected, KFWeapon I, float Width, float Height )
{
	local float RX,RY;
	local Material M;

	if( bSelected )
		M = I.SelectedHudImage;
	else M = I.HudImage;

	if( M!=None )
	{
		RX = C.CurX;
		RY = C.CurY;
		C.DrawTile(M, Width, Height, 0, 0, 256, 192);
		if( !bSelected )
			return;
		C.CurX = RX;
		C.CurY = RY;
	}

	if( !bSelected )
	{
		C.DrawColor.G = 128;
		C.DrawColor.B = 128;
	}
	RX = C.ClipX;
	RY = C.ClipY;
	C.OrgX = C.CurX;
	C.CurX = 0;
	C.ClipX = Width;
	C.ClipY = C.CurY+Height;
	C.DrawText(I.ItemName,false);
	C.OrgX = 0;
	C.ClipX = RX;
	C.ClipY = RY;
	if( !bSelected )
	{
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
	}
}

function DrawInventory(Canvas C)
{
	local Inventory CurInv;
	local int i, Categorized[5], Num[5], X, Y, TempX, TempY, TempWidth, TempHeight, TempBorder, StartY;

	if( PawnOwner == none )
	{
		return;
	}

	if ( bInventoryFadingIn )
	{
		if ( Level.TimeSeconds < InventoryFadeStartTime + InventoryFadeTime )
		{
			C.SetDrawColor(255, 255, 255, byte(((Level.TimeSeconds - InventoryFadeStartTime) / InventoryFadeTime) * 255.0));
		}
		else
		{
			bInventoryFadingIn = false;
			C.SetDrawColor(255, 255, 255, 255);
		}
	}
	else if ( bInventoryFadingOut )
	{
		if ( Level.TimeSeconds < InventoryFadeStartTime + InventoryFadeTime )
		{
			C.SetDrawColor(255, 255, 255, byte((1.0 - ((Level.TimeSeconds - InventoryFadeStartTime) / InventoryFadeTime)) * 255.0));
		}
		else
		{
			bInventoryFadingOut = false;
			return;
		}
	}
	else
	{
		C.SetDrawColor(255, 255, 255, 255);
	}

	TempX = InventoryX * C.ClipX;
	TempY = InventoryY * C.ClipY;
	TempWidth = InventoryBoxWidth * C.ClipX;
	TempHeight = InventoryBoxHeight * C.ClipX;
	TempBorder = BorderSize * C.ClipX;
	C.Font = GetFontSizeIndex(C, -3);
	SelectedInventoryCategory = -1;

	// First count the weapons
	for ( CurInv = PawnOwner.Inventory; CurInv != none; CurInv = CurInv.Inventory )
	{
		// Don't allow non-categorized or Grenades
		if ( CurInv.InventoryGroup>0 && CurInv.InventoryGroup<=ArrayCount(Categorized) && KFWeapon(CurInv)!=None )
		{
			if( CurInv==SelectedInventory ) // Make sure index is in sync (could have desynced)
			{
				SelectedInventoryCategory = CurInv.InventoryGroup-1;
				SelectedInventoryIndex = Categorized[SelectedInventoryCategory];
			}
			++Categorized[CurInv.InventoryGroup-1];
		}
	}
	
	// Check if current selected weapon goes off screen.
	if( SelectedInventoryCategory!=-1 && (TempY+Categorized[SelectedInventoryCategory]*TempHeight)>=C.ClipY )
	{
		// Adjust offset based on current selected weapon.
		Y = SelectedInventoryIndex*TempHeight;
		X = (C.ClipY-TempY)/2;
		if( Y>X )
			StartY = X-Y;
	}
	
	// Now draw weapons.
	for ( CurInv = PawnOwner.Inventory; CurInv != none; CurInv = CurInv.Inventory )
	{
		// Don't allow non-categorized or Grenades
		if ( CurInv.InventoryGroup>0 && CurInv.InventoryGroup<=ArrayCount(Categorized) && KFWeapon(CurInv)!=None )
		{
			i = CurInv.InventoryGroup - 1;
			X = TempX+(TempWidth*i);
			Y = TempY+(Num[i]*TempHeight);
			if( i==SelectedInventoryCategory )
				Y+=StartY;

			// Draw this item's Background
			C.SetPos(X, Y);
			if ( CurInv==SelectedInventory )
				C.DrawTileStretched(SelectedInventoryBackgroundTexture, TempWidth, TempHeight);
			else C.DrawTileStretched(InventoryBackgroundTexture, TempWidth, TempHeight);

			// Draw the Weapon's Icon over the Background
			C.SetPos(X + TempBorder, Y + TempBorder);
			DrawSelectionIcon(C,CurInv==SelectedInventory,KFWeapon(CurInv),TempWidth - (2.0 * TempBorder),TempHeight - (2.0 * TempBorder));
			++Num[i];
		}
	}

	// Draw empty categories boxes.
	for ( i=0; i<ArrayCount(Categorized); i++ )
	{
		if ( Categorized[i]==0 )
		{
			C.SetPos(TempX+(TempWidth*i), TempY);
			C.DrawTileStretched(InventoryBackgroundTexture, TempWidth, TempHeight * 0.25);
		}
	}
}
function PrevWeapon()
{
	local Inventory CurInv;
	local int Categorized[5], Num;
//	local byte Tries;

	if ( PawnOwner==none || PawnOwner.Inventory==None || !ShowInventory() )
		return;

//	while( ++Tries<3 )
//	{
		SelectedInventoryCategory = -1;
		SelectedInventoryIndex = 0;

		// First pass, gather weapon counts.
		for ( CurInv = PawnOwner.Inventory; CurInv != none; CurInv = CurInv.Inventory )
		{
			// Don't allow non-categorized or Grenades
			if ( CurInv.InventoryGroup>0 && CurInv.InventoryGroup<=ArrayCount(Categorized) && KFWeapon(CurInv)!=None )
			{
				if ( CurInv==SelectedInventory )
				{
					SelectedInventoryCategory = CurInv.InventoryGroup - 1;
					SelectedInventoryIndex = Categorized[SelectedInventoryCategory];
				}
				++Num;
				++Categorized[CurInv.InventoryGroup - 1];
			}
		}

		if( Num<=1 )
			return; // Prevent runaway loop.

		// Now check for suitable prev index.
		// Find next available category.
		if( SelectedInventoryIndex==0 )
		{
			while( true )
			{
				if( --SelectedInventoryCategory<0 )
					SelectedInventoryCategory = ArrayCount(Categorized)-1;

				if( Categorized[SelectedInventoryCategory]>0 )
					break;
			}
			SelectedInventoryIndex = Categorized[SelectedInventoryCategory]-1;
		}
		else --SelectedInventoryIndex; // Simply go to previous index.

		// Second pass, find our desired item.
		Num = 0;
		for ( CurInv = PawnOwner.Inventory; CurInv != none; CurInv = CurInv.Inventory )
		{
			if ( CurInv.InventoryGroup==(SelectedInventoryCategory+1) && KFWeapon(CurInv)!=None && (Num++)==SelectedInventoryIndex )
			{
				SelectedInventory = CurInv;
				break;
			}
		}
//		if( PawnOwner.Weapon!=SelectedInventory ) // Make sure not reselecting current weapon.
//			break;
//	}
}
function NextWeapon()
{
	local Inventory CurInv;
	local int Categorized[5], Num;
//	local byte Tries;

	if ( PawnOwner==none || PawnOwner.Inventory==None || !ShowInventory() )
		return;

//	while( ++Tries<3 )
//	{
		SelectedInventoryCategory = -1;
		SelectedInventoryIndex = 0;

		// First pass, gather weapon counts.
		for ( CurInv = PawnOwner.Inventory; CurInv != none; CurInv = CurInv.Inventory )
		{
			// Don't allow non-categorized or Grenades
			if ( CurInv.InventoryGroup>0 && CurInv.InventoryGroup<=ArrayCount(Categorized) && KFWeapon(CurInv)!=None )
			{
				if ( CurInv==SelectedInventory )
				{
					SelectedInventoryCategory = CurInv.InventoryGroup - 1;
					SelectedInventoryIndex = Categorized[SelectedInventoryCategory];
				}
				++Num;
				++Categorized[CurInv.InventoryGroup - 1];
			}
		}

		if( Num<=1 )
			return; // Prevent runaway loop.

		// Now check for suitable next index.
		// Find next available category.
		if( SelectedInventoryCategory==-1 || SelectedInventoryIndex==(Categorized[SelectedInventoryCategory]-1) )
		{
			while( true )
			{
				if( ++SelectedInventoryCategory>=ArrayCount(Categorized) )
					SelectedInventoryCategory = 0;

				if( Categorized[SelectedInventoryCategory]>0 )
					break;
			}
			SelectedInventoryIndex = 0;
		}
		else ++SelectedInventoryIndex; // Simply go to next index.

		// Second pass, find our desired item.
		Num = 0;
		for ( CurInv = PawnOwner.Inventory; CurInv != none; CurInv = CurInv.Inventory )
		{
			if ( CurInv.InventoryGroup==(SelectedInventoryCategory+1) && KFWeapon(CurInv)!=None && (Num++)==SelectedInventoryIndex )
			{
				SelectedInventory = CurInv;
				break;
			}
		}
//		if( PawnOwner.Weapon!=SelectedInventory ) // Make sure not reselecting current weapon.
//			break;
//	}
}

simulated function DrawBars(Canvas C, Actor A, float Height, string BarType)
{
	local vector CameraLocation, CamDir, TargetLocation, HBScreenPos;
	local rotator CameraRotation;
	local float Dist, BarScale;
	local color OldDrawColor;
	local DKMonster Mon;
	local ZombieFleshpound FP;
	local DKFleshPoundNew FPB;
	local DKBrute B;
	local DKHusk Husk;
	local DKScrake Scrake;
	local DKCrawler Crawler;
	local DKShiver Shiver;
	//local DKPatriarch Clamely;
	local HardPat Clamely;
	local MonsterReplicationInfo MRI;
	local float RageDamageGained,RageDamageTreshold,RageSecondsStart,RageSecondsGained,RageTime,CalmTime,RageStartTime,RageHits,CalmHits,
				ScaleVal1,ScaleVal2;
	local bool FullScale;
	local float DifficultyModifier;
	local bool IsInRage;
	local int CR,CG,CB;

	// rjp --  don't draw the health bar if menus are open
	// exception being, the Veterancy menu
	
	if ( PlayerOwner.Player.GUIController.bActive && GUIController(PlayerOwner.Player.GUIController).ActivePage.Name != 'GUIVeterancyBinder' )
	{
		return;
	}
	
	OldDrawColor = C.DrawColor;

	C.GetCameraLocation(CameraLocation, CameraRotation);
	TargetLocation = A.Location + vect(0, 0, 1) * (A.CollisionHeight * 2);
	Dist = VSize(TargetLocation - CameraLocation);

	CamDir  = vector(CameraRotation);

	// Check Distance Threshold / behind camera cut off
	if ( Dist > HealthBarCutoffDist || (Normal(TargetLocation - CameraLocation) dot CamDir) < 0 )
	{
		return;
	}

	// Target is located behind camera
	HBScreenPos = C.WorldToScreen(TargetLocation);

	if ( HBScreenPos.X <= 0 || HBScreenPos.X >= C.SizeX || HBScreenPos.Y <= 0 || HBScreenPos.Y >= C.SizeY)
	{
		return;
	}
	
	FullScale = false;
	
	if ( BarType == "health" )
		goto StartDrawHealth;
		
	if ( BarType == "armor" )
		goto StartDrawArmor;
		
	StartDrawHealth:
	
	Mon = DKMonster(A);
	if ( Mon != none )
	{
		// continue
	}
	else
		return;

	BarScale = Mon.health/Mon.healthmax;
	
	CR = 50;
	CG = 255;
	CB = 50;
	// зеленый, а если монстр двойной, мигает с зеленого на красный
	
	if ( Mon.bDoubled )
	{
		if ( Mon.health < Mon.healthmax * 0.5 )
		{
			BarScale *= 2.0;
		}
		else
		{
			if ( Blink )
				CG = 0;
			//
		}
	}

	//
	
	goto BeginDrawing;
	
	StartDrawArmor:
	
	Mon = DKMonster(A);
	if ( Mon != none && Mon.bHasArmor )
	{
		// continue
	}
	else
		return;
		
	if ( Mon.Isa('HardPat') && !Mon.bHasArmor )
	{
		BarScale =  FMax(0.0,FMin(1.0,((Level.TimeSeconds - HardPat(Mon).ArmorRestoreTime + HardPat(Mon).ArmorRestoreCooldown)/HardPat(Mon).ArmorRestoreCooldown)));
	}
	
	if ( Mon.Isa('HardPatHZD') && !Mon.bHasArmor )
	{
		BarScale =  FMax(0.0,FMin(1.0,((Level.TimeSeconds - HardPatHZD(Mon).ArmorRestoreTime + HardPatHZD(Mon).ArmorRestoreCooldown)/HardPatHZD(Mon).ArmorRestoreCooldown)));
	}
	BarScale = float(Mon.armor)/float(Mon.armormax);
	
	CR = 0;
	CG = 0;
	CB = 128;
	
	goto BeginDrawing;

	BeginDrawing:
	
	if ( FullScale )
		BarScale = 1.0;

	if ( FastTrace(TargetLocation, CameraLocation) )
	{
		C.SetDrawColor(192, 192, 192, 255);
		C.SetPos(HBScreenPos.X - EnemyHealthBarLength * 0.5, HBScreenPos.Y - EnemyHealthBarHeight * BarNum);
		C.DrawTileStretched(WhiteMaterial, EnemyHealthBarLength, EnemyHealthBarHeight);

		C.SetDrawColor(CR, CG, CB, 255);
		C.SetPos(HBScreenPos.X - EnemyHealthBarLength * 0.5 + 1.0, HBScreenPos.Y - EnemyHealthBarHeight * BarNum + 1.0);
		C.DrawTileStretched(WhiteMaterial, (EnemyHealthBarLength - 2.0) * BarScale, EnemyHealthBarHeight - 2.0);
		BarNum++;
	}

	C.DrawColor = OldDrawColor;
}

simulated function StartDrawingBars()
{
	BarNum = 0;
}

simulated function FindPlayerGrenade()
{
	local inventory inv;
	local class<Ammunition> AmmoClass;

	if( PawnOwner == none )
	{
		return;
	}

	for ( inv = PawnOwner.inventory; inv != none; inv = inv.Inventory)
	{
		if ( Frag1_(inv) != none )
		{
			PlayerGrenade = Frag(inv);
			AmmoClass = PlayerGrenade.GetAmmoClass(0);
		}
	}
}

simulated function DrawKFBar(Canvas C, float XCentre, float YCentre, float BarPercentage, byte BarAlpha, optional bool bArmor)
{
	local bool bNeedBlink;

	C.SetDrawColor(192, 192, 192, BarAlpha);
	C.SetPos(XCentre - 0.5 * BarLength, YCentre - 0.5 * BarHeight);
	C.DrawTileStretched(WhiteMaterial, BarLength, BarHeight);
	
	bNeedBlink = false;
	
	if ( BarPercentage > 1.0 )
	{
		BarPercentage = 1.0;
		bNeedBlink = true;
		//
	}

	if ( bArmor )
	{
		C.SetDrawColor(0, 0, 255, BarAlpha);
		C.SetPos(XCentre - (0.5 * BarLength) - ArmorIconSize - 2.0, YCentre - (ArmorIconSize * 0.5));
		C.DrawTile(ArmorIcon.WidgetTexture, ArmorIconSize, ArmorIconSize, 0, 0, ArmorIcon.WidgetTexture.MaterialUSize(), ArmorIcon.WidgetTexture.MaterialVSize());

		C.SetDrawColor(0, 0, 255, BarAlpha);
	}
	else
	{
		if ( BarPercentage > 0.70 )
			C.SetDrawColor(50, 255, 50, BarAlpha);
		else if ( BarPercentage > 0.35 )
			C.SetDrawColor(255, 255, 0, BarAlpha);
		else
			C.SetDrawColor(255, 0, 0, BarAlpha);
		C.SetPos(XCentre - (0.5 * BarLength) - HealthIconSize - 2.0, YCentre - (HealthIconSize * 0.5));
		C.DrawTile(HealthIcon.WidgetTexture, HealthIconSize, HealthIconSize, 0, 0, HealthIcon.WidgetTexture.MaterialUSize(), HealthIcon.WidgetTexture.MaterialVSize());

		if ( BarPercentage > 0.70 )
			C.SetDrawColor(50, 255, 50, BarAlpha);
		else if ( BarPercentage > 0.35 )
			C.SetDrawColor(255, 255, 0, BarAlpha);
		else
			C.SetDrawColor(255, 0, 0, BarAlpha);
	}
	
	if ( Blink && bNeedBlink )
		C.SetDrawColor(0, 0, 0, BarAlpha);

	C.SetPos(XCentre - (0.5 * BarLength) + 1.0, YCentre - (0.5 * BarHeight) + 1.0);
	C.DrawTileStretched(WhiteMaterial, (BarLength - 2.0) * BarPercentage, BarHeight - 2.0);
}

simulated function DrawAmmoBar(Canvas C, float XCentre, float YCentre, float BarPercentage, byte BarAlpha)
{
	local bool bNeedBlink;

	C.SetDrawColor(192, 192, 192, BarAlpha);
	C.SetPos(XCentre - 0.5 * BarLength, YCentre - 0.5 * BarHeight);
	C.DrawTileStretched(WhiteMaterial, BarLength, BarHeight);
	
	BarPercentage = FMin(BarPercentage,1.00);
	BarPercentage = FMax(BarPercentage,0.00);


//	C.SetDrawColor(0, 0, 255, BarAlpha);
//	C.SetPos(XCentre - (0.5 * BarLength) - ArmorIconSize - 2.0, YCentre - (ArmorIconSize * 0.5));
//	C.DrawTile(ArmorIcon.WidgetTexture, ArmorIconSize, ArmorIconSize, 0, 0, ArmorIcon.WidgetTexture.MaterialUSize(), ArmorIcon.WidgetTexture.MaterialVSize());

	C.SetDrawColor(255, 130, 80, BarAlpha);
	C.SetPos(XCentre - (0.5 * BarLength) + 1.0, YCentre - (0.5 * BarHeight) + 1.0);
	C.DrawTileStretched(WhiteMaterial, (BarLength - 2.0) * BarPercentage, BarHeight - 2.0);
}

simulated function SetHUDAlpha()
{
	ZedTimeBG.Tints[0].A = KFHUDAlpha;
	ZedTimeBG.Tints[1].A = KFHUDAlpha;
	ZedTimeIcon.Tints[0].A = KFHUDAlpha;
	ZedTimeIcon.Tints[1].A = KFHUDAlpha;
	ZedTimeDigits.Tints[0].A = KFHUDAlpha;
	ZedTimeDigits.Tints[1].A = KFHUDAlpha;

	Super.SetHUDAlpha();
}

simulated function Message(PlayerReplicationInfo PRI, coerce string Msg, name MsgType)
{
	local Class<LocalMessage> LocalMessageClass;

	if ( PRI != None && MsgType == 'Say' || MsgType == 'TeamSay' )
	{
		DisplayPortrait(PRI);
	}

	switch( MsgType )
	{
		case 'Trader':
			Msg = TraderString$":" @ Msg;
			LocalMessageClass = class'SayMessagePlus';
			break;
		case 'Information':
			LocalMessageClass = class'SayMessageInformation';
			break;
		case 'Voice':
		case 'Say':
			if ( PRI == None )
			{
				return;
			}

			Msg = PRI.PlayerName $ ":" @ Msg;
			if ( PRI.bAdmin || SRPlayerReplicationInfo(PRI).bSunriseAdmin )
				LocalMessageClass = class'SayMessageAdmin';
			else
				LocalMessageClass = class'SayMessageSunrise';
			break;
		case 'TeamSay':
			if ( PRI == None )
			{
				return;
			}

			Msg = PRI.PlayerName $ "(" $ PRI.GetLocationName() $ "):" @ Msg;
			if ( PRI.bAdmin || IsAdminID(PRI) )
				LocalMessageClass = class'SayMessageAdmin';
			else
				LocalMessageClass = class'TeamSayMessagePlus';
			break;
		case 'CriticalEvent':
			LocalMessageClass = class'KFCriticalEventPlus';
			LocalizedMessage(LocalMessageClass, 0, None, None, None, Msg);
			return;
		case 'DeathMessage':
			LocalMessageClass = class'xDeathMessage';
			break;
		default:
			LocalMessageClass = class'StringMessagePlus';
			break;
	}
	if ( MsgType == 'Information' && SRPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).bCongratzDemonessa )
	{
		return;
	}
	AddTextMessage(Msg, LocalMessageClass, PRI);
}

simulated function CongratzDemonessaMess(PlayerReplicationInfo PRI)
{
	local string Mess;
	
	CDMIndex = ++CDMIndex % DemonessaCongratzMess.Length;
	Mess = DemonessaCongratzMess[CDMIndex];
	AddTextMessage(Mess,class'SayMessageDemonessa',PRI);
}

function bool IsAdminID(PlayerReplicationInfo PRI)
{
	local string S;
	
	S = SRPlayerReplicationInfo(PRI).StringPlayerID;
	
//	DKGameType(Level.Game).DebugMessage(SRPlayerReplicationInfo(PRI).Cont.PlayerReplicationInfo.PlayerName);
	
	if ( S == "4134698854" // Dr. Killjoy
	|| S == "91158540" || S == "3152955468" // Sabon
	|| S == "89224638" // Mr_Zera
	|| S == "3651637088" // 6EWEHblU
	|| S == "921186898" // KOC91K
	|| S == "1130048812" // [SG]Goic[ua]
							)
		return true;
	
	return false;
}
//==================================================================================================================
function DisplayMessages(Canvas C)
{
	local int i, j, XPos, YPos,MessageCount;
	local float XL, YL, XXL, YYL;
	local string S;

	for( i = 0; i < ConsoleMessageCount; i++ )
	{
		if ( TextMessages[i].Text == "" )
			break;
		else if( TextMessages[i].MessageLife < Level.TimeSeconds )
		{
			TextMessages[i].Text = "";

			if( i < ConsoleMessageCount - 1 )
			{
				for( j=i; j<ConsoleMessageCount-1; j++ )
					TextMessages[j] = TextMessages[j+1];
			}
			TextMessages[j].Text = "";
			break;
		}
		else
			MessageCount++;
	}

	YPos = (ConsoleMessagePosY * HudCanvasScale * C.SizeY) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeY);
	if ( PlayerOwner == none || PlayerOwner.PlayerReplicationInfo == none || !PlayerOwner.PlayerReplicationInfo.bWaitingPlayer )
	{
		XPos = (ConsoleMessagePosX * HudCanvasScale * C.SizeX) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeX);
	}
	else
	{
		XPos = (0.005 * HudCanvasScale * C.SizeX) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeX);
	}

	C.Font = GetConsoleFont(C);
	C.DrawColor = LevelActionFontColor;

	C.TextSize ("A", XL, YL);

	YPos -= YL * MessageCount+1; // DP_LowerLeft
	YPos -= YL; // Room for typing prompt

	for( i=0; i<MessageCount; i++ )
	{
		if ( TextMessages[i].Text == "" )
			break;

		C.SetPos( XPos, YPos );
		C.DrawColor = TextMessages[i].TextColor;
		YYL = 0;
		XXL = 0;
		if( TextMessages[i].PRI!=None )
		{
			S = TextMessages[i].PRI.PlayerName$": ";
			C.DrawText(S,False);
			C.CurY = YPos;
		}
		if( SmileyMsgs.Length!=0 )
			DrawSmileyText(TextMessages[i].Text,C,,YYL);
		else C.DrawText(TextMessages[i].Text,false);
		YPos += (YL+YYL);
	}
}
function AddTextMessage(string M, class<LocalMessage> MessageClass, PlayerReplicationInfo PRI)
{
	local int i;

	if( bMessageBeep && MessageClass.Default.bBeep )
		PlayerOwner.PlayBeepSound();

    for( i=0; i<ConsoleMessageCount; i++ )
    {
        if ( TextMessages[i].Text == "" )
            break;
    }
    if( i == ConsoleMessageCount )
    {
        for( i=0; i<ConsoleMessageCount-1; i++ )
            TextMessages[i] = TextMessages[i+1];
    }
	TextMessages[i].Text = M;
	TextMessages[i].MessageLife = Level.TimeSeconds + MessageClass.Default.LifeTime;
	TextMessages[i].TextColor = MessageClass.static.GetConsoleColor(PRI);
	if( MessageClass==class'SayMessagePlus' )
		TextMessages[i].PRI = PRI;
	else TextMessages[i].PRI = None;
}
simulated final function DrawSmileyText( string S, canvas C, optional out float XXL, optional out float XYL )
{
	local int i,n;
	local float PX,PY,XL,YL,CurX,CurY,SScale,Sca,AdditionalY,NewAY;
	local string D;
	local color OrgC;

	// Initilize
	C.TextSize("T",XL,YL);
	SScale = YL;
	PX = C.CurX;
	PY = C.CurY;
	CurX = PX;
	CurY = PY;
	OrgC = C.DrawColor;

	// Search for smiles in text
	i = FindNextSmile(S,n);
	While( i!=-1 )
	{
		D = Left(S,i);
		S = Mid(S,i+Len(SmileyMsgs[n].SmileyTag));
		// Draw text behind
		C.SetPos(CurX,CurY);
		C.DrawText(D);
		// Draw smile
		C.StrLen(StripColorForTTS(D),XL,YL);
		CurX+=XL;
		While( CurX>C.ClipX )
		{
			CurY+=(YL+AdditionalY);
			XYL+=(YL+AdditionalY);
			AdditionalY = 0;
			CurX-=C.ClipX;
		}
		C.DrawColor = Default.WhiteColor;
		C.SetPos(CurX,CurY);
		if( SmileyMsgs[n].SmileyTex.USize==16 )
			Sca = SScale;
		else Sca = SmileyMsgs[n].SmileyTex.USize/32*SScale;
		C.DrawRect(SmileyMsgs[n].SmileyTex,Sca,Sca);
		if( Sca>SScale )
		{
			NewAY = (Sca-SScale);
			if( NewAY>AdditionalY )
				AdditionalY = NewAY;
			NewAY = 0;
		}
		CurX+=Sca;
		While( CurX>C.ClipX )
		{
			CurY+=(YL+AdditionalY);
			XYL+=(YL+AdditionalY);
			AdditionalY = 0;
			CurX-=C.ClipX;
		}
		// Then go for next smile
		C.DrawColor = OrgC;
		i = FindNextSmile(S,n);
	}
	// Then draw rest of text remaining
	C.SetPos(CurX,CurY);
	C.StrLen(StripColorForTTS(S),XL,YL);
	C.DrawText(S);
	CurX+=XL;
	While( CurX>C.ClipX )
	{
		CurY+=(YL+AdditionalY);
		XYL+=(YL+AdditionalY);
		AdditionalY = 0;
		CurX-=C.ClipX;
	}
	XYL+=AdditionalY;
	AdditionalY = 0;
	XXL = CurX;
	C.SetPos(PX,PY);
}
simulated final function int FindNextSmile( string S, out int SmileNr )
{
	local int i,p,bp;
	local string CS;

	CS = Caps(S);
	bp = -1;
	for( i=(SmileyMsgs.Length-1); i>=0; --i )
	{
		if( SmileyMsgs[i].bInCAPS )
			p = InStr(CS,SmileyMsgs[i].SmileyTag);
		else p = InStr(S,SmileyMsgs[i].SmileyTag);
		if( p!=-1 && (p<bp || bp==-1) )
		{
			bp = p;
			SmileNr = i;
		}
	}
	Return bp;
}
static final function string StripColorForTTS(string s) // Strip color codes.
{
	local int p;

	p = InStr(s,chr(27));
	while ( p>=0 )
	{
		s = left(s,p)$mid(S,p+4);
		p = InStr(s,Chr(27));
	}
	return s;
}
//===================================================================//Vepr 12
simulated function DrawSpeed(Canvas C)
{
	local float TextWidth, TextHeight;
    local string s;

    if ( PawnOwner == none )
        return;

    s = int(VSize(PawnOwner.Velocity)) $ "/" $ int(PawnOwner.GroundSpeed) @ "uups";
	//draw near in the top middle
	C.Font = LoadSmallFontStatic(SpeedometerFont);
	C.StrLen(s, TextWidth, TextHeight);
	C.SetPos(C.ClipX * SpeedometerX - TextWidth, C.ClipY * SpeedometerY);

    C.DrawColor = WeightDigits.Tints[0]; //default KF HUD color
    if ( PawnOwner.GroundSpeed > 240 ) { 
        // speed bonus - in blue
        C.DrawColor.R = 0;
        C.DrawColor.G = 100;
        C.DrawColor.B = 255;
    }
    else if ( PawnOwner.GroundSpeed > 200 ) { 
        // melee speed - in green
        C.DrawColor.R = 0;
        C.DrawColor.G = 206;
        C.DrawColor.B = 0;
    }

	C.DrawText(s);
}

simulated function SetScoreBoardClass (class<Scoreboard> ScoreBoardClass)
{
    if (ScoreBoard != None )
        ScoreBoard.Destroy();

    if (ScoreBoardClass == None)
        ScoreBoard = None;
    else if(bSBTrue)
    {
        ScoreBoard = Spawn (class'SRScoreBoardAlt', Owner);

       // if (ScoreBoard == None)
            //log ("Hud::SetScoreBoard(): Could not spawn a scoreboard of class "$ScoreBoardClass, 'Error');
    }
    else
    {
        ScoreBoard = Spawn (class'SRScoreBoard', Owner);

       // if (ScoreBoard == None)
           // log ("Hud::SetScoreBoard(): Could not spawn a scoreboard of class "$ScoreBoardClass, 'Error');
    }
}

function UpdateKillMessage(Object OptionalObject,PlayerReplicationInfo RelatedPRI_1)
{
}
///////////////===========================================================================//////////////////////
simulated function DrawKFHUDTextElements(Canvas C)
{
	local float    XL, YL;
	local int      NumZombies, Min;
	local string   S;
	local vector   Pos, FixedZPos;
	local rotator  ShopDirPointerRotation;
	local float    CircleSize;
	local float    ResScale;
	local ShopVolume shV;//Flame
	if ( PlayerOwner == none || KFGRI == none || !KFGRI.bMatchHasBegun || KFPlayerController(PlayerOwner).bShopping )
	{
		return;
	}

	/*ResScale =  C.SizeX / 1024.0;
	CircleSize = FMin(128 * ResScale,128);
	C.FontScaleX = FMin(ResScale,1.f);
	C.FontScaleY = FMin(ResScale,1.f);*/
    ResScale =  C.SizeX / 1024.0;
    CircleSize = FMin(256 * ResScale,256);
	C.FontScaleX = FMin(ResScale,1.f);
	C.FontScaleY = FMin(ResScale,1.f);

	if( !KFGRI.bWaveInProgress )
	{
		C.SetDrawColor(255, 255, 255, 255);
		//C.SetPos(C.ClipX - CircleSize, 2);
		//C.DrawTile(Material'KillingFloorHUD.HUD.Hud_Bio_Clock_Circle', CircleSize, CircleSize, 0, 0, 256, 256);
		C.SetPos(C.ClipX - CircleSize, -20);
		C.DrawTile(Material'Masters.Hud_Bio_Clock_Circle_9m_DR', CircleSize, CircleSize, 0, 0, 512, 512);
		//C.DrawTile(Material'TreeNew_A.Hud_Bio_Clock_Circle_9m_n_y2017', CircleSize, CircleSize, 0, 0, 512, 512);
		//C.DrawTile(Material'Masters.Hud_Bio_Clock_Circle_9m_2', CircleSize, CircleSize, 0, 0, 512, 512);

		if ( KFGRI.TimeToNextWave <= 5 )
		{
			// Hints
			if ( bIsSecondDowntime )
			{
				KFPlayerController(PlayerOwner).CheckForHint(40);
			}
		}

		Min = KFGRI.TimeToNextWave / 60;
		NumZombies = KFGRI.TimeToNextWave - (Min * 60);

		S = Eval((Min >= 10), string(Min), "0" $ Min) $ ":" $ Eval((NumZombies >= 10), string(NumZombies), "0" $ NumZombies);
		C.Font = LoadFont(2);
		C.Strlen(S, XL, YL);
		//C.SetDrawColor(240, 0, 0, KFHUDAlpha);
		//C.SetDrawColor(220, 0, 0, KFHUDAlpha);
		C.SetDrawColor(230, 74, 0, KFHUDAlpha);
		C.SetPos(C.ClipX - CircleSize/2 - (XL / 2), CircleSize/2 - YL*3.5 / 2);
		//C.SetPos(C.ClipX - CircleSize/2 - (XL / 2), CircleSize/2 - YL / 2);
		C.DrawText(S, False);
	}
	else
	{
		//Hints
		if ( KFPlayerController(PlayerOwner) != none )
		{
			KFPlayerController(PlayerOwner).CheckForHint(30);
			if ( !bHint_45_TimeSet && KFGRI.WaveNumber == 1)
			{
				Hint_45_Time = Level.TimeSeconds + 5;
				bHint_45_TimeSet = true;
			}
		}
		C.SetDrawColor(255, 255, 255, 255);
		//C.SetPos(C.ClipX - CircleSize, 2);
		//C.DrawTile(Material'KillingFloorHUD.HUD.Hud_Bio_Circle', CircleSize, CircleSize, 0, 0, 256, 256);
		C.SetPos(C.ClipX - CircleSize, -20);
		C.DrawTile(Material'Masters.Hud_Bio_Circle_9m_DR', CircleSize, CircleSize, 0, 0, 512, 512);
		//C.DrawTile(Material'TreeNew_A.Hud_Bio_Circle_9m_n_y2017', CircleSize, CircleSize, 0, 0, 512, 512);
		//C.DrawTile(Material'Masters.Hud_Bio_Circle_9m_2', CircleSize, CircleSize, 0, 0, 512, 512);

		S = string(KFGRI.MaxMonsters);
		C.Font = LoadFont(1);
		C.Strlen(S, XL, YL);
		//C.SetDrawColor(240, 0, 0, KFHUDAlpha);
		C.SetDrawColor(230, 74, 0, KFHUDAlpha);
		//C.SetDrawColor(220, 0, 0, KFHUDAlpha);
		//C.SetDrawColor(182, 43, 207, KFHUDAlpha);
		//C.SetPos(C.ClipX - CircleSize/2 - (XL / 2), CircleSize/2 - (YL / 1.5));
		C.SetPos(C.ClipX - CircleSize/2 - (XL / 2), CircleSize/2 - (YL*3.2 / 1.5));
		C.DrawText(S);

		S = WaveString @ string(KFGRI.WaveNumber + 1) $ "/" $ string(KFGRI.FinalWave);
		C.Font = LoadFont(5);
		C.Strlen(S, XL, YL);
		//C.SetPos(C.ClipX - CircleSize/2 - (XL / 2), CircleSize/2 + (YL / 2.5));
		C.SetPos(C.ClipX - CircleSize/2 - (XL / 2), CircleSize/2 + (YL*-3.5 / 2.5));
		C.DrawText(S);

		//Needed for the hints showing up in the second downtime
		bIsSecondDowntime = true;
	}

	C.FontScaleX = 1;
	C.FontScaleY = 1;


	if ( KFPRI == none || KFPRI.Team == none || KFPRI.bOnlySpectator || PawnOwner == none )
	{
		return;
	}

	// Draw the shop pointer. Flame
	if ( ShopDirPointer == None )
	{
		ShopDirPointer = Spawn(Class'SRShopDirectionPointer');
		//ShopDirPointer = Spawn(Class'KFShopDirectionPointer');
		ShopDirPointer.bHidden = bHideHud;
	}

	Pos.X = C.SizeX / 18.0;
	Pos.Y = C.SizeX / 18.0;
	Pos = PlayerOwner.Player.Console.ScreenToWorld(Pos) * 10.f * (PlayerOwner.default.DefaultFOV / PlayerOwner.FovAngle) + PlayerOwner.CalcViewLocation;
	ShopDirPointer.SetLocation(Pos);
	shV=GetNearestShop();
	if ( shV != none )
	{

		// Let's check for a real Z difference (i.e. different floor) doesn't make sense to rotate the arrow
		// only because the trader is a midget or placed slightly wrong
		if ( shV.Location.Z > PawnOwner.Location.Z + 50.f || shV.Location.Z < PawnOwner.Location.Z - 50.f )
		{
			ShopDirPointerRotation = rotator(shV.Location - PawnOwner.Location);
		}
		else
		{
			FixedZPos = shV.Location;
			FixedZPos.Z = PawnOwner.Location.Z;
			ShopDirPointerRotation = rotator(FixedZPos - PawnOwner.Location);
		}
	}
	else
	{
		ShopDirPointer.bHidden = true;
		return;
	}
	ShopDirPointer.SetRotation(ShopDirPointerRotation);

	if ( Level.TimeSeconds > Hint_45_Time && Level.TimeSeconds < Hint_45_Time + 2 )
	{
		if ( KFPlayerController(PlayerOwner) != none )
		{
			KFPlayerController(PlayerOwner).CheckForHint(45);
		}
	}

	C.DrawActor(None, False, True); // Clear Z.
	ShopDirPointer.bHidden = false;
	C.DrawActor(ShopDirPointer, False, false);
	ShopDirPointer.bHidden = true;
	DrawTraderDistanceEx(C);
	if( bShowTime )
	{
		DrawPlayerTime(C);
	}
}
simulated final function DrawPlayerTime(Canvas C)
{
	local int       FontSize;
	local float     StrWidth, StrHeight;
	local string    PlayerTimeText;

	PlayerTimeText = SRPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).PlayerLocalTime;

	if ( C.ClipX <= 640 )
		FontSize = 7;
	else if ( C.ClipX <= 800 )
		FontSize = 6;
	else if ( C.ClipX <= 1024 )
		FontSize = 5;
	else if ( C.ClipX <= 1280 )
		FontSize = 4;
	else
		FontSize = 3;

	C.Font = LoadFont(FontSize);
	C.SetDrawColor(255, 50, 50, 255);
	C.StrLen(PlayerTimeText, StrWidth, StrHeight);
	C.SetPos((C.SizeX / 14.0) - (StrWidth / 2.0), C.SizeX / 10.0 + StrHeight);
	C.DrawText(PlayerTimeText);
}
static function font GetNewConsoleFont(Canvas C, int shift)
{
	local int FontSize;

	if( default.OverrideConsoleFontName != "" )
	{
		if( default.OverrideConsoleFont != None )
			return default.OverrideConsoleFont;
		default.OverrideConsoleFont = Font(DynamicLoadObject(default.OverrideConsoleFontName, class'Font'));
		if( default.OverrideConsoleFont != None )
			return default.OverrideConsoleFont;
		Log("Warning: HUD couldn't dynamically load font "$default.OverrideConsoleFontName);
		default.OverrideConsoleFontName = "";
	}

	FontSize = Default.ConsoleFontSize; //5
	if ( C.ClipX < 640 )
		FontSize++;
	if ( C.ClipX < 800 )
		FontSize++;
	if ( C.ClipX < 1024 )
		FontSize++;
	if ( C.ClipX < 1280 )
		FontSize++;
	if ( C.ClipX < 1600 )
		FontSize++;
	return LoadFontStatic(Min(8,Max(1,FontSize+shift)));
}

// Draws the distance to the trader in meters when the ShopDirPointer is active
// Рисуем расстояние до ближайшего магазина
simulated final function DrawTraderDistanceEx(Canvas C)
{
	local int       FontSize;
	local float     StrWidth, StrHeight;
	local string    TraderDistanceText;
	local ShopVolume shV;//Flame
	shV=GetNearestShop();
	if ( PawnOwner != none && KFGRI != none )
	{
		if ( shV != none )
		{
			TraderDistanceText = TraderString$":" @ int(VSize(shV.Location - PawnOwner.Location) / 50) $ DistanceUnitString;
		}
		else
		{
			return;
		}

		if ( C.ClipX <= 640 )
			FontSize = 7;
		else if ( C.ClipX <= 800 )
			FontSize = 6;
		else if ( C.ClipX <= 1024 )
			FontSize = 5;
		else if ( C.ClipX <= 1280 )
			FontSize = 4;
		else
			FontSize = 3;

		C.Font = LoadFont(FontSize);
		C.SetDrawColor(255, 50, 50, 255);
		C.StrLen(TraderDistanceText, StrWidth, StrHeight);
		C.SetPos((C.SizeX / 14.0) - (StrWidth / 2.0), C.SizeX / 10.0);
		C.DrawText(TraderDistanceText);
	}
}
//Ищем ближайший магазин

simulated function ShopVolume GetNearestShop()
{
	local ShopVolume shV;
	local int minDistance;
	minDistance=100000;
	foreach PawnOwner.AllActors(class'ShopVolume',shV)
	{
			minDistance=Min(minDistance,int(VSize(shV.Location - PawnOwner.Location)));
	}
	foreach PawnOwner.AllActors(class'ShopVolume',shV)
	{
			if(int(VSize(shV.Location - PawnOwner.Location))<=minDistance)
				break;
	}
	return shV;
}

defaultproperties
{
	CDMIndex=-1
	CongratzDemonessaMessFreq=8
	DemonessaCongratzMess(0)="À7û "
	DemonessaCongratzMess(1)="ÿÌ3 "
	DemonessaCongratzMess(2)="À7û "
	DemonessaCongratzMess(3)="ÿÌ3 "
	DemonessaCongratzMess(4)="À7û "
	DemonessaCongratzMess(5)="ÿÌ3 "
	DemonessaCongratzMess(6)="À7û "
	DemonessaCongratzMess(7)="ÿÌ3 "
	DemonessaCongratzMess(8)="À7û "
	DemonessaCongratzMess(9)="ÿÌ3 "
	DemonessaCongratzMess(10)="À7û "
	DemonessaCongratzMess(11)="ÿÌ3 "
	DemonessaCongratzMess(12)="À7û "
	DemonessaCongratzMess(13)="ÿÌ3 "
	DemonessaCongratzMess(14)="À7û "
	DemonessaCongratzMess(15)="ÿÌ3 "
	DemonessaCongratzMess(16)="À7û "
	DemonessaCongratzMess(17)="ÿÌ3 "
	DemonessaCongratzMess(18)="À7û "
	DemonessaCongratzMess(19)="ÿÌ3 "
	DemonessaCongratzMess(20)="À7û "
	DemonessaCongratzMess(21)="ÿÌ3 "
	DemonessaCongratzMess(22)="À7û "
	DemonessaCongratzMess(23)="ÿÌ3 "
	DemonessaCongratzMess(24)="À7û "
	DemonessaCongratzMess(25)="ÿÌ3 "
	DemonessaCongratzMess(26)="À7û "
	bSBTrue=false
	bShowTime=true
	bShowSpeed=true
	SpeedometerX=0.900000
	SpeedometerFont=5
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	SumDmgDelay=8.0000000
	SumDmgTxt="Урон:"
//
     //CashIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Pound_Symbol',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.300000,PosX=0.850000,PosY=0.860000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     //CashDigits=(RenderStyle=STY_Alpha,TextureScale=0.500000,PosX=0.882000,PosY=0.867000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
	//CashIcon=(WidgetTexture=Texture'TreeNew_A.Hud_Pound_SymbolM',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.3,DrawPivot=DP_UpperLeft,PosX=0.85,PosY=0.86,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
	CashDigits=(RenderStyle=STY_Alpha,TextureScale=0.50,DrawPivot=DP_UpperLeft,PosX=0.882,PosY=0.867,Tints[0]=(R=255,G=64,B=64,A=255),Tints[1]=(R=255,G=64,B=64,A=255))
//
	BlinkInterval = 0.33
}
