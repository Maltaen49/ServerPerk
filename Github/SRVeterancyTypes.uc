// Written by .:..: (2009)
// Base class of all server veterancy types
class SRVeterancyTypes extends SRVeterancyTypesBase;

var() localized string CustomLevelInfo;
var() localized array<string> SRLevelEffects; // Added in ver 5.00, dynamic array for level effects.
var() byte NumRequirements;
var() localized string 	DisableTag, 
						DisableTag10lvl,
						DisableTag26lvl, 
						DisableTag31lvl,
						DisableTagDonate,
						DisableTagElite,
						DisableTagMAX,
						DisableTagGM,
						DisableTagEU,
						DisableDescription, 
						DisableDescription10lvl,
						DisableDescription26lvl, 
						DisableDescription31lvl,
						DisableDescriptionDonate,
						DisableDescriptionElite,
						DisableDescriptionMAX,
						DisableDescriptionGM,
						DisableDescriptionEU; // Can be set as a reason to hide inventory from specific players.

var		array<string>	PerkDescription;

// Can be used to add in custom stats.
static function AddCustomStats( ClientPerkRepLink Other );

// Return the level of perk that is available, 0 = perk is n/a.
static function byte PerkIsAvailable( ClientPerkRepLink StatOther )
{
	local byte i;

	// Check which level it fits in to.
	for( i=0; i<StatOther.MaximumLevel; i++ )
	{
		if( !LevelIsFinished(StatOther,i) )
			return Clamp(i,StatOther.MinimumLevel,StatOther.MaximumLevel);
	}
	return StatOther.MaximumLevel;
}

// Return the number of different requirements this level has.
static function byte GetRequirementCount( ClientPerkRepLink StatOther, byte CurLevel )
{
	if( CurLevel==StatOther.MaximumLevel )
		return 0;
	return default.NumRequirements;
}

// Return 0-1 % of how much of the progress is done to gain this perk (for menu GUI).
static function float GetTotalProgress( ClientPerkRepLink StatOther, byte CurLevel )
{
	local byte i,rc,Minimum;
	local int R,V,NegReq;
	local float RV;

	if( CurLevel==StatOther.MaximumLevel )
		return 1.f;
	if( StatOther.bMinimalRequirements )
	{
		Minimum = 0;
		CurLevel = Max(CurLevel-StatOther.MinimumLevel,0);
	}
	else Minimum = StatOther.MinimumLevel;

	rc = GetRequirementCount(StatOther,CurLevel);
	for( i=0; i<rc; i++ )
	{
		V = GetPerkProgressInt(StatOther,R,CurLevel,i);
		R*=StatOther.RequirementScaling;
		if( CurLevel>Minimum )
		{
			GetPerkProgressInt(StatOther,NegReq,(CurLevel-1),i);
			NegReq*=StatOther.RequirementScaling;
			R-=NegReq;
			V-=NegReq;
		}
		if( R<=0 ) // Avoid division by zero error.
			RV+=1.f;
		else RV+=FClamp(float(V)/(float(R)),0.f,1.f);
	}
	return RV/float(rc);
}

// Return true if this level is earned.
static function bool LevelIsFinished( ClientPerkRepLink StatOther, byte CurLevel )
{
	local byte i,rc;
	local int R,V;

	if( CurLevel==StatOther.MaximumLevel )
		return false;
	if( StatOther.bMinimalRequirements )
		CurLevel = Max(CurLevel-StatOther.MinimumLevel,0);
	rc = GetRequirementCount(StatOther,CurLevel);
	for( i=0; i<rc; i++ )
	{
		V = GetPerkProgressInt(StatOther,R,CurLevel,i);
		R*=StatOther.RequirementScaling;
		if( R>V )
			return false;
	}
	return true;
}

// Return 0-1 % of how much of the progress is done to gain this individual task (for menu GUI).
static function float GetPerkProgress( ClientPerkRepLink StatOther, byte CurLevel, byte ReqNum, out int Numerator, out int Denominator )
{
	local byte Minimum;
	local int Reduced,Cur,Fin;

	if( CurLevel==StatOther.MaximumLevel )
	{
		Denominator = 1;
		Numerator = 1;
		return 1.f;
	}
	if( StatOther.bMinimalRequirements )
	{
		Minimum = 0;
		CurLevel = Max(CurLevel-StatOther.MinimumLevel,0);
	}
	else Minimum = StatOther.MinimumLevel;
	Numerator = GetPerkProgressInt(StatOther,Denominator,CurLevel,ReqNum);
	Denominator*=StatOther.RequirementScaling;
	if( CurLevel>Minimum )
	{
		GetPerkProgressInt(StatOther,Reduced,CurLevel-1,ReqNum);
		Reduced*=StatOther.RequirementScaling;
		Cur = Max(Numerator-Reduced,0);
		Fin = Max(Denominator-Reduced,0);
	}
	else
	{
		Cur = Numerator;
		Fin = Denominator;
	}
	if( Fin<=0 ) // Avoid division by zero.
		return 1.f;
	return FMin(float(Cur)/float(Fin),1.f);
}

// Return int progress for this perk level up.
static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	FinalInt = 1;
	return 1;
}

static final function int GetDoubleScaling( byte CurLevel, int InValue )
{
	CurLevel-=6;
	return CurLevel*CurLevel*InValue;
}

// Get display info text for menu GUI
static function string GetVetInfoText( byte Level, byte Type, optional byte RequirementNum )
{
	switch( Type )
	{
	case 0:
		return Default.LevelNames[Min(Level,ArrayCount(Default.LevelNames))]; // This was left in the void of unused...
	case 1:
		return GetCustomLevelInfo(Level);
	case 2:
		return Default.Requirements[RequirementNum];
	default:
		return Default.VeterancyName;
	}
}

static function string GetCustomLevelInfo( byte Level )
{
	return Default.CustomLevelInfo;
}

static final function string GetPercentStr( float InValue )
{
	return int(InValue*100.f)$"%";
}

// This function is called for every weapon with and every perk every time trader menu is shown.
// If returned false on any perk, weapon is hidden from the buyable list.
static function bool AllowWeaponInTrader( class<KFWeaponPickup> Pickup, KFPlayerReplicationInfo KFPRI, byte Level )
{
	/*if ( Pickup == class'StimulatorPickup' && ( default.PerkIndex != 0 || Level < 6 ) )
		return false;*/

	return true;
}

