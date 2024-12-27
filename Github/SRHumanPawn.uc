//=============================================================================
// SRHumanPawn
//=============================================================================
class SRHumanPawn extends SRHumanPawnBase;

var SRGameRules GameRules;
var ClientPerkRepLink PerkLink;

// Dr. Killjoy aka Steklo    addition

var	float			CheckTime;
//var Mesh			NormalMesh;
//var AvoidMarker 	InvisZone;

// переменные стимулятора

var bool		bStimulated,bSuffer,bLoseHealth;
var int			StimulateCount;
var float		StimulatedHealth,HealthToConsume,StimulationEndTime,StimulationStartTime,StimulatedSpeed,StimulatedFireRate,StimulatedDamage,StimulatedReloadSpeed,
				HealthConsumePerSec,SufferSpeedReduction,NextSufferTime,SufferEndTime;
				
var float		SpeedStimulationModifier;

var float		KillingSpreeNullCount,KillingSpree;

// Stamina

var float		Stamina;
var float		DamageStaminaExpenceRate;

// Zed time

var bool bClientRequestZedTime;

// Фикс бага с катаной

var	bool		bPerformMove;

// Временный резист к яду и атакам архвайла

var float VenomResistCharge,FrostBlastResistCharge;

// Начисление денег за сварку

var float WeldingDoorPenalty,WeldedArmor;

// Броня

var	int	MaxShieldStrength;

// Модификаторы

var float BoostSpeedModifier;

// Фикс тосскэша

var transient float CashTossTimer,LongTossCashTimer;
var transient byte LongTossCashCount;
//var float TossCashAllowTime, TossCashFreq;
//var int TossCashStucks,TossCashTreshhold;
//var bool bBanned;

var() config bool bDrawBlood;

// Баффы и дебаффы

struct BuffInfoType
{
	var	bool			bPermanent;
	var	float			RemoveTime;
	var	class<Buff>	Buff;
};

var array<BuffInfoType> Buffs;

// Модификаторы скорости

var	const	int	MM_CURRENT,MM_ARCHVILLE;
	CONST		MM_LEN=2;
	
struct MovementModType
{
	var	int		Stucks;
	var	float		Modifier,DefaultModifier;
};

var	array<MovementModType>	MovementMod[MM_LEN];

var KFPCServ KFPCServ;
var float DelayCheckAmmo;

replication
{
	reliable if ( Role == ROLE_Authority )
		bStimulated,
		bSuffer,
		bLoseHealth,
		Stamina,
		bPerformMove,
		WeldingDoorPenalty,
		BoostSpeedModifier,
		DrawBlood;
	
	reliable if ( Role < ROLE_Authority )
		LaunchPickupTurrets,
		LaunchPickupMBot,
		LaunchPickupZic,
		LaunchPickupAlduin,
		LaunchPickupSig,
		bClientRequestZedTime,
		InstigateZedTime;
	//	InvisibilityRequest,
	//	VisibilityRequest;
    /*reliable if( bNetOwner && Role == ROLE_Authority )
        ClientSetInventoryGroup, ClientSetWeaponPriority;*/
}

function AddDefaultInventory()
{
	local KFPlayerReplicationInfo KFPRI;
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;
	local int PerkIndex;
	
	SRPRI = SRPlayerReplicationInfo(PlayerReplicationInfo);
	KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);

	if (SRPRI != none || KFPRI != none)
	{
		weapon = SRPRI.Weapon;
		PerkIndex = KFPRI.ClientVeteranSkill.default.PerkIndex;
	 
		if ( Mid(weapon, 7, 1) == "3" 
		|| Mid(weapon, 7, 1) == "5" 
		|| Mid(weapon, 7, 1) == "4" 
		|| Mid(weapon, 7, 1) == "7" 
		|| SRPRI.HasSkinGroup("Funtik")
		|| SRPRI.HasSkinGroup("Wapik") )
		{
			RequiredEquipment[4] = "Masters.WelderExP";
		}
		if ( PerkIndex == 0 )
		{
			RequiredEquipment[1] = "Mswp.USP45MLLI";
		}
		else if ( PerkIndex == 1 )
		{
			RequiredEquipment[1] = "Mswp.Ashot";
		}
		else if ( PerkIndex == 2 )
		{
			RequiredEquipment[1] = "Mswp.FNP45SA";
		}
		else if ( PerkIndex == 3 )
		{
			RequiredEquipment[1] = "Mswp.OC33LLI";
		}
		else if ( PerkIndex == 4 )
		{
			RequiredEquipment[1] = "Mswp.ShurikenLLI";
		}
		else if ( PerkIndex == 5 )
		{
			RequiredEquipment[1] = "Mswp.PM";
		}
		else if ( PerkIndex == 6 )
		{
			RequiredEquipment[1] = "Mswp.Trigun_Pistol";
		}
		else if ( PerkIndex == 7 )
		{
			RequiredEquipment[1] = "Mswp.BerettaPx4";
		}
		else if ( PerkIndex == 8 )
		{			
			if ( (Mid(weapon, 8, 1) == "O" || Mid(weapon, 8, 1) == "9") && !SRPRI.HasSkinGroup("LLIePLLIeHb") )
			{
				RequiredEquipment[1] = "Mswp.VereskSAAssaultRifle";
			}
			else
			{
				RequiredEquipment[1] = "Mswp.Glock18cLLI";
			}
		}
		else if ( PerkIndex == 9 )
		{
			if ( ((SRPRI.HasSkinGroup("MAX") || SRPRI.ClanTag~="[GodMode]")) && !SRPRI.HasSkinGroup("LLIePLLIeHb") )
			{
				RequiredEquipment[1] = "Mswp.HK1911LLIPistol";
			}
			else if ( SRPRI.HasSkinGroup("DeagleMagadan") )
			{
				RequiredEquipment[1] = "Mswp.DeagleK";
			}
			else 
				RequiredEquipment[1] = "Mswp.SingleM";
		}
		else if ( PerkIndex == 10 )
		{
			RequiredEquipment[1] = "Mswp.P226LLIPistol";
		}
		else if ( PerkIndex == 11 )
		{
			RequiredEquipment[1] = "Mswp.Glock17";
		}
	}
	/*else
	{
		RequiredEquipment[1] = none;
	}*/
	
	super.AddDefaultInventory();
}

simulated function PostBeginPlay()
{
	if(KFPCServ != none)
	{
		KFPCServ = class'DKUtil'.Static.GetKFPCServ(Level.GetLocalPlayerController());
		BurnEffect = class<Emitter>(KFPCServ.GetEffectClass(BurnEffect));
	}
	Super.PostBeginPlay();
}

function ServerSellAmmo( class<Ammunition> Aclass );

simulated function Tick(float DeltaTime)
{
	local KFMonster Mon;
	local bool bNearMonster;
	local SRPlayerReplicationInfo SRPRI;
	local int i,n;
	local int PrevInvisCharge;
	
	if (PlayerReplicationInfo != none )
		SRPRI = SRPlayerReplicationInfo(PlayerReplicationInfo);
	
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( Skins[0] == InvisMaterial && !bInvisible )
		{
			n = VisibleSkins.Length;
			Skins.Length = n;
			
			for(i=0; i<n; i++)
			{
				Skins[i] = VisibleSkins[i];
			}
		}
		else if ( Skins[0] != InvisMaterial && bInvisible )
		{
			n = Skins.Length;
			VisibleSkins.Length = n;
			
			for(i=0; i<n; i++)
			{
				VisibleSkins[i] = Skins[i];
				Skins[i] = InvisMaterial;
			}
		}
	}
	
	if ( Role == ROLE_Authority )
		RepInvisCharge = string(InvisCharge);
	else 
		InvisCharge = float(RepInvisCharge);
	if(Role == ROLE_Authority)
	{
		UpdateBuffs();
		
		if(Level.TimeSeconds > DelayCheckAmmo)
		{
			UpdateAmmoStatus(SRPRI);
			DelayCheckAmmo = Level.TimeSeconds+0.20;
		}
		if ( !bInvisible )
		{
			if ( CheckInvisCooldownTime < Level.TimeSeconds )
			{
				CheckInvisCooldownTime = Level.TimeSeconds + 1.00;
				if(SRPRI != none)
					SRPRI.InvisCooldown = Max(0,SRPRI.InvisCooldown-1);
			}
		}
		else if ( InvisCharge <= 0.00 )
		{
			/*if ( SRPRI.StringPlayerID ~= "76561198051339418" )
			{
				log("InvisCharge = " $ InvisCharge);
				log("BecomeVisible");
			}*/
			BecomeVisible();
		}
		else
		{
			foreach VisibleCollidingActors(class'KFMonster',Mon,Self.CollisionRadius + AlarmRadius + 300, Self.Location)
			{
				if(Mon.bDecapitated
				|| Mon.Health < 0
				|| Mon.Intelligence == BRAINS_Retarded
				|| Mon.Controller != none
				&& KFMonsterController(Mon.Controller) != none
				&& KFMonsterController(Mon.Controller).bUseFreezeHack
				|| DKRegenerator(Mon) != none && DKRegenerator(Mon).bAlmostDead)
				{
					continue;
				}
				
				if ( VSize(Self.Location - Mon.Location) < Self.CollisionRadius + Mon.CollisionRadius + AlarmRadius )
				{
					AlarmLevel += 2.00 * DeltaTime;
					break;
				}
			}
			AlarmLevel = FMax(0.00,AlarmLevel-DeltaTime);
			/*if ( SRPRI.StringPlayerID ~= "76561198051339418" )
			{
				log("AlarmLevel = " $ AlarmLevel);
				log("AlarmLimit = " $ AlarmLimit);
			}*/
			if ( AlarmLevel >= AlarmLimit )
			{
				/*if ( SRPRI.StringPlayerID ~= "76561198051339418" )
				{
					log("AlarmLevel >= AlarmLimit ");
					log("BecomeVisible");
				}*/
				BecomeVisible();
			}
			else
			{
				PrevInvisCharge = InvisCharge;
				InvisCharge -= DeltaTime;
				/*if ( SRPRI.StringPlayerID ~= "76561198051339418" )
					log("InvisCharge = " $ InvisCharge);*/
				if ( PrevInvisCharge != int(InvisCharge) ) // более ровно отображаем изменение шкалы невидимости
				{
					NetUpdateTime = Level.TimeSeconds - 1;
				}
			}
		}

		ReplicateInvisValues();
	}
	
	if ( VenomResistCharge > 0.1 )
	{
		VenomResistCharge = FMax(0.0,VenomResistCharge-DeltaTime);
	}
	
	if ( FrostBlastResistCharge > 0.1 )
	{
		FrostBlastResistCharge = FMax(0.0,FrostBlastResistCharge-DeltaTime);
	}

