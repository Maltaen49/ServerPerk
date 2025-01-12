class SRVetJuggernaut extends SRVeterancyTypes
	abstract;

static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	switch( CurLevel )
	{
	case 0:
		if( ReqNum==0 )
			FinalInt = 3;
		else FinalInt = 5000;
		break;
	case 1:
		if( ReqNum==0 )
			FinalInt = 63;
		else FinalInt = 15000;
		break;
	case 2:
		if( ReqNum==0 )
			FinalInt = 125;
		else FinalInt = 30000;
		break;
	case 3:
		if( ReqNum==0 )
			FinalInt = 250;
		else FinalInt = 60000;
		break;
	case 4:
		if( ReqNum==0 )
			FinalInt = 500;
		else FinalInt = 120000;
		break;
	case 5:
		if( ReqNum==0 )
			FinalInt = 1042;
		else FinalInt = 250000;
		break;
	case 6:
		if( ReqNum==0 )
			FinalInt = 2083;
		else FinalInt = 500000;
		break;
	case 7:
		if( ReqNum==0 )
			FinalInt = 4166;
		else FinalInt = 1000000;
		break;
	case 8:
		if( ReqNum==0 )
			FinalInt = 8333;
		else FinalInt = 2000000;
		break;
	case 9:
		if( ReqNum==0 )
			FinalInt = 16666;
		else FinalInt = 4000000;
		break;
	case 10:
		if( ReqNum==0 )
			FinalInt = 25000;
		else FinalInt = 6000000;
		break;
	case 11:
		if( ReqNum==0 )
			FinalInt = 33333;
		else FinalInt = 8000000;
		break;
	case 12:
		if( ReqNum==0 )
			FinalInt = 57000;
		else FinalInt = 13000000;
		break;
	case 13:
		if( ReqNum==0 )
			FinalInt = 80000;
		else FinalInt = 18000000;
		break;
	case 14:
		if( ReqNum==0 )
			FinalInt = 103000;
		else FinalInt = 23000000;
		break;
	case 15:
		if( ReqNum==0 )
			FinalInt = 127000;
		else FinalInt = 26000000;
		break;
	case 16:
		if( ReqNum==0 )
			FinalInt = 160000;
		else FinalInt = 34000000;
		break;
	case 17:
		if( ReqNum==0 )
			FinalInt = 193000;
		else FinalInt = 42000000;
		break;
	case 18:
		if( ReqNum==0 )
			FinalInt = 227000;
		else FinalInt = 50000000;
		break;
	case 19:
		if( ReqNum==0 )
			FinalInt = 260000;
		else FinalInt = 58000000;
		break;
	case 20:
		if( ReqNum==0 )
			FinalInt = 293000;
		else FinalInt = 66000000;
		break;
	case 21:
		if( ReqNum==0 )
			FinalInt = 343000;
		else FinalInt = 77250000;
		break;
	case 22:
		if( ReqNum==0 )
			FinalInt = 397000;
		else FinalInt = 89250000;
		break;
	case 23:
		if( ReqNum==0 )
			FinalInt = 453000;
		else FinalInt = 102000000;
		break;
	case 24:
		if( ReqNum==0 )
			FinalInt = 513000;
		else FinalInt = 115500000;
		break;
	case 25:
		if( ReqNum==0 )
			FinalInt = 577000;
		else FinalInt = 129750000;
		break;
	case 26:
		if( ReqNum==0 )
			FinalInt = 643000;
		else FinalInt = 144250000;
		break;
	case 27:
		if( ReqNum==0 )
			FinalInt = 713000;
		else FinalInt = 160500000;
		break;
	case 28:
		if( ReqNum==0 )
			FinalInt = 787000;
		else FinalInt = 177000000;
		break;
	case 29:
		if( ReqNum==0 )
			FinalInt = 863000;
		else FinalInt = 194250000;
		break;
	case 30:
		if( ReqNum==0 )
			FinalInt = 943000;
		else FinalInt = 212250000;
		break;
	case 31:
		if( ReqNum==0 )
			FinalInt = 1027000;
		else FinalInt = 231000000;
		break;
	case 32:
		if( ReqNum==0 )
			FinalInt = 1127000;
		else FinalInt = 253500000;
		break;
	case 33:
		if( ReqNum==0 )
			FinalInt = 1227000;
		else FinalInt = 276000000;
		break;
	case 34:
		if( ReqNum==0 )
			FinalInt = 1330000;
		else FinalInt = 298500000;
		break;
	case 35:
		if( ReqNum==0 )
			FinalInt = 1430000;
		else FinalInt = 321000000;
		break;
	case 36:
		if( ReqNum==0 )
			FinalInt = 1530000;
		else FinalInt = 343500000;
		break;
	case 37:
		if( ReqNum==0 )
			FinalInt = 1630000;
		else FinalInt = 366000000;
		break;
	case 38:
		if( ReqNum==0 )
			FinalInt = 1730000;
		else FinalInt = 388500000;
		break;
	case 39:
		if( ReqNum==0 )
			FinalInt = 1860000;
		else FinalInt = 418500000;
		break;
	case 40:
		if( ReqNum==0 )
			FinalInt = 2000000;
		else FinalInt = 450000000;
		break;
	case 41:
		if( ReqNum==0 )
			FinalInt = 4500000;
		else FinalInt = 1000000000;
		break;
	default:
		if( ReqNum==0 )
			FinalInt = 3600+GetDoubleScaling(CurLevel,350);
		else FinalInt = 5500000+GetDoubleScaling(CurLevel,500000);
	}
	if( ReqNum==0 )
		return Min(StatOther.RWeldingArmorPointsStat,FinalInt);
	return Min(StatOther.RMachinegunDamageStat,FinalInt);
}

