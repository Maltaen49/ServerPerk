class SRVetCommando extends SRVeterancyTypes
	abstract;

static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	switch( CurLevel )
	{
	case 0:
		if( ReqNum==0 )
			FinalInt = 3;
		else FinalInt = 10000;
		break;
	case 1:
		if( ReqNum==0 )
			FinalInt = 3;
		else FinalInt = 15000;
		break;
	case 2:
		if( ReqNum==0 )
			FinalInt = 6;
		else FinalInt = 30000;
		break;
	case 3:
		if( ReqNum==0 )
			FinalInt = 12;
		else FinalInt = 60000;
		break;
	case 4:
		if( ReqNum==0 )
			FinalInt = 24;
		else FinalInt = 120000;
		break;
	case 5:
		if( ReqNum==0 )
			FinalInt = 50;
		else FinalInt = 250000;
		break;
	case 6:
		if( ReqNum==0 )
			FinalInt = 100;
		else FinalInt = 500000;
		break;
	case 7:
		if( ReqNum==0 )
			FinalInt = 200;
		else FinalInt = 1000000;
		break;
	case 8:
		if( ReqNum==0 )
			FinalInt = 400;
		else FinalInt = 2000000;
		break;
	case 9:
		if( ReqNum==0 )
			FinalInt = 800;
		else FinalInt = 4000000;
		break;
	case 10:
		if( ReqNum==0 )
			FinalInt = 1200;
		else FinalInt = 6000000;
		break;
	case 11:
		if( ReqNum==0 )
			FinalInt = 1600;
		else FinalInt = 8000000;
		break;
	case 12:
		if( ReqNum==0 )
			FinalInt = 2600;
		else FinalInt = 13000000;
		break;
	case 13:
		if( ReqNum==0 )
			FinalInt = 3600;
		else FinalInt = 18000000;
		break;
	case 14:
		if( ReqNum==0 )
			FinalInt = 4600;
		else FinalInt = 23000000;
		break;
	case 15:
		if( ReqNum==0 )
			FinalInt = 5200;
		else FinalInt = 26000000;
		break;
	case 16:
		if( ReqNum==0 )
			FinalInt = 6800;
		else FinalInt = 34000000;
		break;
	case 17:
		if( ReqNum==0 )
			FinalInt = 8400;
		else FinalInt = 42000000;
		break;
	case 18:
		if( ReqNum==0 )
			FinalInt = 10000;
		else FinalInt = 50000000;
		break;
	case 19:
		if( ReqNum==0 )
			FinalInt = 11600;
		else FinalInt = 58000000;
		break;
	case 20:
		if( ReqNum==0 )
			FinalInt = 13200;
		else FinalInt = 66000000;
		break;
	case 21:
		if( ReqNum==0 )
			FinalInt = 15450;
		else FinalInt = 77250000;
		break;
	case 22:
		if( ReqNum==0 )
			FinalInt = 17850;
		else FinalInt = 89250000;
		break;
	case 23:
		if( ReqNum==0 )
			FinalInt = 20400;
		else FinalInt = 102000000;
		break;
	case 24:
		if( ReqNum==0 )
			FinalInt = 23100;
		else FinalInt = 115500000;
		break;
	case 25:
		if( ReqNum==0 )
			FinalInt = 25950;
		else FinalInt = 129750000;
		break;
	case 26:
		if( ReqNum==0 )
			FinalInt = 28850;
		else FinalInt = 144250000;
		break;
	case 27:
		if( ReqNum==0 )
			FinalInt = 32100;
		else FinalInt = 160500000;
		break;
	case 28:
		if( ReqNum==0 )
			FinalInt = 35400;
		else FinalInt = 177000000;
		break;
	case 29:
		if( ReqNum==0 )
			FinalInt = 38850;
		else FinalInt = 194250000;
		break;
	case 30:
		if( ReqNum==0 )
			FinalInt = 42450;
		else FinalInt = 212250000;
		break;
	case 31:
		if( ReqNum==0 )
			FinalInt = 46200;
		else FinalInt = 231000000;
		break;
	case 32:
		if( ReqNum==0 )
			FinalInt = 50700;
		else FinalInt = 253500000;
		break;
	case 33:
		if( ReqNum==0 )
			FinalInt = 55200;
		else FinalInt = 276000000;
		break;
	case 34:
		if( ReqNum==0 )
			FinalInt = 59700;
		else FinalInt = 298500000;
		break;
	case 35:
		if( ReqNum==0 )
			FinalInt = 64200;
		else FinalInt = 321000000;
		break;
	case 36:
		if( ReqNum==0 )
			FinalInt = 68700;
		else FinalInt = 343500000;
		break;
	case 37:
		if( ReqNum==0 )
			FinalInt = 73200;
		else FinalInt = 366000000;
		break;
	case 38:
		if( ReqNum==0 )
			FinalInt = 77700;
		else FinalInt = 388500000;
		break;
	case 39:
		if( ReqNum==0 )
			FinalInt = 83700;
		else FinalInt = 418500000;
		break;
	case 40:
		if( ReqNum==0 )
			FinalInt = 90000;
		else FinalInt = 450000000;
		break;
	case 41:
		if( ReqNum==0 )
			FinalInt = 200000;
		else FinalInt = 1000000000;
		break;
	default:
		if( ReqNum==0 )
			FinalInt = 3600+GetDoubleScaling(CurLevel,350);
		else FinalInt = 5500000+GetDoubleScaling(CurLevel,500000);
	}
	if( ReqNum==0 )
		return Min(StatOther.RStalkerKillsStat,FinalInt);
	return Min(StatOther.RBullpupDamageStat,FinalInt);
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

	if ( ReqNum == 0 )
	{
		return Min(StatOther.RStalkerKillsStat,FinalInt);
	}
	else
	{
		return Min(StatOther.RBullpupDamageStat,FinalInt);
	}
}

