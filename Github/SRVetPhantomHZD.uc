class SRVetPhantomHZD extends SRVetPhantom;

static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	local SRPlayerReplicationInfo SRPRI;
	local int ret;
	
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	
	if (SRPRI.HasSkinGroup("Mortal"))
		ret = 21;
	else if (!SRPRI.HasSkinGroup("Mortal"))
		ret = 15;
	
	if ( KFPRI.ClientVeteranSkillLevel > 10 )
	{
		ret += 2;
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 25 )
	{
		ret += 2;
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 35 )
	{
		ret += 2;
	}
	
	return ret - 1;
}

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	local float ret,cLevel;
	local SRPlayerReplicationInfo SRPRI;
	
	cLevel = float(KFPRI.ClientVeteranSkillLevel);
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	ret = 1.00;
	if ( DmgType == class'DamTypeRemingtonACRSAabc' 
	|| DmgType == class'DamTypeRemingtonACRSA'  
	|| DmgType == class'DamTypeStingerInf'   
	|| DmgType == class'DamTypeKacChainsawSA'    
	|| DmgType == class'DamTypeTitanShotgun'     
	|| DmgType == class'DamTypeTitanRocket'  
	|| DmgType == class'DamTypeCrossbuzzsawKF2'   
	|| DmgType == class'DamTypeCrossbuzzsawKF2Alt' 
	|| class<DamTypeRavager>(DmgType) != none 
	|| class<DamTypePyramidBladeLLI>(DmgType) != none   
	|| class<DamTypeGreatswordLLI>(DmgType) != none 
	|| class<DamTypeVenom>(DmgType) != none )
	{
		ret *= 0.1;
	}

	if ( SRPRI.HasSkinGroup("Mortal") )
	{
		ret *= 0.2;
	}
	
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
	return ret * 0.9 * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float ret;
	
	ret = 1.0;
	if ( AmmoType == class'GrenadePistolLLILAmmo' ) return ret;
	
	if ( AmmoType == class'FragAmmo' || AmmoType == class'Frag1Ammo' )
		ret = 1.0 + 0.4 * float(KFPRI.ClientVeteranSkillLevel/8);
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

static function int InvisibilityLimit(SRPlayerReplicationInfo SRPRI)
{
	local int cLevel;
	local int ret;
	
	cLevel = SRPRI.ClientVeteranSkillLevel;
	ret = 5 + cLevel/4;
	return ret;
}

static function int DecapCountPerWave(PlayerReplicationInfo PRI)
{
	local SRPlayerReplicationInfo SRPRI;
	local int cLevel,ret;
	
	SRPRI = SRPlayerReplicationInfo(PRI);
	cLevel = SRPRI.ClientVeteranSkillLevel;
	if ( cLevel >= 40 ) ret = 5;
	else if ( cLevel >= 31 ) ret = 4;
	else if ( cLevel >= 21 ) ret = 3;
	else if ( cLevel >= 11 ) ret = 2;
	else ret = 1;
	return ret;
}

static function bool DisableInvisibilityCollision(SRPlayerReplicationInfo SRPRI)
{
	if ( SRPRI.ClientVeteranSkillLevel < 6 )
		return false;
	return true;
}

static function string GetCustomLevelInfo( byte Level )
{
	local string S;
	local float Add;
	local KFPlayerReplicationInfo KFPRI;
	local SRPlayerReplicationInfo SRPRI;
	
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	
	if ( Level < 6 ) Add = 0.50;
	else Add = 0.50 + 0.02 * float(Level-5);
	S = "+" $ GetPercentStr(Add*1.6) $ default.PerkDescription[0];
	if ( Level < 6 ) Add = 0.85;
	else Add = 0.85 + 0.03 * float(Level-5);
	S $= "+" $ GetPercentStr(Add*1.4) $ default.PerkDescription[1];
	S $= GetPercentStr(0.60 + 0.01 * float(Level)) $ default.PerkDescription[2];
	S $= "+" $ GetPercentStr(0.20 + 0.01 * float(Level)) $ default.PerkDescription[3];
	S $= "+" $ GetPercentStr(0.10 + 0.005 * float(Level)) $ default.PerkDescription[4];
	if ( Level > 0 ) S $= "+" $ GetPercentStr(0.01 * float(Level)) $ default.PerkDescription[5];
	S $= string(5 + Level/4) $ default.PerkDescription[6];
	S $= string(5 + Level/4) $ default.PerkDescription[7];
	S $= default.PerkDescription[8];
	ReplaceText(S,"%a",string(FMax(10.00,10.00 + 0.20 * float(Level-5))));
	S $= default.PerkDescription[9];
	ReplaceText(S,"%a",string(FMax(3.0,3.0 + 0.0572 * (Level - 5.0))));
	S $= "+" $ GetPercentStr(0.20 + 0.005 * float(Level)) $ default.PerkDescription[10];
	S $= GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[11];
	if ( Level >= 6 ) S $= default.PerkDescription[12];
	if ( Level >= 31 ) S $= default.PerkDescription[13];
	if ( Level >= 0 )
	{
		S $= default.PerkDescription[14];
		if ( Level >= 40 ) ReplaceText(S,"%a","5");
		else if ( Level >= 31 ) ReplaceText(S,"%a","4");
		else if ( Level >= 21 ) ReplaceText(S,"%a","3");
		else if ( Level >= 11 ) ReplaceText(S,"%a","2");
		else ReplaceText(S,"%a","1");
	}
	S $= default.PerkDescription[15];
	ReplaceText(S,"%a",string(Max(0,(Level-1)/5)));
	if ( Level >=0 )
	{
		Add = 0.0;
		if ( Level >= 0 ) Add += 0.10;
		if ( Level > 5 ) Add += 0.20;
		if ( Level > 15 ) Add += 0.10;
		if ( Level > 25 ) Add += 0.10;
		if ( Level > 35 ) Add += 0.10;
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
	
	ret = 0.35;
	if ( class<DKScrake>(MonsterClass) != none )
	{
		ret = 0.65;
	}
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
}
