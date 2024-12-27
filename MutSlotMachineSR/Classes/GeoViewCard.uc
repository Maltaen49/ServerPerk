Class GeoViewCard extends SlotCard;

#exec Texture Import File=Textures\Matrix.pcx Name=I_Matrix Mips=Off Group="Icons"

var() config float ViewTime;

static function float ExecuteCard( Pawn Target )
{
	Target.PlaySound(Sound'AdrenalineOn',SLOT_None,2);
	if( PlayerController(Target.Controller)!=None )
	{
		Target.Spawn(Class'GeoViewClient',Target.Controller);
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'GeoViewMessage');
	}
	return Default.ViewTime;
}

defaultproperties
{
	CardMaterial=Texture'I_Matrix'
	ViewTime=120
	bNotForBots=true
}