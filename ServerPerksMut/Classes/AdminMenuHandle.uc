Class AdminMenuHandle extends Info;

var bool bMainMenuOpened,bSendCat,bSendWep,bConfigDirty;
var KFPlayerController PlayerOwner;
var UI_Replication Rep;
var array<int> PlayerList;
var int EditingIndex,EditingCategory;
var ServerStStats EditingStats;
var() name MainMenuID,EditStatMenuID,StatEditID,EditTraderID,AddWeaponID,EditWeaponID,AddCategoryID,EditCategoryID,ErrorID,CharacterEditID,EditSettingsID;
var ServerPerksMut MutatorOwner;

var string PendingDataFeed,PendingCategories,PendingString;

var array<string> StatNames,NewStatValues;

struct FSettingType
{
	var byte Type;
	var string ExtraValue,Name,PropName;
};
var array<FSettingType> SettingLines;

function PostBeginPlay()
{
	PlayerOwner = KFPlayerController(Owner);
	if( PlayerOwner==None )
		Error("No KFPlayerController as owner.");
	else
	{
		Rep = Spawn(Class'UI_Replication',PlayerOwner);
		Rep.DlgWindowClosed = WindowClosed;
		Rep.DlgSubmittedValue = SubmittedValue;
	}
}
function Destroyed()
{
	if( Rep!=None )
		Rep.Destroy();
}

function WindowClosed( name ID )
{
	if( ID==MainMenuID )
		Destroy();
}
function SubmittedValue( name ID, int CompID, string Value );
function Tick( float Delta )
{
	if( PlayerOwner==None || Level.Game.bGameEnded )
	{
		if( PlayerOwner!=None )
			PlayerOwner.ClientMessage("Can't edit stats anymore after endgame.");
		Destroy();
	}
}

auto state MainMenu
{
	function BeginState()
	{
		if( !bMainMenuOpened )
		{
			bMainMenuOpened = true;
			Rep.ClientOpenWindow(MainMenuID,0.4,0.3,"ServerPerks Admin Menu");
			Rep.ClientAddComponent(MainMenuID,0,0,true,false,0.1,0.2,0.3,0.2,"Edit Trader","Edit the trader weapons and categories list.");
			Rep.ClientAddComponent(MainMenuID,1,0,true,false,0.6,0.2,0.3,0.2,"Edit Characters","Edit the custom characters players may use.");
			Rep.ClientAddComponent(MainMenuID,2,0,true,false,0.1,0.5,0.3,0.2,"Edit Settings","Edit misc serverperks settings.");
			Rep.ClientAddComponent(MainMenuID,3,0,true,false,0.6,0.5,0.3,0.2,"Edit Stats","Edit individual player stats.");
			Rep.ClientAddComponent(MainMenuID,4,2,true,false,0.35,0.82,0.3,0.15,"Close","Close menu");
		}
	}
	function SubmittedValue( name ID, int CompID, string Value )
	{
		if( ID==MainMenuID )
		{
			switch( CompID )
			{
			case 0:
				GoToState('EditTrader');
				break;
			case 1:
				GoToState('EditChars');
				break;
			case 2:
				GoToState('EditSettings');
				break;
			case 3:
				GoToState('EditStatsM');
				break;
			}
		}
	}
}

state EditSettings
{
	function BeginState()
	{
		local float X,Y;
		local int i;
		local string S;
		local byte T;

		bConfigDirty = false;
		Rep.ClientOpenWindow(EditSettingsID,0.9,0.9,"Server settings menu");
		Rep.ClientAddComponent(EditSettingsID,0,2,true,false,0.85,0.9,0.1,0.05,"Close","Close menu");
		
		X = 0.025;
		Y = 0.05;
		for( i=0; i<SettingLines.Length; ++i )
		{
			S = "";
			S = MutatorOwner.GetPropertyText(SettingLines[i].PropName);
			T = SettingLines[i].Type;
			S = SettingLines[i].ExtraValue$S;

			Rep.ClientAddComponent(EditSettingsID,(i+1),T,true,false,X,Y,0.35,0.048,S,SettingLines[i].Name);
			Y+=0.05;
			if( Y>=0.9 )
			{
				Y = 0.05;
				X+=0.4;
			}
		}
	}
	function EndState()
	{
		if( bConfigDirty )
			MutatorOwner.SaveConfig();
		Rep.ClientCloseWindow(EditSettingsID);
	}
	function WindowClosed( name ID )
	{
		if( ID==EditSettingsID )
			GoToState('MainMenu');
		else Global.WindowClosed(ID);
	}
	function SubmittedValue( name ID, int CompID, string Value )
	{
		if( ID==EditSettingsID )
		{
			if( CompID>=1 && CompID<=SettingLines.Length )
			{
				bConfigDirty = true;
				if( SettingLines[CompID-1].Type==7 )
					MutatorOwner.SetPropertyText(SettingLines[CompID-1].PropName,Eval(Value!="0","True","False"));
				else MutatorOwner.SetPropertyText(SettingLines[CompID-1].PropName,Value);
			}
		}
	}
}

