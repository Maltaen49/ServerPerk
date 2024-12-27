Class GodModeCard extends SlotCard;

var() config float GodModeTime;

static function float ExecuteCard( Pawn Target )
{
	Target.Spawn(Class'GodModeClient',Target);
	if( PlayerController(Target.Controller)!=None )
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'GodModeMessage');
	return Default.GodModeTime;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.CardGroup,"GodModeTime",Default.Class.Name$"-Time",1,0, "Text", "8;1.00:999.00");
}
static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "GodModeTime":	return "How player remains god mode.";
	}
	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
	CardMaterial=Texture'KillingFloor2HUD.Achievements.Achievement_171'
	GodModeTime=40
	Desireability=0.4
}