class HatMessage extends ToxicMessage;

var localized string FailedGiveStr;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject )
{
	if( Switch==0 )
		return Default.Message;
	return Default.FailedGiveStr;
}

defaultproperties
{
	DrawColor=(R=255,G=0,B=0,A=255)
	Message="You were given a santa hat, hohoho!"
	FailedGiveStr="You already had one santa hat!"
}