class SRVetBerserker extends SRVeterancyTypes
	abstract;

/*static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	FinalInt = PerkLevelRequirement(CurLevel,ReqNum);
	return Min(StatOther.RMeleeDamageStat,FinalInt);
}*/

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
	return Min(StatOther.RMeleeDamageStat,FinalInt);
}

/*static function int PerkLevelRequirement(byte CurLevel, byte ReqNum)
{
	local int FinalInt;
	local array<float> StartReq,WholeReq;
	
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
static function float EffectsDamageModifer(KFPlayerReplicationInfo PRI, class EffectType)
{
	local float ret;
	if(EffectType == class'DamTypeQuake')	//PseudoGigant: Сила удара замлетресения
		ret=0.1;
	else if(EffectType == class'DamTypeRadiation') // //PseudoGigant: Резист к радиации 
		ret=0.1;
	else if (EffectType == class'RadiationBlur') //PseudoGigant: расстояние до размытия
		ret=1.0;
	else
		ret=1.0;
	return ret;
}
static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	local float ret;
	
	ret = 1.0;

	if( class<KFWeaponDamageType>(DmgType) != none && class<KFWeaponDamageType>(DmgType).default.bIsMeleeDamage
		&& class<DamTypeColdSteel>(DmgType) == none && class<DamTypeReaper>(DmgType) == none && class<DamTypeCrossbuzzsawKF2>(DmgType) == none )
	{
		ret = 2.5;
	}
	return ret * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
}

static function float GetHeadShotDamMulti(KFPlayerReplicationInfo KFPRI, KFPawn P, class<DamageType> DmgType)
{
	local float ret;
	ret = 1.0;
	if ( class<KFWeaponDamageType>(DmgType) != none && class<KFWeaponDamageType>(DmgType).default.bIsMeleeDamage
		&& class<DamTypeColdSteel>(DmgType) == none && class<DamTypeReaper>(DmgType) == none && class<DamTypeCrossbuzzsawKF2>(DmgType) == none )
	{
		ret = 1.00 + 0.030 * float(Max(0,KFPRI.ClientVeteranSkillLevel-5));
	}

	return ret;
}

static function float DecapDamageModifier(PlayerReplicationInfo PRI, Pawn Victim, class<DamageType> DmgType)
{
	return GetHeadShotDamMulti(KFPlayerReplicationInfo(PRI), KFPawn(Victim),DmgType)*2.0;
}

static function float GetSelfHealPotency(KFPlayerReplicationInfo KFPRI)
{
	local float ret;
	
	ret = 1.0;
	
	if( KFPRI.ClientVeteranSkillLevel > 35 )
	{
		ret = 1.70;
	}
	else if( KFPRI.ClientVeteranSkillLevel > 30 )
	{
		ret = 1.60;
	}
	else if( KFPRI.ClientVeteranSkillLevel > 25 )
	{
		ret = 1.50;
	}
	else if( KFPRI.ClientVeteranSkillLevel > 20 )
	{
		ret = 1.40;
	}
	else if( KFPRI.ClientVeteranSkillLevel > 15 )
	{
		ret = 1.30;
	}
	else if( KFPRI.ClientVeteranSkillLevel > 10 )
	{
		ret = 1.20;
	}
	else if( KFPRI.ClientVeteranSkillLevel > 5 )
	{
		ret = 1.10;
	}
	
	return ret;
}

static function float GetFireSpeedMod(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
	local float ret;
	
	ret = 1.0;
	
	if ( ( KFMeleeGun(Other) != none || SRMeleeGun(Other) != none )
	&& NinjatoInf(Other) == none 
	&& Dagger(Other) == none 
	&& GreatswordLLIInf(Other) == none 
	//&& Reaper(Other) == none 
	&& Ravager(Other) == none 
	&& PyramidBladeLLI(Other) == none )
	{
		ret = 1.20 + 0.02 * float(KFPRI.ClientVeteranSkillLevel);
	}

	return ret * Super.GetFireSpeedMod(KFPRI,Other);
}

static function float GetMeleeMovementSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
	local float ret;
	
	ret = 0.10 + 0.01 * float(KFPRI.ClientVeteranSkillLevel); // ?50% ?????

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
		Reduction = 0.70 - 0.01 * float(KFPRI.ClientVeteranSkillLevel); // ?70% ??????
		Goto SetReduction;
	}

	Reduction = 0.80 - 0.006 * float(KFPRI.ClientVeteranSkillLevel); // ?40% ????
	Goto SetReduction;
	
SetReduction:

	return Reduction * float(Super.ReduceDamage(KFPRI,Injured,Instigator,InDamage,DmgType));
}

static function bool CanBeGrabbed(KFPlayerReplicationInfo KFPRI, KFMonster Other)
{
	return false; // ?????????
}

// Set number times Zed Time can be extended
static function int ZedTimeExtensions(KFPlayerReplicationInfo KFPRI)
{
	return Min(KFPRI.ClientVeteranSkillLevel, 5);
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float ret;
	
	ret = Super.AddExtraAmmoFor(KFPRI,AmmoType);
	
	if ( AmmoType == class'FragAmmo' || AmmoType == class'Frag1Ammo' )
	{
		ret = 1.0 + 0.2 * float(KFPRI.ClientVeteranSkillLevel)/4;
	}
	/*else
		ret=1.0;*/
	return ret;
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'GPLLIProj_Berserker';
}

