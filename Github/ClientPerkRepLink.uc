class ClientPerkRepLink extends LinkedReplicationInfo
	DependsOn(SRHUDKillingFloor);

var int RDamageHealedStat, RWeldingPointsStat, RShotgunDamageStat, RHeadshotKillsStat, RChainsawKills,
		RStalkerKillsStat, RBullpupDamageStat, RMeleeDamageStat, RFlameThrowerDamageStat,RTotalZedTimeStat,
		RSelfHealsStat, RSoleSurvivorWavesStat, RCashDonatedStat, RFeedingKillsStat,RHuntingShotgunKills,
		RBurningCrossbowKillsStat, RGibbedFleshpoundsStat, RStalkersKilledWithExplosivesStat,
		RGibbedEnemiesStat, RBloatKillsStat, RSirenKillsStat, RKillsStat, RMedicKnifeKills, RExplosivesDamageStat,
		TotalPlayTime, WinsCount, LostsCount;
var byte MinimumLevel,MaximumLevel;
var float NextRepTime,RequirementScaling;
var int ClientAccknowledged[2],SendIndex,ClientAckSkinNum;

struct FPerksListType
{
	var class<SRVeterancyTypes> Perkclass;
	var byte CurrentLevel;
};
var array<FPerksListType> CachePerks;

var SRStatsBase StatObject;

struct FShopItemIndex
{
	var class<Pickup> PC;
	var byte CatNum,bDLCLocked;
};
var array< FShopItemIndex > ShopInventory;
var array<Material> ShopPerkIcons;
var array<string> ShopCategories,CustomChars;
var array<GUIBuyable> AllocatedObjects;
var array<SRHUDKillingFloor.SmileyMessageType> SmileyTags;

var SRCustomProgress CustomLink;

var bool bMinimalRequirements,bBWZEDTime,bNoStandardChars;

// Добавленное Dr. Killjoy aka Steklo

// переведена ли стата снайпера с голов, на дамаг
var		byte	RSharpStatModified;

// новые добавленные статы перков
var		int		RMachinegunDamageStat,RWeldingArmorPointsStat,RSmgDamageStat,RGunfighterDamageStat,RSilentDamageStat,RTurretDamageStat,RTechnicianDamageStat,
				RPatriarchKillsStat;

// Достижения



var		int		CompletedOnce;
var		texture	Icon[2];

struct native export KFAchievement
{
	var	string	DisplayName;
	var	string	Description;

	var	byte	bShowProgress;
	var	int		ProgressNumerator;
	var	int		ProgressDenominator;
	var byte	DisplayFormat;
	var byte    Done;
	var	texture	LockedIcon,UnlockedIcon;
};

var	array<KFAchievement>	Achievements,AchievementsSort;

CONST	Num_Achievements = 2;

CONST	AI_10PatKills = 0;

var		array<int>		RAchievementStat[Num_Achievements];

replication
{
	reliable if( Role==ROLE_Authority && bNetOwner )
		RDamageHealedStat, RWeldingPointsStat, RShotgunDamageStat, RHeadshotKillsStat, RChainsawKills,
		RStalkerKillsStat, RBullpupDamageStat, RMeleeDamageStat, RFlameThrowerDamageStat,
		RSelfHealsStat, RSoleSurvivorWavesStat, RCashDonatedStat, RFeedingKillsStat, RHuntingShotgunKills,
		RBurningCrossbowKillsStat, RGibbedFleshpoundsStat, RStalkersKilledWithExplosivesStat, RExplosivesDamageStat,
		RGibbedEnemiesStat, RBloatKillsStat, RTotalZedTimeStat, RSirenKillsStat, RKillsStat, RMedicKnifeKills,
		TotalPlayTime, WinsCount, LostsCount, bBWZEDTime, bNoStandardChars,
		MinimumLevel, RequirementScaling, MaximumLevel, bMinimalRequirements,CustomLink,
		RSharpStatModified,
		RMachinegunDamageStat,
		RWeldingArmorPointsStat,
		RSmgDamageStat,
		RGunfighterDamageStat,
		RSilentDamageStat,
		RPatriarchKillsStat,
		
			// Механик
		RTurretDamageStat,
		RTechnicianDamageStat;

	// Достижения

//	reliable if( Role==ROLE_Authority && bNetOwner )
//		RAchievementStat;

	// Functions server can call.
	reliable if( Role == ROLE_Authority )
		ClientReceivePerk,ClientPerkLevel,ClientReceiveWeapon,ClientSendAcknowledge,ClientReceiveCategory,ClientReceiveChar,ClientReceiveTag,ClientAllReceived;

	reliable if( Role < ROLE_Authority )
		ServerSelectPerk,ServerRequestPerks,ServerAcnowledge,ServerSetCharacter,ServerAckSkin;
}

