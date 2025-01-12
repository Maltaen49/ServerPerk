Class MonsterSpawnCard extends SlotCard;

var class<LocalMessage> SpawnMessage;
var class<xPawn> MonsterClass;
var() config int NumMonsters;
var bool bIgnoreWaveDownTime;

static function float ExecuteCard( Pawn Target )
{
	local int i,c;
	local KFGameType K;

	K = KFGameType(Target.Level.Game);
	if( !Default.bIgnoreWaveDownTime && K!=None && !K.bWaveBossInProgress && !K.bWaveInProgress )
	{
		if( PlayerController(Target.Controller)!=None )
			PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'NoMonstersMessage');
		return 0;
	}
	for( i=0; i<30; ++i )
		if( TryToSpawn(Target) && ++c>=Default.NumMonsters )
			break;
	if( PlayerController(Target.Controller)!=None )
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Default.SpawnMessage);
	return 0;
}
static final function bool TryToSpawn( Pawn A )
{
	local vector V,E,HL,HN;
	local xPawn M;

	E.X = A.CollisionRadius*0.8;
	E.Y = E.X;
	E.Z = A.CollisionHeight*0.8;
	V.X = FRand()-0.5f;
	V.Y = FRand()-0.5f;
	V = Normal(V)*(400+FRand()*300);
	V+=A.Location;
	if( A.Trace(HL,HN,V,A.Location,false,E)!=None )
		V = HL;
	M = A.Spawn(Default.MonsterClass,,,V,rotator(A.Location-V));
	if( M==None )
		return false;
	if( M.Controller!=None )
		M.Controller.SeePlayer(A);
	return true;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.CardGroup,"NumMonsters",Default.Class.Name$"-Count",1,0, "Text", "4;1:99");
}
static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "NumMonsters":	return "How many monsters spawn.";
	}
	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
	NumMonsters=1
	Desireability=0.8
}