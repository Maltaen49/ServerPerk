class SRVetBerserkerHZD extends SRVetBerserker;

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	local float ret;
	
	ret = 1.0;

	if ( class<DamTypeAvengerLLI>(DmgType) != none
	|| class<DamTypeInfernoLLI>(DmgType) != none
	|| class<DamTypeInfernoLLIAlt>(DmgType) != none
	|| class<DamTypeEmpireSword>(DmgType) != none
	|| class<DamTypeEmpireSwordAlt>(DmgType) != none
	|| class<DamTypePurifierSword>(DmgType) != none
	|| class<DamTypePurifierSwordAlt>(DmgType) != none
	|| class<DamTypeTsuguriLLI>(DmgType) != none
	|| class<DamTypeTsuguriLLIAlt>(DmgType) != none
	|| class<DamTypeClaymoreA>(DmgType) != none
	|| class<DamTypeClaymoreAAltAttack>(DmgType) != none  )
	{
		ret *= 0.2;
	}

	if( class<KFWeaponDamageType>(DmgType) != none && class<KFWeaponDamageType>(DmgType).default.bIsMeleeDamage && class<DamTypeCrossbuzzsawKF2>(DmgType) == none
		&& class<DamTypeColdSteel>(DmgType) == none && class<DamTypeReaper>(DmgType) == none && class<DamTypeShurikenLLI>(DmgType) == none )
	{
		ret = 2.5;
	}
	else if( class<DamTypeShurikenLLI>(DmgType) != none )
	{
		ret = 1.0;
	}
	return ret * 0.65 * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
}

static function float GetHeadShotDamMulti(KFPlayerReplicationInfo KFPRI, KFPawn P, class<DamageType> DmgType)
{
	local float ret;
	ret = 1.0;
	if ( class<KFWeaponDamageType>(DmgType) != none && class<KFWeaponDamageType>(DmgType).default.bIsMeleeDamage
		&& class<DamTypeColdSteel>(DmgType) == none && class<DamTypeReaper>(DmgType) == none && class<DamTypeCrossbuzzsawKF2>(DmgType) == none )
	{
		ret = 1.00 + 0.025 * float(Max(0,KFPRI.ClientVeteranSkillLevel-5));
	}

	return ret*0.7;
}