//	if ( !bClientInvis && SRPlayerReplicationInfo(Controller.PlayerReplicationInfo).bInvisible )
//	{
//		MakeInvisible(bInvisCollision, InvisibilityCharge, InvisibleSpottedDur);
//	}
	
//	if ( bClientInvis && !SRPlayerReplicationInfo(Controller.PlayerReplicationInfo).bInvisible )
//	{
//		VisibilityRequest(false);
//	}

	if ( bClientRequestZedTime )
	{
		bClientRequestZedTime = false;
		if ( !KFGameReplicationInfo(Level.Game.GameReplicationInfo).bWaveInProgress || SRPlayerReplicationInfo(Controller.PlayerReplicationInfo).ZedTimeCharge < 100.0 )
		Goto Reloading;
		KFPCServ(Controller).ConsumeZedTimeCharge(100.0);
		DKGameType(Level.Game).ZedTime(true);
	}
	
	Reloading:

	if ( KillingSpreeNullCount < Level.TimeSeconds )
	{
		KillingSpree = 0;
	}
	
	if ( bStimulated )
	{
		if ( StimulationEndTime < Level.TimeSeconds )
		{
			RemoveStimulation();
		}
	}
	else if ( bSuffer )
	{
		if ( bLoseHealth )
		{
			if ( NextSufferTime < Level.TimeSeconds )
			{
				NextSufferTime = Level.TimeSeconds + 0.5;
				Super.TakeDamage(FMin(HealthConsumePerSec,HealthToConsume),Self,Location,VRand(),class'DamTypeOverdose');
				HealthToConsume -= HealthConsumePerSec;
				if ( HealthToConsume <= 0.0 )
				{
					bLoseHealth = false;
					HealthMax = default.HealthMax;
					Health = FMin(Health,HealthMax);
					SufferEndTime = Level.TimeSeconds + ( StimulationEndTime - StimulationStartTime ) * 0.35;
				}
			}
		}
		else if ( SufferEndTime < Level.TimeSeconds )
		{
			RemoveSuffer();
		}
	}

	if( CheckTime < Level.TimeSeconds )
	{
		CheckTime = Level.TimeSeconds + 1.5;
    }

	super.Tick(deltaTime);
}

function ReplicateInvisValues()
{
	local SRPlayerReplicationInfo SRPRI;
	
	if ( PlayerReplicationInfo != none ) SRPRI = SRPlayerReplicationInfo(PlayerReplicationInfo);
	if ( SRPRI != none )
	{
		SRPRI.InvisTimeHUD = InvisCharge;
		SRPRI.InvisAlarmLevelHUD = AlarmLevel * 100.0;
		SRPRI.InvisAlarmLimitHUD = AlarmLimit * 100.0;
	}
}

function UpdateAmmoStatus(SRPlayerReplicationInfo SRPRI)
{
	local Inventory Inv;
	local float CurrentStatus;
	local int Count,CurrentAmmo,MaxAmmo;
	
	if(SRPRI==none)
		return;
	
	for(Inv=Inventory; Inv!=none; Inv=Inv.Inventory)
	{
		if(FlashlightAmmo(Inv)!=none)
			continue;
		
		if (SRAmmunition(Inv)==none)
			continue;
			
		MaxAmmo = SRAmmunition(Inv).default.MaxAmmo;
		CurrentAmmo = SRAmmunition(Inv).AmmoAmount;
			
		if (SRPRI != none && SRPRI.ClientVeteranSkill != none )
		{
			MaxAmmo *= SRPRI.ClientVeteranSkill.Static.AddExtraAmmoFor(SRPRI,class<Ammunition>(Inv.class));
			//Фикс на гранаты
			if(CurrentAmmo > MaxAmmo)
				SRAmmunition(Inv).AmmoAmount = MaxAmmo;
		}
		//CurrentStatus += CurrentAmmo / MaxAmmo;
		CurrentStatus += float(CurrentAmmo) / float(MaxAmmo);
		Count++;
		//Log("UpdateAmmoStatus"@Inv@CurrentStatus@CurrentAmmo@MaxAmmo);
		//Log("UpdateAmmoStatus"@Inv@CurrentStatus);
	}
	SRPRI.AmmoStatus = string(CurrentStatus / float(Count));
    //Log("SRPRI.AmmoStatus"@SRPRI.PlayerName@SRPRI.AmmoStatus);
}

function bool DoJump( bool bUpdating )
{
	if ( bPerformMove ) // фикс от катаны
	{
		return false;
	}
	return Super.DoJump(bUpdating);
}

function bool GiveHealth(int HealAmount, int HealMax)
{
	VenomResistCharge = 5.6;
	return Super.GiveHealth(HealAmount,HealMax);
}

function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
//	local float OldHealth;
	local SRPlayerReplicationInfo SRPRI;
	local float InvisAlarmLimit,InvisDur;
	local bool bCollision;
	local DKMonsterController DKMC;
	
	if ( (DamageType == class'DamTypePoison' || DamageType == class'DamTypePoisonD' || DamageType == class'DamTypePoisonS') && VenomResistCharge > 0.1 )
		Damage *= 0.50;
	if (DamageType == class'DamTypeFrostBlast')
	{
		if ( FrostBlastResistCharge > 0.01 )
			Damage *= 0.50;
		else
			FrostBlastResistCharge = 8.00;
	}
	if (class<DamTypeInvisNade>(DamageType) != none && Role == ROLE_Authority)
	{
		SRPRI = SRPlayerReplicationInfo(PlayerReplicationInfo);
		InvisDur = class<SRVeterancyTypes>(SRPRI.ClientVeteranSkill).Static.GetInvisibilityDuration(SRPRI);
		InvisAlarmLimit = class<SRVeterancyTypes>(SRPRI.ClientVeteranSkill).Static.GetInvisibilityAlarmTime(SRPRI);
		bCollision = !class<SRVeterancyTypes>(SRPRI.ClientVeteranSkill).Static.DisableInvisibilityCollision(SRPRI);
		bGrenadeInvis = true;
		BecomeInvisible(FMax(12.0,InvisDur),InvisAlarmLimit,bCollision);
		return;
	}
	if (InstigatedBy != none && InstigatedBy.Controller != none)
		DKMC = DKMonsterController(InstigatedBy.Controller);
	if ( bInvisible )
	{
		if ( class<SRFireDamageType>(DamageType) != none || class<DamTypeBurned>(DamageType) != none ||
			class<DamTypeVomit>(DamageType) != none ) // огонь и желчь блоата обнаруживают невидимого
		{
			BecomeVisible();
		}
		else if ((DKMC == none || !DKMC.CanSeeInvisible(Self))
				&& !(class<KFWeaponDamageType>(damageType) != none && class<KFWeaponDamageType>(DamageType).default.bIsExplosive
				|| class<DamTypeLAW>(damageType) != none
				|| class<DamTypeRocketImpact>(damageType) != none
				|| class<DamTypeLawRocketImpact>(damageType) != none
				|| class<SirenScreamDamage>(damageType) != none
				|| class<Fell>(damageType) != none
				|| class<DamTypePoison>(damageType) != none
				|| class<DamTypeFrostBlast>(damageType) != none))
					// получает урон от взрывчатки, падения, яда и крика сирен, пули пролетают сквозь невидимого
		{
			return;
		}
	}
//	OldHealth = Health;
	Super.TakeDamage(Damage,InstigatedBy,HitLocation,Momentum,DamageType,HitIndex);

/*
	if ( OldHealth > Health )
	{
		ConsumeStamina(( OldHealth - float(Health) ) * 0.2);
	}
*/
}

simulated function Stimulate(float HealthBoost, float Dur)
{
	local SRPlayerReplicationInfo SRPRI;

	if ( !bSuffer )
	{
		bStimulated = true;
		if ( StimulateCount < 1 )
			StimulationStartTime = Level.TimeSeconds;
		if ( StimulateCount++ < 2 )
		{
			StimulatedHealth += HealthBoost;
			HealthToConsume += 100 + HealthBoost;
			StimulatedSpeed += 0.1;
			StimulatedFireRate += 0.25;
			StimulatedDamage += 0/*.25*/;
			StimulatedReloadSpeed += 0.50;
			
			SRPRI = SRPlayerReplicationInfo(PlayerController(Controller).PlayerReplicationInfo);
			SpeedStimulationModifier = 1.0 + StimulatedSpeed;
			HealthMax = FMin(SuperHealthMax,default.HealthMax+StimulatedHealth);
			SRPRI.DamageMod = 1.0 + StimulatedDamage;
			SRPRI.ReloadMod = 1.0 + StimulatedReloadSpeed;
			SRPRI.FireRateMod = 1.0 + StimulatedFireRate;
		}
		StimulationEndTime = Level.TimeSeconds + Dur;
	}
}

