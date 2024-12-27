class HeadMessage extends ToxicMessage;

var localized string SmallHeadStr;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject )
{
	if( Switch==0 )
		return Default.Message;
	return Default.SmallHeadStr;
}

defaultproperties
{
	DrawColor=(R=255,G=255,B=0,A=255)
	Message="Your head just grew in size!"
	SmallHeadStr="You felt an extreme head shrinking!"
}