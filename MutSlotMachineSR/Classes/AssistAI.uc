class AssistAI extends KFFriendlyAI;

var KFPawn FollowHuman;
var bool bCamp;

State InitilizingMe
{
ignores HearNoise, KilledBy, NotifyBump, HitWall, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling, TakeDamage, ReceiveWarning;

	event SeePlayer(Pawn SeenPlayer)
	{
		if( FollowHuman==None && SeenPlayer.Health>0 && KFPawn(SeenPlayer)!=None && KFHumanPawnEnemy(SeenPlayer)==None )
			FollowHuman = KFPawn(SeenPlayer);
	}
}

function WanderOrCamp(bool bMayCrouch)
{
	GoToState('Wandering');
}

event SeePlayer(Pawn SeenPlayer)
{
	if( FollowHuman==None && SeenPlayer.Health>0 && KFPawn(SeenPlayer)!=None && KFHumanPawnEnemy(SeenPlayer)==None )
		FollowHuman = KFPawn(SeenPlayer);
	else Super.SeePlayer(SeenPlayer);
}

state Wandering
{
ignores EnemyNotVisible,Timer;

	function PickDestination()
	{
		if( FollowHuman==None || FollowHuman.Health<=0 )
		{
			FollowHuman = None;
			bCamp = (Rand(2)==0);
			if( !bCamp )
				Destination = Pawn.Location + VRand()*500.f;
			return;
		}
		if( VSizeSquared(FollowHuman.Location-Pawn.Location)<360000.f && LineOfSightTo(FollowHuman) )
		{
			bCamp = true;
			return;
		}
		if( FindBestPathToward(FollowHuman,false,false) )
			return;
		Destination = Pawn.Location + VRand()*500.f;
	}

Begin:
	bCamp = false;
	while( true )
	{
		WaitForLanding();
		PickDestination();
		if( bCamp )
		{
			bCamp = false;
			Pawn.Acceleration = vect(0,0,0);
			Focus = None;
			FocalPoint = Pawn.Location+VRand()*500;
			NearWall(MINVIEWDIST);
			FinishRotation();
			Sleep(1.f + FRand());
		}
		Pawn.bIsWalking = false;
		Pawn.bWantsToCrouch = false;
		if( MoveTarget!=None )
			MoveToward(MoveTarget,MoveTarget);
		else MoveTo(Destination);
	}
}

defaultproperties
{
}