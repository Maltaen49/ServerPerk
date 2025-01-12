// Written by .:..: (2009)
Class ServerPerksMut extends Mutator
	Config(ServerPerks);

struct ChatIconType
{
	var() config string IconTexture,IconTag;
	var() config bool bCaseInsensitive;
};
var() globalconfig array<string> Perks,TraderInventory,WeaponCategories,CustomCharacters;
var() globalconfig int MinPerksLevel,MaxPerksLevel,RemotePort,MidGameSaveWaves,FTPKeepAliveSec;
var() globalconfig float RequirementScaling;
var() globalconfig string RemoteDatabaseURL,RemotePassword,RemoteFTPUser,RemoteFTPDir,ServerNewsURL,FTPUploadAllIgnoreDate;
var() globalconfig array<ChatIconType> SmileyTags;

var array<ClientPerkRepLink.FShopCategoryIndex> LoadedCategories;
var array<byte> LoadInvCategory;
var array< class<SRVeterancyTypes> > LoadPerks;
var array< class<Pickup> > LoadInventory;
var const int VersionNumber;
var array<PlayerController> PendingPlayers;
var array<StatsObject> ActiveStats;
var localized string ServerPerksGroup;
var transient InternetLink Link;
var KFGameType KFGT;
var int LastSavedWave,WaveCounter;
var SRGameRules RulesMod;
var transient array<name> AddedServerPackages;
var transient float NextCheckTimer;
var array<SRHUDKillingFloor.SmileyMessageType> SmileyMsgs;
var class<Object> SRScoreboardType,SRHudType,SRMenuType;
var class<PlayerController> SRControllerType;

var() globalconfig bool bUploadAllStats,bForceGivePerk,bNoSavingProgress,bUseRemoteDatabase,bUsePlayerNameAsID,bMessageAnyPlayerLevelUp,bNoPerkChanges
						,bUseLowestRequirements,bBWZEDTime,bUseEnhancedScoreboard,bOverrideUnusedCustomStats,bAllowAlwaysPerkChanges,bEnableWebAdmin
						,bForceCustomChars,bEnableChatIcons,bEnhancedShoulderView,bFixGrenadeExploit,bAdminEditStats,bUseFTPLink,bDebugDatabase;
var bool bEnabledEmoIcons;

