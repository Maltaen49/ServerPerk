//=============================================================================
// KFPawn
//=============================================================================
class AssistHuman extends KFHumanPawnEnemy;

function bool CanAttack(Actor Other)
{
	if( Weapon==None || Controller==None || !Controller.LineOfSightTo(Other) )
		return false;
	return true;
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local Inventory I,NI;

	// Leave no weapon drop.
	for( I=Inventory; I!=None; I=NI )
	{
		NI = I.Inventory;
		I.Destroy();
	}
	Super.Died(Killer,damageType,HitLocation);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional int HitIdx )
{
	// Reduce friendly fire by X4
	if( instigatedBy!=None )
	{
		if( KFPawn(instigatedBy)!=None )
			Damage = (Damage >> 2);
	}
	else if( DamageType.default.bDelayedDamage && (PlayerController(DelayedDamageInstigatorController)!=None || Bot(DelayedDamageInstigatorController)!=None) )
		Damage = (Damage >> 2);
	Super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType,HitIdx);
}

defaultproperties
{
	WeaponType=Class'M200SASniperRifle'
	ControllerClass=Class'AssistAI'
	MenuName="Friendly Soldier"
	SoldierOrders=ORDER_Wander
}