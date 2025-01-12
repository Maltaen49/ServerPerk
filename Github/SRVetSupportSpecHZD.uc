class SRVetSupportSpecHZD extends SRVetSupportSpec;

//Умножаем урон с расстоянием
//бонус +100% в притык
static function float NearbyDamageModifer(KFPlayerReplicationInfo KFPRI, float Distance, class<DamageType> DmgType)
{
	local float ret;
	local float lvl;
	ret = 1.0;
	lvl = float(KFPRI.ClientVeteranSkillLevel);
	
	if (Distance < 501)
	{
		/*
			(~50 - это когда совсем в притык)
			10/(50 *0.75)+1.0 = 1.266  (11/. = 1.293)  (15/. = 1.400)
			10/(100*0.75)+1.0 = 1.133  (11/. = 1.146)  (15/. = 1.200)
			10/(200*0.75)+1.0 = 1.066  (11/. = 1.073)  (15/. = 1.100)
			10/(300*0.75)+1.0 = 1.044  (11/. = 1.048)  (15/. = 1.066)
			10/(400*0.75)+1.0 = 1.033  (11/. = 1.036)  (15/. = 1.050)
			10/(500*0.75)+1.0 = 1.026  (11/. = 1.029)  (15/. = 1.040)
		*/
		if (DmgType == class'DamTypeMoss12Shotgun')
		{
			ret = 13/(Distance*0.75)+1.0;
		}
		else if (DmgType == class'DamTypeToz34' || DmgType == class'DamTypeAshot')
		{
			ret = 12.5/(Distance*0.75)+1.0;
		}
		else if (DmgType == class'DamTypeBenelliNew')
		{
			ret = 11.5/(Distance*0.75)+1.0;
		}
		else if (DmgType == class'DamTypeShotgunNew')
		{
			ret = 12/(Distance*0.75)+1.0;
		}
		else if (DmgType == class'DamTypeSaiga12c')
		{
			ret = 10/(Distance*0.75)+1.0;
		}
	}
	if(Distance < 201.0)
	{
		if(DmgType == class'DamTypeRem870EC' ||
		   DmgType == class'DamTypeSuperX3LLI' ||
		   DmgType == class'DamTypeAvalancheSAShotgun' ||
		   DmgType == class'DamTypeNewShotgun')
		{
			ret = FMax(5/(Distance*0.75),0.05+0.005*lvl)+1.0;
		}
		else if (DmgType == class'DamTypeAA12New' || DmgType == class'DamTypeUSAS12_V2')
		{
			ret = FMax(5/(Distance*0.75),0.01+0.005*lvl)+1.0;
		}
		else if (DmgType == class'DamTypeDBSR')	//двухстволка
		{
			ret = FMax(5/(Distance*0.75),0.05+0.005*lvl)+1.0;
		}
	}
	return ret;
}
static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float ret;
	ret = 1.00;
	if ( AmmoType == class'GrenadePistolLLILAmmo'
		|| AmmoType == class'FNC30M203Ammo'
		|| AmmoType == class'Armacham203Ammo' ) return ret;
	
	if ( AmmoType == class'FragAmmo' || AmmoType == class'Frag1Ammo' )
	{
		if (KFPRI.ClientVeteranSkillLevel < 10)
			ret = 1.0;
		else
			ret = 0.0 + 0.25 * float(KFPRI.ClientVeteranSkillLevel/2);	//(20*0.20=4*5=20)
	}
	else if (AmmoType == class'DBShotgunMAmmo')
	{
		ret = 1.35;
	}
	else if (AmmoType == class'ProtectaAmmo' || AmmoType == class'Rem870ECAmmo' || AmmoType == class'AvalancheSAAmmo'
	|| AmmoType == class'AA12NewAmmo' || AmmoType == class'HSGAmmo' || AmmoType == class'Spas12RLLIAmmo' || AmmoType == class'Spas12RLLIAmmo' || AmmoType == class'SuperX3LLIAmmo'
	|| AmmoType == class'JackhammerAmmo' || AmmoType == class'Saiga12cAmmo' || AmmoType == class'BinachiFA6DTAmmo' || AmmoType == class'USAS12_V2Ammo' )
	{
		ret = 1.50;
	}
	else if ( AmmoType == class'ShotgunAmmoM' || AmmoType == class'BenelliAmmoM'
			  || AmmoType == class'toz34ShotgunAmmo' || AmmoType == class'NailgunNewAmmo' || AmmoType == class'AshotAmmo')
	{
		ret = 1.25 + 0.015 * float(KFPRI.ClientVeteranSkillLevel);
	}
	else if ( AmmoType == class'Moss12Ammo' )
	{
		ret = 1.25 + 0.015 * float(KFPRI.ClientVeteranSkillLevel);
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
	}
	return ret;
}
static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	local float ret;
	ret = 0.00;

	if ( DmgType == class'DamTypeAvalancheSAShotgun' || DmgType == class'DamTypeSuperX3LLI' || DmgType == class'DamTypeBinachiFA6DT' )
	{
		ret *= 0.2;
	}

	if ( DmgType == class'DamTypeShotgunNew' || DmgType == class'DamTypeDBSR' || DmgType == class'DamTypeAA12New' || DmgType == class'DamTypeAshot'
		|| DmgType == class'DamTypeBenelliNew' || DmgType == class'DamTypeProtecta' || DmgType == class'DamTypeMoss12Shotgun'
		|| DmgType == class'DamTypeWMediShot' || DmgType == class'DamTypeToz34' || DmgType == class'DamTypeSpas12RLLI' /*|| DmgType == class'DamTypeLegendaryLLI'*/
		|| DmgType == class'DamTypeRem870EC' || DmgType == class'DamTypeSaiga12c' || DmgType == class'DamTypeFrag' || DmgType == class'DamTypeSuperX3LLI' || DmgType == class'DamTypeAvalancheSAShotgun'
		|| DmgType == class'DamTypeWeldShot' || DmgType == class'DamTypeJackhammer' || DmgType == class'DamTypeBinachiFA6DT' || DmgType == class'DamTypeUSAS12_V2'
		|| class<DamTypeShotguns>(DmgType) != none
		|| DmgType == class'DamTypeFragSup')
	{
		if (KFPRI.ClientVeteranSkillLevel < 6)
			ret = 0.80;
		else
			ret = 0.65 + 0.04 * float(KFPRI.ClientVeteranSkillLevel);
	}
	if (DmgType == class'DamTypeWMediShot')
		ret *= 0.333;
	ret += 1.0;
	if(DmgType == class'DamTypeFragSup')
	{
		ret *= 2.0;
	}
	return ret * 0.8 * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
}

