Class CashShareCard extends SlotCard;

static function float ExecuteCard( Pawn Target )
{
	local int Amount,PLCount,PerPlayerCash;
	local Controller C;

	for( C=Target.Level.ControllerList; C!=None; C=C.nextController )
		if( C.bIsPlayer && C.Pawn!=Target && C.Pawn!=None && C.Pawn.Health>0 && (PlayerController(C)!=None || Bot(C)!=None) )
			++PLCount;

	if( PLCount>0 )
	{
		PerPlayerCash = int(Target.Controller.PlayerReplicationInfo.Score/(PLCount+1));
		if( PerPlayerCash>0 )
		{
			for( C=Target.Level.ControllerList; C!=None; C=C.nextController )
				if( C.bIsPlayer && C.Pawn!=Target && C.Pawn!=None && C.Pawn.Health>0 && (PlayerController(C)!=None || Bot(C)!=None) )
				{
					C.PlayerReplicationInfo.Score += PerPlayerCash;
					Amount+=PerPlayerCash;
					C.Pawn.PlaySound( Class'CashPickup'.Default.PickupSound,SLOT_None,2);
					if( PlayerController(C)!=None )
						PlayerController(C).ReceiveLocalizedMessage(Class'CashDonateMessage',PerPlayerCash,Target.Controller.PlayerReplicationInfo);
				}
		}
		Target.PlaySound( Class'CashPickup'.Default.PickupSound,SLOT_None,2);
		Amount = Min(Target.Controller.PlayerReplicationInfo.Score,Amount);
	}
	Target.Controller.PlayerReplicationInfo.Score -= Amount;
	if( PlayerController(Target.Controller)!=None )
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'CashShareMessage',Amount);
	return 0;
}

defaultproperties
{
	CardMaterial=Texture'KillingFloorHUD.HUD.Hud_Pound_Symbol'
	Desireability=0.8
}