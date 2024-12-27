// Self Healing Fire //
class StimulatorLLIAltFire extends WeaponFire;

var float InjectDelay;
var float HealeeRange;

function DoFireEffect()
{
	SetTimer(InjectDelay, False);

	if ( Level.NetMode != NM_StandAlone && Level.Game.NumPlayers > 1 && KFPlayerController(Instigator.Controller) != none &&
		 KFSteamStatsAndAchievements(KFPlayerController(Instigator.Controller).SteamStatsAndAchievements) != none )
	{
		KFSteamStatsAndAchievements(KFPlayerController(Instigator.Controller).SteamStatsAndAchievements).AddSelfHeal();
	}
}

Function Timer()
{
	local float HealSum;

	HealSum = StimulatorLLI(Weapon).HealBoostAmount;

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		HealSum *= ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetHealPotency(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo)) - 1.0 ) * 2.0;
	}

    Weapon.ConsumeAmmo(ThisModeNum, AmmoPerFire);
	SRHumanPawn(Instigator).Stimulate( HealSum, 60.0 + 1.0 * KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkillLevel );
//	Instigator.GiveHealth(HealSum, 100);
}

function bool AllowFire()
{
//	if ( !KFGameReplicationInfo(KFGameType(Level.Game).GameReplicationInfo).bWaveInProgress )
//		return false;
	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.default.PerkIndex != 0 )
		return false;
	return Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire;
}

event ModeDoFire()
{
	Load = 0;
	Super.ModeDoFire(); // We don't consume the ammo just yet.	
}

function PlayFiring()
{
	if ( Weapon.Mesh != None )
	{
		if ( FireCount > 0 )
		{
			if ( Weapon.HasAnim(FireLoopAnim) )
			{
				Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
			}
			else
			{
				Weapon.PlayAnim(FireAnim, FireAnimRate, 0.0);
			}
		}
		else
		{
			Weapon.PlayAnim(FireAnim, FireAnimRate, 0.0);
		}
	}
    Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,Default.FireAnimRate/FireAnimRate,false);
    ClientPlayForceFeedback(FireForce);  // jdf

    FireCount++;
}

defaultproperties
{
     InjectDelay=0.100000
     HealeeRange=70.000000
     TransientSoundVolume=1.800000
     FireAnim="AltFire"
     FireRate=3.600000
     AmmoPerFire=1
	 Ammoclass=class'StimulatorLLIAmmo'
}
