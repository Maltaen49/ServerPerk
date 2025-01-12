class DKGameType extends GTBasis 
	config(ServerPerksV4C);

var globalconfig	bool	bDebug,bDebugRandSpawns;
var globalconfig	string	BossClassDK;
var globalconfig array<int> MonsterNumPerWave;
var() globalconfig int SRMaxPlayers;

//var Lie2menSpectator Lie2men;

struct	BannedInfo
{
	var string ID;
	var string PlName;
};

//var	globalconfig array<BannedInfo> TosscashBuggers;
//var array<ReservePlayerReplicationInfo> RepRecords;

var		int     	StartingCashDoomsday; // The starting cash for Dies Irae difficulty
var		int  	   	MinRespawnCashDoomsday; // The starting cash for Dies Irae difficulty
var		int    		TimeBetweenWavesDoomsday;
var		float		DemoFireDamageModifier;
var		bool		bRequestZedTime;

var		float		AllowKillzedTime;
var		KFPCServ	KillzedInstigator;

//Difficulty variables
var	bool	b6lvlPresence,b9lvlPresence,b10lvlPresence;
var	float	AveragePerkLevel;
var	float	DoubleZedSpawnPossibility,ProfResist,ZedNumModifier;

var int CurrentWave;
var int EndyCounter;

struct MonstersSquad
{
	var array< class<KFMonster> > Filling;
};

struct WaveSquadsList
{
	var array<MonstersSquad> Squads;
};

struct SquadNote
{
	var array<int> MonNum;
	var array< class<KFMonster> > MonClass;
};

struct WaveSquadNote
{
	var array<SquadNote> Squads;
};

var array<WaveSquadNote> LevelSquadNote;

var array<WaveSquadsList> LevelSquads;
var WaveSquadsList SquadsTemplate,CurrentSquads;

// Special Squad Additional Control

var int NumLastSpawned;
var int SpecSquadSpawnCounter,SpecSquadAltSpawnCounter,WaveMonstersLimit;
var array<int> SpecSquadSpawnFrequency;
var array<int> SpecSquadAltSpawnFrequency;

var const float	RSMC_Fleshpound,
				RSMC_FleshpoundP,
				RSMC_Brute,
				RSMC_Scrake,
				RSMC_ScrakeKF2,
				//RSMC_FFP,
				RSMC_Shiver,
				//RSMC_ShiverP,
				RSMC_Reaver,
				//RSMC_ReaverP,
				RSMC_Husk,
				RSMC_Siren,
				RSMC_Poisoner,
				RSMC_Demolisher;

// Random Patriarch spawning in the middle of the game

var float	BossEarlySpawnChance,BossEarlySpawnPlace;
var int		BossEarlySpawnWaveNum,SpawnedMonsters;
var bool	bEarlySpawnBoss;

var array<string> RespawnedPlayer;
var FileLog CorrespondenceLog;

replication
{
	reliable if ( Role == ROLE_Authority )
		AveragePerkLevel;
}

function DramaticEvent(float BaseZedTimePossibility, optional float F2)
{
	local float RandChance;
	local float TimeSinceLastEvent;
	local Controller C;
	
	if ( !bWaveInProgress )
		return;
		
	if ( BaseZedTimePossibility < 0.99 )
		return;

	TimeSinceLastEvent = Level.TimeSeconds - LastZedTimeEvent;


	// Don't go in slomo if we were just IN slomo
	if( TimeSinceLastEvent < 40.0 && BaseZedTimePossibility != 1.0 )
	{
		return;
	}

	RandChance = FRand();
	
	RandChance /= 0.25 * float(GetActualPlayersNum());
	
	if( TimeSinceLastEvent > 60 )
	{
		RandChance /= 0.030 / TimeSinceLastEvent; // за каждые 30 секунд, вероятность увеличивается на 100% от начальной
	}

	//log("TimeSinceLastEvent = "$TimeSinceLastEvent$" RandChance = "$RandChance$" BaseZedTimePossibility = "$BaseZedTimePossibility);

	if( RandChance <= BaseZedTimePossibility || BaseZedTimePossibility > 0.99 )
	{
		bZEDTimeActive =  true;
		bSpeedingBackUp = false;
		LastZedTimeEvent = Level.TimeSeconds;
		CurrentZEDTimeDuration = ZEDTimeDuration;

		SetGameSpeed(ZedTimeSlomoScale);

		for ( C = Level.ControllerList; C != none; C = C.NextController )
		{
			if (KFPlayerController(C)!= none)
			{
				KFPlayerController(C).ClientEnterZedTime();
			}

			if ( C.PlayerReplicationInfo != none && KFSteamStatsAndAchievements(C.PlayerReplicationInfo.SteamStatsAndAchievements) != none )
			{
				KFSteamStatsAndAchievements(C.PlayerReplicationInfo.SteamStatsAndAchievements).AddZedTime(ZEDTimeDuration);
			}
		}
	}
}

function ZedTime(optional bool bProlong)
{
	local Controller C;
	
	if ( !KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress )
		return;

	bSpeedingBackUp = false;
	LastZedTimeEvent = Level.TimeSeconds;
	if ( bZEDTimeActive && bProlong )
		CurrentZEDTimeDuration += ZEDTimeDuration;
	else
		CurrentZEDTimeDuration = ZEDTimeDuration;
	bZEDTimeActive = true;

	SetGameSpeed(ZedTimeSlomoScale);

	for ( C = Level.ControllerList; C != none; C = C.NextController )
	{
		if (KFPlayerController(C)!= none)
		{
			KFPlayerController(C).ClientEnterZedTime();
		}

		if ( C.PlayerReplicationInfo != none && KFSteamStatsAndAchievements(C.PlayerReplicationInfo.SteamStatsAndAchievements) != none )
		{
			KFSteamStatsAndAchievements(C.PlayerReplicationInfo.SteamStatsAndAchievements).AddZedTime(ZEDTimeDuration);
		}
	}
	
}

event InitGame( string Options, out string Error )
{
	local float BossEarlySpawnWaveDeterminator;

	Super.InitGame(Options, Error);
	
	default.MaxPlayers = SRMaxPlayers;
	default.MaxSpectators = 10;
	MaxPlayers = SRMaxPlayers;
	MaxSpectators = 10;
	InitialWave = 0;
	FinalWave = 7;
	CurrentWave = InitialWave;
	LobbyTimeout = 25;
	
	//Lie2men = Spawn(class'Lie2menSpectator',Self);
	
	/*
	if ( FRand() < BossEarlySpawnChance )
	{
		bEarlySpawnBoss = true;
		BossEarlySpawnWaveDeterminator = FRand();
		if ( BossEarlySpawnWaveDeterminator < 0 )
			BossEarlySpawnWaveNum = 0;
		else if ( BossEarlySpawnWaveDeterminator < 0.16 )
			BossEarlySpawnWaveNum = 1;
		else if ( BossEarlySpawnWaveDeterminator < 0.36 )
			BossEarlySpawnWaveNum = 2;
		else if ( BossEarlySpawnWaveDeterminator < 0.60 )
			BossEarlySpawnWaveNum = 3;
		else if ( BossEarlySpawnWaveDeterminator < 0.84 )
			BossEarlySpawnWaveNum = 4;
		else if ( BossEarlySpawnWaveDeterminator < 0.96 )
			BossEarlySpawnWaveNum = 5;
		else
			BossEarlySpawnWaveNum = 6;
		BossEarlySpawnPlace = 0.10 + FRand() * 0.80; // От 10% мобов до 90%
	}
	*/
	//FillLevelSquads();

	// Set up the default game type settings
	bUseEndGameBoss = true;
	bRespawnOnBoss = true;
	MonsterClasses = StandardMonsterClasses;
	MonsterSquad = StandardMonsterSquads;
	MaxZombiesOnce = StandardMaxZombiesOnce;
	bCustomGameLength = false;
	UpdateGameLength();
	
	if ( CorrespondenceLog == none )
	{
		CorrespondenceLog = Spawn(class'FileLog',Self);
		CorrespondenceLog.OpenLog("Correspondence");
	}
}

function SetupWave()
{
	local int i,j;
	local float NewMaxMonsters;
	//local int m;
	local float DifficultyMod, NumPlayersMod;
	local int UsedNumPlayers;
	local int NumPlayersLocal;

	if ( WaveNum > 15 )
	{
		SetupRandomWave();
		return;
	}

	NumPlayersLocal = GetActualPlayersNum();
	CalculateDifficultyByAverageLevel();
	SpecSquadSpawnCounter = SpecSquadSpawnFrequency[WaveNum] + 10000;
	SpecSquadAltSpawnCounter = SpecSquadAltSpawnFrequency[WaveNum] + 10000;
	SpawnedMonsters = 0;
	TraderProblemLevel = 0;
	rewardFlag=false;
	ZombiesKilled=0;
	WaveMonsters = 0;
	WaveNumClasses = 0;
	NewMaxMonsters = Waves[WaveNum].WaveMaxMonsters;
	SetCurrentSquads();

	// scale number of zombies by difficulty
	
//------Added---------------------------------------------------------
	if ( GameDifficulty >= 7.0 ) // Dies Irae
	{
		DifficultyMod=2.0;//2.0;
	}
//--------------------------------------------------------------------
	else if ( GameDifficulty >= 5.0 ) // Hell on Earth
	{
		DifficultyMod=2.6;//1.7;
	}
	else if ( GameDifficulty >= 4.0 ) // Suicidal
	{
		DifficultyMod=2.6;
	}
	else if ( GameDifficulty >= 2.0 ) // Hard
	{
		DifficultyMod=2.2;
	}
	else if ( GameDifficulty == 1.0 ) // Normal
	{
		DifficultyMod=1.3;
	}

	UsedNumPlayers = NumPlayersLocal + NumBots;

	// Scale the number of zombies by the number of players. Don't want to
	// do this exactly linear, or it just gets to be too many zombies and too
	// long of waves at higher levels - Ramm
	switch ( UsedNumPlayers )
	{
		default:
			NumPlayersMod = 2.50 + UsedNumPlayers * 0.60;
	}

	NewMaxMonsters = NewMaxMonsters * DifficultyMod * NumPlayersMod * ( 1.0 + ZedNumModifier );

	TotalMaxMonsters = Clamp(NewMaxMonsters,5,2800);  //11, MAX 1500, MIN 5
	WaveMonstersLimit = TotalMaxMonsters;

	MaxMonsters = Clamp(TotalMaxMonsters,1,MaxZombiesOnce);
	//log("****** "$MaxMonsters$" Max at once!");

	KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonsters=TotalMaxMonsters;
	KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonstersOn=true;
	WaveEndTime = Level.TimeSeconds + 250;
	AdjustedDifficulty = GameDifficulty + Waves[WaveNum].WaveDifficulty;

	j = ZedSpawnList.Length;
	for( i=0; i<j; i++ )
		ZedSpawnList[i].Reset();
	j = 1;
	SquadsToUse.Length = 0;

	for ( i=0; i<InitSquads.Length; i++ )
	{
		if ( (j & Waves[WaveNum].WaveMask) != 0 )
		{
			SquadsToUse.Insert(0,1);
			SquadsToUse[0] = i;

			// Ramm ZombieSpawn debugging
			/*for ( m=0; m<InitSquads[i].MSquad.Length; m++ )
			{
			log("Wave "$WaveNum$" Squad "$SquadsToUse.Length$" Monster "$m$" "$InitSquads[i].MSquad[m]);
			}
			log("****** "$TotalMaxMonsters);*/
		}
		j *= 2;
	}

	// Save this for use elsewhere
	InitialSquadsToUseSize = SquadsToUse.Length;
	bUsedSpecialSquad=false;
	SpecialListCounter=1;

	//Now build the first squad to use
	//BuildNextSquad();
}