simulated function RemoveStimulation()
{
	local SRPlayerReplicationInfo SRPRI;

	bStimulated = false;
	bSuffer = true;
	bLoseHealth = true;
	
	SufferSpeedReduction = StimulatedSpeed;
	HealthConsumePerSec = HealthToConsume * 0.05;
	
	StimulatedHealth = 0;
	StimulatedSpeed = 0;
	StimulatedFireRate = 0;
	StimulatedDamage = 0;
	StimulatedReloadSpeed = 0;
	StimulateCount = 0;
	
	SRPRI = SRPlayerReplicationInfo(PlayerController(Controller).PlayerReplicationInfo);
	SpeedStimulationModifier = 1.0 - SufferSpeedReduction;
	SRPRI.ReloadMod = 1.0;
	SRPRI.DamageMod = 1.0;
	SRPRI.FireRateMod = 1.0;
}

simulated function RemoveSuffer()
{
	bSuffer = false;
	bLoseHealth = false;
	
	SpeedStimulationModifier = 1.0;
	HealthMax = default.HealthMax;
	Health = FMin(Health,HealthMax);
	HealthToConsume = 0.0;
}

simulated event ModifyVelocity(float DeltaTime, vector OldVelocity)
{
    local float WeightMod, HealthMod;
    local float EncumbrancePercentage;

    super(KFPawn).ModifyVelocity(DeltaTime, OldVelocity);

	if (Controller != none)
	{
        // Calculate encumbrance, but cap it to the maxcarryweight so when we use dev weapon cheats we don't move mega slow
        EncumbrancePercentage = (FMin(CurrentWeight, MaxCarryWeight)/MaxCarryWeight);
        // Calculate the weight modifier to speed
        WeightMod = (1.0 - (EncumbrancePercentage * WeightSpeedModifier));
        // Calculate the health modifier to speed
        HealthMod = ((Health/HealthMax) * HealthSpeedModifier) + (1.0 - HealthSpeedModifier);

        // Apply all the modifiers
        GroundSpeed = default.GroundSpeed * HealthMod;
        GroundSpeed *= WeightMod;
        GroundSpeed += InventorySpeedModifier;

		if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			GroundSpeed *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetMovementSpeedModifier(KFPlayerReplicationInfo(PlayerReplicationInfo), KFGameReplicationInfo(Level.GRI));
		}
		
		GroundSpeed *= SpeedStimulationModifier * BoostSpeedModifier;
		UpdateMovementModifiers();
	}
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if ( bStimulated )
		RemoveStimulation();
	if ( bSuffer )
		RemoveSuffer();
		
	BoostSpeedModifier = 1.0;

//	if ( SRPlayerReplicationInfo(Controller.PlayerReplicationInfo).bInvisible )
//	{
//		bInvisible = false;
//		SRPlayerReplicationInfo(Controller.PlayerReplicationInfo).bInvisible = false;
//	}
	if ( Controller != none && KFPCServ(Controller) != none )
		KFPCServ(Controller).GiveZedTimeCharge(0.5);
//	InvisLimitor = Max(5,class<SRveterancyTypes>(SRPlayerReplicationInfo(Controller.PlayerReplicationInfo).ClientVeteranSkill).Static.InvisibilityLimit(SRPlayerReplicationInfo(Controller.PlayerReplicationInfo)));
	Super.Died(Killer,DamageType,HitLocation);
	if ( PlayerReplicationInfo != none && SRPlayerReplicationInfo(PlayerReplicationInfo) != none )
	SRPlayerReplicationInfo(PlayerReplicationInfo).BoundPRI.Timer(); // сохраняем данные в запасной rep info
}

function ConsumeStamina(float Val)
{
//	Stamina = FMax(0.0,Stamina - Val);
	SRPlayerReplicationInfo(PlayerController(Controller).PlayerReplicationInfo).StaminaUsed += Val;
}

simulated event InstigateZedTime()
{
	if ( Role < ROLE_Authority )
		return;

	if ( !DKGameType(Level.Game).bWaveInProgress || SRPlayerReplicationInfo(Controller.PlayerReplicationInfo).ZedTimeCharge < 100.0 )
		return;

	KFPCServ(Controller).ConsumeZedTimeCharge(100.0);
	DKGameType(Level.Game).ZedTime(true);
}

exec function ZedTime()
{
	InstigateZedTime();
}
simulated exec function QuickHeal()
{
    local NewSyringe S;
    local Inventory I;
    local byte C;

    if ( Health>=HealthMax )
        return;
    for( I=Inventory; (I!=None && C++<250); I=I.Inventory )
    {
        S = NewSyringe(I);
        if( S!=None )
            break;
    }
    if ( S == none )
        return;

    if ( S.ChargeBar() < 0.95 )
    {
        if ( PlayerController(Controller) != none && HUDKillingFloor(PlayerController(Controller).myHud) != none )
        {
            HUDKillingFloor(PlayerController(Controller).myHud).ShowQuickSyringe();
        }

        return; // No can heal.
    }

    bIsQuickHealing = 1;
    if ( Weapon==None )
    {
        PendingWeapon = S;
        ChangedWeapon();
    }
    else if ( Weapon!=S )
    {
        PendingWeapon = S;
        Weapon.PutDown();
    }
    else // Syringe already selected, just start healing.
    {
        bIsQuickHealing = 0;
        S.HackClientStartFire();
    }
}

simulated function HandleNadeThrowAnim()
{
    if( Weapon != none )
    {
        if( AK47SHAssaultRifleM(Weapon) != none || AK117SAAssaultRifle(Weapon) != none )
        {
            SetAnimAction('Frag_AK47');
        }
        else if( BullpupM(Weapon) != none )
        {
            SetAnimAction('Frag_Bullpup');
        }
        else if( CrossbowM(Weapon) != none )
        {
            SetAnimAction('Frag_Crossbow');
        }
        else if( DeagleM(Weapon) != none || Magnum44PistolM(Weapon) != none )
        {
            SetAnimAction('Frag_Single9mm');
        }
        else if( DualiesM(Weapon) != none || Dual44MagnumM(Weapon) != none )
        {
            SetAnimAction('Frag_Dual9mm');
        }
        else if( DualDeagleM(Weapon) != none )
        {
            SetAnimAction('Frag_Dual9mm');
        }
        else if( FlameThrowerM(Weapon) != none 
		|| Spitfire(Weapon) != none 
		|| TXM8(Weapon) != none )
        {
            SetAnimAction('Frag_Flamethrower');
        }
        else if( AxeM(Weapon) != none 
		|| AvengerLLIM(Weapon) != none
		|| AvengerLLIW(Weapon) != none
		|| MurasamaDT(Weapon) != none
		|| FrostSword(Weapon) != none
		|| ShadowMourneLLI(Weapon) != none )
        {
            SetAnimAction('Frag_Axe');
        }
        else if( Ninjato(Weapon) != none || FireDragon(Weapon) != none || EbBulava(Weapon) != none )
        {
            SetAnimAction('Frag_Axe');
        }
        else if( ChainsawM(Weapon) != none )
        {
            SetAnimAction('Frag_Chainsaw');
        }
        else if( KatanaM(Weapon) != none || ClaymoreSwordM(Weapon) != none )
        {
            SetAnimAction('Frag_Katana');
        }
        else if( Knife(Weapon) != none )
        {
            SetAnimAction('Frag_Knife');
        }
        else if( Machete(Weapon) != none )
        {
            SetAnimAction('Frag_Knife');
        }
        else if( NewSyringe(Weapon) != none )
        {
            SetAnimAction('Frag_Syringe');
        }
        else if( Welder(Weapon) != none || WelderEx(Weapon) != none || WelderExP(Weapon) != none )
        {
            SetAnimAction('Frag_Syringe');
        }
        else if( BoomStickM(Weapon) != none )
        {
            SetAnimAction('Frag_HuntingShotgun');
        }
        else if( LAWM(Weapon) != none || M202A2(Weapon) != none)
        {
            SetAnimAction('Frag_LAW');
        }
        else if( ShotgunM(Weapon) != none || BenelliShotgunM(Weapon) != none )
        {
            SetAnimAction('Frag_Shotgun');
        }
        else if( WinchesterM(Weapon) != none )
        {
            SetAnimAction('Frag_Winchester');
        }
        else if( SingleM(Weapon) != none )
        {
            SetAnimAction('Frag_Single9mm');
        }
        else if( HK1911LLIPistol(Weapon) != none 
		|| BornBeastSA(Weapon) != none 
		|| ACR10AssaultRifle(Weapon) != none )
        {
            SetAnimAction('Frag_Single9mm');
        }
        else if( M14EBRBattleRifleM(Weapon) != none )
        {
            SetAnimAction('Frag_M14');
        }
        else if( SCARMK17AssaultRifleM(Weapon) != none )
        {
            SetAnimAction('Frag_SCAR');
        }
        else if( AA12AutoShotgunM(Weapon) != none )
        {
            SetAnimAction('Frag_AA12');
        }
        else if( MP5MMedicGunM(Weapon) != none )
        {
            SetAnimAction('Frag_MP5');
        }
        else if( MP7MMedicGunM(Weapon) != none )
        {
            SetAnimAction('Frag_MP7');
        }
        else if( PipeBombExplosive(Weapon) != none || PipeBombExplosiveA(Weapon) != none )
        {
            SetAnimAction('Frag_PipeBomb');
        }
        else if( M79GrenadeLauncherM(Weapon) != none )
        {
            SetAnimAction('Frag_M79');
        }
        else if( M32GrenadeLauncherM(Weapon) != none )
        {
            SetAnimAction('Frag_M32_MGL');
        }
        else if( M4203AssaultRifleM(Weapon) != none )
        {
            SetAnimAction('Frag_M4203');
        }
        else if( M4AssaultRifleM(Weapon) != none )
        {
            SetAnimAction('Frag_M4');
        }
        else if( HuskGunNew(Weapon) != none )
        {
            SetAnimAction('Frag_HuskGun');
        }
    }
    else
    {
        SetAnimAction('Frag_Knife');
    }
}

final function bool HasWeaponclass( class<Inventory> IC )
{
	local Inventory I;
	
	for ( I=Inventory; I!=None; I=I.Inventory )
		if( I.class==IC )
			return true;
	return false;
}

