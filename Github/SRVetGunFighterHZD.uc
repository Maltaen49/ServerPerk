class SRVetGunFighterHZD extends SRVetGunFighter;

/*static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
	local float Reduction;
	local SRPlayerReplicationInfo SRPRI;
	
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	
	Reduction = 1.0;
	
	if ( class<DamTypeHeadshotFragGF>(DmgType) != none && SRPRI.HasSkinGroup("Mortal") )
	{
		Reduction = 0;
	}

	return Reduction * Super.ReduceDamage(KFPRI,Injured,Instigator,InDamage,DmgType);
}	*/	

static function float GetHeadShotDamMulti(KFPlayerReplicationInfo KFPRI, KFPawn P, class<DamageType> DmgType)
{
	local float ret;

	if ( DmgType == class'DamTypeSKS' 
	|| DmgType == class'DamTypeJackalLLI' 
	|| DmgType == class'DamTypeJacalv2' 
	|| DmgType == class'DamTypeBornBeastSA'
	|| DmgType == class'DamTypeACR10AssaultRifle'
	|| DmgType == class'DamTypeG43LLI' 
	|| DmgType == class'DamTypecodolV2')
	{
		ret *= 0.1;
	}
	
	if ( class<DamTypeGunfighter>(DmgType) != none && class<DamTypeHeadshotFragGF>(DmgType) == none )
	{
		if ( KFPRI.ClientVeteranSkillLevel >= 0 )
		{
			ret = 2.0 + 0.0875 * float(KFPRI.ClientVeteranSkillLevel);
		}
	}
	else if ( class<DamTypeHeadshotFragGF>(DmgType) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel >= 0 )
		{
			ret = 2.0;
		}
	}
	else
	{
		ret = 1.0;
	}

	return ret * 0.75 * Super.GetHeadShotDamMulti(KFPRI,P,DmgType);
}

static function float DecapDamageModifier(PlayerReplicationInfo PRI, Pawn Victim, class<DamageType> DmgType)
{
	return GetHeadShotDamMulti(KFPlayerReplicationInfo(PRI), KFPawn(Victim),DmgType) ;//* 0.5;1.7
}

/*static function float AimBonus(SRPlayerReplicationInfo SRPRI)
{
	return 0.0075 * float(SRPRI.ClientVeteranSkillLevel);
}*/

static function float AimBonus(SRPlayerReplicationInfo SRPRI)
{
	return 1.0 + 0.015 * float(SRPRI.ClientVeteranSkillLevel);
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
	|| UHGrenadeMAmmo(Other) != none 
	|| BlasterAmmo(Other) != none
	|| FNC30M203Ammo(Other) != none )
	{
			ret = 0.0;
	}

	if ( Magnum44AmmoM(Other) != none || MK23NewAmmo(Other) != none || Colt1911Ammo(Other) != none
		|| DColt1911Ammo(Other) != none || DesertEagleLLIAmmo(Other) != none )
	{
		ret = ( 1.15 + 0.29 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5)) );
	}
	else if ( WinchesterAmmoM(Other) != none || USP45MLLIAmmo(Other) != none || SingleAmmoM(Other) != none || HK1911LLIAmmo(Other) != none )
	{
		ret = ( 1.10 + 0.20 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5)) );
	}
	else if ( JackalLLIAmmo(Other) != none 
	|| BornBeastSAAmmo(Other) != none 
	|| ACR10Ammo(Other) != none 
	|| Jacalv2Ammo(Other) != none )
	{
		ret = ( 1.10 + 0.04 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5)) );
	}

	return ret * Super.GetAmmoPickupMod(KFPRI,Other);
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	if ( AmmoType == class'GrenadePistolLLILAmmo'
		|| AmmoType == class'FNC30M203Ammo'
		|| AmmoType == class'Armacham203Ammo' ) return 1.0;
	
	if (  AmmoType == class'Frag1Ammo' )
	{
		return 1.00 + 0.20 * float(KFPRI.ClientVeteranSkillLevel/4);
	}
	
	if ( AmmoType == class'Magnum44AmmoM' || AmmoType == class'MK23NewAmmo'
		|| AmmoType == class'Colt1911Ammo' || AmmoType == class'DColt1911Ammo'
		|| AmmoType == class'DesertEagleLLIAmmo' )
	{
		return ( 1.15 + 0.30 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5)) );
	}
	else if ( AmmoType == class'WinchesterAmmoM' )
	{
		return ( 1.10 + 0.20 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5)) );
	}
	else if ( AmmoType == class'SingleAmmoM' || AmmoType == class'HK1911LLIAmmo' || AmmoType == class'USP45MLLIAmmo' )
	{
		return ( 1.10 + 0.10 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5)) );
	}
	else if ( AmmoType == class'JackalLLIAmmo' 
	|| AmmoType == class'BornBeastSAAmmo' 
	|| AmmoType == class'Jacalv2Ammo' 
	|| AmmoType == class'ACR10Ammo' )
	{
		return ( 1.10 + 0.04 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5)) );
	}
	
	return 1.0;
}