/*static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	FinalInt = PerkLevelRequirement(CurLevel,ReqNum);

	if( ReqNum==0 )
		return Min(StatOther.RWeldingArmorPointsStat,FinalInt);
	return Min(StatOther.RMachinegunDamageStat,FinalInt);
}

static function int PerkLevelRequirement(byte CurLevel, byte ReqNum)
{
	local array<float> StartReq,WholeReq;
	local int FinalInt;
	
	StartReq.Insert(0,3);
	WholeReq.Insert(0,3);
	
	if ( ReqNum == 0 )
	{
		StartReq[0] =     1600;
		WholeReq[0] =    20000;
		StartReq[1] =     6000;
		WholeReq[1] =   980000;
		StartReq[2] =   100000;
		WholeReq[2] =  1000000;
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

static function float GetHUDCoiff(KFPlayerReplicationInfo KFPRI)
{
	return 1.0 + (0.025 * float(KFPRI.ClientVeteranSkillLevel));
}
static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{	
	local float ret;
	
	ret = 1.0;
	
	if ( class<SRWeaponDamageType>(DmgType) != none )
	{
		if ( class<SRWeaponDamageType>(DmgType).default.bJugger )
		{
			ret = 1.2 + 0.025 * float(KFPRI.ClientVeteranSkillLevel);
		}
	}
	
	/*if ( class<SRWeaponDamageType>(DmgType) != none )
	{
		if ( class<SRWeaponDamageType>(DmgType).default.bJugger )
		{
			ret = 1.0 + 0.02 * float(KFPRI.ClientVeteranSkillLevel);
		}
	}*/
	return ret * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
}

