Class Reaper extends Monster;

#exec obj load file="Poe.ukx" Package="MutSlotMachineSR.GrimReaper"

var byte AttackCounter;
var Actor HitTarget;
var bool bAttackingAnim,bFlyingAnim;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		AttackCounter;
}

final function AddVictim( Pawn Other )
{
	local ReaperAI R;
	local int i;

	R = ReaperAI(Controller);
	for( i=0; i<R.Victims.Length; ++i )
		if( R.Victims[i]==Other )
			return;
	R.Victims[R.Victims.Length] = Other;
}

simulated function PostNetBeginPlay()
{
	LoopAnim('Idle');
	AttackCounter = 0;
	bNetNotify = true;
	if( Level.NetMode!=NM_DedicatedServer )
	{
		SetTimer(0.25,true);
		Spawn(Class'ReaperFX');
	}
}
simulated function Destroyed()
{
	if( Level.NetMode!=NM_DedicatedServer )
		Spawn(Class'ReaperFX');
	Super.Destroyed();
}
simulated function PostNetReceive()
{
	if( AttackCounter>0 )
	{
		PlayAnim('Swing',,0.2f);
		AttackCounter = 0;
		bAttackingAnim = true;
	}
}
simulated function Timer()
{
	if( bAttackingAnim )
		return;
	if( VSize(Velocity)>50.f )
	{
		if( !bFlyingAnim )
		{
			LoopAnim('Fly',,0.25f);
			bFlyingAnim = true;
		}
	}
	else if( bFlyingAnim )
	{
		bFlyingAnim = false;
		LoopAnim('Idle',,0.25f);
	}
}
simulated function AnimEnd(int Channel)
{
	if( !bAttackingAnim )
		return;
	bAttackingAnim = false;
	bFlyingAnim = false;
	if( Level.NetMode!=NM_DedicatedServer )
		LoopAnim('Idle',,0.1f);
	if( Level.NetMode!=NM_Client )
		AttackCounter = 0;
}

function KillTarget( Actor A )
{
	HitTarget = A;
	Controller.Focus = A;
	bAttackingAnim = true;
	PlayAnim('Swing');
	++AttackCounter;
}

singular function Falling()
{
	SetPhysics(PHYS_Flying);
}
function SetMovementPhysics()
{
	SetPhysics(PHYS_Flying); 
}
function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex);
function Died( Controller Killer, class<DamageType> damageType, vector HitLocation );
function HeadVolumeChange( PhysicsVolume newHeadVolume );

function SwingDamage()
{
	if( HitTarget!=None )
	{
		HitTarget.TakeDamage(3000,Self,HitTarget.Location,vect(0,0,0),Class'DamageType');
		PlaySound(Sound'axehitflesh',SLOT_Misc,2);
	}
}

function ModifyVelocity(float DeltaTime, vector OldVelocity)
{
	if( bAttackingAnim && HitTarget!=None )
		Velocity = HitTarget.Velocity; // Follow victim dead on.
}

defaultproperties
{
	Physics=PHYS_Flying
	ControllerClass=Class'ReaperAI'
	Mesh=Mesh'PoeMesh'
	Skins(0)=FinalBlend'JReaperFB'
	bCollideWorld=false
	bCollideActors=false
	AirSpeed=600
	AirControl=1
	bNetNotify=false
	bPhysicsAnimUpdate=false
	CollisionHeight=30
	CollisionRadius=10
	bCanFly=true
	bCanSwim=true
	SightRadius=1
	MenuName="Reaper"
	bBoss=true
	bUnlit=true
	AmbientGlow=250
	DrawScale=0.7
	bAlwaysRelevant=true
	MovementAnims(0)="Idle"
}