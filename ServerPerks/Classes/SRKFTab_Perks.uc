//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SRKFTab_Perks extends KFTab_Perks;

function ShowPanel(bool bShow)
{
	super(UT2K4TabPanel).ShowPanel(bShow);

	if ( bShow )
	{
		if ( Class'ClientPerkRepLink'.Static.FindStats(PlayerOwner())!=None )
		{
			// Initialize the List
			lb_PerkSelect.List.InitList(None);
			lb_PerkProgress.List.InitList();
		}
		l_ChangePerkOncePerWave.SetVisibility(false);
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

function bool OnSaveButtonClicked(GUIComponent Sender)
{
	local ClientPerkRepLink ST;

	ST = Class'ClientPerkRepLink'.Static.FindStats(PlayerOwner());
	if ( ST!=None && lb_PerkSelect.GetIndex()>=0 )
		ST.ServerSelectPerk(ST.CachePerks[lb_PerkSelect.GetIndex()].PerkClass);
	return true;
}

defaultproperties
{
     Begin Object Class=SRPerkSelectListBox Name=PerkSelectList
         OnCreateComponent=PerkSelectList.InternalOnCreateComponent
         WinTop=0.091627
         WinLeft=0.029240
         WinWidth=0.437166
         WinHeight=0.742836
     End Object
     lb_PerkSelect=SRPerkSelectListBox'ServerPerks.SRKFTab_Perks.PerkSelectList'

     Begin Object Class=SRPerkProgressListBox Name=PerkProgressList
         OnCreateComponent=PerkProgressList.InternalOnCreateComponent
         WinTop=0.476850
         WinLeft=0.499269
         WinWidth=0.463858
         WinHeight=0.341256
     End Object
     lb_PerkProgress=SRPerkProgressListBox'ServerPerks.SRKFTab_Perks.PerkProgressList'

}
