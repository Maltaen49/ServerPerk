class SRVetPhantom extends SRVeterancyTypes
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
	return Min(StatOther.RSilentDamageStat,FinalInt);
}
	
static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
	local float Reduction;
	
	Reduction = 1.0;
	
	if ( class<DamTypeMineFC4LLI>(DmgType) != none || class<DamTypeTitanRocket>(DmgType) != none )
	{
		Reduction = 0;
	}

	return Reduction * Super.ReduceDamage(KFPRI,Injured,Instigator,InDamage,DmgType);
}

static function int GetMaxArmor(KFPlayerReplicationInfo KFPRI)
{
	local int level;
	local SRPlayerReplicationInfo SRPRI;
	
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	level = 1;
	if(KFPRI != none)
		level = KFPRI.ClientVeteranSkillLevel;
	
	if( SRPRI.HasSkinGroup("Mortal") )
		return 800;

	if( level > 40 && !SRPRI.HasSkinGroup("Mortal") )
		return 200;

	return 100;

}
/*static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	FinalInt = PerkLevelRequirement(CurLevel,ReqNum);
	return Min(StatOther.RSilentDamageStat,FinalInt);
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

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	local float ret;
	
	if ( Frag1Ammo(Other) != none )
	{
		return 0.4;
	}	
	ret = 1.0;

	return ret * Super.GetAmmoPickupMod(KFPRI,Other);
}

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float ret;
	local string weapon;
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	
	ret = 1.0;
	
	if ( RemingtonACRSAAssaultRifle(Other) != none 
	&& (Mid(weapon, 10, 1) == "S" || Mid(weapon, 10, 1) == "A") )
	{
		ret = 1.4;
	}
	return ret;
}

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	local float ret,cLevel;
	
	cLevel = float(KFPRI.ClientVeteranSkillLevel);
	ret = 1.00;
	if ( class<DamTypeSilent>(DmgType) != none )
	{
		if ( cLevel <= 5 ) ret = 1.50;
		else ret = 1.50 + 0.02 * (cLevel - 5.0);
	}
	else if ( class<DamTypeColdSteel>(DmgType) != none )
	{
		if ( cLevel <= 5 ) ret = 1.85;
		else ret = 1.85 + 0.03 * (cLevel - 5.0);
	}
	return ret * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
}

static function float GetFireSpeedMod(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
	local float ret;
	local SRPlayerReplicationInfo SRPRI;
	
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	ret = 1.0;
	if ( (Knife(Other) != none 
	|| NinjatoInf(Other) != none 
	|| GreatswordLLIInf(Other) != none
	|| Dagger(Other) != none 
	|| Reaper(Other) != none
	|| CrossbuzzsawKF2(Other) != none
	|| Ravager(Other) != none
	|| PyramidBladeLLI(Other) != none) 
	&& !SRPRI.HasSkinGroup("Mortal") )
		ret = 1.2 + 0.02 * float(KFPRI.ClientVeteranSkillLevel);
	if ( (Knife(Other) != none 
	|| NinjatoInf(Other) != none 
	|| GreatswordLLIInf(Other) != none
	|| Dagger(Other) != none 
	|| Reaper(Other) != none
	|| CrossbuzzsawKF2(Other) != none
	|| Ravager(Other) != none
	|| PyramidBladeLLI(Other) != none) 
	&& SRPRI.HasSkinGroup("Mortal") )
		ret = 1.604 + 0.02 * float(KFPRI.ClientVeteranSkillLevel);
	return ret * Super.GetFireSpeedMod(KFPRI,Other);
}

static function float GetMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
	local float ret;
	local SRPlayerReplicationInfo SRPRI;
	local KFWeapon KFWP;
	
	ret = 1.0;
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	KFWP = KFWeapon(SRPRI.Cont.Pawn.Weapon);
	if ( SRHumanPawn(SRPRI.Cont.Pawn).bInvisible )
		ret = ret * class<SRVeterancyTypes>(SRPRI.ClientVeteranSkill).Static.GetInvisibilitySpeedModifier(SRPRI);
	if ( KFWP != none && !SRPRI.HasSkinGroup("Mortal") && 
	( Knife(KFWP) != none 
	|| NinjatoInf(KFWP) != none 
	|| GreatswordLLIInf(KFWP) != none 
	|| Ravager(KFWP) != none
	|| CrossbuzzsawKF2(KFWP) != none
	|| PyramidBladeLLI(KFWP) != none
	|| Dagger(KFWP) != none ) )
		ret += 0.10 + 0.005 * float(KFPRI.ClientVeteranSkillLevel);
	if ( KFWP != none && SRPRI.HasSkinGroup("Mortal") && 
	( Knife(KFWP) != none 
	|| NinjatoInf(KFWP) != none 
	|| GreatswordLLIInf(KFWP) != none 
	|| Ravager(KFWP) != none
	|| CrossbuzzsawKF2(KFWP) != none
	|| PyramidBladeLLI(KFWP) != none
	|| Dagger(KFWP) != none ) )
		ret += 0.21 + 0.005 * float(KFPRI.ClientVeteranSkillLevel);
	return ret;
}

static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil)
{
	Recoil = 1.0;
	if ( PB(Other.Weapon) != none || Glock17(Other.Weapon) != none || VSSDT(Other.Weapon) != none || MAC10MPM(Other.Weapon) != none || AK12V3SAAssaultRifle(Other.Weapon) != none
		|| SCARLAssaultRifle(Other.Weapon) != none || RemingtonACRSAAssaultRifle(Other.Weapon) != none || AKC74AssaultRifle(Other.Weapon) != none || Reaper(Other.Weapon) != none
		|| SG552_Tactic(Other.Weapon) != none || m21_Cod(Other.Weapon) != none || Venom(Other.Weapon) != none || CrossbuzzsawKF2(Other.Weapon) != none )
		Recoil = 1.0 - 0.60 - 0.01 * float(KFPRI.ClientVeteranSkillLevel);
	return Recoil;
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float ret;
	local string weapon;
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	
	ret = Super.AddExtraAmmoFor(KFPRI,AmmoType);
	if ( AmmoType == class'FragAmmo' || AmmoType == class'Frag1Ammo' )
		ret = 1.0 + 0.2 * float(KFPRI.ClientVeteranSkillLevel/8);
	if ( AmmoType == class'RemingtonACRSAAmmo' && (Mid(weapon, 10, 1) == "S" || Mid(weapon, 10, 1) == "A") )
		ret = 1.9;
	return ret;
}

// Set number times Zed Time can be extended
static function int ZedTimeExtensions(KFPlayerReplicationInfo KFPRI)
{
	return Min(KFPRI.ClientVeteranSkillLevel, 5);
}

static function class<DamageType> GetMAC10DamageType(KFPlayerReplicationInfo KFPRI)
{
	return class'DamTypeMAC10MPSilent';
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'InvisNade';
}

static function float GetInvisibilityDuration(SRPlayerReplicationInfo SRPRI)
{
	local float cLevel,ret;
	
	cLevel = SRPRI.ClientVeteranSkillLevel;
	if ( cLevel <= 5 ) ret = 10.0; // 10 секунд до 6 уровня
	else ret = 10.0 + 0.2 * (cLevel - 5.0); // 17 секунд на 40 уровне
	return ret;
}

static function float GetInvisibilityAlarmTime(SRPlayerReplicationInfo SRPRI)
{
	local float cLevel,ret;
	
	cLevel = SRPRI.ClientVeteranSkillLevel;
	if ( cLevel <= 5 ) ret = 3.0;
	else ret = 3.0 + 0.0572 * (cLevel - 5.0); // 5 секунд на 40 уровне
	return ret;
}

static function float GetInvisibilitySpeedModifier(SRPlayerReplicationInfo SRPRI)
{
	local float cLevel,ret;
	
	cLevel = SRPRI.ClientVeteranSkillLevel;
	ret = 1.20 + 0.005 * cLevel;
	return ret;
}

static function float GetInvisibilityDamageModifier(SRPlayerReplicationInfo SRPRI, class<DamageType> DamageType)
{
	return 1.00;
}

static function float BackstabDamageModifer(PlayerReplicationInfo PRI, Pawn Victim, class<DamageType> DmgType)
{
	local SRPlayerReplicationInfo SRPRI;
	local float cLevel,ret;
	
	SRPRI = SRPlayerReplicationInfo(PRI);
	cLevel = SRPRI.ClientVeteranSkillLevel;
	ret = 1.00 + 0.0075 * cLevel;
	return ret;
}

static function int InvisibilityLimit(SRPlayerReplicationInfo SRPRI)
{
	local int cLevel;
	local int ret;
	
	cLevel = SRPRI.ClientVeteranSkillLevel;
	ret = 5 + cLevel/8;
	return ret;
}

static function int DecapCountPerWave(PlayerReplicationInfo PRI)
{
	local SRPlayerReplicationInfo SRPRI;
	local int cLevel,ret;
	
	SRPRI = SRPlayerReplicationInfo(PRI);
	cLevel = SRPRI.ClientVeteranSkillLevel;
	if ( cLevel >= 40 ) ret = 3;
	else if ( cLevel >= 31 ) ret = 2;
	else if ( cLevel >= 21 ) ret = 1;
	else ret = 0;
	return ret;
}

static function bool DisableInvisibilityCollision(SRPlayerReplicationInfo SRPRI)
{
	if ( SRPRI.ClientVeteranSkillLevel < 21 )
		return false;
	return true;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'DaggerPickup' 
	|| Item == class'NinjatoInfPickup' 
	|| Item == class'GreatswordLLIInfPickup' 
	|| Item == class'RavagerPickup'  
	|| Item == class'PyramidBladeLLIPickup' 
	|| Item == class'PBPickup' 
	|| Item == class'AKC74Pickup' 
	|| Item == class'SG552_TacticPickup' 
	|| Item == class'SCARLAssaultRiflePickup' 
	|| Item == class'RemingtonACRSAPickup'
	|| Item == class'StingerInfPickup'
	|| Item == class'KacChainsawSAPickup'
	|| Item == class'TitanShotgunPickup'
	|| Item == class'TitanRocketLauncherPickup'
	/*|| Item == class'VSSDTPickup'*/ 
	|| Item == class'm21_CodPickup' 
	|| Item == class'AK12V3SAPickup' 
	/*|| Item == class'ReaperPickup'*/
	|| Item == class'MAC10PickupM' 
	|| Item == class'VenomPickup' 
	|| Item == class'HolyHandGrenadeMPickup'
	|| Item == class'MineFC4LLIPickup'
	|| Item == class'CrossbuzzsawKF2Pickup' )
		return GetDefaultCostScaling(KFPRI.ClientVeteranSkillLevel);
	if ( Item == class'Vest' )
		return 0.50;
	return 1.0;
}