final function ClientPerkRepLink FindStats()
{
	local LinkedReplicationInfo L;

	if( Controller==None || Controller.PlayerReplicationInfo==None )
		return None;
	for( L=Controller.PlayerReplicationInfo.CustomReplicationInfo; L!=None; L=L.NextReplicationInfo )
		if( ClientPerkRepLink(L)!=None )
			return ClientPerkRepLink(L);
	return None;
}

function ServerBuyWeapon( class<Weapon> Wclass, float ItemWeight )
{
	local Inventory I, J;
	local float Price,Weight;
	local bool bIsDualWeapon, bHasDual9mms, bHasDualHCs, bHasDualRevolvers, bHasDualBerettaPx4, bHasDualColt1911,/* bHasDUSP45MLLI,*/ bHasDualWaltherP99, bHasDualPM, bHasDualMK23, bHasDualFlareRevolverNew, bHasNonDefaultDualWeapon;

	if( !CanBuyNow() || class<KFWeapon>(Wclass)==None || class<KFWeaponPickup>(Wclass.Default.Pickupclass)==None )
	{
		Return;
	}

	// Validate if allowed to buy that weapon.
	if( PerkLink==None )
		PerkLink = FindStats();
	if( PerkLink!=None && !PerkLink.CanBuyPickup(class<KFWeaponPickup>(Wclass.Default.Pickupclass)) )
		return;
	Price = class<KFWeaponPickup>(Wclass.Default.Pickupclass).Default.Cost;

	if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		Price *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), Wclass.Default.Pickupclass);
	}

	for ( I=Inventory; I!=None; I=I.Inventory )
	{
		if( I.class==Wclass )
		{
			Return; // Already has weapon.
		}

		if ( I.class == class'DualiesM' )
		{
			bHasDual9mms = true;
		}
		else if ( I.class == class'DualDeagleM' )
		{
			bHasDualHCs = true;
		}
		else if ( I.class == class'Dual44MagnumM' )
		{
			bHasDualRevolvers = true;
		}
		else if ( I.class == class'DualBerettaPx4' )
		{
			bHasDualBerettaPx4 = true;
		}
		else if ( I.class == class'DualColt1911' )
		{
			bHasDualColt1911 = true;
		}
		/*else if ( I.class == class'DUSP45MLLI' )
		{
			bHasDUSP45MLLI = true;
		}*/
		else if ( I.class == class'DualWaltherP99' )
		{
			bHasDualWaltherP99 = true;
		}
		else if ( I.class == class'DualPM' )
		{
			bHasDualPM = true;
		}
		/*
		else if ( I.class == class'DualMK23' )
		{
			bHasDualMK23 = true;
		}*/
		else if ( I.class == class'DualFlareRevolverNew' )
		{
			bHasDualFlareRevolverNew = true;
		}
	}

	if ( Wclass == class'DualDeagleM' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.class == class'DeagleM' )
			{
				Price = Price / 2;
				bHasNonDefaultDualWeapon = true;

				break;
			}
		}

		bIsDualWeapon = true;
		bHasDualHCs = true;
	}

	if ( Wclass == class'Dual44MagnumM' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.class == class'Magnum44PistolM' )
			{
				Price = Price / 2;
				bHasNonDefaultDualWeapon = true;

				break;
			}
		}

		bIsDualWeapon = true;
		bHasDualRevolvers = true;
	}

	if ( Wclass == class'DualBerettaPx4' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.class == class'BerettaPx4' )
			{
				Price = Price / 2;
				bHasNonDefaultDualWeapon = true;

				break;
			}
		}

		bIsDualWeapon = true;
		bHasDualBerettaPx4 = true;
	}

	if ( Wclass == class'DualColt1911' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.class == class'Colt1911' )
			{
				Price = Price / 2;
				bHasNonDefaultDualWeapon = true;

				break;
			}
		}

		bIsDualWeapon = true;
		bHasDualColt1911 = true;
	}

	/*if ( Wclass == class'DUSP45MLLI' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.class == class'USP45MLLI' )
			{
				Price = Price / 2;
				bHasNonDefaultDualWeapon = true;

				break;
			}
		}

		bIsDualWeapon = true;
		bHasDUSP45MLLI = true;
	}*/

	if ( Wclass == class'DualWaltherP99' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.class == class'WaltherP99' )
			{
				Price = Price / 2;
				bHasNonDefaultDualWeapon = true;

				break;
			}
		}

		bIsDualWeapon = true;
		bHasDualWaltherP99 = true;
	}

	if ( Wclass == class'DualPM' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.class == class'PM' )
			{
				Price = Price / 2;
				bHasNonDefaultDualWeapon = true;

				break;
			}
		}

		bIsDualWeapon = true;
		bHasDualPM = true;
	}
/*
	if ( Wclass == class'DualMK23' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.class == class'MK23' )
			{
				Price = Price / 2;
				bHasNonDefaultDualWeapon = true;

				break;
			}
		}

		bIsDualWeapon = true;
		bHasDualMK23 = true;
	}
*/
	if ( Wclass == class'DualFlareRevolverNew' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.class == class'FlareRevolverNew' )
			{
				Price = Price / 2;
				bHasNonDefaultDualWeapon = true;

				break;
			}
		}

		bIsDualWeapon = true;
		bHasDualFlareRevolverNew = true;
	}

	bIsDualWeapon = bIsDualWeapon || Wclass == class'DualiesM';

	if ( !bHasNonDefaultDualWeapon && !CanCarry(class<KFWeapon>(Wclass).Default.Weight) )
	{
		bHasNonDefaultDualWeapon = false;
		Return;
	}

    if ( PlayerReplicationInfo.Score < Price )
	{
		bHasNonDefaultDualWeapon = false;
		Return; // Not enough CASH.
	}

	I = Spawn(Wclass);

	if ( I != none )
	{
		if ( KFGameType(Level.Game) != none )
		{
			KFGameType(Level.Game).WeaponSpawned(I);
		}

		KFWeapon(I).UpdateMagCapacity(PlayerReplicationInfo);
		KFWeapon(I).FillToInitialAmmo();
		KFWeapon(I).SellValue = Price * 0.50;
		I.GiveTo(self);
		PlayerReplicationInfo.Score -= Price;

		if ( bIsDualWeapon )
		{
			KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).OnDualsAddedToInventory(bHasDual9mms, bHasDualHCs, bHasDualRevolvers/*, bHasDualBerettaPx4, bHasDualColt1911, bHasDualWaltherP99*/);
		}

        ClientForceChangeWeapon(I);
    }

	bHasNonDefaultDualWeapon = false;

	SetTraderUpdate();
}

function ServerSellWeapon( class<Weapon> Wclass )
{
	local Inventory I;
	//local SingleM NewSingle;
	local DeagleM NewDeagle;
	local Magnum44PistolM New44Magnum;
	local BerettaPx4 NewBerettaPx4;
	local Colt1911 NewColt1911;
	local USP45MLLI NewUSP45MLLI;
	local WaltherP99 NewWaltherP99;
	local PM NewPM;
//	local MK23 NewMK23;
	local FlareRevolverNew NewFlareRevolverNew;
	local float Price;

	if ( !CanBuyNow() || class<KFWeapon>(Wclass) == none || class<KFWeaponPickup>(Wclass.Default.Pickupclass) == none )
	{
		SetTraderUpdate();
		Return;
	}

	for ( I = Inventory; I != none; I = I.Inventory )
	{
		if ( I.class == Wclass )
		{
			if ( KFWeapon(I) != none && KFWeapon(I).SellValue > 0 )
			{
				Price = KFWeapon(I).SellValue;
			}
			else
			{
				Price = int(class<KFWeaponPickup>(Wclass.default.Pickupclass).default.Cost * 0.50);

				if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
				{
					Price *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), Wclass.Default.Pickupclass);
				}
			}

			/*if ( DualiesM(I) != none && DualDeagleM(I) == none && Dual44MagnumM(I) == none && DualBerettaPx4(I) == none && DualColt1911(I) == none && DUSP45MLLI(I) == none && DualWaltherP99(I) == none && DualPM(I) == none && DualFlareRevolverNew(I) == none )
			{
				NewSingle = Spawn(class'SingleM');
				NewSingle.GiveTo(self);
			}*/

			if ( DualDeagleM(I) != none )
			{
				NewDeagle = Spawn(class'DeagleM');
				NewDeagle.GiveTo(self);
				Price = Price / 2;
			}

			if ( Dual44MagnumM(I) != none )
			{
				New44Magnum = Spawn(class'Magnum44PistolM');
				New44Magnum.GiveTo(self);
				Price = Price / 2;
			}

			if ( DualBerettaPx4(I) != none )
			{
				NewBerettaPx4 = Spawn(class'BerettaPx4');
				NewBerettaPx4.GiveTo(self);
				Price = Price / 2;
			}

			if ( DualColt1911(I) != none )
			{
				NewColt1911 = Spawn(class'Colt1911');
				NewColt1911.GiveTo(self);
				Price = Price / 2;
			}

			/*if ( DUSP45MLLI(I) != none )
			{
				NewUSP45MLLI = Spawn(class'USP45MLLI');
				NewUSP45MLLI.GiveTo(self);
				Price = Price / 2;
			}*/

			if ( DualWaltherP99(I) != none )
			{
				NewWaltherP99 = Spawn(class'WaltherP99');
				NewWaltherP99.GiveTo(self);
				Price = Price / 2;
			}

			if ( DualPM(I) != none )
			{
				NewPM = Spawn(class'PM');
				NewPM.GiveTo(self);
				Price = Price / 2;
			}
/*
			if ( DualMK23(I) != none )
			{
				NewMK23 = Spawn(class'MK23');
				NewMK23.GiveTo(self);
				Price = Price / 2;
			}
*/
			if ( DualFlareRevolverNew(I) != none )
			{
				NewFlareRevolverNew = Spawn(class'FlareRevolverNew');
				NewFlareRevolverNew.GiveTo(self);
				Price = Price / 2;
			}

			if ( I == Weapon || I == PendingWeapon )
			{
				ClientCurrentWeaponSold();
			}

			PlayerReplicationInfo.Score += Price;

			I.Destroyed();
			I.Destroy();

			SetTraderUpdate();

			if ( KFGameType(Level.Game) != none )
			{
				KFGameType(Level.Game).WeaponDestroyed(Wclass);
			}

			return;
		}
	}
}

