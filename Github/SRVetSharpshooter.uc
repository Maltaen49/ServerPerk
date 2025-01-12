class SRVetSharpshooter extends SRVeterancyTypes
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
	return Min(StatOther.RHeadshotKillsStat,FinalInt);
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
	return Min(StatOther.RHeadshotKillsStat,FinalInt);
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

	if ( DmgType == class'DamTypeCrossbowM'
	|| DmgType == class'DamTypeCrossbowMHeadShot'
	|| DmgType == class'DamTypeDeagle' 
	|| DmgType == class'DamTypeDualDeagle' 
	|| DmgType == class'DamTypeSIG550SR' 
	|| DmgType == class'DamTypeSIG550SRAlt'
	|| DmgType == class'DamTypeHK417' 
	|| DmgType == class'DamTypeGaussSA' 
	|| DmgType == class'DamTypeHK417A' 
	|| DmgType == class'DamTypeGaussSAAlt' 
	|| DmgType == class'DamTypeM82A1LLINV'  
	|| DmgType == class'DamTypeM99ST' 
	|| DmgType == class'DamTypeAwmDragonLLI'  
	|| DmgType == class'DamTypeBarret_M98_Bravo' 
	|| DmgType == class'DamTypeJNG90SA' 
	|| DmgType == class'DamTypeM82A1LLI' 
	|| DmgType == class'DamTypeM82A1LLIAlt' 
	|| DmgType == class'DamTypeHK417K' 
	|| DmgType == class'DamTypeM200CSA' 
	|| DmgType == class'DamTypeVSSDTB' 
	|| DmgType == class'DamTypeSVU' 
	|| DmgType == class'DamTypeDualies'
	|| DmgType == class'DamTypeSVDLLI'
	|| DmgType == class'DamTypeAMJ'
	|| DmgType == class'DamTypeMusketAlt'
	|| DmgType == class'DamTypeL96AWPLLI' 
	|| DmgType == class'DamTypeL96AWPSILLLI'
	|| DmgType == class'DamTypeMusket' 
	|| DmgType == class'DamTypeVSSKSAAlt' 
	|| DmgType == class'DamTypeVSSKSA' 
	||	DmgType == class'DamTypeB94' 
	|| DmgType == class'DamTypeAW50LLI' 
	|| DmgType == class'DamTypeM99SR' 
	|| DmgType == class'DamTypeOpticalDeagle'
	|| DmgType == class'DamTypeOpticalDeagleW'
	|| DmgType == class'DamTypeWaltherP99' 
	|| DmgType == class'DamTypeFNP45SA' 
	|| DmgType == class'DamTypeDualWaltherP99' 
	|| DmgType == class'DamTypeVSSDTVip'
	|| DmgType == class'DamTypeM200SA' 
	|| DmgType == class'DamTypeMcMillanSA' 
	|| DmgType == class'DamTypePTRSLLI' 
	|| DmgType == class'DamTypeM200SAAlt' 
	|| DmgType == class'DamTypeVSSDTBAlt' )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 2.0;
		}
		else
		{
			ret = 2.0 + 0.05625 * float(KFPRI.ClientVeteranSkillLevel);
		}
	}
	else
	{
		ret = 1.0;
	}
	/*if ( DmgType == class'DamTypeB94' || DmgType == class'DamTypeM99SR' )
	{
		ret *= 2.5;
	}*/
	if ( DmgType == class'DamTypeSVDLLI' || DmgType == class'DamTypeAMJ'/*|| DmgType == class'DamTypeCrossbow' || DmgType == class'DamTypeCrossbowHeadShot' || DmgType == class'DamTypeSVU' */)
	{
		ret *= 2.0;
	}

	ret += 0.05 + 0.05 * float(KFPRI.ClientVeteranSkillLevel);

	return ret;
}

static function float DecapDamageModifier(PlayerReplicationInfo PRI, Pawn Victim, class<DamageType> DmgType)
{
	/*if( DKHusk(Victim) != none ||
		DKDemolisher(Victim) != none ||
		DKBloat(Victim) != none ||
		DKArchville(Victim) != none )
		return 3.0;*/
	//return 1.3;
	return GetHeadShotDamMulti(KFPlayerReplicationInfo(PRI), KFPawn(Victim),DmgType);
}

