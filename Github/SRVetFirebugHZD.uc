class SRVetFirebugHZD extends SRVetFirebug;

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	local float ret;
	
	ret = 1.0;
	
	if ( Frag1Ammo(Other) != none )
	{
		return 0.4;
	}

	if ( FN2000MgAmmo(Other) != none 
	|| Armacham203Ammo(Other) != none
	|| FNC30M203Ammo(Other) != none )
	{
			ret = 0.0;
	}

	if ( FlameAmmo1_(Other) != none || MAC10Ammo(Other) != none || HornetGAmmo(Other) != none )
	{
		ret = 1.25 + 0.10 * float(KFPRI.ClientVeteranSkillLevel);
	}

	return ret * Super.GetAmmoPickupMod(KFPRI,Other);
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float ret;
	
	ret = 1.0;
	
	if ( AmmoType == class'GrenadePistolLLILAmmo'
		|| AmmoType == class'FNC30M203Ammo'
		|| AmmoType == class'Armacham203Ammo' ) return ret;
	
	if ( AmmoType == class'FlameAmmo1_' )
	{
		ret = 4.00/ 3.00 + 0.125 * float(KFPRI.ClientVeteranSkillLevel);
	}
	else if ( AmmoType == class'FireBombAmmo' )
	{
		ret = 1.0 + 0.5 * float(KFPRI.ClientVeteranSkillLevel/4);
	}
	else if ( AmmoType == class'FragAmmo' || AmmoType == class'Frag1Ammo' )
	{
		ret = 1.0 + 0.2 * float(KFPRI.ClientVeteranSkillLevel/2);
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
	local class<KFWeaponDamageType> KFWDT;
	local float ret;
	
	ret = 1.0;

	KFWDT = class<KFWeaponDamageType>(DmgType);
	if ( KFWDT != none && KFWDT.default.bDealBurningDamage && !KFWDT.default.bLocationalHit
		/*|| class<SRFireDamageType>(DmgType) != none*/)
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
			ret = 2.0;
		else ret = 2.0 + 0.03125 * float(KFPRI.ClientVeteranSkillLevel);
	}
	return ret * 0.6 * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
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
	
	S = "+" $ GetPercentStr(Add*1.8) $ default.PerkDescription[0];
	//S = "+" $ GetPercentStr((FMax(0.50,0.25 + 0.05 * float(Level)))*1.8) $ default.PerkDescription[0];
	
	S = S $ "+" $ GetPercentStr(0.50 + 0.05 * float(Level)) $ default.PerkDescription[1];
	
	if ( Level > 0 )
	{
		S = S $ "+" $ GetPercentStr(0.00 + 0.05 * float(Level)) $ default.PerkDescription[2];
	}
	
	S = S $ "+" $ GetPercentStr(0.33 + 0.125 * float(Level)) $ default.PerkDescription[3];
	
	S = S $ default.PerkDescription[4] $ string(5+Level/2) $ default.PerkDescription[5];
	
	S = S $ default.PerkDescription[4] $ string(2+Level/4) $ default.PerkDescription[6];
	
	if ( Level > 0 )
	{
		S = S $ "+" $ GetPercentStr(0.02*float(Level)) $ default.PerkDescription[7];
	}
	
	S = S $ GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[8];
	
	S = S $ default.PerkDescription[9] $ string(Max(0,(Level-1)/5)) $ default.PerkDescription[10];
	
	if ( Level < 6 )
	{
		S = S $ default.PerkDescription[27];
	}
	else
	{
		S = S $ "+" $ GetPercentStr(0.50 * float((Level-1)/5)) $ default.PerkDescription[12];
		
		Add = 0.0;
		
		if ( Level >= 0 ) Add += 0.10;
		if ( Level > 5 ) Add += 0.20;
		if ( Level > 15 ) Add += 0.10;
		if ( Level > 25 ) Add += 0.10;
		if ( Level > 35 ) Add += 0.10;
		
		S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[13];
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

		S = S $ "+" $ string(int(Add)) $ default.PerkDescription[14];
	}
	
	if ( Level > 15 )
	{
		Add = 0.05;
		
		if ( Level > 30 )
		{
			Add = 0.10;
		}
		
		S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[15];
	}
	
	if ( Level > 20 )
	{
		Add = 0.40;
		
		if ( Level > 30 )
		{
			Add = 0.65;
		}
		
		S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[16];
	}
	
	if ( Level > 30 )
	{
		Add = 16.0;
			
		if ( Level > 35 )
		{
			Add = 24.0;
		}
			
		S = S $ default.PerkDescription[17] $ string(int(Add)) $ default.PerkDescription[18];
	}
	
	S = S $ default.PerkDescription[19];
	
	if ( Level < 6 )
	{
		S = S $ default.PerkDescription[11];
	}
	else
	{
		S = S $ default.PerkDescription[19+(Level-1)/5];
	}
	
	return S;
}

static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI, class<KFMonster> MonsterClass)
{
	local float ret;
	
	ret = 0.4;
	
	if ( class<DKFleshPoundNew>(MonsterClass) != none
	|| class<DKScrake>(MonsterClass) != none
	|| class<DKFleshPoundNewP>(MonsterClass) != none
	|| class<DKFleshpoundKF2DT>(MonsterClass) != none
	|| class<ZombieFleshPound_XMasSRP>(MonsterClass) != none
	|| class<ZombieFleshPound_XMasSR>(MonsterClass) != none )
	{
		ret = 0.30;
	}
	/*else if ( class<DKHusk>(MonsterClass) != none || class<DKDemolisher>(MonsterClass) != none )
	{
		ret = 0.20;
	}*/
	else if ( class<DKReaver>(MonsterClass) != none || class<DKBrute>(MonsterClass) != none || class<TankerBruteDT>(MonsterClass) != none
			|| class<DKEndy>(MonsterClass) != none || class<DKCrawler>(MonsterClass) != none )
	{
		ret = 1.0;
	}
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
}