state EditTrader
{
	function BeginState()
	{
		bConfigDirty = false;
		Rep.ClientOpenWindow(EditTraderID,0.6,0.4,"Trader Weapon Editor");
		Rep.ClientAddComponent(EditTraderID,0,0,true,false,0.1,0.26,0.14,0.11,"Add","Add a new weapon class to the list.");
		Rep.ClientAddComponent(EditTraderID,1,0,true,false,0.3,0.26,0.14,0.11,"Edit","Edit the current weapon class.");
		Rep.ClientAddComponent(EditTraderID,2,0,true,false,0.6,0.26,0.14,0.11,"Delete","Remove the current weapon from list.");
		Rep.ClientAddComponent(EditTraderID,3,0,true,false,0.1,0.66,0.14,0.11,"Add","Add a new weapon category to the list.");
		Rep.ClientAddComponent(EditTraderID,4,0,true,false,0.3,0.66,0.14,0.11,"Edit","Rename the current weapon category.");
		Rep.ClientAddComponent(EditTraderID,5,0,true,false,0.6,0.66,0.14,0.11,"Delete","Remove the current weapon category from list.");
		Rep.ClientAddComponent(EditTraderID,8,2,true,false,0.35,0.82,0.3,0.15,"Close","Close menu");

		SendCategories();
		SendWeaponList();
	}
	function EndState()
	{
		if( bConfigDirty )
			MutatorOwner.SaveConfig();
		Rep.ClientCloseWindow(EditTraderID);
		Rep.ClientCloseWindow(AddWeaponID);
		Rep.ClientCloseWindow(EditWeaponID);
		Rep.ClientCloseWindow(AddCategoryID);
		Rep.ClientCloseWindow(EditCategoryID);
	}
	function WindowClosed( name ID )
	{
		if( ID==EditTraderID )
			GoToState('MainMenu');
		else Global.WindowClosed(ID);
	}
	
	function Tick( float Delta )
	{
		if( bSendCat )
		{
			if( Len(PendingCategories)<=200 )
			{
				bSendCat = false;
				Rep.ClientAddComponent(EditTraderID,6,6,true,false,0.025,0.55,0.95,0.1,PendingCategories,"Category:");
				EditingCategory = 0;
				if( !bSendWep )
					UpdateCategoryIndex();
			}
			else
			{
				Rep.ClientPendingData(Left(PendingCategories,200));
				PendingCategories = Mid(PendingCategories,200);
			}
		}
		else if( bSendWep )
		{
			if( Len(PendingDataFeed)<=200 )
			{
				bSendWep = false;
				Rep.ClientAddComponent(EditTraderID,7,6,true,false,0.025,0.15,0.95,0.1,PendingDataFeed,"Weapon:");
				EditingIndex = 0;
			}
			else
			{
				Rep.ClientPendingData(Left(PendingDataFeed,200));
				PendingDataFeed = Mid(PendingDataFeed,200);
			}
		}
		Global.Tick(Delta);
	}
	final function SendCategories()
	{
		local int i;

		bSendCat = true;
		PendingCategories = "0;";
		for( i=0; i<MutatorOwner.WeaponCategories.Length; ++i )
		{
			if( i==0 )
				PendingCategories $= Repl(MutatorOwner.WeaponCategories[i],":",";");
			else PendingCategories $= ":"$Repl(MutatorOwner.WeaponCategories[i],":",";");
		}
		if( i==0 )
			PendingCategories $= "None";
	}
	final function SendWeaponList()
	{
		local int i,j;
		local string S;

		bSendWep = true;
		PendingDataFeed = "0;None";
		for( i=0; i<MutatorOwner.TraderInventory.Length; ++i )
		{
			S = MutatorOwner.TraderInventory[i];
			j = InStr(S,":");
			if( j>=0 )
				S = Mid(S,j+1);
			PendingDataFeed $= ":"$S;
		}
	}
	final function UpdateWeaponCat( int NewID )
	{
		local int j;
		local string S;
		
		if( EditingIndex>0 && !bSendWep && EditingIndex<=MutatorOwner.TraderInventory.Length )
		{
			S = MutatorOwner.TraderInventory[EditingIndex-1];
			j = InStr(S,":");
			if( j>=0 )
				S = Mid(S,j+1);
			MutatorOwner.TraderInventory[EditingIndex-1] = string(NewID)$":"$S;
			bConfigDirty = true;
		}
	}
	final function UpdateCategoryIndex()
	{
		local int j;
		local string S;

		if( EditingIndex>0 && !bSendWep && EditingIndex<=MutatorOwner.TraderInventory.Length )
		{
			S = MutatorOwner.TraderInventory[EditingIndex-1];
			j = InStr(S,":");
			if( j>=0 )
				EditingCategory = int(Left(S,j));
			else EditingCategory = 0;
			Rep.ClientSetCompValue(EditTraderID,6,string(EditingCategory));
		}
	}
	final function DeleteWeapon()
	{
		if( EditingIndex>0 && !bSendWep && EditingIndex<=MutatorOwner.TraderInventory.Length )
		{
			MutatorOwner.TraderInventory.Remove(EditingIndex-1,1);
			bConfigDirty = true;
			SendWeaponList();
		}
	}
	final function DeleteCategory()
	{
		local int i,j,n;
		local string S;

		if( EditingCategory>=0 && !bSendCat && EditingCategory<MutatorOwner.WeaponCategories.Length )
		{
			for( i=0; i<MutatorOwner.TraderInventory.Length; ++i )
			{
				S = MutatorOwner.TraderInventory[i];
				j = InStr(S,":");
				if( j>=0 )
				{
					n = int(Left(S,j));
					S = Mid(S,j+1);
				}
				else n = 0;
				if( n>=EditingCategory )
					n = Max(j-1,0);
				MutatorOwner.TraderInventory[i] = string(n)$":"$S;
			}
			MutatorOwner.WeaponCategories.Remove(EditingCategory,1);
			bConfigDirty = true;
			SendCategories();
			SendWeaponList();
		}
	}
	final function EditBoxWindow( name ID, string Title, string Type, string A, string B, optional string C )
	{
		Rep.ClientOpenWindow(ID,0.7,0.2,Title);
		Rep.ClientAddComponent(ID,0,3,false,false,0.025,0.2,0.95,0.4,C,Type);
		Rep.ClientAddComponent(ID,1,1,true,false,0.1,0.6,0.3,0.2,A,A$" this weapon "$B$" in trader menu.");
		Rep.ClientAddComponent(ID,2,2,true,false,0.6,0.6,0.3,0.2,"Close","Close menu without doing anything");
		PendingString = C;
	}
	final function AddWeapon()
	{
		EditBoxWindow(AddWeaponID,"Add Weapon","Classname:","Add","class");
	}
	final function AddNewWeapon()
	{
		local int i;
		local class<KFWeaponPickup> WC;
		
		WC = Class<KFWeaponPickup>(DynamicLoadObject(PendingString,Class'Class'));
		if( WC==None )
		{
			PlayerOwner.ClientMessage("Couldn't add weapon: Couldn't load class '"$PendingString$"'");
			return;
		}
		i = MutatorOwner.TraderInventory.Length;
		MutatorOwner.TraderInventory.Length = i+1;
		MutatorOwner.TraderInventory[i] = "0:"$string(WC);
		bConfigDirty = true;
		SendWeaponList();
		Rep.ClientCloseWindow(AddWeaponID);
	}
	final function EditWeapon()
	{
		local string S;
		local int i;

		if( EditingIndex>0 && !bSendWep && EditingIndex<=MutatorOwner.TraderInventory.Length )
		{
			S = MutatorOwner.TraderInventory[EditingIndex-1];
			i = InStr(S,":");
			if( i>=0 )
				S = Mid(S,i+1);
			EditBoxWindow(EditWeaponID,"Edit Weapon","Classname:","Edit","class",S);
		}
	}
	final function EditCurrentWeapon()
	{
		local int i,n;
		local class<KFWeaponPickup> WC;
		local string S;
		
		if( EditingIndex>0 && !bSendWep && EditingIndex<=MutatorOwner.TraderInventory.Length )
		{
			WC = Class<KFWeaponPickup>(DynamicLoadObject(PendingString,Class'Class'));
			if( WC==None )
			{
				PlayerOwner.ClientMessage("Couldn't edit weapon: Couldn't load class '"$PendingString$"'");
				return;
			}
			S = MutatorOwner.TraderInventory[EditingIndex-1];
			i = InStr(S,":");
			if( i>=0 )
			{
				n = int(Left(S,i));
				S = Mid(S,i+1);
			}
			else n = 0;
			MutatorOwner.TraderInventory[EditingIndex-1] = string(n)$":"$string(WC);
			bConfigDirty = true;
			SendWeaponList();
			Rep.ClientCloseWindow(EditWeaponID);
		}
	}
	final function AddCategory()
	{
		EditBoxWindow(AddCategoryID,"Add Category","Name:","Add","category");
	}
	final function AddNewCategory()
	{
		local int i;

		i = MutatorOwner.WeaponCategories.Length;
		MutatorOwner.WeaponCategories.Length = i+1;
		MutatorOwner.WeaponCategories[i] = PendingString;
		bConfigDirty = true;
		SendCategories();
		Rep.ClientCloseWindow(AddCategoryID);
	}
	final function EditCategory()
	{
		if( EditingCategory>=0 && !bSendCat && EditingCategory<MutatorOwner.WeaponCategories.Length )
			EditBoxWindow(EditCategoryID,"Edit Category","Name:","Edit","category",MutatorOwner.WeaponCategories[EditingCategory]);
	}
	final function EditCurrentCategory()
	{
		if( EditingCategory>=0 && !bSendCat && EditingCategory<MutatorOwner.WeaponCategories.Length )
		{
			MutatorOwner.WeaponCategories[EditingCategory] = PendingString;
			bConfigDirty = true;
			SendCategories();
			Rep.ClientCloseWindow(EditCategoryID);
		}
	}
	function SubmittedValue( name ID, int CompID, string Value )
	{
		if( ID==EditTraderID )
		{
			switch( CompID )
			{
			case 0:
				AddWeapon();
				break;
			case 1:
				EditWeapon();
				break;
			case 2:
				DeleteWeapon();
				break;
			case 3:
				AddCategory();
				break;
			case 4:
				EditCategory();
				break;
			case 5:
				DeleteCategory();
				break;
			case 6:
				EditingCategory = int(Value);
				UpdateWeaponCat(EditingCategory);
				break;
			case 7:
				EditingIndex = int(Value);
				UpdateCategoryIndex();
				break;
			}
		}
		else if( ID==AddWeaponID )
		{
			switch( CompID )
			{
			case 0:
				PendingString = Value;
				break;
			case 1:
				AddNewWeapon();
				break;
			}
		}
		else if( ID==EditWeaponID )
		{
			switch( CompID )
			{
			case 0:
				PendingString = Value;
				break;
			case 1:
				EditCurrentWeapon();
				break;
			}
		}
		else if( ID==AddCategoryID )
		{
			switch( CompID )
			{
			case 0:
				PendingString = Value;
				break;
			case 1:
				AddNewCategory();
				break;
			}
		}
		else if( ID==EditCategoryID )
		{
			switch( CompID )
			{
			case 0:
				PendingString = Value;
				break;
			case 1:
				EditCurrentCategory();
				break;
			}
		}
	}
}

