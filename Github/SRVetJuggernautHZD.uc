class SRVetJuggernautHZD extends SRVetJuggernaut;
	
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
	return Min(StatOther.RMachinegunDamageStat,FinalInt);
}
	
/*static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	FinalInt = PerkLevelRequirement(CurLevel,ReqNum);

	if( ReqNum==0 )
		return Min(StatOther.RWeldingArmorPointsStat,FinalInt);
	return Min(StatOther.RMachinegunDamageStat,FinalInt);
}*/

/*static function int PerkLevelRequirement(byte CurLevel, byte ReqNum)
{
	local array<float> StartReq,WholeReq;
	local int FinalInt;
	
	StartReq.Insert(0,3);
	WholeReq.Insert(0,3);
	
	if ( ReqNum == 0 )
	{
		StartReq[0] =     1600;
		WholeReq[0] =    20000;
		StartReq[1] =     6000;
		WholeReq[1] =   980000;
		StartReq[2] =   100000;
		WholeReq[2] =  1000000;
	}
	else
	{
		StartReq[0] =    500000;
		WholeReq[0] =   6000000;
		StartReq[1] =   2000000;
		WholeReq[1] = 219000000;
		StartReq[2] =  15000000;
		WholeReq[2] = 225000000;
	}
	
	FinalInt = int(ArythmProgression(CurLevel,StartReq,WholeReq));
	
	return FinalInt;
}*/

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{	
	local float ret;
	
	ret = 1.0;
	
	if ( DmgType == class'DamTypePKPDT' || DmgType == class'DamTypeLaserRCW' )
	{
		ret *= 0.1;
	}

	if ( class<SRWeaponDamageType>(DmgType) != none )
	{
		if ( class<SRWeaponDamageType>(DmgType).default.bJugger )
		{
			ret = 1.2 + 0.025 * float(KFPRI.ClientVeteranSkillLevel);
		}
	}
	
	return ret * 0.9 * Super.AddDamage(KFPRI,Injured,DamageTaker,InDamage,DmgType);
}

