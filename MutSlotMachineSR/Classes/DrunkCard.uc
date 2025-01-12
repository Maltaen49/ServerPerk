Class DrunkCard extends SlotCard;

#exec AUDIO IMPORT FILE="Sounds\burp.wav" NAME="BurpNoise" GROUP="FX"

var() config float DrunkenTime;

static function float ExecuteCard( Pawn Target )
{
	Target.PlaySound(Sound'BurpNoise',SLOT_None,2);
	if( PlayerController(Target.Controller)!=None )
	{
		Target.Spawn(Class'DrunkClient',Target.Controller);
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'DrunkMessage');
	}
	return Default.DrunkenTime;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.CardGroup,"DrunkenTime",Default.Class.Name$"-Time",1,0, "Text", "8;1.00:999.00");
}
static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "DrunkenTime":	return "How long player stays drunk.";
	}
	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
	CardMaterial=Texture'KillingFloorHUD.Achievements.Achievement_0'
	DrunkenTime=80
	bNotForBots=true
}