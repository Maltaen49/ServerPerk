class SRVetSupportSpec extends SRVeterancyTypes
	abstract;

static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	switch( CurLevel )
	{
	case 0:
		FinalInt = 5000;
		break;
	case 1:
		FinalInt = 18750;
		break;
	case 2:
		FinalInt = 37500;
		break;
	case 3:
		FinalInt = 75000;
		break;
	case 4:
		FinalInt = 150000;
		break;
	case 5:
		FinalInt = 312500;
		break;
	case 6:
		FinalInt = 625000;
		break;
	case 7:
		FinalInt = 1250000;
		break;
	case 8:
		FinalInt = 2500000;
		break;
	case 9:
		FinalInt = 5000000;
		break;
	case 10:
		FinalInt = 7500000;
		break;
	case 11:
		FinalInt = 10000000;
		break;
	case 12:
		FinalInt = 17000000;
		break;
	case 13:
		FinalInt = 24000000;
		break;
	case 14:
		FinalInt = 31000000;
		break;
	case 15:
		FinalInt = 38000000;
		break;
	case 16:
		FinalInt = 48000000;
		break;
	case 17:
		FinalInt = 58000000;
		break;
	case 18:
		FinalInt = 68000000;
		break;
	case 19:
		FinalInt = 78000000;
		break;
	case 20:
		FinalInt = 88000000;
		break;
	case 21:
		FinalInt = 103000000;
		break;
	case 22:
		FinalInt = 119000000;
		break;
	case 23:
		FinalInt = 136000000;
		break;
	case 24:
		FinalInt = 154000000;
		break;
	case 25:
		FinalInt = 173000000;
		break;
	case 26:
		FinalInt = 193000000;
		break;
	case 27:
		FinalInt = 214000000;
		break;
	case 28:
		FinalInt = 236000000;
		break;
	case 29:
		FinalInt = 259000000;
		break;
	case 30:
		FinalInt = 283000000;
		break;
	case 31:
		FinalInt = 308000000;
		break;
	case 32:
		FinalInt = 338000000;
		break;
	case 33:
		FinalInt = 368000000;
		break;
	case 34:
		FinalInt = 398000000;
		break;
	case 35:
		FinalInt = 428000000;
		break;
	case 36:
		FinalInt = 458000000;
		break;
	case 37:
		FinalInt = 488000000;
		break;
	case 38:
		FinalInt = 518000000;
		break;
	case 39:
		FinalInt = 558000000;
		break;
	case 40:
		FinalInt = 600000000;
		break;
	case 41:
		FinalInt = 1350000000;
		break;
	default:
		FinalInt = 5500000+GetDoubleScaling(CurLevel,500000);
	}
	return Min(StatOther.RShotgunDamageStat,FinalInt);
}

