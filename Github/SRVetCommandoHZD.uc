class SRVetCommandoHZD extends SRVetCommando;

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	local float ret;
	
	ret = 1.00;
	
	if ( Frag1Ammo(Other) != none )
	{
		return 0.4;
	}

	if ( FN2000MgAmmo(Other) != none )
	{
			ret = 0.0;
	}

	if ( BullpupAmmo(Other) != none 
	|| AK47Ammo(Other) != none 
	|| AK117SAAmmo(Other) != none 
	|| SCARMK17Ammo(Other) != none 
	|| M4Ammo(Other) != none 
	|| FNFALSAAmmo(Other) != none
	|| AN94Ammo(Other) != none 
	|| AN94gAmmo(Other) != none 
	|| SR3MAmmo(Other) != none 
	|| M4A1IronBeastSAAmmo(Other) != none 
	|| FNC30Ammo(Other) != none 
	|| AK12SAv2Ammo(Other) != none 
	|| codolAmmo(Other) != none
	|| OC33LLIAmmo(Other) != none 
	|| AUG_A3ARAmmo(Other) != none 
	|| XM8Ammo(Other) != none 
	|| FFOWARLLIAmmo(Other) != none 
	|| GalilComicSAAmmo(Other) != none 
	|| PDWAmmo(Other) != none
	|| AK12LLIAmmo(Other) != none 
	|| MKb42NewAmmo(Other) != none 
	|| M7A3MSRAmmo(Other) != none 
	|| M4A1SAAmmo(Other) != none )
	{
		ret = 1.25 + 0.085 * float(Max(0,(KFPRI.ClientVeteranSkillLevel-1)/5));
	}
	if ( RadioBombAmmo(Other) != none )
	{
		ret = 1.50 + 0.50 * float(Max(0,(KFPRI.ClientVeteranSkillLevel-1)/5));
	}
	if ( Frag1Ammo(Other) != none )
	{
		ret = 1.00 + 0.20 * float(KFPRI.ClientVeteranSkillLevel/4);
	}

	return ret * Super.GetAmmoPickupMod(KFPRI,Other);
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float ret;
	
	ret = 1.00;
	
	if ( AmmoType == class'GrenadePistolLLILAmmo'
		|| AmmoType == class'FNC30M203Ammo'
		|| AmmoType == class'Armacham203Ammo' ) return ret;
	
	if ( AmmoType == class'BullpupAmmo' 
	|| AmmoType == class'AK47Ammo' 
	|| AmmoType == class'AK117SAAmmo' 
	|| AmmoType == class'SCARMK17Ammo' 
	|| AmmoType == class'M4Ammo' 
	|| AmmoType == class'GalilComicSAAmmo'
	|| AmmoType == class'AN94Ammo' 
	|| AmmoType == class'AN94gAmmo' 
	|| AmmoType == class'M4A1IronBeastSAAmmo' 
	|| AmmoType == class'FNC30Ammo'
	|| AmmoType == class'SR3MAmmo' 
	|| AmmoType == class'FFOWARLLIAmmo' 
	|| AmmoType == class'PDWAmmo'
	|| AmmoType == class'OC33LLIAmmo' 
	|| AmmoType == class'AUG_A3ARAmmo' 
	|| AmmoType == class'XM8Ammo' 
	|| AmmoType == class'M4A1SAAmmo' 
	|| AmmoType == class'AK12SAv2Ammo' 
	|| AmmoType == class'codolAmmo'
	|| AmmoType == class'XM8gAmmo' 
	|| AmmoType == class'AK12LLIAmmo' 
	|| AmmoType == class'MKb42NewAmmo' 
	|| AmmoType == class'M7A3MSRAmmo' 
	|| AmmoType == class'FNFALSAAmmo' )
	{
		ret = 1.25 + 0.1 * float(Max(0,(KFPRI.ClientVeteranSkillLevel-1)/5));
	}
	else if ( AmmoType == class'RadioBombAmmo' )
	{
		ret = 1.50 + 1.00 * float(Max(0,(KFPRI.ClientVeteranSkillLevel-1)/5));
	}
	else if ( AmmoType == class'Frag1Ammo' )
	{
		ret = 1.00 + 0.20 * float(KFPRI.ClientVeteranSkillLevel/4);
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
	
	ret = 1.00;
	
	if ( DmgType == class'DamTypeFFOWARLLI'
	|| DmgType == class'DamTypeM4A1SAAssaultRifle'
	|| DmgType == class'DamTypePDWAssaultRifle'
	|| DmgType == class'DamTypeM4A1IronBeastSA'
	|| DmgType == class'DamTypeFNC30AssaultRifle'
	|| DmgType == class'DamTypeAK12LLI'
	|| DmgType == class'DamTypecodol')
	{
		ret *= 0.2;
	}

	/*if ( DmgType == class'DamTypeAK12LLI'
	|| DmgType == class'DamTypecodol' )
	{
		ret *= 0.6;
	}*/
	
	if ( class<SRWeaponDamageType>(DmgType).default.bCommando || DmgType == class'DamTypeBullpup' || DmgType == class'DamTypeM4AssaultRifle'
		|| DmgType == class'DamTypeAK47AssaultRifle' || DmgType == class'DamTypeSCARMK17New' || DmgType == class'DamTypeAK12SAv2' )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 2.0;
		}
		else
		{
			ret = 2.0 + 0.03125 * float(KFPRI.ClientVeteranSkillLevel);
		}
	}
	return ret * 0.9 * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
	local float Reduction;
	
	Reduction = 1.00;

	if ( class<DamTypeAN94Proj>(DmgType) != none || class<DamTypeM79Grenade>(DmgType) != none || class<DamTypeXM8Grenade>(DmgType) != none )
	{
		Reduction = 0.20;
		Goto SetReduction;
	}
	if ( class<DamTypeRadioBomb>(DmgType) != none )
	{
		Reduction = 0/*1.0 - 0.01 * float(KFPRI.ClientVeteranSkillLevel)*/;
		Goto SetReduction;
	}
	
	/*if ( class<DamTypeRadioBomb>(DmgType) != none )
	{
		Reduction = 0.15;
		Goto SetReduction;
	}*/
	
	if ( class<SirenScreamDamage>(DmgType) != none || class<DamTypePoison>(DmgType) != none )
	{
		Reduction = 0.80 - 0.01 * float(KFPRI.ClientVeteranSkillLevel);
		Goto SetReduction;
	}
	
	if ( class<DamTypePatriarchChaingun>(DmgType) != none )
	{
		Reduction = 0.45 - 0.01 * float(KFPRI.ClientVeteranSkillLevel);
		Goto SetReduction;
	}
	