static function int PerkLevelRequirement(byte CurLevel, byte ReqNum)
{
	local array<float> StartReq,WholeReq;
	local int FinalInt;
	
	StartReq.Insert(0,3);
	WholeReq.Insert(0,3);
	
	if ( ReqNum == 0 )
	{
		StartReq[0] =    100;
		WholeReq[0] =   1200;
		StartReq[1] =    900;
		WholeReq[1] =  43800;
		StartReq[2] =   1500;
		WholeReq[2] =  45000;
	}
	else
	{
		StartReq[0] =    500000;
		WholeReq[0] =   6000000;
		StartReq[1] =   2000000;
		WholeReq[1] = 219000000;
		StartReq[2] =  15000000;
		WholeReq[2] = 225000000;
	}
	
	FinalInt = int(ArythmProgression(CurLevel,StartReq,WholeReq));
	
	return FinalInt;
}*/

static function float DecapDamageModifier(PlayerReplicationInfo PRI, Pawn Victim, class<DamageType> DmgType)
{
	return 2.0;
}

static function bool ShowStalkers(KFPlayerReplicationInfo KFPRI)
{
	return true;
}

static function float GetStalkerViewDistanceMulti(KFPlayerReplicationInfo KFPRI)
{
	return 0.50 + 0.20 * float(KFPRI.ClientVeteranSkillLevel);
}

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float ret;
	
	ret = 1.0;
	
	if ( Bullpup(Other) != none 
	|| AK47AssaultRifle(Other) != none 
	|| SCARMK17AssaultRifle(Other) != none 
	|| M4AssaultRifle(Other) != none 
	|| FNFALSAAssaultRifle(Other) != none
	|| BullpupM(Other) != none 
	|| SCARMK17AssaultRifleM(Other) != none 
	|| M4AssaultRifleM(Other) != none 
	|| FNC30AssaultRifle(Other) != none
	|| M4A1IronBeastSAAssaultRifle(Other) != none  
	|| RNC44AssaultRifle(Other) != none 
	|| codol(Other) != none
	|| AK47SHAssaultRifleM(Other) != none 
	|| AN94AssaultRifle(Other) != none 
	|| SR3MSpecnazRifle(Other) != none 
	|| OC33LLI(Other) != none
	|| AUG_A3AR(Other) != none 
	|| XM8AssaultRifle(Other) != none 
	|| AK12LLIAssaultRifle(Other) != none 
	|| FFOWARLLI(Other) != none 
	|| GalilComicSAAssaultRifle(Other) != none 
	|| AK12SAv2AssaultRifle(Other) != none
	|| MKb42New(Other) != none 
	|| M7A3MSRMedicGun(Other) != none 
	|| M4A1SAAssaultRifle(Other) != none 
	|| PDWAssaultRifle(Other) != none 
	|| AK117SAAssaultRifle(Other) != none )
	{
		ret = 1.25 + 0.05 * float(Max(0,(KFPRI.ClientVeteranSkillLevel-1)/5));
	}
	return ret;
}

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	local float ret;
	
	ret = 1.00;
	
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

	if ( BullpupAmmo(Other) != none
	|| AK47Ammo(Other) != none
	|| SCARMK17Ammo(Other) != none
	|| M4Ammo(Other) != none
	|| AN94Ammo(Other) != none
	|| AN94gAmmo(Other) != none
	|| SR3MAmmo(Other) != none
	|| M4A1IronBeastSAAmmo(Other) != none
	|| FNC30Ammo(Other) != none
	|| RNC44Ammo(Other) != none
	|| codolAmmo(Other) != none
	|| FNFALSAAmmo(Other) != none
	|| AK12SAv2Ammo(Other) != none
	|| OC33LLIAmmo(Other) != none
	|| AUG_A3ARAmmo(Other) != none
	|| XM8Ammo(Other) != none
	|| FFOWARLLIAmmo(Other) != none
	|| GalilComicSAAmmo(Other) != none
	|| PDWAmmo(Other) != none
	|| AK12LLIAmmo(Other) != none
	|| MKb42NewAmmo(Other) != none
	|| M7A3MSRAmmo(Other) != none
	|| M4A1SAAmmo(Other) != none
	|| AK117SAAmmo(Other) != none )
	{
		ret = 1.25 + 0.05 * float(Max(0,(KFPRI.ClientVeteranSkillLevel-1)/5));
	}
	if ( RadioBombAmmo(Other) != none )
	{
		ret = 1.50 + 0.50 * float(Max(0,(KFPRI.ClientVeteranSkillLevel-1)/5));
	}
	if ( Frag1Ammo(Other) != none )
	{
		ret = 1.00 + 0.20 * float(KFPRI.ClientVeteranSkillLevel/4);
	}

	return ret * Super.GetAmmoPickupMod(KFPRI,Other);
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float ret;
	
	ret = 1.00;
	
	if ( AmmoType == class'GrenadePistolLLILAmmo'
		|| AmmoType == class'FNC30M203Ammo'
		|| AmmoType == class'Armacham203Ammo' ) return ret;
	
	if ( AmmoType == class'BullpupAmmo'
	|| AmmoType == class'AK47Ammo'
	|| AmmoType == class'SCARMK17Ammo'
	|| AmmoType == class'M4Ammo'
	|| AmmoType == class'GalilComicSAAmmo'
	|| AmmoType == class'AN94Ammo'
	|| AmmoType == class'AN94gAmmo'
	|| AmmoType == class'M4A1IronBeastSAAmmo'
	|| AmmoType == class'FNC30Ammo'
	|| AmmoType == class'RNC44Ammo'
	|| AmmoType == class'codolAmmo'
	|| AmmoType == class'FNFALSAAmmo'
	|| AmmoType == class'SR3MAmmo'
	|| AmmoType == class'FFOWARLLIAmmo'
	|| AmmoType == class'PDWAmmo'
	|| AmmoType == class'OC33LLIAmmo'
	|| AmmoType == class'AUG_A3ARAmmo'
	|| AmmoType == class'XM8Ammo'
	|| AmmoType == class'M4A1SAAmmo'
	|| AmmoType == class'AK12SAv2Ammo'
	|| AmmoType == class'XM8gAmmo'
	|| AmmoType == class'AK12LLIAmmo'
	|| AmmoType == class'MKb42NewAmmo'
	|| AmmoType == class'M7A3MSRAmmo'
	|| AmmoType == class'AK117SAAmmo' )
	{
		ret = 1.25 + 0.07 * float(Max(0,(KFPRI.ClientVeteranSkillLevel-1)/5));
	}
	else if ( AmmoType == class'RadioBombAmmo' )
	{
		ret = 1.50 + 0.50 * float(Max(0,(KFPRI.ClientVeteranSkillLevel-1)/5));
	}
	else if ( AmmoType == class'Frag1Ammo' )
	{
		ret = 1.00 + 0.20 * float(KFPRI.ClientVeteranSkillLevel/4);
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
	
	ret = 1.00;
	if(DmgType != none)
	{
		if	(
				(
					DmgType != none
					&&	class<SRWeaponDamageType>(DmgType)!=none
					&&	class<SRWeaponDamageType>(DmgType).default.bCommando
				)
				||	DmgType == class'DamTypeBullpup'
				||	DmgType == class'DamTypeM4AssaultRifle'
				||	DmgType == class'DamTypeAK47AssaultRifle'
				||	DmgType == class'DamTypeSCARMK17New'
				||	DmgType == class'DamTypeAK12SAv2'
				||	DmgType == class'DamTypeAK117SA'
			)
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
	}
	return ret * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
}
static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil)
{
	Recoil = 1.00;

	if ( Bullpup(Other.Weapon) != none 
		|| AK47AssaultRifle(Other.Weapon) != none
		|| SCARMK17AssaultRifle(Other.Weapon) != none 
		|| M4AssaultRifle(Other.Weapon) != none
		|| BullpupM(Other.Weapon) != none 
		|| M4A1IronBeastSAAssaultRifle(Other.Weapon) != none 
		|| FNC30AssaultRifle(Other.Weapon) != none 
		|| RNC44AssaultRifle(Other.Weapon) != none 
		|| FNFALSAAssaultRifle(Other.Weapon) != none
		|| SCARMK17AssaultRifleM(Other.Weapon) != none 
		|| M4AssaultRifleM(Other.Weapon) != none
		|| AK47SHAssaultRifleM(Other.Weapon) != none 
		|| AN94AssaultRifle(Other.Weapon) != none 
		|| codol(Other.Weapon) != none
		|| SR3MSpecnazRifle(Other.Weapon) != none 
		|| OC33LLI(Other.Weapon) != none 
		|| AK117SAAssaultRifle(Other.Weapon) != none
		|| AUG_A3AR(Other.Weapon) != none 
		|| M4A1SAAssaultRifle(Other.Weapon) != none 
		|| AK12SAv2AssaultRifle(Other.Weapon) != none
		|| XM8AssaultRifle(Other.Weapon) != none 
		|| AK12LLIAssaultRifle(Other.Weapon) != none 
		|| PDWAssaultRifle(Other.Weapon) != none 
		|| GalilComicSAAssaultRifle(Other.Weapon) != none
		|| MKb42New(Other.Weapon) != none 
		|| M7A3MMedicGun(Other.Weapon) != none 
		|| FFOWARLLI(Other.Weapon) != none )
	{
		Recoil = 0.40 - 0.0075 * float(KFPRI.ClientVeteranSkillLevel);
	}

	return Recoil;
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float ret;
	
	ret = 1.20 + 0.02 * float(KFPRI.ClientVeteranSkillLevel);
	
	return ret * Super.GetReloadSpeedModifier(KFPRI,Other);
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
	local float Reduction;
	
	Reduction = 1.00;

	if ( class<DamTypeAN94Proj>(DmgType) != none || class<DamTypeM79Grenade>(DmgType) != none || class<DamTypeXM8Grenade>(DmgType) != none )
	{
		Reduction = 0.20;
		Goto SetReduction;
	}
	if ( class<DamTypeRadioBomb>(DmgType) != none )
	{
		Reduction = 1.0 - 0.01 * float(KFPRI.ClientVeteranSkillLevel);
		Goto SetReduction;
	}
	
	/*if ( class<DamTypeRadioBomb>(DmgType) != none )
	{
		Reduction = 0.15;
		Goto SetReduction;
	}*/
	
	if ( class<SirenScreamDamage>(DmgType) != none || class<DamTypePoison>(DmgType) != none )
	{
		Reduction = 0.80 - 0.01 * float(KFPRI.ClientVeteranSkillLevel);
		Goto SetReduction;
	}
	
	if ( class<DamTypePatriarchChaingun>(DmgType) != none )
	{
		Reduction = 0.45 - 0.01 * float(KFPRI.ClientVeteranSkillLevel);
		Goto SetReduction;
	}
	
SetReduction:
	
	return Reduction * Super.ReduceDamage(KFPRI,Injured,Instigator,InDamage,DmgType);
}

