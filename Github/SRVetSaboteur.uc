class SRVetSaboteur extends SRVeterancyTypes
	abstract;

static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	switch( CurLevel )
	{
	case 0:
		FinalInt = 5000;
		break;
	case 1:
		FinalInt = 15000;
		break;
	case 2:
		FinalInt = 30000;
		break;
	case 3:
		FinalInt = 60000;
		break;
	case 4:
		FinalInt = 120000;
		break;
	case 5:
		FinalInt = 250000;
		break;
	case 6:
		FinalInt = 500000;
		break;
	case 7:
		FinalInt = 1000000;
		break;
	case 8:
		FinalInt = 2000000;
		break;
	case 9:
		FinalInt = 4000000;
		break;
	case 10:
		FinalInt = 6000000;
		break;
	case 11:
		FinalInt = 8000000;
		break;
	case 12:
		FinalInt = 13000000;
		break;
	case 13:
		FinalInt = 18000000;
		break;
	case 14:
		FinalInt = 23000000;
		break;
	case 15:
		FinalInt = 26000000;
		break;
	case 16:
		FinalInt = 34000000;
		break;
	case 17:
		FinalInt = 42000000;
		break;
	case 18:
		FinalInt = 50000000;
		break;
	case 19:
		FinalInt = 58000000;
		break;
	case 20:
		FinalInt = 66000000;
		break;
	case 21:
		FinalInt = 77250000;
		break;
	case 22:
		FinalInt = 89250000;
		break;
	case 23:
		FinalInt = 102000000;
		break;
	case 24:
		FinalInt = 115500000;
		break;
	case 25:
		FinalInt = 129750000;
		break;
	case 26:
		FinalInt = 144250000;
		break;
	case 27:
		FinalInt = 160500000;
		break;
	case 28:
		FinalInt = 177000000;
		break;
	case 29:
		FinalInt = 194250000;
		break;
	case 30:
		FinalInt = 212250000;
		break;
	case 31:
		FinalInt = 231000000;
		break;
	case 32:
		FinalInt = 253500000;
		break;
	case 33:
		FinalInt = 276000000;
		break;
	case 34:
		FinalInt = 298500000;
		break;
	case 35:
		FinalInt = 321000000;
		break;
	case 36:
		FinalInt = 343500000;
		break;
	case 37:
		FinalInt = 366000000;
		break;
	case 38:
		FinalInt = 388500000;
		break;
	case 39:
		FinalInt = 418500000;
		break;
	case 40:
		FinalInt = 450000000;
		break;
	case 41:
		FinalInt = 1000000000;
		break;
	default:
		FinalInt = 5500000+GetDoubleScaling(CurLevel,500000);
	}
	return Min(StatOther.RSmgDamageStat,FinalInt);
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
	return Min(StatOther.RSmgDamageStat,FinalInt);
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
	WholeReq[1] = 219000000;
	StartReq[2] =  15000000;
	WholeReq[2] = 225000000;
	
	FinalInt = int(ArythmProgression(CurLevel,StartReq,WholeReq));
	
	return FinalInt;
}*/

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	local float ret;
	
	ret = 1.0;
	
	if( class<SRWeaponDamageType>(DmgType).default.bSaboteur )
	{
		ret = 1.60 + 0.01 * float(KFPRI.ClientVeteranSkillLevel);
	}

	return ret * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
}

static function class<DamageType> GetMAC10DamageType(KFPlayerReplicationInfo KFPRI)
{
	return class'DamTypeMAC10MPSmg';
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'StunningNade';
}

static function bool CanBeGrabbed(KFPlayerReplicationInfo KFPRI, KFMonster Other)
{
	if ( KFPRI.ClientVeteranSkillLevel > 5 )
		return !( Other.Isa('ZombieClot') || Other.Isa('DKClot') || Other.Isa('ZombieClot_XMasSR') );
	return true;
}

static function float GetMeleeMovementSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
	return 0.02;
}