function PostBeginPlay()
{
	local int i,j;
	local class<SRVeterancyTypes> V;
	local class<Pickup> P;
	local string S;
	local byte Cat;
	local class<PlayerRecordClass> PR;
	local Texture T;
	local KFLevelRules R;

	if( RulesMod==None )
		RulesMod = Spawn(Class'SRGameRules');

	KFGT = KFGameType(Level.Game);
	if( Level.Game.HUDType~=Class'KFGameType'.Default.HUDType || Level.Game.HUDType~=Class'KFStoryGameInfo'.Default.HUDType )
	{
		bEnabledEmoIcons = bEnableChatIcons;
		Level.Game.HUDType = string(SRHudType);
	}

	if( bUseEnhancedScoreboard && (Level.Game.ScoreBoardType~=Class'KFGameType'.Default.ScoreBoardType || Level.Game.ScoreBoardType~=Class'KFStoryGameInfo'.Default.ScoreBoardType) )
		Level.Game.ScoreBoardType = string(SRScoreboardType);

	// Use own playercontroller class for security reasons.
	if( Level.Game.PlayerControllerClass==Class'KFPlayerController' || Level.Game.PlayerControllerClass==Class'KFPlayerController_Story' )
	{
		Level.Game.PlayerControllerClass = SRControllerType;
		Level.Game.PlayerControllerClassName = string(SRControllerType);
	}
	DeathMatch(Level.Game).LoginMenuClass = string(SRMenuType);

	// Load perks.
	for( i=0; i<Perks.Length; i++ )
	{
		V = class<SRVeterancyTypes>(DynamicLoadObject(Perks[i],Class'Class'));
		if( V!=None )
		{
			LoadPerks[LoadPerks.Length] = V;
			ImplementPackage(V);
		}
	}
	
	// Setup categories
	LoadedCategories.Length = WeaponCategories.Length;
	for( i=0; i<WeaponCategories.Length; ++i )
	{
		S = WeaponCategories[i];
		j = InStr(S,":");
		if( j==-1 )
		{
			LoadedCategories[i].Name = S;
			LoadedCategories[i].PerkIndex = 255;
		}
		else
		{
			LoadedCategories[i].Name = Mid(S,j+1);
			LoadedCategories[i].PerkIndex = int(Left(S,j));
		}
	}
	if( LoadedCategories.Length==0 )
	{
		LoadedCategories.Length = 1;
		LoadedCategories[0].Name = "All";
		LoadedCategories[0].PerkIndex = 255;
	}

	// Init rules
	foreach AllActors(class'KFLevelRules',R)
		break;
	if( R==None && KFGT!=None )
	{
		R = KFGT.KFLRules;
		if( R==None )
		{
			R = Spawn(class'KFLevelRules');
			KFGT.KFLRules = R;
		}
	}
	if( R!=None )
	{
		// Empty all stock weapons first.
		R.MediItemForSale.Length = 0;
		R.SuppItemForSale.Length = 0;
		R.ShrpItemForSale.Length = 0;
		R.CommItemForSale.Length = 0;
		R.BersItemForSale.Length = 0;
		R.FireItemForSale.Length = 0;
		R.DemoItemForSale.Length = 0;
		R.NeutItemForSale.Length = 0;
	}

	// Load up trader inventory.
	for( i=0; i<TraderInventory.Length; i++ )
	{
		S = TraderInventory[i];
		j = InStr(S,":");
		if( j>0 )
		{
			Cat = Min(int(Left(S,j)),LoadedCategories.Length-1);
			S = Mid(S,j+1);
		}
		else Cat = 0;
		P = class<Pickup>(DynamicLoadObject(S,Class'Class'));
		if( P!=None )
		{
			// Inform bots.
			if( R!=None )
				R.MediItemForSale[R.MediItemForSale.Length] = P;

			LoadInventory[LoadInventory.Length] = P;
			LoadInvCategory[LoadInvCategory.Length] = Cat;
			if( P.Outer.Name!='KFMod' )
				ImplementPackage(P);
		}
	}

	// Load custom chars.
	for( i=0; i<CustomCharacters.Length; ++i )
	{
		// Separate group from actual skin.
		S = CustomCharacters[i];
		j = InStr(S,":");
		if( j>=0 )
			S = Mid(S,j+1);
		PR = class<PlayerRecordClass>(DynamicLoadObject(S$"Mod."$S,class'Class',true));
		if( PR!=None )
		{
			if( PR.Default.MeshName!="" ) // Add mesh package.
				ImplementPackage(DynamicLoadObject(PR.Default.MeshName,class'Mesh',true));
			if( PR.Default.BodySkinName!="" ) // Add skin package.
				ImplementPackage(DynamicLoadObject(PR.Default.BodySkinName,class'Material',true));
			ImplementPackage(PR);
		}
	}
	
	// Load chat icons
	if( bEnabledEmoIcons )
	{
		j = 0;
		for( i=0; i<SmileyTags.Length; ++i )
		{
			if( SmileyTags[i].IconTexture=="" || SmileyTags[i].IconTag=="" )
				continue;
			T = Texture(DynamicLoadObject(SmileyTags[i].IconTexture,class'Texture',true));
			if( T==None )
				continue;
			ImplementPackage(T);
			SmileyMsgs.Length = j+1;
			SmileyMsgs[j].SmileyTex = T;
			if( SmileyTags[i].bCaseInsensitive )
				SmileyMsgs[j].SmileyTag = Caps(SmileyTags[i].IconTag);
			else SmileyMsgs[j].SmileyTag = SmileyTags[i].IconTag;
			SmileyMsgs[j].bInCAPS = SmileyTags[i].bCaseInsensitive;
			++j;
		}
		bEnabledEmoIcons = (j!=0);
	}

	Log("Adding"@AddedServerPackages.Length@"additional serverpackages",Class.Outer.Name);
	for( i=0; i<AddedServerPackages.Length; i++ )
		AddToPackageMap(string(AddedServerPackages[i]));
	AddedServerPackages.Length = 0;
	
	if( bUseEnhancedScoreboard || (Level.Game.HUDType~=string(SRHudType)) )
		AddToPackageMap("CountryFlagsTex");

	if( bFixGrenadeExploit )
		Class'Frag'.Default.FireModeClass[0] = Class'FragFireFix';

	if( bUseRemoteDatabase )
	{
		Log("Using remote database:"@RemoteDatabaseURL$":"$RemotePort,Class.Outer.Name);
		RespawnNetworkLink();
	}
}

function Tick( float Delta )
{
	Disable('Tick');
	if( bEnableWebAdmin && Level.NetMode!=NM_StandAlone )
		InitWebServer();
}
function InitWebServer()
{
	local WebServer W;
	local int i;
	local UTServerAdmin U;
	
	// Must increase the limit size.
	class'WebConnection'.default.MaxValueLength = Max(class'WebConnection'.default.MaxValueLength,9999);
	class'WebConnection'.default.MaxLineLength = Max(class'WebConnection'.default.MaxLineLength,10100);

	foreach DynamicActors(class'WebServer',W)
	{
		for( i=0; i<10; ++i )
		{
			U = UTServerAdmin(W.ApplicationObjects[i]);
			if( U!=None )
			{
				for( i=0; i<U.QueryHandlers.Length; ++i )
					if( U.QueryHandlers[i].Class==Class'ServerPerkWebAdmin' )
						return; // Already implemented.
				U.QueryHandlers.Length = i+1;
				U.QueryHandlers[i] = New(U)Class'ServerPerkWebAdmin';
				U.QueryHandlers[i].Init();
				return;
			}
		}
		Log("ServerPerks WebAdmin interface failed to init: Missing UTServerAdmin application.",Class.Outer.Name);
		return;
	}
	Log("ServerPerks WebAdmin interface failed to init: Missing WebServer object.",Class.Outer.Name);
}