/*function ScoreKillAssists(float Score, Controller Victim, Controller Killer)
{
	local int i;
	local float GrossDamage, ScoreMultiplier, KillScore;
	local KFMonsterController MyVictim;
	local KFPlayerReplicationInfo KFPRI;

	MyVictim = KFMonsterController(Victim);

	if ( MyVictim.KillAssistants.Length < 1 )
	{
		return;
	}
	else
	{
		for ( i = 0; i < MyVictim.KillAssistants.Length; i++ )
		{
			GrossDamage += MyVictim.KillAssistants[i].Damage;
		}

		ScoreMultiplier = Score / GrossDamage;

		for ( i = 0; i < MyVictim.KillAssistants.Length; i++  )
		{
			if ( MyVictim.KillAssistants[i].PC != none &&
			MyVictim.KillAssistants[i].PC.PlayerReplicationInfo != none)
			{
				KillScore = ScoreMultiplier * MyVictim.KillAssistants[i].Damage;
				MyVictim.KillAssistants[i].PC.PlayerReplicationInfo.Score += KillScore;

				KFPRI = KFPlayerReplicationInfo(MyVictim.KillAssistants[i].PC.PlayerReplicationInfo) ;
				if(KFPRI != none)
				{
					if(MyVictim.KillAssistants[i].PC != Killer)
					{
						KFPRI.KillAssists ++ ;
					}

					KFPRI.ThreeSecondScore += KillScore;
				}
			}
		}
	}
}*/
function ScoreKill(Controller Killer, Controller Other)
{
	local PlayerReplicationInfo OtherPRI,KillerPRI;
	local float KillScore;
	local KFPlayerReplicationInfo KFPRI;
	if ( Killer != none )
		KillerPRI=Killer.PlayerReplicationInfo;
	if( KillerPRI != none )
		KFPRI=KFPlayerReplicationInfo(KillerPRI);

	if ( Other != none )
		OtherPRI = Other.PlayerReplicationInfo;
	if ( OtherPRI != None )
	{
		OtherPRI.NumLives++;
		OtherPRI.Score -= (OtherPRI.Score * (GameDifficulty * 0.05));	// you Lose 35% of your current cash on Hell on Earth, 15% on normal.
		OtherPRI.Team.Score -= (OtherPRI.Score * (GameDifficulty * 0.05));

		if (OtherPRI.Score < 0 )
			OtherPRI.Score = 0;
		if (OtherPRI.Team.Score < 0 )
			OtherPRI.Team.Score = 0;

		OtherPRI.Team.NetUpdateTime = Level.TimeSeconds - 1;
		OtherPRI.bOutOfLives = true;
		if( Killer!=None && Killer.PlayerReplicationInfo!=None && Killer.bIsPlayer )
			BroadcastLocalizedMessage(class'KFInvasionMessage',1,OtherPRI,Killer.PlayerReplicationInfo);
		else if( Killer==None || Killer.Pawn != none && Monster(Killer.Pawn)==None )
			BroadcastLocalizedMessage(class'KFInvasionMessage',1,OtherPRI);
		else BroadcastLocalizedMessage(class'KFInvasionMessage',1,OtherPRI,,Killer.Pawn.Class);
		CheckScore(None);
	}

	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreKill(Killer, Other);

	if ( MonsterController(Killer) != None )
		return;

	if( (killer == Other) || (killer == None) )
	{
		if ( Other.PlayerReplicationInfo != None )
		{
			Other.PlayerReplicationInfo.Score -= 1;
			Other.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
			ScoreEvent(Other.PlayerReplicationInfo,-1,"self_frag");
		}
	}

	if ( Killer==None || !Killer.bIsPlayer || (Killer==Other) )
		return;

	if ( Other.bIsPlayer )
	{
		Killer.PlayerReplicationInfo.Score -= 5;
		Killer.PlayerReplicationInfo.Team.Score -= 2;
		Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
		ScoreEvent(Killer.PlayerReplicationInfo, -5, "team_frag");
		return;
	}
	if ( LastKilledMonsterClass == None )
		KillScore = 1.0;
	else if(Killer.PlayerReplicationInfo !=none)
	{
		KillScore = LastKilledMonsterClass.Default.ScoringValue;
		
		if ( Killer.PlayerReplicationInfo != none && SRPlayerReplicationInfo(Killer.PlayerReplicationInfo) != none )
		{
			KillScore *= class<SRVeterancyTypes>(SRPlayerReplicationInfo(Killer.PlayerReplicationInfo).ClientVeteranSkill).Static.GetMoneyReward(SRPlayerReplicationInfo(Killer.PlayerReplicationInfo),class<KFMonster>(LastKilledMonsterClass));
		}

		KillScore = FMax(1.00,KillScore);
		Killer.PlayerReplicationInfo.Kills++;

		ScoreKillAssists(KillScore, Other, Killer);

		Killer.PlayerReplicationInfo.Team.Score += KillScore;
		Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
		TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "tdm_frag");
	}

	if (Killer.PlayerReplicationInfo !=none && Killer.PlayerReplicationInfo.Score < 0)
		Killer.PlayerReplicationInfo.Score = 0;
}