static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI, class<KFMonster> MonsterClass)
{
	local float ret;
	ret = 0.40;
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
}
static function int GetMaxArmor(KFPlayerReplicationInfo KFPRI)
{
	local int level;
	level = 1;
	if(KFPRI != none)
		level = KFPRI.ClientVeteranSkillLevel;
	
	if(SRPlayerReplicationInfo(KFPRI).HasSkinGroup("Prorok"))
		return 300;

	return 100;

}
static function string GetCustomLevelInfo( byte Level )
{
	local string S;
	local float Add;
	//S = "+" $ GetPercentStr(FMax(0.50,0.25 + 0.05 * float(Level))) $ default.PerkDescription[0];
	S = "+" $ GetPercentStr((FMax(0.80,0.65 + 0.04 * float(Level)))*1.6) $ default.PerkDescription[0];
	S = S $ "+" $ GetPercentStr((FMax(1.50,1.25 + 0.05 * float(Level))*0.8-1.0)*1.6) $ default.PerkDescription[1];
	//S = S $ "+" $ GetPercentStr(FMax(1.20,1.25 + 0.05 * float(Level))*0.8-1.0) $ default.PerkDescription[1];
	S = S $ "+" $ GetPercentStr(0.90+float(int(0.015*float(Level)*100.0))*0.01) $ default.PerkDescription[2];
	S = S $ "+" $ GetPercentStr(0.50) $ default.PerkDescription[3];
	S = S $ "+" $ GetPercentStr(0.25 + 0.015*float(Level)) $ default.PerkDescription[4];
	S = S $ "+" $ GetPercentStr(0.25 + 0.015*float(Level)) $ default.PerkDescription[5];
	S = S $ default.PerkDescription[11] $ string(int(0.25 * float(Level/2))*4+5) $ default.PerkDescription[6];
	S = S $ "+" $ GetPercentStr(1.0 + 0.05 * float(Level)) $ default.PerkDescription[7];
	S = S $ GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[8];
	S = S $ default.PerkDescription[9] $ string(Max(0,(Level-1)/5)) $ default.PerkDescription[10];
	Add = 21.0;
	if ( Level > 5 )
		Add += 3.0 + 2.0 * float((Level-1)/5);
	S = S $ default.PerkDescription[11] $ string(int(Add)) $ default.PerkDescription[12];
	if ( Level >= 0 )
	{
		Add = 0.0;
		if ( Level >= 0 ) Add += 0.10;
		if ( Level > 5 ) Add += 0.20;
		if ( Level > 15 ) Add += 0.10;
		if ( Level > 25 ) Add += 0.10;
		if ( Level > 35 ) Add += 0.10;
		S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[13];
	}
	if ( Level > 15 )
	{
		Add = 0.05;
		if ( Level > 30 )
			Add = 0.10;
		S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[14];
	}
	if ( Level > 20 )
	{
		Add = 0.0;
		if ( Level > 30 )
			Add = 0.65;
		else // if ( Level > 20 )
			Add = 0.40;
		S = S $ "+" $ string(Add) $ default.PerkDescription[28];
	}
	if ( Level > 30 )
	{
		Add = 16.0;
		if ( Level > 35 )
			Add = 24.0;
		S = S $ default.PerkDescription[15] $ string(int(Add)) $ default.PerkDescription[16];
	}
	S = S $ default.PerkDescription[17] $ GetPercentStr(FMax(0, 0.0075*float(Level))+0.005) $ default.PerkDescription[18] $ default.PerkDescription[29];
	S = S $ default.PerkDescription[17] $ GetPercentStr(0.3) $ default.PerkDescription[18] $ default.PerkDescription[30];
	S = S $ default.PerkDescription[19];
	S = S $ default.PerkDescription[20+Max(0,(Level-1)/5)];
	return S;
}