static function bool AllowWeaponInTraderVip(class<KFWeaponPickup> Pickup, KFPlayerReplicationInfo KFPRI)
{
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;

	SRPRI = SRPlayerReplicationInfo(KFPRI);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;

	if (Pickup == class'RadioBombPickup')
	{
		if (KFPRI.ClientVeteranSkill.default.PerkIndex == 6 ||
			KFPRI.ClientVeteranSkill.default.PerkIndex == 3) return true;
		else return false;
	}
	if (Pickup == class'FireBombPickup')
	{
		if (KFPRI.ClientVeteranSkill.default.PerkIndex == 5) return true;
		else return false;
	}
	if (Pickup == class'HK1911LLIPickup')
	{
		if (SRPRI != none)
		{
			if ( (SRPRI.HasSkinGroup("MAX")
			|| SRPRI.ClanTag~="[GodMode]") && !SRPRI.HasSkinGroup("LLIePLLIeHb") ) return true;
			else return false;
		}
	}
	if (Pickup == class'DeagleKPickup')
	{
		if (SRPRI != none)
		{
			if ( SRPRI.HasSkinGroup("DeagleMagadan") ) return true;
			else return false;
		}
	}
	if (Pickup == class'AlduinDTPickup')
	{
		if (SRPRI != none)
		{
			if ( SRPRI.HasSkinGroup("Dragon") ) return true;
			else return false;
		}
	}
	if (Pickup == class'SinglePickupM')
	{
		if (SRPRI != none)
		{
			if ( ( SRPRI.HasSkinGroup("MAX")
			|| SRPRI.ClanTag~="[GodMode]"
			|| SRPRI.HasSkinGroup("DeagleMagadan") ) && !SRPRI.HasSkinGroup("LLIePLLIeHb") ) return false;
			else return true;
		}
	}
	if (Pickup == class'KhukuriLLIPickup')
	{
		if ( SRPRI != none && SRPRI.bKukri ) return true;
		else return false;
	}
	if (Pickup == class'CrossLLIPickup')
	{
		if ( SRPRI.HasSkinGroup("Hellknife")) return true;
		else return false;
	}
	if (Pickup == class'SKLLIPickup')
	{
		if ( SRPRI.HasSkinGroup("GMKnife")) return true;
		else return false;
	}
	if (Pickup == class'AN94KnifeSAPickup')
	{
		if ( SRPRI.HasSkinGroup("ProrokKnife")) return true;
		else return false;
	}
	if (Pickup == class'KukriFLLIPickup')
	{
		if ( Mid(weapon, 4, 1) == "9" || SRPRI.HasSkinGroup("XASknife")) return true;
		else return false;
	}
	if (Pickup == class'TrackerKnifeLLIPickup')
	{
		if ( SRPRI != none && SRPRI.bHuezhik ) return true;
		else return false;
	}
	if (Pickup == class'VSSDTVipPickup')
	{
		if (Mid(weapon, 0, 1) == "V") return true;
		else return false;
	}
	if (Pickup == class'StingerPickup')
	{
		if (Mid(weapon, 7, 1) == "S" || Mid(weapon, 7, 1) == "C") return true;
		else return false;
	}
	if (Pickup == class'RPKPickup')
	{
		if (Mid(weapon, 7, 1) == "C") return true;
		else return false;
	}
	if (Pickup == class'HK23ESAPickup')
	{
		if (Mid(weapon, 7, 1) == "H") return true;
		else return false;
	}
	if (Pickup == class'SpitfirePickup' 
	|| Pickup == class'RavagerPickup'
	|| Pickup == class'StingerInfPickup'
	|| Pickup == class'HolyHandGrenadeMPickup'
	|| Pickup == class'TitanShotgunPickup'
	|| Pickup == class'MineFC4LLIPickup'
	|| Pickup == class'TitanRocketLauncherPickup'/*) && KFPRI.ClientVeteranSkill.default.PerkIndex == 11*/)
	{
		if (SRPRI.HasSkinGroup("Mortal") && KFPRI.ClientVeteranSkill.default.PerkIndex == 11) return true;
		else return false;
	}
	if (Pickup == class'M82A1LLINVPickup' || Pickup == class'AMJPickup')
	{
		if (SRPRI.HasSkinGroup("Axel") && KFPRI.ClientVeteranSkill.default.PerkIndex == 2) return true;
		else return false;
	}
	if (Pickup == class'M99STPickup')
	{
		if (SRPRI.HasSkinGroup("STALKER1") && KFPRI.ClientVeteranSkill.default.PerkIndex == 2) return true;
		else return false;
	}
	if (Pickup == class'M32PickupW')
	{
		if (SRPRI.HasSkinGroup("Wapik") && KFPRI.ClientVeteranSkill.default.PerkIndex == 0) return true;
		else return false;
	}
	if (Pickup == class'M99SBPickup')
	{
		if (SRPRI.HasSkinGroup("SKABLYA") && KFPRI.ClientVeteranSkill.default.PerkIndex == 4) return true;
		else return false;
	}
	if (Pickup == class'AwmDragonLLIPickup')
	{
		if (SRPRI.HasSkinGroup("Depressive") && KFPRI.ClientVeteranSkill.default.PerkIndex == 2) return true;
		else return false;
	}
	if (Pickup == class'M134DTPickup')
	{
		if (Mid(weapon, 7, 1) == "F" || Mid(weapon, 7, 1) == "W" || Mid(weapon, 7, 1) == "B") return false;
		else return true;
	}
	if (Pickup == class'M134DTRPickup')
	{
		if (Mid(weapon, 7, 1) == "F") return true;
		else return false;
	}
	if (Pickup == class'M134DTWPickup')
	{
		if (Mid(weapon, 7, 1) == "W" ||
		Mid(weapon, 7, 1) == "B") return true;
		else return false;
	}
	if (Pickup == class'ZEDGunLLIPickup')
	{
		if (Mid(weapon, 7, 1) == "Z") return true;
		else return false;
	}
	if (Pickup == class'M202A2Pickup' || Pickup == class'ATMinePickup' || Pickup == class'OpticalDeaglePickupF')
	{
		if (Mid(weapon, 6, 1) == "M" || Mid(weapon, 6, 1) == "R") return true;
		else return false;
	}
	if (Pickup == class'PipeBombPickupA')
	{
		if (Mid(weapon, 6, 1) == "A") return true;
		else return false;
	}
	if (Pickup == class'PipeBombPickup')
	{
		if (Mid(weapon, 6, 1) != "A") return true;
		else return false;
	}
	if (Pickup == class'RG6Pickup')
	{
		if (Mid(weapon, 6, 1) == "R") return true;
		else return false;
	}
	if (Pickup == class'RXRLDTPickup')
	{
		if (Mid(weapon, 6, 1) == "G") return true;
		else return false;
	}
	if (Pickup == class'WZic3LLIPickup')
	{
		if (SRPRI.HasSkinGroup("Zic3")) return true;
		else return false;
	}
	if (Pickup == class'WFieldCannonPickup')
	{
		if (Mid(weapon, 6, 1) == "H") return true;
		else return false;
	}
	if (Pickup == class'AN94SAPickup')
	{
		if (Mid(weapon, 6, 1) == "C") return true;
		else return false;
	}
	if (Pickup == class'FireDragonPickup')
	{
		if (Mid(weapon, 4, 1) == "A") return true;
		else return false;
	}
	if (Pickup == class'EbBulavaPickup')
	{
		if (Mid(weapon, 4, 1) == "E") return true;
		else return false;
	}
	if (Pickup == class'MurasamaDTPickup')
	{
		if (Mid(weapon, 4, 1) == "M") return true;
		else return false;
	}
	if (Pickup == class'L96AWPSILLLIPickup')
	{
		if (Mid(weapon, 0, 1) == "A") return true;
		else return false;
	}
	if (Pickup == class'M82A1LLIPickup')
	{
		if (Mid(weapon, 2, 1) == "3") return true;
		else return false;
	}
	if (Pickup == class'Saiga12SAPickup')
	{
		if (Mid(weapon, 8, 1) == "9" || Mid(weapon, 8, 1) == "I") return true;
		else return false;
	}
	if (Pickup == class'OC14Pickup')
	{
		if (Mid(weapon, 8, 1) == "I" 
		|| Mid(weapon, 8, 1) == "O" 
		|| Mid(weapon, 8, 1) == "9") return true;
		else return false;
	}
	if (Pickup == class'FN2000SPickup')
	{
		if (Mid(weapon, 8, 1) == "6") return true;
		else return false;
	}
	/*if (Pickup == class'LegendaryLLIPickup')
	{
		if (Mid(weapon, 1, 1) == "L") return true;
		else return false;
	}*/
	if (Pickup == class'ASVALSAPickup')
	{
		if (Mid(weapon, 8, 1) == "O" || Mid(weapon, 8, 1) == "9" || Mid(weapon, 8, 1) == "I") return true;
		else return false;
	}
	if (Pickup == class'AEK971Pickup')
	{
		if (Mid(weapon, 8, 1) == "A") return true;
		else return false;
	}
	if (Pickup == class'DualAY69SAPickup')
	{
		if (Mid(weapon, 8, 1) == "O" || Mid(weapon, 8, 1) == "9" || Mid(weapon, 8, 1) == "I") return true;
		else return false;
	}
	if (Pickup == class'VSSDTSPickup')
	{
		if (Mid(weapon, 8, 1) == "V") return true;
		else return false;
	}
	if (Pickup == class'VSSDTBPickup')
	{
		if (Mid(weapon, 2, 1) == "S") return true;
		else return false;
	}
	if (Pickup == class'L96AWPLLIPickup')
	{
		if (Mid(weapon, 0, 1) != "A") return true;
		else return false;
	}
	if (Pickup == class'MusketPickup')
	{
		if (Mid(weapon, 2, 1) == "M") return true;
		else return false;
	}
	if (Pickup == class'VSSKSAPickup')
	{
		if (Mid(weapon, 2, 1) == "V") return true;
		else return false;
	}
	if (Pickup == class'SIG550SRPickup' || Pickup == class'OpticalDeaglePickupW')
	{
		if (Mid(weapon, 2, 1) == "W") return true;
		else return false;
	}
	if (Pickup == class'AFS12Pickup')
	{
		if (Mid(weapon, 8, 1) != "9") return true;
		else return false;
	}
	if (Pickup == class'WColtFPickup')
	{
		if (Mid(weapon, 9, 1) == "M" || Mid(weapon, 9, 1) == "C") return true;
		else return false;
	}
	if (Pickup == class'BlasterPickup')
	{
		if (Mid(weapon, 9, 1) == "N") return true;
		else return false;
	}
	if (Pickup == class'PTRSLLIPickup')
	{
		if (Mid(weapon, 2, 1) == "P" || SRPRI.HasSkinGroup("Zic3")) return true;
		else return false;
	}
	if (Pickup == class'M200CSAPickup')
	{
		if ((Mid(weapon, 2, 1) == "G") && KFPRI.ClientVeteranSkill.default.PerkIndex == 2) return true;
		else return false;
	}
	if (Pickup == class'PatGunPickup')
	{
		if (Mid(weapon, 2, 1) == "P" || SRPRI.HasSkinGroup("Zic3")) return true;
		else return false;
	}
	if (Pickup == class'USAS12_V2Pickup')
	{
		if (Mid(weapon, 1, 1) == "U") return true;
		else return false;
	}
	if (Pickup == class'AvalancheSAPickup')
	{
		if (Mid(weapon, 1, 1) == "A") return true;
		else return false;
	}
	if (Pickup == class'SG556LLIPickup')
	{
		if (Mid(weapon, 9, 1) == "5") return true;
		else return false;
	}
	if (Pickup == class'CucumberLLIPickup')
	{
		if (Mid(weapon, 4, 1) == "K") return true;
		else return false;
	}
	if (Pickup == class'ClaymoreSwordPickupA')
	{
		if (Mid(weapon, 4, 1) == "3") return true;
		else return false;
	}
	if (Pickup == class'CSCrossbowPickup')
	{
		if (Mid(weapon, 9, 1) == "A" || Mid(weapon, 9, 1) == "S") return true;
		else return false;
	}
	if (Pickup == class'Jacalv2Pickup')
	{
		if (Mid(weapon, 9, 1) == "6") return true;
		else return false;
	}
	if (Pickup == class'M4A1SAPickup')
	{
		if (Mid(weapon, 3, 1) == "4") return true;
		else return false;
	}
	if (Pickup == class'AK12SAv2Pickup')
	{
		if (Mid(weapon, 3, 1) == "A" || Mid(weapon, 3, 1) == "4") return true;
		else return false;
	}
	if (Pickup == class'NinjatoInfPickup')
	{
		if (Mid(weapon, 10, 1) != "I" || Mid(weapon, 10, 1) != "A" || Mid(weapon, 10, 1) != "S") return true;
		else return false;
	}
	if (Pickup == class'M32PickupF')
	{
		if (Mid(weapon, 0, 1) == "F") return true;
		else return false;
	}
	if (Pickup == class'PDWPickup')
	{
		if (Mid(weapon, 3, 1) == "K" || Mid(weapon, 3, 1) == "5") return true;
		else return false;
	}
	if (Pickup == class'FNFALSAPickup')
	{
		if (Mid(weapon, 3, 1) == "P") return true;
		else return false;
	}
	if (Pickup == class'PKPDTCPickup' || Pickup == class'PKMCPickup')
	{
		if (Mid(weapon, 7, 1) == "C" && KFPRI.ClientVeteranSkill.default.PerkIndex == 7) return true;
		else return false;
	}
	if (Pickup == class'K3LMGPickup')
	{
		if (Mid(weapon, 7, 1) == "F" && KFPRI.ClientVeteranSkill.default.PerkIndex == 7) return true;
		else return false;
	}
	if (Pickup == class'McMillanSAPickup')
	{
		if ( Mid(weapon, 2, 1) == "K" && KFPRI.ClientVeteranSkill.default.PerkIndex == 2) return true;
		else return false;
	}
	if (Pickup == class'GalilComicSAPickup')
	{
		if (Mid(weapon, 3, 1) == "G" && KFPRI.ClientVeteranSkill.default.PerkIndex == 3) return true;
		else return false;
	}
	if (Pickup == class'P902DTPickup')
	{
		if (Mid(weapon, 8, 1) == "W" && KFPRI.ClientVeteranSkill.default.PerkIndex == 8) return true;
		else return false;
	}
	if (Pickup == class'AK47SPickupM')
	{
		if ((Mid(weapon, 8, 1) == "7") && KFPRI.ClientVeteranSkill.default.PerkIndex == 8) return true;
		else return false;
	}
	if (Pickup == class'AK47JPickupM')
	{
		if ((Mid(weapon, 7, 1) == "7") && KFPRI.ClientVeteranSkill.default.PerkIndex == 7) return true;
		else return false;
	}
	if (Pickup == class'JNG90SAPickup')
	{
		if ((Mid(weapon, 2, 1) == "5" ) && KFPRI.ClientVeteranSkill.default.PerkIndex == 2) return true;
		else return false;
	}
	if (Pickup == class'Barret_M98_BravoPickup' || Pickup == class'HK417APickup')
	{
		if ((Mid(weapon, 2, 1) == "4" ) && KFPRI.ClientVeteranSkill.default.PerkIndex == 2) return true;
		else return false;
	}
	if (Pickup == class'HK417Pickup')
	{
		if ((Mid(weapon, 2, 1) == "4" ) && KFPRI.ClientVeteranSkill.default.PerkIndex == 2) return false;
		else return true;
	}
	if (Pickup == class'ZEDGunMLLIPickup')
	{
		if ((Mid(weapon, 7, 1) == "4") && KFPRI.ClientVeteranSkill.default.PerkIndex == 7) return true;
		else return false;
	}
	if (Pickup == class'LaserGutlingPickup' || Pickup == class'LaserRCWPickup')
	{
		if ((SRPRI.HasSkinGroup("DeathCWeap") || SRPRI.HasSkinGroup("DeathWeap")) && KFPRI.ClientVeteranSkill.default.PerkIndex == 7) return true;
		else return false;
	}
	if (Pickup == class'AK12V3SAPickup')
	{
		if ((Mid(weapon, 10, 1) == "A") && KFPRI.ClientVeteranSkill.default.PerkIndex == 11) return true;
		else return false;
	}
	if (Pickup == class'VenomPickup' || Pickup == class'PyramidBladeLLIPickup')
	{
		if ((SRPRI.HasSkinGroup("Pirate")) && KFPRI.ClientVeteranSkill.default.PerkIndex == 11) return true;
		else return false;
	}
	if (Pickup == class'RFBSAPickup')
	{
		if ((Mid(weapon, 9, 1) == "7") && KFPRI.ClientVeteranSkill.default.PerkIndex == 9) return true;
		else return false;
	}
	if (Pickup == class'CrossbowBalistaPickup')
	{
		if (SRPRI.HasSkinGroup("Britva") && KFPRI.ClientVeteranSkill.default.PerkIndex == 4) return true;
		else return false;
	}
	if (Pickup == class'P416Pickup')
	{
		if (SRPRI.HasSkinGroup("Full") && KFPRI.ClientVeteranSkill.default.PerkIndex == 8) return true;
		else return false;
	}
	if (Pickup == class'GrenadePistolLLILPickup')
	{
		if (SRPRI.HasSkinGroup("XLocki")) return true;
		else return false;
	}
	if (Pickup == class'RNC44Pickup')
	{
		if (SRPRI.HasSkinGroup("Valdemar") && KFPRI.ClientVeteranSkill.default.PerkIndex == 3) return true;
		else return false;
	}
	if (Pickup == class'PurifierSwordPickup')
	{
		if (SRPRI.HasSkinGroup("Valdemar") && KFPRI.ClientVeteranSkill.default.PerkIndex == 4) return true;
		else return false;
	}
	if (Pickup == class'TXM8Pickup')
	{
		if (SRPRI.HasSkinGroup("Valdemar") && KFPRI.ClientVeteranSkill.default.PerkIndex == 5) return true;
		else return false;
	}
	if (Pickup == class'THR40DTPickup')
	{
		if (SRPRI.HasSkinGroup("Valdemar") && KFPRI.ClientVeteranSkill.default.PerkIndex == 7) return true;
		else return false;
	}
	if (Pickup == class'NewShotgunPickup')
	{
		if (SRPRI.HasSkinGroup("Vedl") && KFPRI.ClientVeteranSkill.default.PerkIndex == 1) return true;
		else return false;
	}
	if (Pickup == class'ACR10Pickup')
	{
		if (SRPRI.HasSkinGroup("Tliona") && KFPRI.ClientVeteranSkill.default.PerkIndex == 9) return true;
		else return false;
	}
	return true;
}
static function bool AllowWeaponInTrader10lvl(class<KFWeaponPickup> Pickup, KFPlayerReplicationInfo KFPRI, byte Level)
{
	if (Pickup == class'M99NewPickup')
	{
		if (KFPRI.ClientVeteranSkillLevel >= 10) return true;
		else return false;
	}
	if (Pickup == class'AW50LLIPickup')
	{
		if (KFPRI.ClientVeteranSkillLevel >= 10) return true;
		else return false;
	}
	return true;
}
static function bool AllowWeaponInTrader26lvl(class<KFWeaponPickup> Pickup, KFPlayerReplicationInfo KFPRI, byte Level)
{
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;

	SRPRI = SRPlayerReplicationInfo(KFPRI);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;

	if (Pickup == class'StimulatorPickup')
	{
		if (KFPRI.ClientVeteranSkill.default.PerkIndex == 0 && KFPRI.ClientVeteranSkillLevel >= 26 && Mid(weapon, 0, 1) != "1" && Mid(weapon, 0, 1) != "F") return true;
		else return false;
	}
	return true;
}
static function bool AllowWeaponInTraderGM(class<KFWeaponPickup> Pickup, KFPlayerReplicationInfo KFPRI, byte Level)
{
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;

	SRPRI = SRPlayerReplicationInfo(KFPRI);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;

	if (Pickup == class'FNC30Pickup')
	{
		if (SRPRI.HasSkinGroup("GMFNC") 
		&& (KFPRI.ClientVeteranSkill.default.PerkIndex == 0 
		|| KFPRI.ClientVeteranSkill.default.PerkIndex == 3 
		|| KFPRI.ClientVeteranSkill.default.PerkIndex == 7)) return true;
		else return false;
	}

	return true;
}
static function bool AllowWeaponInTraderEU(class<KFWeaponPickup> Pickup, KFPlayerReplicationInfo KFPRI, byte Level)
{
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;

	SRPRI = SRPlayerReplicationInfo(KFPRI);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;

	if (Pickup == class'ArmachamAssaultRiflePickup')
	{
		if (SRPRI.HasSkinGroup("EUWeapon") && KFPRI.ClientVeteranSkill.default.PerkIndex == 0) return true;
		else return false;
	}

	if (Pickup == class'EmpireSwordPickup')
	{
		if (SRPRI.HasSkinGroup("EUSword") && KFPRI.ClientVeteranSkill.default.PerkIndex == 4) return true;
		else return false;
	}
	
	return true;
}
static function bool AllowWeaponInTraderMAX(class<KFWeaponPickup> Pickup, KFPlayerReplicationInfo KFPRI, byte Level)
{
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;

	SRPRI = SRPlayerReplicationInfo(KFPRI);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;

	if (Pickup == class'TsuguriLLIPickup')
	{
		if (Mid(weapon, 4, 1) == "S") return true;
		else return false;
	}
	if (Pickup == class'WColtBPickup')
	{
		if (Mid(weapon, 9, 1) == "S") return true;
		else return false;
	}
	return true;
}
static function bool AllowWeaponInTraderElite(class<KFWeaponPickup> Pickup, KFPlayerReplicationInfo KFPRI, byte Level)
{
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;

	SRPRI = SRPlayerReplicationInfo(KFPRI);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	
	if (Pickup == class'RG6LLIPickup' || Pickup == class'StimulatorLLIPickup')
	{
		if ((Mid(weapon, 0, 1) == "1" || Mid(weapon, 0, 1) == "6" || Mid(weapon, 0, 1) == "F") && KFPRI.ClientVeteranSkill.default.PerkIndex == 0) return true;
		else return false;
	}
	if (Pickup == class'BinachiFA6DTPickup')
	{
		if ((Mid(weapon, 1, 1) == "A"
		|| Mid(weapon, 1, 1) == "1"
		|| Mid(weapon, 1, 1) == "U") && KFPRI.ClientVeteranSkill.default.PerkIndex == 1) return true;
		else return false;
	}
	if (Pickup == class'GaussSAPickup')
	{
		if ((Mid(weapon, 2, 1) == "1"
		|| Mid(weapon, 2, 1) == "2"
		|| Mid(weapon, 2, 1) == "S" ) && KFPRI.ClientVeteranSkill.default.PerkIndex == 2) return true;
		else return false;
	}
	if (Pickup == class'M4A1IronBeastSAPickup')
	{
		if ((Mid(weapon, 3, 1) == "4" 
		|| Mid(weapon, 3, 1) == "5"
		|| Mid(weapon, 3, 1) == "2"
		|| Mid(weapon, 3, 1) == "G") && KFPRI.ClientVeteranSkill.default.PerkIndex == 3) return true;
		else return false;
	}
	if (Pickup == class'InfernoLLIPickup')
	{
		if ((Mid(weapon, 4, 1) == "1" || Mid(weapon, 4, 1) == "A") && KFPRI.ClientVeteranSkill.default.PerkIndex == 4) return true;
		else return false;
	}
	if (Pickup == class'BazookaLLIPickup')
	{
		if ((Mid(weapon, 6, 1) == "1" 
		|| Mid(weapon, 6, 1) == "R" 
		|| Mid(weapon, 6, 1) == "M" 
		|| Mid(weapon, 6, 1) == "C") 
		&& KFPRI.ClientVeteranSkill.default.PerkIndex == 6) 
			return true;
		else 
			return false;
	}
	if (Pickup == class'XMV850Pickup')
	{
		if ((Mid(weapon, 7, 1) == "1" || Mid(weapon, 7, 1) == "C" || Mid(weapon, 7, 1) == "5" || Mid(weapon, 7, 1) == "W") && KFPRI.ClientVeteranSkill.default.PerkIndex == 7) return true;
		else return false;
	}
	if (Pickup == class'KrissSVSAPickup')
	{
		if ((Mid(weapon, 8, 1) == "O" ||
		Mid(weapon, 8, 1) == "9" ||
		Mid(weapon, 8, 1) == "W" ||
		Mid(weapon, 8, 1) == "1" ||
		Mid(weapon, 8, 1) == "A" ||
		Mid(weapon, 8, 1) == "6") && KFPRI.ClientVeteranSkill.default.PerkIndex == 8) return true;
		else return false;
	}
	if (Pickup == class'BornBeastSAPickup')
	{
		if (Mid(weapon, 9, 1) == "1"
		|| Mid(weapon, 9, 1) == "M"
		|| Mid(weapon, 9, 1) == "S"
		|| Mid(weapon, 9, 1) == "3"
		|| Mid(weapon, 9, 1) == "7"
		|| Mid(weapon, 9, 1) == "N") return true;
		else return false;
	}
	if (Pickup == class'JackalLLIPickup')
	{
		if ((Mid(weapon, 9, 1) == "2"
		|| Mid(weapon, 9, 1) == "S"
		|| Mid(weapon, 9, 1) == "M"
		|| Mid(weapon, 9, 1) == "3"
		|| Mid(weapon, 9, 1) == "6"
		|| Mid(weapon, 9, 1) == "N") && KFPRI.ClientVeteranSkill.default.PerkIndex == 9) return true;
		else return false;
	}
	if (Pickup == class'CrossbuzzsawKF2Pickup' || Pickup == class'KacChainsawSAPickup')
	{
		if (SRPRI.HasSkinGroup("EliteInf") && KFPRI.ClientVeteranSkill.default.PerkIndex == 11) return true;
		else return false;
	}
		
    if (Pickup == class'SC321APickup')
	{
		if (SRPRI.HasSkinGroup("SC321A") && KFPRI.ClientVeteranSkill.default.PerkIndex == 1) return true;
		else return false;
	}

	return true;
}

