Class MaskCard extends SantaHatCard;

static function float ExecuteCard( Pawn Target )
{
	local byte i;

	if( Vehicle(Target)!=None )
	{
		Target = Vehicle(Target).Driver;
		if( Target==None )
			return 0;
	}
	i = GiveHat(Target,Rand(4)+1);
	if( PlayerController(Target.Controller)!=None )
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'MaskMessage',i);
	return 0;
}

defaultproperties
{
	CardMaterial=Texture'I_Pumpkin'
}