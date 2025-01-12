//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SRLobbyFooter extends LobbyFooter;

function bool OnFooterClick(GUIComponent Sender)
{
	local GUIController C;
	local PlayerController PC;

	PC = PlayerOwner();
	C = Controller;
	if(Sender == b_Cancel)
	{
		//Kill Window and exit game/disconnect from server
		LobbyMenu(PageOwner).bAllowClose = true;
		C.ViewportOwner.Console.ConsoleCommand("DISCONNECT");
		PC.ClientCloseMenu(true, false);
		C.AutoLoadMenus();
	}
	else if(Sender == b_Ready)
	{
		if ( PC.Level.NetMode == NM_Standalone || !PC.PlayerReplicationInfo.bReadyToPlay )
		{
			//Set Ready
			PC.ServerRestartPlayer();
			PC.PlayerReplicationInfo.bReadyToPlay = True;
			if ( PC.Level.GRI.bMatchHasBegun )
				PC.ClientCloseMenu(true, false);
			b_Ready.Caption = UnreadyString;
		}
		else
		{
			// Spectate map while waiting for players to get ready
			LobbyMenu(PageOwner).bAllowClose = true;
			PC.ClientCloseMenu(true, false);
		}
	}
	else if (Sender == b_Options)
		PC.ClientOpenMenu("KFGUI.KFSettingsPage", false);
	else if (Sender == b_Perks)
		PC.ClientOpenMenu(string(Class'SRInvasionLoginMenu'), false);
	return false;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=PerksButton
         Caption="Main Menu"
         Hint="Go to main menu"
         WinTop=0.966146
         WinLeft=-0.500000
         WinWidth=0.120000
         WinHeight=0.033203
         RenderWeight=2.000000
         TabOrder=2
         bBoundToParent=True
         ToolTip=None

         OnClick=SRLobbyFooter.OnFooterClick
         OnKeyEvent=Cancel.InternalOnKeyEvent
     End Object
     b_Perks=GUIButton'ServerPerks.SRLobbyFooter.PerksButton'

     UnreadyString="View map"
}