SetReduction:
	
	return Reduction * Super.ReduceDamage(KFPRI,Injured,Instigator,InDamage,DmgType);
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	local Inventory I;
	local string weapon;
	Super(SRVeterancyTypes).AddDefaultInventory(KFPRI,P);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	
	if ( SRPlayerReplicationInfo(KFPRI).bRespawned )
		return;
		
	SRPlayerReplicationInfo(KFPRI).bRespawned = true;
	
	if ( KFPRI.ClientVeteranSkillLevel >= 0 && KFPRI.ClientVeteranSkillLevel < 6 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.BullpupM", GetCostScaling(KFPRI, class'BullpupPickupM'));

		for(I=P.Inventory; I!=none; I=I.Inventory)
		{
			if ( BullpupM(I) != none )
			{
				BullpupM(I).AddAmmo(150,0);
			}
		}
	}
		
	if ( KFPRI.ClientVeteranSkillLevel > 5 && KFPRI.ClientVeteranSkillLevel < 11 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.MKb42New", GetCostScaling(KFPRI, class'MKb42NewPickup'));

		for(I=P.Inventory; I!=none; I=I.Inventory)
		{
			if ( MKb42New(I) != none )
			{
				MKb42New(I).AddAmmo(150,0);
			}
		}
	}
		
	if ( KFPRI.ClientVeteranSkillLevel > 10 && KFPRI.ClientVeteranSkillLevel < 16 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.M4AssaultRifleM", GetCostScaling(KFPRI, class'M4PickupM'));

		for(I=P.Inventory; I!=none; I=I.Inventory)
		{
			if ( M4AssaultRifleM(I) != none )
			{
				M4AssaultRifleM(I).AddAmmo(150,0);
			}
		}
	}
		
	if ( KFPRI.ClientVeteranSkillLevel > 15 && KFPRI.ClientVeteranSkillLevel < 21 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AUG_A3AR", GetCostScaling(KFPRI, class'AUG_A3ARPickup'));

		for(I=P.Inventory; I!=none; I=I.Inventory)
		{
			if ( AUG_A3AR(I) != none )
			{
				AUG_A3AR(I).AddAmmo(150,0);
			}
		}
	}
		
	if ( KFPRI.ClientVeteranSkillLevel > 15 && KFPRI.ClientVeteranSkillLevel < 26 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SCARMK17AssaultRifleM", GetCostScaling(KFPRI, class'SCARMK17PickupM'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 20 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AK47SHAssaultRifleM", GetCostScaling(KFPRI, class'AK47SHPickupM'));

		for(I=P.Inventory; I!=none; I=I.Inventory)
		{
			if ( AK47SHAssaultRifleM(I) != none )
			{
				AK47SHAssaultRifleM(I).AddAmmo(150,0);
			}
		}
	}

	if ( (KFPRI.ClientVeteranSkillLevel > 25 && KFPRI.ClientVeteranSkillLevel < 31 || KFPRI.ClientVeteranSkillLevel > 35) && Mid(weapon, 3, 1) != "4" )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AN94AssaultRifle", GetCostScaling(KFPRI, class'AN94Pickup'));
	
	if ( KFPRI.ClientVeteranSkillLevel > 30 )
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SR3MSpecnazRifle", GetCostScaling(KFPRI, class'SR3MPickup'));
		
	if ( KFPRI.ClientVeteranSkillLevel > 35 )
		P.ShieldStrength += 100;

	if (Mid(weapon, 3, 1) == "4")
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.M4A1SAAssaultRifle", GetCostScaling(KFPRI, class'M4A1SAPickup'));
	}
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
	
	S = "+" $ GetPercentStr(Add*1.7) $ default.PerkDescription[0];
	//S = "+" $ GetPercentStr((FMax(0.50,0.25 + 0.05 * float(Level)))*1.7) $ default.PerkDescription[0];
	
	S = S $ GetPercentStr( 0.01*float(int(100.0*(0.60 + 0.0075 * float(Level)))) ) $ default.PerkDescription[1];
	
	S = S $ "+" $ GetPercentStr( 0.25 + 0.05 * float((Level-1)/5) ) $ default.PerkDescription[2];
	
	S = S $ "+" $ GetPercentStr( 0.20 + 0.02 * float(Level) ) $ default.PerkDescription[3];
	
	S = S $ GetPercentStr ( 0.20 + 0.01 * float(Level) ) $ default.PerkDescription[4];
	
	S = S $ GetPercentStr ( 0.55 + 0.01 * float(Level) ) $ default.PerkDescription[5];
	
	S = S $ default.PerkDescription[6] $ string(30+Level) $ default.PerkDescription[7];
	
	S = S $ GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[8];
	
	S = S $ default.PerkDescription[9] $ string(Max(0,(Level-1)/5)) $ default.PerkDescription[10];
	
	S = S $ default.PerkDescription[11] $ string(12+4*((Level-1)/5)) $ default.PerkDescription[12];
	
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
	
	if ( Level > 15 )
	{
		Add = 0.05;
		
		if ( Level > 30 )
		{
			Add = 0.10;
		}
		
		S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[14];
	}
	
	if ( Level > 20 )
	{
		Add = 0.40;
		
		if ( Level > 30 )
		{
			Add = 0.65;
		}
		
		S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[15];
	}
	
	S = S $ default.PerkDescription[16];
	
	S = S $ default.PerkDescription[17+(Level-1)/5];
	
	return S;
}

