Class CashJackpotCard extends SlotCard;

static function float ExecuteCard( Pawn Target )
{
	local int Amount;

	Target.PlaySound( Class'CashPickup'.Default.PickupSound,SLOT_None,2);
	Amount = 2000+Rand(21)*100;
	Target.Controller.PlayerReplicationInfo.Score += Amount;
	if( PlayerController(Target.Controller)!=None )
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'CashMessage',Amount);
	return 0;
}

defaultproperties
{
	CardMaterial=Texture'KillingFloorHUD.Achievements.Achievement_17'
	Desireability=0.08
}