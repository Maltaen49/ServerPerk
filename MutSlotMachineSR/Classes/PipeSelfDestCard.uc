Class PipeSelfDestCard extends SlotCard;

static function float ExecuteCard( Pawn Target )
{
	local PipeBombProjectile P;

	foreach Target.DynamicActors(Class'PipeBombProjectile',P)
		if( P.Instigator==Target && !P.bEnemyDetected )
		{
			P.bEnemyDetected = true;
			P.SetTimer(0.15,True);
		}
	if( PlayerController(Target.Controller)!=None )
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'PipeSelfDestMessage');
	return 0;
}

defaultproperties
{
	CardMaterial=Texture'KillingFloor2HUD.HUD.Hud_Pipebomb'
	Desireability=0.35
}