static function float DecapDamageModifier(PlayerReplicationInfo PRI, Pawn Victim, class<DamageType> DmgType)
{
	return 1.5;
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
	local float Reduction;
	
	Reduction = 1.0;
	if ( class<ZombieMeleeDamage>(DmgType) != none
		|| class<DamTypeZombieAttack>(DmgType) != none && class<DamTypeZombieAttack>(DmgType).default.bLocationalHit )
		Reduction = 0.80 - 0.0075;
	InDamage = class'DKUtil'.Static.SmoothFloatToInt(float(InDamage)*Reduction);
	return Super.ReduceDamage(KFPRI,Injured,Instigator,InDamage,DmgType);
}

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	local float ret;
	
	if ( Frag1Ammo(Other) != None )
		return 0.0;
		
	ret = 1.0;

	if ( FN2000MgAmmo(Other) != none
	|| Armacham203Ammo(Other) != none
	|| FNC30M203Ammo(Other) != none  )
	{
			ret = 2.0;
	}

	if ( ThompsonAmmo(Other) != none 
	|| SA80LSWAmmo(Other) != none 
	|| PKMAmmo(Other) != none 
	|| M249Ammo(Other) != none 
	|| ZEDGunMLLIAmmo(Other) != none 
	|| BerettaPx4Ammo(Other) != none 
	|| DBerettaPx4Ammo(Other) != none 
	|| RPK47Ammo(Other) != none 
	|| RPKAmmo(Other) != none 
	|| AUG_A1MGAmmo(Other) != none 
	|| M134DTRAmmo(Other) != none 
	|| ZEDGunLLIAmmo(Other) != none
	|| M60Ammo(Other) != none 
	|| M134DTAmmo(Other) != none 
	|| XMV850Ammo(Other) != none 
	|| THR40DTAmmo(Other) != none 
	|| FNC30Ammo(Other) != none 
	|| AK47JAmmo(Other) != none 
	|| StingerAmmo(Other) != none 
	|| HK23ESAAmmo(Other) != none 
	|| PKPDTAmmo(Other) != none 
	|| K3LMGAmmo(Other) != none
	|| PKPDTCAmmo(Other) != none 
	|| PKMCAmmo(Other) != none 
	|| PatGunAmmo(Other) != none 
	|| ultimaxGALAmmo(Other) != none 
	|| LaserGutlingAmmo(Other) != none 
	|| LaserRCWAmmo(Other) != none )
	{
		ret = 1.33 + 0.06 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5));
	}

	return ret * Super.GetAmmoPickupMod(KFPRI,Other);
}

static function class<DamageType> GetFNC30DamageType(KFPlayerReplicationInfo KFPRI)
{
	return class'DamTypeFNC30MG';
}

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float ret;
	local string weapon;
	local SRPlayerReplicationInfo SRPRI;
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	
	ret = 1.0;
	
	if( FNC30AssaultRifle(Other) != none && SRPRI.HasSkinGroup("GMFNC") )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 2.0;
		}
		else
		{
			ret = 2.15 + 0.2 * float((KFPRI.ClientVeteranSkillLevel-1)/5);
		}
	}
	if (  XMV850(Other) != none && SRPRI.HasSkinGroup("XLocki") )
	{
		ret = 1.5;
	}
	if ( PKPDT(Other) != none && Mid(weapon, 7, 1) == "V" )
	{
		ret = 2.0;
	}
	return ret;
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float ret;
	local string weapon;
	local SRPlayerReplicationInfo SRPRI;
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	
	ret = 1.0;

	if ( AmmoType == class'GrenadePistolLLILAmmo'
		|| AmmoType == class'FNC30M203Ammo'
		|| AmmoType == class'Armacham203Ammo' ) return ret;
	
	if ( AmmoType == class'FragAmmo' || AmmoType == class'Frag1Ammo' )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 1.0;
		}
		else
		{
			ret = 1.2 + 0.4 * float((KFPRI.ClientVeteranSkillLevel-1)/5);
		}
	}

	else if ( AmmoType == class'PKPDTAmmo' && Mid(weapon, 7, 1) == "V" )
	{
		ret = 1.33 + 0.1 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5));
	}
	else if ( AmmoType == class'XMV850Ammo' && SRPRI.HasSkinGroup("XLocki") )
	{
		ret = 1.5 + 0.9 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5));
	}
	else if ( AmmoType == class'ThompsonAmmo' 
			|| AmmoType == class'SA80LSWAmmo'
			|| AmmoType == class'PKMAmmo' 
			|| AmmoType == class'M249Ammo' 
			|| AmmoType == class'M134DTRAmmo' 
			|| AmmoType == class'BerettaPx4Ammo' 
			|| AmmoType == class'DBerettaPx4Ammo' 
			|| AmmoType == class'THR40DTAmmo'
			|| AmmoType == class'RPK47Ammo' 
			|| AmmoType == class'RPKAmmo' 
			|| AmmoType == class'AUG_A1MGAmmo' 
			|| AmmoType == class'HK23ESAAmmo'
			|| AmmoType == class'M60Ammo' 
			|| AmmoType == class'M134DTAmmo' 
			|| AmmoType == class'PKMCAmmo' 
			|| AmmoType == class'ZEDGunMLLIAmmo'
			|| AmmoType == class'PKPDTCAmmo' 
			|| AmmoType == class'K3LMGAmmo' 
			|| AmmoType == class'ultimaxGALAmmo'
			|| (AmmoType == class'PKPDTAmmo' && Mid(weapon, 7, 1) != "V") 
			|| AmmoType == class'ZEDGunLLIAmmo' 
			|| AmmoType == class'LaserRCWAmmo' 
			|| AmmoType == class'LaserGutlingAmmo'
			|| AmmoType == class'AK47JAmmo' 
			|| AmmoType == class'StingerAmmo' 
			|| AmmoType == class'StingerAmmo' 
			|| AmmoType == class'FNC30Ammo' 
			|| AmmoType == class'PatGunAmmo'
			|| ( AmmoType == class'XMV850Ammo' && !SRPRI.HasSkinGroup("XLocki") ) )
	{
		ret = 1.33 + 0.06 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5));
	}
	else
	{
		ret = Super.AddExtraAmmoFor(KFPRI,AmmoType);
	}

	return ret;
}