function RespawnNetworkLink()
{
	if( Link!=None )
		Link.Destroy();
	if( !bUseFTPLink )
	{
		Link = Spawn(Class'DatabaseUdpLink');
		DatabaseUdpLink(Link).Mut = Self;
	}
	else
	{
		Link = Spawn(Class'FTPTcpLink');
		FTPTcpLink(Link).Mut = Self;
	}
	Link.BeginEvent();
}

function Mutate(string MutateString, PlayerController Sender)
{
	if( MutateString~="SPHelp" )
		Sender.ClientMessage("ServerPerksMut mutate CMDs: EditStats, SetPerk, Debug, GetID");
	if( Sender.PlayerReplicationInfo.bAdmin || Sender.PlayerReplicationInfo.bSilentAdmin || Viewport(Sender.Player)!=None )
	{
		if( bAdminEditStats && MutateString~="EditStats" )
			Spawn(Class'AdminMenuHandle',Sender).MutatorOwner = Self;
		else if( MutateString~="GetID" )
			ListID(Sender);
		else if( Left(MutateString,7)~="SetPerk" )
			AdminChangePerk(Sender,Mid(MutateString,8));
	}
	if( NextCheckTimer<Level.TimeSeconds && MutateString~="Debug" ) // Allow developer to lookup bugs.
	{
		NextCheckTimer = Level.TimeSeconds+0.25;
		Sender.ClientMessage("Debug info: "$Sender.SteamStatsAndAchievements);
		if( ServerStStats(Sender.SteamStatsAndAchievements)!=None )
		{
			Sender.ClientMessage("Ready:"@ServerStStats(Sender.SteamStatsAndAchievements).bStatsReadyNow@ServerStStats(Sender.SteamStatsAndAchievements).bStatsChecking);
			Sender.ClientMessage("MyStatsObject:"@ServerStStats(Sender.SteamStatsAndAchievements).MyStatsObject);
			Sender.ClientMessage("Timer:"@Sender.SteamStatsAndAchievements.TimerCounter@Sender.SteamStatsAndAchievements.TimerRate);
		}
		Sender.ClientMessage("Perk info:");
		DebugMessageProgress(Sender);
	}
	if ( NextMutator != None )
		NextMutator.Mutate(MutateString, Sender);
}
final function AdminChangePerk( PlayerController Sender, string Cmd )
{
	local int i,ID;
	local Controller C;
	local class<SRVeterancyTypes> V;
	local bool bAll;
	
	i = InStr(Cmd," ");
	if( i==-1 )
	{
		Sender.ClientMessage("Usage: SetPerk <ID/All> <PerkName>");
		return;
	}
	if( Left(Cmd,i)~="All" )
		bAll = true;
	else ID = int(Left(Cmd,i));
	
	Cmd = Mid(Cmd,i+1);
	for( i=0; i<LoadPerks.Length; ++i )
		if( string(LoadPerks[i].Name)~=Cmd || LoadPerks[i].Default.VeterancyName~=Cmd )
		{
			V = LoadPerks[i];
			break;
		}
	if( V==None )
	{
		Sender.ClientMessage("Unknown perk name: "$Cmd);
		return;
	}
	
	for( C=Level.ControllerList; C!=None; C=C.nextController )
	{
		if( C.bIsPlayer && C.PlayerReplicationInfo!=None && (bAll || C.PlayerReplicationInfo.PlayerID==ID) && xPlayer(C)!=None && ServerStStats(xPlayer(C).SteamStatsAndAchievements)!=None )
		{
			ServerStStats(xPlayer(C).SteamStatsAndAchievements).ForcePerkChange(V);
			xPlayer(C).ClientMessage("An admin has forced to change your perk to "$V.Default.VeterancyName);
			if( !bAll )
			{
				Sender.ClientMessage("Changed "$C.PlayerReplicationInfo.PlayerName$" perk to: "$V);
				break;
			}
		}
	}
	if( bAll )
		Sender.ClientMessage("Changed everyones perk to: "$V);
}
final function ListID( PlayerController PC )
{
	local Controller C;
	
	PC.ClientMessage("Player IDs:");
	for( C=Level.ControllerList; C!=None; C=C.nextController )
	{
		if( C.bIsPlayer && C.PlayerReplicationInfo!=None && xPlayer(C)!=None && ServerStStats(xPlayer(C).SteamStatsAndAchievements)!=None )
			PC.ClientMessage("ID="$C.PlayerReplicationInfo.PlayerID$", Name="$C.PlayerReplicationInfo.PlayerName);
	}
}
final function DebugMessageProgress( PlayerController PC )
{
	local KFPlayerReplicationInfo PRI;
	local class<SRVeterancyTypes> VC;
	local int i,Req,Cur,NumR;
	local byte Lvl;
	local ClientPerkRepLink Rep;
	
	PRI = KFPlayerReplicationInfo(PC.PlayerReplicationInfo);
	if( PRI==None || Class<SRVeterancyTypes>(PRI.ClientVeteranSkill)==None )
		return;
	VC = Class<SRVeterancyTypes>(PRI.ClientVeteranSkill);
	Lvl = PRI.ClientVeteranSkillLevel+1;
	
	Rep = Class'SRGameRules'.Static.FindStatsFor(PC);
	if( Rep==None )
		return;

	PC.ClientMessage("Perk: "$VC.Default.VeterancyName$" NextLevel: "$Lvl);
	NumR = VC.Static.GetRequirementCount(Rep,Lvl);
	for( i=0; i<NumR; ++i )
	{
		Cur = VC.Static.GetPerkProgressInt(Rep,Req,Lvl,i);
		PC.ClientMessage("Requirement '"$i$"' GetPerkProgressInt: Current:"$Cur$" Final:"$Req);
		VC.Static.GetPerkProgress(Rep,Lvl,i,Cur,Req);
		PC.ClientMessage("GetPerkProgress: Current:"$Cur$" Final:"$Req);
	}
}
final function ImplementPackage( Object O )
{
	local int i;
	
	if( O==None )
		return;
	while( O.Outer!=None )
		O = O.Outer;
	if( O.Name=='KFMod' )
		return;
	for( i=(AddedServerPackages.Length-1); i>=0; --i )
		if( AddedServerPackages[i]==O.Name )
			return;
	AddedServerPackages[AddedServerPackages.Length] = O.Name;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if( PlayerController(Other)!=None )
	{
		PendingPlayers[PendingPlayers.Length] = PlayerController(Other);
		SetTimer(0.1,false);
	}
	else if( Bot(Other)!=None && Bot(Other).PawnClass==Class'KFHumanPawn' )
	{
		Bot(Other).PawnClass = Class'SRHumanPawn';
		Bot(Other).PreviousPawnClass = Class'SRHumanPawn';
	}
	else if( ServerStStats(Other)!=None )
		SetServerPerks(ServerStStats(Other));
	else if( ClientPerkRepLink(Other)!=None )
		SetupRepLink(ClientPerkRepLink(Other));

	return true;
}
function SetServerPerks( ServerStStats Stat )
{
	local int i;

	Stat.MutatorOwner = Self;
	Stat.Rep.ServerWebSite = ServerNewsURL;
	Stat.Rep.MinimumLevel = MinPerksLevel+1;
	Stat.Rep.MaximumLevel = MaxPerksLevel+1;
	Stat.Rep.RequirementScaling = RequirementScaling;
	Stat.Rep.CachePerks.Length = LoadPerks.Length;
	for( i=0; i<LoadPerks.Length; i++ )
		Stat.Rep.CachePerks[i].PerkClass = LoadPerks[i];
}
function SetupRepLink( ClientPerkRepLink R )
{
	local int i;

	R.bMinimalRequirements = bUseLowestRequirements;
	R.bBWZEDTime = bBWZEDTime;
	R.bNoStandardChars = bForceCustomChars;

	R.ShopInventory.Length = LoadInventory.Length;
	for( i=0; i<LoadInventory.Length; ++i )
	{
		R.ShopInventory[i].PC = LoadInventory[i];
		R.ShopInventory[i].CatNum = LoadInvCategory[i];
	}
	R.ShopCategories = LoadedCategories;
	R.CustomChars = CustomCharacters;
	if( bEnabledEmoIcons )
		R.SmileyTags = SmileyMsgs;
}