static function float DecapDamageModifier(PlayerReplicationInfo PRI, Pawn Victim, class<DamageType> DmgType)
{
	return GetHeadShotDamMulti(KFPlayerReplicationInfo(PRI), KFPawn(Victim),DmgType)*2.0;
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float ret;
	
	ret = 1.0;
	
	if ( AmmoType == class'GrenadePistolLLILAmmo'
		|| AmmoType == class'FNC30M203Ammo'
		|| AmmoType == class'Armacham203Ammo' ) return ret;
	
	if ( AmmoType == class'FragAmmo' || AmmoType == class'Frag1Ammo' )
	{
		ret = 1.0 + 0.4 * float(KFPRI.ClientVeteranSkillLevel)/4;
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
	/*else
		ret=1.0;*/
	return ret;
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
	local float Reduction,P;
	
	Reduction = 1.0;
	
	if ( DmgType == class'DamTypeOverdose' ) // ???????? ??????
	{
		Goto SetReduction;
	}
	
	P = 0.10 + 0.005 * float(KFPRI.ClientVeteranSkillLevel); // ?30% ?????	

	if( FRand() < P && DmgType != class'Fell' && DmgType != class'DamTypePipeBombS' )
		return 0; // Ю??????
	
	if ( DmgType == class'DamTypeVomit' )
	{
		Reduction = 0.40 - 0.01 * float(KFPRI.ClientVeteranSkillLevel); // ?100% ???????		
		Goto SetReduction;
	}
	
	if ( DmgType == class'DamTypePoisonP' )
	{
		Reduction = 1.0;	
		Goto SetReduction;
	}
	if ( DmgType == class'DamTypePoisonS' )
	{
		Reduction = 0.8;	
		Goto SetReduction;
	}
	if ( DmgType == class'DamTypePoison' )
	{
		Reduction = 0.7;	
		Goto SetReduction;
	}
	
	if ( class<DamTypeBurned>(DmgType) != none )
	{
		Reduction = 0.80 - 0.01 * float(KFPRI.ClientVeteranSkillLevel); // ?70% ??????
		Goto SetReduction;
	}

	Reduction = 0.70 - 0.006 * float(KFPRI.ClientVeteranSkillLevel); // ?40% ????
	Goto SetReduction;
	
SetReduction:

	return Reduction * float(Super.ReduceDamage(KFPRI,Injured,Instigator,InDamage,DmgType));
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	local string weapon;
	super(SRVeterancyTypes).AddDefaultInventory(KFPRI,P);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	
	if ( SRPlayerReplicationInfo(KFPRI).bRespawned )
		return;
		
	SRPlayerReplicationInfo(KFPRI).bRespawned = true;
		
	if ( KFPRI.ClientVeteranSkillLevel < 11 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.ScytheNew", GetCostScaling(KFPRI, class'ScytheNewPickup'));

	if ( KFPRI.ClientVeteranSkillLevel > 5 && KFPRI.ClientVeteranSkillLevel < 11 || KFPRI.ClientVeteranSkillLevel > 15 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.ChainsawM", GetCostScaling(KFPRI, class'ChainsawPickupM'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 10 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AxeM", GetCostScaling(KFPRI, class'AxePickupM'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 20 )
		P.ShieldStrength += 100;
		
	if ( KFPRI.ClientVeteranSkillLevel > 25 && Mid(weapon, 4, 1) != "M" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.KatanaLLI", GetCostScaling(KFPRI, class'KatanaLLIPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 30 )
		P.ShieldStrength += 50;
		
	if ( KFPRI.ClientVeteranSkillLevel > 35 )
		P.ShieldStrength += 50;

	if ( SRPlayerReplicationInfo(KFPRI).HasSkinGroup("KTULHU") )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.InfernoLLI", GetCostScaling(KFPRI, class'InfernoLLIPickup'));
	}
	if ( SRPlayerReplicationInfo(KFPRI).HasSkinGroup("Valdemar") )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.PurifierSword", GetCostScaling(KFPRI, class'PurifierSwordPickup'));
	}
	
	if ( Mid(weapon, 4, 1) == "M" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.MurasamaDT", GetCostScaling(KFPRI, class'MurasamaDTPickup'));
}

static function string GetCustomLevelInfo( byte Level )
{
	local string S;
	local float Add;

	S = "+140%" $ default.PerkDescription[0];

	S = S $ "+" $ GetPercentStr((0.20 + 0.02 * float(Level))*1.2) $ default.PerkDescription[1];
	
	S = S $ "+" $ GetPercentStr(0.10 + 0.01 * float(Level)) $ default.PerkDescription[2];
	
	S = S $ GetPercentStr(0.30 + 0.01 * float(Level)) $ default.PerkDescription[3];
	
	S = S $ GetPercentStr(0.60 + 0.01 * float(Level)) $ default.PerkDescription[4];
	
	S = S $ GetPercentStr(0.20 + 0.007 * float(Level)) $ default.PerkDescription[5];
	
	S = S $ GetPercentStr(0.10 + 0.01 * float(Level/2)) $ default.PerkDescription[6];
	
	S = S $ GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[7];
	
	S = S $ default.PerkDescription[8] $ string(Max(0,(Level-1)/5)) $ default.PerkDescription[9];
	
	if ( Level < 6 )
	{
		S = S $ default.PerkDescription[25];
	}
	else
	{
		S = S $ "+" $ GetPercentStr(0.10 * Max(0,(Level-1)/5)) $ default.PerkDescription[11];
		
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
		
		/*if ( Level > 20 )
		{
			Add = 0.0;
			
			if ( Level > 30 )
			{
				Add = 0.65;
			}
			else // if ( Level > 20 )
			{
				Add = 0.40;
			}*/
			
			S = S $ /*"+" $ string(Add) $ */default.PerkDescription[14];
		//}
		
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
	
	if ( Level < 6 )
	{
		S = S $ default.PerkDescription[10];
	}
	else //if ( Level < 31 )
	{
		S = S $ default.PerkDescription[17+(Level-1)/5];
	}
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
	if ( class<DKScrakeKF2DT>(MonsterClass) != none )
	{
		ret = 0.65;
	}
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
}

defaultproperties
{
	PerkDescription(0)=" урона оружием ближнего боя|"
	PerkDescription(1)=" скорости атаки оружием ближнего боя|"
	PerkDescription(2)=" скорости передвижения с оружием ближнего боя|"
	PerkDescription(3)=" сопротивление к урону огнем|"
	PerkDescription(4)=" уменьшение урона от желчи блоата|"
	PerkDescription(5)=" сопротивление к любому урону|"
	PerkDescription(6)=" шанс полностью блокировать получаемый урон|"
	PerkDescription(7)=" скидка на оружие ближнего боя|"
	PerkDescription(8)="Ранг "
	PerkDescription(9)=", бонусы:|"
	PerkDescription(10)="Коса"
	PerkDescription(11)=" эффективности самолечения|"
	PerkDescription(12)=" к запасу патронов|"
	PerkDescription(13)=" ед. переносимого веса|"
	PerkDescription(14)=" Гранаты приманивают мутантов|"//" к скорости восстановления шприца|"
	PerkDescription(15)="Видит здоровье монстров с "
	PerkDescription(16)=" метров|"
	PerkDescription(17)="Особенности перка:|Иммунитет к параличу|Стартовый инвентарь:|"
	PerkDescription(18)="Бензопила и Коса"
	PerkDescription(19)="Топор"
	PerkDescription(20)="Топор и Бензопила"
	PerkDescription(21)="Топор, Бензопила и Броня"
	PerkDescription(22)="Катана, Топор, Бензопила и Броня"
	PerkDescription(23)="Катана, Топор, Бензопила и 150 ед брони"
	PerkDescription(24)="Катана, Топор, Бензопила и 200 ед брони"
	PerkDescription(25)=" Нет|"
}