// Give Extra Items as Default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	local string weapon;
	Super.AddDefaultInventory(KFPRI,P);
	
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;

	if ( SRPlayerReplicationInfo(KFPRI).bRespawned )
		return;
		
	SRPlayerReplicationInfo(KFPRI).bRespawned = true;
	
	if ( (KFPRI.ClientVeteranSkillLevel >= 0 && KFPRI.ClientVeteranSkillLevel < 11 ||
		KFPRI.ClientVeteranSkillLevel >= 31 && KFPRI.ClientVeteranSkillLevel < 36) && !SRPlayerReplicationInfo(KFPRI).HasSkinGroup("Mortal") )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.PB", GetCostScaling(KFPRI, class'PBPickup'));

	if ( (KFPRI.ClientVeteranSkillLevel >= 6 && KFPRI.ClientVeteranSkillLevel < 21 ||
		KFPRI.ClientVeteranSkillLevel >= 31) && !SRPlayerReplicationInfo(KFPRI).HasSkinGroup("Mortal"))
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.Dagger", GetCostScaling(KFPRI, class'DaggerPickup'));
		
	if ( (KFPRI.ClientVeteranSkillLevel >= 11 && KFPRI.ClientVeteranSkillLevel < 16 || 
		KFPRI.ClientVeteranSkillLevel >= 21 && KFPRI.ClientVeteranSkillLevel < 26 ) && !SRPlayerReplicationInfo(KFPRI).HasSkinGroup("Mortal"))
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.MAC10MPM", GetCostScaling(KFPRI, class'MAC10PickupM'));

	if ( (KFPRI.ClientVeteranSkillLevel >= 16 && KFPRI.ClientVeteranSkillLevel < 21 || 
		KFPRI.ClientVeteranSkillLevel >= 36) && !SRPlayerReplicationInfo(KFPRI).HasSkinGroup("Mortal"))
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AKC74AssaultRifle", GetCostScaling(KFPRI, class'AKC74Pickup'));

	if ( KFPRI.ClientVeteranSkillLevel >= 26 && KFPRI.ClientVeteranSkillLevel < 36 && !SRPlayerReplicationInfo(KFPRI).HasSkinGroup("Mortal"))
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SG552_Tactic", GetCostScaling(KFPRI, class'SG552_TacticPickup'));

	if ( KFPRI.ClientVeteranSkillLevel >= 21 
	&& Mid(weapon, 10, 1) != "I" 
	&& Mid(weapon, 10, 1) != "X"
	&& !SRPlayerReplicationInfo(KFPRI).HasSkinGroup("Mortal") )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.NinjatoInf", GetCostScaling(KFPRI, class'NinjatoInfPickup'));

	if ( KFPRI.ClientVeteranSkillLevel >= 21 
	&& Mid(weapon, 10, 1) != "S" 
	&& Mid(weapon, 10, 1) != "A" 
	&& !SRPlayerReplicationInfo(KFPRI).HasSkinGroup("Mortal")
	&& (Mid(weapon, 10, 1) == "X" || Mid(weapon, 10, 1) == "I") )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.GreatswordLLIInf", GetCostScaling(KFPRI, class'GreatswordLLIInfPickup'));

	if ( SRPlayerReplicationInfo(KFPRI).HasSkinGroup("Mortal") )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.Ravager", GetCostScaling(KFPRI, class'RavagerPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.StingerInf", GetCostScaling(KFPRI, class'StingerInfPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.TitanShotgun", GetCostScaling(KFPRI, class'TitanShotgunPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.MineFC4LLIExplosive", GetCostScaling(KFPRI, class'MineFC4LLIPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.HolyHandGrenadeM", GetCostScaling(KFPRI, class'HolyHandGrenadeMPickup'));
		P.ShieldStrength += 400;
	}

	if ( SRPlayerReplicationInfo(KFPRI).HasSkinGroup("Pirate") )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.CrossbuzzsawKF2", GetCostScaling(KFPRI, class'CrossbuzzsawKF2Pickup'));
	}
	
	if ( Mid(weapon, 10, 1) == "S" || Mid(weapon, 10, 1) == "A" )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.GreatswordLLIInf", GetCostScaling(KFPRI, class'GreatswordLLIInfPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.RemingtonACRSAAssaultRifle", GetCostScaling(KFPRI, class'RemingtonACRSAPickup'));
	}

	if ( KFPRI.ClientVeteranSkillLevel >= 36 && !SRPlayerReplicationInfo(KFPRI).HasSkinGroup("Mortal") )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SCARLAssaultRifle", GetCostScaling(KFPRI, class'SCARLAssaultRiflePickup'));

	if ( KFPRI.ClientVeteranSkillLevel > 35 && !SRPlayerReplicationInfo(KFPRI).HasSkinGroup("Mortal") )
		P.ShieldStrength += 100;
}

