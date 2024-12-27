Class PawnHatMesh extends Effects
	transient;

var StaticMesh Models[5];
var vector RelativePos[5];
var rotator RelativeRot[5];
var float Scaling[5];
var Pawn PawnOwner;

simulated final function SetModel( byte Num )
{
	SetStaticMesh(Models[Num]);
	SetDrawScale(Scaling[Num]);
	PawnOwner.AttachToBone(Self,PawnOwner.HeadBone);
	SetRelativeLocation(RelativePos[Num]);
	SetRelativeRotation(RelativeRot[Num]);
}
simulated function Tick( float Delta )
{
	if( PawnOwner==None )
		Destroy();
}

defaultproperties
{
	Models(0)=StaticMesh'SantaHatMesh'
	RelativePos(0)=(X=6)
	RelativeRot(0)=(Roll=16384,Yaw=-16384)
	Scaling(0)=0.6

	Models(1)=StaticMesh'FrankBunnyMask'
	RelativeRot(1)=(Pitch=-16384)
	Scaling(1)=0.65

	Models(2)=StaticMesh'PumpkinHead'
	RelativePos(2)=(X=2)
	RelativeRot(2)=(Roll=16384,Yaw=-16384)
	Scaling(2)=0.25

	Models(3)=StaticMesh'SkullMask'
	RelativeRot(3)=(Pitch=-16384)
	Scaling(3)=0.65

	Models(4)=StaticMesh'HockeyMask'
	RelativeRot(4)=(Pitch=-16384)
	Scaling(4)=0.65

	DrawType=DT_StaticMesh
	bDramaticLighting=true
	bUnlit=false
}