static function bool AllowWeaponInTraderDonate(class<KFWeaponPickup> Pickup, KFPlayerReplicationInfo KFPRI, byte Level)
{
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;

	SRPRI = SRPlayerReplicationInfo(KFPRI);
	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;

	if (Pickup == class'MedSentryGunPickup')
	{
		if ((Mid(weapon, 0, 1) == "M" || Mid(weapon, 0, 1) == "F" || Mid(weapon, 0, 1) == "W"
		|| Mid(weapon, 0, 1) == "1" || Mid(weapon, 0, 1) == "6") && KFPRI.ClientVeteranSkill.default.PerkIndex == 0 
		|| SRPRI.HasSkinGroup("Mortal") && KFPRI.ClientVeteranSkill.default.PerkIndex == 11) return true;
		else return false;
	}
	if (Pickup == class'AugA3SAPickup')
	{
		if ((Mid(weapon, 0, 1) == "M" || Mid(weapon, 0, 1) == "F" || Mid(weapon, 0, 1) == "W"
		|| Mid(weapon, 0, 1) == "1" || Mid(weapon, 0, 1) == "6") && KFPRI.ClientVeteranSkill.default.PerkIndex == 0) return true;
		else return false;
	}
	if (Pickup == class'SuperX3LLIPickup')
	{
		if ((Mid(weapon, 1, 1) == "X" 
		|| Mid(weapon, 1, 1) == "U" 
		|| Mid(weapon, 1, 1) == "A" 
		|| Mid(weapon, 1, 1) == "B" 
		|| Mid(weapon, 1, 1) == "1") && KFPRI.ClientVeteranSkill.default.PerkIndex == 1) return true;
		else return false;
	}
	if (Pickup == class'M200SAPickup')
	{
		if ((Mid(weapon, 2, 1) == "C" 
		|| Mid(weapon, 2, 1) == "B"
		|| Mid(weapon, 2, 1) == "2" ) && KFPRI.ClientVeteranSkill.default.PerkIndex == 2) return true;
		else return false;
	}
	if (Pickup == class'FFOWARLLIPickup')
	{
		if ((Mid(weapon, 3, 1) == "3" 
		|| Mid(weapon, 3, 1) == "4" 
		|| Mid(weapon, 3, 1) == "K" 
		|| Mid(weapon, 3, 1) == "S"
		|| Mid(weapon, 3, 1) == "2" 
		|| Mid(weapon, 3, 1) == "5"
		|| Mid(weapon, 3, 1) == "P") && KFPRI.ClientVeteranSkill.default.PerkIndex == 3) return true;
		else return false;
	}
	if (Pickup == class'AvengerLLIPickupM')
	{
		if ((Mid(weapon, 4, 1) == "F"
		|| Mid(weapon, 4, 1) == "M"
		|| Mid(weapon, 4, 1) == "V"
		|| Mid(weapon, 4, 1) == "1") && KFPRI.ClientVeteranSkill.default.PerkIndex == 4) return true;
		else return false;
	}
	if (Pickup == class'BulkCannonLLIPickup')
	{
		if ((Mid(weapon, 6, 1) == "B" ||
		Mid(weapon, 6, 1) == "M" ||
		Mid(weapon, 6, 1) == "R" ||
		Mid(weapon, 6, 1) == "A" ||
		Mid(weapon, 6, 1) == "G" ||
		Mid(weapon, 6, 1) == "C" ||
		Mid(weapon, 6, 1) == "1") && KFPRI.ClientVeteranSkill.default.PerkIndex == 6) return true;
		else return false;
	}
	if (Pickup == class'PKPDTPickup')
	{
		if ((Mid(weapon, 7, 1) == "K" ||
		Mid(weapon, 7, 1) == "X" ||
		Mid(weapon, 7, 1) == "S" ||
		Mid(weapon, 7, 1) == "F" ||
		Mid(weapon, 7, 1) == "V" ||
		Mid(weapon, 7, 1) == "P" ||
		Mid(weapon, 7, 1) == "B" ||
		Mid(weapon, 7, 1) == "1" ||
		Mid(weapon, 7, 1) == "W" ||
		Mid(weapon, 7, 1) == "4" ||
		Mid(weapon, 7, 1) == "3" ||
		Mid(weapon, 7, 1) == "5") && KFPRI.ClientVeteranSkill.default.PerkIndex == 7) return true;
		else return false;
	}
	if (Pickup == class'HKG36CSAPickup')
	{
		if ((Mid(weapon, 8, 1) == "G" ||
		Mid(weapon, 8, 1) == "O" ||
		Mid(weapon, 8, 1) == "9" ||
		Mid(weapon, 8, 1) == "I" ||
		Mid(weapon, 8, 1) == "V" ||
		Mid(weapon, 8, 1) == "W" ||
		Mid(weapon, 8, 1) == "1" ||
		Mid(weapon, 8, 1) == "A") && KFPRI.ClientVeteranSkill.default.PerkIndex == 8) return true;
		else return false;
	}
	if (Pickup == class'SKSPickup')
	{
		if ((Mid(weapon, 9, 1) == "Z"
		|| Mid(weapon, 9, 1) == "5"
		|| Mid(weapon, 9, 1) == "S"
		|| Mid(weapon, 9, 1) == "M"
		|| Mid(weapon, 9, 1) == "A"
		|| Mid(weapon, 9, 1) == "B"
		|| Mid(weapon, 9, 1) == "1"
		|| Mid(weapon, 9, 1) == "2"
		|| Mid(weapon, 9, 1) == "6"
		|| Mid(weapon, 9, 1) == "7"
		|| Mid(weapon, 9, 1) == "3"
		|| Mid(weapon, 9, 1) == "N") && KFPRI.ClientVeteranSkill.default.PerkIndex == 9) return true;
		else return false;
	}
	if (Pickup == class'GreatswordLLIInfPickup')
	{
		if ((Mid(weapon, 10, 1) == "I" || Mid(weapon, 10, 1) == "S" || Mid(weapon, 10, 1) == "A" || Mid(weapon, 10, 1) == "X") && KFPRI.ClientVeteranSkill.default.PerkIndex == 11) return true;
		else return false;
	}
	if (Pickup == class'RemingtonACRSAPickup')
	{
		if ((Mid(weapon, 10, 1) == "I" || Mid(weapon, 10, 1) == "S" || Mid(weapon, 10, 1) == "A" || Mid(weapon, 10, 1) == "X") && KFPRI.ClientVeteranSkill.default.PerkIndex == 11) return true;
		else return false;
	}
	return true;
}