simulated exec function ToggleFlashlight()
{
	local KFWeapon KFWeap;
	local SRPlayerReplicationInfo SRPRI;
	local class<SRVeterancyTypes> SRVet;

	//if ( Controller == none ) return;
	SRPRI = class'DKUtil'.Static.GetSRPRI(PlayerReplicationInfo);
	SRVet = class'DKUtil'.Static.GetVeteran(PlayerReplicationInfo);
	if ( SRVet == class'SRVetPhantom' || SRVet == class'SRVetPhantomHZD' )
	{
		if ( bMovementDisabled ) return;
		LaunchInvisibility();
		return;
	}
	else if ( SRVet == class'SRVetTechnician' )
	{
		LaunchPickupTurrets();
		return;
	}
	else if ( SRVet == class'SRVetFieldMedic' || SRVet == class'SRVetFieldMedicHZD' )
	{
		LaunchPickupMBot();
		return;
	}
	else if ( SRPRI.HasSkinGroup("Mortal") )
	{
		LaunchPickupMBot();
		return;
	}
	else if ( SRPRI.HasSkinGroup("Zic3") )
	{
		LaunchPickupZic();
		return;
	}
	
	else if ( SRVet != none )
	{
		LaunchPickupAlduin();
		LaunchPickupSig();
		return;
	}	
	
	if ( AUG_A3AR(Weapon) != none )
	{
		AUG_A3AR(Weapon).AllowLight();
		Weapon.ClientStartFire(1);
		return;
	}

	if ( KFWeapon(Weapon) != none && KFWeapon(Weapon).bTorchEnabled )
	{
		Weapon.ClientStartFire(1);
	}
	else
	{
		KFWeap = KFWeapon(FindInventoryType(class'Shotgun'));
		if ( KFWeap == none )
		{
			KFWeap = KFWeapon(FindInventoryType(class'BenelliShotgun'));
    		if ( KFWeap == none )
    		{
				KFWeap = KFWeapon(FindInventoryType(class'DualiesM'));
    			if ( KFWeap == none || DualDeagle(KFWeap) != none || Dual44MagnumM(KFWeap) != none )
    			{
    				KFWeap = KFWeapon(FindInventoryType(class'SingleM'));
    				KFWeap = KFWeapon(FindInventoryType(class'HK1911LLIPistol'));
    				KFWeap = KFWeapon(FindInventoryType(class'DeagleK'));
    			}
			}
		}

		if ( KFWeap != none )
		{
			KFWeap.bPendingFlashlight = true;

			PendingWeapon = KFWeap;

			if ( Weapon != none )
			{
				Weapon.PutDown();
			}
			else
			{
				ChangedWeapon();
			}
		}
	}
}

function GiveWeapon(string aclassName )
{
	local class<Weapon> Weaponclass;
	local Inventory I;
	local Weapon NewWeapon;
	local bool bHasDual9mms, bHasDualHCs, bHasDualRevolvers, bHasDualBerettaPx4, bHasDualColt1911, bHasDUSP45MLLI, bHasDualWaltherP99, bHasDualPM, bHasDualMK23, bHasDualFlareRevolverNew;

	Weaponclass = class<Weapon>(DynamicLoadObject(aclassName, class'class'));

	for ( I = Inventory; I != none; I = I.Inventory )
	{
		if( I.class == Weaponclass )
		{
			Return; // Already has weapon.
		}

		if ( I.class == class'DualiesM' )
		{
			bHasDual9mms = true;
		}
		else if ( I.class == class'DualDeagleM' )
		{
			bHasDualHCs = true;
		}
		else if ( I.class == class'Dual44MagnumM' )
		{
			bHasDualRevolvers = true;
		}
		else if ( I.class == class'DualBerettaPx4' )
		{
			bHasDualBerettaPx4 = true;
		}
		else if ( I.class == class'DualColt1911' )
		{
			bHasDualColt1911 = true;
		}
		/*else if ( I.class == class'DUSP45MLLI' )
		{
			bHasDUSP45MLLI = true;
		}*/
		else if ( I.class == class'DualWaltherP99' )
		{
			bHasDualWaltherP99 = true;
		}
		else if ( I.class == class'DualPM' )
		{
			bHasDualPM = true;
		}/*
		else if ( I.class == class'DualMK23' )
		{
			bHasDualMK23 = true;
		}*/
		else if ( I.class == class'DualFlareRevolverNew' )
		{
			bHasDualFlareRevolverNew = true;
		}
	}

	newWeapon = Spawn(Weaponclass);
	if ( newWeapon != none )
	{
		newWeapon.GiveTo(self);

		if ( Weaponclass == class'DualiesM' || Weaponclass == class'DualDeagleM' || Weaponclass == class'Dual44MagnumM'
		|| Weaponclass == class'DualBerettaPx4' || Weaponclass == class'DualColt1911' /*|| Weaponclass == class'DUSP45MLLI'*/ || Weaponclass == class'DualWaltherP99'
		|| Weaponclass == class'DualPM' /*|| Weaponclass == class'DualMK23'*/ || Weaponclass == class'DualFlareRevolverNew' )
		{
			KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).OnDualsAddedToInventory(bHasDual9mms, bHasDualHCs, bHasDualRevolvers);
		}
		if ( KFGameType(Level.Game) != none )
		{
			KFGameType(Level.Game).WeaponSpawned(newWeapon);
		}
	}
}

simulated function AddBlur(Float BlurDuration, float Intensity)
{
	if( KFPC!=none && Viewport(KFPC.Player)!=None )
		Super.AddBlur(BlurDuration,Intensity);
}


simulated function DoHitCamEffects(vector HitDirection, float JarrScale, float BlurDuration, float JarDurationScale )
{
	/*if( KFPC!=none && Viewport(KFPC.Player)!=None )
		Super.DoHitCamEffects(HitDirection,JarrScale);*/
			if( KFPC!=none && Viewport(KFPC.Player)!=None )
		Super.DoHitCamEffects(HitDirection,JarrScale,BlurDuration,JarDurationScale);
}

simulated function StopHitCamEffects()
{
	if( KFPC!=none && Viewport(KFPC.Player)!=None )
		Super.StopHitCamEffects();
}

exec function TossCash( int Amount )
{
	// To fix cash tossing exploit.
	if( CashTossTimer<Level.TimeSeconds && (LongTossCashTimer<Level.TimeSeconds || LongTossCashCount<20) )
	{
		Super.TossCash(Max(Amount,50));
		CashTossTimer = Level.TimeSeconds+0.1f;
		if( LongTossCashTimer<Level.TimeSeconds )
		{
			LongTossCashTimer = Level.TimeSeconds+5.f;
			LongTossCashCount = 0;
		}
		else ++LongTossCashCount;
	}
}

/*exec function TossCash( int Amount )
{
	if ( bBanned )
	{
		return;
	}

	if ( TossCashAllowTime > Level.TimeSeconds )
	{
		if ( ++TossCashStucks > TossCashTreshhold )
		{
			DKGameType(Level.Game).TosscashBuggers.Insert(0,1);
			DKGameType(Level.Game).TosscashBuggers[0].ID = SRPlayerReplicationInfo(PlayerReplicationInfo).StringPlayerID;
			DKGameType(Level.Game).TosscashBuggers[0].PlName = PlayerReplicationInfo.PlayerName;
			DKGameType(Level.Game).SaveConfig();
			//Level.Game.AccessControl.BanPlayer(PlayerController(Controller));
			bBanned = true;
		}
	}
	else
	{
		Super.TossCash(Amount);
		SRPlayerReplicationInfo(PlayerReplicationInfo).BoundPRI.Timer();
		TossCashAllowTime = Level.TimeSeconds + TossCashFreq;
		TossCashStucks = 1;
	}
}*/


function ApplyBuff(class<Buff> BuffType, float Duration, optional bool bPermanent)
{
	Buffs.Insert(0,1);
	BuffType.Static.ApplyBuff(Self);
	Buffs[0].Buff = BuffType;
	Buffs[0].RemoveTime = Level.TimeSeconds + Duration;
	Buffs[0].bPermanent = bPermanent;
}

function ExtendBuff(class<Buff> BuffType, float Duration, optional bool bPermanent, optional bool bOnlyExtend)
{
	local int i,n;
	
	n = Buffs.Length;
	for(i=0; i<n; i++)
	{
		if ( Buffs[i].Buff == BuffType && Buffs[i].bPermanent == bPermanent )
		{
			Buffs[i].RemoveTime = FMax(Buffs[i].RemoveTime,Level.TimeSeconds + Duration);
			return;
		}
	}
	
	if ( bOnlyExtend )
	{
		return;
	}
	
	// если не нашли такого дебаффа, то добавим его
	ApplyBuff(BuffType,Duration,bPermanent);
}

function RemoveBuff(class<Buff> BuffType, bool bPermanent, optional int Count)
{
	local int i,n;
	
	if ( Count == 0 )
	{
		Count = 2000000;
	}

	n = Buffs.Length;
	for(i=0;i<n; i++)
	{
		if ( ( BuffType == none || Buffs[i].Buff == BuffType ) && Buffs[i].bPermanent == bPermanent )
		{
			Buffs[i].Buff.Static.RemoveBuff(Self);
			Count--;
			i--;
			n--;
			
			if ( Count <= 0 )
			{
				break;
			}
		}
	}
}

function UpdateBuffs()
{
	local int i,n;
	
	n = Buffs.Length;
	
	for(i=0; i<n; i++)
	{
		if ( !Buffs[i].bPermanent && Buffs[i].RemoveTime < Level.TimeSeconds )
		{
			Buffs[i].Buff.Static.RemoveBuff(Self);
			Buffs.Remove(i,1);
			i--;
			n--;
		}
	}
}

