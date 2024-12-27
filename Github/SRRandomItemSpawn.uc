// Класс случайного спавна предметов от Tripwire, модифицированный Dr. Killjoy (Steklo)
// для улучшения геймплея и эффекта неожиданности
// кто спиздил , жри говно сука

class SRRandomItemSpawn extends KFRandomItemSpawn;

struct PickupRecord
{
	var Class<Pickup>	PickupClass;
	var	int				Value;
	var	float			Possibility; // 1.0 is 100%
	var int				PickupWeight;
};

var array<PickupRecord> PossiblePickups[255];
var	array<int>			WaveApproxValue[11];

var bool bNotRandomSpawn;

simulated function DisplayInfo()
{
	local KFPCServ MyPCOwner;
	local int i,k,n;
	local string Answer;
	local Controller C;
	
	for(i=0; i<NumClasses; i=i)
	{
		Answer = "";
		for(k=0; k<3&&i<NumClasses; k++)
		{
			Answer = Answer $ "PossiblePickups[" $ string(i) $ "] = (" $ string(PossiblePickups[i].PickupClass) $ "," $ string(PossiblePickups[i].PickupWeight) $ "; ";
		}
		
		for(C=Level.ControllerList; C!=None; C=C.NextController)
		{
			if ( SRPlayerReplicationInfo(C.PlayerReplicationInfo).bSunriseAdmin )
			{
				KFPlayerController(C).ClientMessage(Answer);
			}
		}
		
	}
}