static function float GetMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
	return 1.20 + 0.01 * float(KFPRI.ClientVeteranSkillLevel/2);
}

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local SRPlayerReplicationInfo SRPRI;
	
	local float ret;
	
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	
	ret = 0.00;
	
	if ( Mac10MPM(Other) != none 
	|| HornetGRifle(Other) != none  
	|| AFS12a(Other) != none 
	|| UMP45SubmachineGun(Other) != none 
	|| Saiga12SAAutoShotgun(Other) != none
	|| AK74uAssaultRifle(Other) != none 
	|| Groza14SAAssaultRifle(Other) != none 
	|| ThompsonNew(Other) != none 
	|| PP19GrenadeRifle(Other) != none
	|| P90DT(Other) != none 
	|| P57LLI(Other) != none 
	|| PP19GrenadeRifle(Other) != none 
	|| OC14AssaultRifle(Other) != none
	|| FN2000SAssaultRifle(Other) != none
	|| Glock18cLLI(Other) != none 
	|| VALDTAssaultRifle(Other) != none 
	|| MP5MMedicGunM(Other) != none 
	|| HKMP7LLI(Other) != none 
	|| MedFMG9SA(Other) != none
	|| (KrissSVSA(Other) != none && !SRPRI.HasSkinGroup("Cronos"))
	|| AK47SAssaultRifleM(Other) != none 
	|| HKG36CSAAssaultRifle(Other) != none 
	|| P416AssaultRifle(Other) != none 
	|| AEK971AssaultRifle(Other) != none 
	|| ASVALSAAssaultRifle(Other) != none 
	|| P902DT(Other) != none 
	|| VSSDTS(Other) != none 
	|| DualAY69SA(Other) != none 
	|| VereskSAAssaultRifle(Other) != none )
	{
		ret = 0.25 + 0.015 * float(KFPRI.ClientVeteranSkillLevel);
	}
		
	if (KrissSVSA(Other) != none && SRPRI.HasSkinGroup("Cronos"))	
	{
		ret = 2.0;
	}
	/*if ( PP19GrenadeRifle(Other) != none )
	{
		ret *= 0.50;
	}*/

	ret += 1.00;

	return ret;
}

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	local float ret;
	
	ret = 0.00;
	
	if ( Frag1Ammo(Other) != none )
	{
		return 0.4;
	}

	if ( FN2000MgAmmo(Other) != none
	|| Armacham203Ammo(Other) != none
	|| FNC30M203Ammo(Other) != none  )
	{
			ret = 0.0;
	}

	if ( Mac10Ammo(Other) != none  
		|| HornetGAmmo(Other) != none 
		|| AFS12Ammo(Other) != none 
		|| Saiga12SAAmmo(Other) != none 
		|| UMP45Ammo(Other) != none 
		|| Glock18cLLIAmmo(Other) != none
		|| ThompsonNewAmmo(Other) != none 
		|| P90DTAmmo(Other) != none 
		|| P57LLIAmmo(Other) != none 
		|| PP19Ammo(Other) != none
		|| VALDTAmmo(Other) != none 
		|| HKMP7LLIAmmo(Other) != none 
		|| MedFMG9SAAmmo(Other) != none 
		|| MP5MAmmoM(Other) != none 
		|| OC14Ammo(Other) != none 
		|| FN2000SAmmo(Other) != none 
		|| VSSDTSAmmo(Other) != none
		|| HKG36CSAAmmo(Other) != none 
		|| P416Ammo(Other) != none 
		|| AEK971Ammo(Other) != none 
		|| (KrissSVSAAmmo(Other) != none)
		|| AK47SAmmo(Other) != none 
		|| KrissSVSAAltAmmo(Other) != none 
		|| ASVALSAAmmo(Other) != none 
		|| DualAY69SAAmmo(Other) != none 
		|| VereskSAAmmo(Other) != none 
		|| P902DTAmmo(Other) != none)
	{
		ret = 0.25 + 0.015 * float(KFPRI.ClientVeteranSkillLevel);
	}
	/*if ( PP19Ammo(Other) != none )
	{
		ret *= 0.50;
	}*/

	ret += 1.00;

	return ret * Super.GetAmmoPickupMod(KFPRI,Other);
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local SRPlayerReplicationInfo SRPRI;
	
	local float ret;
	
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	
	ret = 0.0;
	
	if ( AmmoType == class'GrenadePistolLLILAmmo'
		|| AmmoType == class'FNC30M203Ammo'
		|| AmmoType == class'Armacham203Ammo' ) return ret;
	
	if ( AmmoType == class'FragAmmo' || AmmoType == class'Frag1Ammo' )
	{
		ret = 0.0 + 0.2 * float(KFPRI.ClientVeteranSkillLevel/2);
	}
	else if ( AmmoType == class'TacticalMineAmmo' )
	{
		ret = 0.0 + 0.5 * float(KFPRI.ClientVeteranSkillLevel/3);
	}
	else if ( AmmoType == class'Mac10Ammo' 
			|| AmmoType == class'HornetGAmmo' 
			|| AmmoType == class'AFS12Ammo' 
			|| AmmoType == class'Saiga12SAAmmo' 
			|| AmmoType == class'UMP45Ammo' 
			|| AmmoType == class'AK74uAmmo' 
			|| AmmoType == class'Groza14SAAmmo'
			|| AmmoType == class'ThompsonNewAmmo' 
			|| AmmoType == class'PP19Ammo' 
			|| AmmoType == class'P902DTAmmo'
			|| AmmoType == class'P90DTAmmo' 
			|| AmmoType == class'P57LLIAmmo' 
			|| AmmoType == class'VereskSAAmmo'
			|| AmmoType == class'Glock18cLLIAmmo' 
			|| AmmoType == class'VALDTAmmo' 
			|| AmmoType == class'HKG36CSAAmmo' 
			|| AmmoType == class'P416Ammo' 
			|| AmmoType == class'AEK971Ammo' 
			|| (AmmoType == class'KrissSVSAAmmo' && !SRPRI.HasSkinGroup("Cronos"))
			|| AmmoType == class'AK47SAmmo'
			|| AmmoType == class'KrissSVSAAltAmmo'
			|| AmmoType == class'DualAY69SAAmmo'
			|| AmmoType == class'HKMP7LLIAmmo' 
			|| AmmoType == class'MedFMG9SAAmmo' 
			|| AmmoType == class'MP5MAmmoM' 
			|| AmmoType == class'OC14Ammo' 
			|| AmmoType == class'FN2000SAmmo' 
			|| AmmoType == class'ASVALSAAmmo' 
			|| AmmoType == class'VSSDTSAmmo' )
	{
		ret = 0.25 + 0.015 * float(KFPRI.ClientVeteranSkillLevel);
	}
	else if (AmmoType == class'KrissSVSAAmmo' && SRPRI.HasSkinGroup("Cronos"))
	{
		ret = 3.03;
	}
	else
	{
		ret = Super.AddExtraAmmoFor(KFPRI,AmmoType);
		return ret;
	}
		
	/*if ( AmmoType == class'PP19Ammo' )
	{
		ret *= 0.50;
	}*/
	
	ret += 1.00;

	return ret;
}