function Destroyed()
{
	local SRCustomProgress S,NS;

	for( S=CustomLink; S!=None; S=NS )
	{
		NS = S.NextLink;
		S.Destroy();
	}
	Super.Destroyed();
}

simulated final function string GetCustomValue( class<SRCustomProgress> C )
{
	local SRCustomProgress S;

	for( S=CustomLink; S!=None; S=S.NextLink )
		if( S.class.Name==C.Name )
			return S.GetProgress();
	return "";
}
simulated final function int GetCustomValueInt( class<SRCustomProgress> C )
{
	local SRCustomProgress S;

	for( S=CustomLink; S!=None; S=S.NextLink )
		if( S.class.Name==C.Name )
			return S.GetProgressInt();
	return 0;
}
final function SRCustomProgress AddCustomValue( class<SRCustomProgress> C )
{
	local SRCustomProgress S,Last;

	for( S=CustomLink; S!=None; S=S.NextLink )
	{
		Last = S;
		if( S.class.Name==C.Name )
			return S;
	}
	S = Spawn(C,Owner);
	S.RepLink = Self;

	// Add new one in the end of the chain.
	if( Last!=None )
		Last.NextLink = S;
	else CustomLink = S;
	return S;
}
final function ProgressCustomValue( class<SRCustomProgress> C, int Count )
{
	local SRCustomProgress S;

	for( S=CustomLink; S!=None; S=S.NextLink )
	{
		if( S.class.Name==C.Name )
		{
			S.IncrementProgress(Count);
			break;
		}
	}
}

final function SpawnCustomLinks()
{
	local int i;

	for( i=0; i<CachePerks.Length; ++i )
		CachePerks[i].Perkclass.Static.AddCustomStats(Self);
}

simulated static final function ClientPerkRepLink FindStats( PlayerController Other )
{
	local LinkedReplicationInfo L;
	local ClientPerkRepLink C;

	if( Other.PlayerReplicationInfo==None )
	{
		foreach Other.DynamicActors(class'ClientPerkRepLink',C)
			if( C.Owner==Other )
			{
				C.RepLinkBroken();
				return C;
			}
		return None; // Not yet init.
	}
	for( L=Other.PlayerReplicationInfo.CustomReplicationInfo; L!=None; L=L.NextReplicationInfo )
		if( ClientPerkRepLink(L)!=None )
			return ClientPerkRepLink(L);
	if( Other.Level.NetMode!=NM_Client )
		return None; // Not yet init.
	foreach Other.DynamicActors(class'ClientPerkRepLink',C)
		if( C.Owner==Other )
		{
			C.RepLinkBroken();
			return C;
		}
	return None;
}

simulated function Tick( float DeltaTime )
{
	local PlayerController PC;
	local LinkedReplicationInfo L;

	if( Level.NetMode==NM_DedicatedServer )
	{
		Disable('Tick');
		return;
	}
	PC = Level.GetLocalPlayerController();
	if( Level.NetMode!=NM_Client && PC!=Owner )
	{
		Disable('Tick');
		return;
	}
	if( PC.PlayerReplicationInfo==None )
		return;
	Disable('Tick');
	class'SRLevelCleanup'.Static.AddSafeCleanup(PC);

	if( PC.PlayerReplicationInfo.CustomReplicationInfo!=None )
	{
		for( L=PC.PlayerReplicationInfo.CustomReplicationInfo; L!=None; L=L.NextReplicationInfo )
			if( L==Self )
				return; // Make sure not already added.

		NextReplicationInfo = None;
		for( L=PC.PlayerReplicationInfo.CustomReplicationInfo; L!=None; L=L.NextReplicationInfo )
			if( L.NextReplicationInfo==None )
			{
				L.NextReplicationInfo = Self; // Add to the end of the chain.
				return;
			}
	}
	PC.PlayerReplicationInfo.CustomReplicationInfo = Self;
}
simulated final function RepLinkBroken() // Called by GUI when this is noticed.
{
	Enable('Tick');
	Tick(0);
}