function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	local int i,l;

	Super.GetServerDetails( ServerState );
	l = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.Length = l+1;
	ServerState.ServerInfo[l].Key = "SP: Version";
	ServerState.ServerInfo[l].Value = string(VersionNumber);
	l++;
	ServerState.ServerInfo.Length = l+1;
	ServerState.ServerInfo[l].Key = "SP: Min perk level";
	ServerState.ServerInfo[l].Value = string(MinPerksLevel);
	l++;
	ServerState.ServerInfo.Length = l+1;
	ServerState.ServerInfo[l].Key = "SP: Max perk level";
	ServerState.ServerInfo[l].Value = string(MaxPerksLevel);
	l++;
	ServerState.ServerInfo.Length = l+1;
	ServerState.ServerInfo[l].Key = "SP: Num trader weapons";
	ServerState.ServerInfo[l].Value = string(LoadInventory.Length);
	l++;
	For( i=0; i<LoadPerks.Length; i++ )
	{
		ServerState.ServerInfo.Length = l+1;
		ServerState.ServerInfo[l].Key = "SP: Perk "$(i+1);
		ServerState.ServerInfo[l].Value = LoadPerks[i].Default.VeterancyName;
		l++;
	}
}
function Timer()
{
	local int i;
	
	for( i=(PendingPlayers.Length-1); i>=0; --i )
	{
		if( KFPCServ(PendingPlayers[i])!=None )
			KFPCServ(PendingPlayers[i]).bUseAdvBehindview = bEnhancedShoulderView;
		if( PendingPlayers[i]!=None && PendingPlayers[i].Player!=None && ServerStStats(PendingPlayers[i].SteamStatsAndAchievements)==None )
		{
			if( PendingPlayers[i].SteamStatsAndAchievements!=None )
				PendingPlayers[i].SteamStatsAndAchievements.Destroy();
			PendingPlayers[i].SteamStatsAndAchievements = Spawn(Class'ServerStStats',PendingPlayers[i]);
			PendingPlayers[i].PlayerReplicationInfo.SteamStatsAndAchievements = PendingPlayers[i].SteamStatsAndAchievements;
		}
	}
	PendingPlayers.Length = 0;
}

