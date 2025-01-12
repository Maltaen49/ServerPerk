class SRVetDemolitions extends SRVeterancyTypes
	abstract;

static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	switch( CurLevel )
	{
	case 0:
		FinalInt = 5000;
		break;
	case 1:
		FinalInt = 18750;
		break;
	case 2:
		FinalInt = 37500;
		break;
	case 3:
		FinalInt = 75000;
		break;
	case 4:
		FinalInt = 150000;
		break;
	case 5:
		FinalInt = 312500;
		break;
	case 6:
		FinalInt = 625000;
		break;
	case 7:
		FinalInt = 1250000;
		break;
	case 8:
		FinalInt = 2500000;
		break;
	case 9:
		FinalInt = 5000000;
		break;
	case 10:
		FinalInt = 7500000;
		break;
	case 11:
		FinalInt = 10000000;
		break;
	case 12:
		FinalInt = 17000000;
		break;
	case 13:
		FinalInt = 24000000;
		break;
	case 14:
		FinalInt = 31000000;
		break;
	case 15:
		FinalInt = 38000000;
		break;
	case 16:
		FinalInt = 48000000;
		break;
	case 17:
		FinalInt = 58000000;
		break;
	case 18:
		FinalInt = 68000000;
		break;
	case 19:
		FinalInt = 78000000;
		break;
	case 20:
		FinalInt = 88000000;
		break;
	case 21:
		FinalInt = 103000000;
		break;
	case 22:
		FinalInt = 119000000;
		break;
	case 23:
		FinalInt = 136000000;
		break;
	case 24:
		FinalInt = 154000000;
		break;
	case 25:
		FinalInt = 173000000;
		break;
	case 26:
		FinalInt = 193000000;
		break;
	case 27:
		FinalInt = 214000000;
		break;
	case 28:
		FinalInt = 236000000;
		break;
	case 29:
		FinalInt = 259000000;
		break;
	case 30:
		FinalInt = 283000000;
		break;
	case 31:
		FinalInt = 308000000;
		break;
	case 32:
		FinalInt = 338000000;
		break;
	case 33:
		FinalInt = 368000000;
		break;
	case 34:
		FinalInt = 398000000;
		break;
	case 35:
		FinalInt = 428000000;
		break;
	case 36:
		FinalInt = 458000000;
		break;
	case 37:
		FinalInt = 488000000;
		break;
	case 38:
		FinalInt = 518000000;
		break;
	case 39:
		FinalInt = 558000000;
		break;
	case 40:
		FinalInt = 600000000;
		break;
	case 41:
		FinalInt = 1350000000;
		break;
	default:
		FinalInt = 5500000+GetDoubleScaling(CurLevel,500000);
	}
	return Min(StatOther.RExplosivesDamageStat,FinalInt);
}

static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil)
{
	Recoil = 1.00;

	if ( AN94SAAssaultRifle(Other.Weapon) != none )
	{
		Recoil = 0.40 - 0.0075 * float(KFPRI.ClientVeteranSkillLevel);
	}

	return Recoil;
}