/*static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	FinalInt = PerkLevelRequirement(CurLevel,ReqNum);
	//if( ReqNum==0 )
	//	return Min(StatOther.RWeldingPointsStat,FinalInt);
	return Min(StatOther.RShotgunDamageStat,FinalInt);
}*/
/*static function int PerkLevelRequirement(byte CurLevel, byte ReqNum)
{
	local array<float> StartReq,WholeReq;
	local int FinalInt;
	StartReq.Insert(0,3);
	WholeReq.Insert(0,3);*/
	/*if ( ReqNum == 0 )
	{
		StartReq[0] =    25000;
		WholeReq[0] =   300000;
		StartReq[1] =   100000;
		WholeReq[1] =  7200000;
		StartReq[2] =   750000;
		WholeReq[2] =  7500000;
	}*/
	//else
	//{
		/*StartReq[0] =    500000;
		WholeReq[0] =   6000000;
		StartReq[1] =   2500000;
		WholeReq[1] = 394000000;
		StartReq[2] =  24000000;
		WholeReq[2] = 400000000;*/
		/*StartReq[0] =    500000;
		WholeReq[0] =   6000000;
		StartReq[1] =   2000000;
		WholeReq[1] = 294000000;
		StartReq[2] =  18000000;
		WholeReq[2] = 300000000;
	//}
	FinalInt = int(ArythmProgression(CurLevel,StartReq,WholeReq));
	return FinalInt;
}*/
static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	local int ret;
	ret = 6; // 21 веса
	if ( KFPRI.ClientVeteranSkillLevel > 5 )
	{
		ret = 9 + 2 * ((KFPRI.ClientVeteranSkillLevel-1)/5);
	}
	return ret + Super.AddCarryMaxWeight(KFPRI);
}
static function float GetWeldSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
	return 2.0 + 0.05 * float(KFPRI.ClientVeteranSkillLevel);
}
static function float GetWeldArmorSpeedModifier(SRPlayerReplicationInfo SRPRI)
{
	return 1.33 + 0.017 * float(SRPRI.ClientVeteranSkillLevel);
}
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
		   DmgType == class'DamTypeSC321A' ||
		   DmgType == class'DamTypeNewShotgun' ||
		   DmgType == class'DamTypeAvalancheSAShotgun')
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
	local string weapon;
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;

	if ( AmmoType == class'FragAmmo' || AmmoType == class'Frag1Ammo' )
	{
		if (KFPRI.ClientVeteranSkillLevel < 10)
			ret = 1.0;
		else
			ret = 0.0 + 0.25 * float(KFPRI.ClientVeteranSkillLevel/2);	//(20*0.20=4*5=20)
	}
	else if (AmmoType == class'DBShotgunMAmmo')
	{
		ret = 1.05;
	}
	else if (AmmoType == class'ProtectaAmmo' 
	|| AmmoType == class'Rem870ECAmmo' 
	|| AmmoType == class'AvalancheSAAmmo'
	|| AmmoType == class'AA12NewAmmo' 
	|| AmmoType == class'HSGAmmo' 
	|| AmmoType == class'Spas12RLLIAmmo' 
	|| AmmoType == class'Spas12RLLIAmmo' 
	|| (AmmoType == class'SuperX3LLIAmmo' && Mid(weapon, 1, 1) != "B")
	|| AmmoType == class'SC321AAmmo'
	|| AmmoType == class'JackhammerAmmo'
	|| AmmoType == class'Saiga12cAmmo' 
	|| AmmoType == class'USAS12_V2Ammo' 
	|| AmmoType == class'BinachiFA6DTAmmo'
	|| AmmoType == class'NewShotgunAmmo' )
	{
		ret = 1.30;
	}
	else if (AmmoType == class'SuperX3LLIAmmo' && Mid(weapon, 1, 1) == "B" )
	{
		ret = 2.30;
	}
	else if ( AmmoType == class'ShotgunAmmoM' || AmmoType == class'BenelliAmmoM' || AmmoType == class'AshotAmmo'
			  || AmmoType == class'toz34ShotgunAmmo' || AmmoType == class'NailgunNewAmmo')
	{
		ret = 1.25 + 0.01 * float(KFPRI.ClientVeteranSkillLevel);
	}
	else if ( AmmoType == class'Moss12Ammo' )
	{
		ret = 1.25 + 0.01 * float(KFPRI.ClientVeteranSkillLevel);
	}
	else
	{
		ret = Super.AddExtraAmmoFor(KFPRI,AmmoType);
	}
	return ret;
}
static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	local float ret;
	ret = 0.00;

	if ( DmgType == class'DamTypeShotgunNew' 
	|| DmgType == class'DamTypeDBSR' 
	|| DmgType == class'DamTypeAA12New' 
	|| DmgType == class'DamTypeAshot'
	|| DmgType == class'DamTypeBenelliNew' 
	|| DmgType == class'DamTypeProtecta' 
	|| DmgType == class'DamTypeMoss12Shotgun'
	|| DmgType == class'DamTypeWMediShot' 
	|| DmgType == class'DamTypeToz34' 
	|| DmgType == class'DamTypeSpas12RLLI' /*|| DmgType == class'DamTypeLegendaryLLI'*/
	|| DmgType == class'DamTypeRem870EC' 
	|| DmgType == class'DamTypeSaiga12c' 
	|| DmgType == class'DamTypeFrag' 
	|| DmgType == class'DamTypeSuperX3LLI' 
	|| DmgType == class'DamTypeSC321A'
	|| DmgType == class'DamTypeAvalancheSAShotgun'
	|| DmgType == class'DamTypeWeldShot' 
	|| DmgType == class'DamTypeJackhammer' 
	|| DmgType == class'DamTypeBinachiFA6DT' 
	|| DmgType == class'DamTypeUSAS12_V2'
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
	return ret * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
}
static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
	local float Reduction;
	Reduction = 1.0;
	if ( class<DamTypeFragSup>(DmgType) != none)
		Reduction = 0.90 - 0.005 * float(KFPRI.ClientVeteranSkillLevel);
	return Reduction * Super.ReduceDamage(KFPRI,Injured,Instigator,InDamage,DmgType);
}
/*
static function float GetBodyArmorDamageModifier(KFPlayerReplicationInfo KFPRI)
{
	local float ret;
	if ( KFPRI.ClientVeteranSkillLevel < 6 )
		ret = 0.90;// 10%
	else
		ret = 0.90-0.005*float(KFPRI.ClientVeteranSkillLevel);
	return ret;
}
*/
static function float GetShotgunPenetrationDamageMulti(KFPlayerReplicationInfo KFPRI, float DefaultPenDamageReduction)
{
	return 0.90 + 0.015 * float(KFPRI.ClientVeteranSkillLevel);
}
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float ret;
	ret  = 1.0;
	if ( Item == class'ShotgunPickup' 
	|| Item == class'BoomstickPickup' 
	|| Item == class'AA12Pickup' 
	|| Item == class'BenelliPickup'
	|| Item == class'ShotgunPickupM' 
	|| Item == class'BoomstickPickupM' 
	|| Item == class'AA12PickupM' 
	|| Item == class'BenelliPickupM'
	|| Item == class'ProtectaPickup' 
	|| Item == class'WMediShotPickup' 
	|| Item == class'Moss12Pickup' 
	|| Item == class'SC321APickup'
	|| Item == class'SuperX3LLIPickup'
	|| Item == class'AvalancheSAPickup' 
	|| Item == class'BinachiFA6DTPickup'
	|| Item == class'Saiga12cPickup' 
	|| Item == class'Rem870ECPickup' 
	|| Item == class'toz34ShotgunPickup' 
	|| Item == class'WeldShotPickup'
	|| Item == class'HSGPickup' 
	|| Item == class'Spas12RLLIPickup' 
	|| Item == class'USAS12_V2Pickup'  
	|| Item == class'NewShotgunPickup' 
	/*|| Item == class'LegendaryLLIPickup'*/ )
		ret = GetDefaultCostScaling(KFPRI.ClientVeteranSkillLevel);
	if ( Item == class'Vest' )
		ret *= 0.5;
	return ret;
}
static function float GetAmmoCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float ret;
	ret = 1.0;
	if (Item == class'Frag1Pickup')
		ret *= 0.5;
	return ret;
}
static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'SupportNade';
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
	if ( KFPRI.ClientVeteranSkillLevel > 5 && KFPRI.ClientVeteranSkillLevel < 16 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.ShotgunM", GetCostScaling(KFPRI, class'ShotgunPickupM'));
	if ( KFPRI.ClientVeteranSkillLevel > 10 && KFPRI.ClientVeteranSkillLevel < 21 || KFPRI.ClientVeteranSkillLevel < 6 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.toz34Shotgun", GetCostScaling(KFPRI, class'toz34ShotgunPickup'));
	if ( KFPRI.ClientVeteranSkillLevel > 15 && KFPRI.ClientVeteranSkillLevel < 26 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.BenelliShotgunM", GetCostScaling(KFPRI, class'BenelliPickupM'));
	if ( KFPRI.ClientVeteranSkillLevel > 20 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.BoomStickM", GetCostScaling(KFPRI, class'BoomStickPickupM'));
	if ( KFPRI.ClientVeteranSkillLevel > 25 && KFPRI.ClientVeteranSkillLevel < 36 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.Saiga12c", GetCostScaling(KFPRI, class'Saiga12cPickup'));
	if ( KFPRI.ClientVeteranSkillLevel > 25 && Mid(weapon, 1, 1) != "A" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.Moss12Shotgun", GetCostScaling(KFPRI, class'Moss12Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel > 30 && KFPRI.ClientVeteranSkillLevel < 36 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.HSG", GetCostScaling(KFPRI, class'HSGPickup'));
	if ( KFPRI.ClientVeteranSkillLevel > 35 && Mid(weapon, 1, 1) != "A" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.Spas12RLLI", GetCostScaling(KFPRI, class'Spas12RLLIPickup'));
	if ( KFPRI.ClientVeteranSkillLevel > 35 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AA12AutoShotgunM", GetCostScaling(KFPRI, class'AA12PickupM'));
	if ( KFPRI.ClientVeteranSkillLevel > 0)
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SC321A", GetCostScaling(KFPRI, class'SC321APickup'));
	if ( Mid(weapon, 1, 1) == "B" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SuperX3LLI", GetCostScaling(KFPRI, class'SuperX3LLIPickup'));
	/*if ( Mid(weapon, 1, 1) == "L" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.LegendaryLLI", GetCostScaling(KFPRI, class'LegendaryLLIPickup'));*/
	if ( Mid(weapon, 1, 1) == "A" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AvalancheSAAutoShotgun", GetCostScaling(KFPRI, class'AvalancheSAPickup'));
	if ( KFPRI.ClientVeteranSkillLevel > 35 )
		P.ShieldStrength += 100;
}
static function string GetCustomLevelInfo( byte Level )
{
	local string S;
	local float Add;
	//S = "+" $ GetPercentStr(FMax(0.50,0.25 + 0.05 * float(Level))) $ default.PerkDescription[0];
	S = "+" $ GetPercentStr(FMax(0.80,0.65 + 0.04 * float(Level))) $ default.PerkDescription[0];
	S = S $ "+" $ GetPercentStr(FMax(1.50,1.25 + 0.05 * float(Level))*0.8-1.0) $ default.PerkDescription[1];
	//S = S $ "+" $ GetPercentStr(FMax(1.20,1.25 + 0.05 * float(Level))*0.8-1.0) $ default.PerkDescription[1];
	S = S $ "+" $ GetPercentStr(0.90+float(int(0.015*float(Level)*100.0))*0.01) $ default.PerkDescription[2];
	S = S $ "+" $ GetPercentStr(0.30) $ default.PerkDescription[3];
	S = S $ "+" $ GetPercentStr(0.30 + 0.01*float(Level)) $ default.PerkDescription[4];
	S = S $ "+" $ GetPercentStr(0.30 + 0.02*float(Level)) $ default.PerkDescription[5];
	S = S $ default.PerkDescription[11] $ string(int(0.25 * float(Level/2))*4+5) $ default.PerkDescription[6];
	S = S $ "+" $ GetPercentStr(1.0 + 0.05 * float(Level)) $ default.PerkDescription[7];
	S = S $ GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[8];
	S = S $ default.PerkDescription[9] $ string(Max(0,(Level-1)/5)) $ default.PerkDescription[10];
	Add = 21.0;
	if ( Level > 5 )
		Add += 3.0 + 2.0 * float((Level-1)/5);
	S = S $ default.PerkDescription[11] $ string(int(Add)) $ default.PerkDescription[12];
	if ( Level > 5 )
	{
		Add = 0.10;
		if ( Level > 15 )
			Add += 0.05;
		if ( Level > 25 )
			Add += 0.05;
		if ( Level > 35 )
			Add += 0.05;
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
static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI, class<KFMonster> MonsterClass)
{
	local float ret;
	ret = 0.65;
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
}
defaultproperties
{
	PerkDescription(0)=" урона дробовиками|"
	PerkDescription(1)=" урона гранатами|"
	PerkDescription(2)=" пробивная способность дроби|"
	PerkDescription(3)=" к боезапасу мощных дробовиков|"
	PerkDescription(4)=" к боезапасу средних дробовиков|"
	PerkDescription(5)=" к боезапасу легких дробовиков|"
	PerkDescription(6)=" гранат|"
	PerkDescription(7)=" скорости сварки/разварки дверей|"
	PerkDescription(8)=" скидка на дробовики|"
	PerkDescription(9)="Ранг "
	PerkDescription(10)=", бонусы:|"
	PerkDescription(11)="Может переносить "
	PerkDescription(12)=" ед. веса|"
	PerkDescription(13)=" к запасу патронов|"
	PerkDescription(14)=" скорости бега|"
	PerkDescription(15)="Видит здоровье монстров с "
	PerkDescription(16)=" метров|"
	PerkDescription(17)="Наносит до +"
	PerkDescription(18)=" дополнительного урона в упор "
	PerkDescription(19)="Особенности перка:|Выстрелы дробовиков приостанавливают скрейка|Стартовый инвентарь:|"
	PerkDescription(20)="Обрез ТОЗ-34"
	PerkDescription(21)="Дробовик Benelli M3"
	PerkDescription(22)="Дробовик Benelli M3, Обрез ТОЗ-34"
	PerkDescription(23)="Дробовик Benelli M4 Super, Обрез ТОЗ-34"
	PerkDescription(24)="Дробовик Benelli M4 Super, Ружье"
	PerkDescription(25)="Mossberg-12, Сайга12-С, Ружье"
	PerkDescription(26)="Mossberg-12, HSG, Сайга 12-С, Ружье"
	PerkDescription(27)="Mossberg-12, SPAS-12, AA12, Ружье"
	PerkDescription(28)=" к скорости восстановления шприца|"
	PerkDescription(29)="мощных дробовиков|"
	PerkDescription(30)="средних дробовиков|"
	PerkIndex=1
	IconMat1 = Texture'SunriseHUD.Icons.Perk_Support_Green'
	IconMat2 = Texture'SunriseHUD.Icons.Perk_Support_Orange'
	IconMat3 = Texture'SunriseHUD.Icons.Perk_Support_Blue'
	IconMat4 = Texture'SunriseHUD.Icons.Perk_Support_Purple'
	IconMat5 = Texture'SunriseHUD.Icons.Perk_Support_Red'
	IconMat6 = Texture'SunriseHUD.Icons.Perk_Support_Silver'
	IconMat7 = Texture'SunriseHUD.Icons.Perk_Support_Dark'
	IconMat8 = Texture'SunriseHUD.Icons.Perk_Support_Gold'
	IconMat9 = Texture'SunriseHUD.Icons.Perk_Support_Master'
	IconMat10 = Texture'SunriseHUD.Icons.Perk_Support_Elite'
	VeterancyName="Поддержка"
	//Requirements[0]="Заварить %x ед прочности дверей"
	Requirements[0]="Нанести %x повреждений дробовиками"
	NumRequirements=1//2
}
