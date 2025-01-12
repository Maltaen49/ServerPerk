class SRVetFieldMedic extends SRVeterancyTypes
	abstract;

static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	switch( CurLevel )
	{
	case 0:
		FinalInt = 50;
		break;
	case 1:
		FinalInt = 187;
		break;
	case 2:
		FinalInt = 375;
		break;
	case 3:
		FinalInt = 750;
		break;
	case 4:
		FinalInt = 1500;
		break;
	case 5:
		FinalInt = 3125;
		break;
	case 6:
		FinalInt = 6250;
		break;
	case 7:
		FinalInt = 12500;
		break;
	case 8:
		FinalInt = 25000;
		break;
	case 9:
		FinalInt = 50000;
		break;
	case 10:
		FinalInt = 75000;
		break;
	case 11:
		FinalInt = 100000;
		break;
	case 12:
		FinalInt = 170000;
		break;
	case 13:
		FinalInt = 240000;
		break;
	case 14:
		FinalInt = 310000;
		break;
	case 15:
		FinalInt = 380000;
		break;
	case 16:
		FinalInt = 480000;
		break;
	case 17:
		FinalInt = 580000;
		break;
	case 18:
		FinalInt = 680000;
		break;
	case 19:
		FinalInt = 780000;
		break;
	case 20:
		FinalInt = 880000;
		break;
	case 21:
		FinalInt = 1030000;
		break;
	case 22:
		FinalInt = 1190000;
		break;
	case 23:
		FinalInt = 1360000;
		break;
	case 24:
		FinalInt = 1540000;
		break;
	case 25:
		FinalInt = 1730000;
		break;
	case 26:
		FinalInt = 1930000;
		break;
	case 27:
		FinalInt = 2140000;
		break;
	case 28:
		FinalInt = 2360000;
		break;
	case 29:
		FinalInt = 2590000;
		break;
	case 30:
		FinalInt = 2830000;
		break;
	case 31:
		FinalInt = 3080000;
		break;
	case 32:
		FinalInt = 3380000;
		break;
	case 33:
		FinalInt = 3680000;
		break;
	case 34:
		FinalInt = 3980000;
		break;
	case 35:
		FinalInt = 4280000;
		break;
	case 36:
		FinalInt = 4580000;
		break;
	case 37:
		FinalInt = 4880000;
		break;
	case 38:
		FinalInt = 5180000;
		break;
	case 39:
		FinalInt = 5580000;
		break;
	case 40:
		FinalInt = 6000000;
		break;
	case 41:
		FinalInt = 12500000;
		break;
	default:
		FinalInt = 100000+GetDoubleScaling(CurLevel,20000);
	}
	return Min(StatOther.RDamageHealedStat,FinalInt);
}

/*static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	FinalInt = PerkLevelRequirement(CurLevel,ReqNum);
	return Min(StatOther.RDamageHealedStat,FinalInt);
}

static function int PerkLevelRequirement(byte CurLevel, byte ReqNum)
{
	local array<float> StartReq,WholeReq;
	local int FinalInt;
	
	StartReq.Insert(0,3);
	WholeReq.Insert(0,3);
	
	StartReq[0] =     8000;
	WholeReq[0] =   100000;
	StartReq[1] =    30000;
	WholeReq[1] =  3650000;
	StartReq[2] =   300000;
	WholeReq[2] =  3750000;
	
	FinalInt = int(ArythmProgression(CurLevel,StartReq,WholeReq));
	
	return FinalInt;
}*/
static function class<DamageType> GetFNC30DamageType(KFPlayerReplicationInfo KFPRI)
{
	return class'DamTypeFNC30Medic';
}

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	local float ret;
	
	ret = 1.0;
	
	if( DmgType == class'DamTypeAugA3SA'
	|| DmgType == class'DamTypeFN2000M'
	|| DmgType == class'DamTypeArmachamAssaultRifle'
	|| DmgType == class'DamTypeFNC30Medic'
	|| DmgType == class'DamTypeHKMP7LLI'
	|| DmgType == class'DamTypeMedFMG9SA'
	|| DmgType == class'DamTypeKrissMSR'
	|| DmgType == class'DamTypeM7A3M'
	|| DmgType == class'DamTypeM7A3MSR'
	|| DmgType == class'DamTypeUSP45MLLI'
	|| DmgType == class'DamTypeWMediShot'
	|| DmgType == class'DamTypeMP5SG' )
	{
		ret = 1.20 + 0.01 * float(KFPRI.ClientVeteranSkillLevel);
	}

	return ret * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
}

