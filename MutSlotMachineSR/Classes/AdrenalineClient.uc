Class AdrenalineClient extends Info;

function PostBeginPlay()
{
	Instigator.Health = 500;
	SetTimer(Class'AdrenalineCard'.Default.AdrenalineTime,false);
}
function Timer()
{
	Destroy();
}
function Tick( float Delta )
{
	if( Instigator==None || Instigator.Health<=0 )
		Destroy();
}
function Destroyed()
{
	if( Instigator!=None )
		Instigator.Health = Min(Instigator.Health,100);
}

defaultproperties
{
	RemoteRole=ROLE_None
}