static function float GetSyringeMinimumSelfHealHPLevel(KFPlayerReplicationInfo KFPRI)
{
	local float ret;
	
	ret = 30.0 + 1.0 * float(KFPRI.ClientVeteranSkillLevel);
	
	return ret;
}

static function int ZedTimeExtensions(KFPlayerReplicationInfo KFPRI)
{
	return Min(KFPRI.ClientVeteranSkillLevel,5); // Up to 5 Zed Time Extensions
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'DesorientatingNade';
}

static function class<DamageType> GetFNC30DamageType(KFPlayerReplicationInfo KFPRI)
{
	return class'DamTypeFNC30AssaultRifle';
}

static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float ret;
	
	ret = 1.0;
	
	if ( Item == class'BullpupPickup' 
	|| Item == class'AK47Pickup' 
	|| Item == class'SCARMK17Pickup' 
	|| Item == class'M4Pickup' 
	|| Item == class'codolPickup'
	|| Item == class'BullpupPickupM' 
	|| Item == class'SCARMK17PickupM' 
	|| Item == class'M4PickupM' 
	|| Item == class'FNFALSAPickup'
	|| Item == class'AK47SHPickupM' 
	|| Item == class'AN94Pickup' 
	|| Item == class'SR3MPickup' 
	|| Item == class'RNC44Pickup' 
	|| Item == class'FNC30Pickup' 
	|| Item == class'M4A1IronBeastSAPickup' 
	|| Item == class'OC33LLIPickup'
	|| Item == class'AUG_A3ARPickup' 
	|| Item == class'XM8Pickup' 
	|| Item == class'M7A3MSRPickup' 
	|| Item == class'AK12SAv2Pickup' 
	|| Item == class'AK117SAPickup'
	|| Item == class'MKb42NewPickup' 
	|| Item == class'M4A1SAPickup' 
	|| Item == class'FFOWARLLIPickup' 
	|| Item == class'PDWPickup' 
	|| Item == class'GalilComicSAPickup' )
	{
		ret = GetDefaultCostScaling(KFPRI.ClientVeteranSkillLevel);
	}

	if ( Item == class'RadioBombPickup' )
	{
		ret = 0.05;
	}

	if ( Item == class'Vest' )
	{
		ret *= 0.5;
	}
	
	return ret;
}