static function float EffectsDamageModifer(KFPlayerReplicationInfo PRI, class EffectType)
{
	local float ret;
	if(EffectType == class'DamTypeQuake')	//PseudoGigant: Сила удара замлетресения
		ret=0.300;
	else if(EffectType == class'DamTypeRadiation') // //PseudoGigant: Резист к радиации 
		ret=0.250;
	else if (EffectType == class'RadiationBlur') //PseudoGigant: расстояние до размытия
		ret=0.100;
	else
		ret=1.0;
	return ret;
}
static function float GetHUDCoiff(KFPlayerReplicationInfo KFPRI)
{
	return 1.0 + (0.05 * float(KFPRI.ClientVeteranSkillLevel));
}
static function float GetMeleeMovementSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
	return 0.02;
}
static function float GetSyringeChargeRate(KFPlayerReplicationInfo KFPRI)
{
	return 1.5 + (0.1 * float(KFPRI.ClientVeteranSkillLevel));
}
static function float GetHealPotency(KFPlayerReplicationInfo KFPRI)
{
	return 1.25 + 0.025 * float(KFPRI.ClientVeteranSkillLevel);
}
static function float GetWeldArmorSpeedModifier(SRPlayerReplicationInfo SRPRI)
{
	return 1.33 + 0.017 * float(SRPRI.ClientVeteranSkillLevel);
}

static function float GetWeldSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
	return 1.33 + 0.017 * float(KFPRI.ClientVeteranSkillLevel);
}

static function float GetMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
	return 1.15 + 0.01 * float(KFPRI.ClientVeteranSkillLevel/2);
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
	local float Reduction;
	
	Reduction = 1.00;
	
	if ( class<DamTypeVomit>(DmgType) != none )
	{
		Reduction = 0.60 - 0.01 * float(KFPRI.ClientVeteranSkillLevel);
	}
	
	return Reduction * Super.ReduceDamage(KFPRI,Injured,Instigator,InDamage,DmgType);
}