state EditChars
{
	function BeginState()
	{
		bConfigDirty = false;
		Rep.ClientOpenWindow(CharacterEditID,0.6,0.4,"Character Editor");
		Rep.ClientAddComponent(CharacterEditID,0,0,true,false,0.1,0.4,0.14,0.11,"Add","Add a new character to the list.");
		Rep.ClientAddComponent(CharacterEditID,1,0,true,false,0.3,0.4,0.14,0.11,"Edit","Edit the current character.");
		Rep.ClientAddComponent(CharacterEditID,2,0,true,false,0.6,0.4,0.14,0.11,"Delete","Remove the current character from list.");
		Rep.ClientAddComponent(CharacterEditID,3,2,true,false,0.35,0.82,0.3,0.15,"Close","Close menu");
		SendCharacters();
	}
	function EndState()
	{
		if( bConfigDirty )
			MutatorOwner.SaveConfig();
		Rep.ClientCloseWindow(CharacterEditID);
	}
	function WindowClosed( name ID )
	{
		if( ID==CharacterEditID )
			GoToState('MainMenu');
		else Global.WindowClosed(ID);
	}
	
	function Tick( float Delta )
	{
		if( bSendCat )
		{
			if( Len(PendingCategories)<=200 )
			{
				bSendCat = false;
				Rep.ClientAddComponent(CharacterEditID,4,6,true,false,0.025,0.2,0.95,0.15,PendingCategories,"Character:");
				EditingCategory = 0;
			}
			else
			{
				Rep.ClientPendingData(Left(PendingCategories,200));
				PendingCategories = Mid(PendingCategories,200);
			}
		}
		Global.Tick(Delta);
	}
	final function SendCharacters()
	{
		local int i,j;
		local string S;

		bSendCat = true;
		PendingCategories = "0;";
		for( i=0; i<MutatorOwner.CustomCharacters.Length; ++i )
		{
			S = MutatorOwner.CustomCharacters[i];
			j = InStr(S,":");
			if( j>=0 )
				S = Mid(S,j+1)$" ["$Left(S,j)$"]";
			if( i==0 )
				PendingCategories $= S;
			else PendingCategories $= ":"$S;
		}
		if( i==0 )
			PendingCategories $= "None";
	}
	
	final function DeleteCharacter()
	{
		if( EditingCategory>=0 && !bSendCat && EditingCategory<MutatorOwner.CustomCharacters.Length )
		{
			MutatorOwner.CustomCharacters.Remove(EditingCategory,1);
			bConfigDirty = true;
			SendCharacters();
		}
	}
	final function EditBoxWindow( name ID, string Title, string A, optional string C, optional string Cat )
	{
		Rep.ClientOpenWindow(ID,0.7,0.2,Title);
		Rep.ClientAddComponent(ID,0,3,false,false,0.025,0.2,0.95,0.4,C,"Character:");
		Rep.ClientAddComponent(ID,1,3,false,false,0.025,0.4,0.95,0.4,Cat,"Category:");
		Rep.ClientAddComponent(ID,2,1,true,false,0.1,0.6,0.3,0.2,A,A$" this character.");
		Rep.ClientAddComponent(ID,3,2,true,false,0.6,0.6,0.3,0.2,"Close","Close menu without doing anything");
		PendingString = C;
		PendingDataFeed = Cat;
	}
	final function AddCharacter()
	{
		EditBoxWindow(AddCategoryID,"Add Character","Add");
	}
	final function AddNewCharacter()
	{
		local int i;
		local string S;

		if( class<PlayerRecordClass>(DynamicLoadObject(PendingString$"Mod."$PendingString,class'Class',true))==None )
			PlayerOwner.ClientMessage("Couldn't load any PlayerRecordClass for '"$PendingString$"Mod."$PendingString$"', are sure this is desired?");
		if( PendingDataFeed!="" )
			S = PendingDataFeed$":"$PendingString;
		else S = PendingString;
		i = MutatorOwner.CustomCharacters.Length;
		MutatorOwner.CustomCharacters.Length = i+1;
		MutatorOwner.CustomCharacters[i] = S;
		bConfigDirty = true;
		SendCharacters();
		Rep.ClientCloseWindow(AddCategoryID);
	}
	final function EditCharacter()
	{
		local int i;
		local string S;

		if( EditingCategory>=0 && !bSendCat && EditingCategory<MutatorOwner.CustomCharacters.Length )
		{
			S = MutatorOwner.CustomCharacters[EditingCategory];
			i = InStr(S,":");
			if( i==-1 )
				EditBoxWindow(EditCategoryID,"Edit Character","Edit",S);
			else EditBoxWindow(EditCategoryID,"Edit Character","Edit",Mid(S,i+1),Left(S,i));
		}
	}
	final function EditCurrentCharacter()
	{
		local string S;

		if( EditingCategory>=0 && !bSendCat && EditingCategory<MutatorOwner.CustomCharacters.Length )
		{
			if( class<PlayerRecordClass>(DynamicLoadObject(PendingString$"Mod."$PendingString,class'Class',true))==None )
				PlayerOwner.ClientMessage("Couldn't load any PlayerRecordClass for '"$PendingString$"Mod."$PendingString$"', are sure this is desired?");
			if( PendingDataFeed!="" )
				S = PendingDataFeed$":"$PendingString;
			else S = PendingString;
			MutatorOwner.CustomCharacters[EditingCategory] = S;
			bConfigDirty = true;
			SendCharacters();
			Rep.ClientCloseWindow(EditCategoryID);
		}
	}
	function SubmittedValue( name ID, int CompID, string Value )
	{
		if( ID==CharacterEditID )
		{
			switch( CompID )
			{
			case 0:
				AddCharacter();
				break;
			case 1:
				EditCharacter();
				break;
			case 2:
				DeleteCharacter();
				break;
			case 4:
				EditingCategory = int(Value);
				break;
			}
		}
		else if( ID==AddCategoryID )
		{
			switch( CompID )
			{
			case 0:
				PendingString = Value;
				break;
			case 1:
				PendingDataFeed = Value;
				break;
			case 2:
				AddNewCharacter();
				break;
			}
		}
		else if( ID==EditCategoryID )
		{
			switch( CompID )
			{
			case 0:
				PendingString = Value;
				break;
			case 1:
				PendingDataFeed = Value;
				break;
			case 2:
				EditCurrentCharacter();
				break;
			}
		}
	}
}

