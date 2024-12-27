Class NoDoshCard extends SlotCard;

#exec Texture Import File=NoDosh.pcx Name=I_NoDosh Mips=Off

var config float CashRemainScale;

static function float ExecuteCard( Pawn Target )
{
	local Controller C;

	for( C=Target.Level.ControllerList; C!=None; C=C.nextController )
		if( C.bIsPlayer && (PlayerController(C)!=None || Bot(C)!=None) && C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator )
		{
			C.PlayerReplicationInfo.Score = int(C.PlayerReplicationInfo.Score*Default.CashRemainScale);
			if( PlayerController(C)!=None )
				PlayerController(C).ReceiveLocalizedMessage(Class'NoDoshMessage');
		}
	return 0;
}

defaultproperties
{
	CardMaterial=Texture'I_NoDosh'
	Desireability=0.05
	CashRemainScale=0.1
}