static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil)
{
	Recoil = 1.0;

	if ( ThompsonSubmachineGun(Other.Weapon) != none 
	|| SA80LSW(Other.Weapon) != none 
	|| PKM(Other.Weapon) != none 
	|| M249(Other.Weapon) != none
	|| M134DTR(Other.Weapon) != none 
	|| M134DTW(Other.Weapon) != none 
	|| BerettaPx4(Other.Weapon) != none 
	|| DualBerettaPx4(Other.Weapon) != none 
	|| RPK47Machinegun(Other.Weapon) != none
	|| RPK(Other.Weapon) != none 
	|| AUG_A1MG(Other.Weapon) != none 
	|| HK23ESAAssaultRifle(Other.Weapon) != none
	|| M60(Other.Weapon) != none 
	|| M134DT(Other.Weapon) != none 
	|| PKPDT(Other.Weapon) != none
	|| K3LMGAssaultRifle(Other.Weapon) != none 
	|| PKMC(Other.Weapon) != none 
	|| PKPDTC(Other.Weapon) != none
	|| ZEDGunLLI(Other.Weapon) != none 
	|| PatGun(Other.Weapon) != none 
	|| LaserRCW(Other.Weapon) != none
	|| THR40DT(Other.Weapon) != none 
	|| XMV850(Other.Weapon) != none 
	|| FNC30AssaultRifle(Other.Weapon) != none 
	|| AK47JAssaultRifleM(Other.Weapon) != none
	|| Stinger(Other.Weapon) != none 
	|| ZEDGunMLLI(Other.Weapon) != none 
	|| LaserGutling(Other.Weapon) != none
	|| ultimaxGALAutoShotgun(Other.Weapon) != none )
	{
		Recoil = 0.70 - 0.01 * float(KFPRI.ClientVeteranSkillLevel);
	}
	
	Return Recoil;
}

static function float GetBodyArmorDamageModifier(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel < 6 )
	{
		return 0.625;
	}
	else
	{
		return 1.0 / (2.0 + 0.5*float(KFPRI.ClientVeteranSkillLevel-6)/5);
	}
}

static function float GetWeldSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
	return 1.33 + 0.017 * float(KFPRI.ClientVeteranSkillLevel);
}

