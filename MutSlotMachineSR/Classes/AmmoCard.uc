Class AmmoCard extends SlotCard;

static function float ExecuteCard( Pawn Target )
{
	local Inventory I;

	Target.PlaySound( Class'KFAmmoPickup'.Default.PickupSound,SLOT_None,2);
	for( I=Target.Inventory; I!=None; I=I.Inventory )
		if( Weapon(I)!=None )
			Weapon(I).MaxOutAmmo();
	if( PlayerController(Target.Controller)!=None )
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'AmmoMessage');
	return 0;
}

defaultproperties
{
	CardMaterial=Texture'KillingFloorHUD.HUD.Hud_Bullets'
}