Class SRInvasionLoginMenu extends UT2K4PlayerLoginMenu;

var() noexport  bool                    bNetGame;
var bool bOldSpectator;

var automated   GUIButton               b_Settings, b_Browser, b_Quit, b_Favs,
                                        b_Leave, b_MapVote, b_KickVote, b_MatchSetup, b_Spec, b_Profile;
var             GUIStyles               PlayerStyle;
var array<SRMenuAddition>				AddOnList;
var int									CurTabOrder;

simulated final function GUIButton AddControlButton( string Cap, optional string Hint )
{
	local GUIButton G;
	
	G = GUIButton(AddComponent(string(Class'GUIButton')));
	G.Caption = Cap;
	G.Hint = Hint;
	G.StyleName = "SquareButton";
	G.OnKeyEvent = G.InternalOnKeyEvent;
	G.WinLeft = 0.725;
	G.WinTop = 0.89;
	G.WinWidth = 0.2;
	G.WinHeight = 0.05;
	G.bAutoSize = True;
	G.TabOrder = CurTabOrder++;
	return G;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;
    local string s;
    local eFontScale FS;
	local SRMenuAddition M;

	// Setup panel classes.
	Panels[0].ClassName = string(Class'SRTab_ServerNews');
	Panels[1].ClassName = string(Class'SRTab_MidGamePerks');
	Panels[2].ClassName = string(Class'SRTab_MidGameVoiceChat');
	Panels[3].ClassName = string(Class'SRTab_MidGameHelp');
	Panels[4].ClassName = string(Class'SRTab_MidGameStats');

	// Setup localization.
	Panels[1].Caption = Class'KFInvasionLoginMenu'.Default.Panels[1].Caption;
	Panels[2].Caption = Class'KFInvasionLoginMenu'.Default.Panels[2].Caption;
	Panels[3].Caption = Class'KFInvasionLoginMenu'.Default.Panels[3].Caption;
	Panels[1].Hint = Class'KFInvasionLoginMenu'.Default.Panels[1].Hint;
	Panels[2].Hint = Class'KFInvasionLoginMenu'.Default.Panels[2].Hint;
	Panels[3].Hint = Class'KFInvasionLoginMenu'.Default.Panels[3].Hint;
	b_Spec.Caption=class'KFTab_MidGamePerks'.default.b_Spec.Caption;
	b_MatchSetup.Caption=class'KFTab_MidGamePerks'.default.b_MatchSetup.Caption;
	b_KickVote.Caption=class'KFTab_MidGamePerks'.default.b_KickVote.Caption;
	b_MapVote.Caption=class'KFTab_MidGamePerks'.default.b_MapVote.Caption;
	b_Quit.Caption=class'KFTab_MidGamePerks'.default.b_Quit.Caption;
	b_Favs.Caption=class'KFTab_MidGamePerks'.default.b_Favs.Caption;
	b_Favs.Hint=class'KFTab_MidGamePerks'.default.b_Favs.Hint;
	b_Settings.Caption=class'KFTab_MidGamePerks'.default.b_Settings.Caption;
	b_Browser.Caption=class'KFTab_MidGamePerks'.default.b_Browser.Caption;

 	Super.InitComponent(MyController, MyOwner);

	// Mod menus
	foreach MyController.ViewportOwner.Actor.DynamicActors(class'SRMenuAddition',M)
		if( M.bHasInit )
		{
			AddOnList[AddOnList.Length] = M;
			M.NotifyMenuOpen(Self,MyController);
		}

   	s = GetSizingCaption();

	for ( i = 0; i < Controls.Length; i++ )
    {
    	if ( GUIButton(Controls[i]) != None )
        {
            GUIButton(Controls[i]).bAutoSize = true;
            GUIButton(Controls[i]).SizingCaption = s;
            GUIButton(Controls[i]).AutoSizePadding.HorzPerc = 0.04;
            GUIButton(Controls[i]).AutoSizePadding.VertPerc = 0.5;
        }
    }
    s = class'KFTab_MidGamePerks'.default.PlayerStyleName;
    PlayerStyle = MyController.GetStyle(s, fs);
	InitGRI();
}

function Opened(GUIComponent Sender)
{
	local int i;

	Super.Opened(Sender);
	for( i=0; i<AddOnList.Length; ++i )
		AddOnList[i].NotifyMenuShown();
}
event Closed(GUIComponent Sender, bool bCancelled)
{
	local int i;

	Super.Closed(Sender,bCancelled);
	for( i=0; i<AddOnList.Length; ++i )
		AddOnList[i].NotifyMenuClosed();
}