static function float GetWeldArmorSpeedModifier(SRPlayerReplicationInfo SRPRI)
{
	local string weapon;

	weapon = (SRPRI).Weapon;
	if ( Mid(weapon, 7, 1) == "3" ||  Mid(weapon, 7, 1) == "5" ||  Mid(weapon, 7, 1) == "7" ||  Mid(weapon, 7, 1) == "4" )
		return 2.0 + 0.075 * float(SRPRI.ClientVeteranSkillLevel);
	else
		return 2.0 + 0.05 * float(SRPRI.ClientVeteranSkillLevel);
}
static function bool CanWeldMaxArmor(SRPlayerReplicationInfo SRPRI)
{
	return true;
}
static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	local int ret;
	local string weapon;
	local SRPlayerReplicationInfo SRPRI;
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	SRPRI = SRPlayerReplicationInfo(KFPRI);

	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	
	ret = 4; // 19 веса
	
	if ( Mid(weapon, 7, 1) == "C"  )
	{
		ret = 55;
	}
	else if ( SRPRI.ClientVeteranSkillLevel > 5 && SRPRI.HasSkinGroup("Wapik") )
	{
		ret = 22 + 3 * ((KFPRI.ClientVeteranSkillLevel-1)/5);
	}
	else if ( KFPRI.ClientVeteranSkillLevel > 5 && !SRPRI.HasSkinGroup("Wapik") )
	{
		ret = 6 + 3 * ((KFPRI.ClientVeteranSkillLevel-1)/5);
	}
	
	return ret + Super.AddCarryMaxWeight(KFPRI);
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'SupportAmmoNade';
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
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float ret;
	
	ret = 1.0;
	
	if ( Item == class'ThompsonPickup'
	|| Item == class'SA80LSWPickup'
	|| Item == class'PKMPickup'
	|| Item == class'M249Pickup' 
	|| Item == class'HK23ESAPickup'
	|| Item == class'BerettaPx4Pickup'
	|| Item == class'DualBerettaPx4Pickup'
	|| Item == class'RPK47Pickup'
	|| Item == class'RPKPickup'
	|| Item == class'WeldShotPickup'
	|| Item == class'StingerPickup'
	|| Item == class'AUG_A1MGPickup'
	|| Item == class'M134DTPickup'
	|| Item == class'PKPDTPickup'
	|| Item == class'LaserRCWPickup'
	|| Item == class'PKPDTCPickup'
	|| Item == class'PKMCPickup'
	|| Item == class'K3LMGPickup'
	|| Item == class'ZEDGunLLIPickup'
	|| Item == class'XMV850Pickup'
	|| Item == class'THR40DTPickup'
	|| Item == class'LaserGutlingPickup'
	|| Item == class'ZEDGunMLLIPickup'
	|| Item == class'AK47JPickupM'
	|| Item == class'PatGunPickup'
	|| Item == class'PatGunPickupS'
	|| Item == class'M134DTRPickup'
	|| Item == class'M134DTWPickup'
	|| Item == class'ultimaxGALPickup'  )
	{
		ret = GetDefaultCostScaling(KFPRI.ClientVeteranSkillLevel);
	}

	if ( Item == class'Vest' )
	{
		ret *= 0.5;
	}

	return ret;
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

	if ( KFPRI.ClientVeteranSkillLevel > 5 && KFPRI.ClientVeteranSkillLevel < 11 && Mid(weapon, 7, 1) != "C" && Mid(weapon, 7, 1) != "F" && !SRPRI.HasSkinGroup("DeathWeap") )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.ThompsonSubmachineGun", GetCostScaling(KFPRI, class'ThompsonPickup'));

	if ( KFPRI.ClientVeteranSkillLevel > 10 && KFPRI.ClientVeteranSkillLevel < 16 && Mid(weapon, 7, 1) != "C" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SA80LSW", GetCostScaling(KFPRI, class'SA80LSWPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 15 
		&& KFPRI.ClientVeteranSkillLevel < 21 
		&& Mid(weapon, 7, 1) != "C" 
		&& Mid(weapon, 7, 1) != "4"
		&& !SRPRI.HasSkinGroup("PKPRespawn") )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.RPK47MachineGun", GetCostScaling(KFPRI, class'RPK47Pickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 15 && !SRPRI.HasSkinGroup("ZiC3") )
		P.ShieldStrength += 20;
		
	if ( KFPRI.ClientVeteranSkillLevel > 20 && KFPRI.ClientVeteranSkillLevel < 36 && Mid(weapon, 7, 1) != "4" && Mid(weapon, 7, 1) != "C" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.M249", GetCostScaling(KFPRI, class'M249Pickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 25 && KFPRI.ClientVeteranSkillLevel < 36 && Mid(weapon, 7, 1) != "C" && Mid(weapon, 7, 1) != "4" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SA80LSW", GetCostScaling(KFPRI, class'SA80LSWPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 25 && !SRPRI.HasSkinGroup("ZiC3") )
		P.ShieldStrength += 15;
		
	if ( KFPRI.ClientVeteranSkillLevel > 30 
		&& Mid(weapon, 7, 1) != "C" 
		&& Mid(weapon, 7, 1) != "4"
		&& !SRPRI.HasSkinGroup("ZiC3") )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.ThompsonSubmachineGun", GetCostScaling(KFPRI, class'ThompsonPickup'));
	
	if ( KFPRI.ClientVeteranSkillLevel > 30 && !SRPRI.HasSkinGroup("ZiC3") )
		P.ShieldStrength += 20;
		
	if ( KFPRI.ClientVeteranSkillLevel > 35 
		&& Mid(weapon, 7, 1) != "C" 
		&& Mid(weapon, 7, 1) != "C" 
		&& !SRPRI.HasSkinGroup("DeathWeap")
		&& !SRPRI.HasSkinGroup("ZiC3"))
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.PKM", GetCostScaling(KFPRI, class'PKMPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 35 
		&& Mid(weapon, 7, 1) != "C" 
		&& Mid(weapon, 7, 1) != "4" 
		&& !SRPRI.HasSkinGroup("ZiC3")
		&& !SRPRI.HasSkinGroup("PKPRespawn") )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.RPK47MachineGun", GetCostScaling(KFPRI, class'RPK47Pickup'));
		
	if ( Mid(weapon, 7, 1) == "C" )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.RPK", GetCostScaling(KFPRI, class'RPKPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.PKPDTC", GetCostScaling(KFPRI, class'PKPDTCPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.PKMC", GetCostScaling(KFPRI, class'PKMCPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.Stinger", GetCostScaling(KFPRI, class'StingerPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.XMV850", GetCostScaling(KFPRI, class'XMV850Pickup'));
	}
	if ( SRPRI.HasSkinGroup("PKPRespawn") )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.PKPDT", GetCostScaling(KFPRI, class'PKPDTPickup'));
	}
		
	if ( Mid(weapon, 7, 1) == "4" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.ZEDGunMLLI", GetCostScaling(KFPRI, class'ZEDGunMLLIPickup'));
	
	if ( Mid(weapon, 7, 1) == "Z" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.ZEDGunLLI", GetCostScaling(KFPRI, class'ZEDGunLLIPickup'));
	
	if ( Mid(weapon, 7, 1) == "F" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.K3LMGAssaultRifle", GetCostScaling(KFPRI, class'K3LMGPickup'));
			
	if ( SRPRI.HasSkinGroup("DeathWeap") )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.LaserRCW", GetCostScaling(KFPRI, class'LaserRCWPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.LaserGutling", GetCostScaling(KFPRI, class'LaserGutlingPickup'));
	}		
	if ( SRPRI.HasSkinGroup("ZiC3") )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.XMV850", GetCostScaling(KFPRI, class'XMV850Pickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.FNC30AssaultRifle", GetCostScaling(KFPRI, class'FNC30Pickup'));
	}		
	if ( KFPRI.ClientVeteranSkillLevel > 35 && !SRPRI.HasSkinGroup("ZiC3") )
		P.ShieldStrength += 20;	
	
	if ( SRPRI.HasSkinGroup("ZiC3") )
	{
		P.ShieldStrength += 200;

		for(I=P.Inventory; I!=none; I=I.Inventory)
		{
			if ( Frag1_(I) != none )
			{
				Frag1_(I).AddAmmo(10,0);
			}
		}
	}
}

