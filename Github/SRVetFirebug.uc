class SRVetFirebug extends SRVeterancyTypes
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
	return Min(StatOther.RFlameThrowerDamageStat,FinalInt);
}

/*static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	FinalInt = PerkLevelRequirement(CurLevel,ReqNum);
	return Min(StatOther.RFlameThrowerDamageStat,FinalInt);
}

static function int PerkLevelRequirement(byte CurLevel, byte ReqNum)
{
	local array<float> StartReq,WholeReq;
	local int FinalInt;
	
	StartReq.Insert(0,3);
	WholeReq.Insert(0,3);
	
	StartReq[0] =    500000;
	WholeReq[0] =   6000000;
	StartReq[1] =   2000000;
	WholeReq[1] = 294000000;
	StartReq[2] =  18000000;
	WholeReq[2] = 300000000;
	
	FinalInt = int(ArythmProgression(CurLevel,StartReq,WholeReq));
	
	return FinalInt;
}*/

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float ret;
	
	ret = 1.0;

	if ( Flamethrower(Other) != none 
	|| FlamethrowerM(Other) != none 
	|| Spitfire(Other) != none
	|| TXM8(Other) != none )
	{
		ret = 1.0 + 0.05 * float(KFPRI.ClientVeteranSkillLevel);
	}
	if ( MAC10MP(Other) != none || MAC10MPM(Other) != none || HornetGRifle(Other) != none )
	{
		ret = 1.0 + 0.025 * float(KFPRI.ClientVeteranSkillLevel);
	}

	return ret;
}

static function float DecapDamageModifier(PlayerReplicationInfo PRI, Pawn Victim, class<DamageType> DmgType)
{
	return 2.0;
}

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
	
	if ( AmmoType == class'FlameAmmo1_' )
	{
		ret = 4.00/ 3.00 + 0.10 * float(KFPRI.ClientVeteranSkillLevel);
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
		ret = Super.AddExtraAmmoFor(KFPRI,AmmoType);
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
		/*if ( KFPRI.ClientVeteranSkillLevel < 6 )
			ret = 1.50;
		else ret = 1.25 + 0.05 * float(KFPRI.ClientVeteranSkillLevel);*/
	}
	return ret * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
}

static function int ExtraRange(KFPlayerReplicationInfo KFPRI)
{
	return 0 + Max(0,(KFPRI.ClientVeteranSkillLevel-1))/5;
}

static function float GetFireFieldDurationBonus(KFPlayerReplicationInfo KFPRI)
{
	return 0.02 * float(KFPRI.ClientVeteranSkillLevel); // до 80% увеличения длительности
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
	local class<KFWeaponDamageType> KFWDT;
	
	KFWDT = class<KFWeaponDamageType>(DmgType);
	if ( KFWDT != none && KFWDT.default.bDealBurningDamage /*&& !KFWDT.default.bLocationalHit*/
	|| class<SRFireDamageType>(DmgType) != none )
		return 0; // 100% reduction in damage from fire
	return Super.ReduceDamage(KFPRI,Injured,Instigator,InDamage,DmgType);
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'FlameNadeImproved';
}