static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil)
{
	Recoil = 1.0;

	if ( Crossbow(Other.Weapon) != none 
		|| DeagleM(Other.Weapon) != none
		|| CrossbowM(Other.Weapon) != none
		|| SingleM(Other.Weapon) != none
		|| HK1911LLIPistol(Other.Weapon) != none
		|| SIG550SR(Other.Weapon) != none
		|| GaussSA(Other.Weapon) != none
		|| M82A1LLINV(Other.Weapon) != none
		|| M99ST(Other.Weapon) != none
		|| AwmDragonLLI(Other.Weapon) != none
		|| Barret_M98_Bravo(Other.Weapon) != none
		|| JNG90SA(Other.Weapon) != none
		|| M82A1LLI(Other.Weapon) != none
		|| HK417(Other.Weapon) != none 
		|| HK417A(Other.Weapon) != none 
		|| SVU(Other.Weapon) != none 
		|| VSSKSA(Other.Weapon) != none
		|| DualDeagleM(Other.Weapon) != none 
		|| L96AWPSILLLI(Other.Weapon) != none 
		|| Musket(Other.Weapon) != none
		|| L96AWPLLI(Other.Weapon) != none 
		|| SVDLLI(Other.Weapon) != none
		|| AMJ(Other.Weapon) != none
		|| B94(Other.Weapon) != none 
		|| OpticalDeagle(Other.Weapon) != none 
		|| OpticalDeagleW(Other.Weapon) != none 
		|| PTRSLLI(Other.Weapon) != none
		|| M99New(Other.Weapon) != none 
		|| WaltherP99(Other.Weapon) != none 
		|| FNP45SA(Other.Weapon) != none 
		|| AW50LLI(Other.Weapon) != none
		|| DualWaltherP99(Other.Weapon) != none 
		|| VSSDTVip(Other.Weapon) != none 
		|| VSSDTB(Other.Weapon) != none
		|| M200SASniperRifle(Other.Weapon) != none 
		|| M200CSASniperRifle(Other.Weapon) != none 
		|| McMillanSA(Other.Weapon) != none )
	{
		Recoil = 0.40 - 0.01 * float(KFPRI.ClientVeteranSkillLevel);
	}

	Return Recoil;
}

