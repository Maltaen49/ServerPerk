Class SantaHatCard extends SlotCard;

#exec obj load file="Meshes.usx" Package="MutSlotMachineSR.Masks"

static function float ExecuteCard( Pawn Target )
{
	local byte i;

	if( Vehicle(Target)!=None )
	{
		Target = Vehicle(Target).Driver;
		if( Target==None )
			return 0;
	}
	i = GiveHat(Target,0);
	if( PlayerController(Target.Controller)!=None )
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'HatMessage',i);
	return 0;
}
static final function int GiveHat( Pawn Target, byte Index )
{
	local PawnHatModel PH;

	foreach Target.DynamicActors(Class'PawnHatModel',PH)
		if( PH.HatMatches(Target,Index) )
		{
			PH.SetModel(Index);
			return 1;
		}
	PH = Target.Spawn(Class'PawnHatModel',Target);
	PH.SetModel(Index);
	return 0;
}

defaultproperties
{
	CardMaterial=Texture'I_Santa'
}