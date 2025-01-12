class SRVetSharpshooterHZD extends SRVetSharpshooter;

// Modify fire speed
static function float GetFireSpeedMod(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
	local float ret;
	
	ret = 1.0;
	
	if ( DeagleM(Other) != none 
	|| OpticalDeagle(Other) != none 
	|| SVU(Other) != none 
	|| L96AWPLLI(Other) != none 
	|| L96AWPSILLLI(Other) != none 
	|| Musket(Other) != none 
	|| HK417(Other) != none 
	|| VSSKSA(Other) != none 
	|| SVDLLI(Other) != none 
	|| AMJ(Other) != none )
	{
		ret = 1.5 + 0.04 * float(KFPRI.ClientVeteranSkillLevel);
	}
	if ( M99New(Other) != none
	|| CrossbowM(Other) != none
	|| M200SASniperRifle(Other) != none
	|| GaussSA(Other) != none 
	|| M82A1LLINV(Other) != none 
	|| M99ST(Other) != none 
	|| AwmDragonLLI(Other) != none 
	|| Barret_M98_Bravo(Other) != none 
	|| JNG90SA(Other) != none 
	|| M82A1LLI(Other) != none )
	{
		ret = 1.2 + 0.02 * float(KFPRI.ClientVeteranSkillLevel);
	}
	if ( B94(Other) != none
	|| AW50LLI(Other) != none )
	{
		ret = 1.2 + 0.015 * float(KFPRI.ClientVeteranSkillLevel);
	}
	
	return ret * Super.GetFireSpeedMod(KFPRI,Other);
}

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float ret;
	
	ret = 1.0;
	
	if ( HK417(Other) != none || SVU(Other) != none || OpticalDeagle(Other) != none )
	{
		ret = 2.0;
	}
	return ret;
}

static function float GetHeadShotDamMulti(KFPlayerReplicationInfo KFPRI, KFPawn P, class<DamageType> DmgType)
{
	local float ret;

	if ( DmgType == class'DamTypeSVDLLI' || DmgType == class'DamTypeAMJ'/*|| DmgType == class'DamTypeCrossbow' || DmgType == class'DamTypeCrossbowHeadShot' || DmgType == class'DamTypeSVU' */)
	{
		ret *= 2.0;
	}

	if ( DmgType == class'DamTypeGaussSA' 
	|| DmgType == class'DamTypeGaussSAAlt' 
	|| DmgType == class'DamTypeM200SA'
	|| DmgType == class'DamTypeM82A1LLIAlt' 
	|| DmgType == class'DamTypeM82A1LLI' 
	|| DmgType == class'DamTypeJNG90SA' 
	|| DmgType == class'DamTypeBarret_M98_Bravo'
	|| DmgType == class'DamTypeM82A1LLINV'
	|| DmgType == class'DamTypeM99ST'
	|| DmgType == class'DamTypeAwmDragonLLI'
	|| DmgType == class'DamTypeSVDLLI' )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 2.50;
		}
		else
		{
			ret = 2.4 + 0.09 * float(KFPRI.ClientVeteranSkillLevel);
		}
	}
	else if ( DmgType == class'DamTypeCrossbowM' || DmgType == class'DamTypeCrossbowMHeadShot' ||
		 DmgType == class'DamTypeDeagle' || DmgType == class'DamTypeDualDeagle'
		 || DmgType == class'DamTypeHK417' || DmgType == class'DamTypeHK417K' || 
		 DmgType == class'DamTypeSVU' || DmgType == class'DamTypeDualies' || DmgType == class'DamTypeSVDLLI' || DmgType == class'DamTypeMusketAlt'
		 || DmgType == class'DamTypeL96AWPLLI' || DmgType == class'DamTypeL96AWPSILLLI' || DmgType == class'DamTypeMusket' || DmgType == class'DamTypeVSSKSAAlt' || DmgType == class'DamTypeVSSKSA' ||
		 DmgType == class'DamTypeB94' || DmgType == class'DamTypeAW50LLI' || DmgType == class'DamTypeM99SR' || DmgType == class'DamTypeOpticalDeagle'
		|| DmgType == class'DamTypeWaltherP99' || DmgType == class'DamTypeFNP45SA' || DmgType == class'DamTypeDualWaltherP99' || DmgType == class'DamTypeVSSDTVip'
		|| DmgType == class'DamTypePTRSLLI' )
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
	ret += 0.05 + 0.05 * float(KFPRI.ClientVeteranSkillLevel);

	return ret*1.9;
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float ret;
	ret = 1.0;
	
	if ( AmmoType == class'GrenadePistolLLILAmmo'
		|| AmmoType == class'FNC30M203Ammo'
		|| AmmoType == class'Armacham203Ammo' ) return ret;
	
	if (  AmmoType == class'Frag1Ammo' )
	{
		return 1.00 + 0.40 * float(KFPRI.ClientVeteranSkillLevel/4);
	}
	if (  AmmoType == class'CrossbowAmmoM' )
	{
		return 1.00 + 1.00 * 2.2;
	}
	
	if ( KFPRI.ClientVeteranSkillLevel >= 0 )
	{
		ret += 0.20;
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 5 )
	{
		ret += 0.30;
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 15 )
	{
		ret += 0.20;
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 25 )
	{
		ret += 0.20;
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 35 )
	{
		ret += 0.20;
	}
	
	if ( AmmoType == class'WelderAmmo' )
	{
		ret = 1.00;
	}

	return ret;
}

static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI, class<KFMonster> MonsterClass)
{
	local float ret;
	
	ret = 0.4;
	//Log("GetMoneyReward"@MonsterClass@Super.GetMoneyReward(SRPRI,MonsterClass));
	if ( class<DKFleshPoundNew>(MonsterClass) != none || class<DKFleshpoundKF2DT>(MonsterClass) != none || class<ZombieFleshPound_XMasSR>(MonsterClass) != none )
		ret = 0.1;
	else if ( class<DKHusk>(MonsterClass) != none || class<DKDemolisher>(MonsterClass) != none )
		ret = 1.5;
	else if ( class<DKSiren>(MonsterClass) != none )
		ret = 1.0;
	else if ( class<DKScrake>(MonsterClass) != none )
		ret = 0.2;
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
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
	
	S = "+" $ GetPercentStr(Add*1.8) $ default.PerkDescription[0];
	
	S = S $ "+" $ GetPercentStr(0.05 + 0.05 * float(Level)) $ default.PerkDescription[1];
	
	S = S $ GetPercentStr(0.60 + 0.01 * float(Level)) $ default.PerkDescription[2];
	
	S = S $ GetPercentStr(0.50 + 0.01 * float(Level)) $ default.PerkDescription[3];
	
	S = S $ default.PerkDescription[4] $ string(5+Level/4) $ default.PerkDescription[5];
	
	S = S $ GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[6];
	
	S = S $ default.PerkDescription[7] $ string(Max(0,(Level-1)/5)) $ default.PerkDescription[8];
	
	
	if ( Level >= 0 )
	{
		Add = 0.0;
		if ( Level >= 0 ) Add += 0.20;
		if ( Level > 5 ) Add += 0.30;
		if ( Level > 15 ) Add += 0.20;
		if ( Level > 25 ) Add += 0.20;
		if ( Level > 35 ) Add += 0.20;
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