final function class<SRVeterancyTypes> PickRandomPerk()
{
	local array< class<SRVeterancyTypes> > CA;
	local int i;

	for( i=0; i<CachePerks.Length; i++ )
	{
		if( CachePerks[i].Perkclass!=None && CachePerks[i].CurrentLevel>0 )
			CA[CA.Length] = CachePerks[i].Perkclass;
	}
	if( CA.Length==0 )
		return None;
	return CA[Rand(CA.Length)];
}
final function ServerSelectPerk( class<SRVeterancyTypes> VetType )
{
	StatObject.ServerSelectPerk(VetType);
}
final function ServerRequestPerks()
{
	if( NextRepTime<Level.TimeSeconds )
		SendClientPerks();
}
final function SendClientPerks()
{
	local byte i;

	if( !StatObject.bStatsReadyNow )
		return;
	NextRepTime = Level.TimeSeconds+2.f;
	for( i=0; i<CachePerks.Length; i++ )
		ClientReceivePerk(i,CachePerks[i].Perkclass,CachePerks[i].CurrentLevel);
}
simulated function ClientReceivePerk( int Index, class<SRVeterancyTypes> V, byte Level )
{
	// Setup correct icon for trader.
	if( V.Default.PerkIndex<255 && V.Default.OnHUDIcon!=None )
	{
		if( ShopPerkIcons.Length<=V.Default.PerkIndex )
			ShopPerkIcons.Length = V.Default.PerkIndex+1;
		ShopPerkIcons[V.Default.PerkIndex] = V.Default.OnHUDIcon;
	}

	if( CachePerks.Length<=Index )
		CachePerks.Length = (Index+1);
	CachePerks[Index].Perkclass = V;
	CachePerks[Index].CurrentLevel = Level;
}
simulated final function ClientReceiveTag( Texture T, string Tag, bool bInCaps )
{
	local int i;
	
	i = SmileyTags.Length;
	SmileyTags.Length = i+1;
	SmileyTags[i].SmileyTex = T;
	SmileyTags[i].SmileyTag = Tag;
	SmileyTags[i].bInCAPS = bInCaps;
}
simulated final function ClientAllReceived()
{
	local PlayerController PC;
	local int i;

	PC = Level.GetLocalPlayerController();
	
	if( (PC!=None && PC==Owner) || Level.NetMode==NM_Client )
	{
		// Check if a DLC check is required.
		for( i=(ShopInventory.Length-1); i>=0; --i )
			if( ShopInventory[i].bDLCLocked!=0 )
			{
				Spawn(class'SRSteamStatsGet',Owner).Link = Self;
				break;
			}
	}

	if( SmileyTags.Length==0 )
		return;
	if( PC!=None && SRHUDKillingFloor(PC.MyHUD)!=None )
		SRHUDKillingFloor(PC.MyHUD).SmileyMsgs = SmileyTags;
}

simulated function ClientPerkLevel( int Index, byte CurLevel )
{
	Level.GetLocalPlayerController().ReceiveLocalizedMessage(class'KFVetEarnedMessageSR',(CurLevel-1),,,CachePerks[Index].Perkclass);
	CachePerks[Index].CurrentLevel = CurLevel;
}