/*
function bool AddSquad()
{
	local int numspawned;
	local int ZombiesAtOnceLeft;
	local int TotalZombiesValue;
	local class<DKMonster> RandomMon;

	if(LastZVol==none || NextSpawnSquad.length==0)
	{
		// Throw in the special squad if the time is right
		if( SpecialSquads[WaveNum].ZedClass.Length > 0 && ( SpecSquadSpawnFrequency[WaveNum] < SpecSquadSpawnCounter ) )
		{
			if ( WaveNum > 0 || IsCurrentPerkLevelPresent(6,false) )
			{
				//AddSpecialSquad();
			}
			else
			{
				//BuildNextSquad();
			}
		}
		else
		{
			RandomMon = MaybeSpawnRandomMon();
			if ( RandomMon != none )
			{
				if ( RandomMon == class'DKPoisoner' )
					AddSpecialMonster(RandomMon,2);
				else if ( RandomMon == class'DKShiver' )
					AddSpecialMonster(RandomMon,4);
				else if ( RandomMon == class'DKReaver' )
					AddSpecialMonster(RandomMon,4);
				else
					AddSpecialMonster(RandomMon,1);
			}
			else if ( bEarlySpawnBoss && WaveNum == BossEarlySpawnWaveNum && SpawnedMonsters > int(float(WaveMonstersLimit)*BossEarlySpawnPlace) )
				AddBossEarly();
			else
				BuildNextSquad();
		}
		LastZVol = FindSpawningVolume();
		if( LastZVol!=None )
			LastSpawningVolume = LastZVol;
	}

	if(LastZVol == None)
	{
		NextSpawnSquad.length = 0;
		return false;
	}

	// How many zombies can we have left to spawn at once
	ZombiesAtOnceLeft = MaxMonsters + Max(0,int(float(GetActualPlayersNum()) * 1.5 - 18)) - NumMonsters; // если игроков больше 12, позволяем заспавнить на карту
																								// больше мобов, за каждого игрока на 1.5 моба больше
	//Log("Spawn on"@LastZVol.Name);
	if( LastZVol.SpawnInHere(NextSpawnSquad,,numspawned,TotalMaxMonsters,ZombiesAtOnceLeft,TotalZombiesValue) )
	{
		NumMonsters += numspawned; //NextSpawnSquad.Length;
		WaveMonsters+= numspawned; //NextSpawnSquad.Length;
		SpecSquadSpawnCounter += numspawned;
		SpecSquadAltSpawnCounter += numspawned;
		SpawnedMonsters += numspawned;
		

		if( bDebugMoney )
		{
//------Added---------------------------------------------------------
			if ( GameDifficulty >= 7.0 ) // Dies Irae
			{
				TotalZombiesValue *= 0.4;
			}
//--------------------------------------------------------------------
			else if ( GameDifficulty >= 5.0 ) // Hell on Earth
			{
				TotalZombiesValue *= 0.5;
			}
			else if ( GameDifficulty >= 4.0 ) // Suicidal
			{
				TotalZombiesValue *= 0.6;
			}
			else if ( GameDifficulty >= 2.0 ) // Hard
			{
				TotalZombiesValue *= 0.75;
			}
			else if ( GameDifficulty == 1.0 ) // Normal
			{
				TotalZombiesValue *= 1.0;
			}

			TotalPossibleWaveMoney += TotalZombiesValue;
			TotalPossibleMatchMoney += TotalZombiesValue;
		}

		NextSpawnSquad.Remove(0, numspawned);

		return true;
	}
	else
	{
		TryToSpawnInAnotherVolume();
		return false;
	}
}
*/
State MatchInProgress
{
	function OpenShops()
	{
		local int i;
		local Controller C;

		bTradingDoorsOpen = True;

		for( i=0; i<ShopList.Length; i++ )
		{
			if( ShopList[i].bAlwaysClosed )
				continue;
			if( ShopList[i].bAlwaysEnabled )
			{
				ShopList[i].OpenShop();
			}
		}

		if ( KFGameReplicationInfo(GameReplicationInfo).CurrentShop == none )
		{
			SelectShop();
		}

		KFGameReplicationInfo(GameReplicationInfo).CurrentShop.OpenShop();

		// Tell all players to start showing the path to the trader
		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( C.Pawn!=None && C.Pawn.Health>0 )
			{
				// Disable pawn collision during trader time
				C.Pawn.bBlockActors = false;

				if( KFPlayerController(C) !=None )
				{
					KFPlayerController(C).SetShowPathToTrader(true);

					// Have Trader tell players that the Shop's Open
					if ( WaveNum < FinalWave )
					{
						KFPlayerController(C).ClientLocationalVoiceMessage(C.PlayerReplicationInfo, none, 'TRADER', 2);
					}
					else
					{
						KFPlayerController(C).ClientLocationalVoiceMessage(C.PlayerReplicationInfo, none, 'TRADER', 3);
					}

					//Hints
					KFPlayerController(C).CheckForHint(31);
					HintTime_1 = Level.TimeSeconds + 11;
				}
			}
		}
	}

	function CloseShops()
	{
		local int i;
		local Controller C;
		local Pickup Pickup;
		local SupportBoxPickup Box;
		local MedicFirstAidKit Kit;
		local TurretAmmoBox TBox;
		local TurretRepairKit TRKit;
		local ReaperBlade RB;
		local CrossbuzzsawKF2Blade CB;
		local ShurikenLLIProjectile SH;
		local RadioBombProjectile RBP;
		//local FireBombProjectile FBP;

		bTradingDoorsOpen = False;
		for( i=0; i<ShopList.Length; i++ )
		{
			if( ShopList[i].bCurrentlyOpen )
				ShopList[i].CloseShop();
		}

		SelectShop();
		
		foreach AllActors(class'Pickup', Pickup)
		{
			if ( Pickup.bDropped )
			{
				Pickup.Destroy();
			}
		}
	
		foreach AllActors(class'SupportBoxPickup', Box)
		{
			Box.Destroy();
		}
		
		foreach AllActors(class'ReaperBlade', RB)
		{
			RB.Destroy();
		}
		foreach AllActors(class'CrossbuzzsawKF2Blade', CB)
		{
			CB.Destroy();
		}
		foreach AllActors(class'ShurikenLLIProjectile', SH)
		{
			SH.Destroy();
		}
		foreach AllActors(class'MedicFirstAidKit', Kit)
		{
			Kit.bActive = false;
		}
		
		foreach AllActors(class'TurretAmmoBox', TBox)
		{
			TBox.Destroy();
		}
		
		foreach AllActors(class'TurretRepairKit', TRKit)
		{
			TRKit.Destroy();
		}
		
		foreach AllActors(class'RadioBombProjectile', RBP)
		{
			RBP.Destroy();
		}
		
		/*foreach AllActors(class'FireBombProjectile', FBP)
		{
			FBP.Destroy();
		}*/
		// Tell all players to stop showing the path to the trader
		for ( C = Level.ControllerList; C != none; C = C.NextController )
		{
			if ( C.Pawn != none && C.Pawn.Health > 0 )
			{
				// Restore pawn collision during trader time
				C.Pawn.bBlockActors = C.Pawn.default.bBlockActors;

				if ( KFPlayerController(C) != none )
				{
					KFPlayerController(C).SetShowPathToTrader(false);
					KFPlayerController(C).ClientForceCollectGarbage();

					if ( WaveNum < FinalWave - 1 )
					{
						// Have Trader tell players that the Shop's Closed
						KFPlayerController(C).ClientLocationalVoiceMessage(C.PlayerReplicationInfo, none, 'TRADER', 6);
					}
				}
			}
		}
	}

	function Timer()
	{
		local Controller C;
		local bool bOneMessage;
		local Bot B;
		local int i,j,k;
		local PlayerReplicationInfo PRI;
		local DKRegenerator Regenerator;
		local int NumRegenerators;
		
		if ( !bWaveInProgress )
		{
			foreach DynamicActors(class'DKRegenerator',Regenerator)
			{
				if ( Regenerator != none && !Regenerator.bAlmostDead )
					NumRegenerators++;
			}
		}

		Global.Timer();

		if ( Level.TimeSeconds > HintTime_1 && bTradingDoorsOpen && bShowHint_2 )
		{
			for ( C = Level.ControllerList; C != None; C = C.NextController )
			{
				if( C.Pawn != none && C.Pawn.Health > 0 )
				{
					KFPlayerController(C).CheckForHint(32);
					HintTime_2 = Level.TimeSeconds + 11;
				}
			}

			bShowHint_2 = false;
		}

		if ( Level.TimeSeconds > HintTime_2 && bTradingDoorsOpen && bShowHint_3 )
		{
			for ( C = Level.ControllerList; C != None; C = C.NextController )
			{
				if( C.Pawn != None && C.Pawn.Health > 0 )
				{
					KFPlayerController(C).CheckForHint(33);
				}
			}

			bShowHint_3 = false;
		}

		if ( !bFinalStartup )
		{
			bFinalStartup = true;
			PlayStartupMessage();
		}
		if ( NeedPlayers() && AddBot() && (RemainingBots > 0) )
			RemainingBots--;
		ElapsedTime++;
		GameReplicationInfo.ElapsedTime = ElapsedTime;
		if( !UpdateMonsterCount() )
		{
			EndGame(None,"TimeLimit");
			Return;
		}

		if( bUpdateViewTargs )
			UpdateViews();

		if (!bNoBots && !bBotsAdded)
		{
			if(KFGameReplicationInfo(GameReplicationInfo) != none)

			if((GetActualPlayersNum() + NumBots) < MaxPlayers && KFGameReplicationInfo(GameReplicationInfo).PendingBots > 0 )
			{
				AddBots(1);
				KFGameReplicationInfo(GameReplicationInfo).PendingBots --;
			}

			if (KFGameReplicationInfo(GameReplicationInfo).PendingBots == 0)
			{
				bBotsAdded = true;
				return;
			}
		}

		if( bWaveBossInProgress )
		{
			// Close Trader doors
			if( bTradingDoorsOpen )
			{
				CloseShops();
				TraderProblemLevel = 0;
			}
			if( TraderProblemLevel<4 )
			{
				if( BootShopPlayers() )
					TraderProblemLevel = 0;
				else TraderProblemLevel++;
			}
			if( !bHasSetViewYet && TotalMaxMonsters<=0 && NumMonsters>0 )
			{
				bHasSetViewYet = True;
				for ( C = Level.ControllerList; C != None; C = C.NextController )
					if ( C.Pawn!=None && KFMonster(C.Pawn)!=None && KFMonster(C.Pawn).MakeGrandEntry() )
					{
						ViewingBoss = KFMonster(C.Pawn);
						Break;
					}
				if( ViewingBoss!=None )
				{
					ViewingBoss.bAlwaysRelevant = True;
					for ( C = Level.ControllerList; C != None; C = C.NextController )
					{
						if( PlayerController(C)!=None )
						{
							PlayerController(C).SetViewTarget(ViewingBoss);
							PlayerController(C).ClientSetViewTarget(ViewingBoss);
							PlayerController(C).bBehindView = True;
							PlayerController(C).ClientSetBehindView(True);
							PlayerController(C).ClientSetMusic(BossBattleSong,MTRAN_FastFade);
						}
						if ( C.PlayerReplicationInfo!=None && bRespawnOnBoss )
						{
							C.PlayerReplicationInfo.bOutOfLives = false;
							C.PlayerReplicationInfo.NumLives = 0;
							if ( (C.Pawn == None) && !C.PlayerReplicationInfo.bOnlySpectator && PlayerController(C)!=None )
								C.GotoState('PlayerWaiting');
						}
					}
				}
			}
			else if( ViewingBoss!=None && !ViewingBoss.bShotAnim )
			{
				ViewingBoss = None;
				for ( C = Level.ControllerList; C != None; C = C.NextController )
					if( C.PlayerReplicationInfo!=None && PlayerController(C)!=None )
					{
						if( C.Pawn==None && !C.PlayerReplicationInfo.bOnlySpectator && bRespawnOnBoss )
						{
							C.ServerReStartPlayer();
							UpdateRespawnedArray(KFPCServ(C));
						}
						if( C.Pawn!=None )
						{
							PlayerController(C).SetViewTarget(C.Pawn);
							PlayerController(C).ClientSetViewTarget(C.Pawn);
						}
						else
						{
							PlayerController(C).SetViewTarget(C);
							PlayerController(C).ClientSetViewTarget(C);
						}
						PlayerController(C).bBehindView = False;
						PlayerController(C).ClientSetBehindView(False);
					}
			}
			if( TotalMaxMonsters<=0 || (Level.TimeSeconds>WaveEndTime) )
			{
				// if everyone's spawned and they're all dead
				if ( NumMonsters <= 0 )
					DoWaveEnd();
			}
			else AddBoss();
		}
		else if(bWaveInProgress)
		{
			WaveTimeElapsed += 1.0;

			// Close Trader doors
			if (bTradingDoorsOpen)
			{
				CloseShops();
				TraderProblemLevel = 0;
			}
			if( TraderProblemLevel<4 )
			{
				if( BootShopPlayers() )
					TraderProblemLevel = 0;
				else TraderProblemLevel++;
			}
			if(!MusicPlaying)
				StartGameMusic(True);

			if( TotalMaxMonsters<=0 )
			{
				if ( NumMonsters <= 5 /*|| Level.TimeSeconds>WaveEndTime*/ )
				{
					for ( C = Level.ControllerList; C != None; C = C.NextController )
						if ( KFMonsterController(C)!=None && KFMonsterController(C).CanKillMeYet() )
						{
							C.Pawn.KilledBy( C.Pawn );
							Break;
						}
				}
				// if everyone's spawned and they're all dead
				if ( NumMonsters <= 0 )
				{
					DoWaveEnd();
				}
			} // all monsters spawned
			else if ( (Level.TimeSeconds > NextMonsterTime) && (NumMonsters+NextSpawnSquad.Length <= MaxMonsters) )
			{
				WaveEndTime = Level.TimeSeconds+160;
				//AddSquad();

				if(nextSpawnSquad.length>0)
				{
					NextMonsterTime = Level.TimeSeconds + 0.2;
				}
				else
				{
					NextMonsterTime = Level.TimeSeconds + CalcNextSquadSpawnTime();
				}
			}
		}
		else if ( NumMonsters <= 0 || NumMonsters <= NumRegenerators )
		{
			if ( WaveNum == FinalWave && !bUseEndGameBoss )
			{
				if( bDebugMoney )
				{
					log("$$$$$$$$$$$$$$$$ Final TotalPossibleMatchMoney = "$TotalPossibleMatchMoney,'Debug');
				}

				EndGame(None,"TimeLimit");
				return;
			}
			else if( WaveNum == (FinalWave + 1) && bUseEndGameBoss )
			{
				if( bDebugMoney )
				{
					log("$$$$$$$$$$$$$$$$ Final TotalPossibleMatchMoney = "$TotalPossibleMatchMoney,'Debug');
				}

				EndGame(None,"TimeLimit");
				return;
			}

			WaveCountDown--;
			if ( !CalmMusicPlaying )
			{
				InitMapWaveCfg();
				StartGameMusic(False);
			}

			// Open Trader doors
			if ( WaveNum != InitialWave && !bTradingDoorsOpen )
			{
				OpenShops();
			}

			// Select a shop if one isn't open
			if (	KFGameReplicationInfo(GameReplicationInfo).CurrentShop == none )
			{
				SelectShop();
			}

			KFGameReplicationInfo(GameReplicationInfo).TimeToNextWave = WaveCountDown;
			if ( WaveCountDown == 30 )
			{
				for ( C = Level.ControllerList; C != None; C = C.NextController )
				{
					if ( C.PlayerReplicationInfo!=None && KFPlayerController(C) != None )
					{
						// Have Trader tell players that they've got 30 seconds
						KFPlayerController(C).ClientLocationalVoiceMessage(C.PlayerReplicationInfo, none, 'TRADER', 4);
					}
				}
			}
			else if ( WaveCountDown == 10 )
			{
				for ( C = Level.ControllerList; C != None; C = C.NextController )
				{
					if ( C.PlayerReplicationInfo!=None && KFPlayerController(C) != None )
					{
						// Have Trader tell players that they've got 10 seconds
						KFPlayerController(C).ClientLocationalVoiceMessage(C.PlayerReplicationInfo, none, 'TRADER', 5);
					}
				}
			}
			else if ( WaveCountDown == 5 )
			{
				KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonstersOn=false;
				InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;
			}
			else if ( (WaveCountDown > 0) && (WaveCountDown < 5) )
			{
				if( WaveNum == FinalWave && bUseEndGameBoss )
				{
					BroadcastLocalizedMessage(class'KFMod.WaitingMessage', 3);
				}
				else
				{
					BroadcastLocalizedMessage(class'KFMod.WaitingMessage', 1);
				}
			}
			else if ( WaveCountDown <= 1 )
			{
				for ( C = Level.ControllerList; C != none; C = C.NextController )
					{
						if ( C.PlayerReplicationInfo!=None && PlayerController(C) != none )
						{
							SRPlayerReplicationInfo(PlayerController(C).PlayerReplicationInfo).AmmoSupportUsed = 0;
							SRPlayerReplicationInfo(PlayerController(C).PlayerReplicationInfo).SelfAmmoSupportUsed = 0;
							SRPlayerReplicationInfo(PlayerController(C).PlayerReplicationInfo).MedKitsDropped = 0;
						}
					}
				foreach AllActors(class'PlayerReplicationInfo',PRI)
				{
					/*if ( ReservePlayerReplicationInfo(PRI) != none )
					{
						ReservePlayerReplicationInfo(PRI).ResetWaveRepValues();
						if ( !ReservePlayerReplicationInfo(PRI).bPlayerPresent )
						{
							ReservePlayerReplicationInfo(PRI).bRespawned = false;
						}
					}
					else */if ( SRPlayerReplicationInfo(PRI) != none )
						SRPlayerReplicationInfo(PRI).ResetWaveRepValues();
				}
				bWaveInProgress = true;
				KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress = true;

				// Randomize the ammo pickups again
				if( WaveNum > 0 )
				{
					SetupPickups();
				}

				if( WaveNum == FinalWave && bUseEndGameBoss )
				{
					StartWaveBoss();
				}
				else
				{
					SetupWave();

					for ( C = Level.ControllerList; C != none; C = C.NextController )
					{
						if ( PlayerController(C) != none )
						{
							PlayerController(C).LastPlaySpeech = 0;

							if ( KFPlayerController(C) != none )
							{
								KFPlayerController(C).bHasHeardTraderWelcomeMessage = false;
							}
						}

						if ( Bot(C) != none )
						{
							B = Bot(C);
							InvasionBot(B).bDamagedMessage = false;
							B.bInitLifeMessage = false;

							if ( !bOneMessage && (FRand() < 0.65) )
							{
								bOneMessage = true;

								if ( (B.Squad.SquadLeader != None) && B.Squad.CloseToLeader(C.Pawn) )
								{
									B.SendMessage(B.Squad.SquadLeader.PlayerReplicationInfo, 'OTHER', B.GetMessageIndex('INPOSITION'), 20, 'TEAM');
									B.bInitLifeMessage = false;
								}
							}
						}
					}
				}
			}
		}
	}

	// Use a sine wave to somewhat randomly increase/decrease the frequency (and
	// also the intensity) of zombie squad spawning. This will give "peaks and valleys"
	// the the intensity of the zombie attacks
	function float CalcNextSquadSpawnTime()
	{
		local float NextSpawnTime;
		local float SineMod;
		local int NumPlayersLocal;

		SineMod = 1.0 - Abs(sin(WaveTimeElapsed * SineWaveFreq));
		NumPlayersLocal = GetActualPlayersNum();

		NextSpawnTime = KFLRules.WaveSpawnPeriod;

		if( NumPlayersLocal < 5 )
		{
			NextSpawnTime *= 0.85;
		}
		else if( NumPlayersLocal == 5 )
		{
			NextSpawnTime *= 0.65;
		}
		else if( NumPlayersLocal < 9 )
		{
			NextSpawnTime *= 0.4;
		}
		else if( NumPlayersLocal < 12 )
		{
			NextSpawnTime *= 0.3;
		}
		else if( NumPlayersLocal < 15 )
		{
			NextSpawnTime *= 0.20;
		}
		else if( NumPlayersLocal < 18 )
		{
			NextSpawnTime *= 0.10;
		}
		else
		{
			NextSpawnTime *= 0.10;
		}

		// Make the zeds come a little faster at all times on harder and above
		/*if ( GameDifficulty >= 4.0 ) // Hard
		{
			NextSpawnTime *= 0.85;
		}*/

		NextSpawnTime += SineMod * (NextSpawnTime * 2);

		return NextSpawnTime;
	}

	function DoWaveEnd()
	{
		local Controller C;
		local KFDoorMover KFDM;
		local PlayerController Survivor;
		local int SurvivorCount;

		// Only reset this at the end of wave 0. That way the sine wave that scales
		// the intensity up/down will be somewhat random per wave
		if( WaveNum < 1 )
		{
			WaveTimeElapsed = 0;
		}

		if ( !rewardFlag )
			RewardSurvivingPlayers();

		if( bDebugMoney )
		{
			log("$$$$$$$$$$$$$$$$ Wave "$WaveNum$" TotalPossibleWaveMoney = "$TotalPossibleWaveMoney,'Debug');
			log("$$$$$$$$$$$$$$$$ TotalPossibleMatchMoney = "$TotalPossibleMatchMoney,'Debug');
			TotalPossibleWaveMoney=0;
		}

		// Clear Trader Message status
		bDidTraderMovingMessage = false;
		bDidMoveTowardTraderMessage = false;

		bWaveInProgress = false;
		bWaveBossInProgress = false;
		bNotifiedLastManStanding = false;
		KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress = false;

		WaveCountDown = Max(TimeBetweenWaves,1);
		KFGameReplicationInfo(GameReplicationInfo).TimeToNextWave = WaveCountDown;
		WaveNum++;

		for ( C = Level.ControllerList; C != none; C = C.NextController )
		{
			if ( C.PlayerReplicationInfo != none )
			{
				C.PlayerReplicationInfo.bOutOfLives = false;
				C.PlayerReplicationInfo.NumLives = 0;

				if ( KFPlayerController(C) != none )
				{
					if ( KFPlayerReplicationInfo(C.PlayerReplicationInfo) != none )
					{
						KFPlayerController(C).bChangedVeterancyThisWave = false;

						if ( KFPlayerReplicationInfo(C.PlayerReplicationInfo).ClientVeteranSkill != KFPlayerController(C).SelectedVeterancy )
						{
							KFPlayerController(C).SendSelectedVeterancyToServer();
						}
					}
				}

				if ( C.Pawn != none )
				{
					if ( PlayerController(C) != none )
					{
						Survivor = PlayerController(C);
						SurvivorCount++;
					}
				}
				else if ( C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator )
				{
					if ( !SRPlayerReplicationInfo(C.PlayerReplicationInfo).bRespawned )
						C.PlayerReplicationInfo.Score = Max(MinRespawnCash,int(C.PlayerReplicationInfo.Score));

					if( PlayerController(C) != none )
					{
						PlayerController(C).GotoState('PlayerWaiting');
						PlayerController(C).SetViewTarget(C);
						PlayerController(C).ClientSetBehindView(false);
						PlayerController(C).bBehindView = False;
						PlayerController(C).ClientSetViewTarget(C.Pawn);
					}

					C.ServerReStartPlayer();
					UpdateRespawnedArray(KFPCServ(C));
				}

				if ( KFPlayerController(C) != none )
				{
					if ( KFSteamStatsAndAchievements(PlayerController(C).SteamStatsAndAchievements) != none )
					{
						KFSteamStatsAndAchievements(PlayerController(C).SteamStatsAndAchievements).WaveEnded();
					}
					
					SRPlayerReplicationInfo(C.PlayerReplicationInfo).Score += SRPlayerReplicationInfo(C.PlayerReplicationInfo).WaveMoney;

					// Don't broadcast this message AFTER the final wave!
					if( WaveNum < FinalWave )
					{
						KFPlayerController(C).bSpawnedThisWave = false;
						BroadcastLocalizedMessage(class'KFMod.WaitingMessage', 2);
					}
					else if ( WaveNum == FinalWave )
					{
						KFPlayerController(C).bSpawnedThisWave = false;
					}
					else
					{
						KFPlayerController(C).bSpawnedThisWave = true;
					}
				}
			}
		}

		if ( Level.NetMode != NM_StandAlone && Level.Game.NumPlayers > 1 &&
			SurvivorCount == 1 && Survivor != none && KFSteamStatsAndAchievements(Survivor.SteamStatsAndAchievements) != none )
		{
			KFSteamStatsAndAchievements(Survivor.SteamStatsAndAchievements).AddOnlySurvivorOfWave();
		}

		bUpdateViewTargs = True;

		//respawn doors
		foreach DynamicActors(class'KFDoorMover', KFDM)
			KFDM.RespawnDoor();
	}

	// Setup the random ammo pickups
	function SetupPickups()
	{
		local int NumWeaponPickups, NumAmmoPickups, Random, i, j;
		local int m;

		// Randomize Available Ammo Pickups
		if ( GameDifficulty >= 5.0 ) // Suicidal and Hell on Earth
		{
			NumWeaponPickups = WeaponPickups.Length * 0.1;
			NumAmmoPickups = AmmoPickups.Length * 0.1;
		}
		else if ( GameDifficulty >= 4.0 ) // Hard
		{
			NumWeaponPickups = WeaponPickups.Length * 0.2;
			NumAmmoPickups = AmmoPickups.Length * 0.35;
		}
		else if ( GameDifficulty >= 2.0 ) // Normal
		{
			NumWeaponPickups = WeaponPickups.Length * 0.3;
			NumAmmoPickups = AmmoPickups.Length * 0.5;
		}
		else // Beginner
		{
			NumWeaponPickups = WeaponPickups.Length * 0.5;
			NumAmmoPickups = AmmoPickups.Length * 0.65;
		}

		// Always have at least 1 pickup
		NumWeaponPickups = Max(1, NumWeaponPickups);
		NumAmmoPickups = Max(1, NumAmmoPickups);

		// reset all the of the pickups
		for ( m = 0; m < WeaponPickups.Length ; m++ )
		{
			if(WeaponPickups[m]!=None)
				WeaponPickups[m].DisableMe();
		}

		for ( m = 0; m < AmmoPickups.Length ; m++ )
		{
			if(AmmoPickups[m]!=None)
				AmmoPickups[m].GotoState('Sleeping', 'Begin');
		}
		//Log("WeaponPickupsRoutine.0"@WeaponPickups.Length@NumWeaponPickups);
		// Randomly select which pickups to spawn
		for ( i = 0; i < NumWeaponPickups && j < 10000 && WeaponPickups.Length>0; i++ )
		{
			Random = Rand(WeaponPickups.Length);

			if ( WeaponPickups[Random]!=none && !WeaponPickups[Random].bIsEnabledNow )
			{
				WeaponPickups[Random].EnableMe();
			}
			else
			{
				i--;
			}

			j++;
		}

		for ( i = 0; i < NumAmmoPickups && j < 10000 && AmmoPickups.Length>0; i++ )
		{
			Random = Rand(AmmoPickups.Length);

			if ( AmmoPickups[Random]!=none && AmmoPickups[Random].bSleeping )
			{
				AmmoPickups[Random].GotoState('Pickup');
			}
			else
			{
				i--;
			}

			j++;
		}
	}

	function BeginState()
	{
		Super(Invasion).BeginState();

		WaveNum = InitialWave;
		InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;

		// Ten second initial countdown
		WaveCountDown = 13;// Modify this if we want to make it take long for zeds to spawn initially

		SetupPickups();
	}

	function EndState()
	{
		local Controller C;

		Super(Invasion).EndState();
		
		//Lie2men.Destroyed();
		//Lie2men.Destroy();
		CorrespondenceLog.CloseLog();
		CorrespondenceLog.Destroyed();
		CorrespondenceLog.Destroy();

		// Tell all players to stop showing the path to the trader
		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( C.Pawn!=None && C.Pawn.Health>0 )
			{
				// Restore pawn collision during trader time
				C.Pawn.bBlockActors = C.Pawn.default.bBlockActors;

				if( KFPlayerController(C) !=None )
				{
					KFPlayerController(C).SetShowPathToTrader(false);
				}
			}
		}
	}
}

	
simulated function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType)
{
	local Controller C;
	local string MapName;
	local Inventory I;
	local int j;
	local Grenade g;
	local SupportBoxPickup AS;
	local MedicFirstAidKit AK;
	local float ZedTimeBoostScale;
	local DKMonster Mon;
	local SRPlayerReplicationInfo SRPRI;
	local SRHumanPawn SRHP;
	
	if ( (DKPatriarch(Killed.Pawn) != none || HardPat(Killed.Pawn) != none || HardPatHZD(Killed.Pawn) != none) && Killer != none && PlayerController(Killer) != none )
	{
		if ( Killer.PlayerReplicationInfo != none && SRStatsBase(PlayerController(Killer).SteamStatsAndAchievements) != none )
		{
			SRStatsBase(PlayerController(Killer).SteamStatsAndAchievements).AddPatriarchKill();
		}
	}
	if ( Killer != none && Killer.PlayerReplicationInfo != none )
		SRPRI = SRPlayerReplicationInfo(Killer.PlayerReplicationInfo);
	if ( SRPRI != none && (SRPRI.ClientVeteranSkill == class'SRVetCommando' || SRPRI.ClientVeteranSkill == class'SRVetCommandoHZD') )
	{
		if ( DKPoisoner(KilledPawn) != none )
		{
			SRStatsBase(PlayerController(Killer).SteamStatsAndAchievements).AddVenomousKill();
		}
		else if ( DKShiver(KilledPawn) != none )
		{
			SRStatsBase(PlayerController(Killer).SteamStatsAndAchievements).AddShiverKill();
		}
	}
	Mon = DKMonster(KilledPawn);
	if ( Mon != none && KFMonsterController(Killed) != none && Killer != none && PlayerController(Killer) != none )
	{
		ZedTimeBoostScale = 1.0;
		
		if ( Mon.default.headhealthmax < 100 )
		{
			ZedTimeBoostScale = 1.0;
		}
		if ( Mon.Isa('DKReaver') || Mon.Isa('DKShiver') || Mon.Isa('DKReaverP') )
		{
			ZedTimeBoostScale = 14.0;
		}
		else if ( Mon.Isa('DKHusk') || Mon.Isa('ZombieHusk_XMasSR') || Mon.Isa('DKSiren') || Mon.Isa('ZombieSiren_XMasSR') )
		{
			ZedTimeBoostScale = 8.0;
		}
		else if ( Mon.Isa('DKScrake') || Mon.Isa('ZombieScrake_XMasSR') || Mon.Isa('DKScrakeHZD') )
		{
			ZedTimeBoostScale = 30.0;
		}
		else if ( Mon.Isa('DKScrakeKF2DT') || Mon.Isa('DKScrakeKF2DTHZD') )
		{
			ZedTimeBoostScale = 30.0;
		}
		/*else if ( Mon.Isa('FemaleFP') )
		{
			ZedTimeBoostScale = 30.0;
		}*/
		else if ( Mon.Isa('DKFleshPoundNew') 
			|| Mon.Isa('DKFleshPoundNewHZD') 
			|| Mon.Isa('DKFleshPoundNewP') 
			|| Mon.Isa('DKFleshPoundNewPHZD')
			|| Mon.Isa('DKFleshpoundKF2DT')
			|| Mon.Isa('DKFleshpoundKF2DTHZD'))
		{
			ZedTimeBoostScale = 75.0;
		}
		else if ( Mon.Isa('ZombieFleshPound_XMasSRP') )
		{
			ZedTimeBoostScale = 75.0;
		}
		else if ( Mon.Isa('ZombieFleshPound_XMasSR') )
		{
			ZedTimeBoostScale = 75.0;
		}
		else if ( Mon.Isa('DKBrute') || Mon.Isa('DKTroll') || Mon.Isa('TankerBruteDT') )
		{
			ZedTimeBoostScale = 150.0;
		}
		/*else if ( Mon.Isa('ZombieBrute') )
		{
			ZedTimeBoostScale = 150.0;
		}*/
		
		if ( DamageType == class'DamTypeMelee' )
			ZedTimeBoostScale *= 1.3;	
		
		if ( Killer != none && Killer.Pawn != none )
			SRHP = SRHumanPawn(Killer.Pawn);
		if ( SRHP != none )
		{
			SRHP.KillingSpree+=1.0;
			SRHP.KillingSpreeNullCount = Level.TimeSeconds + 0.5;
			if ( KFPCServ(Killer) != none )
				KFPCServ(Killer).AddZedTimeCharge(0.005 * ZedTimeBoostScale + 0.005 * ( 0.5 + 0.5 * FMax(1.0,SRHP.KillingSpree-1.0) ) );
		}
	}

	/*if ( SRHumanPawn(KilledPawn) != none )
		PlayerDeathSlomo(SRHumanPawn(KilledPawn));*/
	
	if( KFPCServ(Killed) != none )
	{
		I = KilledPawn.Inventory;
		
		if ( SRPRI != none && Killer != Killed )
		{
			SRPRI.TeamKills++;
		}
		if ( Killed.PlayerReplicationInfo != none )
			SRPRI = SRPlayerReplicationInfo(Killed.PlayerReplicationInfo);
		if ( SRPRI != none )
		SRPRI.Dies++;
		if ( SRPRI != none )
		{
			if ( !KFGameType(Level.Game).bTradingDoorsOpen )
			{
				SRPRI.bRespawned = false;
			}
		}
		if( SRPRI != none )
		{
			For( I = KilledPawn.Inventory; I != None; I =I.Inventory )
			{
				if( Frag(I) != none )
				{
					if ( SRPRI.ClientVeteranSkill.Static.GetNadeType(SRPRI) == class'SupportAmmoNade' )
					{
						for(j = Frag(I).AmmoAmount(0); j>0; j--)
						{
							AS = Spawn(class'SupportBoxPickup',KilledPawn,,KilledPawn.Location + VRand() * 85);
							AS.Instigator = KilledPawn;
							AS.GotoState('Pickup');
						}
					}
					else if ( SRPRI.ClientVeteranSkill.Static.GetNadeType(SRPRI) == class'SupportHealNade' )
					{
						for(j = Frag(I).AmmoAmount(0); j>0; j--)
						{
							AK = Spawn(class'MedicFirstAidKit',KilledPawn,,KilledPawn.Location + VRand() * 85);
							AK.Instigator = KilledPawn;
						}
					}
					/*else
					{
						for(j = Frag(I).AmmoAmount(0); j>0; j--)
						{
							g = Spawn(SRPRI.ClientVeteranSkill.Static.GetNadeType(SRPRI),KilledPawn,,KilledPawn.Location);
							g.Instigator = KilledPawn;
							if (g != None)
							{
								g.Speed = 0.0;
								g.MaxSpeed = 0.0;
								g.ExplodeTimer = 0.65;
								g.Velocity = VRand() * 150;
							}
						}
					}*/
				}
			}
		
		}
	}
	
	Super.Killed(Killer,Killed,KilledPawn,DamageType);
}

