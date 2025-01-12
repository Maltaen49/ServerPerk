class SRVetGunFighter extends SRVeterancyTypes
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
	return Min(StatOther.RGunfighterDamageStat,FinalInt);
}

static function int GetMaxArmor(KFPlayerReplicationInfo KFPRI)
{
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;
	local int level;
	level = 1;
	
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	
	if(KFPRI != none)
		level = KFPRI.ClientVeteranSkillLevel;
	
	if(level > 40 && Mid(weapon, 9, 1) == "N")
		return 300;
	else if(level > 40 && Mid(weapon, 9, 1) != "N")
		return 200;

	return 100;

}
/*static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	FinalInt = PerkLevelRequirement(CurLevel,ReqNum);
	return Min(StatOther.RGunfighterDamageStat,FinalInt);
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

static function float GetHeadShotDamMulti(KFPlayerReplicationInfo KFPRI, KFPawn P, class<DamageType> DmgType)
{
	local float ret;

	if ( class<DamTypeGunfighter>(DmgType) != none && class<DamTypeHeadshotFragGF>(DmgType) == none )
	{
		if ( KFPRI.ClientVeteranSkillLevel >= 0 )
		{
			ret = 2.0 + 0.0875 * float(KFPRI.ClientVeteranSkillLevel);
		}
		
	}
	else if ( class<DamTypeHeadshotFragGF>(DmgType) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel >= 0 )
		{
			ret = 1.50;
		}
	}
	else
	{
		ret = 1.0;
	}

	return ret * Super.GetHeadShotDamMulti(KFPRI,P,DmgType);
}

/*static function float GetHeadShotDamMulti(KFPlayerReplicationInfo KFPRI, KFPawn P, class<DamageType> DmgType)
{
	local float ret;

	if ( class<DamTypeGunfighter>(DmgType) != none && class<DamTypeHeadshotFragGF>(DmgType) == none )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 1.55 + 0.05 * float(KFPRI.ClientVeteranSkillLevel);
		}
		else
		{
			ret = 1.50 + 0.10 * float(KFPRI.ClientVeteranSkillLevel);
		}
	}
	else if ( class<DamTypeHeadshotFragGF>(DmgType) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel > 0 )
		{
			ret = 1.50;
		}
	}
	else
	{
		ret = 1.0;
	}

	return ret * Super.GetHeadShotDamMulti(KFPRI,P,DmgType);
}*/

static function float DecapDamageModifier(PlayerReplicationInfo PRI, Pawn Victim, class<DamageType> DmgType)
{
	return GetHeadShotDamMulti(KFPlayerReplicationInfo(PRI), KFPawn(Victim),DmgType) * 0.5;//1.7;
}

static function float CritDamageModifier(SRPlayerReplicationInfo SRPRI)
{
	local float ret;
	
	ret = 1.00 + 0.05 * float(SRPRI.ClientVeteranSkillLevel);
		
	ret += 1.0;
	
	return ret;
}

static function float AimBonus(SRPlayerReplicationInfo SRPRI)
{
	return 0.0075 * float(SRPRI.ClientVeteranSkillLevel);
}

/*static function float AimBonus(SRPlayerReplicationInfo SRPRI)
{
	return 1.40 + 0.01 * float(SRPRI.ClientVeteranSkillLevel);
}*/

