Class GeoViewClient extends Info;

var bool bViewSet;

function PostBeginPlay()
{
	SetTimer(Class'GeoViewCard'.Default.ViewTime,false);
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

simulated function PostNetBeginPlay()
{
	if( bNetOwner || Level.GetLocalPlayerController()==Owner )
	{
		bViewSet = true;
		Level.GetLocalPlayerController().RendMap = 1;
	}
}
simulated function Destroyed()
{
	if( bViewSet )
		Level.GetLocalPlayerController().RendMap = 5;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bSkipActorPropertyReplication=true
	bOnlyRelevantToOwner=true
}