function UpdateMovementModifiers()
{
	local int i,n;
	
	n = ArrayCount(MovementMod);
	for(i=0; i<n; i++)
	{
		GroundSpeed *= MovementMod[i].Modifier;
	}
}

function AddMovementMod(int Num)
{
	MovementMod[Num].Stucks++;
	MovementMod[Num].Modifier = MovementMod[Num].DefaultModifier;
}

function RemoveMovementMod(int Num)
{
	MovementMod[Num].Stucks--;
	
	if ( MovementMod[Num].Stucks <= 0 )
	{
		MovementMod[Num].Modifier = 1.00;
	}
}

function ServerBuyKevlar()
{
	local float Cost;
	local int UnitsAffordable;
	local class<SRVeterancyTypes> SRVet;
	local float MaxArmor;
	
	SRVet = class<SRVeterancyTypes>(SRPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill);
	MaxArmor = SRVet.Static.GetMaxArmor(KFPlayerReplicationInfo(PlayerReplicationInfo));
	
	Cost = FMax(0.00,class'Vest'.default.ItemCost * (MaxArmor - ShieldStrength) / 100.00);

	if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		Cost *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), class'Vest');
	}

	if ( !CanBuyNow() || ShieldStrength >= MaxArmor )
	{
		SetTraderUpdate();
		Return;
	}

	if ( PlayerReplicationInfo.Score >= Cost )
	{
		PlayerReplicationInfo.Score -= Cost;
		ShieldStrength = MaxArmor;
	}
	else if ( ShieldStrength > 0 )
	{
		Cost = class'Vest'.default.ItemCost;
		if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
		{
			Cost *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), class'Vest');
		}

		Cost /= 100.0;

		UnitsAffordable = int(PlayerReplicationInfo.Score / Cost);

		PlayerReplicationInfo.Score -= int(Cost * UnitsAffordable);

		ShieldStrength += UnitsAffordable;
	}

	SetTraderUpdate();
}

/*function ServerBuyKevlar()
{
	local float Cost;
	local int UnitsAffordable;
	local KFPlayerReplicationInfo KFPRI;

	KFPRI=KFPlayerReplicationInfo(PlayerReplicationInfo);
	if(KFPRI.ClientVeteranSkillLevel>=31 && KFPRI.ClientVeteranSkillLevel<=35 && KFPRI.ClientVeteranSkill.default.PerkIndex==4)
	{
		Cost = class'Vest'.default.ItemCost * ((150.0 - ShieldStrength) / 150.0);
		if ( KFPRI.ClientVeteranSkill != none)
		{
			Cost *= KFPRI.ClientVeteranSkill.static.GetCostScaling(KFPRI, class'Vest');
		}
		if ( !CanBuyNow() || ShieldStrength==150 )
		{
			SetTraderUpdate();
			return;
		}
		if ( PlayerReplicationInfo.Score >= Cost )
		{
			PlayerReplicationInfo.Score -= Cost;
			ShieldStrength = 150;
		}
		else if ( ShieldStrength > 0 )
		{
			Cost = class'Vest'.default.ItemCost;
			if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
			{
				Cost *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), class'Vest');
			}
			Cost /= 150.0;
			UnitsAffordable = int(PlayerReplicationInfo.Score / Cost);
			PlayerReplicationInfo.Score -= int(Cost * UnitsAffordable);
			ShieldStrength += UnitsAffordable;
		}
		SetTraderUpdate();
	}
	else if(KFPRI.ClientVeteranSkillLevel>=36 && KFPRI.ClientVeteranSkillLevel<=40 && KFPRI.ClientVeteranSkill.default.PerkIndex==4)
	{
		Cost = class'Vest'.default.ItemCost * ((200.0 - ShieldStrength) / 200.0);
		if ( KFPRI.ClientVeteranSkill != none)
		{
			Cost *= KFPRI.ClientVeteranSkill.static.GetCostScaling(KFPRI, class'Vest');
		}
		if ( !CanBuyNow() || ShieldStrength==200 )
		{
			SetTraderUpdate();
			return;
		}
		if ( PlayerReplicationInfo.Score >= Cost )
		{
			PlayerReplicationInfo.Score -= Cost;
			ShieldStrength = 200;
		}
		else if ( ShieldStrength > 0 )
		{
			Cost = class'Vest'.default.ItemCost;
			if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
			{
				Cost *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), class'Vest');
			}
			Cost /= 200.0;
			UnitsAffordable = int(PlayerReplicationInfo.Score / Cost);
			PlayerReplicationInfo.Score -= int(Cost * UnitsAffordable);
			ShieldStrength += UnitsAffordable;
		}
		SetTraderUpdate();
	}
	else if(KFPRI.ClientVeteranSkillLevel>=31 && KFPRI.ClientVeteranSkillLevel<=40 && KFPRI.ClientVeteranSkill.default.PerkIndex==0)
	{
		Cost = class'Vest'.default.ItemCost * ((130.0 - ShieldStrength) / 130.0);
		if ( KFPRI.ClientVeteranSkill != none)
		{
			Cost *= KFPRI.ClientVeteranSkill.static.GetCostScaling(KFPRI, class'Vest');
		}
		if ( !CanBuyNow() || ShieldStrength==130 )
		{
			SetTraderUpdate();
			return;
		}
		if ( PlayerReplicationInfo.Score >= Cost )
		{
			PlayerReplicationInfo.Score -= Cost;
			ShieldStrength = 130;
		}
		else if ( ShieldStrength > 0 )
		{
			Cost = class'Vest'.default.ItemCost;
			if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
			{
				Cost *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), class'Vest');
			}
			Cost /= 130.0;
			UnitsAffordable = int(PlayerReplicationInfo.Score / Cost);
			PlayerReplicationInfo.Score -= int(Cost * UnitsAffordable);
			ShieldStrength += UnitsAffordable;
		}
		SetTraderUpdate();
	}
	else if(KFPRI.ClientVeteranSkillLevel>=21 && KFPRI.ClientVeteranSkillLevel<=25 && KFPRI.ClientVeteranSkill.default.PerkIndex==5)
	{
		Cost = class'Vest'.default.ItemCost * ((125.0 - ShieldStrength) / 125.0);
		if ( KFPRI.ClientVeteranSkill != none)
		{
			Cost *= KFPRI.ClientVeteranSkill.static.GetCostScaling(KFPRI, class'Vest');
		}
		if ( !CanBuyNow() || ShieldStrength==125 )
		{
			SetTraderUpdate();
			return;
		}
		if ( PlayerReplicationInfo.Score >= Cost )
		{
			PlayerReplicationInfo.Score -= Cost;
			ShieldStrength = 125;
		}
		else if ( ShieldStrength > 0 )
		{
			Cost = class'Vest'.default.ItemCost;
			if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
			{
				Cost *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), class'Vest');
			}
			Cost /= 125.0;
			UnitsAffordable = int(PlayerReplicationInfo.Score / Cost);
			PlayerReplicationInfo.Score -= int(Cost * UnitsAffordable);
			ShieldStrength += UnitsAffordable;
		}
		SetTraderUpdate();
	}
	else if(KFPRI.ClientVeteranSkillLevel>=26 && KFPRI.ClientVeteranSkillLevel<=30 && KFPRI.ClientVeteranSkill.default.PerkIndex==5)
	{
		Cost = class'Vest'.default.ItemCost * ((150.0 - ShieldStrength) / 150.0);
		if ( KFPRI.ClientVeteranSkill != none)
		{
			Cost *= KFPRI.ClientVeteranSkill.static.GetCostScaling(KFPRI, class'Vest');
		}
		if ( !CanBuyNow() || ShieldStrength==150 )
		{
			SetTraderUpdate();
			return;
		}
		if ( PlayerReplicationInfo.Score >= Cost )
		{
			PlayerReplicationInfo.Score -= Cost;
			ShieldStrength = 150;
		}
		else if ( ShieldStrength > 0 )
		{
			Cost = class'Vest'.default.ItemCost;
			if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
			{
				Cost *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), class'Vest');
			}
			Cost /= 150.0;
			UnitsAffordable = int(PlayerReplicationInfo.Score / Cost);
			PlayerReplicationInfo.Score -= int(Cost * UnitsAffordable);
			ShieldStrength += UnitsAffordable;
		}
		SetTraderUpdate();
	}
	else if(KFPRI.ClientVeteranSkillLevel>=31 && KFPRI.ClientVeteranSkillLevel<=35 && KFPRI.ClientVeteranSkill.default.PerkIndex==5)
	{
		Cost = class'Vest'.default.ItemCost * ((175.0 - ShieldStrength) / 175.0);
		if ( KFPRI.ClientVeteranSkill != none)
		{
			Cost *= KFPRI.ClientVeteranSkill.static.GetCostScaling(KFPRI, class'Vest');
		}
		if ( !CanBuyNow() || ShieldStrength==175 )
		{
			SetTraderUpdate();
			return;
		}
		if ( PlayerReplicationInfo.Score >= Cost )
		{
			PlayerReplicationInfo.Score -= Cost;
			ShieldStrength = 175;
		}
		else if ( ShieldStrength > 0 )
		{
			Cost = class'Vest'.default.ItemCost;
			if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
			{
				Cost *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), class'Vest');
			}
			Cost /= 175.0;
			UnitsAffordable = int(PlayerReplicationInfo.Score / Cost);
			PlayerReplicationInfo.Score -= int(Cost * UnitsAffordable);
			ShieldStrength += UnitsAffordable;
		}
		SetTraderUpdate();
	}
	else if(KFPRI.ClientVeteranSkillLevel>=36 && KFPRI.ClientVeteranSkillLevel<=40 && KFPRI.ClientVeteranSkill.default.PerkIndex==5)
	{
		Cost = class'Vest'.default.ItemCost * ((200.0 - ShieldStrength) / 200.0);
		if ( KFPRI.ClientVeteranSkill != none)
		{
			Cost *= KFPRI.ClientVeteranSkill.static.GetCostScaling(KFPRI, class'Vest');
		}
		if ( !CanBuyNow() || ShieldStrength==200 )
		{
			SetTraderUpdate();
			return;
		}
		if ( PlayerReplicationInfo.Score >= Cost )
		{
			PlayerReplicationInfo.Score -= Cost;
			ShieldStrength = 200;
		}
		else if ( ShieldStrength > 0 )
		{
			Cost = class'Vest'.default.ItemCost;
			if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
			{
				Cost *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), class'Vest');
			}
			Cost /= 200.0;
			UnitsAffordable = int(PlayerReplicationInfo.Score / Cost);
			PlayerReplicationInfo.Score -= int(Cost * UnitsAffordable);
			ShieldStrength += UnitsAffordable;
		}
		SetTraderUpdate();
	}
	else
	{
		Cost = class'Vest'.default.ItemCost * ((100.0 - ShieldStrength) / 100.0);
		if ( KFPRI.ClientVeteranSkill != none)
		{
			Cost *= KFPRI.ClientVeteranSkill.static.GetCostScaling(KFPRI, class'Vest');
		}
		if ( !CanBuyNow() || ShieldStrength==100 )
		{
			SetTraderUpdate();
			return;
		}
		if ( PlayerReplicationInfo.Score >= Cost )
		{
			PlayerReplicationInfo.Score -= Cost;
			ShieldStrength = 100;
		}
		else if ( ShieldStrength > 0 )
		{
			Cost = class'Vest'.default.ItemCost;
			if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
			{
				Cost *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), class'Vest');
			}
			Cost /= 100.0;
			UnitsAffordable = int(PlayerReplicationInfo.Score / Cost);
			PlayerReplicationInfo.Score -= int(Cost * UnitsAffordable);
			ShieldStrength += UnitsAffordable;
		}
		SetTraderUpdate();
	}
}*/