function string GetSizingCaption()
{
    local int i;
    local string s;

    for ( i = 0; i < Controls.Length; i++ )
    {
        if ( GUIButton(Controls[i]) != none )
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
        return;

    bInit = False;

    bNetGame = PC.Level.NetMode != NM_StandAlone;

    if ( bNetGame )
        b_Leave.Caption = class'KFTab_MidGamePerks'.default.LeaveMPButtonText;
    else b_Leave.Caption = class'KFTab_MidGamePerks'.default.LeaveSPButtonText;

	bOldSpectator = PC.PlayerReplicationInfo.bOnlySpectator;
    if ( bOldSpectator )
        b_Spec.Caption = class'KFTab_MidGamePerks'.default.JoinGameButtonText;
    else b_Spec.Caption = class'KFTab_MidGamePerks'.default.SpectateButtonText;

    SetupGroups();
	//InitLists();
}
function float ItemHeight(Canvas C)
{
    local float XL, YL, H;
    local eFontScale f;

    f=FNS_Medium;

    PlayerStyle.TextSize(C, MSAT_Blurry, "Wqz, ", XL, H, F);

    if ( C.ClipX > 640 && bNetGame )
        PlayerStyle.TextSize(C, MSAT_Blurry, "Wqz, ", XL, YL, FNS_Small);

    H += YL;
    H += (H * 0.2);

    return h;
}

function SetupGroups()
{
    local PlayerController PC;

    PC = PlayerOwner();

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
		if ( Components[i].bVisible && GUIButton(Components[i]) != none )
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
		if ( !Components[i].bVisible || GUIButton(Components[i]) == none )
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
                if ( Components[i].bVisible && GUIButton(Components[i]) != none )
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

// See if we already have this server in our favorites
function bool CurrentServerIsInFavorites()
{
    local ExtendedConsole.ServerFavorite Fav;
    local string address,portString;

    // Get current network address
    if ( PlayerOwner() == None )
        return true;

    address = PlayerOwner().GetServerNetworkAddress();

    if( address == "" )
        return true; // slightly hacky - dont want to add "none"!

    // Parse text to find IP and possibly port number
    if ( Divide(address, ":", Fav.IP, portstring) )
        Fav.Port = int(portString);
    else Fav.IP = address;

    return class'KFConsole'.static.InFavorites(Fav);
}
function bool ButtonClicked(GUIComponent Sender)
{
    local PlayerController PC;
 
    PC = PlayerOwner();

	if ( Sender == b_Settings )
    {
        // Settings
        Controller.OpenMenu(Controller.GetSettingsPage());
    }
    else if ( Sender == b_Browser )
    {
        // Server browser
        Controller.OpenMenu("KFGUI.KFServerBrowser");
    }
    else if ( Sender == b_Leave )
    {
		// Forfeit/Disconnect
		PC.ConsoleCommand("DISCONNECT");
        KFGUIController(Controller).ReturnToMainMenu();
    }
    else if ( Sender == b_Favs )
    {
        // Add this server to favorites
        PC.ConsoleCommand( "ADDCURRENTTOFAVORITES" );
        b_Favs.MenuStateChange(MSAT_Disabled);
    }
    else if ( Sender == b_Quit )
    {
        // Quit game
        Controller.OpenMenu(Controller.GetQuitPage());
    }
    else if ( Sender == b_MapVote )
    {
        // Map voting
        Controller.OpenMenu(Controller.MapVotingMenu);
    }
    else if ( Sender == b_KickVote )
    {
        // Kick voting
        Controller.OpenMenu(Controller.KickVotingMenu);
    }
    else if ( Sender == b_MatchSetup )
    {
        // Match setup
        Controller.OpenMenu(Controller.MatchSetupMenu);
    }
	else if ( Sender == b_Spec )
	{
		Controller.CloseMenu();

		// Spectate/rejoin
		if ( PC.PlayerReplicationInfo.bOnlySpectator )
			PC.BecomeActivePlayer();
		else PC.BecomeSpectator();
	}
	else if( Sender==b_Profile )
	{
		// Profile
		Controller.OpenMenu(string(Class'SRProfilePage'));
	}
	
	return true;
}

function bool InternalOnPreDraw(Canvas C)
{
	local GameReplicationInfo GRI;
	local PlayerController PC;

	GRI = GetGRI();

    if ( GRI != none )
	{
		if ( bInit )
			InitGRI();

		SetButtonPositions(C);

		PC = PlayerOwner();
		if ( (PC.myHUD == None || !PC.myHUD.IsInCinematic()) && GRI != none && GRI.bMatchHasBegun && !PC.IsInState('GameEnded') )
        	EnableComponent(b_Spec);
		else DisableComponent(b_Spec);
		
		if( PC.PlayerReplicationInfo!=None && bOldSpectator!=PC.PlayerReplicationInfo.bOnlySpectator )
		{
			bOldSpectator = !bOldSpectator;
			if ( bOldSpectator )
				b_Spec.Caption = class'KFTab_MidGamePerks'.default.JoinGameButtonText;
			else b_Spec.Caption = class'KFTab_MidGamePerks'.default.SpectateButtonText;
		}
	}
	return false;
}
function RemoveMultiplayerTabs(GameInfo Game);

defaultproperties
{
     Begin Object Class=GUIButton Name=SettingsButton
         WinTop=0.900000
         WinLeft=0.194420
         WinWidth=0.147268
         WinHeight=0.035000
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnClick=SRInvasionLoginMenu.ButtonClicked
         OnKeyEvent=SettingsButton.InternalOnKeyEvent
     End Object
     b_Settings=GUIButton'ServerPerks.SRInvasionLoginMenu.SettingsButton'

     Begin Object Class=GUIButton Name=BrowserButton
         bAutoSize=True
         WinTop=0.850000
         WinLeft=0.375000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnClick=SRInvasionLoginMenu.ButtonClicked
         OnKeyEvent=BrowserButton.InternalOnKeyEvent
     End Object
     b_Browser=GUIButton'ServerPerks.SRInvasionLoginMenu.BrowserButton'

     Begin Object Class=GUIButton Name=QuitGameButton
         bAutoSize=True
         WinTop=0.870000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=50
         OnClick=SRInvasionLoginMenu.ButtonClicked
         OnKeyEvent=QuitGameButton.InternalOnKeyEvent
     End Object
     b_Quit=GUIButton'ServerPerks.SRInvasionLoginMenu.QuitGameButton'

     Begin Object Class=GUIButton Name=FavoritesButton
         bAutoSize=True
         WinTop=0.870000
         WinLeft=0.025000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=2
         bBoundToParent=True
         bScaleToParent=True
         OnClick=SRInvasionLoginMenu.ButtonClicked
         OnKeyEvent=FavoritesButton.InternalOnKeyEvent
     End Object
     b_Favs=GUIButton'ServerPerks.SRInvasionLoginMenu.FavoritesButton'

     Begin Object Class=GUIButton Name=LeaveMatchButton
         bAutoSize=True
         WinTop=0.870000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=49
         bBoundToParent=True
         bScaleToParent=True
         OnClick=SRInvasionLoginMenu.ButtonClicked
         OnKeyEvent=LeaveMatchButton.InternalOnKeyEvent
     End Object
     b_Leave=GUIButton'ServerPerks.SRInvasionLoginMenu.LeaveMatchButton'

     Begin Object Class=GUIButton Name=MapVotingButton
         bAutoSize=True
         WinTop=0.890000
         WinLeft=0.025000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=3
         OnClick=SRInvasionLoginMenu.ButtonClicked
         OnKeyEvent=MapVotingButton.InternalOnKeyEvent
     End Object
     b_MapVote=GUIButton'ServerPerks.SRInvasionLoginMenu.MapVotingButton'

     Begin Object Class=GUIButton Name=KickVotingButton
         bAutoSize=True
         WinTop=0.890000
         WinLeft=0.375000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=4
         OnClick=SRInvasionLoginMenu.ButtonClicked
         OnKeyEvent=KickVotingButton.InternalOnKeyEvent
     End Object
     b_KickVote=GUIButton'ServerPerks.SRInvasionLoginMenu.KickVotingButton'

     Begin Object Class=GUIButton Name=MatchSetupButton
         bAutoSize=True
         WinTop=0.890000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=5
         OnClick=SRInvasionLoginMenu.ButtonClicked
         OnKeyEvent=MatchSetupButton.InternalOnKeyEvent
     End Object
     b_MatchSetup=GUIButton'ServerPerks.SRInvasionLoginMenu.MatchSetupButton'

     Begin Object Class=GUIButton Name=SpectateButton
         bAutoSize=True
         WinTop=0.890000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=6
         OnClick=SRInvasionLoginMenu.ButtonClicked
         OnKeyEvent=SpectateButton.InternalOnKeyEvent
     End Object
     b_Spec=GUIButton'ServerPerks.SRInvasionLoginMenu.SpectateButton'

     Begin Object Class=GUIButton Name=ProfileButton
         Caption="Profile"
         bAutoSize=True
         WinTop=0.890000
         WinLeft=0.725000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=7
         OnClick=SRInvasionLoginMenu.ButtonClicked
         OnKeyEvent=ProfileButton.InternalOnKeyEvent
     End Object
     b_Profile=GUIButton'ServerPerks.SRInvasionLoginMenu.ProfileButton'

     CurTabOrder=8
     Panels(0)=(Caption="News",Hint="View server news")
     Panels(4)=(Caption="Stats",Hint="View your current stats of this server")
     OnPreDraw=SRInvasionLoginMenu.InternalOnPreDraw
}
