class CashDonateMessage extends ToxicMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject )
{
	return "You've been donated"@Switch@"pounds by"@Eval(RelatedPRI_1!=None,RelatedPRI_1.PlayerName,"someone")$"!";
}

defaultproperties
{
	DrawColor=(R=255,G=255,B=0,A=255)
}