static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil)
{
	if ( Winchester(Other.Weapon) != none
		|| SingleM(Other.Weapon) != none
		|| HK1911LLIPistol(Other.Weapon) != none
		|| DeagleK(Other.Weapon) != none
		|| Dualies(Other.Weapon) != none
		|| M14EBRBattleRifle(Other.Weapon) != none
		|| Magnum44PistolM(Other.Weapon) != none
		|| WinchesterM(Other.Weapon) != none
		|| M14EBRBattleRifleM(Other.Weapon) != none
		|| Colt1911(Other.Weapon) != none
		|| DualColt1911(Other.Weapon) != none
		|| BornBeastSA(Other.Weapon) != none
		|| ACR10AssaultRifle(Other.Weapon) != none
		|| FnFalACOG(Other.Weapon) != none
		|| ACRArthurSAAssaultRifle(Other.Weapon) != none
		|| MK23New(Other.Weapon) != none
		|| M76LLIBattleRifle(Other.Weapon) != none
		|| G43LLI(Other.Weapon) != none
		|| DesertEagleLLI(Other.Weapon) != none
		|| JackalLLI(Other.Weapon) != none
		|| Jacalv2(Other.Weapon) != none
		|| Toz34LLIShotgun(Other.Weapon) != none
		|| USP45MLLI(Other.Weapon) != none
		|| WColtF(Other.Weapon) != none
		|| WColtB(Other.Weapon) != none
		|| SG556LLIBattleRifle(Other.Weapon) != none
		|| SKSBattleRifle(Other.Weapon) != none
		|| codolV2(Other.Weapon) != none
		|| RFBSA(Other.Weapon) != none
		|| CSCrossbow(Other.Weapon) != none )
	{
		Recoil = 0.40 - 0.01 * float(KFPRI.ClientVeteranSkillLevel);
		return Recoil;
	}
	Recoil = 1.0;
	Return Recoil;
}