static function bool AllowWeaponInTrader31lvl(class<KFWeaponPickup> Pickup, KFPlayerReplicationInfo KFPRI, byte Level)
{
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;
	SRPRI = SRPlayerReplicationInfo(KFPRI);

	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;

	if (Pickup == class'KrissMSRPickup')
	{
		if (KFPRI.ClientVeteranSkill.default.PerkIndex == 0 && ( KFPRI.ClientVeteranSkillLevel >= 31 || SRPRI.HasSkinGroup("Demka") || SRPRI.HasSkinGroup("DeathWeap") ) ) return true;
		else return false;
	}
	if (Pickup == class'JackhammerPickup')
	{
		if (KFPRI.ClientVeteranSkill.default.PerkIndex == 1 && ( KFPRI.ClientVeteranSkillLevel >= 31 || SRPRI.HasSkinGroup("Demka") || SRPRI.HasSkinGroup("DeathWeap") ) ) return true;
		else return false;
	}
	if (Pickup == class'AK12LLIPickup')
	{
		if (KFPRI.ClientVeteranSkill.default.PerkIndex == 3 && ( KFPRI.ClientVeteranSkillLevel >= 31 || SRPRI.HasSkinGroup("Demka") || SRPRI.HasSkinGroup("DeathWeap") ) ) return true;
		else return false;
	}
	if (Pickup == class'B94Pickup')
	{
		if (KFPRI.ClientVeteranSkill.default.PerkIndex == 2 && ( KFPRI.ClientVeteranSkillLevel >= 31 || SRPRI.HasSkinGroup("Demka") || SRPRI.HasSkinGroup("DeathWeap") ) ) return true;
		else return false;
	}
	if (Pickup == class'NinjatoPickup')
	{
		if (KFPRI.ClientVeteranSkill.default.PerkIndex == 4 && ( KFPRI.ClientVeteranSkillLevel >= 31 || SRPRI.HasSkinGroup("Demka") || SRPRI.HasSkinGroup("DJRIP")  )) return true;
		else return false;
	}
	if (Pickup == class'M202A1Pickup')
	{
		if (KFPRI.ClientVeteranSkill.default.PerkIndex == 5 && ( KFPRI.ClientVeteranSkillLevel >= 31 || SRPRI.HasSkinGroup("Demka") || SRPRI.HasSkinGroup("DeathWeap") )) return true;
		else return false;
	}
	if (Pickup == class'SeekerSixMPickup')
	{
		if (KFPRI.ClientVeteranSkill.default.PerkIndex == 6 && ( KFPRI.ClientVeteranSkillLevel >= 31 || SRPRI.HasSkinGroup("Demka") || SRPRI.HasSkinGroup("DeathWeap") || SRPRI.HasSkinGroup("DJRIP") )) return true;
		else return false;
	}
	if (Pickup == class'M60Pickup')
	{
		if (KFPRI.ClientVeteranSkill.default.PerkIndex == 7 && ( KFPRI.ClientVeteranSkillLevel >= 31 || SRPRI.HasSkinGroup("Demka") ) ) return true;
		else return false;
	}
	if (Pickup == class'VALDTPickup')
	{
		if (KFPRI.ClientVeteranSkill.default.PerkIndex == 8 && ( KFPRI.ClientVeteranSkillLevel >= 31 || SRPRI.HasSkinGroup("Demka") || SRPRI.HasSkinGroup("DeathWeap") ) ) return true;
		else return false;
	}
	if (Pickup == class'G43LLIPickup')
	{
		if (KFPRI.ClientVeteranSkill.default.PerkIndex == 9 && ( KFPRI.ClientVeteranSkillLevel >= 31 || SRPRI.HasSkinGroup("Demka") || SRPRI.HasSkinGroup("DeathWeap") )) return true;
		else return false;
	}
	if (Pickup == class'VSSDTPickup')
	{
		if (KFPRI.ClientVeteranSkill.default.PerkIndex == 11 && ( KFPRI.ClientVeteranSkillLevel >= 31 || SRPRI.HasSkinGroup("Demka") )) return true;
		else return false;
	}
	return true;
}