static function string GetCustomLevelInfo( byte Level )
{
	local string S;
	local float Add;
	
	S = "";
	
	/*if ( Level > 0 )
	{
		S = "+" $ GetPercentStr(0.02*float(Level)) $ default.PerkDescription[0];
	}*/

	if ( Level >= 0 )
	{
		S = "+" $ GetPercentStr(0.2 + 0.025*float(Level)) $ default.PerkDescription[0];
	}

	S = S $ GetPercentStr(0.30 + 0.01 * float(Level)) $ default.PerkDescription[1];
	
	S = S $ "+" $ GetPercentStr(0.33 + 0.06 * FMax(0.0,float((Level-1)/5))) $ default.PerkDescription[2];
	
	S = S $ "+" $ GetPercentStr(1.0 + 0.05 * float(Level)) $ default.PerkDescription[3];
	
	if ( Level < 6 )
	{
		S = S $ "x1.6";
	}
	else
	{
		S = S $ "x" $ string(2+(Level-6)/10) $ "." $ string(5*(((Level+4)/5)%2));
	}
	
	S = S $ default.PerkDescription[4];
	
	S = S $ GetPercentStr(0.20 + 0.01*float(int(100.0*0.0075*float(Level)))) $ default.PerkDescription[5];
	
	if ( Level < 6 )
	{
		Add = 19.0;
	}
	else
	{
		Add = 21.0 + 3.0 * float((Level-1)/5);
	}
	
	S = S $ default.PerkDescription[6] $ string(int(Add)) $ default.PerkDescription[7];
	
	if ( Level < 6 )
	{
		Add = 5.0;
	}
	else
	{
		Add = 6.0 + 2.0 * float((Level-1)/5);
	}
	
	S = S $ default.PerkDescription[6] $ string(int(Add)) $ default.PerkDescription[8];
	
	S = S $ GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[9];
	
	S = S $ default.PerkDescription[10] $ string(Max(0,(Level-1)/5)) $ default.PerkDescription[11];
	
	S = S $ default.PerkDescription[27] $ GetPercentStr(0.025 * float(Level)) $ default.PerkDescription[28];
	
	if ( Level < 6 )
	{
		S = S $ default.PerkDescription[26];
	}
	else
	{
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
			
			S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[13];
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
		
		if ( Level > 30 )
		{
			Add = 16.0;
			
			if ( Level > 35 )
			{
				Add = 24.0;
			}
			
			S = S $ default.PerkDescription[16] $ string(int(Add)) $ default.PerkDescription[17];
		}
	}
	
	S = S $ default.PerkDescription[18];
	
	if ( Level < 6 )
	{
		S = S $ default.PerkDescription[12];
	}
	else
	{
		S = S $ default.PerkDescription[18+(Level-1)/5];
	}

	return S;
}