// Modify fire speed
static function float GetFireSpeedMod(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;
	local float ret;
	
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;

	ret = 1.0;

	if ( (Mid(weapon, 9, 1) == "N") )
	{
		ret = 1.3;
	}
	if ( Winchester(Other) != none || WinchesterM(Other) != none )
	{
		ret = 1.0 + 0.03 * float(KFPRI.ClientVeteranSkillLevel);
	}
	else if ( M14EBRBattleRifleM(Other) != none )
	{
		ret = 1.0 + 0.015 * float(KFPRI.ClientVeteranSkillLevel);
	}

	return ret * Super.GetFireSpeedMod(KFPRI,Other);
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float ret;
	
	ret = 1.0;

	if ( Winchester(Other) != none || WinchesterM(Other) != none )
	{
		ret = 1.50 + 0.03 * float(KFPRI.ClientVeteranSkillLevel);
	}
	
	if ( M14EBRBattleRifle(Other) != none
		|| SingleM(Other) != none
		|| DeagleK(Other) != none
		|| HK1911LLIPistol(Other) != none
		|| DualiesM(Other) != none
		|| Magnum44PistolM(Other) != none
		|| Dual44MagnumM(Other) != none
		|| M14EBRBattleRifleM(Other) != none
		|| DualColt1911(Other) != none
		|| Colt1911(Other) != none
		|| FnFalACOG(Other) != none
		|| ACRArthurSAAssaultRifle(Other) != none
		|| WColtF(Other) != none
		|| MK23New(Other) != none
		|| M76LLIBattleRifle(Other) != none
		|| G43LLI(Other) != none
		|| SKSBattleRifle(Other) != none
		|| codolV2(Other) != none
		|| RFBSA(Other) != none
		|| DesertEagleLLI(Other) != none
		|| JackalLLI(Other) != none
		|| Jacalv2(Other) != none
		|| USP45MLLI(Other) != none
		|| WColtB(Other) != none
		|| SG556LLIBattleRifle(Other) != none
		|| CSCrossbow(Other) != none
		|| BornBeastSA(Other) != none
		|| ACR10AssaultRifle(Other) != none )
	{
		ret = 1.60 + 0.015 * float(KFPRI.ClientVeteranSkillLevel);
	}

	return ret * Super.GetReloadSpeedModifier(KFPRI,Other);
}

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	if ( SingleM(Other) != none
		|| HK1911LLIPistol(Other) != none
		|| DeagleK(Other) != none
		|| Dualies(Other) != none
		|| Colt1911(Other) != none
		|| DualColt1911(Other) != none
		|| Winchester(Other) != none
		|| WinchesterM(Other) != none
		|| M14EBRBattleRifle(Other) != none
		|| M14EBRBattleRifleM(Other) != none
		|| FnFalACOG(Other) != none
		|| ACRArthurSAAssaultRifle(Other) != none
		|| MK23New(Other) != none
		|| M76LLIBattleRifle(Other) != none
		|| G43LLI(Other) != none
		|| DesertEagleLLI(Other) != none
		|| JackalLLI(Other) != none
		|| Jacalv2(Other) != none
		|| USP45MLLI(Other) != none
		|| SG556LLIBattleRifle(Other) != none
		|| SKSBattleRifle(Other) != none
		|| codolV2(Other) != none
		|| RFBSA(Other) != none
		|| BornBeastSA(Other) != none
		|| ACR10AssaultRifle(Other) != none
		|| CSCrossbow(Other) != none )
	{
		return ( 1.15 + 0.15 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5)) );
	}

	return 1.0;
}

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	local float ret;
	
	ret = 1.0;
	
	if ( Frag1Ammo(Other) != none )
	{
		return 0.4;
	}

	if ( FN2000MgAmmo(Other) != none 
	|| BlasterAmmo(Other) != none 
	|| Armacham203Ammo(Other) != none
	|| FNC30M203Ammo(Other) != none )
	{
			ret = 0.0;
	}

	if ( Magnum44AmmoM(Other) != none || MK23NewAmmo(Other) != none || Colt1911Ammo(Other) != none
		|| DColt1911Ammo(Other) != none || DesertEagleLLIAmmo(Other) != none || DeagleKAmmo(Other) != none )
	{
		ret = ( 1.15 + 0.15 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5)) );
	}
	else if ( WinchesterAmmoM(Other) != none || USP45MLLIAmmo(Other) != none || SingleAmmoM(Other) != none || HK1911LLIAmmo(Other) != none )
	{
		ret = ( 1.10 + 0.10 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5)) );
	}

	return ret * Super.GetAmmoPickupMod(KFPRI,Other);
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	if ( AmmoType == class'GrenadePistolLLILAmmo'
		|| AmmoType == class'FNC30M203Ammo'
		|| AmmoType == class'Armacham203Ammo' ) return 1.0;
	
	if (  AmmoType == class'Frag1Ammo' )
	{
		return 1.00 + 0.20 * float(KFPRI.ClientVeteranSkillLevel/4);
	}
	
	if ( AmmoType == class'Magnum44AmmoM' || AmmoType == class'MK23NewAmmo'
		|| AmmoType == class'Colt1911Ammo' || AmmoType == class'DColt1911Ammo'
		|| AmmoType == class'DesertEagleLLIAmmo' || AmmoType == class'DeagleKAmmo' )
	{
		return ( 1.15 + 0.15 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5)) );
	}
	else if ( AmmoType == class'WinchesterAmmoM' )
	{
		return ( 1.10 + 0.10 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5)) );
	}
	else if ( AmmoType == class'SingleAmmoM' || AmmoType == class'HK1911LLIAmmo' || AmmoType == class'USP45MLLIAmmo' )
	{
		return ( 1.10 + 0.05 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5)) );
	}
	return 1.0;
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	local SRPlayerReplicationInfo SRPRI;
	
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	
	if (SRPRI.HasSkinGroup("Mortal"))
		return class'GunfighterNadeM';
	else 
		return class'GunfighterNade';
}

static function float GetMeleeMovementSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
	return 0.00;
}

// Бонусы, зависящие от загруженности игрока