static function byte PreDrawPerk( Canvas C, byte Level, out Material PerkIcon, out Material StarIcon )
{
	if ( Level == 41 )
	{
		PerkIcon = Default.IconMat10;
		StarIcon = none;
		Level = 0;
		C.SetDrawColor(255, 255, 255, C.DrawColor.A); // Элита
	}
	else if ( Level == 40 )
	{
		PerkIcon = Default.IconMat9;
		StarIcon = Default.StarMat8;
		Level = 0;
		C.SetDrawColor(255, 255, 255, C.DrawColor.A); // Мастер
	}
	else if ( Level > 35 )
	{
		PerkIcon = Default.IconMat8;
		StarIcon = Default.StarMat8;
		Level-=35;
		C.SetDrawColor(255, 255, 255, C.DrawColor.A); // Золотой
	}
	else if ( Level>30 )
	{
		PerkIcon = Default.IconMat7;
		StarIcon = Default.StarMat7;
		Level-=30;
		C.SetDrawColor(255, 255, 255, C.DrawColor.A); // Черный
	}
	else if ( Level>25 )
	{
		PerkIcon = Default.IconMat6;
		StarIcon = Default.StarMat6;
		Level-=25;
		C.SetDrawColor(255, 255, 255, C.DrawColor.A); // Серебрянный
	}
	else if ( Level>20 )
	{
		PerkIcon = Default.IconMat5;
		StarIcon = Default.StarMat5;
		Level-=20;
		C.SetDrawColor(255, 255, 255, C.DrawColor.A); // Красный
	}
	else if ( Level>15 )
	{
		PerkIcon = Default.IconMat4;
		StarIcon = Default.StarMat4;
		Level-=15;
		C.SetDrawColor(255, 255, 255, C.DrawColor.A); // Фиолетовый
	}
	else if ( Level>10 )
	{
		PerkIcon = Default.IconMat3;
		StarIcon = Default.StarMat3;
		Level-=10;
		C.SetDrawColor(255, 255, 255, C.DrawColor.A); // Синий
	}
	else if ( Level>5 )
	{
		PerkIcon = Default.IconMat2;
		StarIcon = Default.StarMat2;
		Level-=5;
		C.SetDrawColor(255, 255, 255, C.DrawColor.A); // Бирюзовый/Оранжевый
	}
	else
	{
		PerkIcon = Default.IconMat1;
		StarIcon = Default.StarMat1;
		C.SetDrawColor(255, 255, 255, C.DrawColor.A); // Зеленый
	}
	return Min(Level,41);
}