function InitPickupClasses()
{
	NumClasses = 0;
	AddPickupClass(Class'MachetePickupM',225,1.00);
	AddPickupClass(Class'AxePickupM',300,1.00);
	AddPickupClass(Class'ChainsawPickupM',900,1.00);
	AddPickupClass(Class'KatanaLLIPickup',1250,1.00);
	AddPickupClass(Class'ClaymoreSwordPickupM',2500,1.00);
	AddPickupClass(Class'L96AWPLLIPickup',1000,1.00);
	AddPickupClass(Class'OpticalDeaglePickup',2000,1.00);
	AddPickupClass(Class'SVUPickup',3000,1.00);
	AddPickupClass(Class'HK417Pickup',2000,1.00);
	AddPickupClass(Class'CrossbowPickupM',1500,1.00);
	AddPickupClass(Class'SVDLLIPickup',4000,1.00);
	AddPickupClass(Class'ShotgunPickupM',400,1.00);
	AddPickupClass(Class'BoomStickPickupM',1350,1.00);
	AddPickupClass(Class'AA12PickupM',3500,1.00);
	AddPickupClass(Class'Moss12Pickup',350,1.00);
	AddPickupClass(Class'Saiga12cPickup',2500,1.00);
	AddPickupClass(Class'WeldShotPickup',1200,0.70);
	AddPickupClass(Class'WMediShotPickup',900,1.00);
	AddPickupClass(Class'ProtectaPickup',5000,1.00);
	AddPickupClass(Class'BenelliPickupM',1500,1.00);
	AddPickupClass(Class'Rem870ECPickup',5000,1.00);
	AddPickupClass(Class'Toz34ShotgunPickup',700,1.00);
	AddPickupClass(Class'HSGPickup',1800,1.00);
	AddPickupClass(Class'MP7MPickupM',1500,1.00);
	AddPickupClass(Class'M7A3MSRPickup',3000,1.00);
	AddPickupClass(Class'MP5MPickupM',2000,0.50);
//	AddPickupClass(Class'M7A3MPickup',2500,1.00);
//	AddPickupClass(Class'OpticalDeagleMedicPickup',2400,1.00);
	AddPickupClass(Class'BullpupPickupM',700,1.00);
	AddPickupClass(Class'AK47SHPickupM',4000,1.00);
	AddPickupClass(Class'SCARMK17PickupM',2000,1.00);
	AddPickupClass(Class'M4PickupM',1800,1.00);
	AddPickupClass(Class'WaltherP99Pickup',650,1.00);
	AddPickupClass(Class'AN94Pickup',3000,1.00);
	AddPickupClass(Class'AUG_A3ARPickup',2500,1.00);
	AddPickupClass(Class'SR3MPickup',5000,1.00);
	AddPickupClass(Class'XM8Pickup',3000,1.00);
	AddPickupClass(Class'LAWPickupM',4000,1.00);
	AddPickupClass(Class'M79PickupM',1250,1.00);
	AddPickupClass(Class'M32PickupM',2500,1.00);
	AddPickupClass(Class'WColtPickup',2500,1.00);
	AddPickupClass(Class'RPGPickup',3000,1.00);
	AddPickupClass(Class'EX41Pickup',2500,1.00);
	AddPickupClass(Class'FlameThrowerPickupM',2000,1.00);
	AddPickupClass(Class'MAC10PickupM',500,1.00);
	AddPickupClass(Class'M79FPickup',3000,1.00);
	AddPickupClass(Class'HuskGunNewPickup',3500,1.00);
	AddPickupClass(Class'FlaregunPickup',1200,1.00);
	AddPickupClass(Class'PP19Pickup',2500,1.00);
	AddPickupClass(Class'FN2000Pickup',2500,1.00);
	AddPickupClass(Class'AFS12Pickup',4000,1.00);
	AddPickupClass(Class'UMP45Pickup',2000,1.00);
	AddPickupClass(Class'AK74uPickup',3000,1.00);
	AddPickupClass(Class'ThompsonPickup',550,1.00);
	AddPickupClass(Class'SA80LSWPickup',1500,1.00);
	AddPickupClass(Class'PKMPickup',3500,1.00);
	AddPickupClass(Class'M249Pickup',4000,1.00);
	AddPickupClass(Class'BerettaPx4Pickup',700,1.00);
	AddPickupClass(Class'RPK47Pickup',1800,1.00);
	AddPickupClass(Class'AUG_A1MGPickup',1200,1.00);
	AddPickupClass(Class'VSSDTPickup',3200,1.00);
//	AddPickupClass(Class'PBPickup',900,1.00);
//	AddPickupClass(Class'VALDTPickup',1800,1.00);
//	AddPickupClass(Class'AKC74Pickup',1000,1.00);
//	AddPickupClass(Class'NinjatoPickup',2100,1.00);
//	AddPickupClass(Class'DaggerPickup',1000,1.00);
	AddPickupClass(Class'Colt1911Pickup',700,1.00);
	AddPickupClass(Class'MK23NewPickup',600,1.00);
	AddPickupClass(Class'Magnum44PickupM',1500,1.00);
	AddPickupClass(Class'WinchesterPickupM',800,1.00);
	AddPickupClass(Class'FnFalACOGPickup',3000,1.00);
	AddPickupClass(Class'M14EBRPickupM',2500,1.00);
	AddPickupClass(Class'Vest',300,1.00);
	AddPickupClass(Class'Vest',900,1.00);
	AddPickupClass(Class'Vest',1500,1.00);
//	AddPickupClass(Class'FirstAidKitSuper',1500,1.00);

}

function AddPickupClass(class<Pickup> PClass, int Val, optional float Pos)
{
	if ( Pos ~= 0.00 )
	{
		Pos = 1.00;
	}
	PossiblePickups[NumClasses].PickupClass = PClass;
	PossiblePickups[NumClasses].Value = Val;
	PossiblePickups[NumClasses].Possibility = Pos;
	NumClasses++;
}

function DebugLog()
{
	if ( DKGameType(Level.Game).bDebugRandSpawns )
	{
		Log("SRRandomItemSpawn NumClasses = " $ string(NumClasses)); 
		Log("SRRandomItemSpawn PowerUp = " $ string(PowerUp));
	}
}