function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local float InstigatorSkill;
	local KFPlayerController PC;
	local float DamageBeforeSkillAdjust;
	local float AwardedDamage;
	local xPawn P;
	local Vector HN;
	local string weapon;
	local SRPlayerReplicationInfo SRPRI;
	
	if (injured.PlayerReplicationInfo != none)
	{
		SRPRI = SRPlayerReplicationInfo(injured.PlayerReplicationInfo);
		weapon = (SRPlayerReplicationInfo(injured.PlayerReplicationInfo)).Weapon;
	}
	
	if( instigatedBy != none && KFHumanPawn(InstigatedBy) !=none && SRPRI != none && SRPRI.HasSkinGroup("DemkaPPP") && Injured != InstigatedBy && Injured != none )
		return 0;

	/*if ( instigatedBy != none 
		&& KFHumanPawn(InstigatedBy) !=none 
		&& SRPRI != none 
		&& SRPRI.HasSkinGroup("Zic3") 
		&& Injured != InstigatedBy 
		&& Injured != none
		&& (DamageType == class'DamTypeZic3LLI' 
		|| DamageType == class'DamTypeZic3LLIAP' 
		|| DamageType == class'DamTypeZic3LLIBS' ) 
	   )
		Damage = 0;*/

	if ( (KFHumanPawn(Injured) !=none || KFHumanPawn(InstigatedBy) != none) &&
		SRPRI.HasSkinGroup("Mortal") && 
		class<DamTypeGunfighter>(DamageType) != none )
		Damage = 0;
		
	if ((KFHumanPawn(Injured) !=none || KFHumanPawn(InstigatedBy) != none) &&
		(DamageType == class'DamTypeZic3LLI'
		|| DamageType == class'DamTypeZic3LLIAP'
		|| DamageType == class'DamTypeZic3LLIBS'))
		Damage = 0;
	
	if( instigatedBy != none && instigatedBy.PlayerReplicationInfo != none && KFHumanPawn(Injured) !=none &&
		SRPlayerReplicationInfo(instigatedBy.PlayerReplicationInfo).HasSkinGroup("DemkaPPP") &&
		Injured != InstigatedBy &&
		DamageType == class'DamTypeSeekerSixMRocket' )
		Damage = 0;

	if (  InstigatedBy != none && !bWaveInProgress && KFHumanPawn(Injured) != none && KFHumanPawn(InstigatedBy) != none
		&& Injured != InstigatedBy )
		Damage = 0;
	
	if(  InstigatedBy != none && KFHumanPawn(injured) != none 
	&& injured != instigatedBy 
	&& DamageType == class'DamTypePipeBomb'
	&& DamageType != class'DamTypePipeBomb'
	/*&& class<DamTypePipeBomb>(DamageType) != none 
	&& class<DamTypePipeBombA>(DamageType) == none*/ )
		return 10;
	
	if(  InstigatedBy != none && KFHumanPawn(injured) != none && injured != instigatedBy && class<DamTypePipeBombS>(DamageType) != none )
		return 0;
		
	if ( Monster(Injured) != None )
	{
		if (  instigatedBy != None && InstigatedBy.PlayerReplicationInfo != none)
		{
			DebugMessage(InstigatedBy.Controller.PlayerReplicationInfo.PlayerName $ " attacks " $ KFMonster(Injured).MenuName $ ", damage = " $ string(Damage) $
			", Offset: X = " $ string(Injured.Location.X-HitLocation.X) $ ", Y = " $ string(Injured.Location.Y-HitLocation.Y) $ ", Z = " $
			string(Injured.Location.Z-HitLocation.Z));
			/*
			if( class<DamTypeM79Grenade>(DamageType) != none  || class<DamTypeM32Grenade>(DamageType) != none ||
				class<DamTypeM203Nade>(DamageType) != none || class<DamTypeRPG>(DamageType) != none ||
				class<DamTypeFlameLauncher>(DamageType) != none || class<DamTypeFlameNade>(DamageType) != none )
			{
				if ( WaveNum < 3 )
				{
					Damage *= DemoFireDamageModifier;
				}
			}*/
			foreach injured.VisibleCollidingActors(class'xPawn', P, 85.00)
			{
				if(SRHumanPawn(P) == none)
				{
					continue;
				}
				else
				{
					if(instigatedBy != none && (DamageType.default.bInstantHit))
					{
						HN = Normal(HitLocation - instigatedBy.Location);
					}
					else
					{
						HN = Normal(Momentum);
						if(HN.Z < 0.60 * VSize(HN * vect(1.00, 1.00, 0.00)))
						{
							HN.Z *= 0.50;
						}
					}
					SRHumanPawn(P).DrawBlood(DamageType, HitLocation, HN, Damage, instigatedBy, KFPCServ(P.Controller));
					continue;
				}			
			}
		}
		if ( InstigatedBy != none && SRHumanPawn(InstigatedBy) != none )
		{
			if ( PlayerController(InstigatedBy.Controller) != none )
			{
				if ( SRPlayerReplicationInfo(InstigatedBy.Controller.PlayerReplicationInfo) != none )
				{
					AwardedDamage = Clamp(Damage, 1, Injured.Health);
					SRPlayerReplicationInfo(InstigatedBy.Controller.PlayerReplicationInfo).DamageDealed += AwardedDamage;
				}
			}
		}
	}
	if (InstigatedBy != none)	
	{
		if ( DamageType == class'DamTypeFlameTendril' && MonsterController(InstigatedBy.Controller) == None )
		{
			Damage *= 0.5;
		}
		
		if ( ( DamageType == class'DamTypeHuskGunStrongShot' || DamageType == class'DamTypeHuskGun' ) && MonsterController(InstigatedBy.Controller) == None )
		{
			Damage *= 0.35;
		}
	}
	if ( !bWaveInProgress && DamageType == class'Fell' && injured.health <= Damage )
	{	
		Damage = Injured.Health - 1;
	}

	if ( KFPawn(Injured) != none )
	{
		if ( KFPlayerReplicationInfo(Injured.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Injured.PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			Damage = KFPlayerReplicationInfo(Injured.PlayerReplicationInfo).ClientVeteranSkill.Static.ReduceDamage(KFPlayerReplicationInfo(Injured.PlayerReplicationInfo), KFPawn(Injured), KFMonster(instigatedBy), Damage, DamageType);
		}
	}

	// This stuff cuts thru all the B.S
	if ( DamageType == class'DamTypeVomit' || DamageType == class'DamTypeWelder' || DamageType == class'SirenScreamDamage' )
	{
		return damage;
	}

	if ( instigatedBy == None )
	{
		return Super(xTeamGame).ReduceDamage( Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
	}

	if ( Monster(Injured) != None )
	{
		if ( instigatedBy != None )
		{
			PC = KFPlayerController(instigatedBy.Controller);
			if ( Class<KFWeaponDamageType>(damageType) != none && PC != none )
			{
				AwardedDamage = Clamp(Damage, 1, Injured.Health);
//				AwardedDamage *= 0.85;
				/*if ( PC.GetPlayerIDHash() == "76561202094964582" || PC.GetPlayerIDHash() == "76561198040142490" )
					AwardedDamage *= 3.0;*/
				AwardedDamage = class'DKUtil'.Static.SmoothFloatToInt(AwardedDamage*GetAwardDamageMod(InstigatedBy,Injured,DamageType));
				if ( class<KFWeaponDamageType>(DamageType) != none && class<KFWeaponDamageType>(DamageType).default.bSniperWeapon )
				{
					SRStatsBaseUpper(PC.SteamStatsAndAchievements).AddSharpshooterDamage(AwardedDamage);
				}
				class<KFWeaponDamageType>(damageType).static.AwardDamage(KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements), AwardedDamage);
			}
		}

		return Damage;
	}

	if ( InstigatedBy != none && MonsterController(InstigatedBy.Controller) != None )
	{
		InstigatorSkill = MonsterController(instigatedBy.Controller).Skill;
		if ( GetActualPlayersNum() > 4 )
			InstigatorSkill += 1.0;
		if ( (InstigatorSkill < 7) && (Monster(Injured) == None) )
		{
			if ( InstigatorSkill <= 3 )
				Damage = Damage;
			else Damage = Damage;
		}
	}
	else if ( InstigatedBy != none && KFFriendlyAI(InstigatedBy.Controller) != None && KFHumanPawn(Injured) != none  )
		Damage *= 0.25;
	else if ( InstigatedBy != none && injured == instigatedBy )
	{
		if ( DamageType == class'DamTypeOverdose' )
		{
			Damage = Damage;
		}
		else
		{
			Damage = Damage * 0.5;
		}
	}


	if ( InvasionBot(injured.Controller) != None )
	{
		if ( !InvasionBot(injured.controller).bDamagedMessage && (injured.Health - Damage < 50) )
		{
			InvasionBot(injured.controller).bDamagedMessage = true;
			if ( FRand() < 0.5 )
				injured.Controller.SendMessage(None, 'OTHER', 4, 12, 'TEAM');
			else injured.Controller.SendMessage(None, 'OTHER', 13, 12, 'TEAM');
		}
		if ( GameDifficulty <= 3 )
		{
			if ( injured.IsPlayerPawn() && (InstigatedBy != none && injured == instigatedby) && (Level.NetMode == NM_Standalone) )
				Damage *= 0.5;

			//skill level modification
			if ( InstigatedBy != none && MonsterController(InstigatedBy.Controller) != None )
				Damage = Damage;
		}
	}

	if( injured.InGodMode() )
		return 0;
	if( InstigatedBy != none && instigatedBy!=injured && MonsterController(InstigatedBy.Controller)==None && (instigatedBy.Controller==None || instigatedBy.GetTeamNum()==injured.GetTeamNum()) )
	{
		if ( class<WeaponDamageType>(DamageType) != None || class<VehicleDamageType>(DamageType) != None )
			Momentum *= TeammateBoost;
		if ( Bot(injured.Controller) != None )
			Bot(Injured.Controller).YellAt(instigatedBy);

		if ( FriendlyFireScale==0.0 || (Vehicle(injured) != None && Vehicle(injured).bNoFriendlyFire) )
		{
			if ( GameRulesModifiers != None )
				return GameRulesModifiers.NetDamage( Damage, 0,injured,instigatedBy,HitLocation,Momentum,DamageType );
			else return 0;
		}
		Damage *= FriendlyFireScale;
	}

	// Start code from DeathMatch.uc - Had to override this here because it was reducing
	// bite damage (which is 1) down to zero when the skill settings were low

	if ( (instigatedBy != None) && (InstigatedBy != Injured) && (Level.TimeSeconds - injured.SpawnTime < SpawnProtectionTime)
		&& (class<WeaponDamageType>(DamageType) != None || class<VehicleDamageType>(DamageType) != None) )
		return 0;

	Damage = super(UnrealMPGameInfo).ReduceDamage( Damage, injured, InstigatedBy, HitLocation, Momentum, DamageType );

	if ( instigatedBy == None)
		return Damage;

	DamageBeforeSkillAdjust = Damage;

	if ( Level.Game.GameDifficulty <= 3 )
	{
		if ( injured.IsPlayerPawn() && (InstigatedBy != none && injured == instigatedby) && (Level.NetMode == NM_Standalone) )
			Damage *= 0.5;
	}
	SeekDamageAbsorbers(Damage,injured,instigatedBy,HitLocation,Momentum,DamageType);
	return (Damage * instigatedBy.DamageScaling);
	// End code from DeathMatch.uc
}

