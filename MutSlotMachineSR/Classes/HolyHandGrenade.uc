Class HolyHandGrenade extends KFWeapon
	CacheExempt;

var Pawn TempPawn;

simulated function AnimEnd(int channel)
{
	local name anim;
	local float frame, rate;

	GetAnimParams(0, anim, frame, rate);
	if( Anim!='Toss' )
		Super.AnimEnd(channel);
}

final function SwitchNextWeapon()
{
	TempPawn = Pawn(Owner);
	TempPawn.DeleteInventory(Self);
}

simulated function float RateSelf()
{
	if( Instigator!=None && Instigator.Weapon==Self )
		return -1;
	return Super.RateSelf();
}

State KillSelf
{
Ignores Timer,AnimEnd;

Begin:
	Sleep(0.8f);
	SwitchNextWeapon();
	Sleep(0.1f);
	TempPawn.Controller.ClientSwitchToBestWeapon();
	Destroy();
}

defaultproperties
{
	Skins(0)=Texture'Grenade'
	Skins(1)=Combiner'KF_Weapons_Trip_T.hands.hands_1stP_military_cmb'
	bKFNeverThrow=true
	Weight=0
	bCanThrow=false
	SleeveNum=1

	AttachmentClass=Class'HHFragAttachment'
	ItemName="Holy Hand Grenade"
	Mesh=SkeletalMesh'HHGrenadeMesh'
	TransientSoundVolume=1.000000
	TransientSoundRadius=700.000000

	DisplayFOV=90.000000
	StandardDisplayFOV=90.0
	AIRating=80
	CurrentRating=80
	InventoryGroup=1
	Priority=80
	PutDownAnim="Deselect"
	RestAnim="Idle"
	AimAnim="Idle"
	RunAnim="Idle"
	PlayerViewOffset=(X=0,Y=-18,Z=-18)
	SmallViewOffset=(X=0,Y=-18,Z=-18)

	FireModeClass(0)=Class'HHGFire'
	FireModeClass(1)=Class'NoFire'

	HudImage=TexScaler'IconScalar'
	SelectedHudImage=TexScaler'IconScalar'
}