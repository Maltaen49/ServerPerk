class TeamFatalityMessage extends ToxicMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject )
{
	return Default.Message@Eval(RelatedPRI_1!=None,RelatedPRI_1.PlayerName,"someone")$"!";
}

defaultproperties
{
	Message="You had all your armor and health taken away by"
	DrawColor=(R=200,G=0,B=0,A=255)
	Lifetime=6
}