function SeekDamageAbsorbers(out int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local TechNadeAvoidMarker BestShield;
	local array<TechNadeAvoidMarker> Shields;
	local int i,n,j,m,index;
	
	if ( SRHumanPawn(Injured) != none 
	|| TurretDK(Injured) != none 
	|| Doom3Bot(Injured) != none 
	|| WerewolfLLI(Injured) != none 
	|| AlduinDT(Injured) != none 
	|| MedSentry(Injured) != none )
	{
		foreach CollidingActors(class'TechNadeAvoidMarker',BestShield,class'TechNade'.default.DamageRadius+Injured.CollisionRadius,Injured.Location)
		{
			if ( BestShield.Source != none && BestShield.Source.Health > 0 )
				Shields[Shields.Length] = BestShield;
		}
		n = Shields.Length;
		if ( n <= 0 ) return;
		for(i=0; i<n; i++)
		{
			index = i;
			BestShield = Shields[i];
			for(j=i+1; j<m; j++)
			{
				if ( BestShield.Source.ShieldOffTime > Shields[j].Source.ShieldOffTime )
				{
					BestShield = Shields[j];
					index = j;
				}
			}
			if ( index != i )
			{
				Shields[index] = Shields[i];
				Shields[i] = BestShield;
			}
		}
		while ( Damage > 0 && Shields.Length > 0 )
		{
			Shields[0].AbsorbDamage(Injured,Damage,InstigatedBy,HitLocation,Momentum,DamageType);
			Shields.Remove(0,1);
		}
	}
}

