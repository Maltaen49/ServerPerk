Class HolyGrenadeCard extends SlotCard;

#exec obj load file="HHMesh.usx" Package="MutSlotMachineSR.HolyGrenade"

var config float UnholyGrenadeRatio;

static function float ExecuteCard( Pawn Target )
{
	local Inventory I;

	if( Vehicle(Target)!=None )
	{
		Target = Vehicle(Target).Driver;
		if( Target==None )
			return 0;
	}
	I = Target.FindInventoryType(Class'HolyHandGrenade');
	if( I==None )
	{
		/*if( FRand()<(Default.UnholyGrenadeRatio/100.f) )
			I = Target.Spawn(Class'UnHolyHandGrenade');
		else */I = Target.Spawn(Class'HolyHandGrenade');
		if( I!=None )
		{
			I.GiveTo(Target);
			Weapon(I).ClientWeaponSet(true);
		}
	}
	if( PlayerController(Target.Controller)!=None )
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'HGrenadeMessage');
	return 0;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.CardGroup,"UnholyGrenadeRatio",Default.Class.Name$"-UnholyRatio",1,0, "Text", "8;0.00:100.00");
}
static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "UnholyGrenadeRatio":	return "How big chance is there to get Unholy Hand Grenade.";
	}
	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
	CardMaterial=Texture'I_HolyGrenade'
	UnholyGrenadeRatio=15
	Desireability=0.08
}