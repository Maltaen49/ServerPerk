Class PawnHatModel extends Actor;

var Pawn PawnOwner,OldOwner;
var byte ModelIndex,OldModelIndex;
var PawnHatMesh HatMesh;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		PawnOwner,ModelIndex;
}

function PostBeginPlay()
{
	PawnOwner = Pawn(Owner);
}
simulated function PostNetReceive()
{
	if( PawnOwner!=OldOwner || OldModelIndex!=ModelIndex )
	{
		OldModelIndex = ModelIndex;
		OldOwner = PawnOwner;
		if( PawnOwner!=None )
			SetModel(ModelIndex);
	}
}
simulated final function SetModel( byte Num )
{
	ModelIndex = Num;
	if( Level.NetMode!=NM_DedicatedServer )
	{
		if( HatMesh!=None && HatMesh.PawnOwner!=PawnOwner )
			HatMesh.Destroy();
		if( HatMesh==None )
		{
			HatMesh = Spawn(class'PawnHatMesh');
			HatMesh.PawnOwner = PawnOwner;
		}
		HatMesh.SetModel(Num);
	}
}
function Tick( float Delta )
{
	if( PawnOwner==None || PawnOwner.Health<=0 )
		Destroy();
}

final function bool HatMatches( Pawn Target, byte Index )
{
	return (Target==PawnOwner && (Index==ModelIndex || (Index>0 && ModelIndex>0)));
}

defaultproperties
{
	DrawType=DT_None
	RemoteRole=ROLE_SimulatedProxy
	bSkipActorPropertyReplication=true
	Physics=PHYS_Trailer
	bNetNotify=true
}