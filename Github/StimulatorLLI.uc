class StimulatorLLI extends SRMeleeGun;

var localized   string  SuccessfulHealMessage;
var 			float 	HealBoostAmount;

replication
{
	reliable if( Role < ROLE_Authority )
		ServerAttemptHeal;

	reliable if( Role == ROLE_Authority )
		ClientSuccessfulHeal;

}

simulated event WeaponTick(float dt)
{
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;
	local KFPlayerReplicationInfo KFPRI;

	KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
	SRPRI = SRPlayerReplicationInfo(Instigator.PlayerReplicationInfo);

	if (KFPRI != none || SRPRI != none)
	{
		weapon = SRPRI.Weapon;
	 
		if	( (Mid(weapon, 0, 1) != "1" && Mid(weapon, 0, 1) != "6" && Mid(weapon, 0, 1) != "F") || KFPRI.ClientVeteranSkill.default.PerkIndex != 0 )
		{
			Destroyed();
			Destroy();
		}
	}
	Super.Weapontick(dt);
}

function bool HandlePickupQuery( pickup Item )
{
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;
	local KFPlayerReplicationInfo KFPRI;

	KFPRI = KFPlayerReplicationInfo(PlayerController(Instigator.Controller).PlayerReplicationInfo);
	SRPRI = SRPlayerReplicationInfo(PlayerController(Instigator.Controller).PlayerReplicationInfo);
	
	if (KFPRI != none || SRPRI != none)
	{
		weapon = SRPRI.Weapon;
	 
		if	( (Mid(weapon, 0, 1) != "1" && Mid(weapon, 0, 1) != "F") || KFPRI.ClientVeteranSkill.default.PerkIndex != 0 )
			return false;
	}

	return Super.HandlePickupQuery(Item);
}

// Try to heal a player on the server
function ServerAttemptHeal()
{
    StimulatorLLIFire(FireMode[0]).AttemptHeal();
}

// The server lets the client know they successfully healed someone
simulated function ClientSuccessfulHeal(String HealedName)
{
   StimulatorLLIFire(FireMode[0]).SuccessfulHeal();
    if( PlayerController(Instigator.Controller) != none )
    {
        PlayerController(Instigator.controller).ClientMessage(SuccessfulHealMessage@HealedName, 'CriticalEvent');
    }
}

simulated function float RateSelf()
{
	return -100;
}

simulated function Timer()
{
	Super.Timer();
	if( KFPawn(Instigator)!=None && KFPawn(Instigator).bIsQuickHealing>0 && ClientState==WS_ReadyToFire )
	{
		if( KFPawn(Instigator).bIsQuickHealing==1 )
		{
			if( !HackClientStartFire() )
			{
				if( Instigator.Health>=Instigator.HealthMax || ChargeBar()<0.75 )
					KFPawn(Instigator).bIsQuickHealing = 2; // Was healed by someone else or some other error occurred.
				SetTimer(0.2,False);
				return;
			}
			KFPawn(Instigator).bIsQuickHealing = 2;
			SetTimer(FireMode[1].FireRate+0.5,False);
		}
		else
		{
			Instigator.SwitchToLastWeapon();
			KFPawn(Instigator).bIsQuickHealing = 0;
		}
	}
	else if( ClientState==WS_Hidden && KFPawn(Instigator)!=None )
		KFPawn(Instigator).bIsQuickHealing = 0; // Weapon was changed, ensure to reset this.
}
simulated function bool HackClientStartFire()
{
	if( StartFire(1) )
	{
		if( Role<ROLE_Authority )
			ServerStartFire(1);
		FireMode[1].ModeDoFire(); // Force to start animating.
		return true;
	}
	return false;
}
/*
simulated function float ChargeBar()
{
	return FClamp(float(AmmoCharge[0])/float(MaxAmmoCount),0,1);
}
*/
simulated function HealthBoost();

defaultproperties
{
	 SleeveNum=4
	 MagCapacity=1
	 HealBoostAmount=25
     SuccessfulHealMessage="You boosted "
     weaponRange=90.000000
     TraderInfoTexture=Texture'Mswp_V5.HealerKF2_LLI_T.HealerKF2_LLI_trader'
     HudImage=Texture'Mswp_V5.HealerKF2_LLI_T.HealerKF2_LLI_unselected'
     SelectedHudImage=Texture'Mswp_V5.HealerKF2_LLI_T.HealerKF2_LLI_selected'
     Weight=1.000000
     StandardDisplayFOV=85.000000
     FireModeclass(0)=class'StimulatorLLIFire'
     FireModeclass(1)=class'StimulatorLLIAltFire'
     AIRating=-2.000000
     bMeleeWeapon=False
     DisplayFOV=85.000000
     Priority=1
     InventoryGroup=1
     GroupOffset=2
	 bCanThrow=False
	 bShowChargingBar=True
     Pickupclass=class'StimulatorLLIPickup'
     BobDamping=7.000000
     Attachmentclass=class'StimulatorLLIAttachment'
     IconCoords=(X1=169,Y1=39,X2=241,Y2=77)
     ItemName="Stimulator"
     Mesh=SkeletalMesh'Mswp_V5.HealerKF2_LLI_mesh'
     Skins(0)=Shader'Mswp_V5.HealerKF2_LLI_T.HealerKF2_LLI_tex_shdr'
     Skins(1)=Shader'Mswp_V5.HealerKF2_LLI_T.HealerKF2_LLI_tex02_shdr'
     Skins(2)=Shader'Mswp_V5.HealerKF2_LLI_T.HealerKF2_LLI_tex01_shdr'
     Skins(3)=Shader'Mswp_V5.HealerKF2_LLI_T.Wep_1stP_Healer_WEAR_111_shdr'
     Skins(4)=Texture'KF_Weapons7_Trip_T.First_Sleeves.UrbanNinja_Sleeves_D'
     AmbientGlow=2
}