static function float GetFireSpeedMod(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
	local float ret;
	
	ret = 1.0;
	
	if ( Mac10MP(Other) != none 
		|| HornetGRifle(Other) != none 
		|| PP19GrenadeRifle(Other) != none 
		|| ASVALSAAssaultRifle(Other) != none
		|| UMP45SubmachineGun(Other) != none 
		|| AK74uAssaultRifle(Other) != none 
		|| Groza14SAAssaultRifle(Other) != none 
		|| ThompsonNew(Other) != none 
		|| VereskSAAssaultRifle(Other) != none
		|| P90DT(Other) != none 
		|| P57LLI(Other) != none 
		|| Glock18cLLI(Other) != none 
		|| VALDTAssaultRifle(Other) != none 
		|| DualAY69SA(Other) != none
		|| MP5MMedicGunM(Other) != none 
		|| HKMP7LLI(Other) != none 
		|| MedFMG9SA(Other) != none 
		|| OC14AssaultRifle(Other) != none 
		|| HKG36CSAAssaultRifle(Other) != none 
		|| P416AssaultRifle(Other) != none 
		|| AEK971AssaultRifle(Other) != none 
		|| P902DT(Other) != none
		|| KrissSVSA(Other) != none
		|| AK47SAssaultRifleM(Other) != none )
	{
		ret = 1.2 + 0.02 * float(KFPRI.ClientVeteranSkillLevel);
	}

	return ret * Super.GetFireSpeedMod(KFPRI,Other);
}