static function class<DamageType> GetMAC10DamageType(KFPlayerReplicationInfo KFPRI)
{
	return class'DamTypeMAC10Firebug';
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float ret;
	
	ret = 1.0;
	
	if ( Flamethrower(Other) != none
	|| FlamethrowerM(Other) != none
	|| Spitfire(Other) != none )
	{
		ret = 1.5 + 0.05 * float(KFPRI.ClientVeteranSkillLevel);
	}
	if ( MAC10MP(Other) != none || MAC10MPM(Other) != none || FlareRevolverNew(Other) != none
		|| DualFlareRevolverNew(Other) != none || M202A1fw(Other) != none || HornetGRifle(Other) != none )
	{

		ret = 1.25 + 0.03 * float(KFPRI.ClientVeteranSkillLevel);
	}
	return ret * Super.GetReloadSpeedModifier(KFPRI,Other);
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float ret;
	
	ret = 1.0;
	
	if ( Item == class'FlameThrowerPickup' 
		|| Item == class'MAC10Pickup' 
		|| Item == class'FlaregunPickup'
		|| Item == class'FlameThrowerPickupM' 
		|| Item == class'TXM8Pickup' 
		|| Item == class'MAC10PickupM' 
		|| Item == class'FN2000Pickup' 
		|| Item == class'PMPickup'
		|| Item == class'DualPMPickup' 
		|| Item == class'FlareRevolverNewPickup' 
		|| Item == class'SpitfirePickup'
		|| Item == class'DualFlareRevolverNewPickup' 
		|| Item == class'TrenchgunNewPickup' 
		|| Item == class'HornetGPickup' )
	{
		ret = GetDefaultCostScaling(KFPRI.ClientVeteranSkillLevel);
	}
	
	/*if ( Item == class'FireBombPickup' )
		ret *= 0.5;*/

	if ( Item == class'Vest' )
	{
		ret *= 0.5;
	}
	
	return ret;
}

