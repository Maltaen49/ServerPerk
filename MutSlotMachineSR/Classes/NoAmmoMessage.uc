class NoAmmoMessage extends ToxicMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject )
{
	return Default.Message@Eval(RelatedPRI_1!=None,RelatedPRI_1.PlayerName,"somebody")$"!";
}

defaultproperties
{
	DrawColor=(R=255,G=0,B=255,A=255)
	Message="You just lost all of your ammo because of"
}