static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil)
{
	Recoil = 0.45 - 0.01 * float(KFPRI.ClientVeteranSkillLevel);
	return Recoil;
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	if ( Mac10MP(Other) != none )
	{
		return 1.75 * Super.GetReloadSpeedModifier(KFPRI,Other);
	}
	if ( HornetGRifle(Other) != none )
	{
		return 1.45 * Super.GetReloadSpeedModifier(KFPRI,Other);
	}
	return Super.GetReloadSpeedModifier(KFPRI,Other);
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
	local float Reduction;
	
	Reduction = 1.00;

	if ( class<DamTypePoisonS>(DmgType) != none )
	{
		Reduction = 0.80 - 0.01 * float(KFPRI.ClientVeteranSkillLevel);
		Goto SetReduction;
	}
	
SetReduction:
	
	return Reduction * Super.ReduceDamage(KFPRI,Injured,Instigator,InDamage,DmgType);
}
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float ret;
	
	ret = 1.0;
	
	if ( Item == class'Mac10Pickup' 
		|| Item == class'HornetGPickup'
		|| Item == class'PP19Pickup' 
		|| Item == class'AFS12Pickup' 
		|| Item == class'Saiga12SAPickup'
		|| Item == class'ThompsonNewPickup' 
		|| Item == class'UMP45Pickup' 
		|| Item == class'AK74uPickup' 
		|| Item == class'Groza14SAPickup' 
		|| Item == class'VSSDTSPickup'
		|| Item == class'TacticalMinePickup' 
		|| Item == class'P90DTPickup' 
		|| Item == class'P57LLIPickup' 
		|| Item == class'OC14PickupS' 
		|| Item == class'FN2000SPickup'
		|| Item == class'Glock18cLLIPickup' 
		|| Item == class'MP5MPickupM' 
		|| Item == class'HKMP7LLIPickup' 
		|| Item == class'MedFMG9SAPickup' 
		|| Item == class'P902DTPickup'
		|| Item == class'OC14Pickup' 
		|| Item == class'HKG36CSAPickup' 
		|| Item == class'P416Pickup' 
		|| Item == class'AEK971Pickup' 
		|| Item == class'ASVALSAPickup' 
		|| Item == class'DualAY69SAPickup' 
		|| Item == class'KrissSVSAPickup' 
		|| Item == class'AK47SPickupM' )
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
	if ( Item == class'TacticalMinePickup' )
	{
		return GetDefaultCostScaling(KFPRI.ClientVeteranSkillLevel);
	}
	return 1.0;
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	local Inventory I;
	local string weapon;
	local SRPlayerReplicationInfo SRPRI;
	
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	
	Super.AddDefaultInventory(KFPRI,P);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	
	if ( SRPlayerReplicationInfo(KFPRI).bRespawned )
		return;
		
	SRPlayerReplicationInfo(KFPRI).bRespawned = true;
		
	if ( KFPRI.ClientVeteranSkillLevel > 5 && KFPRI.ClientVeteranSkillLevel < 21 || KFPRI.ClientVeteranSkillLevel > 35 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.MAC10MPM", GetCostScaling(KFPRI, class'MAC10PickupM'));

	if ( KFPRI.ClientVeteranSkillLevel > 10 && KFPRI.ClientVeteranSkillLevel < 31 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.UMP45SubmachineGun", GetCostScaling(KFPRI, class'UMP45Pickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 30 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AK74uAssaultRifle", GetCostScaling(KFPRI, class'AK74uPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 15 )
		KFHumanPawn(P).CreateInventoryVeterancy("Masters.TacticalMineExplosive", GetCostScaling(KFPRI, class'TacticalMinePickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 20 && Mid(weapon, 8, 1) != "W" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.PP19GrenadeRifle", GetCostScaling(KFPRI, class'PP19Pickup'));
		
	if (Mid(weapon, 8, 1) == "V")
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.VSSDTS", GetCostScaling(KFPRI, class'VSSDTSPickup'));
	}	
	if (Mid(weapon, 8, 1) == "W")
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.P902DT", GetCostScaling(KFPRI, class'P902DTPickup'));
	}

	if (SRPRI.HasSkinGroup("Cronos"))
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.KrissSVSA", GetCostScaling(KFPRI, class'KrissSVSAPickup'));
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 25 )
	{
		if (Mid(weapon, 8, 1) == "9" || Mid(weapon, 8, 1) == "I")
		{
			KFHumanPawn(P).CreateInventoryVeterancy("Mswp.Saiga12SAAutoShotgun", GetCostScaling(KFPRI, class'Saiga12SAPickup'));
		}
		else
			KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AFS12a", GetCostScaling(KFPRI, class'AFS12Pickup'));
	}
		

	if ( KFPRI.ClientVeteranSkillLevel > 35 )
		P.ShieldStrength += 100;
		
	if ( KFPRI.ClientVeteranSkillLevel > 35 )
	{
		for(I=P.Inventory; I!=none; I=I.Inventory)
		{
			if ( Frag1_(I) != none )
			{
				Frag1_(I).AddAmmo(2,0);
			}
			if ( MAC10MPM(I) != none )
			{
				MAC10MPM(I).AddAmmo(140,0);
			}
		}
	}
}

static function string GetCustomLevelInfo( byte Level )
{
	local string S;
	local float Add;

	S = "+" $ GetPercentStr(0.60 + 0.01 * float(Level)) $ default.PerkDescription[0];
	
	S = S $ "+" $ GetPercentStr(0.20 + 0.02 * float(Level)) $ default.PerkDescription[1];
	
	S = S $ "+" $ GetPercentStr(0.25 + float(int((0.015 * float(Level))*100.0))*0.01) $ default.PerkDescription[2];
	
	S = S $ GetPercentStr(0.55 + 0.01 * float(Level)) $ default.PerkDescription[3];
	
	S = S $ "+" $ GetPercentStr(0.20 + 0.01 * float(Level/2)) $ default.PerkDescription[4];
	
	S = S $ default.PerkDescription[5] $ string(5+Level/2) $ default.PerkDescription[6];
	
	S = S $ default.PerkDescription[5] $ string(2+Level/3) $ default.PerkDescription[26];
	
	S = S $ GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[7];
	
	if ( Level > 5 )
	{
		S = S $ default.PerkDescription[10];
	}

	S = S $ default.PerkDescription[8] $ string(Max(0,(Level-1)/5)) $ default.PerkDescription[9];
	
	if ( Level < 6 )
	{
		S = S $ default.PerkDescription[11];
	}
	else
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
		
		if ( Level > 20 )
		{
			Add = 0.40;
			
			if ( Level > 30 )
			{
				Add = 0.65;
			}
			
			S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[14];
		}
		
		if ( Level > 30 )
		{
			Add = 16.0;
			
			if ( Level > 35 )
			{
				Add = 24.0;
			}
			
			S = S $ default.PerkDescription[15] $ string(int(Add)) $ default.PerkDescription[16];
		}
	}
	
	S = S $ default.PerkDescription[17];
	
	S = S $ default.PerkDescription[18+Max(0,(Level-1)/5)];
	
	return S;
}