// Give Extra Items as Default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	local Inventory I;
	local string weapon;
	Super(SRVeterancyTypes).AddDefaultInventory(KFPRI,P);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	if ( SRPlayerReplicationInfo(KFPRI).bRespawned )
		return;
		
	SRPlayerReplicationInfo(KFPRI).bRespawned = true;

	if ( KFPRI.ClientVeteranSkillLevel > 5 && KFPRI.ClientVeteranSkillLevel < 11
	|| KFPRI.ClientVeteranSkillLevel > 15 && KFPRI.ClientVeteranSkillLevel < 21
	|| KFPRI.ClientVeteranSkillLevel > 25 && KFPRI.ClientVeteranSkillLevel < 31
	|| KFPRI.ClientVeteranSkillLevel > 35)
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.MK23New", GetCostScaling(KFPRI, class'MK23NewPickup'));
	}
		
	if ( KFPRI.ClientVeteranSkillLevel > 10 && KFPRI.ClientVeteranSkillLevel < 16
	|| KFPRI.ClientVeteranSkillLevel > 20 && KFPRI.ClientVeteranSkillLevel < 31 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.Colt1911", GetCostScaling(KFPRI, class'Colt1911Pickup'));
	}

	if ( KFPRI.ClientVeteranSkillLevel > 15 && KFPRI.ClientVeteranSkillLevel < 31 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.WinchesterM", GetCostScaling(KFPRI, class'WinchesterPickupM'));
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 30 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.M14EBRBattleRifleM", GetCostScaling(KFPRI, class'M14EBRPickupM'));
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.DesertEagleLLI", GetCostScaling(KFPRI, class'DesertEagleLLIPickup'));
	}
	
	if (Mid(weapon, 9, 1) == "H")
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.UnHolyHandGrenadeM", GetCostScaling(KFPRI, class'UHolyHandGrenadeMPickup'));
	}

	if ( KFPRI.ClientVeteranSkillLevel > 35 )
		P.ShieldStrength += 100;
}

static function string GetCustomLevelInfo( byte Level )
{
	local KFPlayerReplicationInfo KFPRI;
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;
	local string S;
	local float Add;
	
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	
	if ( Level >= 0 )
	{
		Add = 1.0 + 0.0875 * float(Level);
	}
	
	S = "+" $ GetPercentStr(Add*1.6) $ default.PerkDescription[0];
	
	S = S $ GetPercentStr(0.60 + 0.01 * float(Level)) $ default.PerkDescription[1];
	
	S = S $ "+" $ GetPercentStr(0.60 + 0.015 * float(Level)) $ default.PerkDescription[2];
	
	if ( Level < 6 )
	{
		Add = 0.15;
	}
	else
	{
		Add = 0.15 + 0.15 * float((Level-1)/5);
	}
	
	S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[3];

	S = S $ GetPercentStr(1.0 + 0.01 * float(Level)) $ default.PerkDescription[4];
	
	S = S $ default.PerkDescription[5] $ string(5+Level/4) $ default.PerkDescription[6];
	
	S = S $ GetPercentStr(0.10 + 0.01 * float(Level/2)) $ default.PerkDescription[7];
	
	S = S $ default.PerkDescription[8] $ GetPercentStr(1.0 + 0.05 * float(Level)) $ default.PerkDescription[9];
	
	S = S $ GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[10];
	
	S = S $ default.PerkDescription[11] $ string(Max(0,(Level-1)/5)) $ default.PerkDescription[12];

	if ( Level < 6 )
	{
		if (Mid(weapon, 9, 1) == "N")
			Add = 0.48;
		else if (Mid(weapon, 9, 1) != "N")
			Add = 0.18;
	}
	else
	{
		if (Mid(weapon, 9, 1) == "N")
			Add = 0.48 + 0.02 * float((Level-1)/5);
		else if (Mid(weapon, 9, 1) != "N")
			Add = 0.18 + 0.02 * float((Level-1)/5);
	}

	S = S $ "+" $ GetPercentStr(Add) $ default.PerkDescription[13];
	
	if ( Level > 20 )
	{
		Add = 0.0;
			
		if ( Level > 30 )
		{
			Add = 0.65;
		}
		else // if ( Level > 20 )
		{
			Add = 0.40;
		}
			
		S = S $ "+" $ string(Add) $ default.PerkDescription[14];
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
	
	S = S $ default.PerkDescription[17];
	
	S = S $ default.PerkDescription[18+(Level-1)/5];
	
	return S;
}

static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI, class<KFMonster> MonsterClass)
{
	local float ret;
	
	ret = 0.4;
	
	if ( class<DKHusk>(MonsterClass) != none || class<DKDemolisher>(MonsterClass) != none )
	{
		ret = 1.00;
		//return 2.00 * Super.GetMoneyReward(SRPRI,MonsterClass);
	}
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
	//return Super.GetMoneyReward(SRPRI,MonsterClass);
}