final function string GetPlayerID( PlayerController PC )
{
	if( bUsePlayerNameAsID )
		return PC.PlayerReplicationInfo.PlayerName;
	return PC.GetPlayerIDHash();
}
function StatsObject GetStatsForPlayer( PlayerController PC )
{
	local StatsObject S;
	local string SId;
	local int i;

	if( Level.Game.bGameEnded )
		return None;
	SId = GetPlayerID(PC);
	for( i=0; i<ActiveStats.Length; ++i )
		if( string(ActiveStats[i].Name)~=SId )
		{
			S = ActiveStats[i];
			break;
		}
	if( S==None )
	{
		S = new(None,SId) Class'StatsObject';
		S.bStatsChanged = false;
		ActiveStats[ActiveStats.Length] = S;
	}
	S.PlayerName = PC.PlayerReplicationInfo.PlayerName;
	S.PlayerIP = PC.GetPlayerNetworkAddress();
	return S;
}

function SaveStats()
{
	local int i;
	local ClientPerkRepLink CP;

	if( bNoSavingProgress )
		return;

	Log("*** Saving "$ActiveStats.Length$" stat objects ***",Class.Outer.Name);
	foreach DynamicActors(Class'ClientPerkRepLink',CP)
		if( CP.StatObject!=None && ServerStStats(CP.StatObject).MyStatsObject!=None )
			ServerStStats(CP.StatObject).MyStatsObject.SetCustomValues(CP.CustomLink);

	if( bUseRemoteDatabase )
	{
		SaveAllStats();
		return;
	}
	for( i=0; i<ActiveStats.Length; ++i )
		if( ActiveStats[i].bStatsChanged )
		{
			ActiveStats[i].bStatsChanged = false;
			ActiveStats[i].SaveConfig();
		}
}
function CheckWinOrLose()
{
	local bool bWin;
	local Controller P;
	local PlayerController Player;

	bWin = (KFGameReplicationInfo(Level.GRI)!=None && KFGameReplicationInfo(Level.GRI).EndGameType==2);
	for ( P = Level.ControllerList; P != none; P = P.nextController )
	{
		Player = PlayerController(P);

		if ( Player != none )
		{
			if ( ServerStStats(Player.SteamStatsAndAchievements)!=None )
				ServerStStats(Player.SteamStatsAndAchievements).WonLostGame(bWin);
		}
	}
}
function InitNextWave()
{
	if( ++WaveCounter>=MidGameSaveWaves )
	{
		WaveCounter = 0;
		SaveStats();
	}
}

Auto state EndGameTracker
{
Begin:
	if( bUploadAllStats && Level.NetMode==NM_StandAlone )
	{
		Sleep(1.f);
		FTPTcpLink(Link).FullUpload();
		while( true )
		{
			if( KFGT!=None )
				KFGT.WaveCountDown = 60;
			Sleep(1.f);
		}
	}
	while( !Level.Game.bGameEnded )
	{
		Sleep(1.f);
		if( MidGameSaveWaves>0 && KFGT!=None && KFGT.WaveNum!=LastSavedWave )
		{
			LastSavedWave = KFGT.WaveNum;
			InitNextWave();
		}
		if( Level.bLevelChange )
		{
			SaveStats();
			Stop;
		}
	}
	CheckWinOrLose();
	SaveStats();
}

static final function string GetSafeName( string S )
{
	S = Repl(S,"=","-");
	S = Repl(S,Chr(10),""); // LF
	S = Repl(S,Chr(13),""); // CR
	S = Repl(S,"\"","'"); // " -> '
	return S;
}