// Стандартные значения

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	local float ret;
	
	ret = 1.0;
	
	ret *= SRPlayerReplicationInfo(KFPRI).DamageMod;

	return ret * float(InDamage) * 1.00;
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{	
	//local string weapon;
	//local SRPlayerReplicationInfo SRPRI;
	
	//Log("ReduceDamage.0"@Instigator@DmgType@KFHumanPawn(Instigator)@SRPRI.HasSkinGroup("DemkaPPP"));
	/*if( KFHumanPawn(Instigator)!=none && SRPRI.HasSkinGroup("DemkaPPP") )
		return 0;
	Log("ReduceDamage.1");*/

		//SRPRI = SRPlayerReplicationInfo(Injured.PlayerReplicationInfo);
		//weapon = (SRPlayerReplicationInfo(Instigator.PlayerReplicationInfo)).Weapon;

		if ( DmgType == class'DamTypeMG' )
			return 0.25 * float(InDamage);
			
		if ( DmgType == class'DamTypeNailGunNew'
		|| DmgType == class'DamTypeLAWFlame'
		|| DmgType == class'DamTypeM202A2')
			return 0.2;

		/*if ( class<SRFireDamageType>(DmgType) != none )
			return 0.2;*/

		if ( DmgType == class'DamTypeClaymore' )
			return 0.25 * float(InDamage);
				
		if ( DmgType == class'DamTypeRPG' || 
			DmgType == class'DamTypeLAW' || 
			DmgType == class'DamTypeM202A2' || 
			DmgType == class'DamTypeEX41' || 
			DmgType == class'DamTypeSeekerSixMRocket' )
			return 0.4 * float(InDamage);

		if ( DmgType == class'DamTypeFireField' 
		|| DmgType == class'DamTypeHeadshotFrag' 
		|| DmgType == class'DamTypeHeadshotFragGF' 
		|| DmgType == class'DamTypeFireFieldM' 
		|| DmgType == class'DamTypeStun' 
		|| DmgType == class'DamTypeReaper'
		|| DmgType == class'DamTypeCrossbuzzsawKF2'
		|| DmgType == class'DamTypeCrossbuzzsawKF2Alt'
		|| DmgType == class'DamTypeBulkCannonLLI'
		|| DmgType == class'DamTypeAN94SA'
		|| DmgType == class'DamTypeM99ST'
		|| DmgType == class'DamTypeJNG90SA'
		|| DmgType == class'DamTypeGaussSAAlt'
		|| DmgType == class'DamTypeM82A1LLINV'
		|| DmgType == class'DamTypeAMJ'
		|| DmgType == class'DamTypeAwmDragonLLI'
		|| DmgType == class'DamTypeKacChainsawSA'
		|| DmgType == class'DamTypeBarret_M98_Bravo'
		|| DmgType == class'DamTypeGaussSA'
		|| DmgType == class'DamTypeHK417A'
		|| DmgType == class'DamTypeM82A1LLIAlt'
		|| DmgType == class'DamTypeM82A1LLI'
		|| DmgType == class'DamTypeHHGrenM'
		|| DmgType == class'DamTypeHKG36CSAAssaultRifle'
		|| DmgType == class'DamTypeCrossbowBalista'
		|| DmgType == class'DamTypeM99SB'
		|| DmgType == class'DamTypeP416'
		|| DmgType == class'DamTypeAEK971'
		|| DmgType == class'DamTypeKrissSVSA'
		|| DmgType == class'DamTypeAK47S'
		|| DmgType == class'DamTypeVSSDTS'
		|| DmgType == class'DamTypeVereskSA'
		|| DmgType == class'DamTypeM200SA'
		|| DmgType == class'DamTypeMcMillanSA'
		|| DmgType == class'DamTypeM200SAAlt'
		|| DmgType == class'DamTypeVSSKSAAlt'
		|| DmgType == class'DamTypeVSSKSA'
		|| DmgType == class'DamTypeSIG550SRAlt'
		|| DmgType == class'DamTypeSIG550SR'
		|| DmgType == class'DamTypeK3LMGAssaultRifle'
		|| DmgType == class'DamTypeSC321A'
		|| DmgType == class'DamTypeSuperX3LLI' 
		|| DmgType == class'DamTypeAvalancheSAShotgun'
		|| DmgType == class'DamTypePKPDT'
		|| DmgType == class'DamTypeLaserRCW'
		|| DmgType == class'DamTypePKMC'
		|| DmgType == class'DamTypePKPDTC'
		|| DmgType == class'DamTypeZEDGunLLI'
		|| DmgType == class'DamTypeFrostSword'
		|| DmgType == class'DamTypeFrostSwordAltAttack'
		|| DmgType == class'DamTypeAvengerLLI'
		|| DmgType == class'DamTypeMurasamaDT'
		|| DmgType == class'DamTypeInfernoLLI'
		|| DmgType == class'DamTypeInfernoLLIAlt'
		|| DmgType == class'DamTypeTsuguriLLI'
		|| DmgType == class'DamTypeTsuguriLLIAlt'
		|| DmgType == class'DamTypeAvengerLLIAltAttack'
		|| DmgType == class'DamTypeSoundBomb'
		|| DmgType == class'DamTypePipeBombA'
		|| DmgType == class'DamTypeSKS'
		|| DmgType == class'DamTypeRFBSA'
		|| DmgType == class'DamTypeJackalLLI'
		|| DmgType == class'DamTypeJacalv2'
		|| DmgType == class'DamTypeBornBeastSA'
		|| DmgType == class'DamTypeCSCrossbowAlt'
		|| DmgType == class'DamTypeFNFALSA'
		|| DmgType == class'DamTypeCSCrossbow'
		|| DmgType == class'DamTypeFFOWARLLI'
		|| DmgType == class'DamTypeM4A1IronBeastSA'
		|| DmgType == class'DamTypeRNC44AssaultRifle'
		|| DmgType == class'DamTypeNewShotgun'
		|| DmgType == class'DamTypeAK12SAv2'
		|| DmgType == class'DamTypePDWAssaultRifle'
		|| DmgType == class'DamTypeAK47J'
		|| DmgType == class'DamTypeM4A1SAAssaultRifle'
		|| DmgType == class'DamTypeXMV850'
		|| DmgType == class'DamTypeTHR40DT'
		|| DmgType == class'DamTypeLaserGutling'
		|| DmgType == class'DamTypePurifierSword'
		|| DmgType == class'DamTypePurifierSwordAlt'
		|| DmgType == class'DamTypeZEDGunMLLI'
		|| DmgType == class'DamTypeStinger'
		|| DmgType == class'DamTypeHK23ESA'
		|| DmgType == class'DamTypeRG6Grenade'
		|| DmgType == class'DamTypeATMine'
		|| DmgType == class'DamTypeEbBulava'
		|| DmgType == class'DamTypeAugA3SA'
		|| DmgType == class'DamTypeGreatswordLLIHeadCut'
		|| DmgType == class'DamTypeGreatswordLLICritical'
		|| DmgType == class'DamTypeGreatswordLLIAltAttack'
		|| DmgType == class'DamTypeGreatswordLLI'
		|| DmgType == class'DamTypeDualAY69SA'
		|| DmgType == class'DamTypeGalilComicSA'
		|| DmgType == class'DamTypeRXRLDTRocket'
		|| DmgType == class'DamTypeRXRLDTRocketImpact'
		|| DmgType == class'DamTypeRemingtonACRSA'
		|| DmgType == class'DamTypeStingerInf'
		|| DmgType == class'DamTypeTitanShotgun'
		|| DmgType == class'DamTypeTitanShotgun'
		|| DmgType == class'TitanRocketLauncherPickup'
		|| DmgType == class'DamTypeVenom'
		|| DmgType == class'DamTypeHHGrenM'
		|| DmgType == class'DamTypeRemingtonACRSAabc'
		|| DmgType == class'DamTypeAK12v3SA'
		|| DmgType == class'DamTypeCucumberLLI'
		|| DmgType == class'DamTypeUSAS12_V2'
		|| DmgType == class'DamTypeM134DTR'
		|| DmgType == class'DamTypeMusket'
		|| DmgType == class'DamTypeUHHGren'
		|| DmgType == class'DamTypeHHGren'
		|| DmgType == class'DamTypeRPK'
		|| DmgType == class'DamTypeP902DT'
		|| DmgType == class'DamTypeWColtF'
		|| DmgType == class'DamTypeMusketAlt'
		|| DmgType == class'DamTypeM200CSA'
		|| DmgType == class'DamTypeM200SAAlt'
		|| DmgType == class'DamTypeVSSDTBAlt'
		/*|| DmgType == class'DamTypeZic3LLI'
		|| DmgType == class'DamTypeZic3LLIAP'
		|| DmgType == class'DamTypeZic3LLIBS'*/
		|| DmgType == class'DamTypeVSSDTB'
		|| DmgType == class'DamTypeGunfighterCriticalStrike'
		|| DmgType == class'DamTypeOpticalDeagleW'
		|| DmgType == class'DamTypeBinachiFA6DT'
		|| DmgType == class'DamTypePG'
		|| DmgType == class'DamTypeFN2000S'
		|| class<DamTypeTurretExplosion>(DmgType) != none
		|| class<DamTypeRavager>(DmgType) != none
		|| class<DamTypePyramidBladeLLI>(DmgType) != none
		|| DmgType == class'DamTypeSealSquealMExplosion'
		|| DmgType == class'DamTypeToz34'
		|| DmgType == class'DamTypeDBSR'
		|| DmgType == class'DamTypeBazookaLLI'
		|| DmgType == class'DamTypeBazookaLLIImpact'
		|| DmgType == class'DamTypePTRSLLI'		)
			return 0;

	return InDamage;
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float ret;
	
	ret = 1.0;
	
	ret *= SRPlayerReplicationInfo(KFPRI).ReloadMod;
	
	return ret;
}