static function float GetAmmoCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'RadioBombPickup' )
		return 0.05;
	return 1.00;
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	local Inventory I;
	local string weapon;
	local SRPlayerReplicationInfo SRPRI;
	
	Super.AddDefaultInventory(KFPRI,P);
	
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	
	if ( SRPlayerReplicationInfo(KFPRI).bRespawned )
		return;
		
	SRPlayerReplicationInfo(KFPRI).bRespawned = true;
	if (Mid(weapon, 3, 1) == "G")
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.GalilComicSAAssaultRifle", GetCostScaling(KFPRI, class'GalilComicSAPickup'));
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 5 && KFPRI.ClientVeteranSkillLevel < 11 || KFPRI.ClientVeteranSkillLevel > 15 && KFPRI.ClientVeteranSkillLevel < 21
		|| KFPRI.ClientVeteranSkillLevel > 30 && KFPRI.ClientVeteranSkillLevel < 36 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.BullpupM", GetCostScaling(KFPRI, class'BullpupPickupM'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 10 && KFPRI.ClientVeteranSkillLevel < 16 || KFPRI.ClientVeteranSkillLevel > 20 && KFPRI.ClientVeteranSkillLevel < 31 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.M4AssaultRifleM", GetCostScaling(KFPRI, class'M4PickupM'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 15 && KFPRI.ClientVeteranSkillLevel < 21 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.MKb42New", GetCostScaling(KFPRI, class'MKb42NewPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 20 && KFPRI.ClientVeteranSkillLevel < 26 || KFPRI.ClientVeteranSkillLevel > 35 )
	{
		if (Mid(weapon, 3, 1) == "4")
		{
			KFHumanPawn(P).CreateInventoryVeterancy("Mswp.M4A1SAAssaultRifle", GetCostScaling(KFPRI, class'M4A1SAPickup'));
		}
		else
			KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SCARMK17AssaultRifleM", GetCostScaling(KFPRI, class'SCARMK17PickupM'));
	}
		
	if ( KFPRI.ClientVeteranSkillLevel > 25 && KFPRI.ClientVeteranSkillLevel < 31 || KFPRI.ClientVeteranSkillLevel > 35 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AN94AssaultRifle", GetCostScaling(KFPRI, class'AN94Pickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 30 && KFPRI.ClientVeteranSkillLevel < 36 )
		KFHumanPawn(P).CreateInventoryVeterancy("Masters.XM8AssaultRifle", GetCostScaling(KFPRI, class'XM8Pickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 30 && KFPRI.ClientVeteranSkillLevel < 36 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AUG_A3AR", GetCostScaling(KFPRI, class'AUG_A3ARPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 35 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AK47SHAssaultRifleM", GetCostScaling(KFPRI, class'AK47SHPickupM'));

	/*if ( KFPRI.ClientVeteranSkillLevel > 35 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SR3MSpecnazRifle", GetCostScaling(KFPRI, class'SR3MPickup'));*/
		
	if ( SRPRI.HasSkinGroup("DeathWeap") )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.FFOWARLLI", GetCostScaling(KFPRI, class'FFOWARLLIPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.M4A1IronBeastSAAssaultRifle", GetCostScaling(KFPRI, class'M4A1IronBeastSAPickup'));
	}	
	
	if ( SRPRI.HasSkinGroup("Valdemar") )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.RNC44AssaultRifle", GetCostScaling(KFPRI, class'RNC44Pickup'));
	}		
		
	if ( SRPRI.HasSkinGroup("STALKER1") )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.FFOWARLLI", GetCostScaling(KFPRI, class'FFOWARLLIPickup'));
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
	
	S = S $ GetPercentStr( 0.01*float(int(100.0*(0.60 + 0.0075 * float(Level)))) ) $ default.PerkDescription[1];
	
	S = S $ "+" $ GetPercentStr( 0.25 + 0.05 * float((Level-1)/5) ) $ default.PerkDescription[2];
	
	S = S $ "+" $ GetPercentStr( 0.20 + 0.02 * float(Level) ) $ default.PerkDescription[3];
	
	S = S $ GetPercentStr ( 0.20 + 0.01 * float(Level) ) $ default.PerkDescription[4];
	
	S = S $ GetPercentStr ( 0.55 + 0.01 * float(Level) ) $ default.PerkDescription[5];
	
	S = S $ default.PerkDescription[6] $ string(30+Level) $ default.PerkDescription[7];
	
	S = S $ GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[8];
	
	S = S $ default.PerkDescription[9] $ string(Max(0,(Level-1)/5)) $ default.PerkDescription[10];
	
	S = S $ default.PerkDescription[11] $ string(12+4*((Level-1)/5)) $ default.PerkDescription[12];
	
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
	
	if ( Level > 15 )
	{
		Add = 0.05;
		
		if ( Level > 30 )
		{
			Add = 0.10;
		}
		
		S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[14];
	}
	
	if ( Level > 20 )
	{
		Add = 0.40;
		
		if ( Level > 30 )
		{
			Add = 0.65;
		}
		
		S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[15];
	}
	
	S = S $ default.PerkDescription[16];
	
	S = S $ default.PerkDescription[17+(Level-1)/5];
	
	return S;
}