static function int GetMaxArmor(KFPlayerReplicationInfo KFPRI)
{
	local int level;
	level = 1;
	if(KFPRI != none)
		level = KFPRI.ClientVeteranSkillLevel;
	
	if(level > 40)
		return 200;

	return 100;

}
/*static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	FinalInt = PerkLevelRequirement(CurLevel,ReqNum);
	return Min(StatOther.RExplosivesDamageStat,FinalInt);
}

static function int PerkLevelRequirement(byte CurLevel, byte ReqNum)
{
	local array<float> StartReq,WholeReq;
	local int FinalInt;
	
	StartReq.Insert(0,3);
	WholeReq.Insert(0,3);
	
	StartReq[0] =    500000;
	WholeReq[0] =   6000000;
	StartReq[1] =   2000000;
	WholeReq[1] = 294000000;
	StartReq[2] =  18000000;
	WholeReq[2] = 300000000;
	
	FinalInt = int(ArythmProgression(CurLevel,StartReq,WholeReq));
	
	return FinalInt;
}*/

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float ret;
	
	ret = 1.0;
	
	if ( AmmoType == class'GrenadePistolLLILAmmo' 
		|| AmmoType == class'FNC30M203Ammo'
		|| AmmoType == class'Armacham203Ammo' ) return ret;
	
	if ( AmmoType == class'FragAmmo' || AmmoType == class'Frag1Ammo' )
	{
		ret = 1.0 + 0.2 * float(KFPRI.ClientVeteranSkillLevel);
	}
	else if ( AmmoType == class'PipeBombAmmo' )
	{
		ret = 2.5 + 0.5 * float(KFPRI.ClientVeteranSkillLevel/2);
	}
	else if ( AmmoType == class'RadioBombAmmo' || AmmoType == class'ATMineAmmo' )
	{
		ret = 1.50 + 0.25 * float(Max(0,(KFPRI.ClientVeteranSkillLevel-1)/5));
	}
	else
	{
		ret = Super.AddExtraAmmoFor(KFPRI,AmmoType);
	}

	return ret;
}

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	local float ret;
	
	ret = 1.0;

	if ( class<DamTypeFrag>(DmgType) != none || class<DamTypeRPG>(DmgType) != none || class<DamTypeRXRLDTRocket>(DmgType) != none ||
		 class<DamTypeM79Grenade>(DmgType) != none || class<DamTypeM32Grenade>(DmgType) != none
		 || class<DamTypeM203Grenade>(DmgType) != none || class<DamTypeRocketImpact>(DmgType) != none
		|| class<DamTypeLAW>(DmgType) != none || class<DamTrigun_Pistol>(DmgType) != none
		 || class<DamTypeEX41>(DmgType) != none || class<DamTypeWColt>(DmgType) != none || class<DamTypeOpticalDeagleF>(DmgType) != none
		 || class<DamTypeSealSquealMExplosion>(DmgType) != none || class<DamTypeHHGrenM>(DmgType) != none
		 || class<DamTypeSeekerSixMRocket>(DmgType) != none || class<DamTypeSeekerMRocketImpact>(DmgType) != none
		 || class<DamTypeBulkCannonLLI>(DmgType) != none || class<DamTypeM202A2>(DmgType) != none || class<DamTypeRG6Grenade>(DmgType) != none
		 || class<DamTypeFC>(DmgType) != none || class<DamTypeFCAP>(DmgType) != none || class<DamTypeFCBS>(DmgType) != none
		 || class<DamTypeZic3LLI>(DmgType) != none || class<DamTypeZic3LLIAP>(DmgType) != none || class<DamTypeZic3LLIBS>(DmgType) != none
		 || class<DamTypeSig33LLI>(DmgType) != none || class<DamTypeSig33LLIAP>(DmgType) != none || class<DamTypeSig33LLIBS>(DmgType) != none
		 || class<DamTypeAN94SA>(DmgType) != none
		 || class<DamTypeBazookaLLI>(DmgType) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 2.0;
		}
		else
		{
			ret = 2.0 + 0.03125 * float(KFPRI.ClientVeteranSkillLevel);
		}
		/*if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 1.50;
		}
		else
		{
			ret = 1.25 + 0.05 * float(KFPRI.ClientVeteranSkillLevel);
		}*/
	}

	else if ( class<DamTypeRadioBomb>(DmgType) != none || class<DamTypeRadioBomb>(DmgType) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 1.5;
		}
		else
		{
			ret = 1.5 + 0.015625 * float(KFPRI.ClientVeteranSkillLevel);
		}
	}
	
	/*else if ( class<DamTypeRadioBomb>(DmgType) != none || class<DamTypeRadioBomb>(DmgType) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 1.25;
		}
		else
		{
			ret = 1.125 + 0.025 * float(KFPRI.ClientVeteranSkillLevel);
		}
	}*/
		
	else if ( class<DamTypePipeBomb>(DmgType) != none || class<DamTypePipeBombA>(DmgType) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 2.0;
		}
		else
		{
			ret = 2.0 + 0.05125 * float(KFPRI.ClientVeteranSkillLevel);
		}
	}
	
	/*else if ( class<DamTypePipeBomb>(DmgType) != none || class<DamTypePipeBombA>(DmgType) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 1.50;
		}
		else
		{
			ret = 1.25 + 0.07 * float(KFPRI.ClientVeteranSkillLevel);
		}
	}*/
	
	else if ( class<DamTypePipeBombS>(DmgType) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 3.00;
		}
		else
		{
			ret = 3.0 + 0.1025 * float(KFPRI.ClientVeteranSkillLevel);
		}
	}

	/*else if ( class<DamTypePipeBombS>(DmgType) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 2.00;
		}
		else
		{
			ret = 1.50 + 0.14 * float(KFPRI.ClientVeteranSkillLevel);
		}
	}*/

	if ( class<DamTypeFrag>(DmgType) != none )
	{
		ret *= 1.75;
	}

	return ret * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
}