static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI, class<KFMonster> MonsterClass)
{
	local float ret;
	
	ret = 0.7;
	
	if ( class<DKShiver>(MonsterClass) != none || class<DKShiverP>(MonsterClass) != none )
	{
		ret = 1.00;
		//return 2.50 * Super.GetMoneyReward(SRPRI,MonsterClass);
	}
	
	if ( class<DKCrawler>(MonsterClass) != none )
	{
		ret = 1.00;
		//return 1.50 * Super.GetMoneyReward(SRPRI,MonsterClass);
	}
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
	//return Super.GetMoneyReward(SRPRI,MonsterClass);
}

defaultproperties
{
	PerkDescription(0)=" повреждений пистолетами-пулеметами|"
	PerkDescription(1)=" к скорости стрельбы из пистолетов-пулеметов|"
	PerkDescription(2)=" к вместимости магазина пистолетов-пулеметов|"
	PerkDescription(3)=" уменьшение отдачи при использовании любого оружия|"
	PerkDescription(4)=" скорости перемещения|"
	PerkDescription(5)="Может переносить "
	PerkDescription(6)=" гранат|"
	PerkDescription(7)=" скидка на пистолеты-пулеметы и тактические мины|"
	PerkDescription(8)="Ранг "
	PerkDescription(9)=", бонусы:|"
	PerkDescription(10)="Не может быть схвачен клотами|"
	PerkDescription(11)="Нет|"
	PerkDescription(12)=" к боезапасу не профильного оружия|"
	PerkDescription(13)=" к переносимому весу|"
	PerkDescription(14)=" к скорости восстановления шприца|"
	PerkDescription(15)="Видит здоровье монстров с "
	PerkDescription(16)=" метров|"
	PerkDescription(17)="Особенности перка:|Гранаты оглушают врагов|Двойной урон в спину|Стартовый инвентарь:|"
	PerkDescription(18)="Glock 18C"
	PerkDescription(19)="Glock 18C, MAC-10"
	PerkDescription(20)="Glock 18C, MAC-10, HK UMP-45"
	PerkDescription(21)="Glock 18C, MAC-10, HK UMP-45, Тактические мины"
	PerkDescription(22)="Glock 18C, ПП-19 Бизон, HK UMP-45, Тактические мины"
	PerkDescription(23)="Glock 18C, ПП-19 Бизон, HK UMP-45, Вепрь-12, Тактические мины"
	PerkDescription(24)="Glock 18C, ПП-19 Бизон, АКС-74У, Вепрь-12, Тактические мины"
	PerkDescription(25)="Glock 18C, ПП-19 Бизон, АКС-74У, Вепрь-12, MAC-10 + 2 дополнительные обоймы, Тактические мины, +2 дополнительные гранаты"
	PerkDescription(26)=" тактических мин|"

	PerkIndex=8

	IconMat1 = Texture'SunriseHUD.Icons.Perk_Saboteur_Green'
	IconMat2 = Texture'SunriseHUD.Icons.Perk_Saboteur_Orange'
	IconMat3 = Texture'SunriseHUD.Icons.Perk_Saboteur_Blue'
	IconMat4 = Texture'SunriseHUD.Icons.Perk_Saboteur_Purple'
	IconMat5 = Texture'SunriseHUD.Icons.Perk_Saboteur_1Red'
	IconMat6 = Texture'SunriseHUD.Icons.Perk_Saboteur_Silver'
	IconMat7 = Texture'SunriseHUD.Icons.Perk_Saboteur_Dark'
	IconMat8 = Texture'SunriseHUD.Icons.Perk_Saboteur_Gold'
	IconMat9 = Texture'SunriseHUD.Icons.Perk_Saboteur_Master'
	IconMat10 = Texture'SunriseHUD.Icons.Perk_Saboteur_Elite'
	
    VeterancyName="Диверсант"
    Requirements(0)="Нанести %x поверждений пистолетами-пулеметами"
}