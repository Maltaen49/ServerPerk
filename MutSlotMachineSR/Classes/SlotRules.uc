Class SlotRules extends GameRules;

var MutSlotMachineSR Mut;

function ScoreKill(Controller Killer, Controller Killed)
{
	if( (PlayerController(Killer)!=None || Bot(Killer)!=None) && Killer.Pawn!=None && Monster(Killed.Pawn)!=None )
		Mut.AwardKill(Killer,Monster(Killed.Pawn));
	Super.ScoreKill(Killer,Killed);
}