static function float GetFireSpeedMod(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
	local float ret;
	
	ret = 1.0;
	
	ret *= SRPlayerReplicationInfo(KFPRI).FireRateMod;
	
	return ret;
}

static function float GetMeleeMovementSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
	local float ret;
	
	ret = 0.10;

	if ( KFPRI.ClientVeteranSkillLevel > 15 )
	{
		ret -= 0.03;
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 35 )
	{
		ret -= 0.03;
	}
	
	return ret;
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'SnitchNade';
}

static function class<DamageType> GetMAC10DamageType(KFPlayerReplicationInfo KFPRI)
{
	return class'DamTypeMAC10MPSMG';
}

static function float GetDefaultCostScaling(int x)
{
	local float ret;
	
	ret = FMin(0.40,0.40 - 0.01 * (x / 2)); // до 80% скидки на последнем уровне
	
	return ret;
}

static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	local int MinNum;
	local SRPlayerReplicationInfo SRPRI;
	local int PerkIndex;
	local string weapon;

	weapon = (SRPlayerReplicationInfo(KFPRI)).Weapon;
	SRPRI = SRPlayerReplicationInfo(KFPRI);
	
	if(KFPRI != none)
		PerkIndex=KFPRI.ClientVeteranSkill.default.PerkIndex;
	else PerkIndex = -1;
	
	if ( !SRPRI.bRespawned )
	{
		MinNum = 2000;
		if ( KFPRI.ClientVeteranSkillLevel > 5 )
			MinNum = MinNum - 200 * ((KFPRI.ClientVeteranSkillLevel-1)/5);
		KFPRI.Score = Max(MinNum,KFPRI.Score);
	}
	if ( SRPRI.Respawns <= 0 ) SRPRI.Score += SRPRI.StartMoney;
	else SRPRI.Score += SRPRI.WaveMoney;
	
	if(PerkIndex == 11)
	{
		SRPRI.DecapCount = DecapCountPerWave(SRPRI)*0.35;//35%
		SRPRI.InvisCount = InvisibilityLimit(SRPRI)*0.35;//35%
	}
	//SRPRI.DecapCount = DecapCountPerWave(SRPRI);
	if ( SRPRI != none && SRPRI.bKukri )
	{
		RemoveInventory(P,class'Knife');
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.KhukuriLLI", GetCostScaling(KFPRI, class'KhukuriLLIPickup'));
	}
	if ( SRPRI != none && SRPRI.HasSkinGroup("Dragon") )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AlduinDTGun", GetCostScaling(KFPRI, class'AlduinDTPickup'));
	}
	if ( Mid(weapon, 7, 1) == "3" 
	||  Mid(weapon, 7, 1) == "5" 
	||  Mid(weapon, 7, 1) == "4" 
	||  Mid(weapon, 7, 1) == "7" 
	|| SRPRI.HasSkinGroup("Funtik") 
	|| SRPRI.HasSkinGroup("Wapik") )
	{
		RemoveInventory(P,class'WelderEx');
		KFHumanPawn(P).CreateInventoryVeterancy("Masters.WelderExP", GetCostScaling(KFPRI, class'WelderExPPickup'));
	}
	if ( SRPRI.HasSkinGroup("Hellknife") )
	{
		RemoveInventory(P,class'Knife');
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.CrossLLI", GetCostScaling(KFPRI, class'CrossLLIPickup'));
	}
	if ( SRPRI.HasSkinGroup("GMKnife") )
	{
		RemoveInventory(P,class'Knife');
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.SKLLI", GetCostScaling(KFPRI, class'SKLLIPickup'));
	}
	if ( SRPRI.HasSkinGroup("ProrokKnife") )
	{
		RemoveInventory(P,class'Knife');
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AN94KnifeSA", GetCostScaling(KFPRI, class'AN94KnifeSAPickup'));
	}
	if ( Mid(weapon, 4, 1) == "9" || SRPRI.HasSkinGroup("XASknife") )
	{
		RemoveInventory(P,class'Knife');
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.KukriFLLI", GetCostScaling(KFPRI, class'KukriFLLIPickup'));
	}
	if ( SRPRI != none && SRPRI.bHuezhik )
	{
		RemoveInventory(P,class'Knife');
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.TrackerKnifeLLI", GetCostScaling(KFPRI, class'TrackerKnifeLLIPickup'));
	}
	if ( SRPRI != none && SRPRI.bBat )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("Mswp.AluminumBat", GetCostScaling(KFPRI, class'AluminumBatPickup'));
	}
	SRPRI.Respawns++;
}

static function RemoveInventory(Pawn P, class<Inventory> InvClass)
{
	local Inventory I;
	
	for(I=P.Inventory; I!=none; I=I.Inventory)
	{
		if ( I.Class == InvClass )
		{
			if ( Weapon(I) == P.Weapon )
				I.DetachFromPawn(P);
			P.DeleteInventory(I);
			break;
		}
	}
}

// Переписано с функции GiveNades написанной Poosh, под добавление патронов к любому оружию
static function GiveAmmo(KFHumanPawn P, int Amount, class<KFWeapon> WeapClass)
{
    local inventory inv;
    local KFWeapon KFW;

    for ( inv = P.inventory; inv != none ; inv = inv.Inventory )
	{
        KFW = KFWeapon(inv);
		if ( KFW != none && KFW.Class == WeapClass )
		{
			KFW.ConsumeAmmo(0, -Amount);
			break;
		}
	}
}

// Бонусы рангов

static function class<DamageType> GetFNC30DamageType(KFPlayerReplicationInfo KFPRI)
{
	return class'DamTypeFNC30Medic';
}
static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	local float ret;
	
	ret = 1.0;
	
	if ( FN2000MgAmmo(Other) != none 
	|| HGrenadeMAmmo(Other) != none 
	|| MineFC4LLIAmmo(Other) != none 
	|| Armacham203Ammo(Other) != none 
	|| FNC30M203Ammo(Other) != none )
	{
			ret = 0.0;
	}

	if ( Frag1Ammo(Other) != none )
	{
		return 0.4;
	}

	if ( KFPRI.ClientVeteranSkillLevel > 5 )
	{
		ret += 0.10;
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 15 )
	{
		ret += 0.05;
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 25 )
	{
		ret += 0.05;
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 35 )
	{
		ret += 0.05;
	}
	
	ret *= 3.0;
	
	return ret;
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float ret;
	
	ret = 1.0;
	
	if ( AmmoType == class'GrenadePistolLLILAmmo'
		|| AmmoType == class'FNC30M203Ammo'
		|| AmmoType == class'Armacham203Ammo' ) return ret;
	
	if ( KFPRI.ClientVeteranSkillLevel > 5 )
	{
		ret += 0.10;
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 15 )
	{
		ret += 0.05;
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 25 )
	{
		ret += 0.05;
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 35 )
	{
		ret += 0.05;
	}
	
	if ( AmmoType == class'WelderAmmo' ||
		AmmoType == class'M99NewAmmo' ||
		AmmoType == class'AW50LLIAmmo' ||
		AmmoType == class'B94Ammo' ||
		AmmoType == class'PTRSLLIAmmo' ||
		AmmoType == class'M200SAAmmo' ||
		AmmoType == class'McMillanSAAmmo')
	{
		ret = 1.00;
	}
	
	return ret;
}

static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	local int ret;
	
	ret = 15;
	
	if ( default.PerkIndex == 1 || default.PerkIndex == 6 || default.PerkIndex == 7 /*|| default.PerkIndex == 10*/ ) // если это поддержка, подрывник, 
															  // джаггернаут, - оставляем стандартные 15 веса, прибавка будет рассчитана как надо, в самом перке
	{
		return ret - 1;
	}
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

static function float GetMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
	local float ret;
	
	ret = 1.00;
	
	if ( KFPRI.ClientVeteranSkillLevel > 15 )
	{
		ret += 0.05;
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 35 )
	{
		ret += 0.05;
	}
	
	return ret;
}

static function float GetSyringeChargeRate(KFPlayerReplicationInfo KFPRI)
{
	local float ret;
	
	ret = 1.00;
	
	if ( KFPRI.ClientVeteranSkillLevel > 20 )
	{
		ret += 0.40;
	}
	
	if ( KFPRI.ClientVeteranSkillLevel > 30 )
	{
		ret += 0.25;
	}
	
	return ret;
}