// Reduce damage when wearing Armor
static function float GetBodyArmorDamageModifier(KFPlayerReplicationInfo KFPRI)
{
	local float value;
	local int level;
	value = 1.0;
	level = 1;
	
	if(KFPRI != none)
		level = KFPRI.ClientVeteranSkillLevel;

	//Добавляем дополнительный X к Броне, иначе слишком хилый будет.
	if(level > 30)
		value /= 5.5;
	else if(level > 25)
		value /= 5.0;
	else if(level > 20)
		value /= 4.5;
	else if(level > 15)
		value /= 4.0;
	else if(level > 10)
		value /= 3.5;
	else if(level > 5)
		value /= 3.0;
	else 
		value /= 2.5;

	return value ;
}
static function int GetMaxArmor(KFPlayerReplicationInfo KFPRI)
{
	local int level;
	level = 1;
	if(KFPRI != none)
		level = KFPRI.ClientVeteranSkillLevel;
	
	if(level > 40)
		return 300;
	else if(level > 39)
		return 200;
	else if(level > 35)
		return 180;
	else if(level > 30)
		return 160;
	else if(level > 25)
		return 140;
	else if(level > 20)
		return 120;

	return 100;

}
static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float ret;
	
	ret = 1.0;

	if(MP7MMedicGun(Other) != none
	|| HKMP7LLI(Other) != none
	|| MedFMG9SA(Other) != none
	|| MP5MMedicGunM(Other) != none
	|| ArmachamAssaultRifle(Other) != none
	|| FNC30AssaultRifle(Other) != none
	|| FN2000MAssaultRifle(Other) != none
	|| WMediShot(Other) != none
	|| M7A3MSRMedicGun(Other) != none
	|| USP45MLLI(Other) != none
	//|| DUSP45MLLI(Other) != none
	|| KrissMSRMedicGun(Other) != none
	|| AugA3SAMedicGun(Other) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 1.6;
		}
		else
		{
			ret = 1.8 + 0.2 * float((KFPRI.ClientVeteranSkillLevel-1)/5);
		}
	}
	return ret;
}

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	local float ret;
	
	ret = 1.0;
	
	if ( StimulatorAmmo(Other) != none || StimulatorLLIAmmo(Other) != none )
	{
			ret = 0.0;
	}

	if ( Frag1Ammo(Other) != none )
	{
		return 0.4;
	}

	if ( MP7MAmmo(Other) != none 
		|| MP5MAmmo(Other) != none
		|| HKMP7LLIAmmo(Other) != none
		|| MedFMG9SAAmmo(Other) != none 
		|| MP5MAmmoM(Other) != none
		|| ArmachamAssaultRifleAmmo(Other) != none
		|| FNC30Ammo(Other) != none
		|| FN2000MAmmo(Other) != none 
		|| USP45MLLIAmmo(Other) != none
		|| WMediShotAmmo(Other) != none 
		|| M7A3MSRAmmo(Other) != none
		|| KrissMSRAmmo(Other) != none 
		|| AugA3SAAmmo(Other) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 1.6;
		}
		else if ( KFPRI.ClientVeteranSkillLevel < 11 )
		{
			ret = 2.0;
		}
		else
		{
			ret = 1.6 + 0.2 * float((KFPRI.ClientVeteranSkillLevel-1)/5);
		}
	}
	if ( FN2000MgAmmo(Other) != none 
		|| RG6LLIAmmo(Other) != none 
		|| Armacham203Ammo(Other) != none
		|| FNC30M203Ammo(Other) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 1.6;
		}
		else if ( KFPRI.ClientVeteranSkillLevel < 11 )
		{
			ret = 2.0;
		}
		else if ( KFPRI.ClientVeteranSkillLevel < 16 )
		{
			ret = 2.5;
		}
		else
		{
			ret = 3.0;
		}
	}


	return ret * Super.GetAmmoPickupMod(KFPRI,Other);
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local SRPlayerReplicationInfo SRPRI;
	
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	
	if ( AmmoType == class'FragAmmo' || AmmoType == class'Frag1Ammo' )
	{
		//log(" => AmmoType: " @ AmmoType);
		if(KFPRI != none)
		{
			if(KFPRI.ClientVeteranSkillLevel < 7)
				return 1.0 + (float(KFPRI.ClientVeteranSkillLevel-1) * 0.2);
			else
				return 1.0 + (float(KFPRI.ClientVeteranSkillLevel/2) / 3.3);
		}
		//return 3.0 + 0.5 * float(KFPRI.ClientVeteranSkillLevel/2);
	}
	
	if (AmmoType == class'RG6LLIAmmo' && (SRPRI.HasSkinGroup("XLocki") || SRPRI.HasSkinGroup("Valdemar")))
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
			return 3.0;
		
		return 1.5 + 0.4 * float((KFPRI.ClientVeteranSkillLevel-1)/5);
	}

	if (( AmmoType == class'StimulatorAmmo' || AmmoType == class'StimulatorLLIAmmo' ) && !SRPRI.HasSkinGroup("XLocki"))
	{
		return 0.0 + 1.0 * FMax(0.0,(KFPRI.ClientVeteranSkillLevel-1)/5);
	}
	else if (( AmmoType == class'StimulatorAmmo' 
		|| AmmoType == class'StimulatorLLIAmmo' ) 
		&& SRPRI.HasSkinGroup("XLocki"))
	{
		return 0.0 + 2.0 * FMax(0.0,(KFPRI.ClientVeteranSkillLevel-1)/5);
	}
	
	if ( AmmoType == class'FN2000MgAmmo' 
		|| (AmmoType == class'RG6LLIAmmo' && !SRPRI.HasSkinGroup("XLocki") && !SRPRI.HasSkinGroup("Valdemar"))
		|| AmmoType == class'Armacham203Ammo' 
		|| AmmoType == class'FNC30M203Ammo')
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
			return 1.5;
		
		return 1.5 + 0.1 * float((KFPRI.ClientVeteranSkillLevel-1)/5);
	}
	
	return Super.AddExtraAmmoFor(KFPRI,AmmoType);
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'SupportHealNade';
}

