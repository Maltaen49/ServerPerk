Class StarmanCard extends SlotCard;

var() config float StarmanTime;

static function float ExecuteCard( Pawn Target )
{
	Target.Spawn(Class'StarmanClient',Target);
	if( PlayerController(Target.Controller)!=None )
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'StarmanMessage');
	return Default.StarmanTime+1;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.CardGroup,"StarmanTime",Default.Class.Name$"-Time",1,0, "Text", "8;1.00:999.00");
}
static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "StarmanTime":	return "How long starman mode stays on.";
	}
	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
	CardMaterial=Texture'KillingFloor2HUD.Perk_Icons.Hud_Perk_Star_Gold'
	StarmanTime=30
	Desireability=0.1
}