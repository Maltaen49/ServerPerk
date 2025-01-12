Class CashCard extends SlotCard;

static function float ExecuteCard( Pawn Target )
{
	local int Amount;

	Target.PlaySound( Class'CashPickup'.Default.PickupSound,SLOT_None,2);
	Amount = 400+Rand(8)*50;
	Target.Controller.PlayerReplicationInfo.Score += Amount;
	if( PlayerController(Target.Controller)!=None )
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'CashMessage',Amount);
	return 0;
}

defaultproperties
{
	CardMaterial=Texture'KillingFloorHUD.Achievements.Achievement_37'
}