static function SpecialHUDInfo(KFPlayerReplicationInfo KFPRI, Canvas C)
{
	local KFMonster KFEnemy;
	local SRHUDKillingFloor SRHKF;
	local float MaxDistance;
	local HardPat Clamely;
	
	if ( KFPRI.ClientVeteranSkill != class'SRVetCommando' && KFPRI.ClientVeteranSkill != class'SRVetCommandoHZD' && KFPRI.ClientVeteranSkillLevel <= 30 )
		return;

	if ( true )
	{
		SRHKF = SRHUDKillingFloor(C.ViewPort.Actor.myHUD);
		if ( SRHKF == none || Pawn(C.ViewPort.Actor.ViewTarget)==none || Pawn(C.ViewPort.Actor.ViewTarget).Health<=0 )
			return;

		if ( KFPRI.ClientVeteranSkill == class'SRVetCommando' || KFPRI.ClientVeteranSkill == class'SRVetCommandoHZD' )
		{
			MaxDistance = 600 + 200 * ( (KFPRI.ClientVeteranSkillLevel-1)/5 ); // 12 + 4
		}
		else
		{
			if ( KFPRI.ClientVeteranSkillLevel > 35 )
				MaxDistance = 1200; // 24 metres
			else
				MaxDistance = 800; // 16 metres 
		}

		foreach C.ViewPort.Actor.VisibleCollidingActors(class'KFMonster',KFEnemy,MaxDistance,C.ViewPort.Actor.CalcViewLocation)
		{
			if ( KFEnemy.Health > 0 )
			{
				if ((KFPRI.ClientVeteranSkill != class'SRVetCommando' && KFPRI.ClientVeteranSkill != class'SRVetCommandoHZD')
				&& (KFEnemy.IsA('DKPoisoner') || KFEnemy.IsA('DKStalker') || KFEnemy.IsA('ZombieStalker_XMasSR')
				|| KFEnemy.IsA('HardPat')
				|| KFEnemy.IsA('HardPatHZD')))
				continue;

				SRHKF.StartDrawingBars();
				if ( KFPRI.ClientVeteranSkill != class'SRVetCommando' && KFPRI.ClientVeteranSkill != class'SRVetCommandoHZD' ||
					KFPRI.ClientVeteranSkill == class'SRVetCommando' && !KFEnemy.IsA('HardPat') && !KFEnemy.IsA('HardPatHZD') ||
					KFPRI.ClientVeteranSkill == class'SRVetCommandoHZD' && !KFEnemy.IsA('HardPat') && !KFEnemy.IsA('HardPatHZD') )
				{
				SRHKF.DrawBars(C, KFEnemy, 50.0, "health");
				SRHKF.DrawBars(C, KFEnemy, 50.0, "armor");
				}
			}
		}
		
		if ( KFPRI.ClientVeteranSkill != class'SRVetCommando' && KFPRI.ClientVeteranSkill != class'SRVetCommandoHZD' )
		{
			return;
		}
		
		/*foreach C.ViewPort.Actor.VisibleCollidingActors(class'HardPat',Clamely,MaxDistance*2,C.ViewPort.Actor.CalcViewLocation)
		{
			if ( Clamely.Health > 0 && KFPRI.ClientVeteranSkill == class'SRVetCommando' )
			{
				SRHKF.StartDrawingBars();
				SRHKF.DrawBars(C, Clamely, 50.0, "health");
				SRHKF.DrawBars(C, Clamely, 50.0, "armor");
			}
		}*/
	}
}

// Новые функции, сделано Dr. Killjoy aka Steklo

static function float ArythmProgression(int CurLevel, array<float> StartReq, array<float> WholeReq)
{
	local int i,n,nmax;
	local float Progress,ReqAddit,CurrentAddit;
	
	Progress = 0.0;
	
	nmax = 6;
	n = Min(CurLevel,nmax);
	CurrentAddit = StartReq[0];
	ReqAddit = ( WholeReq[0] / float(nmax)*2.0 - 2.0*CurrentAddit ) / float(nmax - 1);
	
	for(i=0; i<n; i++)
	{
		Progress += CurrentAddit;
		CurrentAddit += ReqAddit;
	}
	
	if ( CurLevel < 7 )
	{
		Goto Completion;
	}
	
	nmax = 24;
	n = Min(CurLevel-6,nmax);
	CurrentAddit = StartReq[1];
	ReqAddit = ( WholeReq[1] / float(nmax)*2.0 - 2.0*CurrentAddit ) / float(nmax - 1);
	
	for(i=0; i<n; i++)
	{
		Progress += CurrentAddit;
		CurrentAddit += ReqAddit;
	}
	
	if ( CurLevel < 31 )
	{
		Goto Completion;
	}
	
	nmax = 10;
	n = CurLevel - 30;
	CurrentAddit = StartReq[2];
	ReqAddit = ( WholeReq[2] / float(nmax)*2.0 - 2.0*CurrentAddit ) / float(nmax - 1);
	
	for(i=0; i<n; i++)
	{
		Progress += CurrentAddit;
		CurrentAddit += ReqAddit;
	}
	
Completion:

	return Progress;
	
}

static function int PerkLevelRequirement(byte CurLevel, byte ReqNum)
{
	return 0;
}

static function float GetSelfHealPotency(KFPlayerReplicationInfo KFPRI)
{
	return 1.0;
}

static function float GetSyringeMinimumSelfHealHPLevel(KFPlayerReplicationInfo KFPRI)
{
	return 20.0;
}

static function float GetFireFieldDurationBonus(KFPlayerReplicationInfo KFPRI)
{
	return 0.0;
}

static function float Resistance(SRPlayerReplicationInfo SRPRI)
{
	return 0.05;
}

static function float GetWeldArmorSpeedModifier(SRPlayerReplicationInfo SRPRI)
{
	return 1.0;
}

static function float CritStrikeChance(SRPlayerReplicationInfo SRPRI)
{
	return 0.00;
}

static function float CritDamageModifier(SRPlayerReplicationInfo SRPRI)
{
	return 2.0;
}

static function float AimBonus(SRPlayerReplicationInfo SRPRI)
{
	return 0.00;
}

static function float TurretAmmoMod(KFPlayerReplicationInfo KFPRI, class<Pawn> TurretClass)
{
	return 1.00;
}

static function float TurretHealthMod(KFPlayerReplicationInfo KFPRI, class<Pawn> TurretClass)
{
	return 1.00;
}

static function float GetHUDCoiff(KFPlayerReplicationInfo KFPRI)
{
	return 1.0;
}

static function float GetInvisibilityDuration(SRPlayerReplicationInfo SRPRI)
{
	return 7.0;
}

static function float GetInvisibilityAlarmTime(SRPlayerReplicationInfo SRPRI)
{
	return 3.3;
}

static function float GetInvisibilitySpeedModifier(SRPlayerReplicationInfo SRPRI)
{
	return 1.0;
}

static function float GetInvisibilityDamageModifier(SRPlayerReplicationInfo SRPRI, class<DamageType> DamageType)
{
	return 1.0;
}

static function bool DisableInvisibilityCollision(SRPlayerReplicationInfo SRPRI)
{
	return false;
}

static function int InvisibilityLimit(SRPlayerReplicationInfo SRPRI)
{
	return 0;
}

static function float BackstabDamageModifer(PlayerReplicationInfo PRI, Pawn Victim, class<DamageType> DmgType)
{
	return 1.00;
}

static function float DecapDamageModifier(PlayerReplicationInfo PRI, Pawn Victim, class<DamageType> DmgType)
{
	return 1.00;
}

static function int DecapCountPerWave(PlayerReplicationInfo PRI)
{
	return 0;
}

static function int TurretSupplyAmount(KFPlayerReplicationInfo KFPRI, class<Actor> SupplyClass, Pawn P)
{
	return 0;
}

static function class<DamageType> GetObjectDamageType(SRPlayerReplicationInfo SRPRI, Object Obj, class<DamageType> DamageType)
{
	return DamageType;
}
//=========================================================

static function float GetMoneyReward(SRPlayerReplicationInfo SRPRI,class<KFMonster> MonsterClass)
{
	return 1.00;
}

static function int GetMaxArmor(KFPlayerReplicationInfo KFPRI)
{
	return 100;
}
static function float NearbyDamageModifer(KFPlayerReplicationInfo PRI, float Distance, class<DamageType> DmgType)
{
	return 1.00;
}
static function float EffectsDamageModifer(KFPlayerReplicationInfo PRI, class DmgType)
{
	return 1.00;
}
static function bool CanWeldMaxArmor(SRPlayerReplicationInfo SRPRI)
{
	return false;
}
defaultproperties
{
	DisableDescription10lvl="Предмет станет доступен для покупки , при достижении 10-го уровня перка."
	DisableDescription26lvl="Предмет станет доступен для покупки , при достижении 26-го уровня соответствующего перка."
	DisableDescription31lvl="Предмет станет доступен для покупки , при достижении 31-го уровня соответствующего перка."
	DisableDescriptionDonate="Премиум-оружие с увеличенными характеристиками, для приобритения перейдите на сайт, кнопка Donate/Индивидуальное оружие/Premium Оружие"
	DisableDescriptionElite="Элитное Премиум-оружие с уникальными характеристиками, для приобритения перейдите на сайт, кнопка Donate/Индивидуальное оружие/Elite Premium Оружие"
	DisableDescriptionMAX="Индивидуальное оружие MAX-100"
	DisableDescriptionGM="Индивидуальное оружие клана GodMode"
	DisableDescriptionEU="Индивидуальное оружие клана Elite Unit"
	DisableTag="LOCKED"
	DisableTag10lvl="10 Lvl"
	DisableTag26lvl="26 Lvl"
	DisableTag31lvl="31 Lvl"
	DisableTagDonate="PREMIUM"
	DisableTagElite="ELITE"
	DisableTagMAX="MAX-100"
	DisableTagGM="God Mode"
	DisableTagEU="EliteUnit"
	NumRequirements=1
}