static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI, class<KFMonster> MonsterClass)
{
	local float ret;
	
	ret = 0.7;
	
	if ( class<DKShiver>(MonsterClass) != none )
	{
		ret = 1.00;
		//return 1.50 * Super.GetMoneyReward(SRPRI,MonsterClass);
	}
	
	if ( class<DKStalker>(MonsterClass) != none )
	{
		ret = 0.90;
		//return 2.00 * Super.GetMoneyReward(SRPRI,MonsterClass);
	}
	
	if ( class<DKPoisoner>(MonsterClass) != none )
	{
		ret = 1.50;
		//return 2.00 * Super.GetMoneyReward(SRPRI,MonsterClass);
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
	PerkDescription(0)=" урона штурмовыми винтовками|"
	PerkDescription(1)=" уменьшение отдачи штурмовых винтовок|"
	PerkDescription(2)=" вместимость магазина штурмовых винтовок|"
	PerkDescription(3)=" к скорости перезарядки любого оружия|"
	PerkDescription(4)=" сопротивление к яду и воплю сирены|"
	PerkDescription(5)=" уменьшение урона от пулемета патриарха|"
	PerkDescription(6)="После каждого самолечения остается как минимум "
	PerkDescription(7)=" ед здоровья|"
	PerkDescription(8)=" скидка на штурмовые винтовки|"
	PerkDescription(9)="Ранг "
	PerkDescription(10)=", бонусы:|"
	PerkDescription(11)="Видит здоровье монстров с "
	PerkDescription(12)=" метров|"
	PerkDescription(13)=" ед. переносимого веса|"
	PerkDescription(14)=" к скорости бега|"
	PerkDescription(15)=" скорости восстановления шприца|"
	PerkDescription(16)="Особенности перка:|Гранаты дезориентируют монстров|Дополнительный урон против Отравителей и Шиверов|Стартовый инвентарь:|"
	PerkDescription(17)="ОЦ-33"
	PerkDescription(18)="ОЦ-33 и L22A1"
	PerkDescription(19)="ОЦ-33 и M4"
	PerkDescription(20)="ОЦ-33,L22 A1 и MKb42"
	PerkDescription(21)="ОЦ-33,M4 и SCARMK-17"
	PerkDescription(22)="ОЦ-33,M4 и АН-94 Абакан"
	PerkDescription(23)="ОЦ-33,L22 A1,AUG A3 и HK XM8"
	PerkDescription(24)="ОЦ-33, АН-94 Абакан, АК-47, FN SCAR Mk.17, броня"
	
	PerkIndex=3

	IconMat1 = Texture'SunriseHUD.Icons.Perk_Commando_Green'
	IconMat2 = Texture'SunriseHUD.Icons.Perk_Commando_Orange'
	IconMat3 = Texture'SunriseHUD.Icons.Perk_Commando_Blue'
	IconMat4 = Texture'SunriseHUD.Icons.Perk_Commando_Purple'
	IconMat5 = Texture'SunriseHUD.Icons.Perk_Commando_Red'
	IconMat6 = Texture'SunriseHUD.Icons.Perk_Commando_Silver'
	IconMat7 = Texture'SunriseHUD.Icons.Perk_Commando_Dark'
	IconMat8 = Texture'SunriseHUD.Icons.Perk_Commando_Gold'
	IconMat9 = Texture'SunriseHUD.Icons.Perk_Commando_Master'
	IconMat10 = Texture'SunriseHUD.Icons.Perk_Commando_Elite'

	VeterancyName="Коммандос"
	Requirements[0]="Убить %x сталкеров, отравителей, играя этим перком"
	Requirements[1]="Нанести %x повреждений используя штурмовые винтовки"
	NumRequirements=2

}