static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI, class<KFMonster> MonsterClass)
{
	local float ret;
	
	ret = 0.4;
	
	if ( class<DKShiver>(MonsterClass) != none )
	{
		ret = 0.70;
		//return 1.50 * Super.GetMoneyReward(SRPRI,MonsterClass);
	}
	
	if ( class<DKStalker>(MonsterClass) != none )
	{
		ret = 0.70;
		//return 2.00 * Super.GetMoneyReward(SRPRI,MonsterClass);
	}
	
	if ( class<DKPoisoner>(MonsterClass) != none )
	{
		ret = 1.00;
		//return 2.00 * Super.GetMoneyReward(SRPRI,MonsterClass);
	}
	
	if ( class<DKCrawler>(MonsterClass) != none )
	{
		ret = 0.60;
		//return 1.50 * Super.GetMoneyReward(SRPRI,MonsterClass);
	}
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
	//return Super.GetMoneyReward(SRPRI,MonsterClass);
}

defaultproperties
{
	PerkDescription(0)=" урона штурмовыми винтовками|"
	PerkDescription(1)=" уменьшение отдачи штурмовых винтовок|"
	PerkDescription(2)=" вместимость магазина штурмовых винтовок|"
	PerkDescription(3)=" к скорости перезарядки любого оружия|"
	PerkDescription(4)=" сопротивление к яду и воплю сирены|"
	PerkDescription(5)=" уменьшение урона от пулемета патриарха|"
	PerkDescription(6)="После каждого самолечения остается как минимум "
	PerkDescription(7)=" ед здоровья|"
	PerkDescription(8)=" скидка на штурмовые винтовки|"
	PerkDescription(9)="Ранг "
	PerkDescription(10)=", бонусы:|"
	PerkDescription(11)="Видит здоровье монстров с "
	PerkDescription(12)=" метров|"
	PerkDescription(13)=" ед. переносимого веса|"
	PerkDescription(14)=" к скорости бега|"
	PerkDescription(15)=" скорости восстановления шприца|"
	PerkDescription(16)="Особенности перка:|Гранаты дезориентируют монстров|Дополнительный урон против Отравителей и Шиверов|Стартовый инвентарь:|"
	PerkDescription(17)="ОЦ-33 и L22A1"
	PerkDescription(18)="ОЦ-33 и MKb42"
	PerkDescription(19)="ОЦ-33 и M4"
	PerkDescription(20)="ОЦ-33, AUG A3 и SCARMK-17"
	PerkDescription(21)="ОЦ-33, АК-47 и SCARMK-17"
	PerkDescription(22)="ОЦ-33, АК-47 и АН-94 Абакан"
	PerkDescription(23)="ОЦ-33, АК-47 и СР-3М Вихрь"
	PerkDescription(24)="ОЦ-33, АК-47, АН-94 Абакан, СР-3М Вихрь, броня"


}