static function float GetMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
	local float Bonus;
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;
	
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	if (Mid(weapon, 9, 1) == "N")
	Bonus = 0.48 + 0.02 * float(Max(0,(SRPRI.ClientVeteranSkillLevel-1)/5)); // до 32% увеличения скорости бега
	else if (Mid(weapon, 9, 1) != "N")
	Bonus = 0.18 + 0.02 * float(Max(0,(SRPRI.ClientVeteranSkillLevel-1)/5)); // до 32% увеличения скорости бега
	
	if ( KFHumanPawn(SRPRI.Cont.Pawn).CurrentWeight < 5.99 ) // носит с собой только один пистолет
	{
		Bonus *= 1.5;
	}
	else if ( DesertEagleLLI(KFHumanPawn(SRPRI.Cont.Pawn).Weapon) != none && KFHumanPawn(SRPRI.Cont.Pawn).CurrentWeight < 7.99 )
	{
		Bonus *= 1.5;
	}
	else if ( JackalLLI(KFHumanPawn(SRPRI.Cont.Pawn).Weapon) != none && KFHumanPawn(SRPRI.Cont.Pawn).CurrentWeight < 7.99 )
	{
		Bonus *= 1.5;
	}
	else if ( Jacalv2(KFHumanPawn(SRPRI.Cont.Pawn).Weapon) != none && KFHumanPawn(SRPRI.Cont.Pawn).CurrentWeight < 7.99 )
	{
		Bonus *= 1.5;
	}
	else if ( ACR10AssaultRifle(KFHumanPawn(SRPRI.Cont.Pawn).Weapon) != none && KFHumanPawn(SRPRI.Cont.Pawn).CurrentWeight < 7.99 )
	{
		Bonus *= 1.5;
	}
	else if ( BornBeastSA(KFHumanPawn(SRPRI.Cont.Pawn).Weapon) != none && KFHumanPawn(SRPRI.Cont.Pawn).CurrentWeight < 7.99 )
	{
		Bonus *= 1.5;
	}
	else if ( KFHumanPawn(SRPRI.Cont.Pawn).CurrentWeight < 9.99 ) // не взял боевую винтовку, максимум Винчестер + МК23
	{
		Bonus *= 1.25;
	}
	
	if ( KFHumanPawn(SRPRI.Cont.Pawn).ShieldStrength > 0 )
	{
		Bonus *= FMax(1.0 - (0.4 / 100.0) * KFHumanPawn(SRPRI.Cont.Pawn).ShieldStrength, 0.6);
		//Bonus *= 0.75;//0.5;// понижение бонуса к скорости бега, если игрок носит броню
	}
	
	if ( Knife(KFHumanPawn(SRPRI.Cont.Pawn).Weapon) != none
		|| Machete(KFHumanPawn(SRPRI.Cont.Pawn).Weapon) != none ) // Сохраняем бонус к скорости бега с ножом и мачете
	{
		Bonus = FMax(0.1,Bonus);
	}
	
	return 1.0 + Bonus;
}

static function float CritStrikeChance(SRPlayerReplicationInfo SRPRI)
{
	local float Bonus;
	
	Bonus = 0.10 + 0.005 * float(SRPRI.ClientVeteranSkillLevel); // до 30% шанса крит удара
	
	if ( KFHumanPawn(SRPRI.Cont.Pawn).CurrentWeight < 5.99 ) // носит с собой только один пистолет
	{
		Bonus *= 1.5;
		if ( Magnum44PistolM(KFHumanPawn(SRPRI.Cont.Pawn).Weapon) != none )
		{
			Bonus += 6.0;//8.0;
		}
	}
	else if ( DesertEagleLLI(KFHumanPawn(SRPRI.Cont.Pawn).Weapon) != none && KFHumanPawn(SRPRI.Cont.Pawn).CurrentWeight < 7.99 )
	{
		Bonus *= 1.5;
	}
	else if ( JackalLLI(KFHumanPawn(SRPRI.Cont.Pawn).Weapon) != none && KFHumanPawn(SRPRI.Cont.Pawn).CurrentWeight < 7.99 )
	{
		Bonus *= 1.5;
	}
	else if ( Jacalv2(KFHumanPawn(SRPRI.Cont.Pawn).Weapon) != none && KFHumanPawn(SRPRI.Cont.Pawn).CurrentWeight < 7.99 )
	{
		Bonus *= 1.5;
	}
	else if ( ACR10AssaultRifle(KFHumanPawn(SRPRI.Cont.Pawn).Weapon) != none && KFHumanPawn(SRPRI.Cont.Pawn).CurrentWeight < 7.99 )
	{
		Bonus *= 1.5;
	}
	else if ( BornBeastSA(KFHumanPawn(SRPRI.Cont.Pawn).Weapon) != none && KFHumanPawn(SRPRI.Cont.Pawn).CurrentWeight < 7.99 )
	{
		Bonus *= 1.5;
	}
	else if ( KFHumanPawn(SRPRI.Cont.Pawn).CurrentWeight < 9.99 ) // не взял боевую винтовку, максимум Винчестер + МК23
	{
		Bonus *= 1.25;
		if ( Magnum44PistolM(KFHumanPawn(SRPRI.Cont.Pawn).Weapon) != none )
		{
			Bonus += 3.0;//4.0;
		}
	}
	
	/*if ( KFHumanPawn(SRPRI.Cont.Pawn).ShieldStrength > 0 )
	{
		Bonus *= 0.5; // понижение шанса крита, если игрок носит броню
	}*/
	
	return Bonus;
}