delegate SaveAllStats();
delegate RequestStats( ServerStStats Other );

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.ServerPerksGroup,"MinPerksLevel","Min Perk Level",1,0, "Text", "4;-1:254");
	PlayInfo.AddSetting(default.ServerPerksGroup,"MaxPerksLevel","Max Perk Level",1,0, "Text", "4;0:254");
	PlayInfo.AddSetting(default.ServerPerksGroup,"RequirementScaling","Req Scaling",1,0, "Text", "6;0.01:4.00");
	PlayInfo.AddSetting(default.ServerPerksGroup,"bForceGivePerk","Force perks",1,0, "Check");
	PlayInfo.AddSetting(default.ServerPerksGroup,"bNoSavingProgress","No saving",1,0, "Check");
	PlayInfo.AddSetting(default.ServerPerksGroup,"bAllowAlwaysPerkChanges","Unlimited perk changes",1,0, "Check");
	PlayInfo.AddSetting(default.ServerPerksGroup,"bNoPerkChanges","No perk changes",1,0, "Check");
	PlayInfo.AddSetting(default.ServerPerksGroup,"bUseRemoteDatabase","Use remote database",1,0, "Check");
	PlayInfo.AddSetting(default.ServerPerksGroup,"bUseFTPLink","Use FTP remote database",1,0, "Check");
	PlayInfo.AddSetting(default.ServerPerksGroup,"RemoteDatabaseURL","Remote database URL",1,1,"Text","64");
	PlayInfo.AddSetting(default.ServerPerksGroup,"RemotePort","Remote database port",1,0, "Text", "5;0:65535");
	PlayInfo.AddSetting(default.ServerPerksGroup,"RemotePassword","Remote database password",1,0, "Text", "64");
	PlayInfo.AddSetting(default.ServerPerksGroup,"RemoteFTPUser","Remote database user",1,0, "Text", "64");
	PlayInfo.AddSetting(default.ServerPerksGroup,"RemoteFTPDir","Remote database dir",1,0, "Text", "64");
	PlayInfo.AddSetting(default.ServerPerksGroup,"FTPKeepAliveSec","FTP Keep alive sec",1,0, "Text", "6;0:600");
	PlayInfo.AddSetting(default.ServerPerksGroup,"MidGameSaveWaves","MidGame Save Waves",1,0, "Text", "5;0:10");
	PlayInfo.AddSetting(default.ServerPerksGroup,"ServerNewsURL","Newspage URL",1,0, "Text", "64");

	PlayInfo.AddSetting(default.ServerPerksGroup,"bUsePlayerNameAsID","Use PlayerName as ID",1,0, "Check");
	PlayInfo.AddSetting(default.ServerPerksGroup,"bMessageAnyPlayerLevelUp","Notify any levelup",1,0, "Check");
	PlayInfo.AddSetting(default.ServerPerksGroup,"bUseLowestRequirements","Use lowest req",1,0, "Check");
	PlayInfo.AddSetting(default.ServerPerksGroup,"bBWZEDTime","BW ZED-time",1,0, "Check");
	PlayInfo.AddSetting(default.ServerPerksGroup,"bUseEnhancedScoreboard","Enhanced scoreboard",1,0, "Check");
	PlayInfo.AddSetting(default.ServerPerksGroup,"bForceCustomChars","Force Custom Chars",1,0, "Check");
	PlayInfo.AddSetting(default.ServerPerksGroup,"bEnableChatIcons","Enable chat icons",1,0, "Check");
	PlayInfo.AddSetting(default.ServerPerksGroup,"bEnhancedShoulderView","Shoulder view",1,0, "Check");
	PlayInfo.AddSetting(default.ServerPerksGroup,"bFixGrenadeExploit","No Grenade Exploit",1,0, "Check");
	PlayInfo.AddSetting(default.ServerPerksGroup,"bAdminEditStats","Admin edit stats",1,0, "Check");
	PlayInfo.AddSetting(default.ServerPerksGroup,"bEnableWebAdmin","SP WebAdmin",1,0, "Check");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "MinPerksLevel":		return "Minimum perk level players can have.";
		case "MaxPerksLevel":		return "Maximum perk level players can have.";
		case "RequirementScaling":	return "Perk requirements scaling.";
		case "bForceGivePerk":		return "Force all players to get at least a random perk if they have none selected.";
		case "bNoSavingProgress":	return "Server shouldn't save perk progression.";
		case "bUseRemoteDatabase":	return "Instead of storing perk data locally on server, use remote data storeage server.";
		case "bUseFTPLink":			return "Use FTP transmission for remote database.";
		case "RemoteDatabaseURL":	return "URL of the remote database.";
		case "RemotePort":			return "Port of the remote database.";
		case "RemotePassword":		return "Password for server to access the remote database.";
		case "RemoteFTPUser":		return "User name for server to access the remote database (only for FTP mode).";
		case "MidGameSaveWaves":	return "Between how many waves should it mid-game save stats.";
		case "bUsePlayerNameAsID":	return "Use PlayerName's as ID instead of ID Hash.";
		case "bMessageAnyPlayerLevelUp": return "Broadcast a global message anytime someone gains a perk upgrade.";
		case "bUseLowestRequirements":	return "Use lowest form of requirements for perks.";
		case "bBWZEDTime":			return "Make screen go black and white during ZED-time.";
		case "bUseEnhancedScoreboard":	return "Should use serverperk's own scoreboard.";
		case "bAllowAlwaysPerkChanges":	return "Allow unlimited perk changes.";
		case "bForceCustomChars":	return "Force players to use specified custom characters.";
		case "bEnableChatIcons":	return "Should enable chat icons to replace specific tags in chat.";
		case "bEnhancedShoulderView": return "Should enable a more enhanced on shoulder behindview.";
		case "bFixGrenadeExploit":	return "Should fix unlimited grenades glitch/exploit.";
		case "bAdminEditStats":		return "Allow admins edit stats through an admin menu.";
		case "ServerNewsURL":		return "Server newspage menu URL for page contents.";
		case "RemoteFTPDir":		return "Remote FTP database data storage directory.";
		case "FTPKeepAliveSec":		return "Keep FTP database connection alive with this many sec interval.";
		case "bEnableWebAdmin":		return "Enable additional webserver interface.";
		case "bNoPerkChanges":	return "Never allow players change perk during match.";
	}
	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     Perks(0)="ServerPerksP.SRVetSupportSpec"
     Perks(1)="ServerPerksP.SRVetBerserker"
     Perks(2)="ServerPerksP.SRVetCommando"
     Perks(3)="ServerPerksP.SRVetFieldMedic"
     Perks(4)="ServerPerksP.SRVetFirebug"
     Perks(5)="ServerPerksP.SRVetSharpshooter"
     Perks(6)="ServerPerksP.SRVetDemolitions"
     TraderInventory(0)="5:KFMod.MP7MPickup"
     TraderInventory(1)="5:KFMod.BlowerThrowerPickup"
     TraderInventory(2)="5:KFMod.MP5MPickup"
     TraderInventory(3)="5:KFMod.M7A3MPickup"
     TraderInventory(4)="5:KFMod.KrissMPickup"
     TraderInventory(5)="2:KFMod.ShotgunPickup"
     TraderInventory(6)="2:KFMod.KSGPickup"
     TraderInventory(7)="2:KFMod.BoomStickPickup"
     TraderInventory(8)="2:KFMod.BenelliPickup"
     TraderInventory(9)="2:KFMod.AA12Pickup"
     TraderInventory(10)="2:KFMod.NailGunPickup"
     TraderInventory(11)="2:KFMod.SPShotGunPickup"
     TraderInventory(12)="1:KFMod.DualiesPickup"
     TraderInventory(13)="1:KFMod.MK23Pickup"
     TraderInventory(14)="1:KFMod.DualMK23Pickup"
     TraderInventory(15)="1:KFMod.Magnum44Pickup"
     TraderInventory(16)="1:KFMod.Dual44MagnumPickup"
     TraderInventory(17)="1:KFMod.DeaglePickup"
     TraderInventory(18)="1:KFMod.DualDeaglePickup"
     TraderInventory(19)="3:KFMod.WinchesterPickup"
     TraderInventory(20)="3:KFMod.CrossbowPickup"
     TraderInventory(21)="3:KFMod.M14EBRPickup"
     TraderInventory(22)="3:KFMod.M99Pickup"
     TraderInventory(23)="3:KFMod.SPSniperPickup"
     TraderInventory(24)="4:KFMod.BullpupPickup"
     TraderInventory(25)="4:KFMod.AK47Pickup"
     TraderInventory(26)="4:KFMod.MKb42Pickup"
     TraderInventory(27)="4:KFMod.M4Pickup"
     TraderInventory(28)="4:KFMod.SCARMK17Pickup"
     TraderInventory(29)="4:KFMod.FNFAL_ACOG_Pickup"
     TraderInventory(30)="4:KFMod.ThompsonPickup"
     TraderInventory(31)="4:KFMod.SPThompsonPickup"
     TraderInventory(32)="4:KFMod.ThompsonDrumPickup"
     TraderInventory(33)="0:KFMod.MachetePickup"
     TraderInventory(34)="0:KFMod.AxePickup"
     TraderInventory(35)="0:KFMod.ChainsawPickup"
     TraderInventory(36)="0:KFMod.KatanaPickup"
     TraderInventory(37)="0:KFMod.ClaymoreSwordPickup"
     TraderInventory(38)="0:KFMod.CrossbuzzsawPickup"
     TraderInventory(39)="0:KFMod.ScythePickup"
     TraderInventory(40)="0:KFMod.DwarfAxePickup"
     TraderInventory(41)="7:KFMod.FlameThrowerPickup"
     TraderInventory(42)="2:KFMod.TrenchgunPickup"
     TraderInventory(43)="1:KFMod.FlareRevolverPickup"
     TraderInventory(44)="1:KFMod.DualFlareRevolverPickup"
     TraderInventory(45)="4:KFMod.MAC10Pickup"
     TraderInventory(46)="7:KFMod.HuskGunPickup"
     TraderInventory(47)="6:KFMod.PipeBombPickup"
     TraderInventory(48)="6:KFMod.M79Pickup"
     TraderInventory(49)="6:KFMod.M32Pickup"
     TraderInventory(50)="4:KFMod.M4203Pickup"
     TraderInventory(51)="6:KFMod.SPGrenadePickup"
     TraderInventory(52)="6:KFMod.LAWPickup"
     TraderInventory(53)="6:KFMod.SealSquealPickup"
     TraderInventory(54)="6:KFMod.SeekerSixPickup"
     TraderInventory(55)="8:KFMod.ZEDGunPickup"
     TraderInventory(56)="8:KFMod.ZEDMKIIPickup"
     TraderInventory(57)="2:KFMod.GoldenAA12Pickup"
     TraderInventory(58)="4:KFMod.GoldenAK47Pickup"
     TraderInventory(59)="2:KFMod.GoldenBenelliPickup"
     TraderInventory(60)="0:KFMod.GoldenChainsawPickup"
     TraderInventory(61)="1:KFMod.GoldenDeaglePickup"
     TraderInventory(62)="1:KFMod.GoldenDualDeaglePickup"
     TraderInventory(63)="7:KFMod.GoldenFTPickup"
     TraderInventory(64)="0:KFMod.GoldenKatanaPickup"
     TraderInventory(65)="6:KFMod.GoldenM79Pickup"
     TraderInventory(66)="4:KFMod.CamoMP5MPickup"
     TraderInventory(67)="2:KFMod.CamoShotgunPickup"
     TraderInventory(68)="4:KFMod.CamoM4Pickup"
     TraderInventory(69)="6:KFMod.CamoM32Pickup"
     TraderInventory(70)="4:KFMod.NeonAK47Pickup"
     TraderInventory(71)="5:KFMod.NeonKrissMPickup"
     TraderInventory(72)="2:KFMod.NeonKSGPickup"
     TraderInventory(73)="4:KFMod.NeonSCARMK17Pickup"
     WeaponCategories(0)="4:Melee"
     WeaponCategories(1)="2:Pistol"
     WeaponCategories(2)="1:Shotgun"
     WeaponCategories(3)="2:Sniper"
     WeaponCategories(4)="3:Machine Gun"
     WeaponCategories(5)="0:Medic Gun"
     WeaponCategories(6)="6:Explosive"
     WeaponCategories(7)="5:Flame Thrower"
     WeaponCategories(8)="7:Misc"
     MaxPerksLevel=6
     RemotePort=5000
     RequirementScaling=1.000000
     RemoteDatabaseURL="192.168.1.33"
     RemotePassword="Pass"
     RemoteFTPUser="User"
     SmileyTags(0)=(iconTexture="ServerPerks.I_Mad",IconTag=">:(")
     SmileyTags(1)=(iconTexture="ServerPerks.I_Frown",IconTag=":(")
     SmileyTags(2)=(iconTexture="ServerPerks.I_GreenLickB",IconTag=":)")
     SmileyTags(3)=(iconTexture="ServerPerks.I_Tongue",IconTag=":P",bCaseInsensitive=True)
     SmileyTags(4)=(iconTexture="ServerPerks.I_GreenLick",IconTag=":d")
     SmileyTags(5)=(iconTexture="ServerPerks.I_BigGrin",IconTag=":D")
     SmileyTags(6)=(iconTexture="ServerPerks.I_Indiffe",IconTag=":|")
     SmileyTags(7)=(iconTexture="ServerPerks.I_Ohwell",IconTag=":/")
     SmileyTags(8)=(iconTexture="ServerPerks.I_RedFace",IconTag=":*")
     SmileyTags(9)=(iconTexture="ServerPerks.I_RedFace",IconTag=":-*")
     SmileyTags(10)=(iconTexture="ServerPerks.I_Ban",IconTag="Ban?",bCaseInsensitive=True)
     SmileyTags(11)=(iconTexture="ServerPerks.I_Cool",IconTag="B)")
     SmileyTags(12)=(iconTexture="ServerPerks.I_Hmm",IconTag="Hmm")
     SmileyTags(13)=(iconTexture="ServerPerks.I_Scream",IconTag="XD")
     SmileyTags(14)=(iconTexture="ServerPerks.I_Spam",IconTag="SPAM")
     VersionNumber=750
     ServerPerksGroup="Server Perks"
     SRScoreboardType=Class'ServerPerks.SRScoreBoard'
     SRHudType=Class'ServerPerks.SRHUDKillingFloor'
     SRMenuType=Class'ServerPerks.SRInvasionLoginMenu'
     SRControllerType=Class'ServerPerks.KFPCServ'
     bUseEnhancedScoreboard=True
     bEnableWebAdmin=True
     bEnableChatIcons=True
     bEnhancedShoulderView=True
     bFixGrenadeExploit=True
     bAdminEditStats=True
     GroupName="KF-Stats"
     FriendlyName="Server Veterancy Handler V7"
     Description="Use perks as privately on this server config instead of getting from global steam stats."
}