static function float DecapDamageModifier(PlayerReplicationInfo PRI, Pawn Victim, class<DamageType> DmgType)
{
	return 2.5;
}

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	local float ret;
	
	if ( Frag1Ammo(Other) != None )
		return 0.0;
		
	ret = 1.0;

	if ( FN2000MgAmmo(Other) != none
	|| Armacham203Ammo(Other) != none
	|| FNC30M203Ammo(Other) != none  )
	{
			ret = 2.0;
	}

	if ( ThompsonAmmo(Other) != none 
	|| SA80LSWAmmo(Other) != none 
	|| PKMAmmo(Other) != none 
	|| M249Ammo(Other) != none 
	|| ultimaxGALAmmo(Other) != none 
	|| BerettaPx4Ammo(Other) != none 
	|| DBerettaPx4Ammo(Other) != none 
	|| RPK47Ammo(Other) != none 
	|| RPKAmmo(Other) != none 
	|| AUG_A1MGAmmo(Other) != none 
	|| M134DTRAmmo(Other) != none 
	|| ZEDGunLLIAmmo(Other) != none
	|| M60Ammo(Other) != none 
	|| M134DTAmmo(Other) != none 
	|| XMV850Ammo(Other) != none  
	|| THR40DTAmmo(Other) != none  
	|| FNC30Ammo(Other) != none 
	|| ZEDGunMLLIAmmo(Other) != none 
	|| AK47JAmmo(Other) != none
	|| StingerAmmo(Other) != none 
	|| LaserRCWAmmo(Other) != none 
	|| HK23ESAAmmo(Other) != none 
	|| PKPDTAmmo(Other) != none 
	|| PKPDTCAmmo(Other) != none 
	|| PatGunAmmo(Other) != none )
	{
		ret = 1.33 + 0.13 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5));
	}

	return ret * Super.GetAmmoPickupMod(KFPRI,Other);
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float ret;
	local string weapon;
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	
	ret = 1.0;

	if ( AmmoType == class'GrenadePistolLLILAmmo'
		|| AmmoType == class'FNC30M203Ammo'
		|| AmmoType == class'Armacham203Ammo' ) return ret;
	
	if ( AmmoType == class'FragAmmo' || AmmoType == class'Frag1Ammo' )
	{
		if ( KFPRI.ClientVeteranSkillLevel < 6 )
		{
			ret = 1.2;
		}
		else
		{
			ret = 1.2 + 0.7 * float((KFPRI.ClientVeteranSkillLevel-1)/5);
		}
	}

	else if ( AmmoType == class'PKPDTAmmo' && Mid(weapon, 7, 1) == "V" )
	{
		ret = 1.66 + 0.13 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5));
	}
	else if ( AmmoType == class'ThompsonAmmo'
	|| AmmoType == class'SA80LSWAmmo'
	|| AmmoType == class'PKMAmmo'
	|| AmmoType == class'M249Ammo'
	|| AmmoType == class'M134DTRAmmo'
	|| AmmoType == class'BerettaPx4Ammo'
	|| AmmoType == class'DBerettaPx4Ammo'
	|| AmmoType == class'RPK47Ammo'
	|| AmmoType == class'RPKAmmo'
	|| AmmoType == class'AUG_A1MGAmmo'
	|| AmmoType == class'ultimaxGALAmmo'
	|| AmmoType == class'HK23ESAAmmo'
	|| AmmoType == class'M60Ammo'
	|| AmmoType == class'M134DTAmmo'
	|| AmmoType == class'PKPDTCAmmo'
	|| AmmoType == class'AK47JAmmo'
	|| AmmoType == class'ZEDGunMLLIAmmo'
	|| AmmoType == class'LaserRCWAmmo'
	|| (AmmoType == class'PKPDTAmmo' && Mid(weapon, 7, 1) != "V")
	|| AmmoType == class'ZEDGunLLIAmmo'
	|| AmmoType == class'XMV850Ammo'
	|| AmmoType == class'THR40DTAmmo'
	|| AmmoType == class'FNC30Ammo'
	|| AmmoType == class'StingerAmmo'
	|| AmmoType == class'PatGunAmmo' )
	{
		ret = 1.33 + 0.13 * FMax(0.0,float((KFPRI.ClientVeteranSkillLevel-1)/5));
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

static function string GetCustomLevelInfo( byte Level )
{
	local string S;
	local float Add;
	
	S = "";
	
	if ( Level >= 0 )
	{
		S = "+" $ GetPercentStr((0.2 + 0.025*float(Level))*1.8) $ default.PerkDescription[0];
	}
	
	S = S $ GetPercentStr(0.30 + 0.01 * float(Level)) $ default.PerkDescription[1];
	
	S = S $ "+" $ GetPercentStr(0.33 + 0.13 * FMax(0.0,float((Level-1)/5))) $ default.PerkDescription[2];
	
	S = S $ "+" $ GetPercentStr(1.0 + 0.05 * float(Level)) $ default.PerkDescription[3];
	
	if ( Level < 6 )
	{
		S = S $ "x1.6";
	}
	else
	{
		S = S $ "x" $ string(2+(Level-6)/10) $ "." $ string(5*(((Level+4)/5)%2));
	}
	
	S = S $ default.PerkDescription[4];
	
	S = S $ GetPercentStr(0.20 + 0.01*float(int(100.0*0.0075*float(Level)))) $ default.PerkDescription[5];
	
	if ( Level < 6 )
	{
		Add = 19.0;
	}
	else
	{
		Add = 21.0 + 3.0 * float((Level-1)/5);
	}
	
	S = S $ default.PerkDescription[6] $ string(int(Add)) $ default.PerkDescription[7];
	
	if ( Level < 6 )
	{
		Add = 6.0;
	}
	else
	{
		Add = 6.0 + 3.43 * float((Level-1)/5);
	}
	
	S = S $ default.PerkDescription[6] $ string(int(Add)) $ default.PerkDescription[8];
	
	S = S $ GetPercentStr(1.0 - GetDefaultCostScaling(Level)) $ default.PerkDescription[9];
	
	S = S $ default.PerkDescription[10] $ string(Max(0,(Level-1)/5)) $ default.PerkDescription[11];
	
	S = S $ default.PerkDescription[27] $ GetPercentStr(0.025 * float(Level)) $ default.PerkDescription[28];
	
	if ( Level < 6 )
	{
		S = S $ default.PerkDescription[26];
	}
	else
	{
		if ( Level >=0 )
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
		
		if ( Level > 30 )
		{
			Add = 16.0;
			
			if ( Level > 35 )
			{
				Add = 24.0;
			}
			
			S = S $ default.PerkDescription[16] $ string(int(Add)) $ default.PerkDescription[17];
		}
	}
	
	S = S $ default.PerkDescription[18];
	
	if ( Level < 6 )
	{
		S = S $ default.PerkDescription[12];
	}
	else
	{
		S = S $ default.PerkDescription[18+(Level-1)/5];
	}

	return S;
}

static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI, class<KFMonster> MonsterClass)
{
	local float ret;
	
	ret = 0.4;
	
	return ret * Super.GetMoneyReward(SRPRI,MonsterClass);
}