simulated function ClientReceiveWeapon( int Index, class<Pickup> P, byte Categ )
{
	ShopInventory.Length = Max(ShopInventory.Length,Index+1);
	if( ShopInventory[Index].PC==None )
	{
		ShopInventory[Index].PC = P;
		ShopInventory[Index].CatNum = Categ;
		if( class<KFWeapon>(P.Default.InventoryType)!=none
		 && (class<KFWeapon>(P.Default.InventoryType).Default.AppID>0
		 || class<KFWeapon>(P.Default.InventoryType).Default.UnlockedByAchievement!=-1) )
			ShopInventory[Index].bDLCLocked = 1;
		++ClientAccknowledged[0];
	}
}
simulated function ClientReceiveCategory( byte Index, string S )
{
	ShopCategories.Length = Max(ShopCategories.Length,Index+1);
	if( ShopCategories[Index]=="" )
	{
		ShopCategories[Index] = S;
		++ClientAccknowledged[1];
	}
}
simulated function ClientSendAcknowledge()
{
	ServerAcnowledge(ClientAccknowledged[0],ClientAccknowledged[1]);
}
function ServerAcnowledge( int A, int B )
{
	ClientAccknowledged[0] = A;
	ClientAccknowledged[1] = B;
}
simulated function ClientReceiveChar( string CharName, int Num )
{
	CustomChars.Length = Num+1;
	CustomChars[Num] = CharName;
	ServerAckSkin(Num+1);
}

function ServerAckSkin( int Index )
{
	ClientAckSkinNum = Index;
}

/*simulated final function string PickRandomCustomChar()
{
	local string S;
	local int i;
	
	if( CustomChars.Length==0 )
		return "";
	S = CustomChars[Rand(CustomChars.Length)];
	i = InStr(S,":");
	if( i>=0 )
		S = Mid(S,i+1);
	return S;
}*/
simulated final function string PickRandomCustomChar()
{
	
	if( CustomChars.Length==0 )
		return "";
	return "Sergeant_Powers";
}
simulated final function bool IsCustomCharacter( string CN )
{
	local int i;

	for( i=0; i<CustomChars.Length; ++i )
		if( CustomChars[i]~=CN || Right(CustomChars[i],Len(CN)+1)~=(":"$CN) )
			return true;
	return false;
}
simulated final function SelectedCharacter( string CN )
{
	if( !IsCustomCharacter(CN) ) // Was not a custom character, update URL too.
	{
		if( bNoStandardChars && CustomChars.Length>0 ) // Denied.
			return;
		Level.GetLocalPlayerController().UpdateURL("Character", CN, True);
	}

	ServerSetCharacter(CN);
}

function ServerSetCharacter( string CN )
{
	if( xPlayer(Owner)!=None )
		StatObject.ChangeCharacter(CN);
}

final function bool CanBuyPickup( class<KFWeaponPickup> WC )
{
	local int i;
	local KFPlayerReplicationInfo K;
	
	for( i=(ShopInventory.Length-1); i>=0; --i )
		if( ShopInventory[i].PC==WC )
		{
			K = KFPlayerReplicationInfo(StatObject.PlayerOwner.PlayerReplicationInfo);
			for( i=(CachePerks.Length-1); i>=0; --i )
				if( !CachePerks[i].Perkclass.Static.AllowWeaponInTrader(WC,K,CachePerks[i].CurrentLevel) )
					return false;
			return true;
		}
	return false;
}