static function float GetMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
	return 1.00;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float ret;
	
	ret = 1.0;
	
	if ( Item == class'ChainsawPickupM' 
		|| Item == class'KatanaLLIPickup' 
		|| Item == class'ClaymoreSwordPickupM' 
		|| Item == class'TsuguriLLIPickup'
		|| Item == class'ScytheNewPickup' 
		|| Item == class'CucumberLLIPickup' 
		|| Item == class'InfernoLLIPickup' 
		|| Item == class'EmpireSwordPickup' 
		|| Item == class'PurifierSwordPickup' 
		|| Item == class'ClaymoreSwordPickupA'
		|| Item == class'FallingStarPickup' 
		|| Item == class'AvengerLLIPickupM' 
		|| Item == class'ShadowMourneLLIPickup' 
		|| Item == class'WerewolfLLIPickup' 
		|| Item == class'FrostSwordPickup' 
		|| Item == class'AvengerLLIPickupW' 
		|| Item == class'EbBulavaPickup' 
		|| Item == class'MurasamaDTPickup'
		|| Item == class'M99SBPickup'
		|| Item == class'CrossbowBalistaPickup' )
	{
		ret = GetDefaultCostScaling(KFPRI.ClientVeteranSkillLevel);
	}
	
	if ( Item == class'Vest' )
	{
		ret *= 0.5;
	}

	return ret;
}

