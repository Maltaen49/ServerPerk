class ToxicMessage extends LocalMessage;

var localized string Message;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject )
{
	return Default.Message;
}

defaultproperties
{
	bFadeMessage=True
	bIsUnique=True

	DrawColor=(R=0,G=255,B=0,A=255)
	FontSize=0

	PosY=0.8

	Message="You spilled vomit all over your face!"
	Lifetime=4
	StackMode=SM_Down
}