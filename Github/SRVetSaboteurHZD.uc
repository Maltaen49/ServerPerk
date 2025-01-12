class SRVetSaboteurHZD extends SRVetSaboteur;

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	local float ret;
	
	ret = 1.0;
	
	if( DmgType == class'DamTypeHKG36CSAAssaultRifle' 
	|| DmgType == class'DamTypeAK47S' 
	|| DmgType == class'DamTypeKrissSVSA' 
	|| DmgType == class'DamTypeAEK971' 
	|| DmgType == class'DamTypeFN2000S'
	|| DmgType == class'DamTypeP416' )
	{
		ret = 1.80 + 0.0175 * float(KFPRI.ClientVeteranSkillLevel);
	}
	else if( class<SRWeaponDamageType>(DmgType).default.bSaboteur )
	{
		ret = 1.80 + 0.015 * float(KFPRI.ClientVeteranSkillLevel);
	}

	return ret * 0.6 * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
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
	|| P902DTAmmo(Other) != none
	|| VALDTAmmo(Other) != none 
	|| HKMP7LLIAmmo(Other) != none 
	|| MedFMG9SAAmmo(Other) != none 
	|| MP5MAmmoM(Other) != none 
	|| OC14Ammo(Other) != none 
	|| FN2000SAmmo(Other) != none 
	|| FN2000SgAmmo(Other) != none 
	|| VSSDTSAmmo(Other) != none
	|| HKG36CSAAmmo(Other) != none
	|| P416Ammo(Other) != none  
	|| AEK971Ammo(Other) != none 
	|| KrissSVSAAmmo(Other) != none  
	|| AK47SAmmo(Other) != none 
	|| KrissSVSAAltAmmo(Other) != none
	|| ASVALSAAmmo(Other) != none 
	|| DualAY69SAAmmo(Other) != none 
	|| VereskSAAmmo(Other) != none)
	{
		ret = 0.25 + 0.020 * float(KFPRI.ClientVeteranSkillLevel);
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
	local float ret;
	
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
		ret = 0.0 + 0.5 * float(KFPRI.ClientVeteranSkillLevel/2);
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
			|| AmmoType == class'P90DTAmmo' 
			|| AmmoType == class'P57LLIAmmo' 
			|| AmmoType == class'P902DTAmmo' 
			|| AmmoType == class'VereskSAAmmo'
			|| AmmoType == class'Glock18cLLIAmmo' 
			|| AmmoType == class'VALDTAmmo' 
			|| AmmoType == class'HKG36CSAAmmo'
			|| AmmoType == class'P416Ammo'
			|| AmmoType == class'AEK971Ammo'
			|| AmmoType == class'DualAY69SAAmmo'
			|| AmmoType == class'HKMP7LLIAmmo' 
			|| AmmoType == class'MedFMG9SAAmmo' 
			|| AmmoType == class'MP5MAmmoM' 
			|| AmmoType == class'OC14Ammo' 
			|| AmmoType == class'FN2000SAmmo' 
			|| AmmoType == class'FN2000SgAmmo' 
			|| AmmoType == class'ASVALSAAmmo' 
			|| AmmoType == class'AK47SAmmo'
			|| AmmoType == class'KrissSVSAAmmo'
			|| AmmoType == class'KrissSVSAAltAmmo'
			|| AmmoType == class'VSSDTSAmmo' )
	{
		ret = 0.25 + 0.025 * float(KFPRI.ClientVeteranSkillLevel);
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
			AmmoType == class'M200SAAmmo' )
		{
			ret = 1.00;
		}
		return ret;
	}
		
	/*if ( AmmoType == class'PP19Ammo' )
	{
		ret *= 0.50;
	}*/
	
	ret += 1.00;

	return ret;
}

static function string GetCustomLevelInfo( byte Level )
{
	local string S;
	local float Add;

	S = "+" $ GetPercentStr((0.60 + 0.01 * float(Level))*1.8) $ default.PerkDescription[0];
	
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
	
	if ( Level >= 0 )
	{
		Add = 0.0;
		if ( Level >= 0 ) Add += 0.10;
		if ( Level > 5 ) Add += 0.20;
		if ( Level > 15 ) Add += 0.10;
		if ( Level > 25 ) Add += 0.10;
		if ( Level > 35 ) Add += 0.10;
		
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
	
	ret = 0.4;
	
	if ( class<DKShiver>(MonsterClass) != none || class<DKShiverP>(MonsterClass) != none )
	{
		ret = 0.70;
		//return 2.50 * Super.GetMoneyReward(SRPRI,MonsterClass);
	}
	
	if ( class<DKCrawler>(MonsterClass) != none )
	{
		ret = 0.60;
		//return 1.50 * Super.GetMoneyReward(SRPRI,MonsterClass);
	}
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
	//return Super.GetMoneyReward(SRPRI,MonsterClass);
}
