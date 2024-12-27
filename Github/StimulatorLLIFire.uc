class StimulatorLLIFire extends StimulatorLLIAltFire;

var				float	LastHealAttempt;
var				float	HealAttemptDelay;
var 			float 	LastHealMessageTime;
var 			float 	HealMessageDelay;
var localized   string  NoHealTargetMessage;
var             KFHumanPawn    CachedHealee;

simulated function DestroyEffects()
{
    super.DestroyEffects();

    if (CachedHealee != None)
        CachedHealee = none;
}

function AttemptHeal()
{
	local KFHumanPawn Healtarget;

    CachedHealee = none;

    if( AllowFire() && CanFindHealee() )
    {
        super.ModeDoFire();
        StimulatorLLI(Weapon).ClientSuccessfulHeal(CachedHealee.PlayerReplicationInfo.PlayerName);
    }
    else
    {
        // Give the messages if we missed our heal, can't find a target, etc
		if ( KFPlayerController(Instigator.Controller) != none )
		{
			if ( LastHealAttempt + HealAttemptDelay < Level.TimeSeconds)
			{
				PlayerController(Instigator.controller).ClientMessage(NoHealTargetMessage, 'CriticalEvent');
				LastHealAttempt = Level.TimeSeconds;
			}

			if ( Level.TimeSeconds - LastHealMessageTime > HealMessageDelay )
			{
				// if there's a Player within 2 meters who needs healing, say that we're trying to heal them
				foreach Instigator.VisibleCollidingActors(class'KFHumanPawn', Healtarget, 100)
				{
					if ( Healtarget != Instigator && Healtarget.Health < Healtarget.HealthMax )
					{
						PlayerController(Instigator.Controller).Speech('AUTO', 5, "");
						LastHealMessageTime = Level.TimeSeconds;

						break;
					}
				}
			}
		}
    }
}

// do the animations, etc
simulated function SuccessfulHeal()
{
    if( Weapon.Role < Role_Authority )
    {
        super.ModeDoFire();
    }
}

Function Timer()
{
	local KFPlayerReplicationInfo PRI;
	local int MedicReward;
	local KFHumanPawn Healed;
	local float HealSum; // for modifying based on perks

	Healed = CachedHealee;
	CachedHealee = none;
	
	HealSum = StimulatorLLI(Weapon).HealBoostAmount;

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		HealSum *= ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetHealPotency(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo)) - 1.0 ) * 2.0;
	}

	Weapon.ConsumeAmmo(ThisModeNum, AmmoPerFire);
	/*SRStatsBase(Instigator.PlayerReplicationInfo.SteamStatsAndAchievements).AddDamageHealed(-100-HealSum);*/
	SRHumanPawn(Healed).Stimulate( HealSum, 60.0 + 1.0 * KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkillLevel );
	PlayerController(Healed.Controller).ClientMessage("YOU HAS BEEN STIMULATED. BE AWARE!", 'KFCriticalEvent');
}

function KFHumanPawn GetHealee()
{
	local KFHumanPawn KFHP, BestKFHP;
	local vector Dir;
	local float TempDot, BestDot;

	Dir = vector(Instigator.GetViewRotation());

	foreach Instigator.VisibleCollidingActors(class'KFHumanPawn', KFHP, 80.0)
	{
		if ( KFHP.Health > 0 )
		{
			TempDot = Dir dot (KFHP.Location - Instigator.Location);
			if ( TempDot > 0.7 && TempDot > BestDot )
			{
				BestKFHP = KFHP;
				BestDot = TempDot;
			}
		}
	}

	return BestKFHP;
}

function bool AllowFire()
{
//	if ( !KFGameReplicationInfo(KFGameType(Level.Game).GameReplicationInfo).bWaveInProgress )
//		return false;
	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.default.PerkIndex != 0 )
		return false;
	return Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire;
}

// Can we find someone to heal
function bool CanFindHealee()
{
	local KFHumanPawn Healtarget;

	Healtarget = GetHealee();
	CachedHealee = Healtarget;

	// Can't use Stimulator if we can't find a target
	if ( Healtarget == none )
	{
		if ( KFPlayerController(Instigator.Controller) != none )
		{
			KFPlayerController(Instigator.Controller).CheckForHint(53);
		}

		return false;
	}

    return true;
}

event ModeDoFire()
{
	// Try and heal on the server
    if( Weapon.Instigator.IsLocallyControlled() )
	{
       StimulatorLLI(Weapon).ServerAttemptHeal();
	}
}

defaultproperties
{
     HealAttemptDelay=0.500000
     HealMessageDelay=10.000000
     NoHealTargetMessage="You must be near another player to inject them!"
     InjectDelay=0.360000
     bWaitForRelease=True
     FireAnim="Fire"
     FireRate=2.800000
     AmmoPerFire=1
	 Ammoclass=class'StimulatorLLIAmmo'
}