simulated function PostBeginPlay()
{
	local int i;

	if ( Level.NetMode!=NM_Client )
	{
		if( !bNotRandomSpawn )
		{
			InitPickupClasses();
		}
		else
		{
			NumClasses = 1;
		}

		SetupPossibilities();

		if ( bNotRandomSpawn )
		{
			CurrentClass = 0;
		}
		else
		{
			CurrentClass = GetWeightedRandClass();
		}

		PowerUp = PossiblePickups[CurrentClass].PickupClass;
	}
//	if ( Level.NetMode != NM_DedicatedServer )
//	{
//		for ( i=0; i< NumClasses; i++ )
//			PossiblePickups[i].PickupClass.static.StaticPrecache(Level);
//	}
	// Add to KFGameType.WeaponPickups array
	if ( KFGameType(Level.Game) != none && !bNotRandomSpawn )
	{
		KFGameType(Level.Game).WeaponPickups[KFGameType(Level.Game).WeaponPickups.Length] = self;
		DisableMe();
	}

	SetLocation(Location - vect(0,0,1)); // adjust because reduced drawscale
}

function SetupPossibilities(optional int CurWave)
{
	local int i,c;
	local float TotalPossibility;
	local int TotalValue,MaxValue;
	local float ItemsNum,AverageValue,SummaryValue,PrevAverValue,Difference,Modifier,MinimalPossibility;
	local array<float>	TempWeight;
	local bool bNeedIncrease,bOldNeedIncrease;

	if ( bNotRandomSpawn )
	{
		PossiblePickups[0].Possibility = 1.00;
		return;
	}
	
	TotalValue = 0;
	MaxValue = -1;
	ItemsNum = 0.00;

	for(i=0; i<NumClasses; ++i)
	{
		TotalValue += PossiblePickups[i].Value;
		MaxValue = Max(PossiblePickups[i].Value,MaxValue);
	}
	
	for(i=0; i<NumClasses; ++i)
	{
		ItemsNum += float(MaxValue) / float(PossiblePickups[i].Value) * PossiblePickups[i].Possibility;
	}

	// Start Calculations

	
	SummaryValue = 0.00;
	
	for(i=0; i<NumClasses; ++i)
	{
		SummaryValue += float(MaxValue) * PossiblePickups[i].Possibility;
	}
	
	PrevAverValue = SummaryValue / ItemsNum;
	
	c = 0;
	Modifier = 1.00;
	bOldNeedIncrease = PrevAverValue < WaveApproxValue[CurWave];
	Difference = 2000000000.00;

Retry:

	if ( PrevAverValue ~= WaveApproxValue[CurWave] )
	{
		Goto Finish;
	}

	SummaryValue = 0.00;
	ItemsNum = 0.00;
//	TotalPossibility = 0.00;
	
	for(i=0; i<NumClasses; ++i)
	{
		SummaryValue += float(MaxValue) * PossiblePickups[i].Possibility;
		ItemsNum += float(MaxValue) / float(PossiblePickups[i].Value) * PossiblePickups[i].Possibility;
	}
	
	AverageValue = SummaryValue / ItemsNum;
	
	if ( AverageValue < WaveApproxValue[CurWave] )
	{
		bNeedIncrease = true;
	}
	else
	{
		bNeedIncrease = false;
	}
	
	if ( bNeedIncrease != bOldNeedIncrease )
	{
		Modifier *= 0.90;
	}
	
	for(i=0; i<NumClasses; ++i)
	{
		if ( bNeedIncrease && ( float(PossiblePickups[i].Value) * PossiblePickups[i].Possibility > WaveApproxValue[CurWave] ) )
		{
			PossiblePickups[i].Possibility *= ( 1.0 + ( (float(PossiblePickups[i].Value) * PossiblePickups[i].Possibility) / float(WaveApproxValue[CurWave]) - 1.0 ) * Modifier * FRand() );
		}
		else if ( !bNeedIncrease && ( ( float(PossiblePickups[i].Value) * PossiblePickups[i].Possibility < WaveApproxValue[CurWave] )
				|| ( float(PossiblePickups[i].Value) * PossiblePickups[i].Possibility ~= WaveApproxValue[CurWave] ) ) )
		{
			PossiblePickups[i].Possibility *= ( 1.0 + ( float(WaveApproxValue[CurWave]) / (float(PossiblePickups[i].Value) * PossiblePickups[i].Possibility) - 1.0 ) * Modifier * FRand() );
		}
		else if ( bNeedIncrease && ( float(PossiblePickups[i].Value) * PossiblePickups[i].Possibility < WaveApproxValue[CurWave] ) )
		{
			PossiblePickups[i].Possibility /= ( 1.0 + ( float(WaveApproxValue[CurWave]) / (float(PossiblePickups[i].Value) * PossiblePickups[i].Possibility) - 1.0 ) * Modifier * FRand() );
		}
		else if ( !bNeedIncrease && ( ( float(PossiblePickups[i].Value) * PossiblePickups[i].Possibility > WaveApproxValue[CurWave] )
				|| ( float(PossiblePickups[i].Value) * PossiblePickups[i].Possibility ~= WaveApproxValue[CurWave] ) ) )
		{
			PossiblePickups[i].Possibility /= ( 1.0 + ( (float(PossiblePickups[i].Value) * PossiblePickups[i].Possibility) / float(WaveApproxValue[CurWave]) - 1.0 ) * Modifier * FRand() );
		}
	}
	
	if ( Abs(PrevAverValue - AverageValue) / Difference >= 0.98 )
	{
		Goto Finish;
	}
	
	MinimalPossibility = 2000000000.00;
	
	for(i=0; i<NumClasses; i++)
	{
		if ( PossiblePickups[i].Possibility < MinimalPossibility )
		{
			MinimalPossibility = PossiblePickups[i].Possibility;
		}
	}
	
	if ( MinimalPossibility < 1.00 )
	{
		MinimalPossibility = 1.00 / MinimalPossibility;
		for(i=0; i<NumClasses; i++)
		{
			PossiblePickups[i].Possibility *= MinimalPossibility;
		}
	}
	
	if ( c++ < 240 )
	{
		PrevAverValue = AverageValue;
		bOldNeedIncrease = bNeedIncrease;
		Goto Retry;
	}
	
Finish:
	
	for(i=0; i<NumClasses; ++i)
	{
		PossiblePickups[i].PickupWeight = 1000000.00 * float(TotalValue) / float(PossiblePickups[i].Value) * PossiblePickups[i].Possibility;// Чем дороже оружие, тем меньше шанс
	}
	
	WeightTotal = 0;

	for(i=0; i<NumClasses; ++i)
	{
		if( PossiblePickups[i].PickupWeight == 0 )
		{
			PossiblePickups[i].PickupWeight = 1;
		}
		WeightTotal += PossiblePickups[i].PickupWeight;
	}
	
}

