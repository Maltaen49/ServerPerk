Class HGrenade extends Nade;

#exec AUDIO IMPORT FILE="Hallelujah.WAV" NAME="Hallelujah" GROUP="FX"

var HHGTrail HTrail;
var bool bDoneHale;

simulated function PostBeginPlay()
{
	if( Level.NetMode!=NM_DedicatedServer )
		HTrail = Spawn(Class'HHGTrail',Self);
	Super.PostBeginPlay();
}
simulated function Destroyed()
{
	if( HTrail!=None )
		HTrail.Destroy();
	Super.Destroyed();
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex);

function Timer()
{
	if( !bHidden )
	{
		if( !bDoneHale )
		{
			bDoneHale = true;
			PlaySound(Sound'Hallelujah',SLOT_Misc,2.0);
			SetTimer(2.1,false);
		}
		else Explode(Location, vect(0,0,1));
	}
	else Destroy();
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController  LocalPlayer;
	local Projectile P;
	local byte i;

	bHasExploded = True;
	BlowUp(HitLocation);

	// Shrapnel
	for( i=Rand(8); i<20; i++ )
	{
		P = Spawn(ShrapnelClass,,,,RotRand(True));
		if( P!=None )
			P.RemoteRole = ROLE_None;
	}

	if( Level.NetMode!=NM_DedicatedServer )
	{
		PlaySound(ExplodeSounds[0],SLOT_None,2.0);
		PlaySound(ExplodeSounds[0],SLOT_Misc,2.0);

		Spawn(Class'HHGExplosion',,, HitLocation, rotator(vect(0,0,1)));
		if ( EffectIsRelevant(Location,false) )
			Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));

		// Shake nearby players screens
		LocalPlayer = Level.GetLocalPlayerController();
		if ( (LocalPlayer != None) && (VSize(Location - LocalPlayer.ViewTarget.Location) < (DamageRadius * 1.5)) )
		{
			LocalPlayer.ClientFlash(10.f,vect(1,1,1));
			LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
		}
	}

	Destroy();
}

defaultproperties
{
	Damage=3500
	DamageRadius=3000
	StaticMesh=StaticMesh'HHGrenadeSM'
	Speed=1500
	DrawScale=0.3
	bAlwaysRelevant=true
	ExplodeSounds(0)=Sound'Amb_Destruction.explosions.Expl_Brick_House01'
	TransientSoundVolume=2
	TransientSoundRadius=6000
	ExplodeTimer=4
	MomentumTransfer=1000000

	RotMag=(X=1600.000000,Y=1600.000000,Z=1600.000000)
	RotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
	RotTime=6.000000
	OffsetMag=(X=12.000000,Y=20.000000,Z=15.000000)
	OffsetRate=(X=400.000000,Y=400.000000,Z=400.000000)
	OffsetTime=3.500000
	CollisionHeight=4
	CollisionRadius=4
	MyDamageType=Class'DamTypeHHGren'
}