static function float DecapDamageModifier(PlayerReplicationInfo PRI, Pawn Victim, class<DamageType> DmgType)
{
	return 2.0;
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
	local float Reduction;
	
	Reduction = 1.0;
	
	if ( class<DamTypeFrag>(DmgType) != none || class<DamTypePipeBomb>(DmgType) != none || class<DamTypePipeBombA>(DmgType) != none ||
		 class<DamTypeM79Grenade>(DmgType) != none || class<DamTypeM32Grenade>(DmgType) != none
		 || class<DamTypeM203Grenade>(DmgType) != none || class<DamTypeRocketImpact>(DmgType) != none || class<DamTypeATMine>(DmgType) != none
		 || class<DamTypeRadioBomb>(DmgType) != none || class<DamTypeLAW>(DmgType) != none || class<DamTypeHHGrenM>(DmgType) != none
		 || class<DamTypeEX41>(DmgType) != none || class<DamTypeRPG>(DmgType) != none || class<DamTypeRXRLDTRocket>(DmgType) != none || class<DamTypeM202A2>(DmgType) != none
		 || class<DamTypeSealSquealMExplosion>(DmgType) != none || class<DamTypeBulkCannonLLI>(DmgType) != none || class<DamTypeRG6Grenade>(DmgType) != none
		 || class<DamTypeSeekerSixMRocket>(DmgType) != none || class<DamTypeSeekerMRocketImpact>(DmgType) != none || class<DamTypeZic3LLI>(DmgType) != none
		 || class<DamTypeZic3LLIAP>(DmgType) != none || class<DamTypeZic3LLIBS>(DmgType) != none || class<DamTypeSig33LLI>(DmgType) != none
		 || class<DamTypeSig33LLIAP>(DmgType) != none || class<DamTypeSig33LLIBS>(DmgType) != none
		 || class<DamTypeBazookaLLI>(DmgType) != none )
	{
		Reduction = 0.40 - 0.01 * float(KFPRI.ClientVeteranSkillLevel);
	}

	return Reduction * Super.ReduceDamage(KFPRI,Injured,Instigator,InDamage,DmgType);
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float ret;
	
	ret = 1.00;
	
	if ( M32GrenadeLauncherM(Other) != none || RG6GrenadeLauncher(Other) != none )
	{
		ret = 1.00 + 0.02 * float(KFPRI.ClientVeteranSkillLevel);
	}
	
	if ( BulkCannonLLI(Other) != none  )
	{
		ret = 1.00 + 0.6;
	}
	
	return ret * Super.GetReloadSpeedModifier(KFPRI,Other);
}

static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	local int ret;
	
	if ( KFPRI.ClientVeteranSkillLevel < 6 )
	{
		ret = 0;
	}
	else if ( KFPRI.ClientVeteranSkillLevel < 36 )
	{
		ret = ((KFPRI.ClientVeteranSkillLevel-1)/5) * 2;
	}
	else
	{
		ret = 15;
	}
	
	return ret + Super.AddCarryMaxWeight(KFPRI);
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float ret;

	ret  = 1.0;
	
	if ( Item == class'PipeBombPickup' || Item == class'PipeBombPickupA' )
		ret = FMax(0.12 - (0.01 * float(KFPRI.ClientVeteranSkillLevel)),0.01f); // Up to 99% discount on PipeBomb

	else if ( Item == class'M79Pickup' || Item == class'M32Pickup'
		 || Item == class'LAWPickup' || Item == class'M4203Pickup' || Item == class'M4203Pickup'
		 || Item == class'M79PickupM' || Item == class'M32PickupM' || Item == class'RG6Pickup'
		 || Item == class'LAWPickupM' || Item == class'BulkCannonLLIPickup' || Item == class'UHolyHandGrenadeMPickup' || Item == class'M202A2Pickup' || Item == class'RXRLDTPickup'
		 || Item == class'EX41Pickup' || Item == class'RPGPickup' || Item == class'OpticalDeaglePickupF'
		 || Item == class'WColtPickup' || Item == class'SealSquealMPickup' || Item == class'WFieldCannonPickup'
		 || Item == class'AN94SAPickup' || Item == class'BazookaLLIPickup' || Item == class'WZic3LLIPickup' 
		 || Item == class'WSig33LLIPickup' )
	{
		ret = GetDefaultCostScaling(KFPRI.ClientVeteranSkillLevel);
	}
	
	if ( Item == class'RadioBombPickup' || Item == class'SelfDestructPickup' || Item == class'ATMinePickup' )
	{
		ret = 0.10;
	}

	if ( Item == class'Vest' )
	{
		ret *= 0.5;
	}

	return ret;
}