static function float Resistance(SRPlayerReplicationInfo SRPRI)
{
	if ( KFHumanPawn(SRPRI.Cont.Pawn).ShieldStrength > 0 ) // Пока в броне, слаб против Рыцаря Смерти так же как и все перки
	{
		return 0.05;
	}

	if ( KFHumanPawn(SRPRI.Cont.Pawn).CurrentWeight < 5.99 ) // носит с собой только один пистолет
	{
		return 0.95;
	}
	else if ( KFHumanPawn(SRPRI.Cont.Pawn).CurrentWeight < 9.99 ) // не взял боевую винтовку, максимум Винчестер + МК23
	{
		return 0.65;
	}

	return 0.35; // Даже если загружен, без брони он лучше сопротивляется притягиванию Рыцаря
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'M14EBRPickup'
		|| Item == class'MK23NewPickup'
		|| Item == class'Magnum44PickupM' 
		|| Item == class'M14EBRPickupM'
		|| Item == class'Colt1911Pickup'
		|| Item == class'DualColt1911Pickup'
		|| Item == class'FnFalACOGPickup'
		|| Item == class'ACRArthurSAPickup'
		|| Item == class'M76LLIPickup'
		|| Item == class'DesertEagleLLIPickup'
		|| Item == class'JackalLLIPickup'
		|| Item == class'Jacalv2Pickup'
		//|| Item == class'DualDesertEagleLLIPickup'
		|| Item == class'toz34LLIShotgunPickup'
		|| Item == class'USP45MLLIPickup'
		|| Item == class'WColtBPickup'
		|| Item == class'WColtFPickup'
		|| Item == class'SG556LLIPickup'
		|| Item == class'SKSPickup'
		|| Item == class'codolPickupV2'
		|| Item == class'RFBSAPickup'
		|| Item == class'CSCrossbowPickup'
		|| Item == class'BornBeastSAPickup'
		|| Item == class'ACR10Pickup'
		|| Item == class'BlasterPickup'  )
		return GetDefaultCostScaling(KFPRI.ClientVeteranSkillLevel);

	if ( Item == class'Vest' )
	{
		return 0.50;
	}
	
	return 1.0;
}

