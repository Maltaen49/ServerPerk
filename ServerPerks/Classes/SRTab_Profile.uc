class SRTab_Profile extends KFTab_Profile;

var string ChangedCharacter,ClientRepChar;

function bool InternalDraw(Canvas canvas)
{
	local PlayerController PC;

	PC = PlayerOwner();
	if( PC.PlayerReplicationInfo!=None && ClientRepChar!=PC.PlayerReplicationInfo.CharacterName )
		SetPlayerRec(); // Delayed replication setup.

	return Super.InternalDraw(Canvas);
}

function UpdateScroll()
{
	if( PlayerRec.TextName!="" )
		lb_Scroll.SetContent(PlayerRec.TextName);
	else Super.UpdateScroll();
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
	ChangedCharacter = "";

	if ( Sender == i_Portrait )
		SetPlayerRec();
}

function bool PickModel(GUIComponent Sender)
{
	if ( Controller.OpenMenu(string(Class'SRModelSelect'), PlayerRec.DefaultName, Eval(Controller.CtrlPressed, PlayerRec.Race, "")) )
	{
		Controller.ActivePage.OnClose = ModelSelectClosed;
	}

	return true;
}

function SetPlayerRec()
{
	local PlayerController PC;

	PC = PlayerOwner();
	if( ChangedCharacter!="" )
		sChar = ChangedCharacter;
	else if( PC.PlayerReplicationInfo!=None )
		sChar = PC.PlayerReplicationInfo.CharacterName;

	if( PC.PlayerReplicationInfo!=None )
		ClientRepChar = PC.PlayerReplicationInfo.CharacterName;

	PlayerRec = Class'xUtil'.Static.FindPlayerRecord(sChar);
	UpdateScroll();
	ShowSpinnyDude();
}

function ShowPanel(bool bShow)
{
	local ClientPerkRepLink S;

	if ( bShow )
	{
		if ( bInit )
		{
			bRenderDude = True;
			bInit = False;
		}

		if ( PlayerOwner() != none )
		{
			S = Class'ClientPerkRepLink'.Static.FindStats(PlayerOwner());
			if ( S!=none )
			{
				// Initialize the List
				lb_PerkSelect.List.InitList(None);
				lb_PerkProgress.List.InitList();
			}
		}
	}
	lb_PerkSelect.SetPosition(i_BGPerks.WinLeft + 6.0 / float(Controller.ResX),
						  	  i_BGPerks.WinTop + 38.0 / float(Controller.ResY),
							  i_BGPerks.WinWidth - 10.0 / float(Controller.ResX),
							  i_BGPerks.WinHeight - 35.0 / float(Controller.ResY),
							  true);

	SetVisibility(bShow);
}

function SaveSettings()
{
	local PlayerController PC;
	local ClientPerkRepLink S;

	PC = PlayerOwner();
	S = Class'ClientPerkRepLink'.Static.FindStats(PC);

	if ( ChangedCharacter!="" )
	{
		if( S!=None )
			S.SelectedCharacter(ChangedCharacter);
		else
		{
			PC.ConsoleCommand("ChangeCharacter"@ChangedCharacter);
			if ( !PC.IsA('xPlayer') )
				PC.UpdateURL("Character", ChangedCharacter, True);

			if ( PlayerRec.Sex ~= "Female" )
				PC.UpdateURL("Sex", "F", True);
			else PC.UpdateURL("Sex", "M", True);
		}
		ChangedCharacter = "";
	}

	if ( lb_PerkSelect.GetIndex()>=0 && S!=None )
		S.ServerSelectPerk(S.CachePerks[lb_PerkSelect.GetIndex()].PerkClass);
}

function ModelSelectClosed( optional bool bCancelled )
{
	local string str;

	if ( bCancelled )
		return;

	str = Controller.ActivePage.GetDataString();
	if ( str != "" )
	{
		ChangedCharacter = str;
		SetPlayerRec();
	}
}

function OnPerkSelected(GUIComponent Sender)
{
	local ClientPerkRepLink ST;
	local byte Idx;
	local string S;

	ST = Class'ClientPerkRepLink'.Static.FindStats(PlayerOwner());
	if ( ST==None || ST.CachePerks.Length==0 )
	{
		if( ST!=None )
			ST.ServerRequestPerks();
		lb_PerkEffects.SetContent("Please wait while your client is loading the perks...");
	}
	else
	{
		Idx = lb_PerkSelect.GetIndex();
		if( ST.CachePerks[Idx].CurrentLevel==0 )
			S = ST.CachePerks[Idx].PerkClass.Static.GetVetInfoText(0,1);
		else if( ST.CachePerks[Idx].CurrentLevel==ST.MaximumLevel )
			S = ST.CachePerks[Idx].PerkClass.Static.GetVetInfoText(ST.CachePerks[Idx].CurrentLevel-1,1);
		else S = ST.CachePerks[Idx].PerkClass.Static.GetVetInfoText(ST.CachePerks[Idx].CurrentLevel-1,1)$Class'SRTab_MidGamePerks'.Default.NextInfoStr$ST.CachePerks[Idx].PerkClass.Static.GetVetInfoText(ST.CachePerks[Idx].CurrentLevel,1);
		lb_PerkEffects.SetContent(S);
		lb_PerkProgress.List.PerkChanged(KFStatsAndAchievements, Idx);
	}
}

defaultproperties
{
     Begin Object Class=SRPerkSelectListBox Name=PerkSelectList
         OnCreateComponent=PerkSelectList.InternalOnCreateComponent
         WinTop=0.082969
         WinLeft=0.323418
         WinWidth=0.318980
         WinHeight=0.654653
     End Object
     lb_PerkSelect=SRPerkSelectListBox'ServerPerks.SRTab_Profile.PerkSelectList'

     Begin Object Class=SRPerkProgressListBox Name=PerkProgressList
         OnCreateComponent=PerkProgressList.InternalOnCreateComponent
         WinTop=0.439668
         WinLeft=0.670121
         WinWidth=0.319980
         WinHeight=0.292235
     End Object
     lb_PerkProgress=SRPerkProgressListBox'ServerPerks.SRTab_Profile.PerkProgressList'

}
