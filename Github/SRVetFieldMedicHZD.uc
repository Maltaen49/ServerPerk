class SRVetFieldMedicHZD extends SRVetFieldMedic;

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	local float ret;
	
	ret = 1.0;
	
	if( DmgType == class'DamTypeAugA3SA' )
	{
		ret = 1.40 + 0.02 * float(KFPRI.ClientVeteranSkillLevel);
	}
	else if( DmgType == class'DamTypeFN2000M'
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
		ret = 1.30 + 0.015 * float(KFPRI.ClientVeteranSkillLevel);
	}


	return ret * 0.4 * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
}

static function float GetSyringeChargeRate(KFPlayerReplicationInfo KFPRI)
{
	return 1.5 + (0.1 * float(KFPRI.ClientVeteranSkillLevel));
}
static function float GetHealPotency(KFPlayerReplicationInfo KFPRI)
{
	return 1.25 + 0.03125 * float(KFPRI.ClientVeteranSkillLevel);
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
		|| MP5MAmmoM(Other) != none 
		|| MedFMG9SAAmmo(Other) != none
		|| FN2000MAmmo(Other) != none 
		|| ArmachamAssaultRifleAmmo(Other) != none 
		|| FNC30Ammo(Other) != none 
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
		|| FNC30M203Ammo(Other) != none)
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
	local float ret;
	
	ret = 1.0;
	
	if ( AmmoType == class'GrenadePistolLLILAmmo' ) return ret;
	
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
	
	else if ( AmmoType == class'StimulatorAmmo' || AmmoType == class'StimulatorLLIAmmo' )
	{
		return 0.0 + 1.0 * FMax(0.0,(KFPRI.ClientVeteranSkillLevel-1)/5);
	}
	
	else if ( AmmoType == class'FN2000MgAmmo' 
			|| AmmoType == class'Armacham203Ammo' 
			|| AmmoType == class'RG6LLIAmmo'
			|| AmmoType == class'FNC30M203Ammo' )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
			return 1.6;
		
		return 1.6 + 0.14 * float((KFPRI.ClientVeteranSkillLevel-1)/5);
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

static function string GetCustomLevelInfo( byte Level )
{
	local string S;
	local float Add;

	S = "+" $ GetPercentStr((0.20 + 0.01 * float(Level))*1.4) $ default.PerkDescription[0];
	
	S = S $ "+" $ GetPercentStr(0.5 + 0.1 * float(Level)) $ default.PerkDescription[1];
	
	S = S $ "+" $ GetPercentStr(0.25 + 0.03125 * float(Level)) $ default.PerkDescription[2];
	
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
	
	if ( Level >= 0 )
	{
		Add = 0.0;
		
		if ( Level >= 0 ) Add += 0.10;
		if ( Level > 5 ) Add += 0.20;
		if ( Level > 15 ) Add += 0.10;
		if ( Level > 25 ) Add += 0.10;
		if ( Level > 35 ) Add += 0.10;
		
		
		S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[12];
	}
		
	if ( Level > 5 )
	{
		Add = 0.0;
		
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
	
	ret = 0.20;
	
	if ( class<DKFleshPoundNew>(MonsterClass) != none || class<DKFleshpoundKF2DT>(MonsterClass) != none || class<ZombieFleshPound_XMasSR>(MonsterClass) != none )
	{
		ret = 0.30;
	}
	if ( class<DKScrake>(MonsterClass) != none )
	{
		ret = 0.30;
	}
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
}