// Give Extra Items as Default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	local string weapon;
	local SRPlayerReplicationInfo SRPRI;
  
	Super.AddDefaultInventory(KFPRI,P);

	SRPRI = SRPlayerReplicationInfo(KFPRI);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;

	if ( SRPlayerReplicationInfo(KFPRI).bRespawned )
		return;
		
	SRPlayerReplicationInfo(KFPRI).bRespawned = true;

	if (SRPRI.HasSkinGroup("Tliona"))
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.DamTypeACR10AssaultRifle", GetCostScaling(KFPRI, class'ACR10Pickup'));

	if ( KFPRI.ClientVeteranSkillLevel > 5 && KFPRI.ClientVeteranSkillLevel < 11
	|| KFPRI.ClientVeteranSkillLevel > 15 && KFPRI.ClientVeteranSkillLevel < 21
	|| KFPRI.ClientVeteranSkillLevel > 25 && KFPRI.ClientVeteranSkillLevel < 31
	|| KFPRI.ClientVeteranSkillLevel > 35)
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.MK23New", GetCostScaling(KFPRI, class'MK23NewPickup'));
	}
		
	if ( KFPRI.ClientVeteranSkillLevel > 10 && KFPRI.ClientVeteranSkillLevel < 16
	|| KFPRI.ClientVeteranSkillLevel > 20 && KFPRI.ClientVeteranSkillLevel < 31 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.Colt1911", GetCostScaling(KFPRI, class'Colt1911Pickup'));
	}

	if ( KFPRI.ClientVeteranSkillLevel > 15 && KFPRI.ClientVeteranSkillLevel < 31 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.WinchesterM", GetCostScaling(KFPRI, class'WinchesterPickupM'));
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 30 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.M14EBRBattleRifleM", GetCostScaling(KFPRI, class'M14EBRPickupM'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.DesertEagleLLI", GetCostScaling(KFPRI, class'DesertEagleLLIPickup'));
	}
	
	if ( SRPRI.HasSkinGroup("DeathWeap") )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SKSBattleRifle", GetCostScaling(KFPRI, class'SKSPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.JackalLLI", GetCostScaling(KFPRI, class'JackalLLIPickup'));
	}		

	if ( KFPRI.ClientVeteranSkillLevel > 35 )
		P.ShieldStrength += 100;
}

static function string GetCustomLevelInfo( byte Level )
{
	local KFPlayerReplicationInfo KFPRI;
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;
	local string S;
	local float Add;
	
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;

	/*if ( Level < 6 )
	{
		Add = 0.55 + 0.05 * float(Level);
	}
	else
	{
		Add = 0.50 + 0.10 * float(Level);
	}*/
	
	if ( Level >= 0 )
	{
		Add = 1.0 + 0.0875 * float(Level);
	}
	
	S = "+" $ GetPercentStr(Add) $ default.PerkDescription[0];
	
	S = S $ GetPercentStr(0.60 + 0.01 * float(Level)) $ default.PerkDescription[1];
	
	S = S $ "+" $ GetPercentStr(0.60 + 0.015 * float(Level)) $ default.PerkDescription[2];
	
	if ( Level < 6 )
	{
		Add = 0.15;
	}
	else
	{
		Add = 0.15 + 0.15 * float((Level-1)/5);
	}
	
	S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[3];

	S = S $ GetPercentStr(0.0075 * float(Level)) $ default.PerkDescription[4];
	
	S = S $ default.PerkDescription[5] $ string(5+Level/4) $ default.PerkDescription[6];
	
	S = S $ GetPercentStr(0.10 + 0.01 * float(Level/2)) $ default.PerkDescription[7];
	
	S = S $ default.PerkDescription[8] $ GetPercentStr(1.0 + 0.05 * float(Level)) $ default.PerkDescription[9];
	
	S = S $ GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[10];
	
	S = S $ default.PerkDescription[11] $ string(Max(0,(Level-1)/5)) $ default.PerkDescription[12];
	
	if ( Level < 6 )
	{
		if (Mid(weapon, 9, 1) == "N")
			Add = 0.48;
		else if (Mid(weapon, 9, 1) != "N")
			Add = 0.18;
	}
	else
	{
		if (Mid(weapon, 9, 1) == "N")
			Add = 0.48 + 0.02 * float((Level-1)/5);
		else if (Mid(weapon, 9, 1) != "N")
			Add = 0.18 + 0.02 * float((Level-1)/5);
	}

	S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[13];
	
	if ( Level > 20 )
	{
		Add = 0.0;
			
		if ( Level > 30 )
		{
			Add = 0.65;
		}
		else // if ( Level > 20 )
		{
			Add = 0.40;
		}
			
		S = S $ "+" $ string(Add) $ default.PerkDescription[14];
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
	
	S = S $ default.PerkDescription[17];
	
	S = S $ default.PerkDescription[18+(Level-1)/5];
	
	return S;
}

static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI, class<KFMonster> MonsterClass)
{
	local float ret;
	
	ret = 0.6;
	
	if ( class<DKHusk>(MonsterClass) != none || class<DKDemolisher>(MonsterClass) != none )
	{
		ret = 1.50;
		//return 2.00 * Super.GetMoneyReward(SRPRI,MonsterClass);
	}
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
	//return Super.GetMoneyReward(SRPRI,MonsterClass);
}