static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float ret;
	
	ret = 1.0;
	
	if ( Item == class'MP7MPickup' 
	|| Item == class'MP5MPickup'
	|| Item == class'HKMP7LLIPickup' 
	|| Item == class'MP5MPickupM'
	|| Item == class'FN2000MPickup' 
	|| Item == class'Mswp.M7A3MSRPickup'
	|| Item == class'WMediShotPickup' 
	|| Item == class'Vest' 
	|| Item == class'MedFMG9SAPickup'
	|| Item == class'USP45MLLIPickup' 
	|| Item == class'RG6LLIPickup'
	|| Item == class'FN2000MPickupS' 
	|| Item == class'AugA3SAPickup' 
	|| Item == class'M32PickupW' 
	|| Item == class'M32PickupF' 
	|| Item == class'FNC30Pickup'
	|| Item == class'FNC30PickupS'
	|| Item == class'ArmachamAssaultRiflePickup'
	|| Item == class'ArmachamAssaultRiflePickupS' )
	{
		ret = GetDefaultCostScaling(KFPRI.ClientVeteranSkillLevel);
	}

	if ( Item == class'Vest' )
	{
		ret *= 0.5;
	}
	
	return ret;
}

static function float GetAmmoCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float ret;
	
	ret = 1.0;

	if ( Item == class'FN2000MPickupS' 
	|| Item == class'FN2000MPickup' 
	|| Item == class'M32PickupW' 
	|| Item == class'FNC30Pickup'
	|| Item == class'FNC30PickupS'
	|| Item == class'ArmachamAssaultRiflePickup'
	|| Item == class'ArmachamAssaultRiflePickupS' )
	{
		ret *= 0.5;
	}

	return ret;
}