/*static function float GetAmmoCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float ret;
	
	ret = 1.0;
	
	if ( Item == class'FireBombPickup' )
		ret *= 0.7;
	return 1.00;
}*/

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	local Inventory I;
	local SRPlayerReplicationInfo SRPRI;
	
	Super.AddDefaultInventory(KFPRI,P);

	if ( SRPlayerReplicationInfo(KFPRI).bRespawned )
		return;
		
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	SRPlayerReplicationInfo(KFPRI).bRespawned = true;
	
	if ( KFPRI.ClientVeteranSkillLevel > 5 )
		P.ShieldStrength += 25 * (1+(KFPRI.ClientVeteranSkillLevel-1)/5);//6-й левел 50 брони, 11-й левел 75 брони, 16-й 100 брони, 21-й 125 брони, 26-й 150 брони, 31-й 175 брони, 36-й 200 брони.

	if ( KFPRI.ClientVeteranSkillLevel > 5 && !SRPRI.HasSkinGroup("Mortal") )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.FlameThrowerM", GetCostScaling(KFPRI, class'FlamethrowerPickupM'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 0 && SRPRI.HasSkinGroup("Mortal") )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.Spitfire", GetCostScaling(KFPRI, class'SpitfirePickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 10 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.MAC10MPM", GetCostScaling(KFPRI, class'MAC10PickupM'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 15 )
		KFHumanPawn(P).CreateInventoryVeterancy("Masters.FireBombExplosive", GetCostScaling(KFPRI, class'FireBombPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 20 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.Flaregun", GetCostScaling(KFPRI, class'FlaregunPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 30 && KFPRI.ClientVeteranSkillLevel < 36 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.FlareRevolverNew", GetCostScaling(KFPRI, class'FlareRevolverNewPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 35 )
		KFHumanPawn(P).CreateInventoryVeterancy("Masters.M79FGrenadeLauncher", GetCostScaling(KFPRI, class'M79FPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 30 )
	{
		for(I=P.Inventory; I!=none; I=I.Inventory)
		{
			if ( Flaregun(I) != none )
			{
				Flaregun(I).AddAmmo(10,0);
			}
			if ( Frag1_(I) != none )
			{
				Frag1_(I).AddAmmo(2,0);
			}
		}
	}
}
static function int GetMaxArmor(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel > 40 )
		return 300;
	else if ( KFPRI.ClientVeteranSkillLevel > 35 )
		return 200;
	else if ( KFPRI.ClientVeteranSkillLevel > 30 )
		return 175;
	else if ( KFPRI.ClientVeteranSkillLevel > 25 )
		return 150;
	else if ( KFPRI.ClientVeteranSkillLevel > 20 )
		return 125;

	return super.GetMaxArmor(KFPRI);
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
	S = "+" $ GetPercentStr(Add) $ default.PerkDescription[0];
	
	//S = "+" $ GetPercentStr(FMax(0.50,0.25 + 0.05 * float(Level))) $ default.PerkDescription[0];
	
	S = S $ "+" $ GetPercentStr(0.50 + 0.05 * float(Level)) $ default.PerkDescription[1];
	
	if ( Level > 0 )
	{
		S = S $ "+" $ GetPercentStr(0.00 + 0.05 * float(Level)) $ default.PerkDescription[2];
	}
	
	S = S $ "+" $ GetPercentStr(0.33 + 0.10 * float(Level)) $ default.PerkDescription[3];
	
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
	
	ret = 0.6;
	
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
		ret = 1.5;
	}
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
}

defaultproperties
{
	PerkDescription(0)=" урона огнем|"
	PerkDescription(1)=" скорости перезарядки огнемета|"
	PerkDescription(2)=" к вместимости канистры с топливом|"
	PerkDescription(3)=" запас горючего|"
	PerkDescription(4)="Может переносить до "
	PerkDescription(5)=" гранат|"
	PerkDescription(6)=" поджигательных мин|"
	PerkDescription(7)=" длительности горения огненного поля|"
	PerkDescription(8)=" скидка на поджигающее оружие|"
	PerkDescription(9)="Ранг "
	PerkDescription(10)=", бонусы:|"
	PerkDescription(11)="Пистолет Макарова"
	PerkDescription(12)=" дальности огнемета|"
	PerkDescription(13)=" к запасу патронов|"
	PerkDescription(14)=" ед. переносимого веса|"
	PerkDescription(15)=" к скорости бега|"
	PerkDescription(16)=" скорости восстановления шприца|"
	PerkDescription(17)="Видит здоровье монстров с "
	PerkDescription(18)=" метров|"
	PerkDescription(19)="Особенности перка:|Гранаты поджигают врагов и оставляют горящее поле|Полная неуязвимость к огню|Стартовый инвентарь:|"
	PerkDescription(20)="Пистолет Макарова, Огнемет, 50 ед брони"
	PerkDescription(21)="Пистолет Макарова, Огнемет, MAC-10, 75 ед брони"
	PerkDescription(22)="Пистолет Макарова, Огнемет, MAC-10, Поджигательные мины, 100 ед брони"
	PerkDescription(23)="Пистолет Макарова, Огнемет, MAC-10, Поджигательные мины, Сигнальная ракетница, 125 ед брони"
	PerkDescription(24)="Пистолет Макарова, Огнемет, MAC-10, Пистолет Макарова, Поджигательные мины, Сигнальная ракетница, 150 ед брони"
	PerkDescription(25)="Пистолет Макарова, Огнемет, MAC-10, Flare Revolver, Поджигательные мины, Сигнальная ракетница, 175 ед брони"
	PerkDescription(26)="Пистолет Макарова, Огнемет, MAC-10, M79 Поджигательный, Поджигательные мины, Сигнальная ракетница, 200 ед брони"
	PerkDescription(27)="Нет|"
	
	PerkIndex=5

	IconMat1 = Texture'SunriseHUD.Icons.Perk_Firebug_Green'
	IconMat2 = Texture'SunriseHUD.Icons.Perk_Firebug_Orange'
	IconMat3 = Texture'SunriseHUD.Icons.Perk_Firebug_Blue'
	IconMat4 = Texture'SunriseHUD.Icons.Perk_Firebug_Purple'
	IconMat5 = Texture'SunriseHUD.Icons.Perk_Firebug_Red'
	IconMat6 = Texture'SunriseHUD.Icons.Perk_Firebug_Silver'
	IconMat7 = Texture'SunriseHUD.Icons.Perk_Firebug_Dark'
	IconMat8 = Texture'SunriseHUD.Icons.Perk_Firebug_Gold'
	IconMat9 = Texture'SunriseHUD.Icons.Perk_Firebug_Master'
	IconMat10 = Texture'SunriseHUD.Icons.Perk_Firebug_Elite'

	VeterancyName="Огнеметчик"
	Requirements(0)="Нанести %x повреждений огнем"
}