function float GetAwardDamageMod(Pawn InstigatedBy, Pawn Injured, class<DamageType> DamageType)
{
	local float Mod;
	local class<SRVeterancyTypes> SRVet;
	local class<KFWeaponDamageType> KFWDT;
	local DKMonster DKM;
	
	Mod = 1.00;
	SRVet = class'DKUtil'.Static.GetVeteran(InstigatedBy);
	DKM = DKMonster(Injured);
	KFWDT = class<KFWeaponDamageType>(DamageType);
	if ( SRVet == none || DKM == none || KFWDT == none ) return 1.00;
	
	if ( (SRVet == class'SRVetSharpshooter' || SRVet == class'SRVetSharpshooterHZD') && KFWDT.default.bSniperWeapon && KFWDT.default.bCheckForHeadshots )
	{
		if ( DKScrake(DKM) != none || DKScrakeHZD(DKM) != none || DKScrakeKF2DT(DKM) != none || DKScrakeKF2DTHZD(DKM) != none )
			Mod *= 0.40;
		if ( DKFleshpoundKF2DT(DKM) != none || DKFleshPoundNew(DKM) != none )
			Mod *= 0.60;
		if ( class<DamTypeM200SA>(DamageType) != none 
		|| class<DamTypeM200SAAlt>(DamageType) != none 
		|| class<DamTypeMcMillanSA>(DamageType) != none 
		|| class<DamTypeVSSDTBAlt>(DamageType) != none 
		|| class<DamTypeVSSKSAAlt>(DamageType) != none 
		|| class<DamTypeVSSKSA>(DamageType) != none 
		|| class<DamTypeSIG550SRAlt>(DamageType) != none
		|| class<DamTypeSIG550SR>(DamageType) != none
		|| class<DamTypeMusketAlt>(DamageType) != none
		|| class<DamTypeMusket>(DamageType) != none )
			Mod = 1.35;
		if ( class<DamTypeGaussSA>(DamageType) != none 
		|| class<DamTypeGaussSAAlt>(DamageType) != none 
		|| class<DamTypeM82A1LLINV>(DamageType) != none 
		|| class<DamTypeM99ST>(DamageType) != none 
		|| class<DamTypeAwmDragonLLI>(DamageType) != none 
		|| class<DamTypeBarret_M98_Bravo>(DamageType) != none 
		|| class<DamTypeHK417A>(DamageType) != none 
		|| class<DamTypeJNG90SA>(DamageType) != none 
		|| class<DamTypeM82A1LLI>(DamageType) != none 
		|| class<DamTypeM82A1LLIAlt>(DamageType) != none  )
			Mod = 1.5;
		if ( DKHusk(DKM) != none )
			Mod = 1.20;
		else if ( DKDemolisher(DKM) != none )
			Mod *= 1.40;
		else if ( DKArchville(DKM) != none )
			Mod *= 1.50;
	}
	if ( (SRVet == class'SRVetSaboteur' || SRVet == class'SRVetSaboteurHZD') && KFWDT != none && class<DamTypeTacticalMine>(DamageType) != none )
	{
			Mod = 6000.00;
	}
	if ( (SRVet == class'SRVetBerserker' || SRVet == class'SRVetBerserkerHZD') && KFWDT != none &&  KFWDT.default.bIsMeleeDamage )
	{
		if ( DKScrake(DKM) != none || DKScrakeHZD(DKM) != none || DKScrakeKF2DT(DKM) != none || DKScrakeKF2DTHZD(DKM) != none )
			Mod = 2.00;
	}
	/*if ( DKScrakeKF2DT(DKM) != none )
		Mod = 1.00;*/
	/*if ( ZombieRaptorPounder(DKM) != none )
		Mod = 1.50;
	if ( ZombieCreepyCrawlerDT(DKM) != none )
		Mod = 1.50;
	if ( ZombieMarchHareDT(DKM) != none )
		Mod = 1.50;
	if ( ZombieBrute(DKM) != none )
		Mod = 2.00;
	if ( DKTroll(DKM) != none )
		Mod = 10.00;*/
	/*if ( ZombieScrake_XMasSR(DKM) != none )
		Mod = 2.50;
	if ( ZombieHusk_XMasSR(DKM) != none )
		Mod = 3.0;
	if ( ZombieFleshPound_XMasSR(DKM) != none )
		Mod = 3.0;
	if ( ZombieFleshPound_XMasSRP(DKM) != none )
		Mod = 4.0;
	if ( ZombieStalker_XMasSR(DKM) != none )
		Mod = 2.0;
	if ( ZombieClot_XMasSR(DKM) != none )
		Mod = 2.0;
	if ( ZombieGoreFast_XMasSR(DKM) != none )
		Mod = 2.0;
	if ( ZombieCrawler_XMasSR(DKM) != none )
		Mod = 2.0;
	if ( ZombieBloat_XMasSR(DKM) != none )
		Mod = 2.0;
	if ( ZombieSiren_XMasSR(DKM) != none )
		Mod = 3.0;*/
	return Mod;
}

function int ReduceArmorDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local int AwardedDamage;
	local KFPlayerController PC;

	if ( DKMonster(Injured) != None )
	{
		if ( InstigatedBy != None )
		{
			PC = KFPlayerController(instigatedBy.Controller);
			if ( Class<KFWeaponDamageType>(damageType) != none && PC != none )
			{
				AwardedDamage = Clamp(Damage, 1, DKMonster(Injured).Armor);
				AwardedDamage *= /*ExpGainMod **/ 0.40;
				/*if ( PC.GetPlayerIDHash() == "76561202094964582" || PC.GetPlayerIDHash() == "76561198040142490" )
					AwardedDamage *= 3.0;*/
				Class<KFWeaponDamageType>(damageType).Static.AwardDamage(KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements), AwardedDamage);
			}
		}
	}

	return Damage;
}

function bool AllowBecomeActivePlayer(PlayerController P)
{
	if( P.PlayerReplicationInfo==None || !P.PlayerReplicationInfo.bOnlySpectator )
		Return False; // Already are active player.
	if ( !GameReplicationInfo.bMatchHasBegun || (NumPlayers >= MaxPlayers) || P.IsInState('GameEnded') || P.IsInState('RoundEnded') )
	{
		P.ReceiveLocalizedMessage(GameMessageClass, 13);
		return false;
	}
	if ( (Level.NetMode==NM_Standalone) && (NumBots>InitialBots) )
	{
		RemainingBots--;
		bPlayerBecameActive = true;
	}
//	if( !SRPlayerReplicationInfo(P.PlayerReplicationInfo).bRespawned )
//		P.PlayerReplicationInfo.Score = StartingCash;
//	else
//		P.PlayerReplicationInfo.Score = 0;
	return true;
}

simulated event Tick(float DeltaTime)
{
	//local MedicFirstAidKit Kit;
	local SRHumanPawn SRHP;

	if( FireBombsBlownUp > 0 )
	{
		if( FireBombAllowToBlowTime < Level.TimeSeconds )
			FireBombsBlownUp = 0;
	}
	
	if( RadioBombsBlownUp > 0 )
	{
		if( RadioBombAllowToBlowTime < Level.TimeSeconds )
			RadioBombsBlownUp = 0;
	}
	
	if ( CurrentWave != WaveNum )
	{
		CurrentWave = WaveNum;
		
		CorrespondenceLog.CloseLog();
		CorrespondenceLog.OpenLog("Correspondence");
	}
	
	Super.Tick(DeltaTime);
}

function class<KFMonster> GetReplacement( class<KFMonster> M )
{
	return M;
}

function class<KFMonster> GetSpecialSquadReplacement( class<KFMonster> M )
{
	return M;
}

function LoadUpMonsterList();
function array<IMClassList> LoadUpMonsterListFromGameType();
function array<IMClassList> LoadUpMonsterListFromCollection();
function NotifyGameEvent(int EventNumIn);
simulated function PrepareSpecialSquadsFromGameType();
simulated function PrepareSpecialSquadsFromCollection();
simulated function PrepareSpecialSquads();

function bool AddBoss()
{
	local int ZombiesAtOnceLeft;
	local int numspawned;

	FinalSquadNum = 0;

	NextSpawnSquad.Length = 1;
	
	NextSpawnSquad[0] = Class<KFMonster>(DynamicLoadObject(BossClassDK,Class'Class'));

	if( LastZVol==none )
	{
		LastZVol = FindSpawningVolume(false, true);
		if(LastZVol!=None)
			LastSpawningVolume = LastZVol;
	}

	if(LastZVol == None)
	{
		LastZVol = FindSpawningVolume(true, true);
		if( LastZVol!=None )
			LastSpawningVolume = LastZVol;

		if( LastZVol == none )
		{
			TryToSpawnInAnotherVolume(true);
			return false;
		}
	}

	ZombiesAtOnceLeft = MaxMonsters - NumMonsters;

	if(LastZVol.SpawnInHere(NextSpawnSquad,,numspawned,TotalMaxMonsters,32/*ZombiesAtOnceLeft*/,,true))
	{
		NumMonsters+=numspawned;
		WaveMonsters+=numspawned;

		return true;
	}
	else
	{
		TryToSpawnInAnotherVolume(true);
		return false;
	}

}

/*function AddSpecialPatriarchSquad()
{
	local Class<KFMonster> MC;
	local array< class<KFMonster> > TempSquads;
	local int i,j;

	//Log("Loading up FinalSquads monster classes...");
	for( i=0; i<FinalSquads[FinalSquadNum].ZedClass.Length; i++ )
	{
		if( FinalSquads[FinalSquadNum].ZedClass[i]=="" )
		{
			//log("Missing a FinalSquads squad!!!");
			Continue;
		}
		MC = Class<KFMonster>(DynamicLoadObject(FinalSquads[FinalSquadNum].ZedClass[i],Class'Class'));
		if( MC==None )
		{
			//log("Couldn't DLO a FinalSquads squad!!!");
			Continue;
		}

		for( j=0; j<FinalSquads[FinalSquadNum].NumZeds[i]; j++ )
		{
			//log("FinalSquads!!! FinalSquadNum "$FinalSquadNum$" Monster "$j$" = "$MC);

			TempSquads[TempSquads.Length] = MC;
		}
		//log("****** FinalSquads");
	}

	NextSpawnSquad = TempSquads;
}*/

function AddSpecialPatriarchSquad()
{
	local Class<KFMonster> MC;
	local array< class<KFMonster> > TempSquads;
	local int i,j;

	//Log("Loading up FinalSquads monster classes...");
	for( i=0; i<FinalSquads[FinalSquadNum].ZedClass.Length; i++ )
	{
		if( FinalSquads[FinalSquadNum].ZedClass[i]=="" )
		{
			//log("Missing a FinalSquads squad!!!");
			continue;
		}
		MC = Class<KFMonster>(DynamicLoadObject(FinalSquads[FinalSquadNum].ZedClass[i],Class'Class'));
		if( MC==None )
		{
			//log("Couldn't DLO a FinalSquads squad!!!");
			continue;
		}

		for( j=0; j<FinalSquads[FinalSquadNum].NumZeds[i]; j++ )
		{
			//log("FinalSquads!!! FinalSquadNum "$FinalSquadNum$" Monster "$j$" = "$MC);

			TempSquads[TempSquads.Length] = MC;
		}
		//log("****** FinalSquads");
	}

	NextSpawnSquad = TempSquads;
}

simulated function CalculateDifficultyByAverageLevel()
{
////////
}

function float GetAveragePerkLevel()
{
	local Controller C;
	local float ret;
	local int PNum;
	local SRPlayerReplicationInfo SRPRI;
	
	ret = 0.0;
	PNum = 0;

	foreach AllActors(class 'SRPlayerReplicationInfo', SRPRI) 
	{
		if( SRPRI.PlayerHealth > 0 && !SRPRI.bBot && !SRPRI.bOnlySpectator )
		{
			ret += float(SRPRI.ClientVeteranSkillLevel);
			PNum++;
		}
	}
	return ret / float(PNum);
}

function UpdateRespawnedArray(KFPCserv SRPC)
{
	local int i;

	for(i=0; i<RespawnedPlayer.Length; i++)
	{
		if ( SRPC.GetPlayerIDHash() == RespawnedPlayer[i] )
			break;
	}
	if ( i > RespawnedPlayer.Length )
		RespawnedPlayer[i] = SRPC.GetPlayerIDHash();
		
}

function bool AllowRespawnPlayer(KFPCServ SRPC)
{
	local int i;
	for(i=0; i<RespawnedPlayer.Length; i++)
		if ( SRPC.GetPlayerIDHash() == RespawnedPlayer[i] )
			return false;
	return true;
}

function InitSquadNotes()
{
////////
}