Auto state RepSetup
{
	final function InitDLCCheck()
	{
		local int i;
		
		for( i=(ShopInventory.Length-1); i>=0; --i )
		{
			if( class<KFWeapon>(ShopInventory[i].PC.Default.InventoryType)!=none
			 && (class<KFWeapon>(ShopInventory[i].PC.Default.InventoryType).Default.AppID>0
			 || class<KFWeapon>(ShopInventory[i].PC.Default.InventoryType).Default.UnlockedByAchievement!=-1) )
				ShopInventory[i].bDLCLocked = 1;
		}
	}
Begin:
	if( Level.NetMode==NM_Client )
		Stop;
	Sleep(1.f);
	NetUpdateFrequency = 0.5f;

	if( NetConnection(StatObject.PlayerOwner.Player)!=None ) // Network client.
	{
		// Now MAKE SURE client receives the full inventory list.
		while( ClientAccknowledged[0]<ShopInventory.Length || ClientAccknowledged[1]<ShopCategories.Length )
		{
			for( SendIndex=0; SendIndex<ShopInventory.Length; ++SendIndex )
			{
				ClientReceiveWeapon(SendIndex,ShopInventory[SendIndex].PC,ShopInventory[SendIndex].CatNum);
				Sleep(0.1f);
			}
			for( SendIndex=0; SendIndex<ShopCategories.Length; ++SendIndex )
			{
				ClientReceiveCategory(SendIndex,ShopCategories[SendIndex]);
				Sleep(0.1f);
			}
			ClientSendAcknowledge();
			Sleep(1.f);
		}

		// Send client all the custom characters.
		while( ClientAckSkinNum<CustomChars.Length )
		{
			ClientReceiveChar(CustomChars[ClientAckSkinNum],ClientAckSkinNum);
			Sleep(0.15f);
		}
		// Send all chat icons.
		for( SendIndex=0; SendIndex<SmileyTags.Length; ++SendIndex )
		{
			ClientReceiveTag(SmileyTags[SendIndex].SmileyTex,SmileyTags[SendIndex].SmileyTag,SmileyTags[SendIndex].bInCAPS);
			Sleep(0.1f);
		}
		SmileyTags.Length = 0;
	}
	ClientAllReceived();
	GoToState('');
}

simulated final function ResetItem( GUIBuyable Item )
{
	Item.ItemName = "";
	Item.ItemDescription = "";
	Item.ItemCategorie = "";
	Item.ItemImage = None;
	Item.ItemWeaponclass = None;
	Item.ItemAmmoclass = None;
	Item.ItemPickupclass = None;
	Item.ItemCost = 0;
	Item.ItemAmmoCost = 0;
	Item.ItemFillAmmoCost = 0;
	Item.ItemWeight = 0;
	Item.ItemPower = 0;
	Item.ItemRange = 0;
	Item.ItemSpeed = 0;
	Item.ItemAmmoCurrent = 0;
	Item.ItemAmmoMax = 0;
	Item.bSaleList = false;
	Item.bSellable = false;
	Item.bMelee = false;
	Item.bIsVest = false;
	Item.bIsFirstAidKit = false;
	Item.ItemPerkIndex = 0;
	Item.ItemSellValue = 0;
}
defaultproperties
{
     MaximumLevel=7
     RequirementScaling=1.000000
     ShopPerkIcons(0)=Texture'KillingFloorHUD.Perks.Perk_Medic'
     ShopPerkIcons(1)=Texture'KillingFloorHUD.Perks.Perk_Support'
     ShopPerkIcons(2)=Texture'KillingFloorHUD.Perks.Perk_SharpShooter'
     ShopPerkIcons(3)=Texture'KillingFloorHUD.Perks.Perk_Commando'
     ShopPerkIcons(4)=Texture'KillingFloorHUD.Perks.Perk_Berserker'
     ShopPerkIcons(5)=Texture'KillingFloorHUD.Perks.Perk_Firebug'
     ShopPerkIcons(6)=Texture'KillingFloor2HUD.Perk_Icons.Perk_Demolition'
	 ShopPerkIcons(7)=Texture'SunriseHUD.Icons.Perk_Juggernaut_red'
	 ShopPerkIcons(8)=Texture'SunriseHUD.Icons.Perk_Saboteur_red'
	 ShopPerkIcons(9)=Texture'SunriseHUD.Icons.Perk_Gunfighter_red'
	 ShopPerkIcons(10)=Texture'SunriseHUD.Icons.Perk_Engineer'
	 ShopPerkIcons(11)=Texture'SunriseHUD.Icons.Perk_Infiltrator'
	 bOnlyRelevantToOwner=True
     bAlwaysRelevant=False
	 
	Icon(0)=none
    Icon(1)=none
	
	Achievements(AI_10PatKills)=(DisplayName="Победитель Патриарха",Description="Добить Патриарха 10 раз",bShowProgress=1,ProgressDenominator=10)
}
