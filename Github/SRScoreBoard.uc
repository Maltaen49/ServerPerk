class SRScoreBoard extends KFScoreBoard;

var localized string NotShownInfo,PlayerCountText,SpectatorCountText,AliveCountText,BotText;
var array<string> NewDiffSkillLevel;
var localized string HealText, PerkLevelText, DiesText, TKText, TimeXPos;

simulated event UpdateScoreBoard(Canvas Canvas)
{
	local PlayerReplicationInfo PRI, OwnerPRI,BestPRI,TotalPRI;
	local int i, j, FontReduction, NetXPos, PlayerCount, HeaderOffsetY, HeadFoot, MessageFoot, PlayerBoxSizeY, BoxSpaceY, NameXPos, BoxTextOffsetY, OwnerOffset,
	HealthXPos, BoxXPos,KillsXPos, TitleYPos, BoxWidth, VetXPos, NotShownCount;
	local float XL,YL, chislo;
	local float deathsXL, KillsXL, NetXL, HealthXL, MaxNamePos, KillWidthX, HealedXPos, DiesXPos, TKXPos, TimeXPos;
	local Material VeterancyBox,StarBox;
	local string S;
	local byte Stars;
	local array<PlayerReplicationInfo> SelfPRIArray;
	local int KillsMax,DamageMax,HealMax,BestIndex,TotalDies,TotalTK;
	local float BestCoef,CurCoef;
	local string CurrentPlayerName;

	OwnerPRI = KFPlayerController(Owner).PlayerReplicationInfo;
	OwnerOffset = -1;
	
	KillsMax = 0;
	DamageMax = 0;
	HealMax = 0;
	TotalDies = 0;
	
	for ( i = 0; i < GRI.PRIArray.Length; i++)
	{
		if ( GRI.PRIArray[i].bOnlySpectator )
			continue;
		KillsMax += KFPlayerReplicationInfo(GRI.PRIArray[i]).Kills;
		DamageMax += SRPlayerReplicationInfo(GRI.PRIArray[i]).DamageDealed;
		HealMax += SRPlayerReplicationInfo(GRI.PRIArray[i]).HPHealed;
		TotalDies += SRPlayerReplicationInfo(GRI.PRIArray[i]).Dies;
		TotalTK += SRPlayerReplicationInfo(GRI.PRIArray[i]).TeamKills;
	}
	
//	KillsMax = KFPlayerReplicationInfo(TotalPRI).Kills;
//	DamageMax = SRPlayerReplicationInfo(TotalPRI).DamageDealed;
//	HealMax = SRPlayerReplicationInfo(TotalPRI).HPHealed;
	
	for( i = 0; i < GRI.PRIArray.Length; i++)
	{
		PRI = GRI.PRIArray[i];
		if ( !PRI.bOnlySpectator )
		{
			if( !PRI.bOutOfLives && KFPlayerReplicationInfo(PRI).PlayerHealth>0 )
				++HeadFoot;
			if ( PRI == OwnerPRI )
				OwnerOffset = i;
			PlayerCount++;
		}
		else ++NetXPos;
	}
	
	for(i=0; i<PlayerCount; i++)
	{
		SelfPRIArray.Insert(i,1);
		SelfPRIArray[i] = GRI.PRIArray[i];
	}
	
	if ( HealMax <= 0.1 )
	{
		HealMax = 1.00;
	}
	
	for(i=0; i<SelfPRIArray.Length; i++)
	{
		BestCoef = 0.0;
		for(j=i; j<SelfPRIArray.Length; j++)
		{
			CurCoef =	0.50 * (float(KFPlayerReplicationInfo(SelfPRIArray[j]).Kills)/100.0) +
						//0.25 * (float(SRPlayerReplicationInfo(SelfPRIArray[j]).DamageDealed)/1200000.0) +
						0.50 * (float(SRPlayerReplicationInfo(SelfPRIArray[j]).HPHealed)/1000.0);
			if ( CurCoef > BestCoef )
			{
				BestCoef = CurCoef;
				BestIndex = j;
			}
		}
		PRI = SelfPRIArray[i];
		SelfPRIArray[i] = SelfPRIArray[BestIndex];
		SelfPRIArray[BestIndex] = PRI;
	}
	
	// First, draw title.
	S = NewDiffSkillLevel[Clamp(InvasionGameReplicationInfo(GRI).BaseDifficulty, 0, 7)] @ "|" @ WaveString @ (InvasionGameReplicationInfo(GRI).WaveNumber + 1) @ "|" @ Level.Title @ "|" @ FormatTime(GRI.ElapsedTime);

	Canvas.Font = class'ROHud'.static.GetSmallMenuFont(Canvas);
	Canvas.TextSize(S, XL,YL);
	Canvas.DrawColor = HUDclass.default.RedColor;
	Canvas.Style = ERenderStyle.STY_Normal;

	HeaderOffsetY = Canvas.ClipY * 0.11;
	Canvas.SetPos(0.5 * (Canvas.ClipX - XL), HeaderOffsetY);
	Canvas.DrawTextClipped(S);

	// Second title line
	S = PlayerCountText@PlayerCount@SpectatorCountText@NetXPos@AliveCountText@HeadFoot @ "|" @ PerkLevelText @ FMax(0.00,GetAveragePerkLevel());
	Canvas.TextSize(S, XL,YL);
	HeaderOffsetY+=YL;
	Canvas.SetPos(0.5 * (Canvas.ClipX - XL), HeaderOffsetY);
	Canvas.DrawTextClipped(S);
	HeaderOffsetY+=(YL*3.f);

	// Select best font size and box size to fit as many players as possible on screen
	if ( Canvas.ClipX < 600 )
		i = 4;
	else if ( Canvas.ClipX < 800 )
		i = 3;
	else if ( Canvas.ClipX < 1000 )
		i = 2;
	else if ( Canvas.ClipX < 1200 )
		i = 1;
	else i = 0;

	Canvas.Font = class'ROHud'.static.LoadMenuFontStatic(i);
	Canvas.TextSize("Test", XL, YL);
	PlayerBoxSizeY = 1.2 * YL;
	BoxSpaceY = 0.25 * YL;

	while( ((PlayerBoxSizeY+BoxSpaceY)*PlayerCount)>(Canvas.ClipY-HeaderOffsetY) )
	{
		if( ++i>=5 || ++FontReduction>=3 ) // Shrink font, if too small then break loop.
		{
			// We need to remove some player names here to make it fit.
			NotShownCount = PlayerCount-int((Canvas.ClipY-HeaderOffsetY)/(PlayerBoxSizeY+BoxSpaceY))+1;
			PlayerCount-=NotShownCount;
			break;
		}
		Canvas.Font = class'ROHud'.static.LoadMenuFontStatic(i);
		Canvas.TextSize("Test", XL, YL);
		PlayerBoxSizeY = 1.2 * YL;
		BoxSpaceY = 0.25 * YL;
	}

	HeadFoot = 7 * YL;
	MessageFoot = 1.5 * HeadFoot;

	BoxWidth = 0.9 * Canvas.ClipX;
	BoxXPos = 0.5 * (Canvas.ClipX - BoxWidth);
	BoxWidth = Canvas.ClipX - 2 * BoxXPos;
	VetXPos = BoxXPos + 0.0001 * BoxWidth;
	NameXPos = VetXPos + PlayerBoxSizeY*1.75f;
	KillsXPos = BoxXPos + 0.40 * BoxWidth;
	HealedXPos = BoxXPos + 0.50 * BoxWidth;
	DiesXPos = BoxXPos + 0.60 * BoxWidth;
	TKXPos = BoxXPos + 0.70 * BoxWidth;
	TimeXPos = BoxXPos + 0.80 * BoxWidth;
	HealthXpos = BoxXPos + 0.90 * BoxWidth;
	NetXPos = BoxXPos + 0.996 * BoxWidth;

	// draw background boxes
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = HUDclass.default.WhiteColor;
	Canvas.DrawColor.A = 128;
	
	PlayerCount++;

	for ( i = 0; i < PlayerCount; i++ )
	{
		Canvas.SetPos(BoxXPos, HeaderOffsetY + (PlayerBoxSizeY + BoxSpaceY) * i);
		Canvas.DrawTileStretched( BoxMaterial, BoxWidth, PlayerBoxSizeY);
	}
	if( NotShownCount>0 ) // Add box for not shown players.
	{
		Canvas.DrawColor = HUDclass.default.RedColor;
		Canvas.SetPos(BoxXPos, HeaderOffsetY + (PlayerBoxSizeY + BoxSpaceY) * PlayerCount);
		Canvas.DrawTileStretched( BoxMaterial, BoxWidth, PlayerBoxSizeY);
		Canvas.DrawColor = HUDclass.default.WhiteColor;
	}

	// Draw headers
	TitleYPos = HeaderOffsetY - 1.1 * YL;
	Canvas.TextSize(HealthText, HealthXL, YL);
	Canvas.TextSize(DeathsText, DeathsXL, YL);
	Canvas.TextSize(KillsText, KillsXL, YL);
	Canvas.TextSize(NetText, NetXL, YL);

	Canvas.DrawColor = HUDclass.default.WhiteColor;
	Canvas.SetPos(NameXPos, TitleYPos);
	Canvas.DrawTextClipped(PlayerText);

	Canvas.SetPos(KillsXPos - 0.5 * KillsXL, TitleYPos);
	Canvas.DrawTextClipped(KillsText);

	Canvas.TextSize(HealText, XL, YL);
	Canvas.SetPos(HealedXPos - 0.5 * XL, TitleYPos);
	Canvas.DrawTextClipped(HealText);

	Canvas.TextSize(TKText, XL, YL);
	Canvas.SetPos(TKXPos - 0.5 * XL, TitleYPos);
	Canvas.DrawTextClipped(TKText);
	
	Canvas.TextSize(DiesText, XL, YL);
	Canvas.SetPos(DiesXPos - 0.5 * XL, TitleYPos);
	Canvas.DrawTextClipped(DiesText);

	Canvas.TextSize(TimeText, XL, YL);
	Canvas.SetPos(TimeXPos - 0.5 * XL, TitleYPos);
	Canvas.DrawTextClipped(TimeText);
	
	Canvas.SetPos(HealthXPos - 0.5 * HealthXL, TitleYPos);
	Canvas.DrawTextClipped(HealthText);

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawColor = HUDclass.default.WhiteColor;
	Canvas.SetPos(0.5 * Canvas.ClipX, HeaderOffsetY + 4);

	Canvas.DrawColor = HUDclass.default.WhiteColor;
	Canvas.SetPos(NetXPos - NetXL, TitleYPos);
	Canvas.DrawTextClipped(NetText);

	BoxTextOffsetY = HeaderOffsetY + 0.5 * (PlayerBoxSizeY - YL);

	Canvas.DrawColor = HUDclass.default.WhiteColor;
	MaxNamePos = Canvas.ClipX;
	Canvas.ClipX = KillsXPos - 4.f;
	
	SelfPRIArray.Insert(0,1);

	for ( i = 0; i < PlayerCount; i++ )
	{
		Canvas.SetPos(NameXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
		if( SelfPRIArray[i] == OwnerPRI )
		{
			Canvas.DrawColor.R = 255;
			Canvas.DrawColor.G = 0;
			Canvas.DrawColor.B = 0;
		}
		else if ( i == 0 )
		{
			Canvas.DrawColor.R = 0;
			Canvas.DrawColor.G = 0;
			Canvas.DrawColor.B = 255;
		}
		else
		{
			Canvas.DrawColor.R = 255;
			Canvas.DrawColor.G = 255;
			Canvas.DrawColor.B = 255;
		}
		if ( i == 0 )
			Canvas.DrawTextClipped("TOTAL");
		else
		{
			CurrentPlayerName = SelfPRIArray[i].PlayerName;
			/*
			if ( InStr(CurrentPlayerName,"_") == 0 )
			{
				CurrentPlayerName = Mid(CurrentPlayerName,1);
			}
			*/
			Canvas.DrawTextClipped(CurrentPlayerName);
		}
	}
	if( NotShownCount>0 ) // Draw not shown info
	{
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 0;
		Canvas.SetPos(NameXPos, (PlayerBoxSizeY + BoxSpaceY)*PlayerCount + BoxTextOffsetY);
		Canvas.DrawText(NotShownCount@NotShownInfo,true);
	}

	Canvas.ClipX = MaxNamePos;
	Canvas.DrawColor = HUDclass.default.WhiteColor;

	Canvas.Style = ERenderStyle.STY_Normal;

	// Draw the player informations.
	for ( i = 0; i < PlayerCount; i++ )
	{
		PRI = SelfPRIArray[i];
		Canvas.DrawColor = HUDclass.default.WhiteColor;

		// Display perks.
		if ( i != 0 && KFPlayerReplicationInfo(PRI)!=None && class<SRVeterancyTypes>(KFPlayerReplicationInfo(PRI).ClientVeteranSkill)!=none )
		{
			Stars = class<SRVeterancyTypes>(KFPlayerReplicationInfo(PRI).ClientVeteranSkill).Static.PreDrawPerk(Canvas
				,KFPlayerReplicationInfo(PRI).ClientVeteranSkillLevel,VeterancyBox,StarBox);

			if ( VeterancyBox != None )
				DrawPerkWithStars(Canvas,VetXPos,HeaderOffsetY+(PlayerBoxSizeY+BoxSpaceY)*i,PlayerBoxSizeY,Stars,VeterancyBox,StarBox);
			Canvas.DrawColor = HUDclass.default.WhiteColor;
		}

		// draw kills
		if ( i == 0 )
		{
			chislo = KillsMax;
			if (chislo >= 1000000)
				S = int(chislo/1000000) $ "M";
			else if (chislo >= 10000)
				S = int(chislo/1000) $ "K";
			else
				S = string(int(chislo));
		}
		else
		{
			chislo = KFPlayerReplicationInfo(PRI).Kills;
			S = string(int(chislo));
		}
		Canvas.TextSize(S, XL, YL);
		Canvas.SetPos(KillsXPos-XL*0.5f, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
		Canvas.DrawColor = HUDclass.default.GoldColor;
		Canvas.DrawText(S,true);
		// draw heal
		if ( i == 0 )
			S = string(HealMax);
		else
			S = string(SRPlayerReplicationInfo(PRI).HPHealed);
		Canvas.TextSize(S, XL, YL);
		Canvas.SetPos(HealedXPos-XL*0.5f, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
		Canvas.DrawColor = HUDclass.default.GreenColor;
		Canvas.DrawText(S,true);

		// draw dies
		if ( i != 0 )
		{
			S = string(SRPlayerReplicationInfo(PRI).Dies);
		}
		else
		{
			S = string(TotalDies);
		}
		Canvas.TextSize(S, XL, YL);
		Canvas.SetPos(DiesXPos-XL*0.5f, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
		Canvas.DrawColor = HUDclass.default.RedColor;
		Canvas.DrawText(S,true);
		
		// draw team kills
		if ( i != 0 )
		{
			S = string(SRPlayerReplicationInfo(PRI).TeamKills);
		}
		else
		{
			S = string(TotalTK);
		}
		Canvas.TextSize(S, XL, YL);
		Canvas.SetPos(TKXPos-XL*0.5f, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
		Canvas.DrawText(S,true);
		if ( i != 0 )
		{
		// draw time
			if( GRI.ElapsedTime<PRI.StartTime ) // Login timer error, fix it.
				GRI.ElapsedTime = PRI.StartTime;
			S = FormatTime(GRI.ElapsedTime-PRI.StartTime);
			Canvas.TextSize(S, XL, YL);
			Canvas.SetPos(TimeXPos-XL*0.5f, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
			Canvas.DrawColor = HUDclass.default.WhiteColor;
			Canvas.DrawTextClipped(S);
		}
		// Draw ping
		if ( i != 0 )
		{
			if( PRI.bAdmin )
			{
				Canvas.DrawColor = HUDclass.default.RedColor;
				S = AdminText;
			}
			else if ( !GRI.bMatchHasBegun )
			{
				if ( PRI.bReadyToPlay )
					S = ReadyText;
				else S = NotReadyText;
			}
			else if( !PRI.bBot )
				S = string(PRI.Ping*4);
			else S = BotText;
			Canvas.TextSize(S, XL, YL);
			Canvas.SetPos(NetXPos-XL, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
			Canvas.DrawTextClipped(S);

			// draw healths
			if ( PRI.bOutOfLives || KFPlayerReplicationInfo(PRI).PlayerHealth<=0 /*|| KFMonster(SRPlayerReplicationInfo(PRI).Controller.Pawn) != none*/ )
			{
				Canvas.DrawColor = HUDclass.default.RedColor;
				S = OutText;
			}
			else
			{
				if( KFPlayerReplicationInfo(PRI).PlayerHealth>=90 )
					Canvas.DrawColor = HUDclass.default.GreenColor;
				else if( KFPlayerReplicationInfo(PRI).PlayerHealth>=50 )
					Canvas.DrawColor = HUDclass.default.GoldColor;
				else Canvas.DrawColor = HUDclass.default.RedColor;
				S = KFPlayerReplicationInfo(PRI).PlayerHealth@HealthyString;
			}
			Canvas.TextSize(S, XL, YL);
			Canvas.SetPos(HealthXpos - 0.5 * XL, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
			Canvas.DrawTextClipped(S);
		}
	}
}

simulated final function DrawPerkWithStars( Canvas C, float X, float Y, float Scale, int Stars, Material PerkIcon, Material StarIcon )
{
	local byte i;

	C.SetPos(X,Y);
	C.DrawTile(PerkIcon, Scale, Scale, 0, 0, PerkIcon.MaterialUSize(), PerkIcon.MaterialVSize());
	Y+=Scale*0.9f;
	X+=Scale*0.8f;
	Scale*=0.2f;
	while( Stars>0 )
	{
		for( i=1; i<=Min(5,Stars); ++i )
		{
			C.SetPos(X,Y-(i*Scale*0.8f));
			C.DrawTile(StarIcon, Scale, Scale, 0, 0, StarIcon.MaterialUSize(), StarIcon.MaterialVSize());
		}
		X+=Scale;
		Stars-=5;
	}
}

function float GetAveragePerkLevel()
{
	local float ret;
	local int PNum;
	local SRPlayerReplicationInfo SRPRI;
	local int i,n;
	
	ret = 0.0;
	PNum = 0;
	n = GRI.PRIArray.Length;
	
	for (i=0; i<n; i++)
	{
		SRPRI = SRPlayerReplicationInfo(GRI.PRIArray[i]);
		if ( SRPRI.PlayerHealth > 0 && !SRPRI.bOnlySpectator )
		{
			ret += float(SRPRI.ClientVeteranSkillLevel);
			PNum++;
		}
	}

	return ret / float(PNum);
}

/*simulated event DrawScoreboardAlt( Canvas C )
{
	UpdateGRI();
    UpdateScoreBoard(C);
}*/

/*simulated event UpdateScoreBoardAlt(Canvas Canvas)
{
	local PlayerReplicationInfo PRI, OwnerPRI;
	local int i, FontReduction, NetXPos, PlayerCount, HeaderOffsetY, HeadFoot, MessageFoot, PlayerBoxSizeY, BoxSpaceY, NameXPos, BoxTextOffsetY, OwnerOffset, HealthXPos, BoxXPos,KillsXPos, TitleYPos, BoxWidth, VetXPos, NotShownCount;
	local float XL,YL;
	local float deathsXL, KillsXL, NetXL, HealthXL, MaxNamePos, KillWidthX, CashXPos, TimeXPos;
	local Material VeterancyBox,StarBox;
	local string S;
	local byte Stars;

	OwnerPRI = KFPlayerController(Owner).PlayerReplicationInfo;
	OwnerOffset = -1;

	for ( i = 0; i < GRI.PRIArray.Length; i++)
	{
		PRI = GRI.PRIArray[i];
		if ( !PRI.bOnlySpectator )
		{
			if( !PRI.bOutOfLives && KFPlayerReplicationInfo(PRI).PlayerHealth>0 )
				++HeadFoot;
			if ( PRI == OwnerPRI )
				OwnerOffset = i;
			PlayerCount++;
		}
		else ++NetXPos;
	}

	// First, draw title.
	S = SkillLevel[Clamp(InvasionGameReplicationInfo(GRI).BaseDifficulty, 0, 7)] @ "|" @ WaveString @ (InvasionGameReplicationInfo(GRI).WaveNumber + 1) @ "|" @ Level.Title @ "|" @ FormatTime(GRI.ElapsedTime);

	Canvas.Font = class'ROHud'.static.GetSmallMenuFont(Canvas);
	Canvas.TextSize(S, XL,YL);
	Canvas.DrawColor = HUDclass.default.RedColor;
	Canvas.Style = ERenderStyle.STY_Normal;

	HeaderOffsetY = Canvas.ClipY * 0.11;
	Canvas.SetPos(0.5 * (Canvas.ClipX - XL), HeaderOffsetY);
	Canvas.DrawTextClipped(S);

	// Second title line
	S = PlayerCountText@PlayerCount@SpectatorCountText@NetXPos@AliveCountText@HeadFoot;
	Canvas.TextSize(S, XL,YL);
	HeaderOffsetY+=YL;
	Canvas.SetPos(0.5 * (Canvas.ClipX - XL), HeaderOffsetY);
	Canvas.DrawTextClipped(S);
	HeaderOffsetY+=(YL*3.f);

	// Select best font size and box size to fit as many players as possible on screen
	if ( Canvas.ClipX < 600 )
		i = 4;
	else if ( Canvas.ClipX < 800 )
		i = 3;
	else if ( Canvas.ClipX < 1000 )
		i = 2;
	else if ( Canvas.ClipX < 1200 )
		i = 1;
	else i = 0;

	Canvas.Font = class'ROHud'.static.LoadMenuFontStatic(i);
	Canvas.TextSize("Test", XL, YL);
	PlayerBoxSizeY = 1.2 * YL;
	BoxSpaceY = 0.25 * YL;

	while( ((PlayerBoxSizeY+BoxSpaceY)*PlayerCount)>(Canvas.ClipY-HeaderOffsetY) )
	{
		if( ++i>=5 || ++FontReduction>=3 ) // Shrink font, if too small then break loop.
		{
			// We need to remove some player names here to make it fit.
			NotShownCount = PlayerCount-int((Canvas.ClipY-HeaderOffsetY)/(PlayerBoxSizeY+BoxSpaceY))+1;
			PlayerCount-=NotShownCount;
			break;
		}
		Canvas.Font = class'ROHud'.static.LoadMenuFontStatic(i);
		Canvas.TextSize("Test", XL, YL);
		PlayerBoxSizeY = 1.2 * YL;
		BoxSpaceY = 0.25 * YL;
	}

	HeadFoot = 7 * YL;
	MessageFoot = 1.5 * HeadFoot;

	BoxWidth = 0.9 * Canvas.ClipX;
	BoxXPos = 0.5 * (Canvas.ClipX - BoxWidth);
	BoxWidth = Canvas.ClipX - 2 * BoxXPos;
	VetXPos = BoxXPos + 0.0001 * BoxWidth;
	NameXPos = VetXPos + PlayerBoxSizeY*1.75f;
	KillsXPos = BoxXPos + 0.55 * BoxWidth;
	CashXPos = BoxXPos + 0.65 * BoxWidth;
	HealthXpos = BoxXPos + 0.75 * BoxWidth;
	TimeXPos = BoxXPos + 0.87 * BoxWidth;
	NetXPos = BoxXPos + 0.996 * BoxWidth;

	// draw background boxes
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = HUDclass.default.WhiteColor;
	Canvas.DrawColor.A = 128;

	for ( i = 0; i < PlayerCount; i++ )
	{
		Canvas.SetPos(BoxXPos, HeaderOffsetY + (PlayerBoxSizeY + BoxSpaceY) * i);
		Canvas.DrawTileStretched( BoxMaterial, BoxWidth, PlayerBoxSizeY);
	}
	if( NotShownCount>0 ) // Add box for not shown players.
	{
		Canvas.DrawColor = HUDclass.default.RedColor;
		Canvas.SetPos(BoxXPos, HeaderOffsetY + (PlayerBoxSizeY + BoxSpaceY) * PlayerCount);
		Canvas.DrawTileStretched( BoxMaterial, BoxWidth, PlayerBoxSizeY);
		Canvas.DrawColor = HUDclass.default.WhiteColor;
	}

	// Draw headers
	TitleYPos = HeaderOffsetY - 1.1 * YL;
	Canvas.TextSize(HealthText, HealthXL, YL);
	Canvas.TextSize(DeathsText, DeathsXL, YL);
	Canvas.TextSize(KillsText, KillsXL, YL);
	Canvas.TextSize(NetText, NetXL, YL);

	Canvas.DrawColor = HUDclass.default.WhiteColor;
	Canvas.SetPos(NameXPos, TitleYPos);
	Canvas.DrawTextClipped(PlayerText);

	Canvas.SetPos(KillsXPos - 0.5 * KillsXL, TitleYPos);
	Canvas.DrawTextClipped(KillsText);

	Canvas.TextSize(PointsText, XL, YL);
	Canvas.SetPos(CashXPos - 0.5 * XL, TitleYPos);
	Canvas.DrawTextClipped(PointsText);

	Canvas.TextSize(TimeText, XL, YL);
	Canvas.SetPos(TimeXPos - 0.5 * XL, TitleYPos);
	Canvas.DrawTextClipped(TimeText);

	Canvas.SetPos(HealthXPos - 0.5 * HealthXL, TitleYPos);
	Canvas.DrawTextClipped(HealthText);

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawColor = HUDclass.default.WhiteColor;
	Canvas.SetPos(0.5 * Canvas.ClipX, HeaderOffsetY + 4);

	Canvas.DrawColor = HUDclass.default.WhiteColor;
	Canvas.SetPos(NetXPos - NetXL, TitleYPos);
	Canvas.DrawTextClipped(NetText);

	BoxTextOffsetY = HeaderOffsetY + 0.5 * (PlayerBoxSizeY - YL);

	Canvas.DrawColor = HUDclass.default.WhiteColor;
	MaxNamePos = Canvas.ClipX;
	Canvas.ClipX = KillsXPos - 4.f;

	for ( i = 0; i < PlayerCount; i++ )
	{
		Canvas.SetPos(NameXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
		if( i == OwnerOffset )
		{
			Canvas.DrawColor.G = 0;
			Canvas.DrawColor.B = 0;
		}
		else
		{
			Canvas.DrawColor.G = 255;
			Canvas.DrawColor.B = 255;
		}
		Canvas.DrawTextClipped(GRI.PRIArray[i].PlayerName);
	}
	if( NotShownCount>0 ) // Draw not shown info
	{
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 0;
		Canvas.SetPos(NameXPos, (PlayerBoxSizeY + BoxSpaceY)*PlayerCount + BoxTextOffsetY);
		Canvas.DrawText(NotShownCount@NotShownInfo,true);
	}

	Canvas.ClipX = MaxNamePos;
	Canvas.DrawColor = HUDclass.default.WhiteColor;

	Canvas.Style = ERenderStyle.STY_Normal;

	// Draw the player informations.
	for ( i = 0; i < PlayerCount; i++ )
	{
		PRI = GRI.PRIArray[i];
		Canvas.DrawColor = HUDclass.default.WhiteColor;

		// Display perks.
		if ( KFPlayerReplicationInfo(PRI)!=None && class<SRVeterancyTypes>(KFPlayerReplicationInfo(PRI).ClientVeteranSkill)!=none )
		{
			Stars = class<SRVeterancyTypes>(KFPlayerReplicationInfo(PRI).ClientVeteranSkill).Static.PreDrawPerk(Canvas
				,KFPlayerReplicationInfo(PRI).ClientVeteranSkillLevel,VeterancyBox,StarBox);

			if ( VeterancyBox != None )
				DrawPerkWithStars(Canvas,VetXPos,HeaderOffsetY+(PlayerBoxSizeY+BoxSpaceY)*i,PlayerBoxSizeY,Stars,VeterancyBox,StarBox);
			Canvas.DrawColor = HUDclass.default.WhiteColor;
		}

		// draw kills
		Canvas.TextSize(KFPlayerReplicationInfo(PRI).Kills, KillWidthX, YL);
		Canvas.SetPos(KillsXPos - 0.5 * KillWidthX, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
		Canvas.DrawTextClipped(KFPlayerReplicationInfo(PRI).Kills);

		// draw cash
		S = string(int(PRI.Score));
		Canvas.TextSize(S, XL, YL);
		Canvas.SetPos(CashXPos-XL*0.5f, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
		Canvas.DrawText(S,true);

		// draw time
		if( GRI.ElapsedTime<PRI.StartTime ) // Login timer error, fix it.
			GRI.ElapsedTime = PRI.StartTime;
		S = FormatTime(GRI.ElapsedTime-PRI.StartTime);
		Canvas.TextSize(S, XL, YL);
		Canvas.SetPos(TimeXPos-XL*0.5f, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
		Canvas.DrawText(S,true);

		// Draw ping
		if( PRI.bAdmin )
		{
			Canvas.DrawColor = HUDclass.default.RedColor;
			S = AdminText;
		}
		else if ( !GRI.bMatchHasBegun )
		{
			if ( PRI.bReadyToPlay )
				S = ReadyText;
			else S = NotReadyText;
		}
		else if( !PRI.bBot )
			S = string(PRI.Ping*4);
		else S = BotText;
		Canvas.TextSize(S, XL, YL);
		Canvas.SetPos(NetXPos-XL, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
		Canvas.DrawTextClipped(S);

		// draw healths
		if ( PRI.bOutOfLives || KFPlayerReplicationInfo(PRI).PlayerHealth<=0 )
		{
			Canvas.DrawColor = HUDclass.default.RedColor;
			S = OutText;
		}
		else
		{
			if( KFPlayerReplicationInfo(PRI).PlayerHealth>=90 )
				Canvas.DrawColor = HUDclass.default.GreenColor;
			else if( KFPlayerReplicationInfo(PRI).PlayerHealth>=50 )
				Canvas.DrawColor = HUDclass.default.GoldColor;
			else Canvas.DrawColor = HUDclass.default.RedColor;
			S = KFPlayerReplicationInfo(PRI).PlayerHealth@HealthyString;
		}
		Canvas.TextSize(S, XL, YL);
		Canvas.SetPos(HealthXpos - 0.5 * XL, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
		Canvas.DrawTextClipped(S);
	}
}*/

defaultproperties
{
	HealthText="HEALTH"
	HealthyString="HP"
	InjuredString="HP"
	CriticalString="HP"
    NotShownInfo="player names not shown"
    PlayerCountText="Игроков:"
    SpectatorCountText="| Наблюдателей:"
    AliveCountText="| Живых игроков:"
    BotText="BOT"
	HealText="HEAL"
	DiesText="DIES"
	KillsText="KILLS"
	TKText="T.K."
	TimeText="TIME"
	PerkLevelText="Средний уровень перка:"
	NewDiffSkillLevel(1)="Normal"
    NewDiffSkillLevel(2)="Hard"
	NewDiffSkillLevel(3)="Hard"
    NewDiffSkillLevel(4)="Suicidal"
    NewDiffSkillLevel(5)="Hell On Earth"
	NewDiffSkillLevel(6)="Hell On Earth"
    NewDiffSkillLevel(7)="Судный день"
}