function FillLevelSquads()
{
	local int i,j,k,c,g,n;
	local class<KFMonster> CurrentMonsterClass;
	
	InitSquadNotes();

	for(i=0; i<LevelSquadNote.Length; i++)
	{
		LevelSquads.Insert(i,1);
		for(j=0; j<LevelSquadNote[i].Squads.Length; j++)
		{
			g = 0;
			LevelSquads[i].Squads.Insert(j,1);
			for(c=0; c<LevelSquadNote[i].Squads[j].MonClass.Length; c++)
			{
				CurrentMonsterClass = LevelSquadNote[i].Squads[j].MonClass[c];
				for(n=0; n<LevelSquadNote[i].Squads[j].MonNum[c]; n++)
				{
					LevelSquads[i].Squads[j].Filling.Insert(g,1);
					LevelSquads[i].Squads[j].Filling[g] = CurrentMonsterClass;
					DebugMessage("LevelSquads["$string(i)$"].Squads["$string(j)$"].Filling["$string(g)$"] = "$CurrentMonsterClass.default.MenuName);
					g++;
				}
			}
		}
	}
}
function SetCurrentSquads()
{
	local int i,j,k;

	SquadsTemplate = LevelSquads[WaveNum];
	CurrentSquads = SquadsTemplate;
	DebugMessage("LevelSquadNote.Length = "$string(LevelSquadNote.Length));
	DebugMessage("LevelSquads.Length = "$string(LevelSquads.Length));
	for(i=0; i<LevelSquads.Length; i++)
		for(j=0; j<LevelSquads[i].Squads.Length; j++)
			for(k=0; k<LevelSquads[i].Squads[j].Filling.Length; k++)
	{
		if	(
				i<LevelSquads.Length
				&&	j<LevelSquads[i].Squads.Length
				&&	k<LevelSquads[i].Squads[j].Filling.Length
				&&	LevelSquads[i].Squads[j].Filling[k]!=none
			)
		{
			DebugMessage("LevelSquads["$string(i)$"].Squads["$string(j)$"].Filling["$string(k)$"] = "$LevelSquads[i].Squads[j].Filling[k].default.MenuName);
		}
	}
}
/*
function BuildNextSquadOld()
{
	local int i, j, RandNum;
	//local int m;

	// Reinitialize the SquadsToUse after all the squads have been used up
	if( SquadsToUse.Length == 0 )
	{
		j = 1;

		for ( i=0; i<InitSquads.Length; i++ )
		{
			if ( (j & Waves[WaveNum].WaveMask) != 0 )
			{
				SquadsToUse.Insert(0,1);
				SquadsToUse[0] = i;

				// Ramm ZombieSpawn debugging
			}

			j *= 2;
		}

		if( SquadsToUse.Length==0 )
		{
			Warn("No squads to initilize with.");
			Return;
		}

		// Save this for use elsewhere
		InitialSquadsToUseSize = SquadsToUse.Length;
		SpecialListCounter++;
		bUsedSpecialSquad=false;
	}

	RandNum = Rand(SquadsToUse.Length);
	NextSpawnSquad = InitSquads[SquadsToUse[RandNum]].MSquad;

	// Take this squad out of the list so we don't get repeats
	SquadsToUse.Remove(RandNum,1);
	
	NumLastSpawned = NextSpawnSquad.Length;
}
*/
/*
function BuildNextSquad()
{
	local int i, RandNum;
	local array< class<KFMonster> > TempSquads;

	// Reinitialize the SquadsToUse after all the squads have been used up
	if( CurrentSquads.Squads.Length == 0 )
	{

		for ( i=0; i<SquadsTemplate.Squads.Length; i++ )
		{
			CurrentSquads.Squads.Insert(0,1);
			CurrentSquads.Squads[0] = SquadsTemplate.Squads[i];
		}

		if( CurrentSquads.Squads.Length==0 )
		{
			Warn("No squads to initilize with.");
			Return;
		}

		// Save this for use elsewhere
		InitialSquadsToUseSize = CurrentSquads.Squads.Length;
		SpecialListCounter++;
		bUsedSpecialSquad=false;
	}

	RandNum = Rand(CurrentSquads.Squads.Length);
	for(i=0; i<CurrentSquads.Squads[RandNum].Filling.Length; i++)
	TempSquads[i] = CurrentSquads.Squads[RandNum].Filling[i];
	
	NextSpawnSquad = TempSquads;

	// Take this squad out of the list so we don't get repeats
	CurrentSquads.Squads.Remove(RandNum,1);
	
	NumLastSpawned = NextSpawnSquad.Length;
}
*/
/*
function AddSpecialSquad()
{
	local Class<KFMonster> MC;
	local array< class<KFMonster> > TempSquads;
	local int i,j,WayOfSpawning;
	
	SpecSquadSpawnCounter = 0;
	SpecSquadAltSpawnCounter = 0;
	
	WayOfSpawning = int(FRand() * 2.0);
	
	if ( WayOfSpawning == 2 )
		WayOfSpawning = 1;
	

	//Log("Loading up Special monster classes...");
	for( i=0; i<SpecialSquads[WaveNum].ZedClass.Length; i++ )
	{
		if( SpecialSquads[WaveNum].ZedClass[i]=="" )
		{
			//log("Missing a special squad!!!");
			Continue;
		}
		MC = Class<KFMonster>(DynamicLoadObject(SpecialSquads[WaveNum].ZedClass[i],Class'Class'));
		MC = GetSpecialSquadReplacement(MC);
		if( MC==None )
		{
			//log("Couldn't DLO a special squad!!!");
			Continue;
		}

		for( j=0; j<SpecialSquads[WaveNum].NumZeds[i]; j++ )
		{
			//log("SpecialSquad!!! Wave "$WaveNum$" Monster "$j$" = "$MC);

			TempSquads[TempSquads.Length] = MC;
			
		}
		//log("****** SpecialSquad");
	}
	
	bUsedSpecialSquad = true;

	NextSpawnSquad = TempSquads;
	
	NumLastSpawned = TempSquads.Length;
	
	if ( WaveNum >= 4 ) // с 5 волны
	{
		EndyCounter++;
	}
}
*/
// Spawn a helper squad for the patriarch when he runs off to heal
function AddBossBuddySquad()
{
	local int numspawned;
	local int TotalZombiesValue;
	local int i;
	local int TempMaxMonsters;
	local int TotalSpawned;
	local int TotalZeds;
	local int SpawnDiff;
	local int NumPlayersLocal;
	
	NumPlayersLocal = GetActualPlayersNum();

	// Scale the number of helpers by the number of players
	if( NumPlayersLocal < 6 )
	{
		TotalZeds = 16;
	}
	else if( NumPlayersLocal < 9 )
	{
		TotalZeds = 18;
	}
	else if( NumPlayersLocal < 12 )
	{
		TotalZeds = 20;
	}
	else if( NumPlayersLocal < 15 )
	{
		TotalZeds = 22;
	}
	else if( NumPlayersLocal < 18 )
	{
		TotalZeds = 26;
	}
	else if( NumPlayersLocal < 21 )
	{
		TotalZeds = 28;
	}
	else if( NumPlayersLocal < 26 )
	{
		TotalZeds = 30;
	}
	/*else if( NumPlayers < 24 )
	{
		TotalZeds = 112;
	}*/
	else
	{
		TotalZeds = 30;//128;
	}

	for ( i = 0; i < 10; i++ )
	{
		if( TotalSpawned >= TotalZeds )
		{
			FinalSquadNum++;
			//log("Too many monsters, returning");
			return;
		}

		numspawned = 0;

		// Set up the squad for spawning
		NextSpawnSquad.length = 0;
		AddSpecialPatriarchSquad();

		LastZVol = FindSpawningVolume();
		if( LastZVol!=None )
			LastSpawningVolume = LastZVol;

		if(LastZVol == None)
		{
			LastZVol = FindSpawningVolume();
			if( LastZVol!=None )
				LastSpawningVolume = LastZVol;

			if( LastZVol == none )
			{
				log("Error!!! Couldn't find a place for the Patriarch squad after 2 tries!!!");
			}
		}

		// See if we've reached the limit
		if( (NextSpawnSquad.Length + TotalSpawned) > TotalZeds )
		{
			SpawnDiff = (NextSpawnSquad.Length + TotalSpawned) - TotalZeds;

			if( NextSpawnSquad.Length > SpawnDiff )
			{
				NextSpawnSquad.Remove(0, SpawnDiff);
			}
			else
			{
				FinalSquadNum++;
				return;
			}

			if( NextSpawnSquad.Length == 0 )
			{
				FinalSquadNum++;
				return;
			}
		}

		// Spawn the squad
		TempMaxMonsters =999;
		if( LastZVol.SpawnInHere(NextSpawnSquad,,numspawned,TempMaxMonsters,999,TotalZombiesValue) )
		{
			NumMonsters += numspawned;
			WaveMonsters+= numspawned;
			TotalSpawned += numspawned;

			NextSpawnSquad.Remove(0, numspawned);
		}
	}

	FinalSquadNum++;
}

function AddBossEarly()
{
	local array< class<KFMonster> > TempSquads;
	
	//TempSquads[0] = Class'DKPatriarch';
	TempSquads[0] = Class'HardPat';
	bEarlySpawnBoss = false;

	NextSpawnSquad = TempSquads;
	
	NumLastSpawned = 1;
}

function AddSpecialMonster(class<DKMonster> MonClass, int Num)
{
	local array< class<KFMonster> > TempSquads;
	local int i;

	for(i=0; i<Num; i++)
	{
		TempSquads[i] = MonClass;
	}

	NextSpawnSquad = TempSquads;
	
	NumLastSpawned = i;
}

/*function class<DKMonster> MaybeSpawnRandomMon()
{
	local float Dice;
	
	Dice = FRand();
	
	if ( WaveNum < 7 )
	{
		if ( Dice < RSMC_Fleshpound / float(WaveMonstersLimit) * float(NumLastSpawned) ) // Maybe spawn Fleshpound??
		{
			return class 'DKFleshPoundNew';
		}
		Dice -= RSMC_Fleshpound / float(WaveMonstersLimit) * float(NumLastSpawned);
		
		if ( WaveNum > 1 )
		{
			if ( Dice < RSMC_FleshpoundP / float(WaveMonstersLimit) * float(NumLastSpawned) )
			{
				return class 'DKFleshPoundNewP';
			}
			Dice -= RSMC_FleshpoundP / float(WaveMonstersLimit) * float(NumLastSpawned);
		}

		if ( Dice < RSMC_Brute / float(WaveMonstersLimit) * float(NumLastSpawned) )
		{
			return class 'DKBrute';
		}
		Dice -= RSMC_Brute / float(WaveMonstersLimit) * float(NumLastSpawned);
		
		if ( Dice < RSMC_Scrake / float(WaveMonstersLimit) * float(NumLastSpawned) )
		{
			return class 'DKScrake';
		}
		Dice -= RSMC_Scrake / float(WaveMonstersLimit) * float(NumLastSpawned);
		
		if ( Dice < RSMC_Husk / float(WaveMonstersLimit) * float(NumLastSpawned) )
		{
			return class 'DKHusk';
		}
		Dice -= RSMC_Husk / float(WaveMonstersLimit) * float(NumLastSpawned);
		
		if ( Dice < RSMC_Siren / float(WaveMonstersLimit) * float(NumLastSpawned) )
		{
			return class 'DKSiren';
		}
		Dice -= RSMC_Siren / float(WaveMonstersLimit) * float(NumLastSpawned);

		if ( Dice < RSMC_Shiver / float(WaveMonstersLimit) * float(NumLastSpawned) )
		{
			return class 'DKShiver';
		}
		Dice -= RSMC_Shiver / float(WaveMonstersLimit) * float(NumLastSpawned);
		
		if ( WaveNum > 2 )
		{
			if ( Dice < RSMC_Reaver / float(WaveMonstersLimit) * float(NumLastSpawned))
			{
				return class 'DKReaver';
			}
			Dice -= RSMC_Reaver / float(WaveMonstersLimit) * float(NumLastSpawned);
		}
		if ( WaveNum > 0 )
		{
			if ( Dice < RSMC_Poisoner / float(WaveMonstersLimit) * float(NumLastSpawned) )
			{
				return class 'DKPoisoner';
			}
			Dice -= RSMC_Poisoner / float(WaveMonstersLimit) * float(NumLastSpawned);
		}
		if ( WaveNum > 1 )
		{
			if ( Dice < RSMC_Demolisher / float(WaveMonstersLimit) * float(NumLastSpawned) )
			{
				return class 'DKDemolisher';
			}
			Dice -= RSMC_Demolisher / float(WaveMonstersLimit) * float(NumLastSpawned);
		}
	}

	return none;
}*/
				
function class<DKMonster> MaybeSpawnRandomMon()
{
	//Боюсь даже спрашивать, что за Инштейн придумал это!
	//Возможно оптимизировать в инном ввиде, но нужно придумать другую система шанса
	//#O
	local float Dice, WaveChance;
	Dice = FRand();	//
	WaveChance = float(WaveMonstersLimit) * float(NumLastSpawned);
	
	if ( WaveNum < 7 && WaveNum > 1 )
	{
		if ( Dice < RSMC_FleshpoundP / WaveChance )
		{
			return class 'DKFleshPoundNewP';
		}
		Dice -= RSMC_FleshpoundP / WaveChance;

		if ( Dice < RSMC_Brute / WaveChance )
		{
			return class 'DKBrute';
		}
		Dice -= RSMC_Brute / WaveChance;
	}
	if ( WaveNum < 7 && WaveNum > 0 )
	{
		if ( Dice < RSMC_Fleshpound / WaveChance ) // Maybe spawn Fleshpound??
		{
			return class 'DKFleshPoundNew';
		}
		Dice -= RSMC_Fleshpound / WaveChance;

		if ( Dice < RSMC_Fleshpound / WaveChance ) // Maybe spawn Fleshpound??
		{
			return class 'DKFleshpoundKF2DT';
		}
		Dice -= RSMC_Fleshpound / WaveChance;

		if ( Dice < RSMC_Scrake / WaveChance )
		{
			return class 'DKScrake';
		}
		Dice -= RSMC_Scrake / WaveChance;
		
		if ( Dice < RSMC_ScrakeKF2 / WaveChance )
		{
			return class 'DKScrakeKF2DT';
		}
		Dice -= RSMC_ScrakeKF2 / WaveChance;
		
		/*if ( Dice < RSMC_FFP / WaveChance )
		{
			return class 'FemaleFP';
		}*/
		//Dice -= RSMC_FFP / WaveChance;
		
		if ( Dice < RSMC_Husk / WaveChance )
		{
			return class 'DKHusk';
		}
		Dice -= RSMC_Husk / WaveChance;
		
		if ( Dice < RSMC_Siren / WaveChance )
		{
			return class 'DKSiren';
		}
		Dice -= RSMC_Siren / WaveChance;

		if ( Dice < RSMC_Shiver / WaveChance)
		{
			return class 'DKShiver';
		}
		Dice -= RSMC_Shiver / WaveChance;
		if ( WaveNum > 2 )
		{
			if ( Dice < RSMC_Reaver / WaveChance)
			{
				return class 'DKReaver';
			}
			Dice -= RSMC_Reaver / WaveChance;
		}
		if ( WaveNum > 0 )
		{
			if ( Dice < RSMC_Poisoner / WaveChance)
			{
				return class 'DKPoisoner';
			}
			Dice -= RSMC_Poisoner / WaveChance;
		}
		if ( WaveNum > 1 )
		{
			if ( Dice < RSMC_Demolisher / WaveChance)
			{
				return class 'DKDemolisher';
			}
			Dice -= RSMC_Demolisher / WaveChance;
		}
	}
	return none;
}
simulated function PlayerDeathSlomo(SRHumanPawn SRHP)
{
	if ( SRPlayerReplicationInfo(SRHP.PlayerReplicationInfo).ClientVeteranSkillLevel >=15  
	&& FRand() < 0.00625 * float(SRPlayerReplicationInfo(SRHP.PlayerReplicationInfo).ClientVeteranSkillLevel) )
		DramaticEvent(1.00);
}