// Change the cost of particular ammo
static function float GetAmmoCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'PipeBombPickup' || Item == class'PipeBombPickupA' )
		return FMax(0.12 - (0.01 * float(KFPRI.ClientVeteranSkillLevel)),0.01f); // Up to 99% discount on PipeBomb

	if ( Item == class'RadioBombPickup' || Item == class'ATMinePickup' )
		return 0.10;

	return 1.0;
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'StickyNade';
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	local string weapon;
	local Inventory I;

	Super.AddDefaultInventory(KFPRI,P);

	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;

	if ( SRPlayerReplicationInfo(KFPRI).bRespawned )
		return;
		
	SRPlayerReplicationInfo(KFPRI).bRespawned = true;

	if ( KFPRI.ClientVeteranSkillLevel > 5 && Mid(weapon, 6, 1) != "A" )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.PipeBombExplosive", GetCostScaling(KFPRI, class'PipeBombPickup'));

	if ( KFPRI.ClientVeteranSkillLevel > 5 && Mid(weapon, 6, 1) == "A" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.PipeBombExplosiveA", GetCostScaling(KFPRI, class'PipeBombPickupA'));

	if ( (KFPRI.ClientVeteranSkillLevel > 0 && KFPRI.ClientVeteranSkillLevel < 11
		|| KFPRI.ClientVeteranSkillLevel > 20 && KFPRI.ClientVeteranSkillLevel < 31) && Mid(weapon, 6, 1) != "R" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.M79GrenadeLauncherM", GetCostScaling(KFPRI, class'M79PickupM'));
		
	/*if ( KFPRI.ClientVeteranSkillLevel > 35 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SelfDestruct", GetCostScaling(KFPRI, class'SelfDestructPickup'));*/
		
	if ( KFPRI.ClientVeteranSkillLevel > 10 && KFPRI.ClientVeteranSkillLevel < 16 )
	{
		for(I=P.Inventory; I!=none; I=I.Inventory)
		{
			if ( M79GrenadeLauncherM(I) != none )
			{
				M79GrenadeLauncherM(I).AddAmmo(6,0);
				break;
			}
		}
	}
	
	if ( (KFPRI.ClientVeteranSkillLevel > 10 && KFPRI.ClientVeteranSkillLevel < 16
		|| KFPRI.ClientVeteranSkillLevel > 20 && KFPRI.ClientVeteranSkillLevel < 26
		|| KFPRI.ClientVeteranSkillLevel > 30) && Mid(weapon, 6, 1) != "R" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.M32GrenadeLauncherM", GetCostScaling(KFPRI, class'M32PickupM'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 25 && Mid(weapon, 6, 1) != "R" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.RPG", GetCostScaling(KFPRI, class'RPGPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 25 && KFPRI.ClientVeteranSkillLevel < 31 )
	{
		for(I=P.Inventory; I!=none; I=I.Inventory)
		{
			if ( M79GrenadeLauncherM(I) != none )
			{
				M79GrenadeLauncherM(I).AddAmmo(6,0);
				break;
			}
		}
	}
	
	if ( (KFPRI.ClientVeteranSkillLevel > 35 
		|| KFPRI.ClientVeteranSkillLevel > 15 && KFPRI.ClientVeteranSkillLevel < 21) && Mid(weapon, 6, 1) != "R" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.EX41GrenadeLauncher", GetCostScaling(KFPRI, class'EX41Pickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 15 && KFPRI.ClientVeteranSkillLevel < 21
		|| KFPRI.ClientVeteranSkillLevel > 35 )
	{
		for(I=P.Inventory; I!=none; I=I.Inventory)
		{
			if ( EX41GrenadeLauncher(I) != none )
			{
				EX41GrenadeLauncher(I).AddAmmo(9,0);
				break;
			}
		}
	}
	
	if( Mid(weapon, 6, 1) == "R" )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.RG6GrenadeLauncher", GetCostScaling(KFPRI, class'RG6Pickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SeekerSixMRocketLauncher", GetCostScaling(KFPRI, class'SeekerSixMPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.GrenadePistolLLI", GetCostScaling(KFPRI, class'GrenadePistolLLIPickup'));
	}
	
	if( Mid(weapon, 6, 1) == "M" )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.GrenadePistolLLI", GetCostScaling(KFPRI, class'GrenadePistolLLIPickup'));
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 35 )
		P.ShieldStrength += 100;
}

static function string GetCustomLevelInfo( byte Level )
{
	local string S;
	local float Add;
	
	if ( Level < 6 )
	{
		Add = 1.0;
	}
	else
	{
		Add = 1.0 + 0.03125 * float(Level);
	}
	
	S = "+" $ GetPercentStr(Add) $ default.PerkDescription[0];
	
	//S = "+" $ GetPercentStr(FMax(0.50,0.25 + 0.05 * float(Level))) $ default.PerkDescription[0];
	
	S = S $ GetPercentStr(0.60 + 0.01 * float(Level)) $ default.PerkDescription[1];
	
	S = S $ default.PerkDescription[2] $ string(5+Level) $ default.PerkDescription[3];
	
	S = S $ default.PerkDescription[2] $ string(5+Level/2) $ default.PerkDescription[4];
	
	S = S $ GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[5];
	
	S = S $ GetPercentStr(FMin(0.99,0.88 + 0.01*float(Level))) $ default.PerkDescription[6];
	
	S = S $ default.PerkDescription[7] $ string(Max(0,(Level-1)/5)) $ default.PerkDescription[8];
	
	if ( Level < 6 )
	{
		S = S $ default.PerkDescription[9];
	}
	else
	{
		if ( Level > 5 )
		{
			if ( Level < 36 )
			{
				Add = 2.0 * float((Level-1)/5);
			}
			else
			{
				Add = 15.0;
			}
			
			S = S $ default.PerkDescription[24] $ string(int(Add+15)) $ default.PerkDescription[11];
		}

		if ( Level > 5 )
		{
			Add = 0.10;
			
			if ( Level > 15 )
			{
				Add += 0.05;
			}
			if ( Level > 25 )
			{
				Add += 0.05;
			}
			if ( Level > 35 )
			{
				Add += 0.05;
			}
			
			S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[10];
		}
		
		if ( Level > 15 )
		{
			Add = 0.05;
			
			if ( Level > 30 )
			{
				Add = 0.10;
			}
			
			S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[12];
		}
		
		if ( Level > 20 )
		{
			Add = 0.40;
			
			if ( Level > 30 )
			{
				Add = 0.65;
			}
			
			S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[13];
		}
		
		if ( Level > 30 )
		{
			Add = 16.0;
			
			if ( Level > 35 )
			{
				Add = 24.0;
			}
			
			S = S $ default.PerkDescription[14] $ string(int(Add)) $ default.PerkDescription[15];
		}
	}
	
	S = S $ default.PerkDescription[16];
	
	if ( Level < 6 )
	{
		S = S $ default.PerkDescription[9];
	}
	else
	{
		S = S $ default.PerkDescription[16+(Level-1)/5];
	}
	
	return S;
}

static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI, class<KFMonster> MonsterClass)
{
	local float ret;
	
	ret = 0.65;
	
	if ( class<DKFleshPoundNew>(MonsterClass) != none
	|| class<DKFleshPoundNewP>(MonsterClass) != none
	|| class<DKFleshpoundKF2DT>(MonsterClass) != none
	|| class<ZombieFleshPound_XMasSR>(MonsterClass) != none
	|| class<ZombieFleshPound_XMasSRP>(MonsterClass) != none )
	{
		ret = 1.00;
	}
	else if ( class<DKBrute>(MonsterClass) != none || class<DKEndy>(MonsterClass) != none || class<TankerBruteDT>(MonsterClass) != none )
	{
		ret = 1.00;
	}
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
}

defaultproperties
{
	PerkDescription(0)=" урона взрывчаткой и S&W M29|"
	PerkDescription(1)=" сопротивление к урону от взрывов|"
	PerkDescription(2)="Носит "
	PerkDescription(3)=" гранат|"
	PerkDescription(4)=" мин|"
	PerkDescription(5)=" скидка на гранатометы и S&W M29|"
	PerkDescription(6)=" скидка на мины|"
	PerkDescription(7)="Ранг "
	PerkDescription(8)=", бонусы:|"
	PerkDescription(9)="Нет|"
	PerkDescription(10)=" к запасу патронов|"
	PerkDescription(11)=" блоков веса|"
	PerkDescription(12)=" к скорости бега|"
	PerkDescription(13)=" скорости восстановления шприца|"
	PerkDescription(14)="Видит здоровье монстров с "
	PerkDescription(15)=" метров|"
	PerkDescription(16)="Особенности перка:|Гранаты прилипают к монстрам|Стартовый инвентарь:|"
	PerkDescription(17)="M79 и мины"
	PerkDescription(18)="Milkor MGL-140, мины"
	PerkDescription(19)="EX-41, мины"
	PerkDescription(20)="Milkor MGL-140, М79, мины"
	PerkDescription(21)="РПГ-7, М79, мины"
	PerkDescription(22)="РПГ-7, Milkor MGL-140, мины"
	PerkDescription(23)="РПГ-7, Milkor, EX-41, мины, броня"
	PerkDescription(24)="Может переносить до "

	PerkIndex=6

	IconMat1 = Texture'SunriseHUD.Icons.Perk_Demolition_Green'
	IconMat2 = Texture'SunriseHUD.Icons.Perk_Demolition_Orange'
	IconMat3 = Texture'SunriseHUD.Icons.Perk_Demolition_Blue'
	IconMat4 = Texture'SunriseHUD.Icons.Perk_Demolition_Purple'
	IconMat5 = Texture'SunriseHUD.Icons.Perk_Demolition_Red'
	IconMat6 = Texture'SunriseHUD.Icons.Perk_Demolition_Silver'
	IconMat7 = Texture'SunriseHUD.Icons.Perk_Demolition_Dark'
	IconMat8 = Texture'SunriseHUD.Icons.Perk_Demolition_Gold'
	IconMat9 = Texture'SunriseHUD.Icons.Perk_Demolition_Master'
	IconMat10 = Texture'SunriseHUD.Icons.Perk_Demolition_Elite'

	VeterancyName="Подрывник"
	Requirements(0)="Нанести %x повреждений взрывами или S&W M29"

	SRLevelEffects(0)="5% extra Explosives damage|25% resistance to Explosives|10% discount on Explosives|75% off Remote Explosives"
	SRLevelEffects(1)="10% extra Explosives damage|30% resistance to Explosives|20% increase in grenade capacity|Can carry 3 Remote Explosives|20% discount on Explosives|78% off Remote Explosives"
	SRLevelEffects(2)="20% extra Explosives damage|35% resistance to Explosives|40% increase in grenade capacity|Can carry 4 Remote Explosives|30% discount on Explosives|81% off Remote Explosives"
	SRLevelEffects(3)="30% extra Explosives damage|40% resistance to Explosives|60% increase in grenade capacity|Can carry 5 Remote Explosives|40% discount on Explosives|84% off Remote Explosives"
	SRLevelEffects(4)="40% extra Explosives damage|45% resistance to Explosives|80% increase in grenade capacity|Can carry 6 Remote Explosives|50% discount on Explosives|87% off Remote Explosives"
	SRLevelEffects(5)="50% extra Explosives damage|50% resistance to Explosives|100% increase in grenade capacity|Can carry 7 Remote Explosives|60% discount on Explosives|90% off Remote Explosives|Spawn with a Pipe Bomb"
	SRLevelEffects(6)="60% extra Explosives damage|55% resistance to Explosives|120% increase in grenade capacity|Can carry 8 Remote Explosives|70% discount on Explosives|93% off Remote Explosives|Spawn with an M79 and Pipe Bomb"
	CustomLevelInfo="%s extra Explosives damage|%r resistance to Explosives|120% increase in grenade capacity|Can carry %x Remote Explosives|%y discount on Explosives|%d off Remote Explosives|Spawn with an M79 and Pipe Bomb"
}