static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI, class<KFMonster> MonsterClass)
{
	local float ret;
	
	ret = 0.7;
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
}

defaultproperties
{
	PerkDescription(0)=" урона пулеметами|"
	PerkDescription(1)=" уменьшение отдачи у пулеметов|"
	PerkDescription(2)=" к запасу патронов пулеметов|"
	PerkDescription(3)=" к скорости заваривания брони|"
	PerkDescription(4)=" прочность брони|"
	PerkDescription(5)=" уменьшение урона от ближних атак|"
	PerkDescription(6)="Может переносить "
	PerkDescription(7)=" ед. веса|"
	PerkDescription(8)=" ящиков с патронами|"
	PerkDescription(9)=" скидка на пулеметы|"
	PerkDescription(10)=" Ранг "
	PerkDescription(11)=", бонусы:|"
	PerkDescription(12)="Beretta Px4"
	PerkDescription(13)=" к боезапасу не профильного оружия|"
	PerkDescription(14)=" к скорости бега|"
	PerkDescription(15)=" скорости восстановления шприца|"
	PerkDescription(16)="Видит здоровье монстров с "
	PerkDescription(17)=" метров|"
	PerkDescription(18)="Особенности перка:|Любое профильное оружие джаггернаута обладает 80% пробивной способностью|Стартовый инвентарь:|"
	PerkDescription(19)="Galil ARM"
	PerkDescription(20)="Beretta Px4, SA-80 LSW"
	PerkDescription(21)="Beretta Px4, РПК-47, 20 ед. брони"
	PerkDescription(22)="M249 SAW, Beretta Px4, 20 ед. брони"
	PerkDescription(23)="M249 SAW, SA-80 LSW, Beretta Px4, 35 ед. брони"
	PerkDescription(24)="M249 SAW, SA-80 LSW, Galil ARM, Beretta Px4, 55 ед. брони"
	PerkDescription(25)="ПКМ, РПК-47, Galil ARM, Beretta Px4, 75 ед. брони"
	PerkDescription(26)="Нет|"
	PerkDescription(27)="Видит здоровье и броню игрока дальше на "
	PerkDescription(28)="|"
	
   	NumRequirements=2
	PerkIndex=7

	IconMat1 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Green'
	IconMat2 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Orange'
	IconMat3 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Blue'
	IconMat4 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Purple'
	IconMat5 = Texture'SunriseHUD.Icons.Perk_Juggernaut_1Red'
	IconMat6 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Silver'
	IconMat7 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Dark'
	IconMat8 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Gold'
	IconMat9 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Master'
	IconMat10 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Elite'
	
    VeterancyName="Джаггернаут"
    Requirements(0)="Заварить %x ед. брони"
    Requirements(1)="Нанести %x повреждений пулеметами"
}
