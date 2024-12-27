Class TeamNoAmmoCard extends SlotCard;

#exec Texture Import File=NoAmmo.pcx Name=I_NoAmmo Mips=Off MASKED=1

static function float ExecuteCard( Pawn Target )
{
	local Controller C;
	local Inventory I;

	for( C=Target.Level.ControllerList; C!=None; C=C.nextController )
		if( C.bIsPlayer && C.Pawn!=None && C.Pawn.Health>0 && (PlayerController(C)!=None || Bot(C)!=None) )
		{
			for( I=C.Pawn.Inventory; I!=None; I=I.Inventory )
				if( Weapon(I)!=None )
				{
					Weapon(I).ConsumeAmmo(0,999,true);
					Weapon(I).ConsumeAmmo(1,999,true);
					if( KFWeapon(I)!=None )
						KFWeapon(I).MagAmmoRemaining = 0;
				}
			C.Pawn.PlaySound( Class'KFAmmoPickup'.Default.PickupSound,SLOT_None,2);
			if( PlayerController(C)!=None )
				PlayerController(C).ReceiveLocalizedMessage(Class'NoAmmoMessage',,Target.Controller.PlayerReplicationInfo);
		}
	return 0;
}

defaultproperties
{
	CardMaterial=Texture'I_NoAmmo'
	Desireability=0.06
}