Class PipeSelfDestBCard extends SlotCard;

static function float ExecuteCard( Pawn Target )
{
	local PipeBombProjectile P;

	foreach Target.DynamicActors(Class'PipeBombProjectile',P)
		if( !P.bEnemyDetected )
		{
			P.bEnemyDetected = true;
			P.SetTimer(0.15,True);
		}
	Target.BroadcastLocalizedMessage(Class'PipeSelfDestBMessage',,Target.PlayerReplicationInfo);
	return 0;
}

defaultproperties
{
	CardMaterial=Texture'KillingFloorHUD.Achievements.Achievement_23'
	Desireability=0.07
}