// Modify fire speed
static function float GetFireSpeedMod(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
	local float ret;
	
	ret = 1.0;
	
	if ( DeagleM(Other) != none 
		|| DualDeagleM(Other) != none 
		|| DualDeagleM(Other) != none  )
	{
		ret = 1.0 + 0.03 * float(KFPRI.ClientVeteranSkillLevel);
	}
	if ( L96AWPLLI(Other) != none || L96AWPSILLLI(Other) != none || Musket(Other) != none )
	{
		ret = 1.0 + 0.015 * float(KFPRI.ClientVeteranSkillLevel);
	}
	if ( M99New(Other) != none || CrossbowM(Other) != none
		|| OpticalDeagle(Other) != none )
	{
		ret = 1.0 + 0.0055/*0.0075*/ * float(KFPRI.ClientVeteranSkillLevel);
	}
	if ( M200SASniperRifle(Other) != none || M200CSASniperRifle(Other) != none || McMillanSA(Other) != none || SIG550SR(Other) != none )
	{
		ret = 1.23;//1.37
	}
	
	return ret * Super.GetFireSpeedMod(KFPRI,Other);
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float ret;

	if ( DeagleM(Other) != none 
		|| DualDeagleM(Other) != none
		|| M14EBRBattleRifle(Other) != none 
		|| M14EBRBattleRifleM(Other) != none 
		|| GaussSA(Other) != none
		|| M82A1LLINV(Other) != none
		|| M99ST(Other) != none
		|| AwmDragonLLI(Other) != none
		|| Barret_M98_Bravo(Other) != none
		|| JNG90SA(Other) != none
		|| M82A1LLI(Other) != none
		|| SingleM(Other) != none 
		|| HK1911LLIPistol(Other) != none 
		|| DeagleK(Other) != none 
		|| DualiesM(Other) != none 
		|| HK417(Other) != none 
		|| HK417A(Other) != none 
		|| VSSKSA(Other) != none
		|| SVU(Other) != none 
		|| L96AWPLLI(Other) != none 
		|| L96AWPSILLLI(Other) != none 
		|| Musket(Other) != none 
		|| SVDLLI(Other) != none
		|| AMJ(Other) != none
		|| B94(Other) != none 
		|| OpticalDeagle(Other) != none 
		|| OpticalDeagleW(Other) != none 
		|| DeagleK(Other) != none 
		|| WaltherP99(Other) != none 
		|| FNP45SA(Other) != none 
		|| PTRSLLI(Other) != none
		|| DualWaltherP99(Other) != none 
		|| VSSDTVip(Other) != none 
		|| AW50LLI(Other) != none 
		|| M200CSASniperRifle(Other) != none 
		|| VSSDTB(Other) != none 
		|| SIG550SR(Other) != none )
	{
		ret = 0.50 + 0.01 * float(KFPRI.ClientVeteranSkillLevel);
	}
	
	ret += 1.0;
	
	return ret * Super.GetReloadSpeedModifier(KFPRI,Other);
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	if (  AmmoType == class'Frag1Ammo' )
	{
		return 1.00 + 0.20 * float(KFPRI.ClientVeteranSkillLevel/4);
	}
	if (  AmmoType == class'CrossbowAmmoM' )
	{
		return 1.00 + 1.00 * 1.6;
	}

	return Super.AddExtraAmmoFor(KFPRI,AmmoType);
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'SharpNade';
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float ret;
	
	ret = 1.0;
	
	if ( Item == class'OpticalDeaglePickup' 
		|| Item == class'OpticalDeaglePickupW'
		|| Item == class'M14EBRPickup' 
		|| Item == class'M14EBRPickupM' 
		|| Item == class'GaussSAPickup'
		|| Item == class'HK417Pickup' 
		|| Item == class'HK417APickup' 
		|| Item == class'SVUPickup' 
		|| Item == class'VSSKSAPickup'
		|| Item == class'L96AWPLLIPickup' 
		|| Item == class'SVDLLIPickup' 
		|| Item == class'AMJPickup' 
		|| Item == class'M82A1LLIPickup'
		|| Item == class'M99NewPickup' 
		|| Item == class'L96AWPSILLLIPickup' 
		|| Item == class'McMillanSAPickup'
		|| Item == class'WaltherP99Pickup' 
		|| Item == class'DualWaltherP99Pickup' 
		|| Item == class'VSSDTBPickup'
		|| Item == class'VSSDTVipPickup' 
		|| Item == class'AW50LLIPickup' 
		|| Item == class'M200CSAPickup' 
		|| Item == class'Barret_M98_BravoPickup'
		|| Item == class'M200SAPickup' 
		|| Item == class'PTRSLLIPickup' 
		|| Item == class'MusketPickup' 
		|| Item == class'JNG90SAPickup' 
		|| Item == class'M82A1LLINVPickup'
		|| Item == class'M99STPickup'
		|| Item == class'AwmDragonLLIPickup')
	{
		ret = GetDefaultCostScaling(KFPRI.ClientVeteranSkillLevel);
	}
	
	if ( Item == class'Vest' )
	{
		ret *= 0.5;
	}

	return ret;
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

	if (Mid(weapon, 2, 1) == "V")
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.VSSKSA", GetCostScaling(KFPRI, class'VSSKSAPickup'));

	if (Mid(weapon, 2, 1) == "W")
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SIG550SR", GetCostScaling(KFPRI, class'SIG550SRPickup'));

	if (Mid(weapon, 2, 1) == "G")
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.M200CSASniperRifle", GetCostScaling(KFPRI, class'M200CSAPickup'));

	if (Mid(weapon, 2, 1) == "S")
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.VSSDTB", GetCostScaling(KFPRI, class'VSSDTBPickup'));

	if ( KFPRI.ClientVeteranSkillLevel < 6 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.WaltherP99", GetCostScaling(KFPRI, class'WaltherP99Pickup'));
	
	if ( KFPRI.ClientVeteranSkillLevel > 5 && KFPRI.ClientVeteranSkillLevel < 11 )
	{
		if (Mid(weapon, 0, 1) == "A")
		{
			KFHumanPawn(P).CreateInventoryVeterancy("Masters.L96AWPSILLLI", GetCostScaling(KFPRI, class'L96AWPSILLLIPickup'));
		}
		else
			KFHumanPawn(P).CreateInventoryVeterancy("Mswp.L96AWPLLI", GetCostScaling(KFPRI, class'L96AWPLLIPickup'));
	}
		
	if ( KFPRI.ClientVeteranSkillLevel > 10 && KFPRI.ClientVeteranSkillLevel < 21 && Mid(weapon, 2, 1) != "4")
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.HK417", GetCostScaling(KFPRI, class'HK417Pickup'));

	if ( KFPRI.ClientVeteranSkillLevel > 10 && KFPRI.ClientVeteranSkillLevel < 21 && Mid(weapon, 2, 1) == "4")
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.HK417A", GetCostScaling(KFPRI, class'HK417APickup'));

	if ( KFPRI.ClientVeteranSkillLevel > 20 && KFPRI.ClientVeteranSkillLevel < 26  )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SVU", GetCostScaling(KFPRI, class'SVUPickup'));

	if ( KFPRI.ClientVeteranSkillLevel > 15 && KFPRI.ClientVeteranSkillLevel < 31 && Mid(weapon, 2, 1) != "S" )
	{
		if (Mid(weapon, 0, 1) == "V")
		{
			KFHumanPawn(P).CreateInventoryVeterancy("Masters.VSSDTVip", GetCostScaling(KFPRI, class'VSSDTVipPickup'));
		}
		else
			KFHumanPawn(P).CreateInventoryVeterancy("Mswp.OpticalDeagle", GetCostScaling(KFPRI, class'OpticalDeaglePickup'));
	}
	if ( KFPRI.ClientVeteranSkillLevel > 25 && KFPRI.ClientVeteranSkillLevel < 36 && Mid(weapon, 2, 1) != "V" && Mid(weapon, 2, 1) != "W" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SVDLLI", GetCostScaling(KFPRI, class'SVDLLIPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 35 
	&& Mid(weapon, 2, 1) != "V" 
	&& Mid(weapon, 2, 1) != "W" 
	&& Mid(weapon, 2, 1) != "G" 
	&& Mid(weapon, 2, 1) != "S"
	&& !SRPlayerReplicationInfo(KFPRI).HasSkinGroup("STALKER1") )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AW50LLI", GetCostScaling(KFPRI, class'AW50LLIPickup'));
	
	if ( KFPRI.ClientVeteranSkillLevel > 30 )
	{
		if (Mid(weapon, 0, 1) == "V")
		{
			KFHumanPawn(P).CreateInventoryVeterancy("Masters.VSSDTVip", GetCostScaling(KFPRI, class'VSSDTVipPickup'));
		}
		else
			KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SVU", GetCostScaling(KFPRI, class'SVUPickup'));
	}

	if ( SRPlayerReplicationInfo(KFPRI).HasSkinGroup("STALKER1") )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.M99ST", GetCostScaling(KFPRI, class'M99STPickup'));
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 35 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.OpticalDeagle", GetCostScaling(KFPRI, class'OpticalDeaglePickup'));
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
		Add = 1.0 + 0.05625 * float(Level);
	}
	else
	{
		Add = 1.0 + 0.05625 * float(Level);
	}
	
	S = "+" $ GetPercentStr(Add) $ default.PerkDescription[0];
	
	S = S $ "+" $ GetPercentStr(0.05 + 0.05 * float(Level)) $ default.PerkDescription[1];
	
	S = S $ GetPercentStr(0.60 + 0.01 * float(Level)) $ default.PerkDescription[2];
	
	S = S $ GetPercentStr(0.50 + 0.01 * float(Level)) $ default.PerkDescription[3];
	
	S = S $ default.PerkDescription[4] $ string(5+Level/4) $ default.PerkDescription[5];
	
	S = S $ GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[6];
	
	S = S $ default.PerkDescription[7] $ string(Max(0,(Level-1)/5)) $ default.PerkDescription[8];
	
	if ( Level < 6 )
	{
		S = S $ default.PerkDescription[9];
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
		
		S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[10];
	}
	
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

		S = S $ "+" $ string(int(Add)) $ default.PerkDescription[11];
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
		Add = 0.0;
			
		if ( Level > 30 )
		{
			Add = 0.65;
		}
		else // if ( Level > 20 )
		{
			Add = 0.40;
		}
			
		S = S $ "+" $ string(Add) $ default.PerkDescription[13];
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
	
	S = S $ default.PerkDescription[16];
	
	S = S $ default.PerkDescription[17+(Level-1)/5];
	
	return S;
}

