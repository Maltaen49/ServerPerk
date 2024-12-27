Class UHGrenade extends HGrenade;

#exec AUDIO IMPORT FILE="UnholyBlowup.WAV" NAME="UnholyBlowup" GROUP="FX"

simulated function Explode(vector HitLocation, vector HitNormal)
{
	bHasExploded = True;

	if( Level.NetMode!=NM_DedicatedServer )
		PlaySound(Sound'UnholyBlowup',SLOT_None,2.0);
	if( Level.NetMode!=NM_Client )
		Spawn(Class'BlackHoleProj');

	Destroy();
}

defaultproperties
{
	Skins(0)=Texture'UnholyGrenade'
}