state EditStatsM
{
	function BeginState()
	{
		Rep.ClientOpenWindow(EditStatMenuID,0.4,0.3,"Stats Editor");
		Rep.ClientAddComponent(EditStatMenuID,0,0,true,false,0.1,0.6,0.3,0.2,"Refresh","Refresh players list");
		Rep.ClientAddComponent(EditStatMenuID,1,1,true,true,0.6,0.6,0.3,0.2,"Edit","Edit stats of selected player");
		Rep.ClientAddComponent(EditStatMenuID,3,2,true,false,0.35,0.82,0.3,0.15,"Close","Close menu");
		SetPlayerList();
	}
	function EndState()
	{
		Rep.ClientCloseWindow(EditStatMenuID);
	}
	final function SetPlayerList()
	{
		local Controller C;
		local string S;
		
		PlayerList.Length = 0;
		EditingIndex = 0;
		S = "0;None";
		for( C=Level.ControllerList; C!=None; C=C.nextController )
		{
			if( C.bIsPlayer && xPlayer(C)!=None && ServerStStats(xPlayer(C).SteamStatsAndAchievements)!=none )
			{
				PlayerList[PlayerList.Length] = C.PlayerReplicationInfo.PlayerID;
				S $= ":"$C.PlayerReplicationInfo.PlayerID$" - "$Repl(Left(C.PlayerReplicationInfo.PlayerName,16),":",".");
				if( Len(S)>150 )
				{
					Rep.ClientPendingData(S);
					S = "";
				}
			}
		}
		Rep.ClientAddComponent(EditStatMenuID,2,6,true,false,0.1,0.1,0.8,0.2,S,"Select player:");
		Rep.ClientSetCompLock(EditStatMenuID,1,true);
	}
	final function EditPlayerEntry()
	{
		local Controller C;
		local int i;

		if( EditingIndex==0 || (EditingIndex-1)>=PlayerList.Length )
		{
			PlayerOwner.ClientMessage("You selected an invalid player to edit.");
			return;
		}
		i = PlayerList[EditingIndex-1];
		for( C=Level.ControllerList; C!=None; C=C.nextController )
		{
			if( C.bIsPlayer && xPlayer(C)!=None && C.PlayerReplicationInfo.PlayerID==i && ServerStStats(xPlayer(C).SteamStatsAndAchievements)!=none )
			{
				EditingStats = ServerStStats(xPlayer(C).SteamStatsAndAchievements);
				if( !EditingStats.bStatsReadyNow || EditingStats.MyStatsObject==None )
					PlayerOwner.ClientMessage("Your selected players stats aren't ready to be edited yet.");
				else GoToState('EditStats');
				return;
			}
		}
		PlayerOwner.ClientMessage("Your selected player isn't available on server anymore, please refresh.");
	}
	function SubmittedValue( name ID, int CompID, string Value )
	{
		if( ID==EditStatMenuID )
		{
			switch( CompID )
			{
			case 0:
				SetPlayerList();
				break;
			case 1:
				EditPlayerEntry();
				break;
			case 2:
				EditingIndex = int(Value);
				Rep.ClientSetCompLock(EditStatMenuID,1,(EditingIndex==0));
				break;
			}
		}
	}
	function WindowClosed( name ID )
	{
		if( ID==EditStatMenuID )
			GoToState('MainMenu');
		else Global.WindowClosed(ID);
	}
}
state EditStats
{
	function BeginState()
	{
		Rep.ClientOpenWindow(StatEditID,0.9,0.9,"Stats of "$EditingStats.PlayerOwner.PlayerReplicationInfo.PlayerName);
		Rep.ClientAddComponent(StatEditID,0,1,true,false,0.1,0.9,0.15,0.05,"Save","Save changes of this player stats");
		Rep.ClientAddComponent(StatEditID,1,0,true,false,0.47,0.9,0.15,0.05,"Update","Update stats to match client current stats");
		Rep.ClientAddComponent(StatEditID,2,2,true,false,0.8,0.9,0.15,0.05,"Close","Close window without saving changes");
		ReadStats();
	}
	function EndState()
	{
		Rep.ClientCloseWindow(StatEditID);
	}
	function Tick( float Delta )
	{
		if( EditingStats==None )
		{
			PlayerOwner.ClientMessage("Desired player disconnected.");
			GoToState('EditStatsM');
		}
		Global.Tick(Delta);
	}
	function WindowClosed( name ID )
	{
		if( ID==StatEditID )
			GoToState('EditStatsM');
		else Global.WindowClosed(ID);
	}
	final function AddStat( out int ID, int CurValue, out float X, out float Y, string Info )
	{
		Rep.ClientAddComponent(StatEditID,ID++,5,true,false,X,Y,0.28,0.04,"0:1073741823:1:"$CurValue,Left(Info,13));
		Y+=0.04;
		if( Y>=0.85 )
		{
			X += 0.3;
			Y = 0.025;
		}
	}
	final function AddStatStr( out int ID, string CurValue, out float X, out float Y, string Info )
	{
		Rep.ClientAddComponent(StatEditID,ID++,3,true,false,X,Y,0.28,0.04,CurValue,Left(Info,13));
		Y+=0.04;
		if( Y>=0.85 )
		{
			X += 0.3;
			Y = 0.025;
		}
	}
	final function ReadStats()
	{
		local int i,j;
		local float X,Y;
		local StatsObject S;
		local string Res;
		
		i = 3;
		S = EditingStats.MyStatsObject;
		X = 0.015;
		Y = 0.025;

		NewStatValues.Length = 0;
		for( j=0; j<StatNames.Length; ++j )
		{
			Res = "";
			Res = S.GetPropertyText(StatNames[j]);
			AddStat(i,int(Res),X,Y,StatNames[j]);
		}
		for( j=0; j<S.CC.Length; ++j )
			AddStatStr(i,S.CC[j].V,X,Y,string(S.CC[j].N));
	}
	final function SaveStats()
	{
		local int i;
		local StatsObject S;
		
		Log(PlayerOwner.PlayerReplicationInfo.PlayerName$" edited stats of "$EditingStats.PlayerOwner.PlayerReplicationInfo.PlayerName,Class.Outer.Name);
		S = EditingStats.MyStatsObject;
		for( i=0; i<NewStatValues.Length; ++i )
			if( NewStatValues[i]!="" )
			{
				if( i<StatNames.Length )
					S.SetPropertyText(StatNames[i],NewStatValues[i]);
				else S.CC[i-StatNames.Length].V = NewStatValues[i];
			}
		EditingStats.RepCopyStats();
		EditingStats.NotifyStatChanged();
	}

	function SubmittedValue( name ID, int CompID, string Value )
	{
		if( ID==StatEditID )
		{
			switch( CompID )
			{
			case 0:
				SaveStats();
				break;
			case 1:
				ReadStats();
				break;
			case 2:
				GoToState('EditStatsM');
				break;
			default:
				if( CompID>=3 )
				{
					CompID-=3;
					if( CompID>=NewStatValues.Length )
						NewStatValues.Length = CompID+1;
					NewStatValues[CompID] = Value;
				}
			}
		}
	}
}

