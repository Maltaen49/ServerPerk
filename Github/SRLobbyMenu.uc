class SRLobbyMenu extends LobbyMenu;

struct FPlayerBoxEntry
{
	var moCheckBox			ReadyBox;
	var KFPlayerReadyBar	PlayerBox;
	var GUIImage			PlayerPerk;
	var GUILabel			PlayerVetLabel;
	var bool bIsEmpty;
};
var array<FPlayerBoxEntry>		PlayerBoxes;
var automated GUIScrollTextBox tb_ServerMOTD;
var int MaxPlayersOnList;
var bool bMOTDInit,bMOTDHidden;

function AddPlayer( KFPlayerReplicationInfo PRI, int Index, Canvas C )
{
	local float Top;
	local Material M;

	if( Index>=PlayerBoxes.Length )
	{
		Top = Index*0.045;
		PlayerBoxes.Length = Index+1;
		PlayerBoxes[Index].ReadyBox = new (None) class'moCheckBox';
		PlayerBoxes[Index].ReadyBox.bValueReadOnly = true;
		PlayerBoxes[Index].ReadyBox.ComponentJustification = TXTA_Left;
		PlayerBoxes[Index].ReadyBox.CaptionWidth = 0.82;
		PlayerBoxes[Index].ReadyBox.LabelColor.B = 0;
		PlayerBoxes[Index].ReadyBox.WinTop = 0.0475+Top;
		PlayerBoxes[Index].ReadyBox.WinLeft = 0.075;
		PlayerBoxes[Index].ReadyBox.WinWidth = 0.4;
		PlayerBoxes[Index].ReadyBox.WinHeight = 0.045;
		PlayerBoxes[Index].ReadyBox.RenderWeight = 0.55;
		PlayerBoxes[Index].ReadyBox.bAcceptsInput = False;
		PlayerBoxes[Index].PlayerBox = new (None) class'KFPlayerReadyBar';
		PlayerBoxes[Index].PlayerBox.WinTop = 0.04+Top;
		PlayerBoxes[Index].PlayerBox.WinLeft = 0.04;
		PlayerBoxes[Index].PlayerBox.WinWidth = 0.35;
		PlayerBoxes[Index].PlayerBox.WinHeight = 0.045;
		PlayerBoxes[Index].PlayerBox.RenderWeight = 0.35;
		PlayerBoxes[Index].PlayerPerk = new (None) class'GUIImage';
		PlayerBoxes[Index].PlayerPerk.ImageStyle = ISTY_Justified;
		PlayerBoxes[Index].PlayerPerk.WinTop = 0.043+Top;
		PlayerBoxes[Index].PlayerPerk.WinLeft = 0.0418;
		PlayerBoxes[Index].PlayerPerk.WinWidth = 0.039;
		PlayerBoxes[Index].PlayerPerk.WinHeight = 0.039;
		PlayerBoxes[Index].PlayerPerk.RenderWeight = 0.56;
		PlayerBoxes[Index].PlayerVetLabel = new (None) class'GUILabel';
		PlayerBoxes[Index].PlayerVetLabel.TextAlign = TXTA_Right;
		PlayerBoxes[Index].PlayerVetLabel.TextColor = class'Canvas'.Static.MakeColor(19,19,19);
		PlayerBoxes[Index].PlayerVetLabel.TextFont = "UT2SmallFont";
		PlayerBoxes[Index].PlayerVetLabel.WinTop = 0.04+Top;
		PlayerBoxes[Index].PlayerVetLabel.WinLeft = 0.22907;
		PlayerBoxes[Index].PlayerVetLabel.WinWidth = 0.151172;
		PlayerBoxes[Index].PlayerVetLabel.WinHeight = 0.045;
		PlayerBoxes[Index].PlayerVetLabel.RenderWeight = 0.5;
		AppendComponent(PlayerBoxes[Index].ReadyBox, true);
		AppendComponent(PlayerBoxes[Index].PlayerBox, true);
		AppendComponent(PlayerBoxes[Index].PlayerPerk, true);
		AppendComponent(PlayerBoxes[Index].PlayerVetLabel, true);
		Top = (PlayerBoxes[Index].PlayerBox.WinTop+PlayerBoxes[Index].PlayerBox.WinHeight);
		if( !bMOTDHidden && ADBackground != none && Top>=ADBackground.WinTop )
		{
			ADBackground.WinTop = Top+0.01;
			if( (ADBackground.WinTop+ADBackground.WinHeight)>t_ChatBox.WinTop )
			{
				ADBackground.WinHeight = t_ChatBox.WinTop-ADBackground.WinTop;
				if( ADBackground.WinHeight<0.15 )
				{
					RemoveComponent(ADBackground);
					RemoveComponent(tb_ServerMOTD);
					bMOTDHidden = true;
				}
			}
		}
	}
	PlayerBoxes[Index].ReadyBox.Checked(PRI.bReadyToPlay);
	PlayerBoxes[Index].ReadyBox.SetCaption(" "$Left(PRI.PlayerName,20));

	if ( PRI.ClientVeteranSkill != none )
	{
		PlayerBoxes[Index].PlayerVetLabel.Caption = "Lv" @ PRI.ClientVeteranSkillLevel @ PRI.ClientVeteranSkill.default.VeterancyName;
		if( class<SRVeterancyTypes>(PRI.ClientVeteranSkill)!=None )
		{
			class<SRVeterancyTypes>(PRI.ClientVeteranSkill).Static.PreDrawPerk(C,PRI.ClientVeteranSkillLevel,PlayerBoxes[Index].PlayerPerk.Image,M);
			PlayerBoxes[Index].PlayerPerk.ImageColor = C.DrawColor;
		}
		else
		{
			PlayerBoxes[Index].PlayerPerk.Image = PRI.ClientVeteranSkill.default.OnHUDIcon;
			PlayerBoxes[Index].PlayerPerk.ImageColor = class'Canvas'.Static.MakeColor(255,255,255);
		}
	}
	else
	{
		PlayerBoxes[Index].PlayerPerk.Image = None;
		PlayerBoxes[Index].PlayerVetLabel.Caption = "";
	}
	PlayerBoxes[Index].bIsEmpty = false;
}
function EmptyPlayers( int Index )
{
	while( Index<PlayerBoxes.Length && !PlayerBoxes[Index].bIsEmpty )
	{
		PlayerBoxes[Index].ReadyBox.Checked(False);
		PlayerBoxes[Index].PlayerPerk.Image = None;
		PlayerBoxes[Index].PlayerVetLabel.Caption = "";
		PlayerBoxes[Index].ReadyBox.SetCaption("");
		PlayerBoxes[Index].bIsEmpty = true;
		++Index;
	}
}
function InitComponent(GUIController MyC, GUIComponent MyO)
{
	Super(UT2k4MainPage).InitComponent(MyC, MyO);

	i_Portrait.WinTop = PlayerPortraitBG.ActualTop() + 30;
	i_Portrait.WinHeight = PlayerPortraitBG.ActualHeight() - 36;

	t_ChatBox.FocusInstead = PerkClickLabel;
}
event Opened(GUIComponent Sender)
{
	bShouldUpdateVeterancy = true;
	SetTimer(1,true);
}
function DrawPortrait()
{
	if( PlayerOwner().PlayerReplicationInfo!=None )
		sChar = PlayerOwner().PlayerReplicationInfo.CharacterName;
	else sChar = PlayerOwner().GetUrlOption("Character");

	if( sCharD!=sChar )
	{
		sCharD = sChar;
		SetPlayerRec();
	}
}
function bool NotifyLevelChange()
{
	bPersistent = false;
	bAllowClose = true;
	return true;
}
function SetPlayerRec()
{
	PlayerRec = class'xUtil'.Static.FindPlayerRecord(sChar);
	i_Portrait.Image = PlayerRec.Portrait;
}
function bool InternalOnPreDraw(Canvas C)
{
	local int i, j;
	local string StoryString;
	local String SkillString;
	local KFGameReplicationInfo KFGRI;
	local PlayerController PC;

	PC = PlayerOwner();

	if ( PC == none || PC.Level == none ) // Error?
	{
		return false;
	}

	if ( (PC.PlayerReplicationInfo != none && (!PC.PlayerReplicationInfo.bWaitingPlayer || PC.PlayerReplicationInfo.bOnlySpectator)) || PC.Outer.Name=='Entry' )
	{
		bAllowClose = true;
		PC.ClientCloseMenu(True,False);
		return false;
	}

	t_Footer.InternalOnPreDraw(C);

	WaveLabel.WinWidth = WaveLabel.ActualHeight();

	KFGRI = KFGameReplicationInfo(PC.GameReplicationInfo);

	if ( KFGRI != none )
	{
		WaveLabel.Caption = string(KFGRI.WaveNumber + 1) $ "/" $ string(KFGRI.FinalWave);
	}
	else
	{
		WaveLabel.Caption = "?/?";
		return false;
	}

	C.DrawColor.A = 255;

	// First fill in non-ready players.
	for ( i = 0; i<KFGRI.PRIArray.Length; i++ )
	{
		if ( KFGRI.PRIArray[i] == none || KFGRI.PRIArray[i].bOnlySpectator || KFGRI.PRIArray[i].bReadyToPlay || KFPlayerReplicationInfo(KFGRI.PRIArray[i])==None )
			continue;

		AddPlayer(KFPlayerReplicationInfo(KFGRI.PRIArray[i]),j,C);
		if( ++j>=MaxPlayersOnList )
			GoTo'DoneIt';
	}

	// Then comes rest.
	for ( i = 0; i < KFGRI.PRIArray.Length; i++ )
	{
		if ( KFGRI.PRIArray[i]==none || KFGRI.PRIArray[i].bOnlySpectator || !KFGRI.PRIArray[i].bReadyToPlay || KFPlayerReplicationInfo(KFGRI.PRIArray[i])==None )
			continue;

		if ( KFGRI.PRIArray[i].bReadyToPlay )
		{
			if ( !bTimeoutTimeLogged )
			{
				ActivateTimeoutTime = PC.Level.TimeSeconds;
				bTimeoutTimeLogged = true;
			}
		}
		AddPlayer(KFPlayerReplicationInfo(KFGRI.PRIArray[i]),j,C);
		if( ++j>=MaxPlayersOnList )
			GoTo'DoneIt';
	}

	if( j<MaxPlayersOnList )
		EmptyPlayers(j);

DoneIt:
	StoryString = PC.Level.Description;

	if ( !bStoryBoxFilled )
	{
		l_StoryBox.LoadStoryText();
		bStoryBoxFilled = true;
	}

	CheckBotButtonAccess();

	if ( KFGRI.BaseDifficulty <= 1 )
		SkillString = BeginnerString;
	else if ( KFGRI.BaseDifficulty <= 2 )
		SkillString = NormalString;
	else if ( KFGRI.BaseDifficulty <= 4 )
		SkillString = HardString;
	else if ( KFGRI.BaseDifficulty <= 5 )
		SkillString = SuicidalString;
	else if ( KFGRI.BaseDifficulty <= 7 )
		SkillString = HellOnEarthString;
	else SkillString = SuicidalString;

	CurrentMapLabel.Caption = CurrentMapString @ PC.Level.Title;
	DifficultyLabel.Caption = DifficultyString @ SkillString;

	return false;
}
function DrawPerk(Canvas Canvas)
{
	local float X, Y, Width, Height;
	local int CurIndex,LevelIndex;
	local float TempX, TempY;
	local float TempWidth, TempHeight;
	local float IconSize, ProgressBarWidth, PerkProgress;
	local string PerkName, PerkLevelString;
	local KFPlayerReplicationInfo KFPRI;
	local Material M,SM;
	local ClientPerkRepLink ST;
	local int i;
	DrawPortrait();
	ST = class'ClientPerkRepLink'.Static.FindStats(PlayerOwner());
	KFPRI = KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo);
	if ( KFPRI==None || KFPRI.ClientVeteranSkill==None )
	{
		if( CurrentVeterancyLevel!=255 )
		{
			CurrentVeterancyLevel = 255;
			lb_PerkEffects.SetContent("None perk active");
		}
		return;
	}
	LevelIndex = KFPRI.ClientVeteranSkillLevel;
	PerkName = KFPRI.ClientVeteranSkill.default.VeterancyName;
	PerkLevelString = "Lv" @ LevelIndex;
	switch (KFPRI.ClientVeteranSkill.default.PerkIndex)
	{
		case 0:	PerkProgress = ST.CachePerks[3].Perkclass.Static.GetTotalProgress(ST,ST.CachePerks[3].CurrentLevel);break;
		case 1:	PerkProgress = ST.CachePerks[0].Perkclass.Static.GetTotalProgress(ST,ST.CachePerks[0].CurrentLevel);break;
		case 2:	PerkProgress = ST.CachePerks[5].Perkclass.Static.GetTotalProgress(ST,ST.CachePerks[5].CurrentLevel);break;
		case 3:	PerkProgress = ST.CachePerks[2].Perkclass.Static.GetTotalProgress(ST,ST.CachePerks[2].CurrentLevel);break;
		case 4:	PerkProgress = ST.CachePerks[1].Perkclass.Static.GetTotalProgress(ST,ST.CachePerks[1].CurrentLevel);break;
		case 5:	PerkProgress = ST.CachePerks[4].Perkclass.Static.GetTotalProgress(ST,ST.CachePerks[4].CurrentLevel);break;
		case 6:	PerkProgress = ST.CachePerks[6].Perkclass.Static.GetTotalProgress(ST,ST.CachePerks[6].CurrentLevel);break;
		case 7:	PerkProgress = ST.CachePerks[7].Perkclass.Static.GetTotalProgress(ST,ST.CachePerks[7].CurrentLevel);break;
		case 8:	PerkProgress = ST.CachePerks[8].Perkclass.Static.GetTotalProgress(ST,ST.CachePerks[8].CurrentLevel);break;
		case 9:	PerkProgress = ST.CachePerks[9].Perkclass.Static.GetTotalProgress(ST,ST.CachePerks[9].CurrentLevel);break;
	}
	X = i_BGPerk.ActualLeft() + 5;
	Y = i_BGPerk.ActualTop() + 30;
	Width = i_BGPerk.ActualWidth() - 10;
	Height = i_BGPerk.ActualHeight() - 37;
	// Offset for the Background
	TempX = X;
	TempY = Y + ItemSpacing / 2.0;
	// Initialize the Canvas
	Canvas.Style = 1;
	Canvas.Font = class'ROHUD'.Static.GetSmallMenuFont(Canvas);
	Canvas.SetDrawColor(255, 255, 255, 255);
	// Draw Item Background
	Canvas.SetPos(TempX, TempY);
	//Canvas.DrawTileStretched(ItemBackground, Width, Height);
	IconSize = Height - ItemSpacing;
	// Draw Item Background
	Canvas.DrawTileStretched(PerkBackground, IconSize, IconSize);
	Canvas.SetPos(TempX + IconSize - 1.0, Y + 7.0);
	Canvas.DrawTileStretched(InfoBackground, Width - IconSize, Height - ItemSpacing - 14);
	IconSize -= IconBorder * 2.0 * Height;
	// Draw Icon
	Canvas.SetPos(TempX + IconBorder * Height, TempY + IconBorder * Height);
	if( class<SRVeterancyTypes>(KFPRI.ClientVeteranSkill)!=None )
		class<SRVeterancyTypes>(KFPRI.ClientVeteranSkill).Static.PreDrawPerk(Canvas,KFPRI.ClientVeteranSkillLevel,M,SM);
	else M = KFPRI.ClientVeteranSkill.default.OnHUDIcon;
	Canvas.DrawTile(M, IconSize, IconSize, 0, 0, M.MaterialUSize(), M.MaterialVSize());
	TempX += IconSize + (IconToInfoSpacing * Width);
	TempY += TextTopOffset * Height + ItemBorder * Height;
	ProgressBarWidth = Width - (TempX - X) - (IconToInfoSpacing * Width);
	// Select Text Color
	Canvas.SetDrawColor(0, 0, 0, 255);
	// Draw the Perk's Level name
	Canvas.StrLen(PerkName, TempWidth, TempHeight);
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawText(PerkName);
	// Draw the Perk's Level
	if ( PerkLevelString != "" )
	{
		Canvas.StrLen(PerkLevelString, TempWidth, TempHeight);
		Canvas.SetPos(TempX + ProgressBarWidth - TempWidth, TempY);
		Canvas.DrawText(PerkLevelString);
	}
	TempY += TempHeight + (0.04 * Height);
	// Draw Progress Bar
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawTileStretched(ProgressBarBackground, ProgressBarWidth, ProgressBarHeight * Height);
	Canvas.SetPos(TempX + 3.0, TempY + 3.0);
	Canvas.DrawTileStretched(ProgressBarForeground, (ProgressBarWidth - 6.0) * PerkProgress, (ProgressBarHeight * Height) - 6.0);
	if( CurrentVeterancy!=KFPRI.ClientVeteranSkill || CurrentVeterancyLevel!=LevelIndex )
	{
		CurrentVeterancy = KFPRI.ClientVeteranSkill;
		CurrentVeterancyLevel = LevelIndex;
		lb_PerkEffects.SetContent(class<SRVeterancyTypes>(KFPRI.ClientVeteranSkill).Static.GetVetInfoText(LevelIndex,1));
	}
}
function bool ShowPerkMenu(GUIComponent Sender)
{
	if ( PlayerOwner() != none)
		PlayerOwner().ClientOpenMenu(string(class'SRProfilePage'), false);
	return true;
}
defaultproperties
{
	NormalString="Тяжелый"
	HardString="Суицид"
	SuicidalString = "Ад на земле"
	HellOnEarthString = "Судный день"
     Begin Object class=GUIScrollTextBox Name=MOTDScroll
         CharDelay=0.002500
         EOLDelay=0.100000
         OnCreateComponent=MOTDScroll.InternalOnCreateComponent
         WinTop=0.354102
         WinLeft=0.072187
         WinWidth=0.312375
         WinHeight=0.335000
         TabOrder=9
     End Object
     tb_ServerMOTD=GUIScrollTextBox'Masters.SRLobbyMenu.MOTDScroll'
     MaxPlayersOnList=18
     ADBackground=none
     ReadyBox(0)=None
     ReadyBox(1)=None
     ReadyBox(2)=None
     ReadyBox(3)=None
     ReadyBox(4)=None
     ReadyBox(5)=None
     PlayerBox(0)=None
     PlayerBox(1)=None
     PlayerBox(2)=None
     PlayerBox(3)=None
     PlayerBox(4)=None
     PlayerBox(5)=None
     PlayerPerk(0)=None
     PlayerPerk(1)=None
     PlayerPerk(2)=None
     PlayerPerk(3)=None
     PlayerPerk(4)=None
     PlayerPerk(5)=None
     PlayerVetLabel(0)=None
     PlayerVetLabel(1)=None
     PlayerVetLabel(2)=None
     PlayerVetLabel(3)=None
     PlayerVetLabel(4)=None
     PlayerVetLabel(5)=None
     Begin Object class=SRLobbyChat Name=ChatBox
         OnCreateComponent=ChatBox.InternalOnCreateComponent
         WinTop=0.807600
         WinLeft=0.016090
         WinWidth=0.971410
         WinHeight=0.100000
         RenderWeight=0.010000
         TabOrder=1
         OnPreDraw=ChatBox.FloatingPreDraw
         OnRendered=ChatBox.FloatingRendered
         OnHover=ChatBox.FloatingHover
         OnMousePressed=ChatBox.FloatingMousePressed
         OnMouseRelease=ChatBox.FloatingMouseRelease
     End Object
     t_ChatBox=SRLobbyChat'Masters.SRLobbyMenu.ChatBox'
     Begin Object class=SRLobbyFooter Name=BuyFooter
         RenderWeight=0.300000
         TabOrder=8
         bBoundToParent=False
         bScaleToParent=False
         OnPreDraw=BuyFooter.InternalOnPreDraw
     End Object
     t_Footer=SRLobbyFooter'Masters.SRLobbyMenu.BuyFooter'
	 Begin Object class=GUILabel Name=PerkClickAreaNew
      	WinTop=0.432395
        WinLeft=0.488851
        WinWidth=0.444405
        WinHeight=0.437312
		OnClick=ShowPerkMenu
		bAcceptsInput=true
		OnClickSound=CS_Click
	End Object
	PerkClickLabel=GUILabel'Masters.SRLobbyMenu.PerkClickAreaNew'
}