function int GetWeightedRandClass()
{
	local int RandIndex;
	local int Tally;
	local int i;
	
	if ( bNotRandomSpawn )
	{
		return 0;
	}

	RandIndex = rand(WeightTotal+1); // rand always returns a value between 0 and max-1

	Tally = PossiblePickups[0].PickupWeight;

	while(Tally<RandIndex)
	{
		++i;
		Tally+=PossiblePickups[i].PickupWeight;
	}
	return i;
}

function TurnOn()
{
	CurrentClass=GetWeightedRandClass();

	PowerUp = PossiblePickups[CurrentClass].PickupClass;

	if( myPickup != none )
		myPickup.Destroy();

	SpawnPickup();
	SetTimer(InitialWaitTime+InitialWaitTime*FRand(), false);
}

function SpawnPickup()
{
	super.SpawnPickup();

	/*if ( FirstAidKitSuper(myPickup) != none )
	{
		FirstAidKitSuper(myPickup).MySpawner = self;
	}*/
}

function NotifyNewWave(int CurrentWave, int FinalWave)
{
	SetupPossibilities(CurrentWave);
}

function EnableMe()
{
	bIsEnabledNow = True;
	SetTimer(0.1, false);
}

function EnableMeDelayed(float Delay)
{
	bIsEnabledNow = True;
	SetTimer(Delay, false);
}

defaultproperties
{
	bNotRandomSpawn = false
	
	WaveApproxValue(0) = 400
	WaveApproxValue(1) = 600
	WaveApproxValue(2) = 800
	WaveApproxValue(3) = 1000
	WaveApproxValue(4) = 1300
	WaveApproxValue(5) = 1700
	WaveApproxValue(6) = 2200
	WaveApproxValue(7) = 3000
	
}