function bool AddShieldStrength(int ShieldAmount)
{
	local KFPlayerReplicationInfo KFPRI;
	KFPRI=KFPlayerReplicationInfo(PlayerReplicationInfo);
	
	if(KFPRI.ClientVeteranSkillLevel==41 && KFPRI.ClientVeteranSkill.default.PerkIndex==4 && ShieldStrength >= 300)
		return false;
	else if(KFPRI.ClientVeteranSkillLevel>=36 && KFPRI.ClientVeteranSkillLevel<=40 && KFPRI.ClientVeteranSkill.default.PerkIndex==4 && ShieldStrength >= 200)
		return false;
	else if(KFPRI.ClientVeteranSkillLevel>=31 && KFPRI.ClientVeteranSkillLevel<=35 && KFPRI.ClientVeteranSkill.default.PerkIndex==4 && ShieldStrength >= 150)
		return false;
	else if(KFPRI.ClientVeteranSkillLevel>=31 && KFPRI.ClientVeteranSkillLevel<=40 && KFPRI.ClientVeteranSkill.default.PerkIndex==0 && ShieldStrength >= 130)
		return false;
	else if(KFPRI.ClientVeteranSkillLevel>=21 && KFPRI.ClientVeteranSkillLevel<=25 && KFPRI.ClientVeteranSkill.default.PerkIndex==5 && ShieldStrength >= 125)
		return false;
	else if(KFPRI.ClientVeteranSkillLevel>=26 && KFPRI.ClientVeteranSkillLevel<=30 && KFPRI.ClientVeteranSkill.default.PerkIndex==5 && ShieldStrength >= 150)
		return false;
	else if(KFPRI.ClientVeteranSkillLevel>=31 && KFPRI.ClientVeteranSkillLevel<=35 && KFPRI.ClientVeteranSkill.default.PerkIndex==5 && ShieldStrength >= 175)
		return false;
	else if(KFPRI.ClientVeteranSkillLevel>=36 && KFPRI.ClientVeteranSkillLevel<=40 && KFPRI.ClientVeteranSkill.default.PerkIndex==5 && ShieldStrength >= 200)
		return false;
	else if(KFPRI.ClientVeteranSkillLevel==41 && KFPRI.ClientVeteranSkill.default.PerkIndex==5 && ShieldStrength >= 300)
		return false;
	else if( ShieldStrength >= 100 )
		return false;

	ShieldStrength+=ShieldAmount;

	if(KFPRI.ClientVeteranSkillLevel==41 && KFPRI.ClientVeteranSkill.default.PerkIndex==4 && ShieldStrength >= 300)
		ShieldStrength = 300;
	else if(KFPRI.ClientVeteranSkillLevel>=36 && KFPRI.ClientVeteranSkillLevel<=40 && KFPRI.ClientVeteranSkill.default.PerkIndex==4 && ShieldStrength >= 200)
		ShieldStrength = 200;
	else if(KFPRI.ClientVeteranSkillLevel>=31 && KFPRI.ClientVeteranSkillLevel<=35 && KFPRI.ClientVeteranSkill.default.PerkIndex==4 && ShieldStrength >= 150)
		ShieldStrength = 150;
	else if(KFPRI.ClientVeteranSkillLevel>=31 && KFPRI.ClientVeteranSkillLevel<=40 && KFPRI.ClientVeteranSkill.default.PerkIndex==0 && ShieldStrength >= 130)
		ShieldStrength = 130;
	else if(KFPRI.ClientVeteranSkillLevel>=21 && KFPRI.ClientVeteranSkillLevel<=25 && KFPRI.ClientVeteranSkill.default.PerkIndex==5 && ShieldStrength >= 125)
		ShieldStrength = 125;
	else if(KFPRI.ClientVeteranSkillLevel>=26 && KFPRI.ClientVeteranSkillLevel<=30 && KFPRI.ClientVeteranSkill.default.PerkIndex==5 && ShieldStrength >= 150)
		ShieldStrength = 150;
	else if(KFPRI.ClientVeteranSkillLevel>=31 && KFPRI.ClientVeteranSkillLevel<=35 && KFPRI.ClientVeteranSkill.default.PerkIndex==5 && ShieldStrength >= 175)
		ShieldStrength = 175;
	else if(KFPRI.ClientVeteranSkillLevel>=36 && KFPRI.ClientVeteranSkillLevel<=40 && KFPRI.ClientVeteranSkill.default.PerkIndex==5 && ShieldStrength >= 200)
		ShieldStrength = 200;
	else if(KFPRI.ClientVeteranSkillLevel==41 && KFPRI.ClientVeteranSkill.default.PerkIndex==5 && ShieldStrength >= 300)
		ShieldStrength = 300;
	else if( ShieldStrength >= 100)
		ShieldStrength = 100;

	return true ;
}

function CreateInventoryVeterancy(string InventoryclassName, float SellValueScale)
{
	local Inventory Inv;
	local class<Inventory> Inventoryclass;

	Inventoryclass = Level.Game.BaseMutator.GetInventoryclass(InventoryclassName);
	if( (Inventoryclass!=None) && (FindInventoryType(Inventoryclass)==None) )
	{
		Inv = Spawn(Inventoryclass);
		if( Inv != none )
		{
			Inv.GiveTo(self);
			if ( Inv != none )
				Inv.PickupFunction(self);

			if ( KFWeapon(Inv) != none )
			{
				KFWeapon(Inv).SellValue = float(class<KFWeaponPickup>(Inventoryclass.default.Pickupclass).default.Cost) * SellValueScale * 0.50;
			}

			if ( KFGameType(Level.Game) != none )
			{
				KFGameType(Level.Game).WeaponSpawned(Inv);
			}
		}
	}
}
//=====================================================================// Vepr12

simulated function Fire( optional float F )
{
    local KFWeapon W;
    local KFPCServ PC;
    
    PC = KFPCServ(Controller);
    
    W = KFWeapon(Weapon);
    if ( W != none && !W.bMeleeWeapon && W.bConsumesPhysicalAmmo 
            && W.MagCapacity > 1 && W.MagAmmoRemaining < 1 && !W.bIsReloading && !W.bHoldToReload	
            && PC != none && PC.bManualReload) 
	{
        if ( W.AmmoAmount(0) == 0 )
            PC.ReceiveLocalizedMessage(class'Masters.SRPlayerWarningMessage',1);        
        else
            PC.ReceiveLocalizedMessage(class'Masters.SRPlayerWarningMessage',0);        
        W.PlayOwnedSound(W.GetFireMode(0).NoAmmoSound, SLOT_None,2.0,,,,false);
        return;
    }
    
    Super.Fire(F);
}

function VeterancyChanged()
{
	local SRPlayerReplicationInfo SRPRI;
	SRPRI = SRPlayerReplicationInfo(PlayerReplicationInfo);
	ShieldStrength = FMin(ShieldStrength,class<SRVeterancyTypes>(SRPRI.ClientVeteranSkill).Static.GetMaxArmor(SRPRI));
	Super.VeterancyChanged();
}

// store bonus ammo in pawn's class
function TossWeapon(Vector TossVel)
{
	local KFWeapon w;
	
	w = KFWeapon(Weapon);
	if ( w != none ) 
	{
		w.bIsTier2Weapon = false; // This hack is needed because KFWeaponPickup.DroppedBy isn't set for tier 2 weapons.  
		w.bIsTier3Weapon = w.default.bIsTier3Weapon; // restore default value from the hack in AddInventory()
	}

	super.TossWeapon(TossVel);
	
}

function bool AddInventory( inventory NewItem )
{
    local KFWeapon weap;
    weap = KFWeapon(NewItem);
    if( weap != none ) 
	{
		weap.bIsTier3Weapon = true; // hack to set weap.Tier3WeaponGiver for all weapons
    }
    if ( super.AddInventory(NewItem) ) 
	{
        return true;
    }
    return false;
}

/*simulated function ClientSetInventoryGroup( class<Inventory> NewInventoryclass, byte NewInventoryGroup )
{
    local Inventory Inv;
    local int Count;
    
    if ( Role < ROLE_Authority ) 
	{
        NewInventoryclass.default.InventoryGroup = NewInventoryGroup;
        for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory ) 
		{
            if ( Inv.class == NewInventoryclass ) 
			{
                Inv.InventoryGroup = NewInventoryGroup;
                return;
            }
            count++;
            if ( count > 1000 )
                return;
        }
    }
}*/

