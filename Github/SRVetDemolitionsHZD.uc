class SRVetDemolitionsHZD extends SRVetDemolitions;

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
		if ( KFPRI.ClientVeteranSkillLevel >= 0 )
		{
			ret += 0.10;
		}
		
		if ( KFPRI.ClientVeteranSkillLevel > 5 )
		{
			ret += 0.20;
		}
		
		if ( KFPRI.ClientVeteranSkillLevel > 15 )
		{
			ret += 0.10;
		}
		
		if ( KFPRI.ClientVeteranSkillLevel > 25 )
		{
			ret += 0.10;
		}
		
		if ( KFPRI.ClientVeteranSkillLevel > 35 )
		{
			ret += 0.10;
		}
		
		if ( AmmoType == class'WelderAmmo' ||
			AmmoType == class'M99NewAmmo' ||
			AmmoType == class'AW50LLIAmmo' ||
			AmmoType == class'B94Ammo' ||
			AmmoType == class'PTRSLLIAmmo' ||
			AmmoType == class'M200SAAmmo' ||
			AmmoType == class'GaussSAAmmo' ||
			AmmoType == class'M82A1LLINVAmmo' ||
			AmmoType == class'M99STAmmo' ||
			AmmoType == class'AwmDragonLLIAmmo' ||
			AmmoType == class'Barret_M98_BravoAmmo' ||
			AmmoType == class'JNG90SAAmmo' ||
			AmmoType == class'M82A1LLIAmmo' )
		{
			ret = 1.00;
		}
	}

	return ret;
}

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	local float ret;
	
	ret = 1.0;

	if ( DmgType == class'DamTypeBulkCannonLLI' 
	|| DmgType == class'DamTypeFC' 
	|| DmgType == class'DamTypeFCAP' 
	|| DmgType == class'DamTypeFCBS' 
	|| DmgType == class'DamTypeZic3LLI' 
	|| DmgType == class'DamTypeZic3LLIAP' 
	|| DmgType == class'DamTypeZic3LLIBS' 
	|| DmgType == class'DamTypeSig33LLI' 
	|| DmgType == class'DamTypeSig33LLIAP' 
	|| DmgType == class'DamTypeSig33LLIBS' 
	|| DmgType == class'DamTypeBazookaLLI' 
	|| DmgType == class'DamTypeRG6Grenade' )
	{
		ret *= 0.1;
	}

	if ( class<DamTypeFrag>(DmgType) != none || class<DamTypeRPG>(DmgType) != none || class<DamTypeRXRLDTRocket>(DmgType) != none ||
		 class<DamTypeM79Grenade>(DmgType) != none || class<DamTypeM32Grenade>(DmgType) != none
		 || class<DamTypeM203Grenade>(DmgType) != none || class<DamTypeRocketImpact>(DmgType) != none
		|| class<DamTypeLAW>(DmgType) != none || class<DamTrigun_Pistol>(DmgType) != none
		 || class<DamTypeEX41>(DmgType) != none || class<DamTypeWColt>(DmgType) != none
		 || class<DamTypeSealSquealMExplosion>(DmgType) != none || class<DamTypeHHGrenM>(DmgType) != none
		 || class<DamTypeSeekerSixMRocket>(DmgType) != none || class<DamTypeSeekerMRocketImpact>(DmgType) != none
		 || class<DamTypeBulkCannonLLI>(DmgType) != none || class<DamTypeRG6Grenade>(DmgType) != none
		 || class<DamTypeFC>(DmgType) != none || class<DamTypeFCAP>(DmgType) != none
		 || class<DamTypeFCBS>(DmgType) != none || class<DamTypeBazookaLLI>(DmgType) != none
		 || class<DamTypeZic3LLI>(DmgType) != none || class<DamTypeZic3LLIAP>(DmgType) != none
		 || class<DamTypeZic3LLIBS>(DmgType) != none
		 || class<DamTypeSig33LLI>(DmgType) != none || class<DamTypeSig33LLIAP>(DmgType) != none
		 || class<DamTypeSig33LLIBS>(DmgType) != none  )
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

	else if ( class<DamTypeOpticalDeagleF>(DmgType) != none || class<DamTypeM202A2>(DmgType) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 1.5;
		}
		else
		{
			ret = 1.5 + 0.02 * float(KFPRI.ClientVeteranSkillLevel);
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

	return ret * 0.6 * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
}

static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI, class<KFMonster> MonsterClass)
{
	local float ret;
	
	ret = 0.4;
	
	if ( class<DKFleshPoundNew>(MonsterClass) != none
	|| class<DKFleshPoundNewP>(MonsterClass) != none
	|| class<DKFleshpoundKF2DT>(MonsterClass) != none
	|| class<ZombieFleshPound_XMasSR>(MonsterClass) != none
	|| class<ZombieFleshPound_XMasSRP>(MonsterClass) != none )
	{
		ret = 0.70;
	}
	else if ( class<DKBrute>(MonsterClass) != none || class<DKEndy>(MonsterClass) != none || class<TankerBruteDT>(MonsterClass) != none )
	{
		ret = 0.70;
	}
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
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
	
	S = "+" $ GetPercentStr(Add*1.6) $ default.PerkDescription[0];
	//S = "+" $ GetPercentStr((FMax(0.50,0.25 + 0.05 * float(Level)))*1.6) $ default.PerkDescription[0];
	
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

		if ( Level >= 0 )
		{
			Add = 0.0;
			
			if ( Level >= 0 ) Add += 0.10;
			if ( Level > 5 ) Add += 0.20;
			if ( Level > 15 ) Add += 0.10;
			if ( Level > 25 ) Add += 0.10;
			if ( Level > 35 ) Add += 0.10;
			
			
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