defaultproperties
{
	PerkDescription(0)=" урона пулеметами|"
	PerkDescription(1)=" уменьшение отдачи у пулеметов|"
	PerkDescription(2)=" к запасу патронов пулеметов|"
	PerkDescription(3)=" к скорости заваривания брони|"
	PerkDescription(4)=" прочность брони|"
	PerkDescription(5)=" уменьшение урона от ближних атак|"
	PerkDescription(6)="Может переносить "
	PerkDescription(7)=" ед. веса|"
	PerkDescription(8)=" ящиков с патронами|"
	PerkDescription(9)=" скидка на пулеметы|"
	PerkDescription(10)=" Ранг "
	PerkDescription(11)=", бонусы:|"
	PerkDescription(12)="Beretta Px4"
	PerkDescription(13)=" к боезапасу не профильного оружия|"
	PerkDescription(14)=" к скорости бега|"
	PerkDescription(15)=" скорости восстановления шприца|"
	PerkDescription(16)="Видит здоровье монстров с "
	PerkDescription(17)=" метров|"
	PerkDescription(18)="Особенности перка:|Любое профильное оружие джаггернаута обладает 80% пробивной способностью|Стартовый инвентарь:|"
	PerkDescription(19)="Galil ARM"
	PerkDescription(20)="Beretta Px4, SA-80 LSW"
	PerkDescription(21)="Beretta Px4, РПК-47, 20 ед. брони"
	PerkDescription(22)="M249 SAW, Beretta Px4, 20 ед. брони"
	PerkDescription(23)="M249 SAW, SA-80 LSW, Beretta Px4, 35 ед. брони"
	PerkDescription(24)="M249 SAW, SA-80 LSW, Galil ARM, Beretta Px4, 55 ед. брони"
	PerkDescription(25)="ПКМ, РПК-47, Galil ARM, Beretta Px4, 75 ед. брони"
	PerkDescription(26)="Нет|"
	PerkDescription(27)="Видит здоровье и броню игрока дальше на "
	PerkDescription(28)="|"
	
   	NumRequirements=1
	PerkIndex=7

	IconMat1 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Green'
	IconMat2 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Orange'
	IconMat3 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Blue'
	IconMat4 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Purple'
	IconMat5 = Texture'SunriseHUD.Icons.Perk_Juggernaut_1Red'
	IconMat6 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Silver'
	IconMat7 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Dark'
	IconMat8 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Gold'
	IconMat9 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Master'
	IconMat10 = Texture'SunriseHUD.Icons.Perk_Juggernaut_Elite'
	
    VeterancyName="Джаггернаут"
    Requirements(0)="Нанести %x повреждений пулеметами"
    Requirements(1)="Нанести %x повреждений пулеметами"
}
