class RulesTab extends MidGamePanel;
var bool bClean;
var automated GUISectionBackground i_BGSec;
var automated GUIScrollTextBox lb_Text;
var() config array<string> RulesLine;
var(ServerNews) localized string DefaultText;
var bool bReceivedRules;
var automated GUISectionBackground	i_BGPerks;
var	automated SRStatListBox	lb_PerkSelect;
var automated   GUIButton			   b_Team, b_Settings, b_Browser, b_Quit, b_Favs,
										b_Leave, b_MapVote, b_KickVote, b_MatchSetup, b_Spec, b_Profile;
var() noexport  bool					bTeamGame, bFFAGame, bNetGame;
var localized   string				  LeaveMPButtonText, LeaveSPButtonText, SpectateButtonText, JoinGameButtonText;
var localized   array<string>		   ContextItems, DefaultItems;
var localized   string				  KickPlayer, BanPlayer;
var localized   string				  BuddyText;
var localized   string				  RedTeam, BlueTeam;
var			 string				  PlayerStyleName;
var			 GUIStyles			   PlayerStyle;
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;
	local int n;
	local string s;
	local eFontScale FS;
	Super.InitComponent(MyController, MyOwner);
	s = GetSizingCaption();
	for ( i = 0; i < Controls.Length; i++ )
	{
		if ( GUIButton(Controls[i]) != None && Controls[i] != b_Team )
		{
			GUIButton(Controls[i]).bAutoSize = true;
			GUIButton(Controls[i]).SizingCaption = s;
			GUIButton(Controls[i]).AutoSizePadding.HorzPerc = 0.04;
			GUIButton(Controls[i]).AutoSizePadding.VertPerc = 0.5;
		}
	}
	PlayerStyle = MyController.GetStyle(PlayerStyleName, fs);
    bClean = true;
    lb_Text.SetContent(DefaultText);
	lb_Text.OnDraw = OnLabelDraw;
	n = RulesLine.Length;
    for(i=0; i<n; i++)
    {
		lb_Text.AddText(RulesLine[i]);
    }
    lb_Text.AddText(" ");
    lb_Text.MyScrollBar.GripPos = 0;
    lb_Text.MyScrollBar.CurPos = 0;
    lb_Text.MyScrollBar.MyList.SetTopItem(0);
    lb_Text.MyScrollBar.AlignThumb();
    OnShow = Shown;
}
function bool OnLabelDraw(Canvas c)
{
    C.Style = 1;
    C.Font = class'ROHUD'.Static.GetSmallMenuFont(C);

    return false;
}
function Shown()
{
    lb_Text.MyScrollBar.GripPos = 0;
    lb_Text.MyScrollBar.CurPos = 0;

       lb_Text.MyScrollBar.MyList.SetTopItem(0);
       lb_Text.MyScrollBar.AlignThumb();
}
function string GetSizingCaption()
{
	local int i;
	local string s;

	for ( i = 0; i < Controls.Length; i++ )
	{
		if ( GUIButton(Controls[i]) != none && Controls[i] != b_Team )
		{
			if ( s == "" || Len(GUIButton(Controls[i]).Caption) > Len(s) )
			{
				s = GUIButton(Controls[i]).Caption;
			}
		}
	}

	return s;
}
function GameReplicationInfo GetGRI()
{
	return PlayerOwner().GameReplicationInfo;
}
function InitGRI()
{
	local PlayerController PC;
	local GameReplicationInfo GRI;
	GRI = GetGRI();
	PC = PlayerOwner();
	if ( PC == none || PC.PlayerReplicationInfo == none || GRI == none )
	{
		return;
	}
	bInit = False;
	if ( !bTeamGame && !bFFAGame )
	{
		if ( GRI.bTeamGame )
		{
			bTeamGame = True;
		}
		else if ( !(GRI.GameClass ~= "Engine.GameInfo") )
		{
			bFFAGame = True;
		}
	}
	bNetGame = PC.Level.NetMode != NM_StandAlone;
	if ( bNetGame )
	{
		b_Leave.Caption = LeaveMPButtonText;
	}
	else
	{
		b_Leave.Caption = LeaveSPButtonText;
	}
	if ( PC.PlayerReplicationInfo.bOnlySpectator )
	{
		b_Spec.Caption = JoinGameButtonText;
	}
	else
	{
		b_Spec.Caption = SpectateButtonText;
	}
	SetupGroups();
}

