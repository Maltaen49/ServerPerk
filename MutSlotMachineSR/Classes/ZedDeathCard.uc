Class ZedDeathCard extends SlotCard;

static function float ExecuteCard( Pawn Target )
{
	local Reaper R;
	local KFMonster M;
	local Controller C;

	R = Class'InstaDeathCard'.Static.SummonReaper(Target);
	if( R==None )
		return 0.f; // FAIL!

	for( C=Target.Level.ControllerList; C!=None; C=C.nextController )
	{
		M = KFMonster(C.Pawn);
		if( M!=None && M.Health>0 && VSize(M.Location-Target.Location)<8000 )
			R.AddVictim(M);
	}

	Target.PlaySound(Sound'RevebBell',SLOT_None,2,,1000.f);
	if( PlayerController(Target.Controller)!=None )
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'ZedDeathMessage');
	return 10.f;
}

defaultproperties
{
	CardMaterial=Texture'KillingFloor2HUD.Achievements.Achievement_57'
	Desireability=0.1
}