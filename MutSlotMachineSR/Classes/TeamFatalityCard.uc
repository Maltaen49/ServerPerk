Class TeamFatalityCard extends SlotCard;

#exec AUDIO IMPORT FILE="Sounds\lightn5a.wav" NAME="LightningStrike" GROUP="FX"

static function float ExecuteCard( Pawn Target )
{
	local Controller C;

	for( C=Target.Level.ControllerList; C!=None; C=C.nextController )
		if( C.bIsPlayer && C.Pawn!=None && C.Pawn.Health>0 && (PlayerController(C)!=None || Bot(C)!=None) )
		{
			C.Pawn.Health = 1;
			if( xPawn(C.Pawn)!=None )
			{
				xPawn(C.Pawn).ShieldStrength = 0;
				xPawn(C.Pawn).SmallShieldStrength = 0;
			}
			C.Pawn.TakeDamage(0,None,vect(0,0,0),vect(0,0,0),Class'DamageType'); // Make player do near death scream.
			C.Pawn.PlaySound( Sound'LightningStrike',SLOT_None,2);
			if( PlayerController(C)!=None )
				PlayerController(C).ReceiveLocalizedMessage(Class'TeamFatalityMessage',,Target.Controller.PlayerReplicationInfo);
		}
	return 0;
}

defaultproperties
{
	CardMaterial=Texture'KillingFloorHUD.Achievements.Achievement_36'
	Desireability=0.05
}