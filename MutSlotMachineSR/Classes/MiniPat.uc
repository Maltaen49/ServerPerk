Class MiniPat extends HardPat;

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    super(ZombieBossBase).Died(Killer,damageType,HitLocation);
}
function bool MakeGrandEntry()
{
	return false;
}
state KnockDown
{
 Begin:
    GotoState('');
}
defaultproperties
{
	ScoringValue=350
	MenuName="Patriarch Jr."
}