/*static function float GetSyringeChargeRate(KFPlayerReplicationInfo KFPRI)
{
	local float ret;
	
	ret = 1.00;

	return ret;
}*/
// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	local string weapon;
	super.AddDefaultInventory(KFPRI,P);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	
	if ( SRPlayerReplicationInfo(KFPRI).bRespawned )
		return;
		
	SRPlayerReplicationInfo(KFPRI).bRespawned = true;
		
	if ( KFPRI.ClientVeteranSkillLevel < 6 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.MacheteM", GetCostScaling(KFPRI, class'MachetePickupM'));

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

	if ( Mid(weapon, 4, 1) == "M" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.MurasamaDT", GetCostScaling(KFPRI, class'MurasamaDTPickup'));

	if ( Mid(weapon, 4, 1) == "W" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AvengerLLIW", GetCostScaling(KFPRI, class'AvengerLLIPickupW'));

	if ( Mid(weapon, 4, 1) == "G" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.FrostSword", GetCostScaling(KFPRI, class'FrostSwordPickup'));
	
	if ( Mid(weapon, 4, 1) == "3" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.ClaymoreSwordA", GetCostScaling(KFPRI, class'ClaymoreSwordPickupA'));

	if ( SRPlayerReplicationInfo(KFPRI).HasSkinGroup("Valdemar") )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.PurifierSword", GetCostScaling(KFPRI, class'PurifierSwordPickup'));
	}
}
static function int GetMaxArmor(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel > 40 )
		return 300;
	else if ( KFPRI.ClientVeteranSkillLevel > 35 )
		return 200;
	else if ( KFPRI.ClientVeteranSkillLevel > 30 )
		return 150;
	return super.GetMaxArmor(KFPRI);
}
static function string GetCustomLevelInfo( byte Level )
{
	local string S;
	local float Add;

	S = "+100%" $ default.PerkDescription[0];

	S = S $ "+" $ GetPercentStr(0.20 + 0.02 * float(Level)) $ default.PerkDescription[1];
	
	S = S $ "+" $ GetPercentStr(0.10 + 0.01 * float(Level)) $ default.PerkDescription[2];
	
	S = S $ GetPercentStr(0.30 + 0.01 * float(Level)) $ default.PerkDescription[3];
	
	S = S $ GetPercentStr(0.60 + 0.01 * float(Level)) $ default.PerkDescription[4];
	
	S = S $ GetPercentStr(0.20 + 0.01 * float(Level/2)) $ default.PerkDescription[5];
	
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
	
	ret = 0.6;
	if ( class<DKScrake>(MonsterClass) != none )
	{
		ret = 0.85;
	}
	if ( class<DKScrakeKF2DT>(MonsterClass) != none )
	{
		ret = 0.85;
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
	PerkDescription(10)="Мачете"
	PerkDescription(11)=" эффективности самолечения|"
	PerkDescription(12)=" к запасу патронов|"
	PerkDescription(13)=" ед. переносимого веса|"
	PerkDescription(14)=" Гранаты приманивают мутантов|"//" к скорости восстановления шприца|"
	PerkDescription(15)="Видит здоровье монстров с "
	PerkDescription(16)=" метров|"
	PerkDescription(17)="Особенности перка:|Иммунитет к параличу|Стартовый инвентарь:|"
	PerkDescription(18)="Бензопила"
	PerkDescription(19)="Топор"
	PerkDescription(20)="Топор и Бензопила"
	PerkDescription(21)="Топор, Бензопила и Броня"
	PerkDescription(22)="Катана, Топор, Бензопила и Броня"
	PerkDescription(23)="Катана, Топор, Бензопила и 150 ед брони"
	PerkDescription(24)="Катана, Топор, Бензопила и 200 ед брони"
	PerkDescription(25)=" Нет|"

	PerkIndex=4

	IconMat1 = Texture'SunriseHUD.Icons.Perk_Berserker_Green'
	IconMat2 = Texture'SunriseHUD.Icons.Perk_Berserker_Orange'
	IconMat3 = Texture'SunriseHUD.Icons.Perk_Berserker_Blue'
	IconMat4 = Texture'SunriseHUD.Icons.Perk_Berserker_Purple'
	IconMat5 = Texture'SunriseHUD.Icons.Perk_Berserker_Red'
	IconMat6 = Texture'SunriseHUD.Icons.Perk_Berserker_Silver'
	IconMat7 = Texture'SunriseHUD.Icons.Perk_Berserker_Dark'
	IconMat8 = Texture'SunriseHUD.Icons.Perk_Berserker_Gold'
	IconMat9 = Texture'SunriseHUD.Icons.Perk_Berserker_Master'
	IconMat10 = Texture'SunriseHUD.Icons.Perk_Berserker_Elite'
	
	VeterancyName="Берсеркер"
	Requirements(0)="Нанести %x повреждений оружием ближнего боя"

	SRLevelEffects(0)="10% extra melee damage|5% faster melee movement|10% less damage from Bloat Bile|10% discount on Katana/Chainsaw/Sword|Can't be grabbed by Clots"
	SRLevelEffects(1)="20% extra melee damage|5% faster melee attacks|10% faster melee movement|25% less damage from Bloat Bile|5% resistance to all damage|20% discount on Katana/Chainsaw/Sword|Can't be grabbed by Clots"
	SRLevelEffects(2)="40% extra melee damage|10% faster melee attacks|15% faster melee movement|35% less damage from Bloat Bile|10% resistance to all damage|30% discount on Katana/Chainsaw/Sword|Can't be grabbed by Clots|Zed-Time can be extended by killing an enemy while in slow motion"
	SRLevelEffects(3)="60% extra melee damage|10% faster melee attacks|20% faster melee movement|50% less damage from Bloat Bile|15% resistance to all damage|40% discount on Katana/Chainsaw/Sword|Can't be grabbed by Clots|Up to 2 Zed-Time Extensions"
	SRLevelEffects(4)="80% extra melee damage|15% faster melee attacks|20% faster melee movement|65% less damage from Bloat Bile|20% resistance to all damage|50% discount on Katana/Chainsaw/Sword|Can't be grabbed by Clots|Up to 3 Zed-Time Extensions"
	SRLevelEffects(5)="100% extra melee damage|20% faster melee attacks|20% faster melee movement|75% less damage from Bloat Bile|30% resistance to all damage|60% discount on Katana/Chainsaw/Sword|Spawn with a Chainsaw|Can't be grabbed by Clots|Up to 4 Zed-Time Extensions"
	SRLevelEffects(6)="100% extra melee damage|25% faster melee attacks|30% faster melee movement|80% less damage from Bloat Bile|40% resistance to all damage|70% discount on Katana/Chainsaw/Sword|Spawn with a Chainsaw and Body Armor|Can't be grabbed by Clots|Up to 4 Zed-Time Extensions"
	CustomLevelInfo="%r extra melee damage|%s faster melee attacks|20% faster melee movement|80% less damage from Bloat Bile|%l resistance to all damage|%d discount on Katana/Chainsaw/Sword|Spawn with a Chainsaw and Body Armor|Can't be grabbed by Clots|Up to 4 Zed-Time Extensions"
}