function bool IsCurrentPerkLevelPresent(int PerkLevel, optional bool bCheckDead)
{
	local Controller C;
	local SRPlayerReplicationInfo SRPRI;
	
	for(C=Level.ControllerList; C!=none; C=C.NextController)
	{
		if ( C.bIsPlayer && C.Pawn != none && ( C.Pawn.Health > 0 || bCheckDead ) )
		{
			SRPRI = SRPlayerReplicationInfo(C.PlayerReplicationInfo);
			if ( SRPRI != none && SRPRI.ClientVeteranSkill != none && SRPRI.ClientVeteranSkillLevel >= PerkLevel )
				return true;
		}
	}
	return false;
}

function AllMessage(string Mes)
{
	local Controller C;

	for( C = Level.ControllerList; C != None; C = C.nextController )
	{
		if( C.IsA('PlayerController') || C.IsA('xBot'))
		{
			C.Pawn.ClientMessage(Mes);
		}
	}
}

function DebugMessage(string Mes)
{
	if ( !bDebug )
		return;
	AllMessage(mes);
}

function TesterMessage(string Mes)
{
/*
	local Controller C;

	for( C = Level.ControllerList; C != None; C = C.nextController )
	{
		if( C.IsA('PlayerController') || C.IsA('xBot'))
		{

			if (	SRPlayerReplicationInfo(C.PlayerReplicationInfo).StringPlayerID == "76561198051424268" ||
					SRPlayerReplicationInfo(C.PlayerReplicationInfo).StringPlayerID == "76561202094964582" ||
					SRPlayerReplicationInfo(C.PlayerReplicationInfo).StringPlayerID == "76561198049490366" ||
					SRPlayerReplicationInfo(C.PlayerReplicationInfo).StringPlayerID == "76561198054633002" ||
					SRPlayerReplicationInfo(C.PlayerReplicationInfo).StringPlayerID == "76561198026416647" ||
					SRPlayerReplicationInfo(C.PlayerReplicationInfo).StringPlayerID == "76561202182120566" )
			{
				if ( SRHumanPawn(C.Pawn).bTestMode )
				{
					C.Pawn.ClientMessage(Mes);
				}
			}
		}
	}
*/
}

/*function NotifyRepInfoSpawn(SRPlayerReplicationInfo RepSpawned)
{
	local int i,n;
	
	//log("NotifyRepInfoSpawn entry");
	n = RepRecords.Length;
	//log("RepRecords.Length = " $ n);
	for(i=0; i<n; i++)
	{
		//log("RepRecords[" $ i $ "].StringPlayerID = " $ RepRecords[i].StringPlayerID);
		if ( RepSpawned.StringPlayerID ~= RepRecords[i].StringPlayerID )
		{
			//log("RepSpawned.StringPlayerID = " $ RepSpawned.StringPlayerID);
			RepSpawned.BoundPRI = RepRecords[i];
			RepSpawned.RestoreRepInfo();
			RepSpawned.BoundPRI.BoundPRI = RepSpawned;
			ReservePlayerReplicationInfo(RepSpawned.BoundPRI).bPlayerPresent = true;
			return;
		}
	}

	RepRecords.Insert(0,1);
	RepRecords[0] = Spawn(class'ReservePlayerReplicationInfo',RepSpawned.Controller,,vect(0,0,0),rot(0,0,0));
	RepSpawned.BoundPRI = RepRecords[0];
	RepSpawned.BoundPRI.BoundPRI = RepSpawned;
	ReservePlayerReplicationInfo(RepSpawned.BoundPRI).bPlayerPresent = true;
	ReservePlayerReplicationInfo(RepSpawned.BoundPRI).Timer();
}*/

function int GetActualPlayersNum()
{
	local Controller C;
	local int ret;
	
	for(C=Level.ControllerList; C!=none; C=C.NextController)
	{
		if ( C.bIsPlayer && C.Pawn != none && KFHumanPawn(C.Pawn) != none && C.Pawn.Health > 0 )
			++ret;
	}
	
	return ret;
}

//Flame
function ShowPathTo(PlayerController P, int TeamNum)
{
	local int i;
	local array<Teleporter> TelList;

	for(i=0;i<ShopList.Length;i++)
	{
		ShopList[i].InitTeleports();
		TelList=ShopList[i].TelList;
		if	(
				TelList.Length>0
				&&	TelList[0] != None
				&&	P.FindPathToward(TelList[0],false) != None
			)
		{
			Spawn(class'RedWhisp', P,, P.Pawn.Location);
		}
	}
}

/*cccccccccccc
Убил моба в тело (с головой)
DKMonster(Pawn).bTakingHeadshot = False;
DKMonster(Pawn).bDecapitated = False;
Обезглавил моба (тело ходит живое)
DKMonster(Pawn).bTakingHeadshot = True
DKMonster(Pawn).bDecapitated = False
Убил обезглавленое тело (или само умерло)
DKMonster(Pawn).bTakingHeadshot = False
DKMonster(Pawn).bDecapitated = True
Убил моба в голову (происходит 2 события);
1-обезглавлевание
DKMonster(Pawn).bTakingHeadshot = True
DKMonster(Pawn).bDecapitated = False
2-смерть тела
DKMonster(Pawn).bTakingHeadshot = True  
DKMonster(Pawn).bDecapitated=  True
*/

simulated function Neutralized(Controller owner, Controller target, class<DamageType> damageType)
{
	local Pawn POwner, PTarget;
	local SRPlayerReplicationInfo SRPRI;
	local DKMonster MonsterType;

	if ( DKMonster(target.Pawn).IsaZedTimeMonster() && !DKMonster(target.Pawn).bZedTimeUsed )
	{
		KFGameType(Level.Game).DramaticEvent(1.0);
		DKMonster(target.Pawn).bZedTimeUsed = true;
	}

	if(owner != none && owner.bIsPlayer && target != none)
	{
		POwner = owner.Pawn;
		PTarget = target.Pawn;
		SRPRI = SRPlayerReplicationInfo(owner.PlayerReplicationInfo);
		if(target.bIsPlayer)
		{
			//Team Kill
			if(SRPRI != none && owner != target)
				SRPRI.ScoreBoardStruct.TeamKills++;
		
			//Dies
			if(target.PlayerReplicationInfo != none)
				SRPRI = SRPlayerReplicationInfo(target.PlayerReplicationInfo);
			if(SRPRI != none)
				SRPRI.ScoreBoardStruct.Dies++;
		}
		else if (DKMonster(PTarget) != none && SRPRI != none)
		{
			MonsterType = DKMonster(PTarget);
			if(!MonsterType.bDecapitated)
			{ 
				switch(MonsterType)
				{
					case DKPoisoner(PTarget):
						SRPRI.ScoreBoardStruct.Poisoner++;
						break;
					case DKStalker(PTarget):  		
						SRPRI.ScoreBoardStruct.Stalker++;
						break;
					case ZombieStalker_XMasSR(PTarget):  		
						SRPRI.ScoreBoardStruct.Stalker++;
						break;
					case DKHusk(PTarget):			
						SRPRI.ScoreBoardStruct.Husk++;
						break;
					case ZombieHusk_XMasSR(PTarget):			
						SRPRI.ScoreBoardStruct.Husk++;
						break;
					case DKDemolisher(PTarget):		
						SRPRI.ScoreBoardStruct.Demolisher++;
						break;
					case DKScrakeHZD(PTarget): 
						SRPRI.ScoreBoardStruct.Scrake++;
						break;
					case DKScrake(PTarget): 
						SRPRI.ScoreBoardStruct.Scrake++;
						break;
					case ZombieScrake_XMasSR(PTarget): 
						SRPRI.ScoreBoardStruct.Scrake++;
						break;
					case DKScrakeKF2DT(PTarget): 
						SRPRI.ScoreBoardStruct.Scrake++;
						break;
					case DKScrakeKF2DTHZD(PTarget): 
						SRPRI.ScoreBoardStruct.Scrake++;
						break;
					case DKBrute(PTarget):  
						SRPRI.ScoreBoardStruct.Brute++;
						break;
					case TankerBruteDT(PTarget):  
						SRPRI.ScoreBoardStruct.Brute++;
						break;
					/*case DKTroll(PTarget):  
						SRPRI.ScoreBoardStruct.Brute++;
						break;
					case ZombieBrute(PTarget):  
						SRPRI.ScoreBoardStruct.Brute++;
						break;*/
					case DKEndy(PTarget):
						SRPRI.ScoreBoardStruct.Endy++;
						break;
					case DKEndyHzD(PTarget):
						SRPRI.ScoreBoardStruct.Endy++;
						break;
					case DKArchville(PTarget):
						SRPRI.ScoreBoardStruct.Archvile++;
						break;
					/*case FemaleFP(PTarget):
						SRPRI.ScoreBoardStruct.FFP++;
						break;*/
					case DKFleshPoundNew(PTarget):
						SRPRI.ScoreBoardStruct.FP++;
						break;
					case DKFleshPoundNewHZD(PTarget):
						SRPRI.ScoreBoardStruct.FP++;
						break;
					case ZombieFleshPound_XMasSR(PTarget):
						SRPRI.ScoreBoardStruct.FP++;
						break;
					case DKFleshpoundKF2DT(PTarget):
						SRPRI.ScoreBoardStruct.FP++;
						break;
					case DKFleshpoundKF2DTHZD(PTarget):
						SRPRI.ScoreBoardStruct.FP++;
						break;
					case DKFleshPoundNewPHZD(PTarget):
						SRPRI.ScoreBoardStruct.FP++;
						break;
					case DKFleshPoundNewP(PTarget):
						SRPRI.ScoreBoardStruct.FP++;
						break;
					case DKFleshPoundNewP(PTarget):
						SRPRI.ScoreBoardStruct.MFP++;
						break;
					case ZombieFleshPound_XMasSRP(PTarget):
						SRPRI.ScoreBoardStruct.FP++;
						break;
					case ZombieFleshPound_XMasSRP(PTarget):
						SRPRI.ScoreBoardStruct.MFP++;
						break;
					}
					return;
			}
			//весь типаж
			switch(MonsterType)
			{
				case DKPatriarch(PTarget):
					SRPRI.ScoreBoardStruct.Patriarch++;
				case HardPat(PTarget):
					SRPRI.ScoreBoardStruct.Patriarch++;
				case HardPatHZD(PTarget):
					SRPRI.ScoreBoardStruct.Patriarch++;
			}
		}
	}
}

//Warning 2012_11_18
function AmmoPickedUp(KFAmmoPickup PickedUp)
{
	local int Random, i;
	for ( i = 0; i < 10000; i++ )
	{
		Random = Rand(AmmoPickups.Length);
		if (	AmmoPickups[Random]!=None && //warning fix
				AmmoPickups[Random] != PickedUp && AmmoPickups[Random].bSleeping )
		{
			AmmoPickups[Random].GotoState('Sleeping', 'DelayedSpawn');
			return;
		}
	}
	PickedUp.GotoState('Sleeping', 'DelayedSpawn');
}
//Flame 2012_11_18

defaultproperties
{
	bDebug=false;
	BossEarlySpawnChance=0.00;
	b6lvlPresence=false;
	b9lvlPresence=false;
	b10lvlPresence=false;
	AveragePerkLevel=0.0;
	DoubleZedSpawnPossibility=0.00;
	ProfResist=0.0;
	ZedNumModifier=0.0;
	DemoFireDamageModifier=1.0;
	FireBombsBlownUp=0;
	FireBombAllowToBlowTime=0.0;
	SRMaxPlayers=25;
	DefaultPlayerClassName="Masters.SRHumanPawn"
	GameReplicationInfoClass=Class'Masters.SRGameReplicationInfo'
	//MaxPlayers = 25
	
	MonsterNumPerWave = 20, 28, 32, 32, 35, 40, 42;
	
	bDebugRandSpawns = true;

	//BossClassDK = "Masters.DKPatriarch"
	BossClassDK = "Masters.HardPat"
}