// Give Extra Items as Default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	local string weapon;
	local Inventory I;

	Super.AddDefaultInventory(KFPRI,P);

	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	
	if ( SRPlayerReplicationInfo(KFPRI).bRespawned )
		return;
		
	SRPlayerReplicationInfo(KFPRI).bRespawned = true;
	
	
	if(KFPRI.ClientVeteranSkillLevel > 35)
		P.ShieldStrength = GetMaxArmor(KFPRI);
	else
		P.ShieldStrength = GetMaxArmor(KFPRI)*0.5;
	

	if ( KFPRI.ClientVeteranSkillLevel < 6 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.USP45MLLI", GetCostScaling(KFPRI, class'USP45MLLIPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 5 && KFPRI.ClientVeteranSkillLevel < 16 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.MP5MMedicGunM", GetCostScaling(KFPRI, class'MP5MPickupM'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 10 && KFPRI.ClientVeteranSkillLevel < 21 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.WMediShot", GetCostScaling(KFPRI, class'WMediShotPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 15 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.HKMP7LLI", GetCostScaling(KFPRI, class'HKMP7LLIPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 20 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.M7A3MSRMedicGun", GetCostScaling(KFPRI, class'Mswp.M7A3MSRPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 25 && Mid(weapon, 0, 1) != "1" && Mid(weapon, 0, 1) != "F" )
		KFHumanPawn(P).CreateInventoryVeterancy("Masters.Stimulator", GetCostScaling(KFPRI, class'StimulatorPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 25 && (Mid(weapon, 0, 1) == "1" || Mid(weapon, 0, 1) == "6" || Mid(weapon, 0, 1) == "F") )
		KFHumanPawn(P).CreateInventoryVeterancy("Masters.StimulatorLLI", GetCostScaling(KFPRI, class'StimulatorLLIPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 30 )
	{

		for(I=P.Inventory; I!=none; I=I.Inventory)
		{
			if ( Frag1_(I) != none )
			{
				Frag1_(I).AddAmmo(2,0);
			}
		}
	}
	
	if( Mid(weapon, 0, 1) == "6" )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AugA3SAMedicGun", GetCostScaling(KFPRI, class'AugA3SAPickup'));
	}

	if( Mid(weapon, 0, 1) == "F" )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.M32GrenadeLauncherF", GetCostScaling(KFPRI, class'M32PickupF'));
	}

	if( SRPlayerReplicationInfo(KFPRI).HasSkinGroup("Wapik") )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.M32GrenadeLauncherW", GetCostScaling(KFPRI, class'M32PickupW'));
	}

	if ( SRPlayerReplicationInfo(KFPRI).HasSkinGroup("KTULHU") || SRPlayerReplicationInfo(KFPRI).HasSkinGroup("Valdemar") )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.RG6LLIGrenadeLauncher", GetCostScaling(KFPRI, class'RG6LLIPickup'));
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 35 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.FN2000MAssaultRifle", GetCostScaling(KFPRI, class'FN2000MPickup'));
}
static function string GetCustomLevelInfo( byte Level )
{
	local string S;
	local float Add;

	S = "+" $ GetPercentStr(0.20 + 0.01 * float(Level)) $ default.PerkDescription[0];

	S = S $ "+" $ GetPercentStr(0.5 + 0.1 * float(Level)) $ default.PerkDescription[1];
	
	S = S $ "+" $ GetPercentStr(0.25 + 0.05 * float(Level/2)) $ default.PerkDescription[2];
	
	S = S $ default.PerkDescription[3] $ string(5+Level/2) $ default.PerkDescription[4];
	
	S = S $ GetPercentStr(0.40 + 0.01 * float(Level)) $ default.PerkDescription[5];
	
	S = S $ "+" $ GetPercentStr(0.15 + 0.01 * float(Level/2)) $ default.PerkDescription[6];
	
	S = S $ default.PerkDescription[25] $ GetPercentStr(0.05 * float(Level)) $ default.PerkDescription[26];
	
	Add = 0.60;
	
	if ( Level > 5 )
	{
		Add = 0.80 + 0.20 * float((Level-1)/5);
	}
	
	S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[7];
	
	S = S $ GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[8];
	
	S = S $ default.PerkDescription[9] $ string(Max(0,(Level-1)/5)) $ default.PerkDescription[10];
	
	Add = 2.0;
	
	if ( Level > 5 )
	{
		Add = 3.0 + 1.0 * float((Level-1)/5);
	}
	
	S = S $ string(int(Add)) $ default.PerkDescription[11];
	
	if ( Level > 5 )
	{
		Add = 0.0;
		
		if ( Level > 5 )
		{
			Add += 0.10;
		}
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
		
		S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[12];
		
		if ( Level > 10 )
		{
			Add = 0.0;
			
			if ( Level > 10 )
			{
				Add += 2.0;
			}
			if ( Level > 25 )
			{
				Add += 2.00;
			}
			if ( Level > 35 )
			{
				Add += 2.00;
			}
			
			S = S $ "+" $ string(int(Add)) $ default.PerkDescription[13];
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
	
	S = S $ default.PerkDescription[17+(Level-1)/5];
	
	return S;
}

static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI, class<KFMonster> MonsterClass)
{
	local float ret;
	
	ret = 0.30;
	
	if ( class<DKFleshPoundNew>(MonsterClass) != none || class<DKFleshpoundKF2DT>(MonsterClass) != none || class<ZombieFleshPound_XMasSR>(MonsterClass) != none )
	{
		ret = 0.40;
	}
	if ( class<DKScrake>(MonsterClass) != none )
	{
		ret = 0.40;
	}
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
}

defaultproperties
{
	PerkDescription(0)=" повреждений мед. оружием| "
	PerkDescription(1)=" скорость восстановления шприца|"
	PerkDescription(2)=" эффективности лечения|"
	PerkDescription(3)="Носит"
	PerkDescription(4)=" аптечек|"
	PerkDescription(5)=" сопротивление к желчи блоата|"
	PerkDescription(6)=" скорости бега|"
	PerkDescription(7)=" вместимости магазина|"
	PerkDescription(8)=" скидка на медицинское оружие и броню|"
	PerkDescription(9)="Ранг "
	PerkDescription(10)=", бонусы:|"
	PerkDescription(11)="x прочность брони|"
	PerkDescription(12)=" к запасу патронов|"
	PerkDescription(13)=" ед. переносимого веса|"
	PerkDescription(14)="Видит здоровье монстров с "
	PerkDescription(15)=" метров|"
	PerkDescription(16)="Стартовый инвентарь:|"
	PerkDescription(17)="HK USP 45 Match"
	PerkDescription(18)="HK USP 45 Match, MP7, броня"
	PerkDescription(19)="HK USP 45 Match, MP7, MP5, броня"
	PerkDescription(20)="HK USP 45 Match, Мед дробовик, MP5, броня"
	PerkDescription(21)="HK USP 45 Match, Мед дробовик, M7A3, броня"
	PerkDescription(22)="HK USP 45 Match, Мед дробовик, M7A3, Стимулятор, броня"
	PerkDescription(23)="HK USP 45 Match, Мед дробовик, M7A3, Стимулятор, +2 аптечки, 130 ед брони"
	PerkDescription(24)="HK USP 45 Match, Мед дробовик, M7A3, FN2000 медицинский, Стимулятор, +2 аптечки, 130 ед брони"
	PerkDescription(25)="Видит здоровье и броню игрока дальше на "
	PerkDescription(26)="|"
	
	PerkIndex=0

	IconMat1 = Texture'SunriseHUD.Icons.Perk_Medic_Green'
	IconMat2 = Texture'SunriseHUD.Icons.Perk_Medic_Orange'
	IconMat3 = Texture'SunriseHUD.Icons.Perk_Medic_Blue'
	IconMat4 = Texture'SunriseHUD.Icons.Perk_Medic_Purple'
	IconMat5 = Texture'SunriseHUD.Icons.Perk_Medic_Red'
	IconMat6 = Texture'SunriseHUD.Icons.Perk_Medic_Silver'
	IconMat7 = Texture'SunriseHUD.Icons.Perk_Medic_Dark'
	IconMat8 = Texture'SunriseHUD.Icons.Perk_Medic_Gold'
	IconMat9 = Texture'SunriseHUD.Icons.Perk_Medic_Master'
	IconMat10 = Texture'SunriseHUD.Icons.Perk_Medic_Elite'

	VeterancyName="Медик"
	Requirements[0]="Вылечить %x ед здоровья товарищам по команде"

	SRLevelEffects(0)="10% faster Syringe recharge|10% more potent medical injections|10% less damage from Bloat Bile|10% discount on Body Armor|85% discount on MP7M Medic Gun"
	SRLevelEffects(1)="25% faster Syringe recharge|25% more potent medical injections|25% less damage from Bloat Bile|20% larger MP7M Medic Gun clip|10% better Body Armor|20% discount on Body Armor|87% discount on MP7M Medic Gun"
	SRLevelEffects(2)="50% faster Syringe recharge|25% more potent medical injections|50% less damage from Bloat Bile|5% faster movement speed|40% larger MP7M Medic Gun clip|20% better Body Armor|30% discount on Body Armor|89% discount on MP7M Medic Guns"
	SRLevelEffects(3)="75% faster Syringe recharge|50% more potent medical injections|50% less damage from Bloat Bile|10% faster movement speed|60% larger MP7M Medic Gun clip|30% better Body Armor|40% discount on Body Armor|91% discount on MP7M Medic Guns"
	SRLevelEffects(4)="100% faster Syringe recharge|50% more potent medical injections|50% less damage from Bloat Bile|15% faster movement speed|80% larger MP7M Medic Gun clip|40% better Body Armor|50% discount on Body Armor|93% discount on MP7M Medic Guns"
	SRLevelEffects(5)="150% faster Syringe recharge|50% more potent medical injections|75% less damage from Bloat Bile|20% faster movement speed|100% larger MP7M Medic Gun clip|50% better Body Armor|60% discount on Body Armor|95% discount on MP7M Medic Guns|Spawn with Body Armor"
	SRLevelEffects(6)="200% faster Syringe recharge|75% more potent medical injections|75% less damage from Bloat Bile|25% faster movement speed|100% larger MP7M Medic Gun clip|75% better Body Armor|70% discount on Body Armor||97% discount on MP7M Medic Guns| Spawn with Body Armor and Medic Gun"
	CustomLevelInfo="%s faster Syringe recharge|75% more potent medical injections|75% less damage from Bloat Bile|%r faster movement speed|100% larger MP7M Medic Gun clip|75% better Body Armor|%d discount on Body Armor||%m discount on MP7M Medic Guns| Spawn with Body Armor and Medic Gun"
}
