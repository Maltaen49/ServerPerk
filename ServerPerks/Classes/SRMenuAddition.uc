// Can be used to add custom GUI components to Esc menu.
class SRMenuAddition extends ReplicationInfo
	abstract;

var PlayerController PlayerOwner;
var SRInvasionLoginMenu ActiveMenu;
var bool bHasInit;

replication
{
	// Functions server can call.
	reliable if( Role==ROLE_Authority )
		RepInit;
}

function PostBeginPlay()
{
	PlayerOwner = PlayerController(Owner);
	GoToState('ServerIdle');
}
simulated function PostNetBeginPlay()
{
	bHasInit = true;
}
simulated function RepInit()
{
	// Do nothing, simply to force server initiate actor channel immeaditly.
}
simulated function NotifyMenuOpen( SRInvasionLoginMenu M, GUIController C )
{
	ActiveMenu = M;
}
simulated function NotifyMenuShown();
simulated function NotifyMenuClosed();

simulated function RemoveComponents(); // Unhook the custom menu buttons here so game doesn't crash.

simulated function Destroyed()
{
	local int i;

	if( ActiveMenu!=None )
	{
		for( i=0; i<ActiveMenu.AddOnList.Length; ++i )
			if( ActiveMenu.AddOnList[i]==Self )
			{
				ActiveMenu.AddOnList.Remove(i,1);
				break;
			}
		RemoveComponents();
		ActiveMenu = None;
	}
}

state ServerIdle
{
	function PostNetBeginPlay();
Begin:
	Sleep(0.1);
	if( PlayerOwner==None || PlayerOwner.Player==None )
		Destroy();
	if( Viewport(PlayerOwner.Player)!=None )
	{
		Global.PostNetBeginPlay();
		GoToState('LocalHost');
	}
	else RepInit();
	Sleep(2.f);
	NetUpdateFrequency = 0.2;
	while( PlayerOwner!=None )
		Sleep(0.8);
	Destroy();
}
state LocalHost
{
Begin:
	RemoteRole = ROLE_None;
	while( PlayerOwner!=None )
		Sleep(0.8);
	Destroy();
}

defaultproperties
{
     bOnlyRelevantToOwner=True
     bAlwaysRelevant=False
     NetUpdateFrequency=100.000000
}