function float ItemHeight(Canvas C)
{
	local float XL, YL, H;
	local eFontScale f;
	if ( bTeamGame )
	{
		f=FNS_Medium;
	}
	else
	{
		f=FNS_Large;
	}
	PlayerStyle.TextSize(C, MSAT_Blurry, "Wqz, ", XL, H, F);
	if ( C.ClipX > 640 && bNetGame )
	{
		PlayerStyle.TextSize(C, MSAT_Blurry, "Wqz, ", XL, YL, FNS_Small);
	}
	H += YL;
	H += (H * 0.2);
	return h;
}
function SetupGroups()
{
	local int i;
	local PlayerController PC;
	PC = PlayerOwner();
	if ( bTeamGame )
	{
		if ( PC.GameReplicationInfo != None && PC.GameReplicationInfo.bNoTeamChanges )
		{
			RemoveComponent(b_Team,true);
		}
	}
	else if ( bFFAGame )
	{
		RemoveComponent(b_Team, true);
	}
	else
	{
		for ( i = 0; i < Controls.Length; i++ )
		{
			if ( Controls[i] != i_BGPerks && Controls[i] != lb_PerkSelect )
			{
				RemoveComponent(Controls[i], True);
			}
		}
	}
	if ( PC.Level.NetMode != NM_Client )
	{
		RemoveComponent(b_Favs);
		RemoveComponent(b_Browser);
	}
	else if ( CurrentServerIsInFavorites() )
	{
		DisableComponent(b_Favs);
	}

	if ( PC.Level.NetMode == NM_StandAlone )
	{
		RemoveComponent(b_MapVote, True);
		RemoveComponent(b_MatchSetup, True);
		RemoveComponent(b_KickVote, True);
	}
	else if ( PC.VoteReplicationInfo != None )
	{
		if ( !PC.VoteReplicationInfo.MapVoteEnabled() )
		{
			RemoveComponent(b_MapVote,True);
		}

		if ( !PC.VoteReplicationInfo.KickVoteEnabled() )
		{
			RemoveComponent(b_KickVote);
		}

		if ( !PC.VoteReplicationInfo.MatchSetupEnabled() )
		{
			RemoveComponent(b_MatchSetup);
		}
	}
	else
	{
		RemoveComponent(b_MapVote);
		RemoveComponent(b_KickVote);
		RemoveComponent(b_MatchSetup);
	}
	RemapComponents();
}
function SetButtonPositions(Canvas C)
{
	local int i, j, ButtonsPerRow, ButtonsLeftInRow, NumButtons;
	local float Width, Height, Center, X, Y, YL, ButtonSpacing;
	Width = b_Settings.ActualWidth();
	Height = b_Settings.ActualHeight();
	Center = ActualLeft() + (ActualWidth() / 2.0);
	ButtonSpacing = Width * 0.05;
	YL = Height * 1.2;
	Y = b_Settings.ActualTop();
	ButtonsPerRow = ActualWidth() / (Width + ButtonSpacing);
	ButtonsLeftInRow = ButtonsPerRow;
	for ( i = 0; i < Components.Length; i++)
	{
		if ( Components[i].bVisible && GUIButton(Components[i]) != none && Components[i] != b_Team )
		{
			NumButtons++;
		}
	}
	if ( NumButtons < ButtonsPerRow )
	{
		X = Center - (((Width * float(NumButtons)) + (ButtonSpacing * float(NumButtons - 1))) * 0.5);
	}
	else if ( ButtonsPerRow > 1 )
	{
		X = Center - (((Width * float(ButtonsPerRow)) + (ButtonSpacing * float(ButtonsPerRow - 1))) * 0.5);
	}
	else
	{
		X = Center - Width / 2.0;
	}
	for ( i = 0; i < Components.Length; i++)
	{
		if ( !Components[i].bVisible || GUIButton(Components[i]) == none || Components[i]==b_Team )
		{
			continue;
		}
		Components[i].SetPosition( X, Y, Width, Height, true );
		if ( --ButtonsLeftInRow > 0 )
		{
			X += Width + ButtonSpacing;
		}
		else
		{
			Y += YL;
			for ( j = i + 1; j < Components.Length && ButtonsLeftInRow < ButtonsPerRow; j++)
			{
				if ( Components[i].bVisible && GUIButton(Components[i]) != none && Components[i] != b_Team )
				{
					ButtonsLeftInRow++;
				}
			}
			if ( ButtonsLeftInRow > 1 )
			{
				X = Center - (((Width * float(ButtonsLeftInRow)) + (ButtonSpacing * float(ButtonsLeftInRow - 1))) * 0.5);
			}
			else
			{
				X = Center - Width / 2.0;
			}
		}
	}
}
function bool CurrentServerIsInFavorites()
{
	local ExtendedConsole.ServerFavorite Fav;
	local string address,portString;
	if ( PlayerOwner() == None )
	{
		return true;
	}
	address = PlayerOwner().GetServerNetworkAddress();
	if( address == "" )
	{
		return true;
	}
	if ( Divide(address, ":", Fav.IP, portstring) )
	{
		Fav.Port = int(portString);
	}
	else
	{
		Fav.IP = address;
	}
	return class'KFConsole'.static.InFavorites(Fav);
}
function bool ButtonClicked(GUIComponent Sender)
{
	local PlayerController PC;
	local GUIController C;
	C = Controller;
	PC = PlayerOwner();
	if ( Sender == b_Settings )
	{
		Controller.OpenMenu(Controller.GetSettingsPage());
	}
	else if ( Sender == b_Browser )
	{
		Controller.OpenMenu("KFGUI.KFServerBrowser");
	}
	else if ( Sender == b_Leave )
	{
		PC.ConsoleCommand("DISCONNECT");
		KFGUIController(C).ReturnToMainMenu();
	}
	else if ( Sender == b_Favs )
	{
		PC.ConsoleCommand( "ADDCURRENTTOFAVORITES" );
		b_Favs.MenuStateChange(MSAT_Disabled);
	}
	else if ( Sender == b_Quit )
	{
		Controller.OpenMenu(Controller.GetQuitPage());
	}
	else if ( Sender == b_MapVote )
	{
		Controller.OpenMenu(Controller.MapVotingMenu);
	}
	else if ( Sender == b_KickVote )
	{
		Controller.OpenMenu(Controller.KickVotingMenu);
	}
	else if ( Sender == b_MatchSetup )
	{
		Controller.OpenMenu(Controller.MatchSetupMenu);
	}
	else if ( Sender == b_Spec )
	{
		Controller.CloseMenu();
		if ( PC.PlayerReplicationInfo.bOnlySpectator )
		{
			PC.BecomeActivePlayer();
		}
		else
		{
			PC.BecomeSpectator();
		}
	}
	else if( Sender==b_Profile )
	{
		Controller.OpenMenu(string(Class'SRProfilePage'));
	}
	return true;
}
function bool InternalOnPreDraw(Canvas C)
{
	local GameReplicationInfo GRI;
	GRI = GetGRI();
	if ( GRI != none )
	{
		if ( bInit )
		{
			InitGRI();
		}
		SetButtonPositions(C);
		if ( (PlayerOwner().myHUD == None || !PlayerOwner().myHUD.IsInCinematic()) && GRI != none && GRI.bMatchHasBegun && !PlayerOwner().IsInState('GameEnded') )
		{
			EnableComponent(b_Spec);
		}
		else
		{
			DisableComponent(b_Spec);
		}
	}
	return false;
}
function bool ContextMenuOpened(GUIContextMenu Menu)
{
	local GUIList List;
	local PlayerReplicationInfo PRI;
	local byte Restriction;
	local GameReplicationInfo GRI;
	GRI = GetGRI();
	if ( GRI == None )
	{
		return false;
	}
	List = GUIList(Controller.ActiveControl);
	if ( List == None )
	{
		log(Name @ "ContextMenuOpened active control was not a list - active:" $ Controller.ActiveControl.Name);
		return False;
	}
	if ( !List.IsValid() )
	{
		return False;
	}
	PRI = GRI.FindPlayerByID(int(List.GetExtra()));
	if ( PRI == None || PRI.bBot || PlayerIDIsMine(PRI.PlayerID) )
	{
		return False;
	}
	Restriction = PlayerOwner().ChatManager.GetPlayerRestriction(PRI.PlayerID);
	if ( bool(Restriction & 1) )
	{
		Menu.ContextItems[0] = ContextItems[0];
	}
	else
	{
		Menu.ContextItems[0] = DefaultItems[0];
	}
	if ( bool(Restriction & 2) )
	{
		Menu.ContextItems[1] = ContextItems[1];
	}
	else
	{
		Menu.ContextItems[1] = DefaultItems[1];
	}
	if ( bool(Restriction & 4) )
	{
		Menu.ContextItems[2] = ContextItems[2];
	}
	else
	{
		Menu.ContextItems[2] = DefaultItems[2];
	}

	if ( bool(Restriction & 8) )
	{
		Menu.ContextItems[3] = ContextItems[3];
	}
	else
	{
		Menu.ContextItems[3] = DefaultItems[3];
	}
	Menu.ContextItems[4] = "-";
	Menu.ContextItems[5] = BuddyText;
	if ( PlayerOwner().PlayerReplicationInfo.bAdmin )
	{
		Menu.ContextItems[6] = "-";
		Menu.ContextItems[7] = KickPlayer $ "["$List.Get() $ "]";
		Menu.ContextItems[8] = BanPlayer $ "["$List.Get() $ "]";
	}
	else if ( Menu.ContextItems.Length > 6 )
	{
		Menu.ContextItems.Remove(6,Menu.ContextItems.Length - 6);
	}
	return True;
}
function ContextClick(GUIContextMenu Menu, int ClickIndex)
{
	local bool bUndo;
	local byte Type;
	local GUIList List;
	local PlayerController PC;
	local PlayerReplicationInfo PRI;
	local GameReplicationInfo GRI;
	GRI = GetGRI();
	if ( GRI == None )
	{
		return;
	}
	PC = PlayerOwner();
	bUndo = Menu.ContextItems[ClickIndex] == ContextItems[ClickIndex];
	List = GUIList(Controller.ActiveControl);
	if ( List == None )
	{
		return;
	}
	PRI = GRI.FindPlayerById(int(List.GetExtra()));
	if ( PRI == None )
	{
		return;
	}
	if ( ClickIndex > 5 ) // Admin stuff
	{
		switch ( ClickIndex )
		{
			case 6:
			case 7: PC.AdminCommand("admin kick"@List.GetExtra()); break;
			case 8: PC.AdminCommand("admin kickban"@List.GetExtra()); break;
		}

		return;
	}
	if ( ClickIndex > 3 )
	{
		Controller.AddBuddy(List.Get());

		return;
	}
	Type = 1 << ClickIndex;
	if ( bUndo )
	{
		if ( PC.ChatManager.ClearRestrictionID(PRI.PlayerID, Type) )
		{
			PC.ServerChatRestriction(PRI.PlayerID, PC.ChatManager.GetPlayerRestriction(PRI.PlayerID));
			ModifiedChatRestriction(Self, PRI.PlayerID);
		}
	}
	else
	{
		if ( PC.ChatManager.AddRestrictionID(PRI.PlayerID, Type) )
		{
			PC.ServerChatRestriction(PRI.PlayerID, PC.ChatManager.GetPlayerRestriction(PRI.PlayerID));
			ModifiedChatRestriction(Self, PRI.PlayerID);
		}
	}
}
defaultproperties
{
     Begin Object Class=GUISectionBackground Name=BGSec
         Caption="Правила Сервера"
         WinTop=0.018000
         WinLeft=0.019240
         WinWidth=0.961520
         WinHeight=0.798982
         bFillClient=True
         OnPreDraw=BGSec.InternalPreDraw
     End Object
     i_BGSec=GUISectionBackground'RulesTab.BGSec'
     Begin Object Class=GUIScrollTextBox Name=InfoText
         CharDelay=0.002500
         EOLDelay=0.000000
         WinTop=0.082000
         WinLeft=0.052000
         WinWidth=0.945000
         WinHeight=0.760000
         bNoTeletype=True
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
         OnCreateComponent=InfoText.InternalOnCreateComponent
     End Object
     lb_Text=GUIScrollTextBox'RulesTab.InfoText'
    RulesLine(0) = "НА СЕРВЕРЕ ЗАПРЕЩАЕТСЯ:"
    RulesLine(1) = " - Воровство оружия"
    RulesLine(2) = " - Блок респа"
    RulesLine(3) = " - Использование вредоносных программ, нарушающих работоспособность сервера"
	RulesLine(4) = " - Использование читов"
	RulesLine(5) = " - Использование багов"
	RulesLine(6) = " - Прокачка перков неигровым способом"
	RulesLine(7) = " - Играть со стандартным ником"
	RulesLine(8) = " - Использование недопустимых никнеймов"
	RulesLine(9) = " - Клевета"
	RulesLine(10) = " - Умышленный огонь по своим"
	RulesLine(11) = " - Умышленное убийство игроков"
	RulesLine(12) = " - Оскорбления родителей - наказывается перманентным баном на всем проекте"
	RulesLine(13) = " - Флуд и оффтоп"
	RulesLine(14) = " - Оскорбления игроков и администраторов"
	RulesLine(15) = " - Голосование за кик без причины"
	RulesLine(16) = " - Разжигание межнациональной/межрелигиозной розни, любые националистические/фашистские ники , высказывания"
	RulesLine(17) = ""
	RulesLine(18) = "=================================="
	RulesLine(19) = ""
	RulesLine(20) = "Использование заполовиненной двери НЕ СЧИТАЕТСЯ БАГОМ"
	RulesLine(21) = ""
	RulesLine(22) = "=================================="
    RulesLine(23) = "It's forbidden on WTF server:"
    RulesLine(24) = " - Weapon theft"
    RulesLine(25) = " - Monsters respawn blocking"
    RulesLine(26) = " - Using server efficiency disturbing soft"
	RulesLine(27) = " - Using cheats"
	RulesLine(28) = " - Using Bugs"
	RulesLine(29) = " - Leveling perk in no-playing way"
	RulesLine(30) = " - Playing with standart nicknames"
	RulesLine(31) = " - Playing with intolerant or unreadable nicknames"
	RulesLine(32) = " - Lying, slander"
	RulesLine(33) = " - Intentional friendly fire"
	RulesLine(34) = " - Intentional teamkill"
	RulesLine(35) = " - Insults of parents - it is punishable by a permanent ban for the all project"
	RulesLine(36) = " - Flood & offtop"
	RulesLine(37) = " - Insulting players or administrators"
	RulesLine(38) = " - Votekick without a reason"
	RulesLine(39) = "No racism or prejudice towards any nationality or religion - Instant Permanent Ban"
	RulesLine(40) = ""
	RulesLine(41) = "=================================="
	RulesLine(42) = ""
	RulesLine(43) = "Using halfed door DON'T count as a bug"
	RulesLine(44) = ""
	RulesLine(45) = "=================================="
	PlayerStyleName="TextLabel"
	OnPreDraw=InternalOnPreDraw
	PropagateVisibility=False
	WinWidth=.5
	WinHeight=.75
	WinTop=0.125
	WinLeft=0.25
	LeaveMPButtonText="Отключиться"
	SpectateButtonText="Наблюдать"
	JoinGameButtonText="Войти"
	Begin Object Class=GUIContextMenu name=PlayerListContextMenu
		OnSelect=ContextClick
		OnOpen=ContextMenuOpened
	End Object
	ContextMenu=PlayerListContextMenu
	KickPlayer="Kick "
	BanPlayer="Ban "
	Begin Object Class=GUIButton Name=SettingsButton
		Caption="Настройки"
		StyleName="SquareButton"
		OnClick=ButtonClicked
  		WinWidth=0.147268
		WinHeight=0.048769
		WinLeft=0.194420
		WinTop=0.878657
		TabOrder=0
		bBoundToParent=true
		bScaleToParent=true
	End Object
	b_Settings=SettingsButton
	Begin Object Class=GUIButton Name=BrowserButton
		Caption="Сервера"
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.20000
		WinHeight=0.05000
		WinLeft=0.375000
		WinTop=0.85000//0.675
		bAutoSize=True
		TabOrder=1
		bBoundToParent=true
		bScaleToParent=true
	End Object
	b_Browser=BrowserButton
	Begin Object Class=GUIButton Name=LeaveMatchButton
		Caption=""
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.20000
		WinHeight=0.05000
		WinLeft=0.7250000
		WinTop=0.87
		bAutoSize=True
		TabOrder=10
		bBoundToParent=true
		bScaleToParent=true
	End Object
	b_Leave=LeaveMatchButton
	Begin Object Class=GUIButton Name=FavoritesButton
		Caption="В избранное"
		Hint="Add this server to your Favorites"
		StyleName="SquareButton"
		WinWidth=0.20000
		WinHeight=0.05000
		WinLeft=0.02500
		WinTop=0.870
		bBoundToParent=true
		bScaleToParent=true
		OnClick=ButtonClicked
		bAutoSize=True
		TabOrder=3
	End Object
	b_Favs=FavoritesButton
	Begin Object Class=GUIButton Name=QuitGameButton
		Caption="Выход"
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.20000
		WinHeight=0.05000
		WinLeft=0.725000
		WinTop=0.870
		bAutoSize=True
		TabOrder=11
	End Object
	b_Quit=QuitGameButton
	Begin Object Class=GUIButton Name=MapVotingButton
		Caption="Карты"
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.20000
		WinHeight=0.050000
		WinLeft=0.025000
		WinTop=0.890
		bAutoSize=True
		TabOrder=5
	End Object
	b_MapVote=MapVotingButton
	Begin Object Class=GUIButton Name=KickVotingButton
		Caption="Исключение"
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.20000
		WinHeight=0.050000
		WinLeft=0.375000
		WinTop=0.890
		bAutoSize=True
		TabOrder=6
	End Object
	b_KickVote=KickVotingButton
	Begin Object Class=GUIButton Name=MatchSetupButton
		Caption="Match Setup"
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.20000
		WinHeight=0.050000
		WinLeft=0.725000
		WinTop=0.890
		bAutoSize=True
		TabOrder=7
	End Object
	b_MatchSetup=MatchSetupButton
	Begin Object Class=GUIButton Name=SpectateButton
		Caption="Наблюдать"
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.20000
		WinHeight=0.050000
		WinLeft=0.725000
		WinTop=0.890
		bAutoSize=True
		TabOrder=9
	End Object
	b_Spec=SpectateButton
	Begin Object Class=GUIButton Name=ProfileButton
		Caption="Профиль"
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.20000
		WinHeight=0.050000
		WinLeft=0.725000
		WinTop=0.890
		bAutoSize=True
		TabOrder=10
	End Object
	b_Profile=ProfileButton
}