defaultproperties
{
	PerkDescription(0)=" урона пистолетами и винтовками в голову|"
	PerkDescription(1)=" уменьшение отдачи с пистолетов и винтовок|"
	PerkDescription(2)=" к скорости перезарядки пистолетов и винтовок|"
	PerkDescription(3)=" к емкости магазина|"
	PerkDescription(4)=" увеличение шанса попадания в голову|"
	PerkDescription(5)="Носит "
	PerkDescription(6)=" хедшотных гранат|"
	PerkDescription(7)=" шанс крит удара при использовании оружия перка|"
	PerkDescription(8)="Крит удары наносят +"
	PerkDescription(9)=" урона|"
	PerkDescription(10)=" скидка на пистолеты и тяжелые винтовки|"
	PerkDescription(11)="Ранг "
	PerkDescription(12)=", бонусы:"
	PerkDescription(13)=" скорости перемещения|"
	PerkDescription(14)=" скорости восстановления шприца|"
	PerkDescription(15)="Видит здоровье монстров с "
	PerkDescription(16)=" метров|"
	PerkDescription(17)="Особенности перка:|40% штраф к бонусу скорости бега, при ношении 100 брони|50% увеличение бонуса к шансу крита и скорости бега при ношении 5 и меньше блоков веса или одного Desert Eagle|25% увеличение бонуса к шансу крита и скорости бега при ношении 9 и менее блоков веса|Стартовый инвентарь:|"
	PerkDescription(18)="Нет"
	PerkDescription(19)="MK-23"
	PerkDescription(20)="Colt М1911(А1)"
	PerkDescription(21)="MK-23 и Winchester 94"
	PerkDescription(22)="Colt М1911(А1) и Winchester 94"
	PerkDescription(23)="MK-23, Colt М1911(А1) и Winchester 94"
	PerkDescription(24)="Mk-14 EBR и Desert Eagle"
	PerkDescription(25)="Mk-14 EBR, MK-23, броня и Desert Eagle"

    PerkIndex=9

	IconMat1 = Texture'SunriseHUD.Icons.Perk_Gunfighter_Green'
	IconMat2 = Texture'SunriseHUD.Icons.Perk_Gunfighter_Orange'
	IconMat3 = Texture'SunriseHUD.Icons.Perk_Gunfighter_Blue'
	IconMat4 = Texture'SunriseHUD.Icons.Perk_Gunfighter_Purple'
	IconMat5 = Texture'SunriseHUD.Icons.Perk_Gunfighter_1Red'
	IconMat6 = Texture'SunriseHUD.Icons.Perk_Gunfighter_Silver'
	IconMat7 = Texture'SunriseHUD.Icons.Perk_Gunfighter_Dark'
	IconMat8 = Texture'SunriseHUD.Icons.Perk_Gunfighter_Gold'
	IconMat9 = Texture'SunriseHUD.Icons.Perk_Gunfighter_Master'
	IconMat10 = Texture'SunriseHUD.Icons.Perk_Gunfighter_Elite'

    VeterancyName="Ганфайтер"
    Requirements(0)="Нанести %x урона пистолетами и боевыми винтовками"
}