static function string GetCustomLevelInfo( byte Level )
{
	local string S;
	local float Add;
	
	if ( Level < 6 ) Add = 0.50;
	else Add = 0.50 + 0.02 * float(Level-5);
	S = "+" $ GetPercentStr(Add) $ default.PerkDescription[0];
	if ( Level < 6 ) Add = 0.85;
	else Add = 0.85 + 0.03 * float(Level-5);
	S $= "+" $ GetPercentStr(Add) $ default.PerkDescription[1];
	S $= GetPercentStr(0.60 + 0.01 * float(Level)) $ default.PerkDescription[2];
	S $= "+" $ GetPercentStr(0.20 + 0.01 * float(Level)) $ default.PerkDescription[3];
	S $= "+" $ GetPercentStr(0.10 + 0.005 * float(Level)) $ default.PerkDescription[4];
	if ( Level > 0 ) S $= "+" $ GetPercentStr(0.01 * float(Level)) $ default.PerkDescription[5];
	S $= string(5 + Level/8) $ default.PerkDescription[6];
	S $= string(5 + Level/8) $ default.PerkDescription[7];
	S $= default.PerkDescription[8];
	ReplaceText(S,"%a",string(FMax(10.00,10.00 + 0.20 * float(Level-5))));
	S $= default.PerkDescription[9];
	ReplaceText(S,"%a",string(FMax(3.0,3.0 + 0.0572 * (Level - 5.0))));
	S $= "+" $ GetPercentStr(0.20 + 0.005 * float(Level)) $ default.PerkDescription[10];
	S $= GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[11];
	if ( Level >= 21 ) S $= default.PerkDescription[12];
	if ( Level >= 31 ) S $= default.PerkDescription[13];
	if ( Level >= 21 )
	{
		S $= default.PerkDescription[14];
		if ( Level >= 40 ) ReplaceText(S,"%a","3");
		else if ( Level >= 31 ) ReplaceText(S,"%a","2");
		else ReplaceText(S,"%a","1");
	}
	S $= default.PerkDescription[15];
	ReplaceText(S,"%a",string(Max(0,(Level-1)/5)));
	if ( Level < 6 ) S $= default.PerkDescription[16];
	else
	{
		Add = 0.0;
		if ( Level > 5 ) Add += 0.10;
		if ( Level > 15 ) Add += 0.05;
		if ( Level > 25 ) Add += 0.05;
		if ( Level > 35 ) Add += 0.05;
		S $= "+" $ GetPercentStr(Add) $ default.PerkDescription[17];
	}
	if ( Level > 10 )
	{
		Add = 0.0;
		if ( Level > 10 ) Add += 2.0;
		if ( Level > 25 ) Add += 2.00;
		if ( Level > 35 ) Add += 2.00;
		S $= "+" $ string(int(Add)) $ default.PerkDescription[18];
	}
	if ( Level > 20 )
	{
		Add = 0.40;
		if ( Level > 30 ) Add = 0.65;
		S $= "+" $ GetPercentStr(Add) $ default.PerkDescription[19];
	}
	if ( Level > 30 )
	{
		Add = 16.0;
		if ( Level > 35 ) Add = 24.0;
		S $= default.PerkDescription[20];
		ReplaceText(S,"%a",string(int(Add)));
	}
	S $= default.PerkDescription[21];
	S $= default.PerkDescription[22+Max(0,(Level-1)/5)];
	return S;
}