static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI, class<KFMonster> MonsterClass)
{
	local float ret;
	
	ret = 0.6;
	//Log("GetMoneyReward"@MonsterClass@Super.GetMoneyReward(SRPRI,MonsterClass));
	if ( class<DKFleshPoundNew>(MonsterClass) != none || class<DKFleshpoundKF2DT>(MonsterClass) != none || class<ZombieFleshPound_XMasSR>(MonsterClass) != none )
		ret = 0.2;
	else if ( class<DKHusk>(MonsterClass) != none || class<DKDemolisher>(MonsterClass) != none )
		ret = 2.5;
	else if ( class<DKSiren>(MonsterClass) != none )
		ret = 1.2;
	else if ( class<DKScrake>(MonsterClass) != none )
		ret = 0.3;
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
}

defaultproperties
{
	PerkDescription(0)=" урона снайперским оружием в голову|"
	PerkDescription(1)=" урона в голову любым оружием|"
	PerkDescription(2)=" уменьшение отдачи у снайперского оружия|"
	PerkDescription(3)=" к скорости перезарядки снайперского оружия|"
	PerkDescription(4)="Носит "
	PerkDescription(5)=" гранат|"
	PerkDescription(6)=" скидка на снайперские винтовки и пистолеты|"
	PerkDescription(7)="Ранг "
	PerkDescription(8)=", бонусы:|"
	PerkDescription(9)="Нет|"
	PerkDescription(10)=" к запасу патронов|"
	PerkDescription(11)=" ед. переносимого веса|"
	PerkDescription(12)=" к скорости бега|"
	PerkDescription(13)=" скорости восстановления шприца|"
	PerkDescription(14)="Видит здоровье монстров с "
	PerkDescription(15)=" метров|"
	PerkDescription(16)="Особенности перка:|Гранаты наносят урон в голову|Стартовый инвентарь:|"
	PerkDescription(17)="Walther P-99"
	PerkDescription(18)="L96 AWP"
	PerkDescription(19)="HK-417"
	PerkDescription(20)="HK-417, Deagle"
	PerkDescription(21)="СВУ, Deagle" 
	PerkDescription(22)="СВД-С, Deagle"
	PerkDescription(23)="СВД-С, СВУ"
	PerkDescription(24)="AW-50, СВУ, Deagle, Броня"

	PerkIndex=2

	IconMat1 = Texture'SunriseHUD.Icons.Perk_Sharpshooter_Green'
	IconMat2 = Texture'SunriseHUD.Icons.Perk_SharpShooter_Orange'
	IconMat3 = Texture'SunriseHUD.Icons.Perk_Sharpshooter_Blue'
	IconMat4 = Texture'SunriseHUD.Icons.Perk_Sharpshooter_Purple'
	IconMat5 = Texture'SunriseHUD.Icons.Perk_Sharpshooter_Red'
	IconMat6 = Texture'SunriseHUD.Icons.Perk_Sharpshooter_Silver'
	IconMat7 = Texture'SunriseHUD.Icons.Perk_Sharpshooter_Dark'
	IconMat8 = Texture'SunriseHUD.Icons.Perk_Sharpshooter_Gold'
	IconMat9 = Texture'SunriseHUD.Icons.Perk_Sharpshooter_Master'
	IconMat10 = Texture'SunriseHUD.Icons.Perk_SharpShooter_Elite'
	
	VeterancyName="Снайпер"
	Requirements[0]="Нанести %x повреждений в голову снайперским оружием"
}
