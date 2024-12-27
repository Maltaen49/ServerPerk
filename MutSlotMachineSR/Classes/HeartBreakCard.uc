Class HeartBreakCard extends SlotCard;

static function float ExecuteCard( Pawn Target )
{
	Target.Health = Max(Target.Health>>1,1);
	if( PlayerController(Target.Controller)!=None )
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'HeartBMessage');
	return 0;
}

defaultproperties
{
	CardMaterial=Texture'KillingFloorHUD.Achievements.Achievement_40'
}