defaultproperties
{
     MainMenuID="i"
     EditStatMenuID="Core"
     StatEditID="j"
     EditTraderID="Rand"
     AddWeaponID="Warn"
     EditWeaponID="Dot"
     AddCategoryID="Lerp"
     EditCategoryID="Eval"
     ErrorID="Error"
     CharacterEditID="Log"
     EditSettingsID="S"
     StatNames(0)="DamageHealedStat"
     StatNames(1)="WeldingPointsStat"
     StatNames(2)="ShotgunDamageStat"
     StatNames(3)="HeadshotKillsStat"
     StatNames(4)="StalkerKillsStat"
     StatNames(5)="BullpupDamageStat"
     StatNames(6)="MeleeDamageStat"
     StatNames(7)="FlameThrowerDamageStat"
     StatNames(8)="SelfHealsStat"
     StatNames(9)="SoleSurvivorWavesStat"
     StatNames(10)="CashDonatedStat"
     StatNames(11)="FeedingKillsStat"
     StatNames(12)="BurningCrossbowKillsStat"
     StatNames(13)="GibbedFleshpoundsStat"
     StatNames(14)="StalkersKilledWithExplosivesStat"
     StatNames(15)="GibbedEnemiesStat"
     StatNames(16)="BloatKillsStat"
     StatNames(17)="SirenKillsStat"
     StatNames(18)="KillsStat"
     StatNames(19)="ExplosivesDamageStat"
     StatNames(20)="TotalPlayTime"
     StatNames(21)="WinsCount"
     StatNames(22)="LostsCount"
     StatNames(23)="TotalZedTimeStat"
     SettingLines(0)=(Type=5,ExtraValue="-1:250:1:",Name="Min Perk Level",PropName="MinPerksLevel")
     SettingLines(1)=(Type=5,ExtraValue="0:250:1:",Name="Max Perk Level",PropName="MaxPerksLevel")
     SettingLines(2)=(Type=4,ExtraValue="0.0001:100:0.05:",Name="Requirement Scale",PropName="RequirementScaling")
     SettingLines(3)=(Type=5,ExtraValue="0:10:1:",Name="Mid-Game save waves",PropName="MidGameSaveWaves")
     SettingLines(4)=(Type=7,Name="Force perks for all",PropName="bForceGivePerk")
     SettingLines(5)=(Type=7,Name="No perk saving",PropName="bNoSavingProgress")
     SettingLines(6)=(Type=7,Name="Use PlayerName as ID",PropName="bUsePlayerNameAsID")
     SettingLines(7)=(Type=7,Name="Message everyones levelup",PropName="bMessageAnyPlayerLevelUp")
     SettingLines(8)=(Type=7,Name="Use lowest requirements",PropName="bUseLowestRequirements")
     SettingLines(9)=(Type=7,Name="Black and white ZED-time",PropName="bBWZEDTime")
     SettingLines(10)=(Type=7,Name="Use enhanced scoreboard",PropName="bUseEnhancedScoreboard")
     SettingLines(11)=(Type=7,Name="Remove unused custom stats",PropName="bOverrideUnusedCustomStats")
     SettingLines(12)=(Type=7,Name="Always allow perk changes",PropName="bAllowAlwaysPerkChanges")
     SettingLines(13)=(Type=7,Name="Force everyone use custom char",PropName="bForceCustomChars")
     SettingLines(14)=(Type=7,Name="Enable chat emoticons",PropName="bEnableChatIcons")
     SettingLines(15)=(Type=7,Name="Over shoulder view",PropName="bEnhancedShoulderView")
     SettingLines(16)=(Type=7,Name="Fix grenade exploit",PropName="bFixGrenadeExploit")
     SettingLines(17)=(Type=7,Name="Use remote database",PropName="bUseRemoteDatabase")
     SettingLines(18)=(Type=7,Name="Use FTP as database",PropName="bUseFTPLink")
     SettingLines(19)=(Type=3,Name="Newspage URL",PropName="ServerNewsURL")
     SettingLines(20)=(Type=3,Name="Remove DB URL",PropName="RemoteDatabaseURL")
     SettingLines(21)=(Type=3,Name="Remove DB Password",PropName="RemotePassword")
     SettingLines(22)=(Type=3,Name="Remove DB User",PropName="RemoteFTPUser")
     SettingLines(23)=(Type=3,Name="Remote DB Dir",PropName="RemoteFTPDir")
     SettingLines(24)=(Type=7,Name="No perk changes",PropName="bNoPerkChanges")
}