static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI, class<KFMonster> MonsterClass)
{
	local float ret;
	
	ret = 0.5;
	if ( class<DKScrake>(MonsterClass) != none )
	{
		ret = 0.85;
	}
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
}

defaultproperties
{
	PerkDescription(0)=" урона оружием с глушителями|"
	PerkDescription(1)=" урона холодным оружием|"
	PerkDescription(2)=" меньше отдачи оружием с глушителями|"
	PerkDescription(3)=" к скорости атаки холодным оружием|"
	PerkDescription(4)=" к скорости передвижения с холодным оружием|"
	PerkDescription(5)=" урона холодным оружием в спину|"
	PerkDescription(6)=" зарядов невидимости|"
	PerkDescription(7)=" гранат|"
	PerkDescription(8)="Невидимость длится %a секунд|"
	PerkDescription(9)="Выходит из невидимости, находясь близко к монстрам в течении %a секунд|"
	PerkDescription(10)=" к скорости перемещения во время невидимости|"
	PerkDescription(11)=" скидка на оружие с глушителями, холодное оружие и Резак|"
	PerkDescription(12)="Проходит сквозь людей и монстров во время невидимости|"
	PerkDescription(13)="Может использовать обычную атаку холодным оружием во время невидимости|"
	PerkDescription(14)="Может применить прием 'Обезглавливание' %a раз за волну|"
	PerkDescription(15)="Ранг %a, бонусы:|"
	PerkDescription(16)="Нет|"
	PerkDescription(17)=" к боезапасу|"
	PerkDescription(18)=" к переносимому весу|"
	PerkDescription(19)=" к скорости восстановления шприца|"
	PerkDescription(20)="Видит здоровье монстров с %a метров|"
	PerkDescription(21)="Особенности перка:|Гранаты вводят людей в невидимость|Не может застанить скрейка в лицо будучи видимым|Стартовый инвентарь:|"
	PerkDescription(22)="ПБ"
	PerkDescription(23)="ПБ и Dagger"
	PerkDescription(24)="MAC-10 и Dagger"
	PerkDescription(25)="AK-74 и Dagger"
	PerkDescription(26)="Ниндзято и MAC-10"
	PerkDescription(27)="Ниндзято и SG-552 Tactic"
	PerkDescription(28)="Ниндзято, SG-552 Tactic, ПБ и Dagger"
	PerkDescription(29)="Ниндзято, SCAR Mk.16, AK-74, Dagger и Броня"
	PerkDescription(30)="Нет"

    PerkIndex=11

	IconMat1 = Texture'SunriseHUD.Icons.Perk_Infiltrator_Green'
	IconMat2 = Texture'SunriseHUD.Icons.Perk_Infiltrator_Orange'
	IconMat3 = Texture'SunriseHUD.Icons.Perk_Infiltrator_Blue'
	IconMat4 = Texture'SunriseHUD.Icons.Perk_Infiltrator_Purple'
	IconMat5 = Texture'SunriseHUD.Icons.Perk_Infiltrator_1Red'
	IconMat6 = Texture'SunriseHUD.Icons.Perk_Infiltrator_Silver'
	IconMat7 = Texture'SunriseHUD.Icons.Perk_Infiltrator_Dark'
	IconMat8 = Texture'SunriseHUD.Icons.Perk_Infiltrator_Gold'
	IconMat9 = Texture'SunriseHUD.Icons.Perk_Infiltrator_Master'
	IconMat10 = Texture'SunriseHUD.Icons.Perk_Infiltrator_Elite'

    VeterancyName="Инфильтратор"
    Requirements(0)="Нанести %x урона холодным оружием и оружием с глушителями"
}