/*simulated function ClientSetWeaponPriority( class<Weapon> NewWeaponclass, byte NewInventoryGroup, byte GroupOffset, byte Priority )
{
    local Inventory Inv;
    local int Count;
    
    if ( Role < ROLE_Authority ) 
	{
        //need to change default value to, because it is using in some static functions
        NewWeaponclass.default.InventoryGroup = NewInventoryGroup; 
        NewWeaponclass.default.GroupOffset = GroupOffset; 
        NewWeaponclass.default.Priority = Priority; 
        //search the client inventory for the specified class and change its group
        for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory ) 
		{
            if ( Inv.class == NewWeaponclass ) 
			{
                Inv.InventoryGroup = NewInventoryGroup;
                Inv.GroupOffset = GroupOffset;
                Weapon(Inv).Priority = Priority;
                return;
            }
            count++;
            if ( count > 1000 )
                return;
        }
    }
}*/

/*function FindGameRules()
{
	local GameRules G;
	
	if ( GameRules != none )
		return;
		
	for ( G=Level.Game.GameRulesModifiers; GameRules == none && G!=None; G=G.NextGameRules ) {
		GameRules = SRGameRules(G);
	}
}*/

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    local vector direction;
    local rotator InvRotation;
    local float jarscale;
	local Sound CurrentSound;

    PlayDirectionalHit(HitLocation);

    if( Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds )
        return;

    LastPainSound = Level.TimeSeconds;

    if( HeadVolume.bWaterVolume )
    {
        if( DamageType.IsA('Drowned') )
            PlaySound( GetSound(EST_Drown), SLOT_Pain,1.5*TransientSoundVolume );
        else
            PlaySound( GetSound(EST_HitUnderwater), SLOT_Pain,1.5*TransientSoundVolume );
        return;
    }

	if ( SoundGroupClass != none )
		CurrentSound = SoundGroupClass.static.GetHitSound();
	
	if ( CurrentSound != none )
    PlaySound(CurrentSound, SLOT_Pain,2*TransientSoundVolume,,200);

    // for standalone and client
    // Cooney
    if ( Level.NetMode != NM_DedicatedServer )
    {
        // Get the approximate direction
        // that the hit went into the body
        direction = Location - HitLocation;
        // No up-down jarring effects since
        // I dont have the barrel valocity
        direction.Z = 0.0f;
        direction = normal(direction);

        // We need to rotate the jarring direction
        // in screen space so basically the
        // exact opposite of the player's pawn's
        // rotation.
        InvRotation.Yaw = -Rotation.Yaw;
        InvRotation.Roll = -Rotation.Roll;
        InvRotation.Pitch = -Rotation.Pitch;
        direction = direction >> InvRotation;

        jarscale = 0.1f + (Damage/10.0f);
        if ( jarscale > 1.0f )
        {
            jarscale = 1.0f;
        }

        DoHitCamEffects(direction,jarscale,2.0,1.0);
    }
}

simulated function DrawBlood(class<DamageType> DamageType, Vector HitLocation, Vector hitRay, int Damage, Pawn Victim, KFPCServ PC)
{
	if( bDrawBlood )
		class'SRHumanPawn'.static.ShowBloodSplats(DamageType, Victim, HitLocation + hitRay * CollisionRadius * 0.50, hitRay, Damage, 2);
	else
		return;
}

static function ShowBloodSplats(class<DamageType> DamageType, Pawn Victim, Vector HitLoc, Vector hitRay, int Damage, byte Mode)
{
	if(!class'GameInfo'.static.UseLowGore())
	{
		if(Damage > 50 + Rand(30) && (FRand() < 0.25 * float(Mode)) && (DKGorefast(Victim) == none) || (FRand() < 0.25 * float(Mode) && (DKGorefast(Victim) != none)))
		{
			BloodSplashScreenFX(Victim, HitLoc, hitRay, Damage, DamageType);
		}
	}
}

static function BloodSplashScreenFX(Pawn Victim, Vector HitLoc, Vector hitRay, int Damage, class<DamageType> DamageType)
{
	local PlayerController PC;
	local Actor A, E;
	local Vector CamLoc;
	local Rotator CamRot;

	PC = Victim.Level.GetLocalPlayerController();
	if(PC != none)
	{
		PC.PlayerCalcView(A, CamLoc, CamRot);
		if(VSize(HitLoc - CamLoc) < float(200) && (vector(CamRot) Dot Normal(HitLoc - CamLoc) > 0.70))
		{
			if(GetBloodEffect(DamageType, Victim) != none)
			{
				E = PC.Spawn(GetBloodEffect(DamageType, Victim), PC,, CamLoc + vector(CamRot) * float(16), CamRot);
			}
		}
	}
}

static function class<Actor> GetBloodEffect(class<DamageType> DamageType, Pawn A)
{
	if(A.classIsChildOf(DamageType, class'DamTypeMelee') && ((class<DamTypeBlackChainsaw>(DamageType) == none)
	|| (class<DamTypeBlackChainsawAltAttack>(DamageType) == none)))
	{
		return class'BG_ScnBloodSlice';
	}
	else if(A.classIsChildOf(DamageType, class'ZombieMeleeDamage') && (DKGorefast(A) != none))
	{
		return class'BG_ScnBloodSlash';
	}
	else if(class<DamTypeBlackChainsaw>(DamageType) != none || class<DamTypeBlackChainsawAltAttack>(DamageType) != none )
	{
		return class'BG_ScnBloodSaw';
	}
	else
	{
		return class'BG_ScnBlood';
	}
}

simulated function ThrowGrenadeFinished()
{
	SecondaryItem = none;
	if ( Weapon != none )
	{
		if ( KFWeapon(Weapon) != none ) KFWeapon(Weapon).ClientGrenadeState = GN_BringUp;
		Weapon.BringUp();
	}
	bThrowingNade = false;
}

simulated function LaunchInvisibility()
{
	local SRPlayerReplicationInfo SRPRI;
	local float InvisDur,InvisAlarmLimit;
	local bool bCollision;
	
	SRPRI = SRPlayerReplicationInfo(PlayerReplicationInfo);
		
	if ( SRPRI.InvisCooldown > 0 || SRPRI.InvisCount <= 0 || bInvisible )
		return;
			
	InvisDur = class'SRVetPhantom'.Static.GetInvisibilityDuration(SRPRI);
	InvisAlarmLimit = class'SRVetPhantom'.Static.GetInvisibilityAlarmTime(SRPRI);
	bCollision = !class'SRVetPhantom'.Static.DisableInvisibilityCollision(SRPRI);
		
	bMainInvis = true;
	BecomeInvisible(InvisDur,InvisAlarmLimit,bCollision);
}

simulated function LaunchPickupTurrets()
{
	local TurretDK Turret;
	local Doom3Bot Bot;
	
	foreach VisibleCollidingActors(class'TurretDK', Turret, CollisionRadius + 100, Location)
	{
		if ( Turret.TurretPickUp(Self) ) return;
	}
	foreach VisibleCollidingActors(class'Doom3Bot', Bot, CollisionRadius + 100, Location)
	{
		if ( Bot.TurretPickUp(Self) ) return;
	}
}

simulated function LaunchPickupMBot()
{
	local MedSentry MBot;

	foreach VisibleCollidingActors(class'MedSentry', MBot, CollisionRadius + 100, Location)
	{
		if ( MBot.TurretPickUp(Self) ) return;
	}
}

simulated function LaunchPickupZic()
{
	local Zic3LLI Zic;

	foreach VisibleCollidingActors(class'Zic3LLI', Zic, CollisionRadius + 100, Location)
	{
		if ( Zic.TurretPickUp(Self) ) return;
	}
}

simulated function LaunchPickupAlduin()
{
	local AlduinDT Alduin;

	foreach VisibleCollidingActors(class'AlduinDT', Alduin, CollisionRadius + 100, Location)
	{
		if ( Alduin.TurretPickUp(Self) ) return;
	}
}

simulated function LaunchPickupSig()
{
	local Sig33LLI Sig;

	foreach VisibleCollidingActors(class'Sig33LLI', Sig, CollisionRadius + 100, Location)
	{
		if ( Sig.TurretPickUp(Self) ) return;
	}
}

simulated function RemoveFlamingEffects()
{
    local int i;

    if( Level.NetMode == NM_DedicatedServer )
        return;

    for( i=0; i<Attached.length; i++ )
    {
        if( Attached[i].IsA('xEmitter') && !Attached[i].IsA('BloodJet'))
        {
            xEmitter(Attached[i]).mRegen = false;
        }

         if( Attached[i].IsA('SRMonsterFlame'))
        {
          Attached[i].LifeSpan = 0.1;
        }
    }
}

defaultproperties
{
	MM_CURRENT = 0
	MM_ARCHVILLE = 1
	MovementMod(0) = (Stucks=0,Modifier=1.00,DefaultModifier=0.60)
	MovementMod(1) = (Stucks=0,Modifier=1.00,DefaultModifier=0.70)
	
	bDrawBlood=false
	//TossCashTreshhold = 10
	//TossCashFreq = 0.03

	MaxCarryWeight = 1.0
	HealthMax = 100.0
    SuperHealthMax = 250.0
	MaxShieldStrength = 100
	SpeedStimulationModifier = 1.0
	WeldingDoorPenalty = 0.0
	BoostSpeedModifier = 1.0
	
	BurnEffect = class 'SRMonsterFlame'

    RequiredEquipment(0) = "KFMod.Knife"
    RequiredEquipment(1) = "Mswp.SingleM"
    RequiredEquipment(2) = "Masters.Frag1_"
    RequiredEquipment(3) = "Masters.NewSyringe"
    RequiredEquipment(4) = "Masters.WelderEx"
}